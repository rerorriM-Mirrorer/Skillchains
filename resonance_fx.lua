-- Skillchains HUD-only effects: the server's action clocks own all timers.
-- EnemyBar2's ghost_glow soft-alpha rails gain rounded ghost-glow cap PNGs.
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
    -- Only the continuous border system needs sprite assets now.
    -- Vertical/center light-leak flares were deliberately retired.
    for _,name in ipairs({'border_glow','border_lower',
        'glow_cap_l','glow_cap_r'}) do
        local file=(name=='glow_cap_l' and 'ghost_glow_cap_l.png')
            or (name=='glow_cap_r' and 'ghost_glow_cap_r.png')
            or 'ghost_glow.png'
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
    function self:transition_progress(s,options)
        if not s or (s.step or 0)<=1 then return 1 end
        local age,delay=age_and_delay(s)
        local duration=tonumber((options or {}).duration) or .30
        if duration<=0 then return age>=delay and 1 or 0 end
        -- Straddles the *real* pre-window->decay deadline, without changing
        -- either Skillchains/TargetSC timestamp or the countdown length.
        return smooth((age-(delay-duration/2))/duration)
    end
    function self:chain_brightness(s,options)
        if not s or (s.step or 0)<=1 then return 1 end
        return .46+.54*self:transition_progress(s,options)
    end
    function self:palette_blend(s)
        if not s or (s.step or 0)<=1 then return 1 end
        local age=age_and_delay(s)
        -- A genuine color fade, not an instantaneous weapon-skill replacement.
        return smooth((age-1)/1)
    end
    function self:render(s,opt,bar,palette,display_palette,glow_options,transition_options)
        if not s or not bar then self:hide();return end
        self.frame=self.frame+1
        opt=opt or {}
        glow_options=glow_options or {}
        transition_options=transition_options or {}
        local intensity=max(0,tonumber(opt.intensity) or 1)
        local enabled=opt.enabled~=false and intensity>0
        local global_glow=max(0,tonumber(opt.glow) or 1)
        local glow_scale=max(0,tonumber(glow_options.scale) or 1)
        local gi=intensity*global_glow*glow_scale
        local x,y,w,h=bar.x,bar.y,bar.width,bar.height
        local age,delay=age_and_delay(s)
        local level=tonumber(s.level) or 0
        local opener=(s.step or 0)<=1
        palette=palette or {white}
        local c1=palette[1] or white
        local progress=opener and 0 or self:transition_progress(s,transition_options)
        local l4mode=glow_options.l4 or 'whitegold'
        local level4_color=(l4mode=='gold' and gold)
            or (l4mode=='white' and white)
            or {255,239,194}
        local border=dark
        local border_alpha=180
        if level==1 then border=c1;border_alpha=230
        elseif level==2 then border=white;border_alpha=244
        elseif level==3 then border=white;border_alpha=255
        elseif level>=4 then border=level4_color;border_alpha=255 end
        if opener then
            border=dark
        else
            -- Full-strength white rail while the pre-window remains white.
            -- The border joins the fill's property fade, no color pop.
            border=mix(white,border,progress)
            border_alpha=210+(border_alpha-210)*progress
        end
        if s.expire_age then
            border_alpha=border_alpha*(1-smooth(s.expire_age/.35))
        end
        border_alpha=border_alpha*self:bar_reveal(s,opt)
        local alpha=floor(clamp(border_alpha,0,255)+.5)
        for _,id in ipairs({bar.frame.frame,bar.frame.cap_l,bar.frame.cap_r}) do
            windower.prim.set_color(id,alpha,border[1],border[2],border[3])
        end
        if not enabled then self:finish();return end

        -- Successful chains: one WHITE expansion from far left, then remain
        -- white throughout the pre-window. It transitions over the real
        -- countdown boundary, half before and half after, in .30s by default.
        -- Opening WS retains its proven: white first beat -> dim second beat.
        local white_alpha
        if opener then
            white_alpha=age<1 and 255 or
                (age<2 and 255*(1-smooth(age-1)) or 0)
        else
            white_alpha=255*(1-progress)
        end
        local fill_extent=age<1 and w*smooth(age) or w
        if not opener and age>=delay then
            -- No lingering full-width white block over the shrinking fill.
            fill_extent=min(w,max(0,(bar.fill or w)+2))
        end
        white_caps(x,y,fill_extent,h,white_alpha*intensity)

        -- Only one visual language for power: soft glow strips following the
        -- upper/lower border AND mirrored half-capsule glow textures at ends.
        -- White-gold L4 color and stronger cap options are separate from
        -- tier selection. No sprite flame/vertical flare/center pulse.
        local levels=glow_options.levels or '34'
        if levels~='off' and level>=1 and level<=4
            and levels:find(tostring(level),1,true) then
            local upper_tier=level>=3
            local rail=max(0,tonumber(glow_options[upper_tier and 'rail34'
                or 'rail12']) or (upper_tier and .60 or .30))
            local cap=max(0,tonumber(glow_options[upper_tier and 'cap34'
                or 'cap12']) or (upper_tier and .75 or .35))
            local base=upper_tier and (level>=4 and 72 or 68) or 72
            local electric=level>=4 and (.60+.40*sin(age*23)^2) or 1
            if level>=4 and age>=delay then
                electric=electric*(.78+.22*sin(age*28)^2)
            end
            local style=transition_options.style or 'energized'
            -- Before activation the glow is dormant; it charges as white
            -- gives way to color. In uniform style the glow simply fades in.
            local charge
            if opener then
                charge=1
            elseif style=='energized' then
                charge=.10+.90*smooth(progress/.85)
            else
                charge=progress
            end
            local glow_color=level>=4 and level4_color
                or (level==3 and white or c1)
            local rail_alpha=base*gi*rail*electric*charge
            local cap_alpha=base*gi*cap*electric*charge
            local scale=max(.5,tonumber(bar.scale) or 1)
            local inset=max(2,math.floor(5*scale+.5))
            local rail_height=max(5,math.floor(7*scale+.5))
            local cap_w=max(7,math.floor(14*scale+.5))
            local cap_h=max(12,math.floor(h+14*scale+.5))
            local cap_y=y+math.floor((h-cap_h)/2+.5)
            -- Both PNGs are centered around the real frame's centerline.
            -- Horizontal halo ends *inside* bar.x and bar.x+w.
            sprite('border_glow',x+inset,y-rail_height/2,
                max(1,w-2*inset),rail_height,rail_alpha,glow_color)
            sprite('border_lower',x+inset,y+h-rail_height/2,
                max(1,w-2*inset),rail_height,rail_alpha,glow_color)
            sprite('glow_cap_l',x,cap_y,cap_w,cap_h,
                cap_alpha,glow_color)
            sprite('glow_cap_r',x+w-cap_w,cap_y,cap_w,cap_h,
                cap_alpha,glow_color)
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
