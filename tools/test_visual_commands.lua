-- Simulate real Skillchains addon-command registration in Lua 5.1.
-- FFXI rendering, TargetSC native DLL and game packets are NOT exercised.
string.ucfirst=function(s)return s:sub(1,1):upper()..s:sub(2)end
local function harness()
    local clock,events,renders=100,{},{},{}
    local sent={}
    local raw_deadlines={}
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
    local saves=0
    env.config={load=function(d)return copy(d)end,
        save=function() saves=saves+1 end,reload=function()end}
    local player={main_job='WAR',id=1,status=0}
    local target={id=71,index=12,hpp=100}
    local messages={}
    env.windower={register_event=function(name,fn)events[name]=fn end,
        send_command=function(line)sent[#sent+1]=line end,add_to_chat=function(_,msg)messages[#messages+1]=msg end,
        ffxi={get_info=function()return {logged_in=true}end,
            get_player=function()return player end,get_mob_by_target=function()return target end,
            get_abilities=function()return {weapon_skills={},job_abilities={}}end,
            get_items=function()return {}end}}
    env.require=function(name)
        if name=='resonance_ui' then return {new=function()return {
            render=function(_,frame)renders[#renders+1]=copy(frame or {hidden=true})end,
            hide=function()end,destroy=function()end}end} end
        if name=='targetsc_bridge' then return assert(setfenv(assert(loadfile('targetsc_bridge.lua')),env))() end
        if name=='skillchains_demo' then return assert(loadfile('skillchains_demo.lua'))() end
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
    setfenv(assert(loadfile('Skillchains.lua')),env)()
    return events['addon command'],env,messages,function()return saves end,
        function(now)clock=now end,events,renders,sent
end

local command,env,messages,saves,set_clock,events,renders,sent=harness()
local opt=env.settings.Resonance
local function run(cmd,...)
    command(cmd,...)
    return messages[#messages] or ''
end
assert(opt.glow.levels==nil and opt.glow.level_mask==nil,
    'No numeric-looking mask in Windower typed defaults')
assert(opt.glow.rail34==.75 and opt.glow.cap34==.85)
assert(opt.transition.duration==.30 and opt.transition.style=='energized')
assert(run('glow','levels','1234'):find('default 234',1,true))
assert(opt.glow.level_mask=='L1,L2,L3,L4' and not tonumber(opt.glow.level_mask))
run('glow','levels','42')
assert(opt.glow.level_mask=='L2,L4','Canonicalize and sort level mask')
run('glow','levels','off') assert(opt.glow.level_mask=='off')
run('glow','levels','34')
local before=saves()
assert(run('glow','rail12','3.125'):find('default 0.300',1,true))
assert(opt.glow.rail12==3.125 and saves()==before+1)
assert(run('glow','cap34','100'):find('default 0.850',1,true))
assert(opt.glow.cap34==100,'Unbounded positive cap multiplier')
run('glow','rail34','0.6')
run('glow','preset','balanced')
assert(opt.glow.cap34==opt.glow.rail34 and
    opt.glow.cap12==opt.glow.rail12)
run('glow','preset','capforward')
assert(math.abs(opt.glow.cap34-opt.glow.rail34*(.85/.75))<1e-9 and
    math.abs(opt.glow.cap12-opt.glow.rail12*(.35/.30))<1e-9)
run('glow','pre3','.5')
run('glow','pre4','.9')
run('glow','pre12','0')
assert(opt.glow.pre3==.5 and opt.glow.pre4==.9 and opt.glow.pre12==0)
run('glow','level1','0.4')
run('glow','level2','1.8')
run('glow','level3','3')
run('glow','level4','0')
run('glow','scale','8.7')
assert(opt.glow.level1==.4 and opt.glow.level2==1.8 and
    opt.glow.level3==3 and opt.glow.level4==0 and
    opt.glow.scale==8.7)
local saved=opt.glow.scale
run('glow','scale','-1') assert(opt.glow.scale==saved)
run('glow','scale','1e999') assert(opt.glow.scale==saved)
run('glow','scale','nan') assert(opt.glow.scale==saved)
assert(run('track','alpha','95'):find('default 155',1,true))
assert(opt.track.alpha==95)
run('track','rgb','3','5','9')
assert(opt.track.color[1]==3 and opt.track.color[2]==5
    and opt.track.color[3]==9)
run('track','rgb','-1','5','9') assert(opt.track.color[1]==3)
run('track','alpha','400') assert(opt.track.alpha==95)
run('track','reset')
assert(opt.track.alpha==155 and opt.track.color[1]==6)
run('glow','reset')
assert(opt.glow.level_mask=='L2,L3,L4')
assert(opt.glow.rail34==.75 and opt.glow.cap34==.85 and
    opt.glow.pre4==.85)
assert(opt.track.alpha==155 and opt.bar.x==466,
    'Glow-only reset must not change track/positions')
opt.glow.levels=34
opt.glow.level_mask=nil
run('glow')
assert(messages[#messages-1]:find('Glow levels 34',1,true))
run('glow','levels','12')
assert(opt.glow.level_mask=='L1,L2')
opt.glow.levels='off'
run('glow')
assert(messages[#messages-1]:find('Glow levels L1,L2',1,true))
local mask=opt.glow.level_mask
run('glow','levels','135') assert(opt.glow.level_mask==mask)
run('glow','l4','gold') assert(opt.glow.l4=='gold')
run('glow','l4','white') assert(opt.glow.l4=='white')
run('glow','l4','whitegold') assert(opt.glow.l4=='whitegold')
assert(run('transition','.3'):find('default .300s',1,true))
run('transition','0') assert(opt.transition.duration==0)
run('transition','3.7') assert(opt.transition.duration==3.7)
run('transition','-1') assert(opt.transition.duration==3.7)
run('transition','style','uniform') assert(opt.transition.style=='uniform')
run('transition','style','energized') assert(opt.transition.style=='energized')
assert(run('anim','glow','9.5'):find('default 2.00',1,true))
assert(opt.animation.glow==9.5)
assert(math.abs(opt.animation.fade_period-1/2.4)<1e-8)
assert(run('anim','fade','period','.24'):find('0.240s',1,true))
assert(opt.animation.fade_period==.24)
run('anim','fade','period','0')
assert(opt.animation.fade_period==.24,'Invalid period must leave setting unchanged')
run('anim','fade','on')
assert(opt.animation.fade==true and opt.animation.fade_period==.24)
run('anim','fade','off')
assert(not opt.animation.fade)
run('glow','pre2','.95')
assert(opt.glow.pre2==.95)
run('anim','preview','umbra')
assert(run('anim','preview','radiance'):find('radiance',1,true))
assert(run('anim','preview','lux'):find('lux',1,true))
run('anim','preview','off')
run('anim','intensity','4') assert(opt.animation.intensity==4)
run('anim','flare','4') assert(opt.animation.flare==4)
assert(run('glow'):find('//sc glow levels',1,true))
assert(run('transition'):find('Transition',1,true))
assert(saves()>10,'Settings changes should save')
print('PASS visual commands: cap presets, prewindow electricity, per-level glow, track RGB/alpha, selective resets and validation')


-- A standalone demo must use the same main HUD renderer and never inject
-- transport messages, change tracked combat states, or touch saved settings.
local saved_before=saves()
local sent_before=#sent
run('demo')
assert(#sent==sent_before and saves()==saved_before)
events.prerender()
assert(renders[#renders].step==1 and renders[#renders].active[1]=='Scission')
set_clock(109);events.prerender()
assert(renders[#renders].step==2 and renders[#renders].active[1]=='Detonation')
set_clock(117);events.prerender()
assert(renders[#renders].step==3 and renders[#renders].active[1]=='Gravitation')
set_clock(124);events.prerender()
assert(renders[#renders].step==4 and renders[#renders].active[1]=='Darkness')
set_clock(130);events.prerender()
assert(renders[#renders].step==5 and renders[#renders].active[1]=='Umbra'
    and not renders[#renders].closed,'Terminal Level 4 charge is visible')
set_clock(133);events.prerender()
assert(renders[#renders].closed and renders[#renders].mb_left==7)
assert(run('demo','status'):find('Umbra HUD demo:',1,true))
assert(#sent==sent_before and saves()==saved_before,
    'The demo must not alter TargetSC transport or settings')
run('demo','off')
assert(run('demo','status'):find('idle',1,true))
set_clock(134);events.prerender()
assert(renders[#renders].hidden,'Normal empty HUD restored after demo off')
set_clock(200);run('demo');events.prerender()
set_clock(240.1);events.prerender()
assert(renders[#renders].hidden,'Demo expires after independent MB tail')
assert(#sent==sent_before,'No fake TargetSC actions from any demo frame')
print('PASS Skillchains demo integration: actual handler, HUD frames, stop, auto-end, no transport/settings')
