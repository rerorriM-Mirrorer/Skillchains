-- Skillchains HUD-only effects: the server's action clocks own all timers.
-- EnemyBar2's procedural soft-alpha ghost_flare/glow textures are reused here.
-- This module does not listen to combat packets or control TargetSC. Author: A.
local images=require('images')
local M={}
local sin,exp,floor,min,max,pi=math.sin,math.exp,math.floor,math.min,math.max,math.pi
local function clamp(x,a,b) return max(a,min(b,x)) end
local function smooth(t) t=clamp(t,0,1);return t*t*(3-2*t) end
local function mix(a,b,t)
    t=clamp(t,0,1)
    return {floor(a[1]*(1-t)+b[1]*t+.5),floor(a[2]*(1-t)+b[2]*t+.5),
        floor(a[3]*(1-t)+b[3]*t+.5)}
end
local white={255,255,255}
local gold={249,207,103}
local dark={9,10,21}
function M.new(prefix)
    local self={ids={},sprites={},prefix=prefix or 'sc_resonance_fx_'}
    -- A solid white bar really grows from zero during the first strike.
    -- The light around it uses alpha-textured sprites, never square halos.
    for _,name in ipairs({'wash'}) do
        local id=self.prefix..name
        windower.prim.create(id)
        windower.prim.set_color(id,0,255,255,255)
        windower.prim.set_visibility(id,false)
        self.ids[name]=id
    end
    for _,name in ipairs({'edge','left','right','moving','border_glow'}) do
        local file=name=='border_glow' and 'ghost_glow.png' or 'ghost_flare.png'
        self.sprites[name]=images.new('',{
            pos={x=0,y=0},visible=false,draggable=false,
            size={width=1,height=1},
            color={alpha=0,red=255,green=255,blue=255},
            texture={path=windower.addon_path..'images/resonance/'..file,fit=false}
        })
    end
    function self:hide()
        for _,id in pairs(self.ids) do windower.prim.set_visibility(id,false) end
        for _,p in pairs(self.sprites) do p:hide() end
    end
    local function wash(x,y,w,h,a,c)
        local id=self.ids.wash
        if a<=0 or w<=0 or h<=0 then
            windower.prim.set_visibility(id,false)
            return
        end
        windower.prim.set_color(id,floor(clamp(a,0,255)+.5),c[1],c[2],c[3])
        windower.prim.set_position(id,floor(x+.5),floor(y+.5))
        windower.prim.set_size(id,max(1,floor(w+.5)),max(1,floor(h+.5)))
        windower.prim.set_visibility(id,true)
    end
    local function sprite(name,x,y,w,h,a,c)
        local p=self.sprites[name]
        if a<=0 or w<=0 or h<=0 then p:hide();return end
        p:pos(floor(x+.5),floor(y+.5))
        p:size(max(1,floor(w+.5)),max(1,floor(h+.5)))
        p:color(c[1],c[2],c[3])
        p:alpha(floor(clamp(a,0,255)+.5))
        p:show()
    end
    function self:shake(s,opt)
        if not s or (s.step or 0)<=1 or (opt or {}).enabled==false then return 0 end
        local age=max(0,(s.now or 0)-(s.created or s.now or 0))
        local amp=tonumber((opt or {}).intensity) or 1
        if age>.35 then return 0 end
        return floor(3*amp*sin(75*age)*exp(-12*age)+.5)
    end
    local function age_and_delay(s)
        local created=s.created or s.now or 0
        local age=max(0,(s.now or 0)-created)
        local delay=max(.1,(s.sc_open or created)-created)
        return age,delay
    end
    function self:label_alpha(s,opt)
        if not s or (opt or {}).enabled==false then return 1 end
        local age,delay=age_and_delay(s)
        if s.step==1 and age<delay then
            -- Enter during the SECOND beat; complete by the second beat's end.
            return smooth(3*age/delay-1)
        end
        if (s.step or 0)>1 and age<.3 then return .55+.45*smooth(age/.3) end
        return 1
    end
    function self:bar_fraction(s,opt)
        local fraction=clamp((s.sc_left or 0)/max(.01,s.sc_total or 8),0,1)
        if (s.sc_wait or 0)>0 then fraction=1 end
        if not s or (opt or {}).enabled==false or (s.step or 0)<=1 then
            return fraction
        end
        local age=age_and_delay(s)
        if age<.3 then
            local previous=clamp(s.from_fraction or .45,0,1)
            return previous+(1-previous)*smooth(age/.3)
        end
        return fraction
    end
    function self:opacity(s,opt)
        if not s then return 1 end
        if s.expire_age then return 1-smooth(s.expire_age/.35) end
        if (opt or {}).enabled==false or not (opt or {}).fade or (s.sc_wait or 0)>0 then return 1 end
        local proportion=clamp((s.sc_left or 0)/max(.01,s.sc_total or 8),0,1)
        return (.30+.70*proportion)*(.82+.18*sin((s.now or 0)*pi*2.4)^2)
    end
    -- The bar is intentionally absent behind the white opener's first beat.
    -- The white overlay itself is the bar at that moment.
    function self:bar_reveal(s,opt)
        if not s or (opt or {}).enabled==false or s.step~=1 then return 1 end
        local age,delay=age_and_delay(s)
        return smooth(3*age/delay-1)
    end
    -- Start pre-window with ONLY the primary weapon skill property palette.
    -- After the real window begins, retain the same palette, just brighter.
    function self:open_brightness(s)
        if not s or (s.sc_wait or 0)>0 then return .46 end
        local elapsed=max(0,(s.now or 0)-(s.sc_open or s.now or 0))
        return .46+.54*smooth(elapsed/.23)
    end
    function self:palette_blend(s)
        if not s or (s.step or 0)<=1 then return 1 end
        local age=age_and_delay(s)
        -- A genuine color fade, not an instantaneous weapon-skill replacement.
        return smooth((age-.18)/.55)
    end
    function self:render(s,opt,bar,palette)
        self:hide()
        if not s or not bar then return end
        opt=opt or {}
        local intensity=clamp(tonumber(opt.intensity) or 1,0,2)
        local enabled=opt.enabled~=false and intensity>0
        local fi=intensity*clamp(tonumber(opt.flare) or 1,0,2)
        local gi=intensity*clamp(tonumber(opt.glow) or 1,0,2)
        local x,y,w,h=bar.x,bar.y,bar.width,bar.height
        local fill=clamp(bar.fill or w,0,w)
        local age,delay=age_and_delay(s)
        local level=tonumber(s.level) or 0
        local c1=(palette and palette[1]) or white
        local c2=(palette and palette[#palette]) or c1
        local frame=bar.frame
        local border=dark
        local border_alpha=180
        if level==1 then border=c1;border_alpha=230
        elseif level==2 then border=white;border_alpha=244
        elseif level==3 then border=white;border_alpha=255
        elseif level>=4 then border=gold;border_alpha=255 end
        if enabled and level>0 and age<.6 then
            border=mix(white,border,smooth((age-.3)/.3))
            border_alpha=255
        end
        if s.expire_age then
            border_alpha=border_alpha*(1-smooth(s.expire_age/.35))
        end
        -- The opener never whitens its actual SC border; only its detached
        -- expanding white overlay flashes, and the dark frame emerges after.
        if s.step==1 then
            border=dark
            border_alpha=border_alpha*self:bar_reveal(s,opt)
        end
        if not enabled then border=level>0 and border or dark end
        for _,id in ipairs({frame.frame,frame.cap_l,frame.cap_r}) do
            windower.prim.set_color(id,floor(clamp(border_alpha,0,255)+.5),
                border[1],border[2],border[3])
        end
        if not enabled then return end
        local scale=max(.5,tonumber(bar.scale) or 1)
        local flare_w=max(8,14*scale)
        local flare_h=max(11,20*scale)
        if level>=3 then
            local alpha=(level==3 and 110 or 160)*gi
            if level>=4 then alpha=alpha*(.60+.40*sin(age*23)^2) end
            sprite('border_glow',x-3*scale,y-8*scale,w+6*scale,h+16*scale,
                alpha,level>=4 and gold or white)
        end
        if s.expire_age then return end
        if s.step==1 then
            local beat=3*age/delay
            if beat<1 then
                local t=smooth(beat)
                local end_x=max(1,w*t)
                -- No SC background/frame underneath this first beat.
                wash(x,y,end_x,h,255*intensity,white)
                sprite('edge',x+end_x-flare_w/2,y+(h-flare_h)/2,
                    flare_w,flare_h,220*fi,white)
            elseif beat<2 then
                wash(x,y,w,h,255*intensity*(1-smooth(beat-1)),white)
            end
            return -- no second or third opener pulses
        end
        if age<.6 then
            local a=age<.3 and 235 or 235*(1-smooth((age-.3)/.3))
            wash(x+1,y+1,max(1,fill-2),max(1,h-2),a*intensity,white)
            if age<.3 then
                sprite('edge',x+fill-flare_w/2,y+(h-flare_h)/2,flare_w,
                    flare_h,210*fi*(1-age/.3),white)
            end
        end
        if fill<=2 then return end
        local flicker=.87+.13*sin((s.now or 0)*26)^2
        sprite('left',x-flare_w/2,y+(h-flare_h)/2,flare_w,flare_h,
            185*fi*flicker,c1)
        sprite('right',x+fill-flare_w/2,y+(h-flare_h)/2,flare_w,flare_h,
            185*fi*flicker,c2)
        -- All follow flares run in the THREE-SECOND WAIT, not during SC decay.
        if age>=delay then
            -- Future level-four choice: three pulses then a brighter flicker,
            -- no unapproved continuous traveling flare.
            if level>=4 then
                local a=80*gi*(.5+.5*sin(age*28)^2)
                sprite('border_glow',x-4*scale,y-8*scale,
                    w+8*scale,h+16*scale,a,gold)
            end
            return
        end
        if level>=4 then
            -- Preview-only provisional three-beat pulse, reserved for live
            -- calibration after actual Radiance/Umbra become available.
            local t=3*age/delay
            local a=210*fi*(1-smooth(t-floor(t)))
            sprite('moving',x+w/2-flare_w/2,y+(h-flare_h)/2,flare_w,
                flare_h,a,white)
            return
        end
        local passes=max(1,min(3,level))
        local progress=passes*age/delay
        local pass=floor(progress)
        local t=clamp(progress-pass,0,1)
        if pass>=passes then return end
        local pos=x+1+t*max(1,fill-2)
        sprite('moving',pos-flare_w/2,y+(h-flare_h)/2,flare_w,flare_h,
            225*fi,mix(c1,c2,t))
    end
    function self:destroy()
        for _,id in pairs(self.ids) do windower.prim.delete(id) end
        for _,p in pairs(self.sprites) do p:destroy() end
    end
    return self
end
return M
