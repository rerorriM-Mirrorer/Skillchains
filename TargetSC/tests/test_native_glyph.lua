-- Test5.7: the addon sends Umbra's 3D ending glyph (native.glyph, 13 args)
-- only to native 0.11.0; 0.10.0 never gets it. Simulated native sink and
-- Windower API; no DLL is loaded. Usage: lua5.1 this [0.10.0]
package.path='./TargetSC/?.lua;'..package.path
local version=arg[1]or '0.11.0'
local now=0
os.clock=function()return now end
local events={}
local native={discs={},max_args=0,mids={},glyphs={}}
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
function native.glyph(...)native.glyphs[#native.glyphs+1]={n=select('#',...),...}end
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
events['addon command']('umbra','ending','swallow')
events['addon command']('preview','umbra')
for t=0,11.3,.05 do now=t events.prerender()end
if version=='0.11.0'then
    assert(#native.glyphs>0,'3D glyph reaches native 0.11.0')
    local g=native.glyphs[1]
    assert(g.n==13 and g[12]==1 and g[13]==0,'13 args, clipped, no circle (swallow)')
else
    assert(#native.glyphs==0,'0.10.0 never receives native.glyph')
end
print('PASS Test5.7 native glyph args ('..version..')')
