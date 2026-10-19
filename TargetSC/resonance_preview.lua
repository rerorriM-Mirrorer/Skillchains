-- Explicitly local visual scenarios. Never publishes or acts on game state.
-- Preview deadlines intentionally model Skillchains' default delay and its
-- continuation/MB formulas, rather than silently mixing phases. Author: A.
local M={}
local examples={level1='Liquefaction',level2='Fusion',level3='Light',level4='Radiance'}
function M.parse(args,resonance)
    local first=(args[1] or 'opener'):lower()
    local kind=first
    local prop,level
    if examples[first] then kind='chain';prop=examples[first]
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
function M.new(spec,id,now,resonance)
    local self={id=id,at=now,kind=spec.kind,properties=spec.properties,level=spec.level,
        model=resonance.new(),events={},phase=nil}
    local p=spec.properties[1]
    local function state(created,step,properties,level,closed)
        return {id=id,revision=step,created=created,sc_open=created+3,
            sc_close=created+3+8-step,mb_close=step>1 and created+10 or 0,
            step=step,level=level,properties=properties,elements=resonance.elements(properties[1]),closed=closed}
    end
    local kind=spec.kind
    local s
    if kind=='opener' or kind=='pre' or kind=='demo' then s=state(now,1,spec.properties,spec.level,false)
    else s=state(now,2,spec.properties,spec.level,kind=='closed' or spec.level==4) end
    if kind=='window' then
        s=state(now-3,2,spec.properties,spec.level,false)
    elseif kind=='expire' then s=state(now-8,2,spec.properties,spec.level,false) end
    self.model.states[id]=s
    self.ends=kind=='pre' and now+3 or math.max(s.sc_close+.25,s.mb_close)
    if kind=='demo' then
        -- Complete sequence uses realistic default 3s pre-windows: chain at
        -- 5s, burst at 9s, SC end 14s and MB end 15s.
        self.events={{at=now+5,kind='chain'},{at=now+9,kind='burst'}};self.ends=now+15.25
    end
    function self:advance(clock)
        for _,event in ipairs(self.events)do
            if not event.done and clock>=event.at then
                event.done=true
                if event.kind=='chain' then
                    local properties=(p=='Liquefaction') and {'Fusion'} or {p}
                    local next_state=state(event.at,2,properties,resonance.level(properties[1]),resonance.level(properties[1])==4)
                    next_state.previous=self.model.states[self.id];self.model.states[self.id]=next_state
                else
                    local pm=self.model;pm.connected=true;pm.session='preview';pm.sequence=0
                    local current=pm.states[self.id]
                    pm:receive({'1','preview','1','burst',tostring(event.at),tostring(self.id),
                        current.elements[1],'0','spells'},clock)
                end
            end
        end
        local current=self.model.states[self.id]
        self.phase=current and resonance.phase(current,clock) or 'expired'
        return clock>=self.ends
    end
    local relative_open=s.sc_open-now
    self.description=kind=='demo' and ('demo: opener charge 0–3s; chain 5s, charged until 8s; burst 9s; '..(spec.level==4 and 'closed result, no continuation; ' or 'SC end 14s; ')..'MB end 15s') or
        kind=='pre' and 'pre only: ground charge 0–3s; stops before countdown' or
        kind=='opener' and 'opener: ground charge 0–3s; sky enters/countdown 3–10s; no MB' or
        s.closed and 'closed: paired charge 0–3s; MB-only until 10s; no continuation opportunity' or
        ('%s: window opens %.1fs; SC end %.1fs; MB end %.1fs%s'):format(kind,relative_open,s.sc_close-now,s.mb_close-now,
            s.closed and '; closed chain has no continuation' or '')
    return self
end
return M
