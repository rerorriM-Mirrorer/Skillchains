-- Test6.0: Umbra collapse ending (everything shrinks to the center over the
-- last seconds, slow start then a whoosh; MB ring does not sink; disc stays
-- opaque) and the floor glyph lift above the black disc. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
R.native_level=11
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function link(o,name)
    local p=P.new(P.parse({'Radiance','4'},R),71,0,R,o)
    if name~='Radiance'then local st=p.model.states[71];st.properties={'Umbra'};st.elements=R.elements('Umbra')end
    return p,p.model.states[71]
end
local function at(p,t,o)p:advance(t)return p.model:frame(71,t,2,4,o)end
local function role(f,r)for _,d in ipairs(f.discs)do if d.role==r then return d end end end
local function mb(f)for _,v in ipairs(f)do if v.part=='mb'and v.role=='core'then return v end end end
local o=copy(R.defaults);o.umbra_disc_opacity=1
local _,st=link(o)
local E=st.mb_close-o.mb_ending
-- Collapse factor: 1 before, slow start, whoosh, ~0 at the deadline.
near(M.umbra_collapse(st,E-.1,o),1,1e-9,'full before the ending')
assert(M.umbra_collapse(st,E+1,o)>.9,'very slow start (half way still > 90%)')
assert(M.umbra_collapse(st,st.mb_close-.05,o)<.15,'whoosh at the end')
-- Everything shrinks together: disc, MB ring, floor glyph.
local before,late=at(link(o),E-.05,o),at(link(o),E+1.6,o)
local c=M.umbra_collapse(st,E+1.6,o)
near(role(late,'property').radius,role(before,'property').radius*c,1e-6,'disc shrinks')
near(mb(late).radius,mb(before).radius*c,1e-6,'MB ring shrinks')
assert(role(late,'mb-glyph').radius<role(before,'mb-glyph').radius,'glyph shrinks')
-- MB ring does not sink; disc stays opaque.
near(mb(late).offset,mb(before).offset,1e-9,'MB ring height held')
assert(math.floor(role(late,'property').color/16777216)>=254,'black disc stays opaque')
local off=copy(o);off.umbra_collapse=false
assert(mb(at(link(off),E+1.6,off)).offset<mb(before).offset,'without collapse it sinks as before')
-- The swallow glyph shrinks too.
local sw=copy(o);sw.umbra_ending='swallow';sw.umbra_ending_when='open';sw.umbra_ending_time=10;sw.umbra_sink_time=8
local g1=at(link(sw),E-.05,sw).glyphs3[1].radius
assert(at(link(sw),E+1.6,sw).glyphs3[1].radius<g1*.7,'swallow glyph collapses')
-- Radiance unaffected.
local ra=at(link(o,'Radiance'),E+1.6,o)
assert(mb(ra).offset<mb(at(link(o,'Radiance'),E-.05,o)).offset,'Radiance keeps its normal ending')
-- Curve and time.
local sharp=copy(o);sharp.umbra_collapse_curve=8
assert(M.umbra_collapse(st,E+1.5,sharp)>M.umbra_collapse(st,E+1.5,o),'higher curve = later whoosh')
local long=copy(o);long.umbra_collapse_time=4
assert(M.umbra_collapse(st,st.mb_close-3,long)<1,'collapse time')
-- Glyph lift: always just above the disc plane, bursts included.
local gf=at(link(o),5,o)
near(role(gf,'mb-glyph').offset,role(gf,'property').offset+o.umbra_glyph_lift,1e-9,'just above the black hole')
local m=link(o);m.model.bursts[71]={{at=5,color=R.element_color('Ice')}}
m:advance(5.3)
local bf=m.model:frame(71,5.3,2,4,o)
near(role(bf,'mb-glyph').offset,role(bf,'property').offset+o.umbra_glyph_lift,1e-9,'held there on a burst')
-- Commands, presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('umbra',{'collapse','off'});assert(settings.umbra_collapse==false)
cmd('umbra',{'collapse','on'});cmd('umbra',{'collapse','curve','6'});cmd('umbra',{'collapse','time','3'})
assert(settings.umbra_collapse and settings.umbra_collapse_curve==6 and settings.umbra_collapse_time==3)
cmd('umbra',{'collapse','time','same'});assert(settings.umbra_collapse_time==-1)
cmd('umbra',{'glyph','lift','0'});assert(settings.umbra_glyph_lift==0)
cmd('umbra',{'glyph','lift','same'});assert(settings.umbra_glyph_lift==-1)
cmd('preset',{'killala'});assert(settings.umbra_collapse==false and settings.umbra_glyph_lift==-1)
cmd('preset',{'default'});assert(settings.umbra_collapse==true and settings.umbra_glyph_lift==.004)
print('PASS Test6.0 Umbra collapse (slow start, whoosh, disc/MB ring/glyph/swallow shrink, MB ring held, disc opaque, curve/time, Radiance unaffected) and glyph lift (rest and bursts); commands; presets')
