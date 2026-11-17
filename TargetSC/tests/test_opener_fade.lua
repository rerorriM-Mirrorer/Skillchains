-- Test3.8: opener arc fade (lead/trail, length, curve, glow follow);
-- only gapped opener ground/sky rings; killala and fade 0 send nothing new.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local opener={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,
 properties={'Fusion','Liquefaction'},elements=R.elements('Fusion')}
local link={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=2,
 properties={'Fusion'},elements=R.elements('Fusion')}
local function frame(s,t,o)local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local o=copy(R.defaults)
local f=frame(opener,104,o)
local cores,glows=0,0
for _,r in ipairs(f)do
 if r.part=='ground'or r.part=='sky'then
  assert(r.gap>0)
  near(r.fade,o.opener_fade*(r.role=='glow'and o.opener_fade_glow or 1),1e-9,'fade '..r.role)
  near(r.fade_length,1);near(r.fade_curve,1);assert(r.fade_direction==1,'lead = +1')
  if r.role=='core'then cores=cores+1 else glows=glows+1 end
 end
end
assert(cores>0 and glows>0,'cores and glows faded')
-- Options flow through.
local x=copy(o);x.opener_fade=.9;x.opener_fade_length=.4;x.opener_fade_curve=2;x.opener_fade_end='trail';x.opener_fade_glow=.5
for _,r in ipairs(frame(opener,104,x))do
 if r.part=='ground'or r.part=='sky'then
  near(r.fade,r.role=='glow'and .45 or .9);near(r.fade_length,.4);near(r.fade_curve,2);assert(r.fade_direction==-1)
 end
end
-- Glow follow 0: glow stays even (no fade field at all).
local g0=copy(o);g0.opener_fade_glow=0
for _,r in ipairs(frame(opener,104,g0))do if r.role=='glow'then assert(r.fade==nil,'glow even')end end
-- Fade 0, no gap, killala, and non-opener rings send nothing new.
local z=copy(o);z.opener_fade=0
for _,r in ipairs(frame(opener,104,z))do assert(r.fade==nil,'fade 0 sends nothing')end
local nogap=copy(o);nogap.opener_gap=0
for _,r in ipairs(frame(opener,104,nogap))do assert(r.fade==nil,'closed opener rings untouched')end
local k=copy(o);for key,v in pairs(R.killala)do k[key]=v end
for _,r in ipairs(frame(opener,104,k))do assert(r.fade==nil,'killala untouched')end
for _,r in ipairs(frame(link,104,o))do assert(r.fade==nil,'links untouched')end
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('opener',{'fade','0.8'})and settings.opener_fade==.8)
assert(cmd('opener',{'fade','1.5'})and settings.opener_fade==.8,'range')
assert(cmd('opener',{'fade','length','0.4'})and settings.opener_fade_length==.4)
assert(cmd('opener',{'fade','length','0'})and settings.opener_fade_length==.4)
assert(cmd('opener',{'fade','curve','2'})and settings.opener_fade_curve==2)
assert(cmd('opener',{'fade','curve','4'})and settings.opener_fade_curve==2)
assert(cmd('opener',{'fade','trail'})and settings.opener_fade_end=='trail')
assert(cmd('opener',{'fade','lead'})and settings.opener_fade_end=='lead')
assert(cmd('opener',{'fade','glow','0.3'})and settings.opener_fade_glow==.3)
assert(cmd('opener',{'fade','sideways'})and settings.opener_fade==.8,'unknown word')
assert(cmd('opener',{'discs','size','1.2'})and settings.opener_disc_size==1.2,'opener discs still works')
assert(cmd('opener',{'gap','40'})and settings.opener_gap==40,'opener gap still works')
assert(cmd('preset',{'killala'})and settings.opener_fade==0)
assert(cmd('preset',{'default'})and settings.opener_fade==.6 and settings.opener_fade_end=='lead')
print('PASS Test3.8 opener arc fade: cores+glows, lead/trail, length, curve, glow follow, untouched elsewhere, commands')
