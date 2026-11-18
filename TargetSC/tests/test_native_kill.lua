-- 0.18: the SC kill sends native.shift (halves) and native.line (seams) only
-- to native 0.12.0; a reported kill turns a death into the kill animation
-- instead of the plain detarget fade. Simulated native sink and Windower API;
-- no DLL is loaded. Usage: lua5.1 this [0.11.0]
package.path='./TargetSC/?.lua;'..package.path
local version=arg[1]or '0.12.0'
local now=0
os.clock=function()return now end
local events={}
local native={discs={},max_args=0,mids={},glyphs={},lines={},shifts={},rings={}}
function native.version()return version end
function native.start()return 'running'end
function native.stop()end
function native.clear()native.discs={}end
function native.begin()native.discs={}end
function native.ring()native.rings[#native.rings+1]=true end
function native.shift(e,n)native.shifts[#native.shifts+1]={e,n}end
function native.line(...)native.lines[#native.lines+1]={n=select('#',...),...}end
function native.arc()end
function native.disc(...)
    local n=select('#',...)
    native.max_args=math.max(native.max_args,n)
    local a={...}
    if n>=16 then native.mids[#native.mids+1]={mid=a[15],pos=a[16],hub=a[14]}end
    native.discs[#native.discs+1]=a
end
function native.glyph(...)native.glyphs[#native.glyphs+1]={n=select('#',...),...}end
function native.commit()end
function native.status()return 'simulated'end
local mob={id=71,index=12,hpp=100,is_npc=true,spawn_type=16,model_size=1.5,model_scale=1,valid_target=true}
windower={addon_path='./TargetSC/',add_to_chat=function()end,send_command=function()end,debug=function()end,
    dir_exists=function()return true end,
    ffxi={get_info=function()return{logged_in=true}end,get_player=function()return{status=0}end,
        get_mob_by_target=function()return mob end,get_mob_by_index=function()return {id=71,valid_target=true}end,
        get_mob_by_id=function(id)if id==500 then return {id=500,x=0,y=-5}end if id==71 then return {id=71,x=0,y=0}end end},
    register_event=function(...)local args={...}local fn=table.remove(args)for _,name in ipairs(args)do events[name]=fn end end}
_addon={}
package.preload.chat=function()string.color=function(s)return s end return {}end
package.preload.config=function()return {load=function(d)return d end,save=function()end}end
package.preload._TargetSC=function()return native end
package.preload.sc_runtime=function()return {command=function()end}end
assert(loadfile('TargetSC/TargetSC.lua'))()
events.load()
local command=events['addon command']
command('preview','kill','sc')
for t=0,2.5,.05 do now=t events.prerender()end
if version=='0.12.0'then
    assert(#native.lines>0 and native.lines[1].n==8,'seam lines (8 args)')
    local moved=false for _,v in ipairs(native.shifts)do if v[1]~=0 or v[2]~=0 then moved=true end end
    assert(moved,'halves shifted sideways')
else
    assert(#native.lines==0 and #native.shifts==0,'older DLL never gets shift/line')
end
-- A real kill: the death plays the kill (full strength) instead of dimming.
command('preview','off');now=10;events.prerender()
command('_event','1','session','1','online','20')
command('_event','1','session','2','state','20','71','1','20','23','30','0','2','2','0','Fusion','Fire,Light','0')
command('_event','1','session','3','synced','20')
now=21 events.prerender()
assert(#native.rings>0,'live state drawn')
command('_event','1','session','4','kill','21.5','71','mb','Ice','500')
now=21.55 events.prerender()
mob.hpp=0 now=21.6 events.prerender()
native.rings={}now=21.9 events.prerender()
assert(#native.rings>0,'kill animation drawing on the dead enemy')
now=24 native.rings={} events.prerender()
assert(#native.rings==0,'gone after the kill time')
print('PASS 0.18 native kill ('..version..')')
