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
    if first=='mb'or first=='mbdemo'or (first=='demo'and (args[2]or ''):lower()=='mb')then
        return {kind='mbdemo',properties={'Scission'},level=1}
    end
    if first=='demo' or first=='umbra' or first=='full'then
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
    if kind=='window'or kind=='burst' then
        s=state(now-3,2,spec.properties,spec.level,false)
    elseif kind=='expire' then s=state(now-8,2,spec.properties,spec.level,false) end
    self.model.states[id]=s
    self.ends=kind=='pre' and now+3 or math.max(s.sc_close+1.05,s.mb_close)
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
        self.ends=prior.mb_close+.05
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
        return clock>=self.ends
    end
    local relative_open=s.sc_open-now
    self.description=kind=='mbdemo'and 'MB demo: original four links; Wind 12.6s, Earth 23.8s, Water 29.8s, Dark 38.8s. Ends 40s; local visuals only.'or
        kind=='burst'and ('local '..spec.element..' MB response at 0.6s; original SC/MB clocks unchanged')or kind=='umbra' and 'Umbra demo: Fast Blade 0s; Gust Slash 9s; Nightmare Scythe 17s; Rudra\'s Storm 24s; Entropy 30s. Four links; no burst events; final MB reminder ends 40s.' or
        kind=='pre' and 'pre only: ground charge 0–3s; stops before countdown' or
        kind=='opener' and 'opener: ground charge 0–3s; sky enters/countdown 3–10s; no MB' or
        s.closed and 'closed: paired charge 0–3s, rings settle/fade in place; MB reminder until 10s; no continuation opportunity' or
        ('%s: window opens %.1fs; SC end %.1fs; MB end %.1fs%s'):format(kind,relative_open,s.sc_close-now,s.mb_close-now,
            s.closed and '; closed chain has no continuation' or '')
    return self
end
return M
