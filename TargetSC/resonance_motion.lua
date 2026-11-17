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
    mb_breath_min=.35,mb_breath_gain=3,mb_hold=.6,mb_return=2,mb_lift=.3,mb_shimmer=1,
    -- Test3 (2026-11-16): the large lower glyph rises to just above the MB
    -- ring on a confirmed burst, stays white, and lands with the property
    -- trace. glyph_height 0 / glyph_tint 1 / intro_glyph 1 restore Killala.
    mb_glyph_height=1.1,mb_glyph_tint=0,mb_glyph_rise=.15,mb_intro_glyph=.5,mb_intro_disc=1,
    -- Two-element property discs blend smoothly instead of splitting in half.
    disc_blend='gradient',
    -- Multi-color SC rings (ground, sky and their glows) blend smoothly too.
    -- Opener rings always stay split around their two gaps.
    ring_blend='gradient',
    -- Test3.2: SC rings turn with the property disc (stage speed easing to
    -- the disc minimum), carry a soft brighter/dimmer side so the spin reads,
    -- glows may turn faster, and the MB ring settles onto the large glyph
    -- during the closing pulses.
    ring_spin='disc',ring_shade=.25,ring_glow_spin=1,mb_ending_drop=1,
    -- Test3.4: confirmed-MB glows on the two glyphs get a turning lit side,
    -- an added spin (turns/sec) over their glyph, and optional softening.
    mb_glow_shade=.5,mb_glow_spin=.5,mb_glow_flicker=1,mb_glow_width=1,
    -- Test3.5: the white awakening disc keeps its opacity at the center and
    -- fades toward the edge (inner/outer multiply its opacity); size scales it.
    awakening_inner=1,awakening_outer=0,awakening_size=1,
    -- Test3.6: opener-only property disc FILL (glyph lines unchanged):
    -- center/edge opacity multipliers and size. Defaults change nothing.
    opener_disc_inner=1,opener_disc_outer=1,opener_disc_size=1,
    -- When the awakening disc's fade ends: 'default' (two-thirds of the wait,
    -- as before), 'open' (window opens), 'close' (window ends) or '1'..'9'
    -- seconds after the window opens. A link fades it out over .3 s.
    awakening_until='default',
    -- Test3.8: opener arcs fade along their length from the bright end
    -- (lead = facing the spin); the glow band follows by opener_fade_glow.
    opener_fade=.6,opener_fade_length=1,opener_fade_curve=1,opener_fade_end='lead',opener_fade_glow=1,
    -- Test4.0: opener properties share the circle as sections (gaps 90/60/30
    -- for 1/2/3 properties); each element is one arc, stacked by height.
    opener_layout='sections',opener_spacing=.035,
    -- Test4.1: openers keep turning: gentler slowdown toward a minimum speed.
    opener_spin_slowdown=1,opener_spin_minimum=.5,
    -- Test4.2: opener property-disc glyph line opacity; -1 = follow discs outline.
    opener_disc_outline=-1,
    -- Test4.4: link property discs (all levels): fill center/edge fade, fill
    -- size, glyph-line (sigil) size; Light/Darkness disc look.
    disc_inner=1,disc_outer=1,disc_size=1,disc_size_lines=1,disc_lightdark='classic',
    -- Test4.5: level-3 Light/Darkness links: white/black outer strands, the
    -- four element colors around the middle strand, MB ring cycling them.
    ring_lightdark='elements',ring_lightdark_spin=1,ring_lightdark_tint='white',mb_lightdark_cycle=2,
    -- Test4.6: level-3 LIGHT only (Darkness keeps the elements look): all
    -- strands white; the four inner rings' glows carry the four element
    -- colors (top to bottom), slowly rotating; MB ring white breathing.
    ring_light='white',ring_light_cycle=4,ring_light_glow=1,
    -- Test4.7: Light's colored inner glows stay off until its window opens,
    -- then rise to `rings light glow`; its MB ring matches the lowest SC ring.
    ring_light_opening='off',ring_light_mb='match',
    -- Test4.8: large breathing glyph: after a burst it stays risen and fades
    -- (instead of falling); at the floor it shows only the window-opening
    -- flash (no breathing).
    mb_glyph_after='fade',mb_glyph_rest='hidden'}
