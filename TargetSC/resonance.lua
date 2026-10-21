-- Pure state/animation model. No Windower or combat packet dependency. Author: A.
local M={}
local motion=require('resonance_motion')
M.defaults=motion.defaults
M.phase=motion.phase
local min,max,exp,sin,pi=math.min,math.max,math.exp,math.sin,math.pi
local function clamp(x,a,b) return max(a,min(b,x)) end
local function smooth(x) x=clamp(x,0,1) return x*x*(3-2*x) end
local E={Fire={255,64,40},Ice={120,235,255},Wind={115,245,145},Earth={176,114,48},
    Lightning={240,120,255},Water={65,130,255},Light={255,255,255},Dark={25,14,52},Darkness={25,14,52}}
local P={Liquefaction={'Fire'},Induration={'Ice'},Detonation={'Wind'},Scission={'Earth'},
    Impaction={'Lightning'},Reverberation={'Water'},Transfixion={'Light'},Compression={'Dark'},
    Fusion={'Light','Fire'},Fragmentation={'Lightning','Wind'},Gravitation={'Dark','Earth'},Distortion={'Water','Ice'}}
local levels={Fusion=2,Fragmentation=2,Gravitation=2,Distortion=2,Light=3,Darkness=3,Radiance=4,Umbra=4}
local names={}
for name in pairs(P) do names[name:lower()]=name end
for name in pairs(levels) do names[name:lower()]=name end
local alias={fire='Liquefaction',ice='Induration',wind='Detonation',earth='Scission',
    lightning='Impaction',water='Reverberation',dark='Compression'}
