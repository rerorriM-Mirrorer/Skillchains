-- Test7.24: the level-2 lit disc is sent with the sliced center (disc arg 18
-- = 1, arg 17 = 1e9 for no clip) only to native 0.14.0; older DLLs get the
-- plain gradient disc. Simulated native sink and Windower API; no DLL is
-- loaded. Usage: lua5.1 this [0.13.0|0.14.0]
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local version=arg[1]or '0.14.0'
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
assert(loadfile('TargetSC/TargetSC.lua'))()
events.load()
local command=events['addon command']
command('lit','level2','on')
command('preview','mb')
local sliced,plain_lit,shimmer=0,0,0
for t=0,22,.05 do now=t
    native.sent={}
    events.prerender()
    for _,a in ipairs(native.sent)do
        if #a>=23 and a[19]then
            -- Test7.25: 0.15.0 glyph shimmer (args 19-23) on the glyph lines only.
            shimmer=shimmer+1
            assert(a[5]~=0 and a[6]>0,'shimmer only on discs with glyph lines')
            assert(a[19]>=0 and a[19]<2*math.pi and a[20]>0 and a[21]==.35 and a[22]==.8 and a[23]==1,'shimmer args')
            assert(a[17]==1e9,'no clip')
        end
        if a[18]==1 then
            sliced=sliced+1
            assert(a[17]==1e9,'no clip: arg 17 = 1e9')
            assert(a[11]==1 and a[7]==4,'gradient, four sectors')
            assert(a[13]==0,'edge clear by default (lit2 fade 1 0)')
        end
    end
end
if version=='0.14.0'or version=='0.15.0'then assert(sliced>0,'level-2 lit disc sent sliced')
else assert(sliced==0,'older DLL: never arg 18')end
if version=='0.15.0'then assert(shimmer>0,'glyph shimmer sent')else assert(shimmer==0,'pre-0.15.0: no shimmer args')end
print('PASS Test7.24/7.25 native sliced center + glyph shimmer sender ('..version..', '..sliced..' sliced, '..shimmer..' shimmer disc calls)')
