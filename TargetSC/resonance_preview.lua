-- Explicitly local visual scenarios. Never publishes or acts on game state.
-- Preview deadlines intentionally model Skillchains' default delay and its
-- continuation/MB formulas, rather than silently mixing phases. Author: A.
local M={}
local examples={level1='Liquefaction',level2='Fusion',level3='Light',level4='Radiance'}
-- Four successful links after the opener; the final Entropy needs Anguta and
-- qualifying Aeonic Aftermath. Tests validate these against Skillchains' own
-- current skills table and check_props resolver, not a second combat parser.
M.umbra_sequence={
    {weapon=32,name='Fast Blade',property='Scission',level=1,used='Scission'},
    {weapon=19,name='Gust Slash',property='Detonation',level=1,used='Detonation'},
    {weapon=99,name='Nightmare Scythe',property='Gravitation',level=2,used='Compression'},
    {weapon=31,name="Rudra's Storm",property='Darkness',level=3,used='Distortion'},
    {weapon=109,name='Entropy (Anguta + qualifying Aeonic Aftermath)',property='Umbra',level=4,used='Darkness'},
}
function M.parse(args,resonance)
    local first=(args[1] or 'opener'):lower()
    local kind=first
    local prop,level
    if first=='burst'then
        local element=resonance.element(args[2]or 'Wind')
        if not element then return nil,'Use an element such as Wind, Fire, Ice, Water, Earth, Lightning, Light or Dark.'end
        return {kind='burst',properties={'Fragmentation'},level=2,element=element}
    end
    local second=(args[2]or ''):lower()
    if first=='mb'and second=='light'then return {kind='mblight',properties={'Fusion'},level=2}end
    if first=='mb'and (second=='dark'or second=='darkness')then return {kind='mbdark',properties={'Darkness'},level=3}end
    if first=='mb'or first=='mbdemo'or (first=='demo'and (args[2]or ''):lower()=='mb')then
        return {kind='mbdemo',properties={'Scission'},level=1}
    end
    -- Test5.2: `preview umbra` = a Darkness window about to close, closed by
    -- Umbra (its full level-4 animation). The four-link demo stays on
    -- `preview demo` / `preview full`.
    if first=='umbra'then return {kind='umbraopen',properties={'Darkness'},level=3}end
    -- 0.18: `preview kill mb [element]` / `preview kill sc`.
    if first=='kill'then
        if second=='sc'then return {kind='killsc',properties={'Scission'},level=1}end
        local element=args[3]and (args[3]:sub(1,1):upper()..args[3]:sub(2):lower())or 'Fire'
        if element=='Thunder'then element='Lightning'end
        return {kind='killmb',properties={'Fusion'},level=2,element=element}
    end
    if first=='demo' or first=='full'then
        return {kind='umbra',properties={'Scission'},level=1}
    elseif examples[first] then kind='chain';prop=examples[first]
    elseif first=='opener' or first=='pre' or first=='window' or first=='expire' or first=='chain' or first=='closed' or first=='demo' then
        prop=args[2] or ((kind=='chain' or kind=='window' or kind=='expire') and 'Fusion' or kind=='closed' and 'Radiance' or 'Liquefaction')
        level=args[3]
    else
        -- Backward-compatible property syntax now chooses a single chain
        -- scenario, with its phase times reported explicitly in chat.
        kind='chain';prop=args[1];level=args[2]
    end
    local properties={}
    for p in (prop or 'Liquefaction'):gmatch('[^,]+') do
        local name=resonance.property(p)
        if not name then return nil,'Unknown property: '..p end
        properties[#properties+1]=name
    end
    if #properties<1 or #properties>3 then return nil,'Use one to three comma-separated opener properties.' end
    if #properties>1 and kind~='opener' and kind~='pre' and kind~='demo' then return nil,'Multiple properties are for opener/pre/demo previews.' end
    level=level and tonumber(level) or resonance.level(properties[1])
    if not level or level%1~=0 or level<1 or level>4 then return nil,'Level must be 1–4.' end
    return {kind=kind,properties=properties,level=level}
end
-- Test6.6.1: how long the MB presentation still draws after its deadline
-- (converge's fade; lingering blooms, which also fade over mb ending fade). Read live, so a changed setting
-- applies to a running preview. Previews used to stop .05 s after the close.
function M.mb_tail(opts,resonance)
    local d=resonance.defaults
    local function o(k)if opts[k]~=nil then return opts[k]end return d[k]end
    local tail=.05
    if o('mb_ending_style')=='converge'then tail=math.max(tail,(o('mb_ending_fade')or 0)+.05)end
    if o('mb_ending_blooms')=='linger'and o('mb_bloom')then tail=math.max(tail,(o('mb_ending_fade')or 0)+.05)end
    return tail
end
function M.new(spec,id,now,resonance,opts)
    local self={id=id,at=now,kind=spec.kind,properties=spec.properties,level=spec.level,
        model=resonance.new(),events={},phase=nil,opts=opts or resonance.defaults}
    local function state(created,step,properties,level,closed)
        return {id=id,revision=step,created=created,sc_open=created+3,
            sc_close=created+3+8-step,mb_close=step>1 and created+10 or 0,
            step=step,level=level,properties=properties,elements=resonance.elements(properties[1]),closed=closed}
    end
    local kind=spec.kind
    local s
    if kind=='opener' or kind=='pre' or kind=='umbra' or kind=='mbdemo' then s=state(now,1,spec.properties,spec.level,false)
    else s=state(now,2,spec.properties,spec.level,kind=='closed' or spec.level==4) end
    -- Test4.9 overlap previews (user-specified). Times are relative to the
    -- preview start; `ending` = the last mb ending seconds of a window.
    local ending=(self.opts.mb_ending or resonance.defaults.mb_ending or 2)
    local function burst_at(at,element)
        self.events[#self.events+1]={at=at,kind='burst',element=element,color=resonance.element_color(element)}
    end
    local function chain_at(at,step,property,level,closed,label)
        local next_state=state(at,step,{property},level,closed)
        self.events[#self.events+1]={at=at,kind='chain',state=next_state,label=label}
        return next_state
    end
    if kind=='mblight'then
        -- A Fusion link already open and nearly closed (SC ends at 3 s); a
        -- Fire MB at 1.2 s; Light (level 3) opens just after, at 1.8 s; a
        -- Light MB once its window is open; a Wind MB just after the
        -- ending begins.
        s=state(now-5,3,{'Fusion'},2,false)
        self.stage='Fusion window open, nearly closed (local visual preview)'
        burst_at(now+1.2,'Fire')
        local light=chain_at(now+1.8,4,'Light',3,false,'Light (Level 3) opens from Fusion')
        burst_at(light.sc_open+.5,'Light')
        burst_at(light.mb_close-ending+.15,'Wind')
        self.final=light
    elseif kind=='mbdark'then
        -- Darkness (level 3) opens; Ice MB, then Darkness as that response
        -- ends; Umbra (level 4) near the window end; Ice, Earth, then
        -- Darkness exactly as the ending begins.
        s=state(now,4,{'Darkness'},3,false)
        self.stage='Darkness (Level 3) opens (local visual preview)'
        burst_at(now+1,'Ice')
        burst_at(now+1+((self.opts.mb_hold or .6)+(self.opts.mb_return or 2))*.9,'Dark')
        local umbra=chain_at(s.sc_close-.7,5,'Umbra',4,true,'Umbra (Level 4) closes the chain')
        burst_at(umbra.sc_open+1.3,'Ice')
        burst_at(umbra.sc_open+3,'Earth')
        burst_at(umbra.mb_close-ending,'Dark')
        self.final=umbra
    end
    if kind=='killmb'then
        -- Fusion open; an MB at 1.5 s defeats the target.
        s=state(now-1,2,{'Fusion'},2,false)
        self.stage='Fusion window open (local visual preview)'
        local element=resonance.element_color(spec.element)and spec.element or 'Fire'
        burst_at(now+1.5,element)
        self.events[#self.events+1]={at=now+1.5+1e-6,kind='kill',how='mb',element=element}
        self.final={mb_close=now+1.5+(self.opts.kill_time or resonance.defaults.kill_time)+.6}
    elseif kind=='killsc'then
        -- Scission opener; at 2 s a weapon skill makes Fragmentation and defeats the target.
        s=state(now,1,{'Scission'},1,false)
        self.stage='Scission opener (local visual preview)'
        chain_at(now+2,2,'Fragmentation',2,false,'Fragmentation (Level 2) defeats the target')
        self.events[#self.events+1]={at=now+2+1e-6,kind='kill',how='sc'} -- just after the chain
        self.final={mb_close=now+2+(self.opts.kill_sc_freeze or resonance.defaults.kill_sc_freeze)+
            (self.opts.kill_time or resonance.defaults.kill_time)+.3}
    end
    if kind=='umbraopen'then
        -- Darkness (level 3) opened 5 s ago; its SC window closes at 2 s.
        -- Umbra (level 4) lands at 1.2 s and plays out to its MB deadline.
        s=state(now-5,4,{'Darkness'},3,false)
        self.stage='Darkness window open, about to close (local visual preview)'
        self.final=chain_at(now+1.2,5,'Umbra',4,true,'Umbra (Level 4) closes the chain')
    end
    if self.final then table.sort(self.events,function(a,b)return a.at<b.at end)end
    if kind=='window'or kind=='burst' then
        s=state(now-3,2,spec.properties,spec.level,false)
    elseif kind=='expire' then s=state(now-8,2,spec.properties,spec.level,false) end
    self.model.states[id]=s
    self.ends=kind=='pre' and now+3 or math.max(s.sc_close+1.05,s.mb_close)
    -- Test6.6.1: the MB deadline the preview's ending tail counts from.
    self.mb_end=kind~='pre'and s.step>1 and s.mb_close or nil
    -- A real final link (mb light/dark) counts from its own deadline; kill
    -- previews (no link) keep their fixed end.
    if self.final then self.ends=self.final.mb_close+.05;self.mb_end=self.final.step and self.final.step>1 and self.final.mb_close or nil end
    if kind=='burst'then
        self.events[1]={at=now+.6,kind='burst',color=resonance.element_color(spec.element)}
    end
    if kind=='umbra'or kind=='mbdemo' then
        local prior=s
        self.stage='Fast Blade: Scission opener'
        for step=2,#M.umbra_sequence do
            local row=M.umbra_sequence[step]
            local at=prior.sc_close-1
            local next_state=state(at,step,{row.property},row.level,step==#M.umbra_sequence)
            self.events[#self.events+1]={at=at,kind='chain',state=next_state,
                label=row.name..': '..row.property..' (Level '..row.level..')'}
            prior=next_state
        end
        self.ends=prior.mb_close+.05;self.mb_end=prior.mb_close
        if kind=='mbdemo'then
            -- Same four successful links and clocks; middle hits deliberately
            -- overlap the next chain's white introduction.
            local hits={{12.6,'Wind'},{23.8,'Earth'},{29.8,'Water'},{38.8,'Dark'}}
            for _,hit in ipairs(hits)do
                self.events[#self.events+1]={at=now+hit[1],kind='burst',element=hit[2],
                    color=resonance.element_color(hit[2])}
            end
            table.sort(self.events,function(a,b)return a.at<b.at end)
        end
    end
    function self:advance(clock)
        for _,event in ipairs(self.events)do
            if not event.done and clock>=event.at then
                event.done=true
                if event.kind=='burst'then
                    local bursts=self.model.bursts[self.id]or {}
                    bursts[#bursts+1]={at=event.at,color=event.color}
                    self.model.bursts[self.id]=bursts
                    self.stage=(event.element or spec.element)..' burst (local visual preview)'
                elseif event.kind=='kill'then
                    -- The killer is you: the seam runs from you toward the target.
                    self.model.kills[self.id]={kind=event.how,element=event.element,
                        color=event.element and resonance.element_color(event.element)or nil,at=event.at,
                        angle=resonance.view_angle}
                    self.stage=(event.how=='mb'and 'MB'or 'SC')..' kill (local visual preview)'
                elseif event.kind=='chain' then
                    local next_state=event.state
                    local previous=self.model.states[self.id]
                    if previous then previous.previous=nil end
                    next_state.previous=previous;self.model.states[self.id]=next_state
                    self.stage=event.label
                end
            end
        end
        local current=self.model.states[self.id]
        self.phase=current and resonance.phase(current,clock,self.opts) or 'expired'
        return clock>=math.max(self.ends,self.mb_end and self.mb_end+M.mb_tail(self.opts,resonance)or 0)
    end
    local relative_open=s.sc_open-now
    local function at(t)return ('%.1fs'):format(t-now)end
    local function list()
        local parts={}
        for _,e in ipairs(self.events)do
            parts[#parts+1]=(e.kind=='burst'and (e.element..' MB ')or e.kind=='kill'and 'kill 'or (e.state.properties[1]..' link '))..at(e.at)
        end
        return table.concat(parts,', ')
    end
    self.description=kind=='killmb'and ('MB kill: Fusion open; '..tostring(spec.element)..' MB defeats the target at 1.5s; local visuals only.')or
        kind=='killsc'and 'SC kill: Scission opener; Fragmentation weapon skill defeats the target at 2.0s; local visuals only.'or
        kind=='umbraopen'and ('Umbra: Darkness window closing (2.0s); Umbra lands 1.2s; full Umbra animation, ends '..at(self.ends)..'; local visuals only.')or
        kind=='mblight'and ('MB Light overlap: Fusion window open (closes 3.0s); '..list()..'. Ends '..at(self.ends)..'; local visuals only.')or
        kind=='mbdark'and ('MB Dark overlap: Darkness link 0s; '..list()..'. Ends '..at(self.ends)..'; local visuals only.')or
        kind=='mbdemo'and 'MB demo: original four links; Wind 12.6s, Earth 23.8s, Water 29.8s, Dark 38.8s. Ends 40s; local visuals only.'or
        kind=='burst'and ('local '..spec.element..' MB response at 0.6s; original SC/MB clocks unchanged')or kind=='umbra' and 'Umbra demo: Fast Blade 0s; Gust Slash 9s; Nightmare Scythe 17s; Rudra\'s Storm 24s; Entropy 30s. Four links; no burst events; final MB reminder ends 40s.' or
        kind=='pre' and 'pre only: ground charge 0–3s; stops before countdown' or
        kind=='opener' and 'opener: ground charge 0–3s; sky enters/countdown 3–10s; no MB' or
        s.closed and 'closed: paired charge 0–3s, rings settle/fade in place; MB reminder until 10s; no continuation opportunity' or
        ('%s: window opens %.1fs; SC end %.1fs; MB end %.1fs%s'):format(kind,relative_open,s.sc_close-now,s.mb_close-now,
            s.closed and '; closed chain has no continuation' or '')
    return self
end
return M
