-- Test3: HUD frame cadence + positions preset on the REAL TargetSC/sc_runtime.
-- Harness copied from test_integrated_loader.lua (stubs only Windower/HUD).
package.path='./TargetSC/?.lua;./?.lua;'..package.path
string.color=function(s)return s end
string.ucfirst=function(s)return s:sub(1,1):upper()..s:sub(2)end
local now=100
local handlers,models,commands={}, {}, {}
local renders,rescues,chat={},0,{}
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
    addon_path='./TargetSC/',debug=function()end,add_to_chat=function(_,m)chat[#chat+1]=m end,
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
        return {new=function(opts)return{
            hide=function()end,destroy=function()end,set_ctrl=function()end,
            render=function(_,state)renders[#renders+1]={at=now,state=state}end,
            rescue=function()rescues=rescues+1 end,
            set_mb_position=function(_,x,y)opts.mb.x,opts.mb.y=x,y end,
            mb_align=function(_,position)opts.mb.position=position;opts.mb.x=opts.bar.x;opts.mb.y=opts.bar.y+25 end
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
local function event(name,...)for _,callback in ipairs(handlers[name]or{})do callback(...) end end
event('load')
local target={id=71,index=12,hpp=100}
e.windower.ffxi.get_info=function()return{logged_in=true}end
e.windower.ffxi.get_player=function()return{main_job='WAR',id=1,status=0}end
e.windower.ffxi.get_mob_by_target=function()return target end
-- The world renderer finds nothing to draw; only the HUD path is measured.
e.windower.ffxi.get_mob_by_index=function()return nil end
e.windower.ffxi.get_abilities=function()return{weapon_skills={},job_abilities={}}end
e.windower.ffxi.get_items=function()return{}end
local function frames(from,to,fps)
    local before=#renders
    local stamps={}
    local t=from
    while t<to-1e-9 do now=t;event('prerender');t=t+1/fps end
    for i=before+1,#renders do stamps[#stamps+1]=renders[i].at end
    return stamps
end
local function gaps(stamps)
    local seen={}
    for i=2,#stamps do seen[math.floor((stamps[i]-stamps[i-1])*600+.5)]=true end
    local list={}for k in pairs(seen)do list[#list+1]=k end table.sort(list)return list
end
-- Opener at 200: every 60 fps frame renders during the sweep (smooth on).
now=200
e.apply_properties(71,'weapon_skills',32,{'Scission'},3,1)
local sweep=frames(200,202,60)
assert(#sweep>=119,'opening sweep renders every frame: '..#sweep)
-- Well after the animation: steady, EVEN 30 Hz cadence (every other frame).
local steady=frames(206,208,60)
local g=gaps(steady)
assert(#g==1 and g[1]==20,'even 1/30 s cadence after animation, got '..table.concat(g,','))
-- Link at 208 with 3 s delay: smooth until delay+.6 covers the transition.
now=208
e.apply_properties(71,'weapon_skills',19,{'Detonation'},3,2,false,nil,1)
local link=frames(208,211.5,60)
assert(#link>=209,'refill and window transition render every frame: '..#link)
-- Regression (Test3 live report): after a smooth period the HUD froze for
-- seconds because every-frame renders advanced the 30 Hz grid. Other
-- targets' new skillchains keep re-arming smoothing; never a gap > 1/30.
local continuous=frames(211.5,214,60)
for i=2,#continuous do
    assert(continuous[i]-continuous[i-1]<1/30+1e-6,'HUD paused at '..continuous[i-1])
end
assert(continuous[1]-211.5<1/30+1e-6,'HUD resumes immediately after smoothing ends')
assert(#continuous>=74 and 214-continuous[#continuous]<1/30+1e-6,'HUD keeps drawing: '..#continuous)
now=214
e.apply_properties(90,'weapon_skills',32,{'Scission'},3,1) -- another target
local mixed=frames(214,221,60)
for i=2,#mixed do assert(mixed[i]-mixed[i-1]<1/30+1e-6,'pause after foreign SC at '..mixed[i-1])end
assert(#mixed>=210 and 221-mixed[#mixed]<1/30+1e-6,'HUD keeps drawing after foreign SC: '..#mixed)
-- smooth off: back to 30 Hz even during the sweep.
event('addon command','sc','smooth','off')
now=221
target={id=72,index=13,hpp=100}
e.apply_properties(72,'weapon_skills',32,{'Scission'},3,1)
local throttled=frames(221,223,60)
assert(#throttled<=62 and #throttled>=58,'smooth off keeps 30 Hz: '..#throttled)
event('addon command','sc','smooth','on')
-- Position presets for SC bar, MB ribbon and learning panel.
local opts=assert(e.settings and e.settings.Resonance,'HUD settings reachable')
event('addon command','sc','positions','cioara')
assert(opts.bar.x==1490 and opts.bar.y==60 and opts.list.x==1050 and opts.list.y==2100)
assert(opts.mb.position=='custom' and opts.mb.x==1489 and opts.mb.y==54 and opts.mb.width==445)
event('addon command','sc','positions','default')
assert(opts.bar.x==466 and opts.bar.y==696 and opts.mb.position=='below' and opts.mb.width==310)
local count=#chat
event('addon command','sc','positions','nowhere')
assert(#chat>count and opts.bar.x==466,'unknown preset reports usage, changes nothing')
assert(rescues>=2,'presets are clamped onto the current screen')
print('PASS Test3 HUD cadence: every-frame opening sweep/transition, even 30 Hz otherwise, smooth off, positions presets')
