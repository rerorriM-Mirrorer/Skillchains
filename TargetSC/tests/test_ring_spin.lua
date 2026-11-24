-- Test3.2: rings turn with the property disc (stage speed easing to the
-- disc minimum), soft lit side, optional faster glow, MB ring settles onto
-- the large glyph during the closing pulses; killala restores all.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance')
local M=require('resonance_motion')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function find(f,part,role)for _,v in ipairs(f)do if v.part==part and v.role==role then return v end end end
local function layer(f,role)for _,v in ipairs(f.discs)do if v.role==role then return v end end end
local function alpha(c)return math.floor(c/16777216)end
local o=copy(R.defaults);o.mb_intro=0;o.mb_ending_style='off'
local function state(level,props)
 return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,
  step=level>1 and 2 or 2,level=level,properties=props,elements=R.elements(props[1])}
end
local function frame(s,t,opts)local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,opts or o)end
-- Every level's rings share the disc's angle; it keeps turning at the deadline.
for level,props in pairs({[1]={'Scission'},[2]={'Fusion'},[3]={'Light'}})do
 local s=state(level,props)
 local o2=copy(o);o2['disc_speed_level'..level]=2
 for _,t in ipairs({103.5,105,107.9})do
  local f=frame(s,t,o2)
  local disc=layer(f,'property')
  for _,part in ipairs({'ground','sky'})do
   local core=find(f,part,'core')
   if core then near(core.rotation,disc.rotation,1e-9,'L'..level..' '..part..' in step at '..t)end
  end
 end
 local a,b=M.disc_rotation(s,107.8,o2),M.disc_rotation(s,107.9,o2)
 assert(b>a,'L'..level..' still turning near the deadline (eases to minimum, not zero)')
end
-- Classic restores the old rings: L1 still, L2 on stage rotation.
local classic=copy(o);classic.ring_spin='classic'
near(find(frame(state(1,{'Scission'}),105,classic),'ground','core').rotation,0)
near(find(frame(state(2,{'Fusion'}),105,classic),'ground','core').rotation,M.rotation(state(2,{'Fusion'}),105,classic))
-- Lit side: single color -> bright/dim pair; two colors -> A+ mid B- mid.
local f1=frame(state(1,{'Scission'}),105)
local c1=find(f1,'ground','core')
assert(#c1.colors==2 and c1.blend==1 and c1.colors[1]%16777216==c1.colors[2]%16777216)
assert(alpha(c1.colors[1])>alpha(c1.colors[2]),'one side brighter')
local f2=frame(state(2,{'Fusion'}),105)
local c2=find(f2,'sky','core')
assert(#c2.colors==4 and c2.blend==1 and alpha(c2.colors[1])>alpha(c2.colors[3]),'L2 keeps order with lit side')
local even=copy(o);even.ring_shade=0
assert(#find(frame(state(1,{'Scission'}),105,even),'ground','core').colors==1,'shade 0 = even ring')
-- Openers untouched: split, no shading, original rotation.
local opener={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,
 properties={'Fusion','Liquefaction'},elements=R.elements('Fusion')}
for _,r in ipairs(frame(opener,104))do
 if r.part=='ground'or r.part=='sky'then
  assert(r.blend==0 and #r.colors<=2,'opener unchanged')
  near(r.rotation,M.rotation(opener,104,o),1e-9,'opener rotation unchanged')
 end
end
-- Glow spins at the multiplier.
local fast=copy(o);fast.ring_glow_spin=2
local ff=frame(state(2,{'Fusion'}),105,fast)
near(find(ff,'ground','glow').rotation,2*find(ff,'ground','core').rotation,1e-9,'glow twice as fast')
-- MB ring settles onto the large glyph plane across the ending interval.
local e=copy(R.defaults);e.mb_intro=0
local s=state(2,{'Fusion'})
local start=find(frame(s,110-e.mb_ending-.01,e),'mb','core').offset
local mid=find(frame(s,110-e.mb_ending/2,e),'mb','core').offset
local late=find(frame(s,110-.02,e),'mb','core')
assert(mid<start and mid>e.disc_height,'MB ring lowering')
if late then assert(late.offset<mid and late.offset-e.disc_height<.01,'nearly on the glyph at the deadline')end
local nodrop=copy(e);nodrop.mb_ending_drop=0
near(find(frame(s,110-e.mb_ending/2,nodrop),'mb','core').offset,start,1e-9,'drop 0 keeps height')
-- Commands and presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('rings',{'spin','classic'})and settings.ring_spin=='classic')
assert(cmd('rings',{'shade','0.4'})and settings.ring_shade==.4)
assert(cmd('rings',{'glow','spin','2'})and settings.ring_glow_spin==2)
assert(cmd('rings',{'glow','spin','9'})and settings.ring_glow_spin==2)
assert(cmd('mb',{'ending','drop','0.5'})and settings.mb_ending_drop==.5)
assert(cmd('mb',{'ending','0.9'})and settings.mb_ending==.9,'ending duration still works')
assert(cmd('mb',{'ending','style','hard'})and settings.mb_ending_style=='hard','ending style still works')
assert(cmd('preset',{'killala'})and settings.ring_spin=='classic'and settings.ring_shade==0 and settings.mb_ending_drop==0)
assert(cmd('preset',{'default'})and settings.ring_spin=='disc'and settings.ring_shade==.25 and settings.mb_ending_drop==1)
print('PASS Test3.2 rings in step with disc at stage speed easing to minimum, lit side, glow spin, MB ring settles, openers unchanged, killala')
