-- Test10: analytic clapper motion and original chain with real-property MBs.
-- Host simulation; no game actions, renderer or source clock changes.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local B=require('resonance_burst')
local P=require('resonance_preview')
local C=require('resonance_controls')
local function copy(t)local o={}for k,v in pairs(t)do o[k]=v end return o end
local function near(a,b)assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b))end
local function layer(f,role,part)
 for _,v in ipairs(part and f or f.discs)do if v.role==role and(not part or v.part==part)then return v end end
end
local function alpha(c)return math.floor(c/16777216)end
local o=copy(R.defaults);o.mb_intro=0;o.amplitude=0;o.hum_amplitude=0;o.mb_overall=.6
local s={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,
 step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}
local function model()local m=R.new();m.states[71]=copy(s);return m end
local function frame(m,t,opts)return m:frame(71,t,2,4,opts or o)end
local m=model();local f=frame(m,101)
local ring=assert(layer(f,'core','mb'));local fill=assert(layer(f,'property'))
local trace=assert(layer(f,'property-trace'));local large=assert(layer(f,'mb-glyph'))
near(ring.radius,2*.89);near(large.radius,ring.radius)
near(ring.offset,(trace.offset+f.ground)/2)
assert(fill.offset<ring.offset and ring.offset<f.ground)
near(f.ground,o.ground_height+o.ground_lift)
local rotation=large.rotation
near(layer(frame(m,102),'mb-glyph').rotation-rotation,-2*math.pi*o.mb_spin)
local slow=copy(o);slow.disc_slowdown=4;slow.disc_speed=0
near(layer(frame(m,102,slow),'mb-glyph').rotation,layer(frame(m,102),'mb-glyph').rotation)
local trough=frame(m,102);local peak=frame(m,101)
assert(alpha(layer(trough,'mb-glyph').outline)>0)
assert(alpha(layer(trough,'mb-glyph').outline)<alpha(layer(peak,'mb-glyph').outline))
assert(alpha(layer(trough,'core','mb').color)>0)
assert(layer(frame(m,102),'core','mb').color%16777216~=layer(frame(m,104),'core','mb').color%16777216)
local terminal=model();terminal.states[71].level=4;terminal.states[71].properties={'Umbra'};terminal.states[71].closed=true
near(layer(frame(terminal,101),'core','mb').radius,2*.96)
-- Immediate elemental flash/lift, a full hold through ring flashing, then
-- one quintic energy drives height, color and alpha back to the foundation.
m=model();m.bursts[71]={{at=104,color=R.element_color('Fire')}}
local baseline=frame(model(),104)
local base_fill=layer(baseline,'property');local base_trace=layer(baseline,'property-trace')
for _,t in ipairs({104,104.1,104.44})do
 f=frame(m,t);fill=layer(f,'property');trace=layer(f,'property-trace')
 near(fill.offset,base_fill.offset);near(trace.offset,base_trace.offset+o.mb_lift)
 assert(alpha(fill.color)==153 and alpha(trace.outline)==153)
 assert(fill.color%16777216==R.argb(R.element_color('Fire'),0))
 assert(trace.outline%16777216==fill.color%16777216)
 assert(layer(f,'burst-glow','property-trace'))
end
local middle=104+.45+o.mb_return/2
f=frame(m,middle);trace=layer(f,'property-trace');fill=layer(f,'property')
near(B.return_energy(middle-104,.45,o.mb_return),.5)
near(trace.offset,base_trace.offset+o.mb_lift*.5)
assert(alpha(fill.color)==math.floor((o.disc_opacity*o.opacity+o.mb_overall)*.5*255+.5))
f=frame(m,105.31);near(layer(f,'property-trace').offset,base_trace.offset)
assert(layer(f,'property-trace').outline==base_trace.outline)
assert(layer(f,'property').color==base_fill.color)
assert(not layer(f,'burst-glow','property-trace'))
near(B.return_energy(0,.45,.85),1);near(B.return_energy(2,.45,.85),0)
for _,key in ipairs({'mb_overall','mb_floor','mb_effects'})do
 local muted=copy(o);muted[key]=0
 local hit=model();hit.bursts[71]={{at=104,color=R.element_color('Fire')}}
 local plain=frame(model(),104,muted);f=frame(hit,104,muted)
 near(layer(f,'property-trace').offset,layer(plain,'property-trace').offset)
 assert(layer(f,'property').color==layer(plain,'property').color)
