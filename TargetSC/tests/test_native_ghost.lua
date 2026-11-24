-- Test7.28: the ghost pass. With native 0.16.0 every piece below the MB
-- ring (not the MB ring) is sent after native.ghost(ghost); others after
-- native.ghost(0); older DLLs never get native.ghost. Simulated native sink
-- and Windower API; no DLL is loaded. Usage: lua5.1 this [0.16.0|0.15.0]
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local version=arg[1]or '0.16.0'
local now=0
os.clock=function()return now end
local events={}
local native={discs={},max_args=0,mids={},glyphs={},lines={},shifts={},rings={}}
function native.version()return version end
function native.start()return 'running'end
function native.stop()end
function native.clear()native.discs={}end
function native.begin()native.discs={}end
local ghost_now=0
local log={}
function native.ghost(k)ghost_now=k;log[#log+1]={kind='ghost',k=k}end
function native.ring(...)native.rings[#native.rings+1]=true;log[#log+1]={kind='ring',offset=select(2,...),ghost=ghost_now}end
function native.shift(e,n)native.shifts[#native.shifts+1]={e,n}end
function native.line(...)native.lines[#native.lines+1]={n=select('#',...),...}end
function native.arc(...)log[#log+1]={kind='arc',offset=select(2,...),ghost=ghost_now}end
function native.disc(...)
    local n=select('#',...)
    native.max_args=math.max(native.max_args,n)
    local a={...}
    if n>=16 then native.mids[#native.mids+1]={mid=a[15],pos=a[16],hub=a[14]}end
    native.discs[#native.discs+1]=a
    log[#log+1]={kind='disc',offset=a[2],ghost=ghost_now}
    native.sent=native.sent or {};native.sent[#native.sent+1]=a
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
local R=require('resonance')
assert(R.defaults.ghost==.3 and R.defaults.ghost_level4_lift==.003,'ghost defaults')
assert(loadfile('TargetSC/TargetSC.lua'))()
events.load()
local command=events['addon command']
command('preview','mb','light')
local below,above,calls=0,0,0
for t=0,26,.1 do now=t
    log={};ghost_now=0
    events.prerender()
    for _,e in ipairs(log)do
        if e.kind=='ghost'then calls=calls+1
        elseif e.ghost>0 then below=below+1;assert(e.ghost==.3,'ghost opacity .3')
        else above=above+1 end
    end
end
if version=='0.16.0'then
    assert(calls>0 and below>0 and above>0,'some pieces ghosted, some not: '..below..'/'..above)
else assert(calls==0 and below==0,'pre-0.16.0: never native.ghost')end
-- ghost 0 turns it off.
command('ghost','0')
local any=false
for t=0,26,.25 do now=t;log={};ghost_now=0;events.prerender()for _,e in ipairs(log)do if e.kind~='ghost'and e.ghost>0 then any=true end end end
assert(not any,'ghost 0: nothing ghosted')
print('PASS Test7.28 native ghost pass sender ('..version..', '..below..' ghosted pieces, '..above..' plain)')
