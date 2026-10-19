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
    local self={ids={},sprites={},sprite_state={},prim_state={},
        frame=0,prefix=prefix or 'sc_resonance_fx_'}
    -- Reuse the pooled assets. The new end sprites have a rounded glowing
    -- base whose bottom edge is exactly the fill's lower raster edge.
    for _,name in ipairs({'wash','wash_cap_l','wash_cap_r'}) do
        local id=self.prefix..name
        windower.prim.create(id)
        windower.prim.set_color(id,0,255,255,255)
        windower.prim.set_visibility(id,false)
        self.ids[name]=id
        self.prim_state[name]={shown=false}
    end
    for _,name in ipairs({'edge','left','right','moving','border_glow',
        'border_lower','glow_cap_l','glow_cap_r'}) do
        local file
        if name=='border_glow' or name=='border_lower' then
            file='ghost_glow.png'
        elseif name=='moving' then
            file='ghost_flare.png' -- preserve original L4 center pulses
        elseif name=='left' or name=='glow_cap_l' then
            file='edge_flare_left.png'
        else
            file='edge_flare_right.png'
        end
        self.sprites[name]=images.new('',{
            pos={x=0,y=0},visible=false,draggable=false,
            size={width=1,height=1},
            color={alpha=0,red=255,green=255,blue=255},
            texture={path=windower.addon_path..'images/resonance/'..file,fit=false}
        })
        self.sprite_state[name]={shown=false}
    end
    -- Mark/sweep instead of hide/show on every animation frame. Windower's
    -- visibility and texture operations are comparatively expensive across
    -- four clients; unchanged geometry/color is also left untouched.
    function self:hide()
        for name,id in pairs(self.ids) do
            local st=self.prim_state[name]
            if st.shown then
                windower.prim.set_visibility(id,false)
                st.shown=false
            end
        end
        for name,p in pairs(self.sprites) do
            local st=self.sprite_state[name]
            if st.shown then p:hide();st.shown=false end
        end
    end
    function self:finish()
        for name,id in pairs(self.ids) do
            local st=self.prim_state[name]
            if st.shown and st.frame~=self.frame then
                windower.prim.set_visibility(id,false)
                st.shown=false
            end
        end
        for name,p in pairs(self.sprites) do
            local st=self.sprite_state[name]
            if st.shown and st.frame~=self.frame then
                p:hide()
                st.shown=false
            end
        end
    end
    local function primitive(name,x,y,w,h,a,c)
        if a<=0 or w<=0 or h<=0 then return end
        local st=self.prim_state[name]
        local id=self.ids[name]
        x,y,w,h=floor(x+.5),floor(y+.5),max(1,floor(w+.5)),max(1,floor(h+.5))
        a=floor(clamp(a,0,255)+.5)
        if x~=st.x or y~=st.y then
            windower.prim.set_position(id,x,y);st.x,st.y=x,y
        end
        if w~=st.w or h~=st.h then
            windower.prim.set_size(id,w,h);st.w,st.h=w,h
        end
        if a~=st.a or st.r~=c[1] or st.g~=c[2] or st.b~=c[3] then
            windower.prim.set_color(id,a,c[1],c[2],c[3])
            st.a,st.r,st.g,st.b=a,c[1],c[2],c[3]
        end
        if not st.shown then
            windower.prim.set_visibility(id,true)
            st.shown=true
        end
        st.frame=self.frame
    end
    -- Bar outline and opening wash use the same two-pixel-rounded ends.
    -- A zero-length sweep draws *nothing*, avoiding the initial 1px flash.
    local function white_caps(x,y,w,h,a)
        if w<=0 or a<=0 then return end
        if w<=2 then
            primitive('wash',x,y,w,h,a,white)
            return
        end
        primitive('wash',x+1,y,w-2,h,a,white)
        primitive('wash_cap_l',x,y+1,1,max(1,h-2),a,white)
        primitive('wash_cap_r',x+w-1,y+1,1,max(1,h-2),a,white)
    end
    local function sprite(name,x,y,w,h,a,c)
        if a<=0 or w<=0 or h<=0 then return end
        local p=self.sprites[name]
        local st=self.sprite_state[name]
        x,y,w,h=floor(x+.5),floor(y+.5),max(1,floor(w+.5)),max(1,floor(h+.5))
        a=floor(clamp(a,0,255)+.5)
        if x~=st.x or y~=st.y then
            p:pos(x,y);st.x,st.y=x,y
        end
        if w~=st.w or h~=st.h then
            p:size(w,h);st.w,st.h=w,h
        end
        if c[1]~=st.r or c[2]~=st.g or c[3]~=st.b then
            p:color(c[1],c[2],c[3]);st.r,st.g,st.b=c[1],c[2],c[3]
        end
        if a~=st.a then p:alpha(a);st.a=a end
        if not st.shown then p:show();st.shown=true end
        st.frame=self.frame
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
            -- Enter during the FIRST beat, reaching full strength as the
            -- white opener finishes expanding.
            return smooth(3*age/delay)
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
        if age<1 then
            local previous=clamp(s.from_fraction or .45,0,1)
            return previous+(1-previous)*smooth(age)
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
        if not s or (opt or {}).enabled==false then return 1 end
        if s.step~=1 then return 1 end -- previous SC fill/track stay visible
        local age=age_and_delay(s)
        return smooth(age-1)
    end
    -- Start pre-window with ONLY the primary weapon skill property palette.
    -- After the real window begins, retain the same palette, just brighter.
    function self:open_brightness(s)
        if not s or (s.sc_wait or 0)>0 then return .46 end
        local elapsed=max(0,(s.now or 0)-(s.sc_open or s.now or 0))
        return .46+.54*smooth(elapsed/.35)
    end
    function self:chain_brightness(s)
        if not s or (s.step or 0)<=1 then return 1 end
        local age,delay=age_and_delay(s)
        -- Brighten through the actual wait; don't jump at window opening.
        return .46+.54*smooth((age-(delay-.55))/.55)
    end
    function self:palette_blend(s)
        if not s or (s.step or 0)<=1 then return 1 end
        local age=age_and_delay(s)
        -- A genuine color fade, not an instantaneous weapon-skill replacement.
        return smooth((age-1)/1)
    end
    function self:render(s,opt,bar,palette,display_palette)
        if not s or not bar then self:hide();return end
        self.frame=self.frame+1
        opt=opt or {}
        local intensity=clamp(tonumber(opt.intensity) or 1,0,2)
        local enabled=opt.enabled~=false and intensity>0
        local fi=intensity*clamp(tonumber(opt.flare) or 1,0,2)
        local gi=intensity*clamp(tonumber(opt.glow) or 1,0,2)
        local x,y,w,h=bar.x,bar.y,bar.width,bar.height
        local fill=clamp(bar.fill or w,0,w)
        local age,delay=age_and_delay(s)
        local level=tonumber(s.level) or 0
        palette=palette or {white}
        local c1=palette[1] or white
        local c2=palette[#palette] or c1
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
        if s.step==1 then border=dark end
        border_alpha=border_alpha*self:bar_reveal(s,opt)
        if not enabled then border=level>0 and border or dark end
        for _,id in ipairs({frame.frame,frame.cap_l,frame.cap_r}) do
            windower.prim.set_color(id,floor(clamp(border_alpha,0,255)+.5),
                border[1],border[2],border[3])
        end
        if not enabled then self:finish();return end
        local scale=max(.5,tonumber(bar.scale) or 1)
        local flare_w=max(8,14*scale)
        local flare_h=max(11,20*scale)
        -- The new edge sprites end at their bright rounded foot. Anchor
        -- their last raster row on the fill's last raster row at ANY height.
        -- Fill primitive occupies y+1 through y+h-2 (inclusive).
        local fill_bottom=y+h-2
        local function base_y(height) return fill_bottom-height+1 end
        local flare_y=base_y(flare_h)
        local edge_inset=max(3,5*scale)
        local left_edge=x+edge_inset
        local right_edge=x+max(edge_inset,fill-edge_inset)
        if level>=3 then
            -- Two narrow soft rails, NOT a bright sheet over the empty track.
            -- Keep the interior dark even at large glow and fade settings.
            local alpha=(level==3 and 85 or 115)*gi
            if level>=4 then alpha=alpha*(.60+.40*sin(age*23)^2) end
            local halo_color=level>=4 and gold or white
            local halo_height=max(5,7*scale)
            sprite('border_glow',x+edge_inset,y-halo_height/2,
                max(1,w-2*edge_inset),halo_height,alpha,halo_color)
            sprite('border_lower',x+edge_inset,y+h-halo_height/2,
                max(1,w-2*edge_inset),halo_height,alpha,halo_color)
            -- Soft endcaps finish the shortened glow rails without extending
            -- outside the rounded gauge silhouette.
            local cap=max(3,7*scale)
            local cap_height=max(9,14*scale)
            sprite('glow_cap_l',x+1,base_y(cap_height),
                cap,cap_height,alpha*.85,halo_color)
            sprite('glow_cap_r',x+w-cap-1,base_y(cap_height),
                cap,cap_height,alpha*.85,halo_color)
        end
        if s.expire_age then self:finish();return end
        -- Opener begins from nothing; a successful SC retains its previous
        -- fill and dark track underneath the white re-expansion.
        local opener=(s.step or 0)<=1
        local white_alpha=age<1 and 255 or
            (age<2 and 255*(1-smooth(age-1)) or 0)
        local white_edge_alpha=age<1 and 210*smooth(age/.20) or
            (age<2 and 210*(1-smooth(age-1)) or 0)
        -- The white effect ALWAYS grows from 0. For successful chains
        -- draw_bar independently grows its underlying property fill from
        -- the prior fraction (without hiding the track or previous state).
        local fill_extent=age<1 and w*smooth(age) or w
        if age<2 then
            -- Like the opener, the WHITE sweep starts at the left rail and
            -- covers the entire bar through the growing right edge. For
            -- successful chains the prior fill and track stay underneath.
            white_caps(x,y,fill_extent,h,white_alpha*intensity)
            local end_x=x+max(edge_inset,fill_extent-edge_inset)
            -- Animate HEIGHT, not vertical position: keep the bright foot
            -- fixed to the same lower fill row as the plume grows upward.
            local beat=age<1 and smooth(age) or 1-smooth(age-1)
            local flare_pulse=.63+.37*sin(beat*pi)
            local pulse_h=max(5,floor(flare_h*flare_pulse+.5))
            local pulse_y=base_y(pulse_h)
            sprite('edge',end_x-flare_w,pulse_y,flare_w,pulse_h,
                white_edge_alpha*fi,white)
            if not opener then
                sprite('left',left_edge,pulse_y,flare_w,pulse_h,
                    white_edge_alpha*fi,white)
            end
        end
        if not opener and age<delay then
            -- Restore the original L4 three-beat center pulses for ALL
            -- confirmed chain levels, not one last-second blink.
            local progress=3*age/delay
            local t=progress-floor(progress)
            local pulse=1-smooth(t)
            local flicker=level>=4 and (.60+.40*sin(age*23)^2) or 1
            -- The property color at the fill's center may differ from
            -- either gradient end. Do not substitute gold at level four.
            local mid=(#palette+1)/2
            local lower=max(1,floor(mid))
            local upper=min(#palette,lower+1)
            local middle=mix(palette[lower] or c1,
                palette[upper] or c2,mid-lower)
            sprite('moving',x+w/2-flare_w/2,flare_y,flare_w,flare_h,
                210*fi*pulse*flicker,middle)
        end
        -- Bring in property-colored edge flares while the white dissipates.
        -- Their arrival precedes the final brightness ramp, avoiding a pop.
        local active=smooth((age-(delay-.70))/.55)
        if age>=delay then active=1 end
        local flicker=.87+.13*sin((s.now or 0)*26)^2
        if fill>2 and active>0 then
            if not opener then
                sprite('left',left_edge,flare_y,flare_w,flare_h,
                    185*fi*active*flicker,c1)
            end
            sprite('right',right_edge-flare_w,flare_y,flare_w,flare_h,
                185*fi*active*flicker,c2)
        end
        if level>=4 and age>=delay then
            local a=80*gi*(.5+.5*sin(age*28)^2)
            local halo_height=max(5,7*scale)
            sprite('border_glow',x+edge_inset,y-halo_height/2,
                max(1,w-2*edge_inset),halo_height,a,gold)
            sprite('border_lower',x+edge_inset,y+h-halo_height/2,
                max(1,w-2*edge_inset),halo_height,a,gold)
        end
        self:finish()
    end
    function self:destroy()
        for _,id in pairs(self.ids) do windower.prim.delete(id) end
        for _,p in pairs(self.sprites) do p:destroy() end
    end
    return self
end
return M
