-- Reusable, deterministic HUD resonance effects. Source clocks belong to
-- Skillchains.lua. This file never interprets combat packets. Author: A.
local M={}
local sin,cos,exp,floor,max,min,pi=math.sin,math.cos,math.exp,math.floor,math.max,math.min,math.pi
local function clamp(n,a,b) return max(a,min(b,n)) end
local function smooth(t) t=clamp(t,0,1);return t*t*(3-2*t) end
local white={255,255,255}
local gold={249,207,103}
function M.new(prefix)
    local self={ids={},prefix=prefix or 'sc_resonance_fx_'}
    for _,name in ipairs({'wash','edge','pulse','pulse_halo','left','right',
        'left_halo','right_halo','moving','moving_halo','border_glow'}) do
        local id=self.prefix..name
        windower.prim.create(id)
        windower.prim.set_color(id,0,255,255,255)
        windower.prim.set_visibility(id,false)
        self.ids[name]=id
    end
    function self:hide()
        for _,id in pairs(self.ids) do windower.prim.set_visibility(id,false) end
    end
    local function draw(name,x,y,w,h,a,c)
        local id=self.ids[name]
        if a<=0 or w<=0 or h<=0 then
            windower.prim.set_visibility(id,false)
            return
        end
        windower.prim.set_color(id,floor(clamp(a,0,255)+.5),c[1],c[2],c[3])
        windower.prim.set_position(id,floor(x+.5),floor(y+.5))
        windower.prim.set_size(id,max(1,floor(w+.5)),max(1,floor(h+.5)))
        windower.prim.set_visibility(id,true)
    end
    function self:shake(state,opt)
        if not state or state.step<=1 or not opt.enabled then return 0 end
        local age=max(0,(state.now or 0)-(state.created or state.now))
        if age>.35 then return 0 end
        return floor(3*(opt.intensity or 1)*sin(75*age)*exp(-12*age)+.5)
    end
    function self:label_alpha(state,opt)
        if not state or not opt.enabled then return 1 end
        local age=max(0,(state.now or 0)-(state.created or state.now))
        local duration=max(.1,(state.sc_open or 0)-(state.created or 0))
        if state.step==1 and age<duration then
            local phase=3*age/duration
            return smooth(phase-2)
        end
        if state.step>1 and age<.3 then return .55+.45*smooth(age/.3) end
        return 1
    end
    function self:bar_fraction(state,opt)
        local fraction=clamp((state.sc_left or 0)/max(.01,state.sc_total or 8),0,1)
        if (state.sc_wait or 0)>0 then fraction=1 end
        if not opt.enabled or state.step<=1 then return fraction end
        local age=max(0,(state.now or 0)-(state.created or state.now))
        if age<.3 then
            local previous=clamp(state.from_fraction or .45,0,1)
            return previous+(1-previous)*smooth(age/.3)
        end
        return fraction
    end
    function self:opacity(state,opt)
        if not state then return 1 end
        if state.expire_age then return 1-smooth(state.expire_age/.35) end
        if not opt.enabled or not opt.fade or (state.sc_wait or 0)>0 then return 1 end
        local proportion=clamp((state.sc_left or 0)/max(.01,state.sc_total or 8),0,1)
        return (.30+.70*proportion)*(.82+.18*sin((state.now or 0)*pi*2.4)^2)
    end
    function self:render(state,opt,bar,palette)
        self:hide()
        if not state or not bar then return end
        opt=opt or {}
        local intensity=clamp(tonumber(opt.intensity) or 1,0,2)
        local enabled=opt.enabled~=false and intensity>0
        local x,y,w,h=bar.x,bar.y,bar.width,bar.height
        local fill=clamp(bar.fill or w,0,w)
        local age=max(0,(state.now or 0)-(state.created or state.now))
        local level=tonumber(state.level) or 0
        local c1=(palette and palette[1]) or white
        local c2=(palette and palette[#palette]) or c1
        local frame=bar.frame
        local border=white
        local border_alpha=180
        if level==1 then border=c1;border_alpha=222
        elseif level==2 then border=white;border_alpha=240
        elseif level==3 then border=white;border_alpha=255
        elseif level>=4 then border=gold;border_alpha=255 end
        if enabled and level>0 and age<.6 then
            border=white
            border_alpha=255
        end
        if not enabled then
            border=level==1 and c1 or (level>=4 and gold or
                (level>1 and white or {9,10,21}))
            border_alpha=level>0 and 222 or 180
        end
        for _,id in ipairs({frame.frame,frame.cap_l,frame.cap_r}) do
            windower.prim.set_color(id,border_alpha,border[1],border[2],border[3])
        end
        if not enabled then return end
        local i=intensity
        if level>=3 then
            local glow_alpha=(level==3 and 75 or 120)*i
            if level>=4 then glow_alpha=glow_alpha*(.7+.3*sin(age*21)^2) end
            draw('border_glow',x-2,y-2,w+4,h+4,glow_alpha,
                level>=4 and gold or white)
        end
        if state.expire_age then
            local a=100*(1-smooth(state.expire_age/.35))*i
            draw('wash',x+1,y+1,fill,h-2,a,c1)
            return
        end
        if state.step==1 then
            -- Fit the three perceived beats to the actual pre-window delay.
            -- No visual stage can extend the server-reported continuation clock.
            local duration=max(.10,(state.sc_open or 0)-(state.created or 0))
            local phase=3*age/duration
            if phase<1 then
                local t=smooth(phase)
                local end_x=w*t
                draw('wash',x+1,y+1,end_x,h-2,(130+125*sin(t*pi*.7))*i,white)
                draw('edge',x+end_x-2,y-3,max(2,4*i),h+6,210*i,white)
            elseif phase<2 then
                draw('wash',x+1,y+1,w-2,h-2,255*i*(1-smooth(phase-1)),white)
                local p=smooth(phase-1)
                draw('pulse_halo',x+w*p-8,y-1,16,h+2,110*i*(1-p*.5),white)
                draw('pulse',x+w*p-2,y,4,h,235*i*(1-p*.6),white)
            elseif phase<3 then
                local p=smooth(phase-2)
                draw('pulse_halo',x+w*p-8,y-1,16,h+2,100*i,c1)
                draw('pulse',x+w*p-2,y,4,h,220*i,c1)
            end
            return
        end
        -- A successful SC is another strike. The whitening and vibration are
        -- transient; the level-sensitive border remains until expiry.
        if age<.6 then
            local shine=age<.3 and 230 or 230*(1-smooth((age-.3)/.3))
            draw('wash',x+1,y+1,max(1,fill-2),h-2,shine*i,white)
            if age<.3 then
                local lead=x+fill
                draw('edge',lead-2,y-3,4,h+6,245*i*(1-age/.3),white)
            end
        end
        if fill<2 then return end
        local open_elapsed=max(0,(state.now or 0)-(state.sc_open or state.now))
        local flicker=.83+.17*sin((state.now or 0)*28)^2
        local left_x=x+1
        local right_x=x+max(1,fill)-1
        draw('left_halo',left_x-3,y-3,7,h+6,110*i*flicker,c1)
        draw('right_halo',right_x-3,y-3,7,h+6,110*i*flicker,c2)
        draw('left',left_x,y-2,2,h+4,235*i*flicker,c1)
        draw('right',right_x,y-2,2,h+4,235*i*flicker,c2)
        if (state.sc_wait or 0)>0 then return end
        local passes=level>=4 and floor(open_elapsed)+1 or
            level==3 and 3 or level==2 and 2 or 1
        local pass=floor(open_elapsed)
        if pass>=passes or level<4 and pass>=max(1,level) then return end
        local t=clamp(open_elapsed-pass,0,1)
        local flare_x=x+1+t*max(1,fill-2)
        local gradient={c1[1]*(1-t)+c2[1]*t,c1[2]*(1-t)+c2[2]*t,
            c1[3]*(1-t)+c2[3]*t}
        draw('moving_halo',flare_x-6,y-2,12,h+4,125*i,gradient)
        draw('moving',flare_x-1,y-3,3,h+6,250*i,gradient)
    end
    function self:destroy()
        for _,id in pairs(self.ids) do windower.prim.delete(id) end
    end
    return self
end
return M
