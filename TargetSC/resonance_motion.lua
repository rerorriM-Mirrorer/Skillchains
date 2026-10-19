-- Analytic TargetSC presentation. All live phase boundaries come from source
-- created/sc_open/sc_close/mb_close. Only explicit preview supplies fake state.
-- Author: A.
local M={}
local min,max,sin,exp,pi=math.min,math.max,math.sin,math.exp,math.pi
local function clamp(v,a,b)return max(a,min(b,v))end
local function smooth(v)v=clamp(v,0,1)return v*v*(3-2*v)end
M.defaults={opacity=1,scale=2,height=1,intensity=2,motion='flutter',layout='grounded',
    period=.15,amplitude=.28,damping=.85,width=2,glow=.8,brightness=1,discs=true,disc_opacity=.32}
local white={255,255,255}
local gold={255,217,115}
local function option(opts,k)
    if opts[k]~=nil then return opts[k] end
    return M.defaults[k]
end
local function mix(a,b,t)
    t=clamp(t,0,1)return {a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t,a[3]+(b[3]-a[3])*t}
end
function M.phase(s,now)
    if now<s.sc_open then return 'pre' end
    if s.closed then return now<s.mb_close and 'mb-only' or 'expired' end
    if now<s.sc_close then return 'countdown' end
    if now<s.sc_close+.22 then return 'expiration' end
    return now<s.mb_close and 'mb-only' or 'expired'
end
local function oscillator(age,opts,level)
    local period=option(opts,'period')*(level==3 and 1.5 or level>=4 and .7 or 1)
    if option(opts,'motion')=='sine' then return .5+.5*sin(age*pi/period),age end
    local tick=math.floor((max(0,age)+1e-9)/period)
    return tick%2,tick*period
end
function M.positions(s,now,height,opts)
    local phase=M.phase(s,now)
    local age=max(0,now-s.created)
    local elapsed=max(0,now-s.sc_open)
    local remaining=clamp((s.sc_close-now)/max(.1,s.sc_close-s.sc_open),0,1)
    local floor=height*.035
    if s.closed and now>=s.sc_open then return floor,nil,0 end
    -- An opener has no sky until the authoritative window-opening boundary.
    -- A successful chain recharges the existing pair immediately at impact.
    local paired=s.step>1 or phase~='pre'
    if not paired then
        local u=oscillator(age,opts,s.level)
        local local_amp=height*.055*option(opts,'intensity')*(.35+.65*exp(-age*.9))
        local fall=height*.12*(1-smooth(age/.25))
        return floor+fall+u*local_amp,nil,remaining
    end
    local unfold=s.step>1 and smooth(age/.3) or smooth(elapsed/.28)
    local separation=phase=='pre' and 1 or remaining
    local span=height*.90*separation*unfold
    local layout=option(opts,'layout')
    local bottom,top=floor,floor+span
    if layout~='grounded' then
        bottom=height*.49-span*.5;top=height*.49+span*.5
    end
    if s.step>1 and s.previous and age<.3 then
        local old_bottom,old_top=M.positions(s.previous,s.created,height,opts)
        local reset=smooth(age/.3)
        bottom=old_bottom+(bottom-old_bottom)*reset
        top=(old_top or old_bottom)+(top-(old_top or old_bottom))*reset
    end
    local u,sampled=oscillator(phase=='pre' and age or elapsed,opts,s.level)
    local decay=phase=='pre' and (.40+.60*exp(-sampled*.55)) or exp(-sampled*option(opts,'damping'))
    local amp=height*option(opts,'amplitude')*option(opts,'intensity')*decay*separation*unfold
    if phase=='pre' then amp=amp*.32 end
    if layout=='center' then
        local inward=clamp(option(opts,'amplitude')*option(opts,'intensity')*decay,0,1)*u
        local mid=(bottom+top)*.5
        bottom=bottom+(mid-bottom)*inward;top=top+(mid-top)*inward
    else
        -- Opposed flutter: floor->center and sky->center on the same tick.
        -- Allow overlap at large user amplitude, but keep the ground above terrain.
        bottom=max(floor,bottom+u*amp);top=max(floor,top-u*amp)
    end
    return bottom,top,remaining