-- Exact 2026-10-22 Killala profile (identical to Cioara's 2026-11-16 saved
-- TargetSC settings): `//tsc preset killala` restores the pre-Test3 look.
M.killala={mb_glyph_height=0,mb_glyph_tint=1,mb_glyph_rise=0,mb_intro_glyph=1,mb_intro_disc=1,disc_blend='split',ring_blend='split',
    ring_spin='classic',ring_shade=0,ring_glow_spin=1,mb_ending_drop=0,
    mb_glow_shade=0,mb_glow_spin=0,mb_glow_flicker=1,mb_glow_width=1,
    awakening_inner=1,awakening_outer=1,awakening_size=1,
    opener_disc_inner=1,opener_disc_outer=1,opener_disc_size=1,awakening_until='default',
    opener_fade=0,opener_fade_length=1,opener_fade_curve=1,opener_fade_end='lead',opener_fade_glow=1,
    opener_layout='rings',opener_spacing=.035,opener_spin_slowdown=3,opener_spin_minimum=0,
    opener_disc_outline=-1,
    disc_inner=1,disc_outer=1,disc_size=1,disc_size_lines=1,disc_lightdark='classic',
    ring_lightdark='classic',ring_lightdark_spin=1,ring_lightdark_tint='gold',mb_lightdark_cycle=2,
    ring_light='classic',ring_light_cycle=4,ring_light_glow=1,ring_light_opening='on',ring_light_mb='white',
    mb_glyph_after='fall',mb_glyph_rest='breath'}
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
    if s.step==1 then
        -- Test4.1 opener spin: full speed through the wait, then ease toward
        -- a minimum (never above full) along (1-t)^slowdown; 0 = no slowing.
        -- Integrated analytically so the angle never jumps.
        local power=option(opts,'opener_spin_slowdown')
        local minimum=min(turns,option(opts,'opener_spin_minimum'))
        local charge=max(0,min(now,s.sc_open)-s.created)
        local elapsed=max(0,now-s.sc_open)
        local duration=s.closed and option(opts,'fade_duration')or max(.1,s.sc_close-s.sc_open)
        return 2*pi*option(opts,'disc_speed')*(turns*charge+minimum*elapsed+
            (turns-minimum)*M.slow_integral(elapsed,duration,power))
    end
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
-- Test4.0 opener section arcs, top of the stack first: {lead,tail} pairs.
-- One element: one arc. Two: each color leads and trails into the other
-- (game order, first on top). Light/Darkness (and level 4): one arc per
-- element, white/black heads trailing into each element color.
local function opener_arcs(p,context)
    local elements=context.elements(p)
    local color=function(e)return context.element_color(e)or white end
    if context.level(p)>=3 then
        local head=(p=='Darkness'or p=='Umbra')and {0,0,0}or white
        local arcs={}
        for _,e in ipairs(elements)do arcs[#arcs+1]={head,color(e),head=true}end
        return arcs
    elseif #elements>=2 then
        return {{color(elements[1]),color(elements[2])},{color(elements[2]),color(elements[1])}}
    end
    local c=color(elements[1]or 'Light')
    return {{c,c}}
end
-- Test4.5: is this a level-3 Light/Darkness link drawn in the elements look?
local function lightdark(s,opts)
    if s.step<=1 or s.level~=3 then return false end
    if s.properties[1]=='Darkness'then return option(opts,'ring_lightdark')=='elements'end
    -- Light has its own mode since Test4.6 (white|elements|classic).
    return s.properties[1]=='Light'and option(opts,'ring_light')=='elements'
end
-- Test4.6 Light 'white' look: all strands white, element-colored inner glows.
local function light_white(s,opts)
    return s.step>1 and s.level==3 and s.properties[1]=='Light'and option(opts,'ring_light')=='white'
end
local function element_colors(p,context)
    local r={}
    for _,e in ipairs(context.elements(p))do r[#r+1]=context.element_color(e)or white end
    return r
end
local function specifications(s,context,opts)
    local result={}
    if light_white(s,opts)then
        return {{colors={white},radial=1,stack=0},{colors={white},radial=1,stack=.035},
            {colors={white},radial=1,stack=.07}}
    end
    if lightdark(s,opts)then
        -- Bottom and top strands white (Light) or black (Darkness); the middle
        -- strand blends around the circle through the four element colors.
        local head=s.properties[1]=='Darkness'and {0,0,0}or white
        return {{colors={head},radial=1,stack=0},
            {colors=element_colors(s.properties[1],context),radial=1,stack=.035,spin=option(opts,'ring_lightdark_spin')},
            {colors={head},radial=1,stack=.07}}
    end
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
    -- Added glow spin (turns/sec, negative reverses) on top of each glyph's
    -- own angle; continuous clock so a re-strike never jumps the lit side.
    local glow_turn=2*pi*option(opts,'mb_glow_spin')*max(0,now-s.created)
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
    -- Test4.7: Light's colored inner glows: 0 before the window, rising to
    -- `rings light glow` over the same .3 s opening transition.
    local light_open=1
    if light_white(s,opts)and option(opts,'ring_light_opening')=='off'then
        light_open=smooth((now-(s.sc_open-.15))/.30)
    end
    -- Test4.7: level-3 Light MB ring matches the lowest SC ring's look:
    -- white, the same lit side and the same rotation (MB timing kept).
    local mb_like_ring=light_white(s,opts)and option(opts,'ring_light_mb')=='match'
    if light_white(s,opts)then mb_color=white end -- white breathing for Light
    if lightdark(s,opts)then
        -- Cycle through the four element colors; at multiplier 2 each color
        -- hands to the next twice as fast as level 2's two-color cycle.
        local four=element_colors(s.properties[1],context)
        local per=option(opts,'mb_period')/max(.05,option(opts,'mb_lightdark_cycle'))
        local position=(age/per)%#four
        local k=math.floor(position)
        mb_color=mix(four[k+1],four[(k+1)%#four+1],smooth(position-k))
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
        local mode=option(opts,'ring_blend')
        local smooth_mode=mode=='gradient'or mode=='firm'
        local burst_glow=role=='burst-glow'
        local shade=burst_glow and option(opts,'mb_glow_shade')or option(opts,'ring_shade')
        local eligible=#colors<=2 and (burst_glow or (not opener and (part=='ground'or part=='sky'))
            or (part=='mb'and mb_like_ring))
        if eligible and smooth_mode and (shade>0 or (mode=='firm'and #colors==2))then
            -- Lit side: one side slightly brighter, the opposite slightly
            -- dimmer; the native gradient blends alpha too, so it turns with
            -- the ring. gradient: A+ | mid | B- | mid (even fade).
            -- firm: A+ | A | B- | B — each color holds through its half and
            -- the fade concentrates where they meet (four-stop "harder" blend).
            local c1,c2=colors[1],colors[#colors]
            if mode=='firm'then
                p={context.argb(c1,a*(1+shade)),context.argb(c1,a*(1+shade*.35)),
                    context.argb(c2,a*(1-shade)),context.argb(c2,a*(1-shade*.35))}
            elseif #colors==1 then
                p={context.argb(c1,a*(1+shade)),context.argb(c1,a*(1-shade))}
            else
                local middle=mix(c1,c2,.5)
                p={context.argb(c1,a*(1+shade)),context.argb(middle,a),
                    context.argb(c2,a*(1-shade)),context.argb(middle,a)}
            end
        end
        out[#out+1]={radius=r,offset=h,width=0,pixels=pixels,color=p[1],colors=p,
            rotation=rotation or 0,role=role,part=part,strand=strand,
            gap=opener and (part=='ground'or part=='sky')and option(opts,'opener_gap')or 0,
            blend=(burst_glow or not opener)and #p>1 and smooth_mode and 1 or 0}
        local entry=out[#out]
        if opener and (part=='ground'or part=='sky')and entry.gap>0 then
            -- Opener arc fade (native 0.8.0). Openers spin toward increasing
            -- angle, so +1 keeps the end facing the spin bright ("lead").
            local fade=option(opts,'opener_fade')*(role=='glow'and option(opts,'opener_fade_glow')or 1)
            if fade>0 then
                entry.fade=min(1,fade)
                entry.fade_length=option(opts,'opener_fade_length')
                entry.fade_curve=option(opts,'opener_fade_curve')
                entry.fade_direction=option(opts,'opener_fade_end')=='trail'and -1 or 1
            end
        end
    end
    local function arc(r,h,lead,tail,a,pixels,role,part,strand,rotation,start,span)
        if a<=.002 or r<.01 then return end
        local fade=option(opts,'opener_fade')*(role=='glow'and option(opts,'opener_fade_glow')or 1)
        out[#out+1]={kind='arc',radius=min(r,100),offset=h,width=0,pixels=pixels,
            color=context.argb(lead,a),tail=context.argb(tail,a),colors={context.argb(lead,a)},
            rotation=rotation or 0,arc_start=start,arc_span=span,role=role,part=part,strand=strand,gap=0,blend=0,
            fade=min(1,max(0,fade)),fade_length=option(opts,'opener_fade_length'),
            fade_curve=option(opts,'opener_fade_curve'),
            fade_direction=option(opts,'opener_fade_end')=='trail'and -1 or 1}
    end
    local function ring(r,h,colors,a,part,strand,rotation,light,glow_colors,glow_gain)
        local opening=opener and (part=='ground'or part=='sky')
        local mode=opening and option(opts,'opener_glow')or 'color'
        if glow>0 and light~=false and mode~='off'then
            local surround=mode=='black'and {{0,0,0}}or glow_colors or colors
            band(r,h,surround,a*.24*glow*(glow_gain or 1),px+4*min(glow,3),'glow',part,strand,
                opening and rotation or (rotation or 0)*option(opts,'ring_glow_spin'))
        end
        band(r,h,colors,a,px,'core',part,strand,rotation)
    end
    local function disc(r,h,angle,colors,a,glyph,outline,role,stroke_color)
        if (a<=.002 and outline<=.002)or r<.01 or #out.discs>=8 then return end
        r=min(r,100)
        local p=packed(colors,a)
        local mode=option(opts,'disc_blend')
        if mode=='firm'and #p==2 then p={p[1],p[1],p[2],p[2]}end -- hold, then meet
        out.discs[#out.discs+1]={radius=r,offset=h,rotation=angle,color=p[1],colors=p,
            glyph=glyph,outline=context.argb(stroke_color or white,outline),role=role,
            blend=#p>1 and (mode=='gradient'or mode=='firm')and 1 or 0}
    end
    local electric=1
    if not opener and s.level==3 then electric=.68+.32*sin(age*11)^2
    elseif not opener and s.level>=4 then electric=(.37+.63*sin(age*23)^2)*(.72+.28*sin(age*28)^2)end
    local sections=opener and option(opts,'opener_layout')=='sections'and (context.native_level or 9)>=9
    if show_sc and phase~='mb-only'and phase~='expired'and sections then
        -- Test4.0: each property owns an equal section of the circle; its
        -- elements are stacked arcs at the same radius, lifted by spacing.
        local alpha=opacity*option(opts,'brightness')*(phase=='pre'and .78 or .95)*fade
        local n=#s.properties
        local gap=({90,60,30})[n]or 30
        local section=(360-n*gap)/n
        local rotation=M.rotation(s,now,opts)
        local function shade(c,head)
            local target=(not head)and option(opts,'opener_muted')and muted(c)or c
            return mix(mix(white,target,color_t),white,flash)
        end
        local mode=option(opts,'opener_glow')
        out.strands=0
        for k,p in ipairs(s.properties)do
            local start=(k-1)*(section+gap)+gap/2
            local arcs=opener_arcs(p,context)
            for idx,pair in ipairs(arcs)do
                out.strands=out.strands+1
                local lead,tail=shade(pair[1],pair.head),shade(pair[2],false)
                local lift=(#arcs-idx)*option(opts,'opener_spacing')
                local strand=(k-1)*4+idx
                for _,place in ipairs({{bottom,'ground'},{top,'sky'}})do
                    if place[1]then
                        local h=place[1]+lift
                        local draw_radius=radius
                        if place[2]=='sky'then draw_radius=radius*M.bell_factor(top-bottom,height,opts)end
                        if glow>0 and mode~='off'then
                            local gl,gt=lead,tail
                            if mode=='black'then gl,gt={0,0,0},{0,0,0}end
                            arc(draw_radius,h,gl,gt,alpha*.24*glow,px+4*min(glow,3),'glow',place[2],strand,rotation,start,section)
                        end
                        arc(draw_radius,h,lead,tail,alpha,px,'core',place[2],strand,rotation,start,section)
                    end
                end
            end
        end
    elseif show_sc and phase~='mb-only'and phase~='expired'then
        local specs=specifications(s,context,opts)
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
            -- classic: only openers and L2 turn, slowing to a stop. disc
            -- (default): every link turns with the property disc, at its stage
            -- speed easing to the disc minimum, so rings and glyph stay in step.
            local rotation=(opener or s.level==2)and M.rotation(s,now,opts)or 0
            if not opener and option(opts,'ring_spin')=='disc'then rotation=M.disc_rotation(s,now,opts)end
            rotation=rotation*(spec.spin or 1) -- Light/Darkness middle strand may turn at its own rate
            for _,place in ipairs({{bottom,'ground'},{top,'sky'}})do
                if place[1]then
                    local h=place[1]+spec.stack
                    local draw_radius=r
                    if place[2]=='sky'then
                        draw_radius=r*M.bell_factor(top-bottom,height,opts)
                    end
                    -- Test4.6: Light white look: the four inner rings (top to
                    -- bottom: sky middle, sky lower, ground upper, ground
                    -- middle) glow in the element colors, rotating slowly.
                    local inner_glow
                    if light_white(s,opts)then
                        local index=place[2]=='sky'and (j<=2 and 3-j)or (place[2]=='ground'and j>=2 and 6-j)or nil
                        if index then
                            local four=element_colors('Light',context)
                            local step=age/max(.1,option(opts,'ring_light_cycle'))
                            local k=math.floor(step)
                            local a1=four[(index-1+k)%4+1]
                            local a2=four[(index+k)%4+1]
                            inner_glow=mix(a1,a2,smooth(step-k))
                        end
                    end
                    if glow>0 and not opener and s.level>=3 then
                        local tint=(s.properties[1]=='Darkness'or s.properties[1]=='Umbra')and {132,74,224}or gold
                        -- Light's gold glow reads close to Earth; the elements
                        -- look may use a white glow instead (rings lightdark tint).
                        if lightdark(s,opts)and s.properties[1]=='Light'and option(opts,'ring_lightdark_tint')=='white'then tint=white end
                        if light_white(s,opts)then tint=inner_glow or white end
                        band(draw_radius,h,{tint},opacity*.32*glow*electric*fade*(inner_glow and option(opts,'ring_light_glow')*light_open or 1),px+6*min(glow,3),'glow',place[2],j,
                            rotation*option(opts,'ring_glow_spin'))
                    end
                    ring(draw_radius,h,colors,alpha,place[2],j,rotation,nil,
                        inner_glow and {inner_glow}or nil,inner_glow and option(opts,'ring_light_glow')*light_open or nil)
                end
            end
        end
    end
    -- One pooled large glyph: opener fill, continuous breath and layered MB
    -- bloom. Clapper strikes contract/settle along the property return curve.
    if opening then
        local progress=clamp((now-opening.created)/max(.1,opening.open-opening.created),0,1)
        local grow=1-(1-clamp(progress*3,0,1))^3
        local initial=0
        if show_sc and opening.opener_seen and option(opts,'awakening')then
            local span=max(.1,opening.open-opening.created)
            local start=opening.created+span/3 -- the grow ends here, as before
            local mode=tostring(option(opts,'awakening_until'))
            local finish=opening.created+span*2/3
            if mode=='open'then finish=opening.open
            elseif mode=='close'then finish=max(opening.open,opening.close or opening.open)
            elseif tonumber(mode)then
                -- Never outlast the opener's own window: past its end the whole
                -- display clears, so cap the timed fade to finish cleanly.
                finish=min(opening.open+tonumber(mode),max(opening.open,opening.close or opening.open))
            end
            local level=1-smooth((now-start)/max(.05,finish-start))
            -- A link takes over: finish quickly and continuously, no pop.
            if s.step>1 then level=level*(1-smooth((now-s.created)/.3))end
            initial=option(opts,'awakening_opacity')*opacity*level
        end
        if initial>0 and s.step>1 then
            -- The link's large MB glyph now owns the pooled shape, so the
            -- lingering awakening disc finishes as its own fill disc.
            local before=#out.discs
            disc(radius*.96*option(opts,'awakening_size'),option(opts,'disc_height'),0,{white},initial,0,0,'awakening')
            if #out.discs>before then
                local d=out.discs[#out.discs]
                d.inner,d.outer=option(opts,'awakening_inner'),option(opts,'awakening_outer')
            end
            initial=0
        end
        local role='mb-glyph'
        local fill=0
        local color=white -- steady neutral breath; only confirmed MBs tint it
        local resting_radius=clapper and s.step>1 and mb_radius or radius*.96
        opening.radius=resting_radius
        opening.offset=option(opts,'disc_height')
        opening.rotation=clapper and -2*pi*option(opts,'mb_spin')*max(0,now-opening.created)or 0
        opening.opacity=response.idle
        -- Test4.8 rest hidden: no floor breathing; the window-opening flash,
        -- bursts and the ending still light it.
        if clapper and option(opts,'mb_glyph_rest')=='hidden'and not response.ending then opening.opacity=0 end
        local fades=clapper and option(opts,'mb_glyph_after')=='fade'
        if initial>0 then
            role='awakening';fill=initial
            opening.radius=opening.radius*grow*option(opts,'awakening_size');opening.opacity=0
        end
        if response.responding then
            fill=0;role='mb-glyph'
            if clapper then
                local energy=option(opts,'mb_burst')>0 and (response.property or 0)or 0
                local strike=energy*(1+(option(opts,'mb_burst')-1)*(1-energy))
                opening.radius=resting_radius*(1+option(opts,'mb_expand')*energy)
                local rest=option(opts,'disc_height')
                local ring_fraction=option(opts,'mb_glyph_height')
                if ring_fraction>0 then
                    -- Rise toward (or just past) the steady MB ring, using the
                    -- SAME return energy as the lifted property trace so both
                    -- land together. A re-strike continues from the current
                    -- height (response.glyph_rise) instead of dropping first.
                    -- Test4.8 fade: stay at the risen height (no fall); the
                    -- opacity below fades along the same return energy.
                    local rise=(response.glyph_rise or 1)*(fades and 1 or energy)
                    opening.offset=rest+(mb_height-rest)*ring_fraction*rise
                else
                    opening.offset=rest+height*option(opts,'mb_rise')*(fades and 1 or energy)
                end
                color=mix(color,response.element,strike*option(opts,'mb_glyph_tint'))
                opening.opacity=opening.opacity+(1-opening.opacity)*strike
            else
                color=mix(response.element,white,response.white)
                opening.radius=resting_radius*(1+option(opts,'mb_expand')*response.rise)
                opening.offset=option(opts,'disc_height')+height*option(opts,'mb_rise')*response.rise
                opening.opacity=response.release
            end
        end
        local glyph_intro=intro*option(opts,'mb_intro_glyph')
        if glyph_intro>0 then
            -- A new MB window may announce itself more quietly on the large
            -- glyph than on the property disc and ring (mb intro glyph).
            role='mb-glyph';fill=0
            color=mix(color,white,glyph_intro)
            opening.opacity=opening.opacity+(1-opening.opacity)*glyph_intro
        end
        if response.ending then
            -- A closing signal wins over a simultaneous hit's color/alpha,
            -- while an already rising glyph keeps its continuous trajectory.
            color=white
            opening.opacity=response.end_flash*option(opts,'mb_effects')
        end
        if role=='mb-glyph'then opening.opacity=opening.opacity*mb_overall end
        out.awakening_glyph=opening
        local before=#out.discs
        disc(opening.radius,opening.offset,fill>0 and 0 or opening.rotation,{white},fill,fill>0 and 0 or 2,
            fill>0 and 0 or opening.opacity,role,color)
        if role=='awakening'and #out.discs>before then
            -- Radial fill: center and rim opacity multipliers (native 0.7.0).
            local d=out.discs[#out.discs]
            d.inner,d.outer=option(opts,'awakening_inner'),option(opts,'awakening_outer')
        end
        if clapper and response.element and (response.shimmer or 0)>0 then
            -- The shimmer follows the glyph: white unless mb glyph tint > 0.
            local shimmer_color=mix(white,response.element,option(opts,'mb_glyph_tint'))
            band(opening.radius,opening.offset,{shimmer_color},mb_overall*min(1,response.shimmer)*.65,
                px+10*option(opts,'mb_glow_width'),'burst-glow','mb-glyph',0,opening.rotation+glow_turn)
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
        -- Test4.2: opener discs may use their own line opacity (-1 = same
        -- as discs outline).
        local line=option(opts,'disc_outline')
        if opener and option(opts,'opener_disc_outline')>=0 then line=option(opts,'opener_disc_outline')end
        local outline=line*opacity*life*reveal
        local base=option(opts,'disc_height')+details.ground_wave
        local glyph=option(opts,'disc_style')=='outline'and 2 or option(opts,'disc_style')=='fill'and 0 or 1
        local properties=opener and s.properties or {s.properties[1]}
        for j,p in ipairs(properties)do
            local colors=property_palette(p,context)
            local terminal=not opener and s.level>=4
            -- Test4.4 Light/Darkness 'elements' look: white/black center (hub)
            -- blending out to a rim of the four element colors.
            local hub
            if not terminal and (p=='Light'or p=='Darkness')and option(opts,'disc_lightdark')=='elements'then
                colors={}
                for _,e in ipairs(context.elements(p))do colors[#colors+1]=context.element_color(e)or white end
                hub=p=='Darkness'and {0,0,0}or white
            end
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
                if hub then hub=mix(hub,clapper and response.element or white,flash)end
            end
            local disc_intro=intro*option(opts,'mb_intro_disc')
            if disc_intro>0 then
                disc_fill=disc_fill+(mb_overall-disc_fill)*disc_intro
                disc_outline=disc_outline+(mb_overall-disc_outline)*disc_intro
                stroke=mix(stroke,white,disc_intro)
                for i,c in ipairs(colors)do colors[i]=mix(c,white,disc_intro)end
                if hub then hub=mix(hub,white,disc_intro)end
            end
            local angle=M.disc_rotation(s,now,opts)
            -- Stage-specific fill/line sizing and radial fade (opener or links).
            local fill_size=opener and option(opts,'opener_disc_size')or option(opts,'disc_size')
            local line_size=opener and 1 or option(opts,'disc_size_lines')
            local inner=opener and option(opts,'opener_disc_inner')or option(opts,'disc_inner')
            local outer=opener and option(opts,'opener_disc_outer')or option(opts,'disc_outer')
            local function finish_fill(d,a)
                if inner~=1 or outer~=1 then d.inner,d.outer=inner,outer end -- 1 1 = untouched
                if hub then d.hub=context.argb(hub,a)end
            end
            local h=base+.006+(j-1)*.008
            if terminal or clapper then
                -- Separate planes let a struck trace lift while its fill
                -- remains anchored. Terminal traces keep their .006 clearance.
                local r=terminal and radius*.92 or radius*(.78-(j-1)*.11)
                local respond=flash>0 or disc_intro>0
                local before=#out.discs
                local fill_alpha=(glyph==2 and not respond)and 0 or disc_fill
                disc(r*fill_size,h,angle,colors,fill_alpha,0,0,'property')
                if #out.discs>before then finish_fill(out.discs[#out.discs],fill_alpha)end
                local trace_height=h+(terminal and .006 or 0)
                if clapper and mb_overall>0 then
                    trace_height=trace_height+(response.lift or 0)*option(opts,'mb_floor')
                end
                disc(r*line_size,trace_height,angle,{white},0,2,
                    (glyph==0 and not respond)and 0 or disc_outline,'property-trace',stroke)
                if clapper and response.element and (response.shimmer or 0)>0 and option(opts,'mb_floor')>0 then
                    band(r*line_size,trace_height,{response.element},mb_overall*min(1,response.shimmer)*option(opts,'mb_floor'),
                        px+12*option(opts,'mb_glow_width'),'burst-glow','property-trace',0,angle+glow_turn)
                end
            else
                local r=radius*(.78-(j-1)*.11)
                local line_style=(flash>0 or disc_intro>0)and 1 or glyph
                local custom=fill_size~=1 or line_size~=1 or inner~=1 or outer~=1 or hub~=nil
                if custom and line_style~=2 then
                    -- Classic path: draw the fill on its own (resized, radial,
                    -- hub) and the glyph lines separately at their own size.
                    local before=#out.discs
                    disc(r*fill_size,h,angle,colors,disc_fill,0,0,'property')
                    if #out.discs>before then finish_fill(out.discs[#out.discs],disc_fill)end
                    if line_style~=0 then disc(r*line_size,h,angle,{white},0,2,disc_outline,'property',stroke)end
                else
                    disc(r,h,angle,colors,disc_fill,line_style,disc_outline,'property',stroke)
                end
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
        local ring_height=mb_height
        if response.ending and clapper then
            -- Through the closing pulses the MB ring settles down onto the
            -- large glyph's resting plane (same radius), reaching it at the
            -- real MB deadline when everything goes dark.
            local progress=clamp(1-(s.mb_close-now)/option(opts,'mb_ending'),0,1)
            ring_height=mb_height+(option(opts,'disc_height')-mb_height)*
                option(opts,'mb_ending_drop')*smooth(progress)
        end
        local mb_rotation=0
        if mb_like_ring then
            -- Same turn as the lowest SC ring (level 3 uses the disc spin
            -- unless rings spin classic, where level 3 does not turn).
            mb_rotation=option(opts,'ring_spin')=='disc'and M.disc_rotation(s,now,opts)or 0
        end
        ring(mb_radius,ring_height,{color},alpha*mb_overall,'mb',0,mb_rotation)
    end
    while #out>32 do table.remove(out,1)end
    return out
end
return M
