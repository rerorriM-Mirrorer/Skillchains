-- Analytic presentation driven by source timestamps, never accumulated frames.
-- Strike displacement and the settled ground hum are in world units. Author: A.
local M={}
local min,max,sin,exp,pi=math.min,math.max,math.sin,math.exp,math.pi
local function clamp(v,a,b)return max(a,min(b,v))end
local function smooth(v)v=clamp(v,0,1)return v*v*(3-2*v)end
-- Lionstag's 2026-10-19 13:16:05 snapshot is the resettable Test3 baseline.
-- Existing saved settings survive; preset default deliberately restores these.
M.defaults={opacity=.3,scale=2,height=1,intensity=1,motion='sine',layout='grounded',
    period=.09,amplitude=.3,damping=3,width=2,glow=1,brightness=4,discs=true,disc_opacity=.3,
    hum_amplitude=.018,hum_period=.12,hum_slowdown=1,hum_gain=.35,
    disc_outline=.45,disc_style='glyph',disc_height=.008,disc_speed=1,disc_slowdown=1,
    awakening=true,awakening_opacity=.3,ground_height=.04,fade_duration=.8}
local white,gold={255,255,255},{255,217,115}
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
    local turns=s.step==1 and .5 or s.level==1 and 1 or s.level==2 and 2 or s.level==3 and 4 or 0
    return 2*pi*turns*option(opts,'disc_speed')*energy_time(s,now,opts,option(opts,'disc_slowdown'))
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
    local floor=option(opts,'ground_height')
    local ground_wave,sky_wave,details=M.vibration(s,at,opts)
    details.ground_wave=ground_wave
    local paired=s.step>1 or phase~='pre'
    if not paired then return floor+ground_wave,nil,remaining,details end
    local unfold=s.step>1 and smooth(age/.3)or smooth(elapsed/.28)
    local span=height*.90*(s.closed and 1 or remaining)*unfold
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
            result[#result+1]={colors={c},radial=s.level>=4 and 1+(j-(#colors+1)/2)*.075 or 1,
                stack=(s.level==2 or s.level==3)and (j-1)*.035 or 0}
        end
    end
    return result
end
function M.frame(model,s,now,radius,height,opts,context)
    local out={discs={}}
    local age=max(0,now-s.created)
    local phase=M.phase(s,now,opts)
    out.phase=phase
    if phase=='expired'then return out end
    local bottom,top,remaining,details=M.positions(s,now,height,opts)
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
        local p=packed(colors,a)
        out[#out+1]={radius=r,offset=h,width=0,pixels=pixels,color=p[1],colors=p,
            rotation=rotation or 0,role=role,part=part,strand=strand}
    end
    local function ring(r,h,colors,a,part,strand,rotation,light)
        if glow>0 and light~=false then band(r,h,colors,a*.24*glow,px+4*min(glow,3),'glow',part,strand,rotation)end
        band(r,h,colors,a,px,'core',part,strand,rotation)
    end
    local function disc(r,h,angle,colors,a,glyph,outline,role)
        if (a<=.002 and outline<=.002)or r<.01 or #out.discs>=8 then return end
        local p=packed(colors,a)
        out.discs[#out.discs+1]={radius=r,offset=h,rotation=angle,color=p[1],colors=p,
            glyph=glyph,outline=context.argb(white,outline),role=role}
    end
    local electric=1
    if not opener and s.level==3 then electric=.68+.32*sin(age*11)^2
    elseif not opener and s.level>=4 then electric=(.37+.63*sin(age*23)^2)*(.72+.28*sin(age*28)^2)end
    if phase~='mb-only'then
        local specs=specifications(s,context)
        if not opener and age<.16 then specs={{colors={white},radial=1,stack=0}}end
        out.strands=#specs
        local alpha=opacity*option(opts,'brightness')*(phase=='pre'and .78 or .95)*fade
        if s.level>=3 and not opener then alpha=alpha*(.72+.28*electric)end
        for j,spec in ipairs(specs)do
            local colors={}
            for _,c in ipairs(spec.colors)do colors[#colors+1]=mix(mix(white,c,color_t),white,flash)end
            local r=radius*spec.radial
            local rotation=opener and M.rotation(s,now,opts)or 0
            for _,place in ipairs({{bottom,'ground'},{top,'sky'}})do
                if place[1]then
                    local h=place[1]+spec.stack
                    if glow>0 and not opener and s.level>=3 then
                        local tint=(s.properties[1]=='Darkness'or s.properties[1]=='Umbra')and {132,74,224}or gold
                        band(r,h,{tint},opacity*.32*glow*electric*fade,px+6*min(glow,3),'glow',place[2],j,rotation)
                    end
                    ring(r,h,colors,alpha,place[2],j,rotation)
                end
            end
        end
        -- One awakening flash, independent of persistent property discs.
        if opener and phase=='pre'and option(opts,'awakening')then
            local grow=1-(1-clamp(progress*3,0,1))^3
            local a=option(opts,'awakening_opacity')*opacity*(1-smooth((progress-1/3)*3))
            disc(radius*.96*grow,.004,0,{white},a,0,0,'awakening')
        end
        if option(opts,'discs')then
            local life=phase=='pre'and 1 or s.closed and fade or remaining
            local reveal=opener and smooth(progress*5)or 1
            local fill=option(opts,'disc_opacity')*opacity*life*reveal
            local outline=option(opts,'disc_outline')*opacity*life*reveal
            local base=option(opts,'disc_height')+details.ground_wave
            local glyph=option(opts,'disc_style')=='outline'and 2 or option(opts,'disc_style')=='fill'and 0 or 1
            disc(radius*.78,base,0,{white},0,2,outline*.65,'ground-glyph')
            local properties=opener and s.properties or {s.properties[1]}
            for j,p in ipairs(properties)do
                local colors=property_palette(p,context)
                if not opener then
                    if s.level>=4 then colors={(p=='Umbra'or p=='Darkness')and {0,0,0}or white};glyph=0
                    else for i,c in ipairs(colors)do colors[i]=mix(white,c,color_t)end end
                end
                disc(radius*(.78-(j-1)*.11),base+.006+(j-1)*.008,M.rotation(s,now,opts),
                    colors,fill,glyph,outline,'property')
            end
        end
    end
    -- Keep the independent MB-lifetime reminder halo as requested.
    if s.mb_close>now and now>=boundary then
        local colors=context.palette(s)
        ring(radius,height*.49,{colors[#colors]},opacity*.30*clamp((s.mb_close-now)/10,0,1),'mb',0,0)
    end
    local bursts=model.bursts[s.id]or {}
    for i=#bursts,1,-1 do
        local b=bursts[i];local a=now-b.at
        if a>.52 then table.remove(bursts,i)
        elseif a>=0 then
            local f=(1-a/.52)^2*opacity*intensity
            ring(radius*(1+a*3),height*.42,{b.color},f*.6,'burst',0,0,false)
            if a<.16 then ring(radius,height*.49+sin(a*110)*height*.008,{mix(b.color,white,.4)},f*.5,'burst',0,0,false)end
        end
    end
    while #out>32 do table.remove(out,1)end
    return out
end
return M
