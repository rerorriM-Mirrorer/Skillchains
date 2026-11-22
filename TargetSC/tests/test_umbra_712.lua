-- Test7.12: Umbra MB pulse floor/strength, under disc slowing after the
-- flash-out, black disc white flash, and the cioara preset.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local M=require('resonance_motion')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function link(level,property,created)
    return {id=83,revision=level,created=created,sc_open=created+3,sc_close=created+8,mb_close=created+10,
        step=level==1 and 2 or level,level=level,properties={property},elements=R.elements(property)}
end
local function frame(now,o)
    local m=R.new();local s=link(4,'Umbra',100);s.previous=link(3,'Darkness',90);m.states[83]=s
    return m:frame(83,now,2,4,o),s
end
local function mb_alpha(f)for _,x in ipairs(f)do if x.part=='mb'and x.role=='core'then return math.floor(x.color/16777216)end end return 0 end
local function role(f,r)for _,d in ipairs(f.discs or {})do if d.role==r then return d end end end
local a=dofile('TargetSC/tests/fixture_cioara_1122.lua')
for k,v in pairs(R.defaults)do if a[k]==nil then a[k]=v end end
a.mb_intro=0
for _,k in ipairs({'umbra_mb_floor','umbra_under_slow','umbra_slow_time','umbra_slow_to','umbra_disc_flash','umbra_flash_fade'})do assert(R.defaults[k]~=nil,k)end
assert(R.defaults.umbra_mb_floor==0 and R.defaults.umbra_under_slow==false and R.defaults.umbra_disc_flash==false)
-- Pulse range: with no flicker, floor lifts the minimum, strength raises the peak.
local base=copy(a);base.umbra_mb_flicker=0
local function range(o)local lo,hi=1e9,-1e9 for i=0,200 do local v=mb_alpha(frame(100.5+i*.02,o))lo,hi=math.min(lo,v),math.max(hi,v)end return lo,hi end
local lo0,hi0=range(base)
local fl=copy(base);fl.umbra_mb_floor=.4
local lo1,hi1=range(fl)
assert(lo0<=2 and lo1>=math.floor(.4*a.mb_overall*255)-3,'floor .4 keeps the ring visible ('..lo0..' -> '..lo1..')')
local st=copy(base);st.umbra_mb_strength=1.5
local _,hi2=range(st)
assert(hi2>hi0,'strength 1.5 brighter peak ('..hi0..' -> '..hi2..')')
-- Under slow: off = unchanged; on: same angle before the flash-out, slower after, continuous.
local _,s=frame(100,a)
-- The frame's view shifts sc_open by `umbra open time` (A: 2 s).
local view=setmetatable({sc_open=s.created+a.umbra_open_time},{__index=s})
local f=M.umbra_flashed(view,a,false)
local sl=copy(a);sl.umbra_under_slow=true
local function under(o,t)local d=role(frame(t,o),'umbra-under')return d and d.rotation end
near(under(sl,f-.2),under(a,f-.2),1e-6,'same before the flash-out')
local r0,r1,r2=under(sl,f),under(sl,f+1),under(sl,f+1.01)
local d0,d1=under(a,f+1),under(a,f+1.01)
assert(math.abs(r2-r1)<math.abs(d1-d0),'slower after the flash-out')
near(under(sl,f+.001),r0,.01,'continuous at the flash-out')
local stop1,stop2=under(sl,f+sl.umbra_slow_time+.5),under(sl,f+sl.umbra_slow_time+1)
near(stop1,stop2,1e-6,'slow to 0 stops after the slow time')
local half=copy(sl);half.umbra_slow_to=.5
local h1,h2=under(half,f+5),under(half,f+5.1)
local lvl4=(a.umbra_spin>=0)and a.umbra_spin or a.disc_speed_level4 -- umbra spin overrides the L4 speed
local w=2*math.pi*a.disc_speed*lvl4*a.umbra_under_spin*(a.umbra_under_direction=='reverse'and -1 or 1)
near(h2-h1,w*.5*.1,1e-6,'slow to .5 keeps half speed')
-- Disc flash: black before, white through the last ring flash, back to black.
local df=copy(a);df.umbra_disc_flash=true
local function black(o,t)local d=role(frame(t,o),'property')return d and d.colors and d.colors[1]%16777216 end
assert(black(df,f-.5)==black(a,f-.5),'unchanged before the flash')
assert(black(df,f-.01)==0xFFFFFF,'white during the last ring flash')
assert(black(df,f+df.umbra_flash_fade+.05)==black(a,f+df.umbra_flash_fade+.05),'back to the normal disc after the fade')
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala,R.cioara)
assert(cmd('umbra',{'mb','floor','.4'})and settings.umbra_mb_floor==.4)
assert(cmd('umbra',{'mb','strength','2'})and settings.umbra_mb_strength==2)
assert(cmd('umbra',{'under','slow','on'})and settings.umbra_under_slow==true)
assert(cmd('umbra',{'slow','time','3'})and settings.umbra_slow_time==3)
assert(cmd('umbra',{'slow','to','.2'})and settings.umbra_slow_to==.2)
assert(cmd('umbra',{'disc','flash','on'})and settings.umbra_disc_flash==true)
assert(cmd('umbra',{'flash','fade','.5'})and settings.umbra_flash_fade==.5)
-- Preset cioara: every value of A's 11-22 profile; default still resets.
assert(cmd('preset',{'cioara'}))
for k,v in pairs(R.cioara)do assert(settings[k]==v,'cioara '..k)end
assert(settings.umbra_wobble_peak==9 and settings.ring_level4_gap==.09 and settings.radiance_mb_flicker==.3)
assert(cmd('preset',{'default'})and settings.umbra_wobble_peak==R.defaults.umbra_wobble_peak)
print('PASS Test7.12 Umbra MB floor/strength, under slow (ease-out, continuous, stop/half), black disc flash, commands, preset cioara')
-- Preview path (E4b).
local P=require('resonance_preview')
local po=copy(a);po.umbra_disc_flash=true;po.umbra_under_slow=true
local pv=P.new(assert(P.parse({'demo'},R)),84,200,R,po)
local at;for _,e in ipairs(pv.events)do if e.kind=='chain'and e.state.level==4 then at=e.at end end
pv:advance(at)
local ps=pv.model.states[84]
local pf=M.umbra_flashed(setmetatable({sc_open=ps.created+po.umbra_open_time},{__index=ps}),po,false)
local white=false
for _,d in ipairs(pv.model:frame(84,pf-.01,2,4,po).discs or {})do if d.role=='property'and d.colors and d.colors[1]%16777216==0xFFFFFF then white=true end end
assert(white,'demo black disc flashes white')
print('PASS Test7.12 preview path: demo Umbra disc flash')
