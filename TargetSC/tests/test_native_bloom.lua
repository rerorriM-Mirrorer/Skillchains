-- Test4.9: the addon sends the bloom's middle radial stop (disc args 15-16)
-- only to native 0.10.0, and 0.9.0 keeps its 14-argument calls. Simulated
-- native sink and Windower API; no DLL is loaded. Usage: lua5.1 this [0.9.0]
package.path='./TargetSC/?.lua;'..package.path
local version=arg[1]or '0.10.0'
local now=0
os.clock=function()return now end
local events={}
local native={discs={},max_args=0,mids={}}
function native.version()return version end
function native.start()return 'running'end
function native.stop()end
function native.clear()native.discs={}end
function native.begin()native.discs={}end
function native.ring()end
function native.arc()end
function native.disc(...)
    local n=select('#',...)
    native.max_args=math.max(native.max_args,n)
    local a={...}
    if n>=16 then native.mids[#native.mids+1]={mid=a[15],pos=a[16],hub=a[14]}end
    native.discs[#native.discs+1]=a
end
function native.commit()end
function native.status()return 'simulated'end
local mob={id=71,index=12,hpp=100,is_npc=true,spawn_type=16,model_size=1.5,model_scale=1,valid_target=true}
windower={addon_path='./TargetSC/',add_to_chat=function()end,send_command=function()end,debug=function()end,
    dir_exists=function()return true end,
    ffxi={get_info=function()return{logged_in=true}end,get_player=function()return{status=0}end,
        get_mob_by_target=function()return mob end,get_mob_by_index=function()return {id=71,valid_target=true}end},
    register_event=function(...)local args={...}local fn=table.remove(args)for _,name in ipairs(args)do events[name]=fn end end}
_addon={}
package.preload.chat=function()string.color=function(s)return s end return {}end
package.preload.config=function()return {load=function(d)return d end,save=function()end}end
package.preload._TargetSC=function()return native end
package.preload.sc_runtime=function()return {command=function()end}end
assert(loadfile('TargetSC/TargetSC.lua'))()
events.load()
events['addon command']('preview','mb','light')
for t=0,2,.05 do now=t events.prerender()end -- through the Fire MB at 1.2 s
if version=='0.10.0'then
    assert(#native.mids>0,'bloom middle stop reaches native 0.10.0')
    local m=native.mids[1]
    assert(math.abs(m.mid-.35)<1e-9 and math.abs(m.pos-.5)<1e-9 and m.hub>=0,'default middle .35 at half the radius, hub color')
else
    assert(native.max_args<=14 and #native.mids==0,'0.9.0 never receives args 15-16')
end
print('PASS Test4.9 native bloom args ('..version..')')
