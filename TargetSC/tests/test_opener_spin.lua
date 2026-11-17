-- Test4.1: opener spin slowdown/minimum. Old values (3, 0) reproduce the
-- previous angle exactly; new defaults keep turning; no angle jumps.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local M=require('resonance_motion')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local s={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,properties={'Fusion'}}
local o=copy(R.defaults)
local turn=2*math.pi*o.disc_speed_opener*o.disc_speed
-- Previous formula, written out independently.
local function old(now)
 local charge=now<s.sc_open and math.max(0,now-s.created)or s.sc_open-s.created
 local elapsed=math.max(0,now-s.sc_open);local d=s.sc_close-s.sc_open
 local t=math.min(1,elapsed/d)
 return turn*(charge+(now<s.sc_open and 0 or d*(1-(1-t)^4)/4))
end
local legacy=copy(o);legacy.opener_spin_slowdown=3;legacy.opener_spin_minimum=0
for _,t in ipairs({100,101.5,103,104,106.5,109,110,110.5})do near(M.rotation(s,t,legacy),old(t),1e-9,'legacy '..t)end
-- Speed via finite differences.
local function speed(t,opts)return (M.rotation(s,t+1e-4,opts)-M.rotation(s,t,opts))/1e-4/(2*math.pi*o.disc_speed)end
-- Defaults: full speed during the wait, linear ease to .5 at window close.
near(speed(101,o),o.disc_speed_opener,1e-3,'full in the wait')
near(speed(106.5,o),.5+(4-.5)*.5,1e-2,'halfway: minimum + half the rest')
near(speed(109.999,o),.5,1e-2,'reaches minimum at close')
assert(speed(108,o)>speed(108,legacy)*5,'much faster than before late in the window')
-- Slowdown 0: never slows.
local steady=copy(o);steady.opener_spin_slowdown=0
for _,t in ipairs({101,104,107,109.5})do near(speed(t,steady),4,1e-3,'steady '..t)end
-- Minimum never exceeds the opener's own speed.
local capped=copy(o);capped.opener_spin_minimum=4;capped.disc_speed_opener=2
near(speed(109.9,capped),2,1e-3,'minimum capped at stage speed')
-- Continuous: no jump at the window opening or close.
for _,t in ipairs({103,110})do
 near(M.rotation(s,t-1e-7,o),M.rotation(s,t+1e-7,o),1e-5,'continuous at '..t)
end
-- Links are unaffected.
local link={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=2,properties={'Fusion'}}
local a,b=copy(o),copy(o);b.opener_spin_slowdown=0;b.opener_spin_minimum=3
for _,t in ipairs({101,104,107})do near(M.rotation(link,t,a),M.rotation(link,t,b),1e-12,'link '..t)end
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('opener',{'spin','slowdown','0'})and settings.opener_spin_slowdown==0)
assert(cmd('opener',{'spin','minimum','1.5'})and settings.opener_spin_minimum==1.5)
assert(cmd('opener',{'spin','minimum','9'})and settings.opener_spin_minimum==1.5)
assert(cmd('opener',{'spin','fast'})and settings.opener_spin_slowdown==0)
assert(cmd('preset',{'killala'})and settings.opener_spin_slowdown==3 and settings.opener_spin_minimum==0)
assert(cmd('preset',{'default'})and settings.opener_spin_slowdown==1 and settings.opener_spin_minimum==.5)
print('PASS Test4.1 opener spin: legacy identical, ease to minimum, slowdown 0 steady, capped, continuous, links unchanged')
