-- TargetSC's optional, process-local state publisher. Author: A.
-- No packet listener, native module, files, or cross-client IPC here.
local M = {}
local burst_messages = {
    [252]=true,[265]=true,[268]=true,[269]=true,[271]=true,[272]=true,
    [274]=true,[275]=true,[379]=true,[650]=true,[747]=true,[748]=true,
    [749]=true,[750]=true,[751]=true,[752]=true,[753]=true,[754]=true,
    [755]=true,[803]=true,[804]=true,
}
local element_names = {[0]='Fire','Ice','Wind','Earth','Lightning','Water','Light','Dark'}

function M.new(definitions, resources, send, clock)
    clock = clock or os.clock
    local self = {subscribed=false, sequence=0, revision=0, revisions={}, failures=0,
        session=('%d-%.6f'):format(os.time(),clock())}
    local function emit(kind, ...)
        if not self.subscribed then return end
        self.sequence = self.sequence + 1
        local parts = {'1',self.session,tostring(self.sequence),kind,('%.6f'):format(clock())}
        for _,value in ipairs({...}) do parts[#parts+1]=tostring(value) end
        -- All fields are addon-generated numeric/enumerated tokens. Never
        -- forward user text or evaluate a received message as Lua.
        local ok = pcall(send, 'lua i TargetSC _event '..table.concat(parts,' '))
        if not ok then self.failures=self.failures+1 end
    end
    function self:state(id, state, snapshot)
        local properties, elements, seen, level = {}, {}, {}, 1
        for _,name in ipairs(state.active or {}) do
            local def=definitions[name]
            if def then
                properties[#properties+1]=name
                level=math.max(level,def.lvl)
                for _,element in ipairs(def) do
                    if not seen[element] then elements[#elements+1]=element seen[element]=true end
                end
            end
        end
        if #properties==0 then return end
        level=state.result_level or level
        if not snapshot then
            self.revision=self.revision+1
            self.revisions[id]={revision=self.revision,created=clock()}
        end
        local rev=self.revisions[id] or {revision=0,created=clock()}
        emit('state',id,rev.revision,('%.6f'):format(rev.created),
            ('%.6f'):format(state.delay),('%.6f'):format(state.times),
            ('%.6f'):format(state.mb_window or 0),state.step,level,
            state.closed and 1 or 0,table.concat(properties,','),table.concat(elements,','),
            snapshot and 1 or 0)
    end
    function self:subscribe(states)
        self.subscribed=true
        emit('online')
        for id,state in pairs(states) do
            if math.max(state.times,state.mb_window or 0)>clock() then self:state(id,state,true) end
        end
        emit('synced')
    end
    function self:expire(id)
        self.revisions[id]=nil
        emit('expire',id)
    end
    function self:reset(reason)
        self.revisions={}
        emit('reset',reason)
    end
    function self:stop() emit('offline') self.subscribed=false end
    function self:announce()
        -- One lifecycle notification. A loaded TargetSC requests a snapshot;
        -- an absent companion never changes Skillchains combat/UI behavior.
        pcall(send,'lua i TargetSC _ready')
    end
    function self:bursts(act)
        if not self.subscribed then return end
        -- Extend Skillchains' existing action observer solely to publish
        -- confirmed MB messages (including secondary AoE targets). No timer
        -- mutation and no inference from ordinary spell damage.
        local spell = act.category==4 and resources.spells[act.param]
        local element = spell and element_names[spell.element]
        local resource = act.category==4 and 'spells' or 'unknown'
        for _,target in ipairs(act.targets or {}) do
            for _,action in ipairs(target.actions or {}) do
                if burst_messages[action.message] then
                    emit('burst',target.id,element or 'Unknown',act.param or 0,resource)
                    break -- one ripple per target per action packet
                end
            end
        end
    end
    return self
end
return M
