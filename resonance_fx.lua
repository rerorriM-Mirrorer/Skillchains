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
    for _,name in ipairs({'wash','wash_cap_l','wash_cap_r'}) do
        local id=self.prefix..name
        windower.prim.create(id)
        windower.prim.set_color(id,0,255,255,255)
        windower.prim.set_visibility(id,false)
        self.ids[name]=id
    end
    for _,name in ipairs({'edge','left','right','moving','border_glow','border_lower'}) do
        local file=(name=='border_glow' or name=='border_lower')
            and 'ghost_glow.png' or 'ghost_flare.png'
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
    -- Uses the same inset end-cap silhouette as the SC gauge: 1px shorter
    -- left/right tips so the white opening bar is never a sharp rectangle.
    local function white_caps(x,y,w,h,a)
        wash(x+1,y,max(1,w-2),h,a,white)
        for _,cap in ipairs({'wash_cap_l','wash_cap_r'}) do
            local id=self.ids[cap]
            if w<2 or a<=0 then
                windower.prim.set_visibility(id,false)
            else
                local px=cap=='wash_cap_l' and x or x+w-1
                windower.prim.set_color(id,floor(clamp(a,0,255)+.5),255,255,255)
                windower.prim.set_position(id,floor(px+.5),floor(y+1+.5))
                windower.prim.set_size(id,1,max(1,floor(h-2+.5)))
                windower.prim.set_visibility(id,true)
            end
        end
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
        return .46+.54*smooth((age-(delay-.30))/.30)
    end
    function self:palette_blend(s)
        if not s or (s.step or 0)<=1 then return 1 end
        local age=age_and_delay(s)
        -- A genuine color fade, not an instantaneous weapon-skill replacement.
        return smooth((age-1)/1)
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
        if s.step==1 then border=dark end
        border_alpha=border_alpha*self:bar_reveal(s,opt)
        if not enabled then border=level>0 and border or dark end
        for _,id in ipairs({frame.frame,frame.cap_l,frame.cap_r}) do
            windower.prim.set_color(id,floor(clamp(border_alpha,0,255)+.5),
                border[1],border[2],border[3])
        end
        if not enabled then return end
        local scale=max(.5,tonumber(bar.scale) or 1)
        local flare_w=max(8,14*scale)
        local flare_h=max(11,20*scale)
        -- Soft ghost-flare image is brightest at its foot. Its lower edge
        -- meets the SC fill's bottom, while tips extend above the upper rail.
        local flare_y=y+h-1-flare_h
        local edge_inset=max(2,3*scale)
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
        end
        if s.expire_age then return end
        -- All skillchain tiers share one three-beat pre-window sequence.
        -- 0-1s: expand white bar. 1-2s: white dissolves to dim property.
        -- Final .3s: property brightens and colored edge flares emerge.
        local white_alpha=age<1 and 255 or
            (age<2 and 255*(1-smooth(age-1)) or 0)
        local white_edge_alpha=age<1 and 210 or
            (age<2 and 210*(1-smooth(age-1)) or 0)
        local fill_extent=age<1 and w*smooth(age) or w
        if age<2 then
            white_caps(x,y,fill_extent,h,white_alpha*intensity)
            local right=x+max(edge_inset,fill_extent-edge_inset)
            sprite('edge',right-flare_w/2,flare_y,flare_w,flare_h,
                white_edge_alpha*fi,white)
            -- A second white flare accompanies the expanding left edge.
            sprite('left',left_edge-flare_w/2,flare_y,flare_w,flare_h,
                white_edge_alpha*fi,white)
        end
        if age<delay then
            -- A single centered pulse precedes decay on every tier.
            -- Retain L4's faster electrical shimmer as a modulation.
            local pulse=smooth((age-(delay-.30))/.30)
            local flicker=level>=4 and (.60+.40*sin(age*23)^2) or 1
            sprite('moving',x+w/2-flare_w/2,flare_y,flare_w,flare_h,
                190*fi*pulse*flicker,level>=4 and gold or c1)
        end
        local active=smooth((age-(delay-.30))/.30)
        if age>=delay then active=1 end
        local flicker=.87+.13*sin((s.now or 0)*26)^2
        if fill>2 and active>0 then
            sprite('left',left_edge-flare_w/2,flare_y,flare_w,flare_h,
                185*fi*active*flicker,c1)
            sprite('right',right_edge-flare_w/2,flare_y,flare_w,flare_h,
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
    end
    function self:destroy()
        for _,id in pairs(self.ids) do windower.prim.delete(id) end
        for _,p in pairs(self.sprites) do p:destroy() end
    end
    return self
end
return M
