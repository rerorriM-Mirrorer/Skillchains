-- Analytic MB presentation only: no event publication or deadline changes.
-- One retained glyph responds to the latest confirmed burst. Author: A.
local M={max_duration=4}
function M.duration(opts)return opts.mb_duration or 1.2 end
local function clamp(x)return math.max(0,math.min(1,x))end
local function smooth(x)x=clamp(x)return x*x*(3-2*x)end
function M.sample(model,state,now,option)
    local duration=option('mb_duration')
    local effects=option('mb_effects')
    local left=math.max(0,state.mb_close-now)
    local active=not state.source_expired and left>0 and now>=state.created
    local out={idle=0,flash=0,rise=0,release=0,ring=0}
    if active then
        local age=math.max(0,now-state.created)
        local breathe=.5-.5*math.cos(age*2*math.pi/option('mb_period'))
        out.idle=option('mb_idle')*breathe*smooth(left)*effects
        local ending=option('mb_ending')
        if left<=ending then
            local progress=clamp(1-left/ending)*3
            local pulse=math.min(2,math.floor(progress))
            out.end_flash=(1-pulse/3)*math.sin((progress-pulse)*math.pi)^2
            out.ending=true
            out.idle=option('mb_idle')*out.end_flash*effects
        end
    end
    local bursts=model.bursts[state.id]or {}
    for i=#bursts,1,-1 do
        local burst=bursts[i]
        local age=now-burst.at
        if age>duration then table.remove(bursts,i)
        elseif age>=0 then
            local glyph=model.awakening_glyphs and model.awakening_glyphs[state.id]
            if glyph and glyph.release_last~=burst.at then
                -- A second burst recolors/rebrightens the active release;
                -- it must not teleport a still-visible glyph back to the floor.
                if not glyph.release_end or burst.at>=glyph.release_end then
                    glyph.release_started=burst.at
                end
                glyph.release_last=burst.at;glyph.release_end=burst.at+duration
            end
            out.element=burst.color
            out.flash=(1-smooth(age/(duration/3)))*effects
            out.ring=(1-smooth(age/(duration*.375)))*effects
            out.flicker=.5+.5*math.cos(age*2*math.pi*12)
            out.white=(1-smooth(age/(duration*.2916666667)))*out.flicker
            out.rise=smooth((now-(glyph and glyph.release_started or burst.at))/duration)
            out.release=option('mb_burst')*(1-smooth((age-duration*.1)/(duration*.9)))*effects
            out.responding=true
            break
        end
    end
    local glyph=model.awakening_glyphs and model.awakening_glyphs[state.id]
    if not out.responding and glyph and glyph.release_end then
        out.idle=out.idle*smooth((now-glyph.release_end)/.5)
    end
    return out
end
return M