function M.property(name) return names[(name or 'Liquefaction'):lower()] or alias[(name or ''):lower()] end
function M.level(name) return levels[name] or 1 end
function M.elements(name) return P[name] or ((name=='Light' or name=='Radiance') and {'Fire','Wind','Lightning','Light'} or {'Earth','Ice','Water','Dark'}) end
local function palette(s)
    local dark=s.properties[1]=='Darkness' or s.properties[1]=='Umbra'
    if s.level==4 then
        return dark and {{5,3,14},{25,9,46},{49,18,78},{88,48,118}} or
            {{255,255,255},{255,252,228},{255,231,155},{237,193,91}}
    elseif s.level==3 then
        return dark and {{5,5,8},{29,15,45},{13,23,48}} or
            {{255,255,255},{248,244,222},{224,190,105}}
    end
    local colors={}
    if #s.properties==1 and P[s.properties[1]] then
        for _,e in ipairs(P[s.properties[1]]) do colors[#colors+1]=E[e] end
    else
        for _,e in ipairs(s.elements) do if E[e] and #colors<4 then colors[#colors+1]=E[e] end end
    end
    return #colors>0 and colors or {E.Light}
end
local function rgb(color,white)
    return {color[1]+(255-color[1])*white,color[2]+(255-color[2])*white,color[3]+(255-color[3])*white}
end
function M.argb(c,alpha)
    return math.floor(clamp(alpha,0,1)*255+.5)*16777216+math.floor(c[1]+.5)*65536+
        math.floor(c[2]+.5)*256+math.floor(c[3]+.5)
end
function M.dimensions(mob,opts)
    local size=tonumber(mob.model_size) or 0
    local scale=tonumber(mob.model_scale) or 1
    if scale<=0 then scale=1 end
    local extent=size>.05 and size*scale or 1.15*(.5/max(scale,.18))
    local radius_extent=extent
    if radius_extent>1.15 then radius_extent=1.15+math.sqrt(radius_extent-1.15)*.62 end
    return clamp(radius_extent*.55,.4,12)*opts.scale,
        clamp(extent*1.6,.65,30)*opts.scale*opts.height
end
local function base_motion(s,now)
    local age=max(0,now-s.created)
    local open_age=max(0,now-s.created-(s.step>1 and .12 or 0))
    local attack=smooth(open_age/.42)
    local left=clamp((s.sc_close-now)/max(.1,s.sc_close-s.sc_open),0,1)
    local separation=attack*(now<s.sc_open and 1 or left)
    local vibration=sin(age*2*pi*13)*exp(-age*4.5)*.025
    return age,separation,vibration
end
local function draw_state(out,s,now,radius,height,opts)
    local age,separation,vibration=base_motion(s,now)
    local tail=now>=s.sc_close or s.closed
    local colors=palette(s)
    local intensity=opts.intensity
    local function ring(r,h,w,c,a)
        if a<.002 then return end
        -- Glow first, then its delicate core. Native submission is capped at 24.
        out[#out+1]={radius=r,offset=h,width=w*4,color=M.argb(c,a*.10)}
        out[#out+1]={radius=r,offset=h,width=w,color=M.argb(c,a)}
    end
    local width=clamp(radius*.010,.008,.045)
    local mid=height*.49
    local strike=(s.step>1 and .26 or .18)
    local flash=clamp(1-age/strike,0,1)*intensity
    local end_flash=not s.closed and clamp(1-math.abs(now-s.sc_close)/.18,0,1)*intensity or 0
    if not tail or (s.closed and age<.65) or end_flash>0 then
        if s.closed then separation=smooth(age/.40)*(1-smooth((age-.40)/.25)) end
        local brightness=(.28+.30*(1-separation)^3+.12*flash+.12*end_flash)*opts.opacity
        local exit=tail and not s.closed and clamp(1-(now-s.sc_close)/.22,0,1) or 1
        local span=height*.45*separation
        for j,c in ipairs(colors) do
            local strand=j-(#colors+1)*.5
            local radial=(s.level>=3) and strand*radius*.035 or 0
            local stack=(s.level<3) and strand*height*.018 or 0
            local color=rgb(c,clamp(end_flash*.9+flash*.28,0,1))
            local a=brightness*exit*(s.level>=3 and .83 or 1)
            for _,side in ipairs({-1,1}) do
                local h=mid+side*span+stack+vibration*height*intensity*side
                ring(radius+radial,h,width,color,a)
            end
        end
    end
    -- MB can outlive continuation. One faint central halo remains; its life is
    -- based solely on the publisher's MB deadline, never a new SC timer.
    if tail and s.mb_close>now and (not s.closed or age>=.65) then
        local strength=clamp((s.mb_close-now)/10,0,1)
        local c=colors[#colors]
        ring(radius,mid,width,c,opts.opacity*.16*strength)
    end
    if flash>.01 then
        ring(radius*(.72+.28*smooth(age/.2)),mid,width*1.25,rgb(colors[1],.5),opts.opacity*.35*flash)
    end
end
function M.new()
    local self={states={},bursts={},awakening_glyphs={},connected=false,session=nil,sequence=0,events=0,
        gaps=0,rejected=0,clock_warning=0,unknown_bursts=0,synced=false}
    function self:clear() self.states={} self.bursts={} self.awakening_glyphs={} end
    function self:opening_glyph(state)
        local glyph=self.awakening_glyphs[state.id]
        if state.step==1 and (not glyph or glyph.created~=state.created)then
            glyph={created=state.created,open=state.sc_open,rotation=0,glyph=2,opacity=0,
                shape='property-glyph',radius=0,offset=0}
            self.awakening_glyphs[state.id]=glyph
        end
        return glyph
    end
    function self:receive(args,now)
        if #args<5 or args[1]~='1' then self.rejected=self.rejected+1 return false,'unsupported/malformed bridge frame' end
        local session,seq,kind,stamp=args[2],tonumber(args[3]),args[4],tonumber(args[5])
        if not session:match('^[%w.%-]+$') or not seq or not stamp or seq%1~=0 or seq<1 then
            self.rejected=self.rejected+1 return false,'invalid bridge envelope'
        end
        if kind=='online' then
            -- Duplicate/delayed handshakes must not rewind the current session.
            if session==self.session and seq<=self.sequence then return false,'duplicate' end
            self:clear() self.session=session self.sequence=seq-1 self.connected=true self.synced=false self.needs_sync=false
        elseif session~=self.session or not self.connected then return false,'awaiting source snapshot' end
        if seq<=self.sequence then return false,'duplicate' end
        if seq~=self.sequence+1 then self.gaps=self.gaps+1 self.needs_sync=true end
        self.sequence=seq self.events=self.events+1 self.last_event=now
        self.clock_warning=now-stamp
        if kind=='state' then
            if #args~=17 then self.rejected=self.rejected+1 return false,'malformed state' end
            local id,rev,created,open,close,mb,step,level,closed=unpack(args,6,14)
            id,rev,created,open,close,mb,step,level=tonumber(id),tonumber(rev),tonumber(created),tonumber(open),tonumber(close),tonumber(mb),tonumber(step),tonumber(level)
            if not id or id<=0 or not rev or not created or not open or not close or not mb or not step or
                not level or level<1 or level>4 or close<open or (closed~='0' and closed~='1') then
                self.rejected=self.rejected+1 return false,'invalid state fields'
            end
            local properties,elements={},{}
            for p in args[15]:gmatch('[^,]+') do
                if not names[p:lower()] then return false,'unknown property' end
                properties[#properties+1]=p
            end
            for e in args[16]:gmatch('[^,]+') do if not E[e] then return false,'unknown element' end elements[#elements+1]=e end
            if #properties==0 or #properties>8 or #elements==0 or #elements>8 then return false,'invalid properties/elements' end
            local old=self.states[id]
            local state={id=id,revision=rev,created=created,sc_open=open,sc_close=close,mb_close=mb,
                step=step,level=level,closed=closed=='1',properties=properties,elements=elements,
                suppress_impact=args[17]=='1'}
            if old and args[17]=='0' and step>1 then
                state.previous=old state.previous.previous=nil
            end
            if step==1 and args[17]=='0' then self.bursts[id]=nil end
            self.states[id]=state
            self:opening_glyph(state)
        elseif kind=='burst' then
            local id,element=tonumber(args[6]),args[7]
            if not id then return false,'invalid burst' end
            if not E[element] then self.unknown_bursts=self.unknown_bursts+1 return true,'burst element unavailable' end
            local state=self.states[id]
            if state and state.mb_close>stamp then
                local bursts=self.bursts[id] or {}
                bursts[#bursts+1]={at=stamp,color=E[element]}
                if #bursts>4 then table.remove(bursts,1) end
                self.bursts[id]=bursts
            end
        elseif kind=='expire' then
            local id=tonumber(args[6]) if id then self.states[id]=nil self.bursts[id]=nil self.awakening_glyphs[id]=nil end
        elseif kind=='reset' then self:clear()
        elseif kind=='offline' then self:clear() self.connected=false self.synced=false
        elseif kind=='synced' then self.synced=not self.needs_sync
        elseif kind~='online' then return false,'unknown event' end
        return true,kind
    end
    function self:frame(id,now,radius,height,opts)
        local out={}
        local s=self.states[id]
        if not s then return out end
        local fade=opts.fade_duration or motion.defaults.fade_duration
        local boundary=s.closed and s.sc_open or s.sc_close
        if now>max(boundary+fade,s.mb_close) then
            local glyph=self.awakening_glyphs[id]
            if glyph then glyph.opacity=0 end
            self.states[id]=nil self.bursts[id]=nil return out
        end
        if (opts.motion or motion.defaults.motion)~='legacy' then
            if s.previous and now-s.created>=.3 then s.previous=nil end
            return motion.frame(self,s,now,radius,height,opts,{palette=palette,argb=M.argb,level=M.level})
        end
        if s.previous and now-s.created<.12 then
            local old=s.previous
            local _,sep=base_motion(old,s.created)
            local t=smooth((now-s.created)/.12)
            local previous={id=old.id,created=now,sc_open=now+1,sc_close=now+2,mb_close=0,
                step=1,level=old.level,properties=old.properties,elements=old.elements}
            -- A visual-only collapse; never stored as a combat deadline.
            local colors=palette(previous)
            for _,side in ipairs({-1,1}) do for _,c in ipairs(colors) do
                out[#out+1]={radius=radius*(1-t*.20),offset=height*(.49+side*.45*sep*(1-t)),
                    width=clamp(radius*.012,.008,.045),color=M.argb(rgb(c,t*.5),opts.opacity*(.4+.2*t))}
            end end
        else
            s.previous=nil draw_state(out,s,now,radius,height,opts)
        end
        local bursts=self.bursts[id] or {}
        for i=#bursts,1,-1 do
            local b=bursts[i] local age=now-b.at
            if age>.52 then table.remove(bursts,i)
            elseif age>=0 then
                local fade=(1-age/.52)^2*opts.opacity*opts.intensity
                out[#out+1]={radius=radius*(1+age*3),offset=height*.42,width=clamp(radius*.012,.008,.05),color=M.argb(b.color,fade*.6)}
                if age<.16 then
                    out[#out+1]={radius=radius,offset=height*.49+sin(age*110)*height*.008,
                        width=clamp(radius*.02,.01,.06),color=M.argb(rgb(b.color,.4),fade*.5)}
                end
            end
        end
        -- A pathological burst pile-up cannot increase native work indefinitely.
        while #out>24 do table.remove(out,1) end
        return out
    end
    return self
end
return M
