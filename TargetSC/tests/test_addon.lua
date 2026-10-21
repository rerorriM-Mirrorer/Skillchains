-- Exercise the actual addon command/lifecycle handlers with a simulated native
-- sink and Windower API. This does not load a DLL or render a game frame.
package.path='./TargetSC/?.lua;'..package.path
local now=0
local realclock=os.clock os.clock=function()return now end
local events,messages,commands={}, {}, {}
local saved
local native={starts=0,stops=0,clears=0,draws=0,rings={}}
function native.version()return '0.5.0'end
function native.start()native.starts=native.starts+1 return 'running'end
function native.stop()native.stops=native.stops+1 end
function native.clear()native.clears=native.clears+1 native.rings={} native.discs={}end
function native.begin(index,id)native.index=index native.id=id native.rings={} native.discs={}end
function native.ring(r,h,w,c,px,sectors,c2,c3,c4,rotation,gap)
    assert(sectors>=1 and sectors<=4 and rotation==rotation and gap>=0 and gap<=60)
    native.rings[#native.rings+1]={r,h,w,c,px,sectors,c2,c3,c4,rotation,gap}
end
function native.disc(r,h,a,c,g,outline,sectors,c2,c3,c4)
    assert(sectors>=1 and sectors<=4 and outline>=0 and outline<=4294967295)
    native.discs=native.discs or {};native.discs[#native.discs+1]={r,h,a,c,g,outline,sectors,c2,c3,c4}
end
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
package.preload.config=function()return {load=function(d)return d end,save=function(settings)saved=settings end}end
package.preload._TargetSC=function()return native end
assert(loadfile('TargetSC/TargetSC.lua'))()
events.load()
assert(native.starts==1 and commands[#commands]=='lua c Skillchains targetsc subscribe')
local command=events['addon command']
command('preview','demo','Liquefaction')
for _,t in ipairs({.5,2.5,3.05,9.5,17.5,24.5,30.5,33.9,40.1})do now=t events.prerender() end
assert(native.draws==9 and #native.rings==0,'preview exits with clean geometry')
command('preview','Fusion','2') now=41 events.prerender()
assert(#native.rings>0)
identity=72 now=41.1 events.prerender() assert(#native.rings==0,'recycled index hidden')
identity=71 now=41.2 events.prerender() assert(#native.rings==0,'preview canceled on tracking failure')
command('preview','Radiance','4') now=41.7 events.prerender() assert(#native.rings>0)
player.status=4 now=41.8 events.prerender() assert(#native.rings==0,'cutscene clears')
player.status=0 command('off') assert(native.stops==1)
command('on') assert(native.starts==2)
command('preset','vivid') command('motion','sine') command('layout','symmetric')
command('flutter','period','.2') command('flutter','amplitude','.3') command('flutter','damping','1')
command('width','2') command('glow','.5') command('brightness','1.5')
command('discs','off') command('discs','on') command('discs','opacity','.25')
command('hum','amplitude','.02') command('hum','period','.2') command('hum','slowdown','2') command('hum','gain','.5')
command('ground','height','.05') command('fade','duration','.9')
command('discs','outline','.6') command('discs','style','outline') command('discs','height','.01')
command('discs','speed','.5') command('discs','slowdown','2')
command('awakening','off') command('awakening','on') command('awakening','opacity','.2')
assert(saved.disc_style=='outline' and saved.hum_amplitude==.02 and saved.disc_speed==.5)
command('discs','speed','nan') command('hum','amplitude','99') command('discs','style','invalid')
assert(saved.disc_speed==.5 and saved.hum_amplitude==.02 and saved.disc_style=='outline','invalid options cannot overwrite settings')
command('ground','height','.39')
command('mb','idle','.1') command('mb','burst','.7') command('mb','period','2')
command('mb','rise','.6') command('mb','expand','.2') command('sky','expand','.5')
assert(saved.mb_idle==.1 and saved.mb_burst==.7 and saved.mb_period==2 and saved.sky_expand==.5)
command('mb','idle','2') command('mb','period','nan') command('sky','expand','99')
assert(saved.mb_idle==.1 and saved.mb_period==2 and saved.sky_expand==.5)
command('preview','burst','Wind') now=now+.1 events.prerender()
assert(#native.discs>0,'new burst preview renders through actual addon handler')
command('preview','off')
command('mb','opacity','.6') assert(saved.mb_opacity==.6)
command('mb','overall','.5') command('mb','ending','style','both')
command('mb','intro','.3') command('mb','intro','flashes','1')
assert(saved.mb_intro==.3 and saved.mb_intro_flashes==1)
command('mb','intro','flashes','1.5') command('mb','intro','1')
assert(saved.mb_intro==.3 and saved.mb_intro_flashes==1)
command('discs','minimum','.5') command('sky','hold','.5')
assert(saved.mb_overall==.5 and saved.mb_ending_style=='both'and saved.disc_minimum==.5 and saved.sky_hold==.5)
command('mb','ending','style','invalid') command('mb','overall','2') command('sky','hold','nan')
assert(saved.mb_overall==.5 and saved.mb_ending_style=='both'and saved.sky_hold==.5)
command('mb','opacity','2') assert(saved.mb_opacity==.6)
command('discs','speed','level2','.7') assert(saved.disc_speed_level2==.7 and saved.disc_speed==.5)
command('discs','speed','opener','.25') assert(saved.disc_speed_opener==.25)
command('discs','speed','level2','nan') assert(saved.disc_speed_level2==.7)
command('opener','preset','combined')
assert(saved.opener_gap==12 and saved.opener_glow=='black'and saved.opener_muted)
assert(saved.ground_height==.39 and saved.disc_outline==.6,'opener preset preserves other tuning')
command('opener','preset','original')
assert(saved.opener_gap==0 and saved.opener_glow=='color'and not saved.opener_muted)
command('opener','gap','on') command('opener','glow','off') command('opener','muted','on')
assert(saved.opener_gap==12 and saved.opener_glow=='off'and saved.opener_muted)
command('opener','gap','nan') command('opener','gap','61') command('opener','glow','bad')
command('opener','muted','bad') command('opener','preset','bad')
assert(saved.opener_gap==12 and saved.opener_glow=='off'and saved.opener_muted)
command('opener','gap','off') assert(saved.opener_gap==0)
command('opener','gap','12') assert(saved.opener_gap==12)
command('opener','muted') assert(not saved.opener_muted)
for _,name in ipairs({'gap','black','muted','quiet','combined'})do command('opener','preset',name)end
command('preset','discsoff') assert(saved.discs==false and saved.awakening==true)
command('preset','discson') assert(saved.discs==true)
command('height','2') command('preset','default')
for k,v in pairs(require('resonance').defaults)do assert(saved[k]==v,'resettable snapshot default '..k)end
command('motion','flutter') command('layout','grounded')
command('opacity','.4') command('scale','1.5') command('intensity','0') command('height','1.2')
command('preview','no-such-property')
command('scale','nan') command('scale','100') command('preview','Fusion','2.5')
command() assert(messages[#messages]:find('help'))
command('status')
command('_event','1','session','1','online','41.8')
command('_event','1','session','2','state','41.8','71','1','41.8','44.8','51.8','0','1','1','0','Liquefaction','Fire','1')
command('_event','1','session','3','synced','41.8')
now=42.3 events.prerender() assert(#native.rings>0)
-- Position is resolved by the native sink from the unchanged index, so Lua
-- movement never modifies event deadlines or replays a source state.
mob.x=20 now=42.4 events.prerender() assert(native.id==71)
mob.hpp=0 now=42.5 events.prerender() assert(#native.rings==0,'death clears')
mob.hpp=100 mob.id=72 identity=72 now=42.6 events.prerender() assert(#native.rings==0,'new target has no invented state')
mob=nil now=42.7 events.prerender() assert(#native.rings==0,'despawn clears')
events['zone change']() assert(#native.rings==0)
command('restart') assert(commands[#commands]=='lua reload TargetSC')
local reload_count=0 for _,c in ipairs(commands)do if c=='lua reload TargetSC'then reload_count=reload_count+1 end end
assert(reload_count==1)
events.unload() assert(native.stops>=2)
os.clock=realclock
print('PASS actual addon lifecycle/commands: preview timeline, native submissions, identity gate, cutscene, zone, off/on, settings, help, restart/unload')
