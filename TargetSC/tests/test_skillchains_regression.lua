-- Compare the actual modified Skillchains.lua to the pinned personal baseline.
-- Usage: lua5.1 TargetSC/tests/test_skillchains_regression.lua /tmp/sc-baseline.lua
assert(arg[1],'Pass Skillchains.lua from commit e095657 as the first argument')
string.ucfirst=function(s)return s:sub(1,1):upper()..s:sub(2)end
local function harness(path)
    local clock,events,renders=100,{},{}
    local env=setmetatable({_addon={},res={spells={[144]={element=0}},jobs={}}},{__index=_G})
    env.os=setmetatable({clock=function() return clock end},{__index=os})
    local function set(values)
        local result={contains=function(self,v)return self[v]~=nil end}
        for _,v in ipairs(values) do result[v]=true end
        return result
    end
    env.S=set
    env.L=function(values)return setmetatable(values,{__add=function(a,b)
        local result={} for _,v in ipairs(a)do result[#result+1]=v end for _,v in ipairs(b)do result[#result+1]=v end
        return env.L(result)
    end})end
    local function copy(t)
        if type(t)~='table' then return t end
        local result={} for k,v in pairs(t)do result[k]=copy(v)end return result
    end
    env.config={load=function(d)return copy(d)end,save=function()end,reload=function()end}
    local player={main_job='WAR',id=1,status=0}
    local target={id=71,index=12,hpp=100}
    env.windower={register_event=function(name,fn)events[name]=fn end,
        send_command=function()end,add_to_chat=function()end,
        ffxi={get_info=function()return {logged_in=true}end,
            get_player=function()return player end,get_mob_by_target=function()return target end,
            get_abilities=function()return {weapon_skills={},job_abilities={}}end,
            get_items=function()return {}end}}
    env.require=function(name)
        if name=='resonance_ui' then return {new=function()return {
            render=function(_,frame)renders[#renders+1]=copy(frame or {hidden=true})end,
            hide=function()end,destroy=function()end}end} end
        if name=='targetsc_bridge' then return assert(setfenv(assert(loadfile('targetsc_bridge.lua')),env))() end
        if name=='skills' then return assert(loadfile('skills.lua'))() end
        return {}
    end
    env.ActionPacket={open_listener=function()end,new=function(act)
        local a={get_message_id=function()return act.message end,get_add_effect=function()return act.effect end,
            get_spell=function()return 0,act.resource,act.spell,false,act.conclusion end}
        local t={id=act.target or 71,get_actions=function()return function()return a end end}
        return {get_category_string=function()return act.kind end,get_id=function()return 1 end,
            get_targets=function()return function()return t end end}
    end}
    setfenv(assert(loadfile(path)),env)()
    if path=='Skillchains.lua' then events['addon command']('targetsc','subscribe') end
    local function advance(t)clock=t events.prerender()end
    local function action(t,params)clock=t params.param=params.param or 1 env.action_handler(params)end
    action(100,{kind='weaponskill_finish',resource='weapon_skills',spell=6,message=185})
    advance(100.1) advance(102) advance(104)
    action(104,{kind='weaponskill_finish',resource='weapon_skills',spell=1,message=185,
        conclusion=true,effect={animation='fusion',message_id=288}})
    advance(104.1) advance(107.5)
    local deadlines=copy(env.resonating[71])
    -- Real action_handler path: a confirmed Fire burst on the tracked target.
    action(108,{kind='spell_finish',category=4,param=144,resource='spells',spell=144,message=252,
        targets={{id=71,actions={{message=252}}}}})
    assert(env.resonating[71].times==deadlines.times and env.resonating[71].mb_window==deadlines.mb_window)
    advance(113.5) advance(114.1) advance(116)
    env.apply_properties(71,'weapon_skills',1,{'Light'},3,6,true)
    advance(117) advance(120) advance(124) advance(127)
    events['zone change']() advance(128)
    events.logout() advance(129)
    return renders
end
local before,after=harness(arg[1]),harness('Skillchains.lua')
local function equal(a,b,path)
    assert(type(a)==type(b),path..' type changed')
    if type(a)~='table' then assert(a==b,path..' value changed: '..tostring(a)..' vs '..tostring(b)) return end
    for k,v in pairs(a)do equal(v,b[k],path..'.'..tostring(k))end
    for k in pairs(b)do assert(a[k]~=nil,path..' added '..tostring(k))end
end
equal(before,after,'bar snapshots')
print('PASS actual Skillchains baseline comparison: opener, chain timers, confirmed MB, MB-only tail, closed chain, expiry, zone/logout; '..#after..' identical bar snapshots')
