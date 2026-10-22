-- Analytic presentation driven by source timestamps, never accumulated frames.
-- Strike displacement and the settled ground hum are in world units. Author: A.
local M={}
local Burst=require('resonance_burst')
local min,max,sin,exp,pi=math.min,math.max,math.sin,math.exp,math.pi
local function clamp(v,a,b)return max(a,min(b,v))end
local function smooth(v)v=clamp(v,0,1)return v*v*(3-2*v)end
-- Effective global + Killala profile from 2026-10-22 16:41:47 XML.
-- Existing saved settings survive; preset default deliberately restores these.
M.defaults={opacity=0.27,scale=2,height=0.66,intensity=0.3,motion='sine',layout='grounded',
    period=0.09,amplitude=0.3,damping=3,width=2,glow=1,brightness=4,discs=true,disc_opacity=1,
    hum_amplitude=0.018,hum_period=0.12,hum_slowdown=1,hum_gain=0.35,
    disc_outline=0.6,disc_style='glyph',disc_height=0.06,disc_speed=0.1,disc_slowdown=3,
    disc_speed_opener=4,disc_speed_level1=2,disc_speed_level2=3,disc_speed_level3=4,disc_speed_level4=0,mb_opacity=0.39,
    mb_idle=0.1,mb_burst=0.6,mb_floor=1,mb_ring=1,mb_period=2,mb_rise=0.01,mb_expand=0,sky_expand=0.39,
    awakening=true,awakening_opacity=0.3,ground_height=0.3,fade_duration=0.8,
    opener_gap=12,opener_glow='black',opener_muted=true,
    display='both',sky_cutoff=.5,sky_curve=3,sky_hold=.3,sky_descent=0,disc_minimum=.5,
    mb_duration=0.9,mb_effects=1,mb_ending=2,mb_ending_style='soft',mb_overall=0.66,
    mb_intro=.6,mb_intro_flashes=1,ground_lift=.04,
    mb_style='clapper',mb_size=.5,mb_position=.5,mb_spin=.025,
    mb_breath_min=.35,mb_breath_gain=3,mb_hold=.6,mb_return=2,mb_lift=.3,mb_shimmer=1}
local white,gold={255,255,255},{255,217,115}
-- Mix toward the brightest channel before dimming: hue is preserved while
-- saturation becomes 75% and value 82% of the ordinary elemental color.
local function muted(c)
    local value=max(c[1],c[2],c[3])
    return {(.75*c[1]+.25*value)*.82,(.75*c[2]+.25*value)*.82,(.75*c[3]+.25*value)*.82}
end
local function option(opts,k)
    if opts and opts[k]~=nil then return opts[k]end
    return M.defaults[k]
end
local function mix(a,b,t)
    t=clamp(t,0,1)return {a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t,a[3]+(b[3]-a[3])*t}
end
function M.phase(s,now,opts)
    if now<s.sc_open then return 'pre'end
    local boundary=s.closed and s.sc_open or s.sc_close
    if not s.closed and now<boundary then return 'countdown'end
    if now<boundary+option(opts,'fade_duration')then return s.closed and 'terminal' or 'expiration'end
    return now<s.mb_close and 'mb-only' or 'expired'
end
-- Integral of f*(1-t/duration)^power: zero final speed without an angle jump.
function M.slow_integral(elapsed,duration,power)
    local t=clamp(elapsed/max(.001,duration),0,1)
    return duration*(1-(1-t)^(power+1))/(power+1)
end
local function energy_time(s,now,opts,power)
    local charge=max(0,s.sc_open-s.created)
    if now<s.sc_open then return max(0,now-s.created)end
    local duration=s.closed and option(opts,'fade_duration')or max(.1,s.sc_close-s.sc_open)
    return charge+M.slow_integral(now-s.sc_open,duration,power)
end
function M.rotation(s,now,opts)
    local stage=s.step==1 and 'opener'or 'level'..s.level
    local turns=option(opts,'disc_speed_'..stage)
    return 2*pi*turns*option(opts,'disc_speed')*energy_time(s,now,opts,option(opts,'disc_slowdown'))
