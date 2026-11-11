-- Load the real combined TargetSC entry point and embedded Skillchains
-- runtime in one simulated Lua environment. Only native, Windower APIs and
-- HUD drawing are stubbed. No game/native execution is claimed.
package.path='./TargetSC/?.lua;./?.lua;'..package.path
string.color=function(s)return s end
string.ucfirst=function(s)return s:sub(1,1):upper()..s:sub(2)end
local now=100
local handlers,models,commands={}, {}, {}
local function copy(t)
    if type(t)~='table'then return t end
    local r={}for k,v in pairs(t)do r[k]=copy(v)end return r
end
local e=setmetatable({_addon={},res={spells={[144]={element=0}},jobs={}}},{__index=_G})
e.os=setmetatable({clock=function()return now end},{__index=os})
e.package={cpath=package.cpath}
e.S=function(values)
    local r={contains=function(self,v)return self[v]~=nil end}
    for _,v in ipairs(values)do r[v]=true end return r
end
e.L=function(t)return setmetatable(t,{__add=function(a,b)
    local r=copy(a)for _,v in ipairs(b)do r[#r+1]=v end return e.L(r)
end})end
e.config={
    load=function(path,default)
        if type(path)=='string'then
            assert(path=='data/skillchains-settings.xml','HUD requires independent settings')
            return copy(default)
        end
        return copy(path)
    end,
    save=function()end,
    reload=function()end
}
e.windower={
    addon_path='./TargetSC/',debug=function()end,add_to_chat=function()end,
    send_command=function(c)commands[#commands+1]=c end,
    register_event=function(...)
        local a={...};local fn=table.remove(a)
        for _,event in ipairs(a)do
            handlers[event]=handlers[event]or{}
            table.insert(handlers[event],fn)
        end
    end,
    ffxi={
        get_info=function()return{logged_in=false}end,
        get_player=function()return nil end,
        get_mob_by_target=function()return nil end
    }
}
e.ActionPacket={open_listener=function(fn)e.action_handler=fn end}
-- Windower-style iterators across all targets and subactions.
e.ActionPacket.new=function(act)
    local packet={}
    function packet:get_category_string()return act.category end
    function packet:get_id()return act.actor_id end
    function packet:get_targets()
        local i=0
        return function()
            i=i+1
            local raw=act.targets and act.targets[i]
            if not raw then return nil end
            return {id=raw.id,get_actions=function()
                local j=0
                return function()
                    j=j+1
                    local action=raw.actions and raw.actions[j]
                    if not action then return nil end
                    return {
                        get_message_id=function()return action.message end,
                        get_spell=function()return action.param or 1,action.resource,
                            action.id or act.param,false,action.conclusion or false end,
                        get_add_effect=function()return action.add_effect or false end
                    }
                end
            end}
        end
    end
    return packet
end
local module_cache={}
e.require=function(mod)
    if mod=='config'then return e.config end
    if mod=='resonance_ui'then
        return {new=function()return{
            hide=function()end,destroy=function()end,set_ctrl=function()end
        }end}
    end
    if mod=='targetsc_local' or mod=='targetsc_bridge' or mod=='sc_runtime' then
        if not module_cache[mod] then
            module_cache[mod]=setfenv(assert(loadfile('TargetSC/'..mod..'.lua')),e)()
        end
        return module_cache[mod]
    end
    if mod=='resonance' then
        local base=require('resonance')
        local wrap={}for k,v in pairs(base)do wrap[k]=v end
        wrap.new=function()
            local m=base.new()
            models[#models+1]=m
            return m
        end
        return wrap
    end
    if mod=='_TargetSC'then return{
        version=function()return '0.5.0'end,start=function()return'running'end,
        stop=function()end,clear=function()end,begin=function()end,
        ring=function()end,disc=function()end,commit=function()end,
        status=function()return'simulated native'end
    }end
    if mod=='resonance_preview'or mod=='resonance_controls'or mod=='skills'
        or mod=='skillchains_demo'then return require(mod)end
    return {}
end

setfenv(assert(loadfile('TargetSC/TargetSC.lua')),e)()
assert(e._addon.name=='TargetSC'and e._addon.version=='0.12.1-unified-test2')
assert(type(e.action_handler)=='function','real action packet listener installed')
assert(#(handlers.load or{})==2,'both systems register load inside one addon')
assert(#(handlers['addon command']or{})==1,'only one command dispatcher')

local function event(name,...)
    for _,callback in ipairs(handlers[name]or{})do callback(...) end
end
event('load')
local model=assert(models[1])
assert(model.connected and model.synced,'embedded source must synchronize on load')
assert(#commands==0,'no inter-addon commands during initialization')
assert(type(e.apply_properties)=='function')
e.apply_properties(71,'weapon_skills',32,{'Scission'},3,1)
assert(model.states[71]and model.states[71].sc_close==110)
now=104
e.apply_properties(71,'weapon_skills',19,{'Detonation'},3,2,false,nil,1)
assert(model.states[71].sc_close==113 and model.states[71].mb_close==114)
local created=model.states[71].created
-- Uriel Blade (Trust/NPC AoE) must set each successful enemy's
-- resonance, not only the first entity reported in the action packet.
now=106
local function hit(id,message,resource,ability,more)
    local t={id=id,actions={{message=message,resource=resource,id=ability}}}
    if more then for _,act in ipairs(more)do t.actions[#t.actions+1]=act end end
    return t
end
e.action_handler({category='mob_tp_finish',actor_id=988,param=2273,
    targets={hit(81,188,'monster_abilities',2273),
        hit(82,317,'monster_abilities',2273),
        hit(83,110,'monster_abilities',2273)}})
assert(not model.states[81],'miss never starts a window')
assert(model.states[82] and model.states[83],'AoE must register secondary targets')
assert(model.states[82].sc_close==116 and model.states[83].sc_close==116)
-- Myrr's WS should register in Cioara's client from an external actor.
now=107
e.action_handler({category='weaponskill_finish',actor_id=721,param=160,
    targets={hit(84,185,'weapon_skills',160)}})
assert(model.states[84]and model.states[84].sc_close==117,
    'external actor Shining Strike must open Impaction window')
now=108
e.action_handler({category='weaponskill_finish',actor_id=721,param=160,
    targets={hit(85,188,'weapon_skills',160)}})
assert(not model.states[85],'missed Shining Strike cannot open a window')
-- If multiple subactions exist, confirmed SC outranks ordinary opener.
now=109
e.action_handler({category='mob_tp_finish',actor_id=988,param=2273,
    targets={hit(82,317,'monster_abilities',2273,{
       {message=317,resource='monster_abilities',id=2273,
        conclusion=true,add_effect={message_id=291,animation='fusion'}}
    })}})
assert(model.states[82].step==2 and model.states[82].level==2,
    'confirmed skillchain overrides opener in same packet')
assert(model.states[82].mb_close==119,'MB window based on chain time')
event('addon command','sync')
assert(model.synced and model.states[71].created==created,'snapshot keeps timestamps')
event('addon command','sc','status')
assert(#commands==0,'HUD status and synchronization use no external addon')
event('addon command','off')
assert(not next(model.states),'off clears world while leaving source running')
e.apply_properties(72,'weapon_skills',32,{'Scission'},3,1)
assert(not model.states[72],'off unsubscribes world, not combat listener')
event('addon command','on')
assert(model.synced and model.states[72],'on restores source snapshot')
assert(model.states[82] and model.states[83] and model.states[84],'AoE and party states survive resubscription')
event('zone change')
assert(not next(model.states),'zone clears both consumer and source')
event('unload')
assert(#commands==0,'lifecycle never addresses standalone Skillchains')
print('PASS real merged entry + SC runtime: one event listener, source clocks, HUD command, on/off, zone, no IPC')
