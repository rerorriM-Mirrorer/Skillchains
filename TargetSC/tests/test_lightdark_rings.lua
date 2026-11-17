-- Test4.5: level-3 Light/Darkness links: white/black outer strands, four
-- element colors on the middle strand, MB ring cycling the four colors.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local M=require('resonance_motion')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function rgb(c)return c%16777216 end
local function argb(c)return rgb(R.argb(c,1))end
local function link(prop,level)return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=level,
 properties={prop},elements=R.elements(prop)}end
local function frame(s,t,o)local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local function cores(f,part)local r={}for _,x in ipairs(f)do if x.part==part and x.role=='core'then r[x.strand]=x end end return r end
local o=copy(R.defaults);o.ring_shade=0;o.mb_intro=0;o.ring_light='elements' -- Test4.5 look; Light's white look has its own test
for prop,head in pairs({Light=0xFFFFFF,Darkness=0})do
 local f=frame(link(prop,3),104,o)
 for _,part in ipairs({'ground','sky'})do
  local c=cores(f,part)
  assert(c[1]and c[2]and c[3],prop..' three strands '..part)
  assert(#c[1].colors==1 and rgb(c[1].colors[1])==head and rgb(c[3].colors[1])==head,prop..' outer strands '..part)
  assert(#c[2].colors==4 and c[2].blend==1,prop..' middle four colors blended')
  for i,e in ipairs(R.elements(prop))do assert(rgb(c[2].colors[i])==argb(R.element_color(e)),prop..' middle '..e)end
  near(c[2].rotation,c[1].rotation,1e-12,prop..' middle turns with the rest by default')
 end
end
-- Middle strand spin multiplier.
local sp=copy(o);sp.ring_lightdark_spin=-1
local c=cores(frame(link('Light',3),104,sp),'ground')
near(c[2].rotation,-c[1].rotation,1e-12,'counter-turn')
-- Glow tint: white for Light in elements look; gold option; Darkness purple.
local function glows(f)local r={}for _,x in ipairs(f)do if x.role=='glow'and #x.colors==1 then r[#r+1]=rgb(x.colors[1])end end return r end
local wt=glows(frame(link('Light',3),104,o))
local found_white=false;for _,v in ipairs(wt)do if v==0xFFFFFF then found_white=true end end
assert(found_white,'white Light glow tint')
local g=copy(o);g.ring_lightdark_tint='gold'
local found_gold=false;for _,v in ipairs(glows(frame(link('Light',3),104,g)))do if v==argb({255,217,115})then found_gold=true end end
assert(found_gold,'gold option')
-- MB ring cycles through the four colors, twice level 2's speed by default.
local function mb(t,opts,prop)for _,x in ipairs(frame(link(prop or 'Light',3),t,opts))do if x.part=='mb'and x.role=='core'then return x end end end
local per=o.mb_period/o.mb_lightdark_cycle -- seconds per color hand-off
local seen={}
for i=0,3 do local x=mb(100+i*per,o);if x then seen[rgb(x.colors[1])]=true end end
for _,e in ipairs(R.elements('Light'))do assert(seen[argb(R.element_color(e))],'MB ring shows '..e)end
-- Classic restores the previous three-tone strands and MB color.
local cl=copy(o);cl.ring_lightdark='classic';cl.ring_light='classic'
local cc=cores(frame(link('Light',3),104,cl),'ground')
for j=1,3 do assert(#cc[j].colors==1)end
assert(rgb(cc[2].colors[1])~=0xFFFFFF or rgb(cc[3].colors[1])~=0xFFFFFF,'classic tones')
-- Other levels/properties untouched; level 4 untouched.
for _,s in ipairs({link('Fusion',2),link('Radiance',4),link('Umbra',4)})do
 local a,b=frame(s,104,o),frame(s,104,cl)
 assert(#a==#b)
 for i=1,#a do assert(a[i].colors[1]==b[i].colors[1],'untouched '..s.properties[1])end
end
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('rings',{'lightdark','classic'})and settings.ring_lightdark=='classic')
assert(cmd('rings',{'lightdark','elements'})and settings.ring_lightdark=='elements')
assert(cmd('rings',{'lightdark','spin','-0.5'})and settings.ring_lightdark_spin==-.5)
assert(cmd('rings',{'lightdark','tint','gold'})and settings.ring_lightdark_tint=='gold')
assert(cmd('rings',{'lightdark','tint','blue'})and settings.ring_lightdark_tint=='gold')
assert(cmd('rings',{'lightdark','cycle','3'})and settings.mb_lightdark_cycle==3)
assert(cmd('rings',{'shade','0.5'})and settings.ring_shade==.5,'rings shade still works')
assert(cmd('preset',{'killala'})and settings.ring_lightdark=='classic'and settings.ring_lightdark_tint=='gold')
assert(cmd('preset',{'default'})and settings.ring_lightdark=='elements'and settings.mb_lightdark_cycle==2 and settings.ring_light=='white')
print('PASS Test4.5 Light/Darkness level 3: white/black outer strands, four-color middle, spin, tint, MB four-color cycle, classic, others untouched')