end
-- Only the property disc carries on through an enabled MB window. Integrate
-- speed analytically so there is no angle jump as it reaches its idle speed.
-- A stationary stage remains stationary; the minimum never speeds a stage up.
function M.disc_rotation(s,now,opts)
    local display=option(opts,'display')
    if (display~='both'and display~='mb')or s.step==1 or s.mb_close<=s.created then
        return M.rotation(s,now,opts)
    end
    local turns=option(opts,'disc_speed_level'..s.level)
    local minimum=min(turns,option(opts,'disc_minimum'))
    local at=min(now,s.mb_close)
    local elapsed=max(0,at-s.sc_open)
    local energy=energy_time(s,at,opts,option(opts,'disc_slowdown'))
    return 2*pi*option(opts,'disc_speed')*((turns-minimum)*energy+
        minimum*(max(0,min(at,s.sc_open)-s.created)+elapsed))
end
-- Hold the fully unfolded bell through its color transition, then use a
-- smooth compressed descent that still reaches the source deadline exactly.
function M.descent_remaining(s,now,opts)
    local duration=max(.1,s.sc_close-s.sc_open)
    local hold=option(opts,'sky_hold')
    local held=hold>0 and min(hold+.15,max(0,duration-.1))or 0
    local t=clamp((now-s.sc_open-held)/max(.1,duration-held),0,1)
    -- Warp only presentation progress after the existing hold. Zero preserves
    -- the old linear/no-hold or smooth/held curve, with exact source endpoints.
    local curve=option(opts,'sky_descent')
    if curve>0 then t=1-(1-t)^(1+curve)
    elseif curve<0 then t=t^(1-curve)end
    return 1-(hold>0 and smooth(t)or t)
end
local function wave(cycles,opts)
    if option(opts,'motion')=='flutter'then return math.floor(cycles*2+1e-9)%2 end
    return .5+.5*sin(cycles*2*pi)
end
function M.vibration(s,now,opts)
    -- Opener appearance and window opening restart the SAME strike envelope.
    -- Closed results have no window-opening strike or fictitious countdown.
    local age=max(0,now-s.created)
    local strike_age=(now<s.sc_open or s.closed)and age or now-s.sc_open
    local decay=exp(-strike_age*option(opts,'damping'))
    local strike=option(opts,'amplitude')*option(opts,'intensity')*decay*
        wave(strike_age/(2*option(opts,'period')),opts)
    local level=s.step==1 and 1 or s.level
    local gain=1+(level-1)*option(opts,'hum_gain')
    local frequency=gain/(2*option(opts,'hum_period'))
    local hum_phase=frequency*energy_time(s,now,opts,option(opts,'hum_slowdown'))
    local hum=option(opts,'hum_amplitude')*gain*option(opts,'intensity')*(1-decay)*wave(hum_phase,opts)
    local duration=s.closed and option(opts,'fade_duration')or max(.1,s.sc_close-s.sc_open)
    local left=now<s.sc_open and 1 or clamp(1-(now-s.sc_open)/duration,0,1)
    return strike+hum,strike,{strike=strike,hum=hum,
        hum_amplitude=option(opts,'hum_amplitude')*gain*option(opts,'intensity')*(1-decay),
        hum_hz=frequency*left^option(opts,'hum_slowdown')}
