-- Exercise the actual addon command/lifecycle handlers with a simulated native
-- sink and Windower API. This does not load a DLL or render a game frame.
package.path='./TargetSC/?.lua;'..package.path
local now=0
local realclock=os.clock os.clock=function()return now end
local events,messages,commands={}, {}, {}
local native={starts=0,stops=0,clears=0,draws=0,rings={}}
function native.version()return '0.2.0'end
function native.start()native.starts=native.starts+1 return 'running'end
function native.stop()native.stops=native.stops+1 end
function native.clear()native.clears=native.clears+1 native.rings={} native.discs={}end
function native.begin(index,id)native.index=index native.id=id native.rings={} native.discs={}end
function native.ring(r,h,w,c)native.rings[#native.rings+1]={r,h,w,c}end
function native.disc(r,h,a,c,g)native.discs=native.discs or {};native.discs[#native.discs+1]={r,h,a,c,g}end
function native.commit()native.draws=native.draws+1 end
function native.status()return 'simulated native sink'end
local mob={id=71,index=12,hpp=100,is_npc=true,spawn_type=16,model_size=1.5,model_scale=1,valid_target=true}
local player={status=0}
local identity=71
windower={addon_path='./TargetSC/',
    add_to_chat=function(_,text)messages[#messages+1]=text end,
    send_command=function(text)commands[#commands+1]=text end,
    debug=function()end,dir_exists=function()return true end,
    ffxi={get_info=function()return{logged_in=true}end,get_player=function()return player end,
        get_mob_by_target=function()return mob end,
        get_mob_by_index=function()return {id=identity,valid_target=true}end},
    register_event=function(...)
        local args={...}local fn=table.remove(args)
        for _,name in ipairs(args)do events[name]=fn end
    end}
_addon={}
package.preload.chat=function()string.color=function(s)return s end return {}end
package.preload.config=function()return {load=function(d)return d end,save=function()end}end
package.preload._TargetSC=function()return native end
assert(loadfile('TargetSC/TargetSC.lua'))()
events.load()
assert(native.starts==1 and commands[#commands]=='lua c Skillchains targetsc subscribe')
local command=events['addon command']
command('preview','demo','Liquefaction')
for _,t in ipairs({.5,2.5,3.05,5.5,9.05,14.4,15.3})do now=t events.prerender() end
assert(native.draws==7 and #native.rings==0,'preview exits with clean geometry')
command('preview','Fusion','2') now=16 events.prerender()
assert(#native.rings>0)
identity=72 now=16.1 events.prerender() assert(#native.rings==0,'recycled index hidden')
identity=71 now=16.2 events.prerender() assert(#native.rings==0,'preview canceled on tracking failure')
command('preview','Radiance','4') now=16.7 events.prerender() assert(#native.rings>0)
player.status=4 now=16.8 events.prerender() assert(#native.rings==0,'cutscene clears')
player.status=0 command('off') assert(native.stops==1)
command('on') assert(native.starts==2)
command('preset','vivid') command('motion','sine') command('layout','symmetric')
command('flutter','period','.2') command('flutter','amplitude','.3') command('flutter','damping','1')
command('width','2') command('glow','.5') command('brightness','1.5')
command('discs','off') command('discs','on') command('discs','opacity','.25')
command('motion','flutter') command('layout','grounded')
command('opacity','.4') command('scale','1.5') command('intensity','0') command('height','1.2')
command('preview','no-such-property')
command('scale','nan') command('scale','100') command('preview','Fusion','2.5')
command() assert(messages[#messages]:find('help'))
command('status')
command('_event','1','session','1','online','16.8')
command('_event','1','session','2','state','16.8','71','1','16.8','19.8','26.8','0','1','1','0','Liquefaction','Fire','1')
command('_event','1','session','3','synced','16.8')
now=17.3 events.prerender() assert(#native.rings>0)
-- Position is resolved by the native sink from the unchanged index, so Lua
-- movement never modifies event deadlines or replays a source state.
mob.x=20 now=17.4 events.prerender() assert(native.id==71)
mob.hpp=0 now=17.5 events.prerender() assert(#native.rings==0,'death clears')
mob.hpp=100 mob.id=72 identity=72 now=17.6 events.prerender() assert(#native.rings==0,'new target has no invented state')
mob=nil now=17.7 events.prerender() assert(#native.rings==0,'despawn clears')
events['zone change']() assert(#native.rings==0)
command('restart') assert(commands[#commands]=='lua reload TargetSC')
local reload_count=0 for _,c in ipairs(commands)do if c=='lua reload TargetSC'then reload_count=reload_count+1 end end
assert(reload_count==1)
events.unload() assert(native.stops>=2)
os.clock=realclock
print('PASS actual addon lifecycle/commands: preview timeline, native submissions, identity gate, cutscene, zone, off/on, settings, help, restart/unload')
