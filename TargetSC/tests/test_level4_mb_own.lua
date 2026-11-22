-- Test7.11: own MB flicker depths for Radiance/Umbra (Umbra on top of its
-- pulse) and the Umbra wobble after the flash-out.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local M=require('resonance_motion')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function link(level,property,created)
    return {id=81,revision=level,created=created,sc_open=created+3,sc_close=created+8,mb_close=created+10,
        step=level==1 and 2 or level,level=level,properties={property},elements=R.elements(property)}
end
local function frame(now,o,p,prior)
    local m=R.new();local s=link(4,p,100);s.previous=link(3,prior,90);m.states[81]=s
    return m:frame(81,now,2,4,o),s
end
local function mb_alpha(f)for _,x in ipairs(f)do if x.part=='mb'and x.role=='core'then return math.floor(x.color/16777216)end end end
local function swing(o,p,prior,t0)
    local lo,hi=1e9,-1e9
    for i=0,40 do local v=mb_alpha(frame(t0+i*.005,o,p,prior))if v then lo,hi=math.min(lo,v),math.max(hi,v)end end
    return lo,hi
end
local a=dofile('TargetSC/tests/fixture_cioara_1121.lua')
for k,v in pairs(R.defaults)do if a[k]==nil then a[k]=v end end
a.mb_intro=0
assert(R.defaults.radiance_mb_flicker==-1 and R.defaults.umbra_mb_flicker==-1 and R.defaults.umbra_wobble_after==false)
-- Umbra (pulse, A's profile): no flicker before; with umbra mb flicker 1 it flickers on top.
local off=copy(a);off.umbra_mb_flicker=0
local on=copy(a);on.umbra_mb_flicker=1
local lo0,hi0=swing(off,'Umbra','Darkness',101.2)
local lo1,hi1=swing(on,'Umbra','Darkness',101.2)
assert(hi1>0 and lo1<hi1*.6,'Umbra flickers on top of the pulse ('..lo1..'..'..hi1..')')
local diff=0
for i=0,40 do local t=101.2+i*.005;local x,y=mb_alpha(frame(t,off,'Umbra','Darkness')),mb_alpha(frame(t,on,'Umbra','Darkness'))
    if x and y and x>8 then assert(y<=x+1,'flicker only dims the pulse');if y<x*.8 then diff=diff+1 end end end
assert(diff>3,'flicker visible on top of the pulse ('..diff..')')
-- Radiance own depth .3 is shallower than 1; same = mb level4 depth.
local r3=copy(a);r3.radiance_mb_flicker=.3
local r1=copy(a);r1.radiance_mb_flicker=1
local l3,h3=swing(r3,'Radiance','Light',101)
local l1,h1=swing(r1,'Radiance','Light',101)
assert((h3-l3)/h3<(h1-l1)/h1,'radiance mb flicker .3 shallower than 1')
local same=copy(a);same.radiance_mb_flicker=-1;same.mb_level4_depth=.3
for _,t in ipairs({101,101.03,101.07})do assert(mb_alpha(frame(t,same,'Radiance','Light'))==mb_alpha(frame(t,r3,'Radiance','Light')),'same = mb level4 depth')end
-- Each setting only touches its own level 4.
local u9=copy(a);u9.umbra_mb_flicker=.9
for _,t in ipairs({101,101.05})do assert(mb_alpha(frame(t,u9,'Radiance','Light'))==mb_alpha(frame(t,a,'Radiance','Light')),'umbra setting leaves Radiance')end
-- mb level4 breath turns both off.
local br=copy(on);br.mb_level4='breath'
local lb,hb=swing(br,'Umbra','Darkness',101.2)
near=function(x,y,e,m)assert(math.abs(x-y)<e,m)end
for i=0,10 do local t=101.2+i*.01;assert(mb_alpha(frame(t,br,'Umbra','Darkness'))==mb_alpha(frame(t,off,'Umbra','Darkness')),'breath: Umbra back to the pulse only')end
-- Wobble after: off = unchanged; on = 0 before the flash-out, grows to the deadline.
local w=copy(a);w.umbra_wobble_after=true
local _,s=frame(100,w,'Umbra','Darkness')
local start=M.umbra_flashed(s,w,false)
assert(M.umbra_wobble(s,start-.1,w)==0,'nothing before the flash-out')
assert(M.umbra_wobble(s,start+1,a)==0,'off by default')
local function peak(t0,t1)local m=0 for t=t0,t1,.004 do m=math.max(m,math.abs(M.umbra_wobble(s,t,w)))end return m end
local early,late=peak(start,start+.6),peak(s.mb_close-.6,s.mb_close)
assert(late>early*3 and late>0,'grows toward the deadline ('..early..' -> '..late..')')
local base=w.hum_amplitude*(1+3*w.hum_gain)*w.intensity
assert(late<=base*w.umbra_wobble_peak+1e-9 and late>base*w.umbra_wobble_peak*.6,'peak x hum amplitude')
-- It moves the black disc plane in the frame.
local function disc_h(f)for _,d in ipairs(f.discs or {})do if d.role=='umbra-black'or d.role=='property'then return d.offset end end end
local hs={}
for i=0,20 do local f=frame(s.mb_close-.5+i*.01,w,'Umbra','Darkness');hs[#hs+1]=disc_h(f)end
local lo,hi=1e9,-1e9 for _,h in ipairs(hs)do if h then lo,hi=math.min(lo,h),math.max(hi,h)end end
assert(hi-lo>base*w.umbra_wobble_peak*.5,'Umbra disc wobbles near the deadline ('..(hi-lo)..')')
-- Radiance unaffected.
local fr1,fr2=frame(108,w,'Radiance','Light'),frame(108,a,'Radiance','Light')
for i=1,#fr1 do assert(fr1[i].offset==fr2[i].offset,'Radiance unchanged')end
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('radiance',{'mb','flicker','.3'})and settings.radiance_mb_flicker==.3)
assert(cmd('radiance',{'mb','flicker','same'})and settings.radiance_mb_flicker==-1)
assert(cmd('umbra',{'mb','flicker','1'})and settings.umbra_mb_flicker==1)
assert(cmd('umbra',{'wobble','after','on'})and settings.umbra_wobble_after==true)
assert(cmd('umbra',{'wobble','peak','8'})and settings.umbra_wobble_peak==8)
assert(cmd('umbra',{'wobble','speed','3'})and settings.umbra_wobble_speed==3)
assert(cmd('umbra',{'wobble','curve','1'})and settings.umbra_wobble_curve==1)
print('PASS Test7.11: own Radiance/Umbra MB flicker (Umbra on top of the pulse, same = mb level4 depth, breath off); Umbra wobble after the flash-out (off by default, grows to the deadline, moves the disc, Radiance untouched); commands')
-- Preview path (E4b): `preview demo` Umbra link wobbles after its flash-out.
local P=require('resonance_preview')
local po=copy(a);po.umbra_wobble_after=true
local pv=P.new(assert(P.parse({'demo'},R)),82,200,R,po)
local at;for _,e in ipairs(pv.events)do if e.kind=='chain'and e.state.level==4 then at=e.at end end
pv:advance(at)
local st=pv.model.states[82]
local fl=M.umbra_flashed(st,po,false)
assert(M.umbra_wobble(st,fl-.05,po)==0 and math.abs(M.umbra_wobble(st,st.mb_close-.3,po))>=0,'demo wobble timing')
local m2=0 for t=st.mb_close-.6,st.mb_close,.004 do m2=math.max(m2,math.abs(M.umbra_wobble(st,t,po)))end
assert(m2>0,'demo Umbra wobbles near the deadline')
print('PASS Test7.11 preview path: demo Umbra wobble after the flash-out')