end
function M.positions(s,now,height,opts)
    local phase=M.phase(s,now,opts)
    -- Natural expiry freezes the last geometry and fades it in place.
    local at=not s.closed and min(now,s.sc_close)or now
    local age=max(0,at-s.created)
    local elapsed=max(0,at-s.sc_open)
    local remaining=at<s.sc_open and 1 or s.closed and 0 or
        clamp((s.sc_close-at)/max(.1,s.sc_close-s.sc_open),0,1)
    local floor=option(opts,'ground_height')+option(opts,'ground_lift')
    local ground_wave,sky_wave,details=M.vibration(s,at,opts)
    details.ground_wave=ground_wave
    local paired=s.step>1 or phase~='pre'
    if not paired then return floor+ground_wave,nil,remaining,details end
    local unfold=s.step>1 and smooth(age/.3)or smooth(elapsed/.28)
    local descent=s.closed and 1 or M.descent_remaining(s,at,opts)
    local span=height*.90*descent*unfold
    local bottom,top=floor,floor+span
    local layout=option(opts,'layout')
    if layout~='grounded'then bottom=height*.49-span*.5;top=height*.49+span*.5 end
    if s.step>1 and s.previous and age<.3 then
        local old_bottom,old_top=M.positions(s.previous,s.created,height,opts)
        local t=smooth(age/.3)
        bottom=old_bottom+(bottom-old_bottom)*t
        top=(old_top or old_bottom)+(top-(old_top or old_bottom))*t
    end
    if layout=='center'then
        -- Comparison layout: constrain inward vibration to the current half
        -- span rather than allowing the two strands to cross each other.
        ground_wave=min(ground_wave,span*.5);sky_wave=min(sky_wave,span*.5)
    end
    -- Sky: damped strike only. Ground: strike plus its smaller sustained hum.
    bottom=bottom+ground_wave
    top=max(floor,top-sky_wave)
    return bottom,top,remaining,details
end
-- Height, not elapsed time, traces the requested bell profile. The radius
-- reaches normal after cutoff of the descent, then stays there.
function M.bell_factor(separation,height,opts)
    local descent=1-clamp(separation/max(.001,height*.9),0,1)
    local curve=max(0,1-descent/option(opts,'sky_cutoff'))
    return 1+option(opts,'sky_expand')*curve^option(opts,'sky_curve')
end
local function property_palette(name,context)
    return context.palette({properties={name},elements={},level=context.level(name)})
