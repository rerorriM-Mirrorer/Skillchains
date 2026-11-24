-- Test4.0: opener sections. Properties share the circle (gaps 90/60/30),
-- each element is one stacked arc; two-element arcs lead/trail into each
-- other; Light/Darkness arcs have white/black heads trailing into elements.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function rgb(c)return c%16777216 end
local function opener(props)
 return {id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,
  properties=props,elements=R.elements(props[1])}
end
local function frame(s,t,o)local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local o=copy(R.defaults);o.opener_muted=false
o.ring_converge=false -- Test7.15: section geometry without the closing convergence
local function arcs(f,part,role)local r={}for _,a in ipairs(f)do if a.kind=='arc'and a.part==part and a.role==role then r[#r+1]=a end end return r end
-- Gaps and equal sections for 1, 2, 3 properties.
for n,props in ipairs({{'Liquefaction'},{'Liquefaction','Fusion'},{'Liquefaction','Fusion','Light'}})do
 local f=frame(opener(props),104,o)
 local gap=({90,60,30})[n];local span=(360-n*gap)/n
 for _,a in ipairs(arcs(f,'ground','core'))do near(a.arc_span,span,1e-9,n..' props span')end
 local starts={}
 for _,a in ipairs(arcs(f,'ground','core'))do starts[a.arc_start]=true end
 local count=0;for _ in pairs(starts)do count=count+1 end
 assert(count==n,n..' distinct sections')
 for k=1,n do assert(starts[(k-1)*(span+gap)+gap/2],'section '..k..' start')end
end
-- Arc counts per property: 1, 2, 4.
local f=frame(opener({'Liquefaction','Fusion','Light'}),104,o)
local per={}
for _,a in ipairs(arcs(f,'ground','core'))do per[a.arc_start]=(per[a.arc_start]or 0)+1 end
local section=(360-3*30)/3
assert(per[15]==1 and per[15+section+30]==2 and per[15+2*(section+30)]==4,'1/2/4 arcs')
-- Colors at the end of the white-to-color shift (t well past 2/3 of the wait).
f=frame(opener({'Fusion'}),102.6,o)
local two=arcs(f,'ground','core')
assert(#two==2)
local light,fire=rgb(R.argb(R.element_color('Light'),1)),rgb(R.argb(R.element_color('Fire'),1))
table.sort(two,function(a,b)return a.offset<b.offset end) -- ground offsets: smaller = higher lift? check both orders
local first=two[1];local second=two[2]
assert((rgb(first.color)==light and rgb(first.tail)==fire and rgb(second.color)==fire and rgb(second.tail)==light)
 or (rgb(first.color)==fire and rgb(first.tail)==light and rgb(second.color)==light and rgb(second.tail)==fire),'two-element lead/tail swap')
-- Game order on top: Fusion lists Light first, so the Light-led arc is lifted
-- (a larger offset is higher above the ground).
local top=two[1].offset>two[2].offset and two[1]or two[2]
assert(rgb(top.color)==light and rgb(top.tail)==fire,'Light-led arc on top')
local lifted=math.abs(two[1].offset-two[2].offset)
near(lifted,o.opener_spacing,1e-9,'stack spacing')
-- Light: four arcs, white heads, element tails.
f=frame(opener({'Light'}),102.6,o)
local four=arcs(f,'ground','core')
assert(#four==4)
local tails={}
for _,a in ipairs(four)do assert(rgb(a.color)==0xFFFFFF,'white head');tails[rgb(a.tail)]=true end
for _,e in ipairs(R.elements('Light'))do assert(tails[rgb(R.argb(R.element_color(e),1))],'tail '..e)end
f=frame(opener({'Darkness'}),102.6,o)
for _,a in ipairs(arcs(f,'ground','core'))do assert(rgb(a.color)==0,'black head')end
-- Fade, glow follow, rotation and glow mode carry over; sky present too.
f=frame(opener({'Fusion'}),104,o)
for _,a in ipairs(arcs(f,'ground','glow'))do near(a.fade,o.opener_fade*o.opener_fade_glow);assert(rgb(a.color)==0 and rgb(a.tail)==0,'black glow')end
assert(#arcs(f,'sky','core')==2,'sky arcs')
-- Spacing command, layout switch, killala and old DLL fall back to rings.
local rings=copy(o);rings.opener_layout='rings'
for _,r in ipairs(frame(opener({'Fusion'}),104,rings))do assert(r.kind~='arc','rings layout')end
local k=copy(o);for key,v in pairs(R.killala)do k[key]=v end
for _,r in ipairs(frame(opener({'Fusion'}),104,k))do assert(r.kind~='arc','killala rings')end
R.native_level=8
for _,r in ipairs(frame(opener({'Fusion'}),104,o))do assert(r.kind~='arc','0.8.0 DLL falls back')end
R.native_level=nil
-- Links never use sections.
local link={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}
for _,r in ipairs(frame(link,104,o))do assert(r.kind~='arc','links unchanged')end
-- Worst case stays inside the 64-stroke native limit.
local worst=0;for _ in ipairs(frame(opener({'Light','Darkness','Fusion'}),104,o))do worst=worst+1 end
assert(worst<=64,'stroke budget '..worst)
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('opener',{'spacing','0.05'})and settings.opener_spacing==.05)
assert(cmd('opener',{'spacing','1'})and settings.opener_spacing==.05)
assert(cmd('opener',{'layout','rings'})and settings.opener_layout=='rings')
assert(cmd('opener',{'layout','spiral'})and settings.opener_layout=='rings')
assert(cmd('preset',{'default'})and settings.opener_layout=='sections')
assert(cmd('preset',{'killala'})and settings.opener_layout=='rings')
print('PASS Test4.0 opener sections: gaps 90/60/30, 1/2/4 arcs, lead/tail colors, white/black heads, stacking, fade/glow, fallbacks, budget '..worst)
