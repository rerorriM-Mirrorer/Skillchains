-- Test4.6: level-3 Light 'white' look: all strands white; four inner rings
-- glow in the element colors top to bottom, rotating; MB ring white.
-- Darkness keeps the elements look.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function rgb(c)return c%16777216 end
local function argb(c)return rgb(R.argb(c,1))end
local function link(prop)return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=3,
 properties={prop},elements=R.elements(prop)}end
local function frame(s,t,o)local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local o=copy(R.defaults);o.ring_shade=0;o.mb_intro=0
local four={};for i,e in ipairs(R.elements('Light'))do four[i]=argb(R.element_color(e))end
local function sample(t,opts)
 local f=frame(link('Light'),t,opts or o)
 local core,glow={},{}
 for _,x in ipairs(f)do
  local key=x.part..x.strand
  if x.role=='core'and (x.part=='ground'or x.part=='sky')then core[key]=x end
  if x.role=='glow'and (x.part=='ground'or x.part=='sky')then glow[key]=glow[key]or {};glow[key][#glow[key]+1]=x end
 end
 return core,glow,f
end
-- All six strands white.
local core,glow,f=sample(104)
for _,place in ipairs({'ground','sky'})do for j=1,3 do
 local x=core[place..j];assert(x and #x.colors==1 and rgb(x.colors[1])==0xFFFFFF,'white '..place..j)
end end
-- Inner glows top to bottom: sky2, sky1, ground3, ground2 at step boundaries.
local order={'sky2','sky1','ground3','ground2'}
local function glow_rgb(g,key)local seen={}for _,x in ipairs(g[key]or{})do seen[rgb(x.colors[1])]=true end return seen end
-- (Age 0 shows the brief white link strike; sample later step boundaries.)
local fast=copy(o);fast.ring_light_cycle=1
for k=1,4 do
 local _,g=sample(100+k*fast.ring_light_cycle,fast)
 for i,key in ipairs(order)do
  local want=four[(i-1+k)%4+1]
  assert(glow_rgb(g,key)[want],'inner '..key..' step '..k)
 end
 -- Outer rings keep white glows.
 for _,key in ipairs({'sky3','ground1'})do assert(glow_rgb(g,key)[0xFFFFFF],'outer white glow '..key)end
end
-- One of the four inner glows is Light (white) at each step boundary.
local _,g=sample(102,fast)
local whites=0;for _,key in ipairs(order)do if glow_rgb(g,key)[0xFFFFFF]then whites=whites+1 end end
assert(whites==1,'exactly one inner glow is the Light element')
-- Glow strength option scales the colored glow alpha.
local strong=copy(o);strong.ring_light_glow=2
local function inner_alpha(opts)local _,g2=sample(104,opts);for _,x in ipairs(g2['sky2'])do if rgb(x.colors[1])~=0xFFFFFF then return math.floor(x.colors[1]/16777216)end end end
assert(inner_alpha(strong)>inner_alpha(o),'glow strength')
-- MB ring white.
for _,x in ipairs(f)do if x.part=='mb'and x.role=='core'then assert(rgb(x.colors[1])==0xFFFFFF,'white MB ring')end end
-- Darkness unchanged by the Light mode.
local dark1,dark2=frame(link('Darkness'),104,o),frame(link('Darkness'),104,(function()local x=copy(o);x.ring_light='classic';return x end)())
assert(#dark1==#dark2)
for i=1,#dark1 do assert(dark1[i].colors[1]==dark2[i].colors[1],'Darkness untouched')end
local found4=false;for _,x in ipairs(dark1)do if x.role=='core'and #x.colors==4 then found4=true end end
assert(found4,'Darkness keeps its four-color middle strand')
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('rings',{'light','elements'})and settings.ring_light=='elements')
assert(cmd('rings',{'light','white'})and settings.ring_light=='white')
assert(cmd('rings',{'light','cycle','8'})and settings.ring_light_cycle==8)
assert(cmd('rings',{'light','glow','1.5'})and settings.ring_light_glow==1.5)
assert(cmd('rings',{'light','glow','9'})and settings.ring_light_glow==1.5)
assert(cmd('rings',{'lightdark','spin','-2'})and settings.ring_lightdark_spin==-2,'lightdark still works')
assert(cmd('preset',{'killala'})and settings.ring_light=='classic')
print('PASS Test4.6 Light white look: six white strands, inner element glows rotating top to bottom, glow strength, white MB ring, Darkness untouched')
