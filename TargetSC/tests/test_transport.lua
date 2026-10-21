-- Actual Skillchains and TargetSC command handlers in isolated Lua states,
-- with Windower's documented command-vs-invoke distinction. No DLL/game.
package.path='./TargetSC/?.lua;./?.lua;'..package.path
string.color=function(s)return s end
string.ucfirst=function(s)return s:sub(1,1):upper()..s:sub(2)end
local function run(source_first)
    local now,loaded,queue,traffic=100,{},{},{}
    local consumers={}
    local function dispatch(text)
        traffic[#traffic+1]=text
        assert(not text:find(';',1,true),'one command per transport call')
        local mode,name,tail=text:match('^lua (%S+) (%S+)%s*(.*)$')
        assert(mode=='c','Transport must deliver addon command, not invoke a Lua function: '..text)
        local args={}for word in tail:gmatch('%S+')do args[#args+1]=word end
        queue[#queue+1]={name=name:lower(),args=args}
    end
    local function drain()
        local count=0
        while #queue>0 do
            count=count+1;assert(count<100,'handshake must not loop')
            local item=table.remove(queue,1)
            local env=loaded[item.name]
            if env then env.events['addon command'](unpack(item.args))end
        end
    end
    local function copy(t)
        if type(t)~='table'then return t end
        local r={}for k,v in pairs(t)do r[k]=copy(v)end return r
    end
    local function environment(name)
        local e=setmetatable({_addon={},events={},res={spells={[144]={element=0}},jobs={}}},{__index=_G})
        e.os=setmetatable({clock=function()return now end},{__index=os})
        e.package={cpath=package.cpath}
        e.S=function(values)
            local r={contains=function(self,v)return self[v]~=nil end}
            for _,v in ipairs(values)do r[v]=true end return r
        end
        e.L=function(t)return setmetatable(t,{__add=function(a,b)
            local r=copy(a)for _,v in ipairs(b)do r[#r+1]=v end return e.L(r)
        end})end
        e.config={load=function(d)return copy(d)end,save=function()end}
        e.windower={addon_path='./TargetSC/',send_command=dispatch,add_to_chat=function()end,debug=function()end,
            register_event=function(...)
                local a={...};local fn=table.remove(a)for _,event in ipairs(a)do e.events[event]=fn end
            end,
            ffxi={get_info=function()return{logged_in=false}end}}
        e.ActionPacket={open_listener=function()end}
        e.require=function(module)
            if module=='config'then return e.config end
            if module=='resonance_ui'then return {new=function()return{hide=function()end,destroy=function()end}end}end
            if module=='skillchains_demo'then return require('skillchains_demo')end
            if module=='targetsc_bridge'then return setfenv(assert(loadfile('targetsc_bridge.lua')),e)()end
            if module=='skills'then return require('skills')end
            if module=='resonance'then
                local r=require('resonance');local wrapped={}
                for k,v in pairs(r)do wrapped[k]=v end
                wrapped.new=function()local m=r.new();consumers[#consumers+1]=m;return m end
                return wrapped
            end
            if module=='resonance_preview'or module=='resonance_controls'then return require(module)end
            if module=='_TargetSC'then return {version=function()return '0.4.0'end,start=function()return'running'end,
                stop=function()end,clear=function()end,begin=function()end,ring=function()end,
                disc=function()end,commit=function()end,status=function()return'simulated'end}end
            return {}
        end
        setfenv(assert(loadfile(name=='skillchains' and 'Skillchains.lua' or 'TargetSC/TargetSC.lua')),e)()
        loaded[name]=e;e.events.load();drain();return e
    end
    local sc,tsc
    if source_first then sc=environment('skillchains');tsc=environment('targetsc')
    else tsc=environment('targetsc');sc=environment('skillchains')end
    local model=consumers[#consumers]
    assert(model.connected and model.synced,'both real handlers must complete the handshake')
    local preview=require('resonance_preview')
    local sequence=preview.umbra_sequence
    local skills=require('skills').weapon_skills
    assert(skills[sequence[1].weapon].skillchain[1]==sequence[1].property)
    sc.info.player=1;sc.info.aeonic='Anguta'
    for step=2,#sequence do
        local row=sequence[step]
        local props=sc.aeonic_prop(skills[row.weapon],1)
        local level,result,ultimate=sc.check_props({sequence[step-1].property},props)
        assert(level==row.level and (ultimate or result)==row.property,
            'demo combination disagrees with actual Skillchains resolver at '..row.name)
    end
    sc.apply_properties(71,'weapon_skills',32,{'Scission'},3,1);drain()
    local first=model.states[71]
    assert(first and first.sc_open==103 and first.sc_close==110 and first.mb_close==0)
    now=104
    sc.apply_properties(71,'weapon_skills',19,{'Detonation'},3,2,false,nil,1);drain()
    local state=model.states[71]
    assert(state.step==2 and state.sc_open==107 and state.sc_close==113 and state.mb_close==114)
    now=105;tsc.events['addon command']('sync');drain()
    assert(model.synced and model.states[71].created==104 and model.states[71].sc_close==113,
        'snapshot must retain exact source age/deadlines')
    local no_demo_messages=#traffic
    sc.events['addon command']('demo');drain()
    assert(#traffic==no_demo_messages,'HUD-only demo must never publish a TargetSC event')
    sc.events['addon command']('demo','off');drain()
    local count=#traffic;now=106
    tsc.events['addon command']('status');drain();assert(#traffic==count,'status must not poll')
    sc.events.unload();drain();assert(not model.connected and not next(model.states))
    sc=environment('skillchains');assert(model.connected and model.synced,'source reload must announce to real receiver')
    tsc.events['addon command']('off');drain()
    count=#traffic
    sc.apply_properties(72,'weapon_skills',32,{'Scission'},3,1);drain()
    assert(#traffic==count,'unsubscribe actually reaches publisher')
    tsc.events['addon command']('on');drain();assert(model.states[72] and model.synced)
    sc.events['zone change']();drain();assert(not next(model.states),'zone reset delivered')
    tsc.events.unload();drain()
end
run(true);run(false)
print('PASS real-addon command transport: both load orders, subscription, source states, snapshot, reload, off/on, unsubscribe, zone, no polling')
