-- Test4.7: level-3 Light: colored inner glows off before the window opens,
-- rising to `rings light glow` as it opens; MB ring matches the lowest SC
-- ring (white, lit side, rotation) while keeping its MB timing.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local M=require('resonance_motion')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function rgb(c)return c%16777216 end
local function argb(c)return rgb(R.argb(c,1))end
local function alpha(c)return math.floor(c/16777216)end
local light={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=3,properties={'Light'},elements=R.elements('Light')}
local function frame(t,o,s)local m=R.new();m.states[71]=copy(s or light);return m:frame(71,t,2,4,o)end
local o=copy(R.defaults);o.mb_intro=0;o.ring_shade=.6
local elements={};for _,e in ipairs(R.elements('Light'))do if argb(R.element_color(e))~=0xFFFFFF then elements[argb(R.element_color(e))]=true end end
-- Any non-white glow on the SC rings is a colored inner glow (blends included).
local function tinted(x)return x.role=='glow'and (x.part=='ground'or x.part=='sky')and rgb(x.colors[1])~=0xFFFFFF end
local function colored(f)local n=0;for _,x in ipairs(f)do if tinted(x)then n=n+1 end end return n end
-- Before the window: no colored glows; after: colored glows at full setting.
assert(colored(frame(101.5,o))==0,'no colored glows before the window opens')
assert(colored(frame(104,o))>0,'colored glows after it opens')
local on=copy(o);on.ring_light_opening='on'
assert(colored(frame(101.5,on))>0,'opening on: glows from the start')
-- After the transition, identical to opening on (rings only).
for _,t in ipairs({103.5,105,107})do
 local a,b=frame(t,o),frame(t,on)
 for i=1,#a do for k=1,#a[i].colors do assert(a[i].colors[k]==b[i].colors[k],'same after opening '..t)end end
end
-- Strength rises through the opening (.3 s centred on the window).
local function strongest(t)local best=0;for _,x in ipairs(frame(t,o))do if tinted(x)then best=math.max(best,alpha(x.colors[1]))end end return best end
assert(strongest(102.9)<strongest(103.2),'glows rise as the window opens')
-- MB ring matches the lowest SC ring: white, lit side (bright/dim pair), same rotation.
local function find(f,part,strand)for _,x in ipairs(f)do if x.part==part and x.role=='core'and (strand==nil or x.strand==strand)then return x end end end
local f=frame(105,o)
local mb,low=find(f,'mb'),find(f,'ground',1)
assert(mb and low)
near(mb.rotation,low.rotation,1e-12,'MB ring turns with the lowest ring')
assert(#mb.colors==2 and rgb(mb.colors[1])==0xFFFFFF and alpha(mb.colors[1])>alpha(mb.colors[2]),'white with a lit side')
assert(#low.colors==2,'lowest ring has the same lit side')
local wh=copy(o);wh.ring_light_mb='white'
local plain=find(frame(105,wh),'mb')
assert(#plain.colors==1 and plain.rotation==0,'mb white: plain, still')
-- MB timing kept: breathing still changes its alpha over time.
local a1,a2=alpha(find(frame(104.5,o),'mb').colors[1]),alpha(find(frame(105.5,o),'mb').colors[1])
assert(a1~=a2,'MB ring still breathes')
-- Only level-3 Light: Darkness and Fusion MB rings unchanged.
for _,s in ipairs({{id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=3,properties={'Darkness'},elements=R.elements('Darkness')},
 {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}})do
 local x=find(frame(105,o,s),'mb');assert(x.rotation==0 and #x.colors==1,s.properties[1]..' MB ring unchanged')
end
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('rings',{'light','opening','on'})and settings.ring_light_opening=='on')
assert(cmd('rings',{'light','opening','off'})and settings.ring_light_opening=='off')
assert(cmd('rings',{'light','mb','white'})and settings.ring_light_mb=='white')
assert(cmd('rings',{'light','mb','match'})and settings.ring_light_mb=='match')
assert(cmd('rings',{'light','mb','gold'})and settings.ring_light_mb=='match')
assert(cmd('preset',{'killala'})and settings.ring_light_opening=='on'and settings.ring_light_mb=='white')
assert(cmd('preset',{'default'})and settings.ring_light_opening=='off'and settings.ring_light_mb=='match')
print('PASS Test4.7 Light: colored glows off until the window opens then rise; MB ring matches lowest ring (white, lit side, rotation), still breathes; Darkness/L2 untouched')
