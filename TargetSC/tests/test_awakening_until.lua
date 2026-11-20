-- Test3.7: awakening fade until default|open|close|1-9; default identical
-- to the previous curve; a link fades it out over .3 s without a jump.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function smooth(v)v=math.max(0,math.min(1,v))return v*v*(3-2*v)end
local opener={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,
 properties={'Fusion','Liquefaction'},elements=R.elements('Fusion')}
local function level(m,t,o)
 local f=m:frame(71,t,2,4,o)
 for _,d in ipairs(f.discs)do if d.role=='awakening'then return math.floor(d.colors[1]/16777216)/255 end end
 return 0
end
local function model()local m=R.new();m.states[71]=copy(opener);return m end
local base=copy(R.defaults)
local peak=base.awakening_opacity*base.opacity
-- Default: exactly the previous curve (fade 1/3 -> 2/3 of the 3 s wait).
for _,t in ipairs({100.5,101,101.4,101.7,102,102.5,103.5})do
 local p=(t-100)/3;local want=peak*(1-smooth((math.min(1,p)-1/3)*3))
 near(level(model(),t,base),want,1/255+1e-9,'default at '..t)
end
assert(level(model(),102.01,base)==0,'default gone at two-thirds')
-- open: still visible just before the window, gone exactly at it.
local o=copy(base);o.awakening_until='open'
assert(level(model(),102.5,o)>0,'open: lingers toward the window') -- 75% through its fade
near(level(model(),103,o),0,1e-9,'open: gone at the window')
assert(level(model(),101.5,o)>level(model(),101.5,base),'open fades more slowly')
-- close: lasts through the window, ends at sc_close.
local c=copy(base);c.awakening_until='close'
assert(level(model(),106,c)>0 and level(model(),107.75,c)>0,'close: visible in the window')
near(level(model(),110,c),0,1e-9,'close: gone at window end')
-- N seconds after the window opens.
for _,n in ipairs({1,5,9})do
 local x=copy(base);x.awakening_until=tostring(n)
 local finish,start=math.min(103+n,110),101 -- capped at window end
 assert(level(model(),start+.75*(finish-start),x)>0,n..' s: visible 75% through')
 near(level(model(),finish,x),0,1e-9,n..' s: gone on time')
end
-- Grow phase identical in every mode.
for _,mode in ipairs({'open','close','4'})do
 local x=copy(base);x.awakening_until=mode
 for _,t in ipairs({100.1,100.5,100.9})do near(level(model(),t,x),level(model(),t,base),1/255+1e-9,mode..' grow '..t)end
end
-- A link while it lingers: continuous fade-out over .3 s.
-- (Test6.7: the link's own new disc is off here; test_awakening_links covers it.)
local m=model();local x=copy(base);x.awakening_until='close';x.awakening_links=false
level(m,104,x)
local before=level(m,104.99,x)
m.states[71]={id=71,revision=2,created=105,sc_open=108,sc_close=113,mb_close=115,step=2,level=2,
 properties={'Fusion'},elements=R.elements('Fusion')}
local at=level(m,105,x)
assert(math.abs(at-before)<=2/255,'no jump when the link lands')
assert(level(m,105.15,x)<at and level(m,105.15,x)>0,'fading during the .3 s')
near(level(m,105.3,x),0,1e-9,'gone .3 s after the link')
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
for arg,want in pairs({open='open',window='open',close='close',default='default',['4']='4',['9']='9',['1']='1'})do
 assert(cmd('awakening',{'fade','until',arg})and settings.awakening_until==want,arg)
end
for _,bad in ipairs({'0','10','2.5','soon',''})do
 settings.awakening_until='open'
 assert(cmd('awakening',{'fade','until',bad})and settings.awakening_until=='open','reject '..bad)
end
assert(cmd('awakening',{'fade','0.5','0.2'})and settings.awakening_inner==.5 and settings.awakening_outer==.2,'fade numbers still work')
assert(cmd('preset',{'killala'})and settings.awakening_until=='default')
print('PASS Test3.7 awakening fade until: default identical, open/close/1-9 end on time, grow unchanged, link fade-out continuous')