end
local function colors_for(s,context)
    if s.step>1 then return context.palette(s) end
    -- One concentric strand/disc per inherent opening WS property. Each uses
    -- its own primary color, not a falsely completed L2/L3 result palette.
    local result={}
    for _,p in ipairs(s.properties)do
        local temp={properties={p},elements=s.elements,level=(p=='Light' or p=='Darkness') and 3 or
            (p=='Radiance' or p=='Umbra') and 4 or 1}
        result[#result+1]=context.palette(temp)[1]
    end
    return result
end
function M.frame(model,s,now,radius,height,opts,context)
    local out={discs={}}
    local age=max(0,now-s.created)
    local delay=max(.1,s.sc_open-s.created)
    local phase=M.phase(s,now)
    out.phase=phase
    if phase=='expired' then return out end
    local colors=colors_for(s,context)
    local bottom,top,remaining=M.positions(s,now,height,opts)
    out.ground,out.sky,out.remaining=bottom,top,remaining
    local intensity=option(opts,'intensity')
    local opacity=option(opts,'opacity')
    local px=max(1,option(opts,'width'))
    local glow=option(opts,'glow')
    local function ring(r,h,c,a,width,light)
        if a<=.002 or r<.01 then return end
        local pixels=width or px
        if glow>0 and light~=false then
            out[#out+1]={radius=r,offset=h,width=0,pixels=pixels+4*min(glow,3),
                color=context.argb(c,a*.24*glow),role='glow'}
        end
        out[#out+1]={radius=r,offset=h,width=0,pixels=pixels,color=context.argb(c,a),role='core'}
    end
    local function disc(r,h,angle,c,a,glyph)
        if not option(opts,'discs') or a<=.002 or r<.01 then return end
        if #out.discs>=8 then return end
        out.discs[#out.discs+1]={radius=r,offset=h,rotation=angle,color=context.argb(c,a),glyph=glyph and 1 or 0}
    end
    local opener=s.step==1
    local progress=clamp(age/delay,0,1)
    -- Successful-chain white charge and the 0.30s boundary-centered color
    -- transition match Animation8 without importing or mutating its painter.
    local color_t=opener and smooth((progress-1/3)*3) or smooth((now-(s.sc_open-.15))/.30)
    local flash=s.suppress_impact and 0 or clamp(1-age/.3,0,1)*min(1,intensity)
    local end_flash=phase=='expiration' and clamp(1-(now-s.sc_close)/.22,0,1) or 0
    local electric=1
    if not opener and s.level==3 then electric=.68+.32*sin(age*11)^2
    elseif not opener and s.level>=4 then
        electric=(.37+.63*sin(age*23)^2)*(phase=='pre' and 1 or .72+.28*sin(age*28)^2)
    end
    local alpha=opacity*option(opts,'brightness')*(phase=='pre' and .78 or .95)
    if s.level>=3 and not opener then alpha=alpha*(.72+.28*electric) end
    if phase=='expiration' then alpha=alpha*end_flash end
    if phase=='mb-only' then
        local life=clamp((s.mb_close-now)/10,0,1)
        ring(radius,height*.49,colors[#colors],opacity*.30*life,px)
        if option(opts,'discs') and s.level>=4 then
            local solid=(s.properties[1]=='Umbra' or s.properties[1]=='Darkness') and {0,0,0} or white
            disc(radius*.78,height*.055,0,solid,option(opts,'disc_opacity')*life,false)
        end
    else
        local strands=not opener and age<.16 and 1 or #colors
        for j=1,strands do
            local c=colors[j]
            local radius_j=radius*(1+(j-(strands+1)/2)*.075)
            local color=mix(white,c,color_t)
            color=mix(color,white,max(flash,end_flash))
            local glow_color=(not opener and s.level>=4) and
                ((s.properties[1]=='Umbra' or s.properties[1]=='Darkness') and {132,74,224} or gold) or
                (not opener and s.level==3 and ((s.properties[1]=='Darkness') and {115,95,165} or white)) or color
            -- The luminous perimeter can already carry gold/electric color
            -- while the core is white-charged, as in Animation8.
            if glow>0 and not opener and s.level>=3 then
                out[#out+1]={radius=radius_j,offset=bottom,width=0,pixels=px+6*min(glow,3),
                    color=context.argb(glow_color,opacity*.32*glow*electric),role='glow'}
                if top then out[#out+1]={radius=radius_j,offset=top,width=0,pixels=px+6*min(glow,3),
                    color=context.argb(glow_color,opacity*.32*glow*electric),role='glow'} end
            end
            ring(radius_j,bottom,color,alpha)
            if top then ring(radius_j,top,color,alpha) end
        end
        local disc_alpha=option(opts,'disc_opacity')*opacity
        if opener and phase=='pre' then
            -- Explicit source-relative thirds: white awakening, property reveal,
            -- then colored preparation pulse. A non-3s source delay scales them.
            local grow=1-(1-clamp(progress*3,0,1))^3
            disc(radius*.96*grow,height*.07,0,white,opacity*.48*(1-smooth((progress-1/3)*3)),false)
            local pulse=progress<2/3 and clamp((progress-1/3)*3,0,1) or clamp((progress-2/3)*3,0,1)
            if progress>=1/3 then
                disc(radius*(.12+.72*pulse),height*.04,0,progress<2/3 and white or colors[1],
                    opacity*.46*sin(pi*pulse)*(1-pulse),false)
            end
        end
        local reveal=opener and smooth((progress-1/3)*3) or 1
        local fade=phase=='pre' and 1 or remaining
        local turns=opener and .5 or s.level==1 and 1 or s.level==2 and 2 or s.level==3 and 4 or 0
        local disc_colors=colors
        if not opener and age<.3 then disc_colors={white} end
        for j=#disc_colors,1,-1 do
            local c=mix(white,disc_colors[j],color_t)
            local glyph=true
            if not opener and s.level>=4 then
                c=(s.properties[1]=='Umbra' or s.properties[1]=='Darkness') and {0,0,0} or white;glyph=false
            end
            disc(radius*(.68+(j-1)*.075),height*(.065+(#disc_colors-j)*.012),
                age*2*pi*turns,c,disc_alpha*reveal*fade,glyph)
        end
    end
    -- MB presentation deliberately retained for this iteration. It is a
    -- separate bounded event queue and never mutates any source deadline.
    local bursts=model.bursts[s.id] or {}
    for i=#bursts,1,-1 do
        local b=bursts[i];local a=now-b.at
        if a>.52 then table.remove(bursts,i)
        elseif a>=0 then
            local f=(1-a/.52)^2*opacity*intensity
            ring(radius*(1+a*3),height*.42,b.color,f*.6,px,false)
            if a<.16 then ring(radius,height*.49+sin(a*110)*height*.008,mix(b.color,white,.4),f*.5,px,false) end
        end
    end
    while #out>32 do table.remove(out,1) end
    return out
end
return M