end
local function specifications(s,context)
    local result={}
    if s.step==1 then
        for j,p in ipairs(s.properties)do
            result[#result+1]={colors=property_palette(p,context),radial=1-(j-1)*.13,stack=0}
        end
    else
        local colors=context.palette(s)
        for j,c in ipairs(colors)do
            local palette={c}
            if s.level==2 and #colors==2 then
                palette=j==1 and {colors[1],colors[2]}or {colors[2],colors[1]}
            end
            result[#result+1]={colors=palette,radial=s.level>=4 and 1+(j-(#colors+1)/2)*.075 or 1,
                stack=(s.level==2 or s.level==3)and (j-1)*.035 or 0}
        end
    end
    return result
end
function M.frame(model,s,now,radius,height,opts,context)
    local out={discs={}}
    local display=option(opts,'display')
    local show_sc=display=='both'or display=='sc'
    local show_mb=display=='both'or display=='mb'
    local age=max(0,now-s.created)
    local phase=s.source_expired and 'expired'or M.phase(s,now,opts)
    out.phase=phase
    local opening=model:opening_glyph(s)
    local response=Burst.sample(model,s,now,function(k)return option(opts,k)end)
    if not show_mb then response={idle=0,flash=0,rise=0,release=0,ring=0,ending=false}end
    if phase=='expired'and not response.responding then
        if opening then opening.opacity=0 end
        return out
    end
    local mb_strength=not s.source_expired and s.mb_close>now and now>=s.created and clamp((s.mb_close-now)/10,0,1)or 0
    local mb_active=not s.source_expired and s.step>1 and now>=s.created and now<s.mb_close
    local mb_overall=option(opts,'mb_overall')
    local intro=not response.ending and mb_overall>0 and (response.intro or 0)or 0
    out.mb_strength=mb_strength
    local bottom,top,remaining,details=M.positions(s,now,height,opts)
    local clapper=option(opts,'mb_style')=='clapper'
    local terminal=s.step>1 and s.level>=4
    local property_radius=radius*(terminal and .92 or .78)
    local mb_radius=clapper and property_radius+(radius-property_radius)*option(opts,'mb_size')or radius
    -- The MB ring shares the large glyph's steady vertical reference. Use
    -- nominal anchors, never SC vibration, descent or property-transition
    -- blending. A common property plane also avoids a height step at level 4.
    local property_top=option(opts,'disc_height')+.006
    local floor_anchor=option(opts,'ground_height')+option(opts,'ground_lift')
    local mb_height=clapper and property_top+(floor_anchor-property_top)*option(opts,'mb_position')or height*.49
    local mb_colors=context.palette(s)
    local mb_color=mb_colors[#mb_colors]
    if clapper and s.level==2 and #mb_colors==2 then
        local cycle=.5-.5*math.cos(age*pi/option(opts,'mb_period'))
        mb_color=mix(mb_colors[1],mb_colors[2],smooth(cycle))
    end
    out.ground,out.sky,out.remaining,out.vibration=bottom,top,remaining,details
    local intensity,opacity=option(opts,'intensity'),option(opts,'opacity')
    local px,glow=max(1,option(opts,'width')),option(opts,'glow')
    local opener=s.step==1
    local progress=clamp(age/max(.1,s.sc_open-s.created),0,1)
    local color_t=opener and smooth(progress*1.5)or smooth((now-(s.sc_open-.15))/.30)
    local flash=s.suppress_impact and 0 or clamp(1-age/.3,0,1)*min(1,intensity)
    local fading=phase=='expiration'or phase=='terminal'
    local boundary=s.closed and s.sc_open or s.sc_close
    local fade=fading and 1-smooth((now-boundary)/option(opts,'fade_duration'))or 1
    local function packed(colors,a)
        local r={}for _,c in ipairs(colors)do r[#r+1]=context.argb(c,a)end return r
    end
    local function band(r,h,colors,a,pixels,role,part,strand,rotation)
        if a<=.002 or r<.01 then return end
        r=min(r,100)
        local p=packed(colors,a)
        out[#out+1]={radius=r,offset=h,width=0,pixels=pixels,color=p[1],colors=p,
            rotation=rotation or 0,role=role,part=part,strand=strand,
            gap=opener and (part=='ground'or part=='sky')and option(opts,'opener_gap')or 0}
    end
    local function ring(r,h,colors,a,part,strand,rotation,light)
        local opening=opener and (part=='ground'or part=='sky')
        local mode=opening and option(opts,'opener_glow')or 'color'
        if glow>0 and light~=false and mode~='off'then
            local surround=mode=='black'and {{0,0,0}}or colors
            band(r,h,surround,a*.24*glow,px+4*min(glow,3),'glow',part,strand,rotation)
        end
        band(r,h,colors,a,px,'core',part,strand,rotation)
    end
    local function disc(r,h,angle,colors,a,glyph,outline,role,stroke_color)
        if (a<=.002 and outline<=.002)or r<.01 or #out.discs>=8 then return end
        r=min(r,100)
        local p=packed(colors,a)
        out.discs[#out.discs+1]={radius=r,offset=h,rotation=angle,color=p[1],colors=p,
            glyph=glyph,outline=context.argb(stroke_color or white,outline),role=role}
    end
    local electric=1
    if not opener and s.level==3 then electric=.68+.32*sin(age*11)^2
    elseif not opener and s.level>=4 then electric=(.37+.63*sin(age*23)^2)*(.72+.28*sin(age*28)^2)end
    if show_sc and phase~='mb-only'and phase~='expired'then
        local specs=specifications(s,context)
        if not opener and s.level~=2 and age<.16 then specs={{colors={white},radial=1,stack=0}}end
        out.strands=#specs
        local alpha=opacity*option(opts,'brightness')*(phase=='pre'and .78 or .95)*fade
        if s.level>=3 and not opener then alpha=alpha*(.72+.28*electric)end
        for j,spec in ipairs(specs)do
            local colors={}
            for _,c in ipairs(spec.colors)do
                local target=opener and option(opts,'opener_muted')and muted(c)or c
                colors[#colors+1]=mix(mix(white,target,color_t),white,flash)
            end
            local r=radius*spec.radial
            local rotation=(opener or s.level==2)and M.rotation(s,now,opts)or 0
            for _,place in ipairs({{bottom,'ground'},{top,'sky'}})do
                if place[1]then
                    local h=place[1]+spec.stack
                    local draw_radius=r
                    if place[2]=='sky'then
                        draw_radius=r*M.bell_factor(top-bottom,height,opts)
                    end
                    if glow>0 and not opener and s.level>=3 then
                        local tint=(s.properties[1]=='Darkness'or s.properties[1]=='Umbra')and {132,74,224}or gold
                        band(draw_radius,h,{tint},opacity*.32*glow*electric*fade,px+6*min(glow,3),'glow',place[2],j,rotation)
                    end
                    ring(draw_radius,h,colors,alpha,place[2],j,rotation)
                end
            end
        end
    end
    -- One pooled large glyph: opener fill, continuous breath and layered MB
    -- bloom. Clapper strikes contract/settle along the property return curve.
    if opening then
        local progress=clamp((now-opening.created)/max(.1,opening.open-opening.created),0,1)
        local grow=1-(1-clamp(progress*3,0,1))^3
        local initial=show_sc and opening.opener_seen and option(opts,'awakening')and
            option(opts,'awakening_opacity')*opacity*(1-smooth((progress-1/3)*3))or 0
        local role='mb-glyph'
        local fill=0
        local color=white -- steady neutral breath; only confirmed MBs tint it
        local resting_radius=clapper and s.step>1 and mb_radius or radius*.96
        opening.radius=resting_radius
        opening.offset=option(opts,'disc_height')
        opening.rotation=clapper and -2*pi*option(opts,'mb_spin')*max(0,now-opening.created)or 0
        opening.opacity=response.idle
        if initial>0 then
            role='awakening';fill=initial
            opening.radius=opening.radius*grow;opening.opacity=0
        end
        if response.responding then
            fill=0;role='mb-glyph'
            if clapper then
                local energy=option(opts,'mb_burst')>0 and (response.property or 0)or 0
                local strike=energy*(1+(option(opts,'mb_burst')-1)*(1-energy))
                opening.radius=resting_radius*(1+option(opts,'mb_expand')*energy)
                opening.offset=option(opts,'disc_height')+height*option(opts,'mb_rise')*energy
                color=mix(color,response.element,strike)
                opening.opacity=opening.opacity+(1-opening.opacity)*strike
            else
                color=mix(response.element,white,response.white)
                opening.radius=resting_radius*(1+option(opts,'mb_expand')*response.rise)
                opening.offset=option(opts,'disc_height')+height*option(opts,'mb_rise')*response.rise
                opening.opacity=response.release
            end
        end
        if intro>0 then
            role='mb-glyph';fill=0
            color=mix(color,white,intro)
            opening.opacity=opening.opacity+(1-opening.opacity)*intro
        end
        if response.ending then
            -- A closing signal wins over a simultaneous hit's color/alpha,
            -- while an already rising glyph keeps its continuous trajectory.
            color=white
            opening.opacity=response.end_flash*option(opts,'mb_effects')
        end
        if role=='mb-glyph'then opening.opacity=opening.opacity*mb_overall end
        out.awakening_glyph=opening
        disc(opening.radius,opening.offset,fill>0 and 0 or opening.rotation,{white},fill,fill>0 and 0 or 2,
            fill>0 and 0 or opening.opacity,role,color)
        if clapper and response.element and (response.shimmer or 0)>0 then
            band(opening.radius,opening.offset,{response.element},mb_overall*min(1,response.shimmer)*.65,
                px+10,'burst-glow','mb-glyph',0,opening.rotation)
        end
    end
    if option(opts,'discs')then
        local sc_life=(phase=='mb-only'or phase=='expired')and 0 or phase=='pre'and 1 or s.closed and fade or remaining
        local life=max(show_sc and sc_life or 0,show_mb and mb_strength or 0)
        if show_mb and s.step>1 and s.mb_close>s.created then
            -- Keep the elemental foundation steady, then gently extinguish
            -- it across the SAME ending interval as the white MB signals.
            life=mb_active and smooth((s.mb_close-now)/option(opts,'mb_ending'))or 0
        end
        local reveal=opener and smooth(progress*5)or 1
        local fill=option(opts,'disc_opacity')*opacity*life*reveal
        local outline=option(opts,'disc_outline')*opacity*life*reveal
        local base=option(opts,'disc_height')+details.ground_wave
        local glyph=option(opts,'disc_style')=='outline'and 2 or option(opts,'disc_style')=='fill'and 0 or 1
        local properties=opener and s.properties or {s.properties[1]}
        for j,p in ipairs(properties)do
            local colors=property_palette(p,context)
            local terminal=not opener and s.level>=4
            local terminal_stroke=white
            if terminal then
                local dark=p=='Umbra'or p=='Darkness'
                colors={dark and {0,0,0}or white}
                terminal_stroke=dark and {255,242,204}or {0,0,0}
            end
            local flash=response.flash*option(opts,'mb_floor')
            if clapper then flash=mb_overall>0 and (response.property or 0)*option(opts,'mb_floor')or 0 end
            if show_mb and s.step>1 then flash=flash*life end
            local disc_fill=fill+(max(fill,mb_overall*life)-fill)*flash
            local disc_outline=outline+(max(outline,mb_overall*life)-outline)*flash
            if clapper then
                disc_fill=fill+(mb_overall*life-fill)*flash
                disc_outline=outline+(mb_overall*life-outline)*flash
            else flash=flash*mb_overall end
            local stroke=response.element and mix(terminal_stroke,response.element,flash)or terminal_stroke
            if flash>0 then
                for i,c in ipairs(colors)do colors[i]=mix(c,clapper and response.element or white,flash)end
            end
            if intro>0 then
                disc_fill=disc_fill+(mb_overall-disc_fill)*intro
                disc_outline=disc_outline+(mb_overall-disc_outline)*intro
                stroke=mix(stroke,white,intro)
                for i,c in ipairs(colors)do colors[i]=mix(c,white,intro)end
            end
            local angle=M.disc_rotation(s,now,opts)
            local h=base+.006+(j-1)*.008
            if terminal or clapper then
                -- Separate planes let a struck trace lift while its fill
                -- remains anchored. Terminal traces keep their .006 clearance.
                local r=terminal and radius*.92 or radius*(.78-(j-1)*.11)
                local respond=flash>0 or intro>0
                disc(r,h,angle,colors,(glyph==2 and not respond)and 0 or disc_fill,
                    0,0,'property')
                local trace_height=h+(terminal and .006 or 0)
                if clapper and mb_overall>0 then
                    trace_height=trace_height+(response.lift or 0)*option(opts,'mb_floor')
                end
                disc(r,trace_height,angle,{white},0,2,
                    (glyph==0 and not respond)and 0 or disc_outline,'property-trace',stroke)
                if clapper and response.element and (response.shimmer or 0)>0 and option(opts,'mb_floor')>0 then
                    band(r,trace_height,{response.element},mb_overall*min(1,response.shimmer)*option(opts,'mb_floor'),
                        px+12,'burst-glow','property-trace',0,angle)
                end
            else
                disc(radius*(.78-(j-1)*.11),h,angle,colors,disc_fill,
                    (flash>0 or intro>0)and 1 or glyph,disc_outline,'property',stroke)
            end
        end
    end
    -- MB ring remains tied to its original deadline; response overlays never
    -- reset its fade, the continuation phase, or the property-disc rotation.
    if show_mb and mb_strength>0 then
        local color=mb_color
        local alpha=option(opts,'mb_opacity')+(1-option(opts,'mb_opacity'))*(1-mb_strength)
        if clapper then alpha=alpha*(response.breath or 1)end
        local strength=response.ring*option(opts,'mb_ring')
        if response.element and strength>0 then
            color=mix(color,mix(response.element,white,response.flicker),strength)
            alpha=alpha+(1-alpha)*strength
        end
        if intro>0 then
            color=mix(color,white,intro)
            alpha=alpha+(1-alpha)*intro
        end
        if response.ending then
            color=mix(color,white,option(opts,'mb_effects'))
            alpha=alpha*(1-option(opts,'mb_effects'))+response.end_flash*option(opts,'mb_effects')
        end
        ring(mb_radius,mb_height,{color},alpha*mb_overall,'mb',0,0)
    end
    while #out>32 do table.remove(out,1)end
    return out
end
return M
