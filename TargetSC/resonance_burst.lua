-- Analytic MB presentation only: no event publication or deadline changes.
-- One retained glyph responds to the latest confirmed burst. Author: A.
local M={max_duration=4}
function M.duration(opts)
    local duration=opts.mb_duration or 1.2
    if (opts.mb_style or 'clapper')=='classic'then return duration end
    return math.max(duration,math.max(opts.mb_hold or .12,duration*.375)+(opts.mb_return or .85))
end
local function clamp(x)return math.max(0,math.min(1,x))end
local function smooth(x)x=clamp(x)return x*x*(3-2*x)end
-- One energy envelope lands height, color and opacity together, with zero
-- velocity/acceleration at either end of the finite return interval.
function M.return_energy(age,start,duration)
    local u=clamp((age-start)/math.max(.001,duration))
    return 1-u*u*u*(10+u*(-15+6*u))
end
-- Each fresh source MB window announces its palette with one or two short
-- white flashes. Snapshots/reloads never replay an already active window.
function M.introduction(state,now,duration,flashes)
    local age=now-state.created
    if state.suppress_impact or state.source_expired or state.step<=1 or
        now>=state.mb_close or age<0 or duration<=0 or age>=duration then return 0 end
    local within=(age/duration*flashes)%1
    -- Brief full-strength plateau, quick fade, then a dark gap. The plateau
    -- makes the peak legible even when a source event falls between frames.
    return 1-smooth((within-.4)/.45)
end
-- The soft ending is strong / half-strength / strong. Hard uses three
-- rectangular white on/off flashes. Both fit, in order, inside one interval.
function M.ending(progress,style)
    if progress<0 or progress>=1 or style=='off'then return 0 end
    if style=='both'then
        style=progress<.5 and 'soft'or 'hard'
        progress=(progress*2)%1
    end
    local phase=progress*3
    local pulse=math.floor(phase)
    local within=phase-pulse
    if style=='hard'then return within<.5 and 1 or 0 end
    return (pulse==1 and .5 or 1)*math.sin(within*math.pi)^2
end
function M.sample(model,state,now,option)
    local duration=option('mb_duration')
    local effects=option('mb_effects')
    local clapper=option('mb_style')=='clapper'
    local left=math.max(0,state.mb_close-now)
    local active=not state.source_expired and left>0 and now>=state.created
    local out={idle=0,flash=0,rise=0,release=0,ring=0}
    if active then
        out.intro=M.introduction(state,now,option('mb_intro'),option('mb_intro_flashes'))*effects
        local age=math.max(0,now-state.created)
        local breathe=.5-.5*math.cos(age*2*math.pi/option('mb_period'))
        out.idle=option('mb_idle')*breathe*smooth(left)*effects
        if clapper then
            out.breath=option('mb_breath_min')+(1-option('mb_breath_min'))*breathe
            out.idle=option('mb_idle')*option('mb_breath_gain')*out.breath*
                smooth(left/option('mb_ending'))*effects
        end
        local ending=option('mb_ending')
        if left<=ending and option('mb_ending_style')~='off'then
            out.end_flash=M.ending(clamp(1-left/ending),option('mb_ending_style'))
            out.ending=true
            out.idle=option('mb_idle')*out.end_flash*effects
        end
    end
    local bursts=model.bursts[state.id]or {}
    for i=#bursts,1,-1 do
        local burst=bursts[i]
        local age=now-burst.at
        local lifetime=clapper and math.max(duration,math.max(option('mb_hold'),duration*.375)+option('mb_return'))or duration
        if age>lifetime then table.remove(bursts,i)
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
            if clapper then
                local return_at=math.max(option('mb_hold'),duration*.375)
                out.property=M.return_energy(age,return_at,option('mb_return'))*effects
                out.lift=option('mb_lift')*out.property
                out.shimmer=option('mb_shimmer')*math.exp(-age*3)*
                    (.55+.45*math.cos(age*2*math.pi*9))*out.property
                out.white=0 -- the new strike is immediately its burst element
                local t=smooth((age-option('mb_hold'))/math.max(.001,duration-option('mb_hold')))
                out.release=option('mb_burst')>0 and (1-t)*(1+(option('mb_burst')-1)*t)*effects or 0
            end
            out.responding=true
            break
        end
    end
    local glyph=model.awakening_glyphs and model.awakening_glyphs[state.id]
    if not out.responding and not out.ending and glyph and glyph.release_end then
        out.idle=out.idle*smooth((now-glyph.release_end)/.5)
    end
    -- A selected ending extinguishes the MB presentation at its real deadline.
    -- Do not let a late release reappear after those closing lights go out.
    -- With ending off, retain the original confirmed-burst tail comparison.
    if now>=state.mb_close and option('mb_ending_style')~='off'then
        out.release=0;out.flash=0;out.ring=0;out.responding=false
        out.property=0;out.lift=0;out.shimmer=0
    end
    return out
end
return M