end
local restraint=copy(o);restraint.mb_lift=0;restraint.mb_shimmer=0
local hit=model();hit.bursts[71]={{at=104,color=R.element_color('Fire')}}
f=frame(hit,104,restraint)
near(layer(f,'property-trace').offset,base_trace.offset);assert(not layer(f,'burst-glow','property-trace'))
-- Release cache stays airborne when another hit arrives during the release.
hit=model();hit.bursts[71]={{at=104,color=R.element_color('Fire')}}
local before=layer(frame(hit,104.5),'mb-glyph').offset
hit.bursts[71][2]={at=104.5,color=R.element_color('Light')}
near(layer(frame(hit,104.5),'mb-glyph').offset,before)
local sc=copy(o);sc.display='sc';f=frame(hit,104.5,sc)
assert(not layer(f,'mb-glyph')and not layer(f,'core','mb'))
near(layer(f,'property-trace').offset,base_trace.offset)
assert(not layer(frame(hit,110),'property-trace')and not layer(frame(hit,110),'mb-glyph'))
-- Original five WS events / four successful links and their deadlines stay
-- exact. Every added burst belongs to its active property's actual elements.
local demo=P.new(assert(P.parse({'mb'},R)),71,200,R,o)
assert(#demo.events==8);local chain,bursts=0,0;local current=demo.model.states[71]
local expected={209,217,224,230}
for _,event in ipairs(demo.events)do
 if event.kind=='chain'then chain=chain+1;near(event.at,expected[chain]);current=event.state
 else
  bursts=bursts+1;assert(event.at>current.created and event.at<current.mb_close)
  local valid=false;for _,element in ipairs(R.elements(current.properties[1]))do if element==event.element then valid=true end end
  assert(valid,'invalid demo MB element '..event.element)
 end
end
assert(chain==4 and bursts==4);near(demo.ends,240.05)
for i=0,4010 do
 local t=200+i/100;demo:advance(t);f=demo.model:frame(71,t,2,4,o)
 assert(#f<=32 and #f.discs<=8)
 for _,d in ipairs(f.discs)do assert(d.radius==d.radius and d.offset==d.offset and d.radius<=100)end
end
for _,args in ipairs({{'mbdemo'},{'demo','mb'}})do assert(P.parse(args,R).kind=='mbdemo')end
local original=P.new(assert(P.parse({'demo'},R)),71,200,R,o)
assert(#original.events==4);for _,event in ipairs(original.events)do assert(event.kind=='chain')end
local late=P.new(assert(P.parse({'mb'},R)),71,200,R,o);late:advance(239)
assert(late.model.states[71].level==4 and #late.model.bursts[71]==4)
local saved=0;local settings=copy(o)
local command=C.new(settings,R.defaults,function()saved=saved+1 end,function()end)
for _,row in ipairs({{'style','classic'},{'size','.6'},{'position','.3'},{'spin','.02'},
 {'hold','.2'},{'return','1'},{'lift','.05'},{'shimmer','.4'},{'breath','min','.2'},{'breath','gain','3'}})do command('mb',row)end
command('ground',{'lift','.02'});assert(saved==11 and settings.mb_style=='classic'and settings.mb_breath_min==.2)
for _,row in ipairs({{'style','bad'},{'size','2'},{'lift','nan'},{'breath','min','-1'},{'return','0'}})do command('mb',row)end
assert(saved==11)
print('PASS Test10 clapper placement/radii, shared breathing/cycling/reverse spin, full immediate strikes, quintic return, restraint/master controls, overlapping release, deadline clipping and four-link MB demo transitions')
