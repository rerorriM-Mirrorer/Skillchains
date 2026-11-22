-- Test7.18.1: awakening_until values never saved as numbers. Simulated Windower config.
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
function native.ring(r,h,w,c,px,sectors,c2,c3,c4,rotation,gap,blend,fade)
    assert(sectors>=1 and sectors<=4 and rotation==rotation and gap>=0 and gap<=60)
    assert(fade==nil,'0.5.0 native receives no arc fade arguments')
    assert(blend==0,'0.5.0 native receives no ring gradient flag')
    native.rings[#native.rings+1]={r,h,w,c,px,sectors,c2,c3,c4,rotation,gap}
end
function native.disc(r,h,a,c,g,outline,sectors,c2,c3,c4,blend,inner,outer)
    assert(sectors>=1 and sectors<=4 and outline>=0 and outline<=4294967295)
    -- Test3.5: a 0.5.0 DLL never receives the 0.7.0 radial arguments.
    assert(inner==nil and outer==nil,'0.5.0 native receives no radial fill arguments')
    -- Test3: this mock reports DLL 0.5.0, so Lua must send its four-step
    -- gradient fallback (blend 0) rather than the 0.6.0 gradient flag.
    assert(blend==0,'0.5.0 native receives no gradient flag')
    if sectors==4 then native.fallbacks=(native.fallbacks or 0)+1 end
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
local registered,saves=nil,0
package.preload.config=function()return {
    -- A's 04:22 log: cioara held awakening_until_level1/2/3 = 1, 4, 9 (numbers).
    load=function(d)local s={}for k,v in pairs(d)do s[k]=v end
        s.awakening_until_level1,s.awakening_until_level2,s.awakening_until_level3,s.awakening_until=1,'4',9,'close' return s end,
    save=function(settings)saved=settings;saves=saves+1 end,
    register=function(s,fn)registered={s,fn}end}end
package.preload._TargetSC=function()return native end
package.preload.sc_runtime=function()return {command=function(cmd) _G.__test_sc_command=cmd end}end
assert(loadfile('TargetSC/TargetSC.lua'))()
assert(saved and saves==1,'normalized once and saved')
assert(saved.awakening_until_level1=='1s'and saved.awakening_until_level2=='4s'and saved.awakening_until_level3=='9s','numbers become text')
assert(saved.awakening_until=='close','words untouched')
assert(registered and registered[1]==saved,'re-run on every settings reload (login/character)')
-- A later reload (character change) bringing numbers back is fixed again.
saved.awakening_until_opener=3;registered[2](saved)
assert(saved.awakening_until_opener=='3s'and saves==2,'reload normalized')
registered[2](saved);assert(saves==2,'no save when nothing changed')
local M=require('resonance_motion')
assert(M.until_seconds('4s')==4 and M.until_seconds(4)==4 and M.until_seconds('4')==4 and M.until_seconds('close')==nil,'reader')
-- The fade end is the same for 4, '4' and '4s'.
local function lvl(v)return M.awakening_level(0,3,10,5,{awakening_until_level2=v,awakening_until='default'},'level2')end
assert(lvl('4s')==lvl(4)and lvl(4)==lvl('4')and lvl('4s')~=lvl('same'),'same fade for every form')
print('PASS Test7.18.1 awakening fade-until saved as text (no Windower type warnings), old numeric values converted on load and reload')
