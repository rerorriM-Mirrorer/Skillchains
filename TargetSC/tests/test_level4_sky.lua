-- Test6.8: `umbra sky off` / `radiance sky off` draw one set of SC rings
-- (ground only). The previous link's sky rings drop onto the ground rings
-- over the .3 s hand-off; close sequences and blooms run as for one set.
-- Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
R.native_level=10
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function link(name,o)
    local p=P.new(P.parse({'Radiance','4'},R),71,0,R,o)
    if name=='Umbra'then local st=p.model.states[71];st.properties={'Umbra'};st.elements=R.elements('Umbra')end
    return p
end
local function at(p,t,o)p:advance(t)return p.model:frame(71,t,2,4,o)end
local function count(f,part)local n=0 for _,v in ipairs(f)do if v.part==part then n=n+1 end end return n end
local function ring(f,part,j)for _,v in ipairs(f)do if v.part==part and v.strand==j and v.role=='core'then return v end end end
local function blooms(f)local n=0 for _,d in ipairs(f.discs)do if d.role=='umbra-bloom'then n=n+1 end end return n end
local o=copy(R.defaults);o.ring_level4_open='pop' -- Test7.7: these check the pre-collapse opening (sky sets on)
-- Defaults unchanged: both sets drawn.
assert(o.umbra_sky=='same'and o.radiance_sky=='bell','defaults')
for _,name in ipairs({'Umbra','Radiance'})do
    local f=at(link(name,o),1,o)
    assert(count(f,'sky')>0 and count(f,'ground')>0 and f.sky,name..' both sets by default')
end
-- Off: no sky rings, ground rings unchanged.
for _,name in ipairs({'Umbra','Radiance'})do
    local off=copy(o);off[name:lower()..'_sky']='off'
    for _,t in ipairs({.5,1,2.5})do
        local on,f=at(link(name,o),t,o),at(link(name,off),t,off)
        assert(count(f,'sky')==0 and f.sky==nil,name..' no sky rings at '..t)
        assert(count(f,'ground')==count(on,'ground'),name..' same ground rings')
        near(ring(f,'ground',1).offset,ring(on,'ground',1).offset,1e-9,name..' ground height')
        near(ring(f,'ground',1).radius,ring(on,'ground',1).radius,1e-9,name..' ground size')
    end
end
-- Each setting only touches its own skillchain.
local uo=copy(o);uo.umbra_sky='off'
assert(count(at(link('Radiance',uo),1,uo),'sky')>0,'umbra sky off leaves Radiance')
local ro=copy(o);ro.radiance_sky='off'
assert(count(at(link('Umbra',ro),1,ro),'sky')>0,'radiance sky off leaves Umbra')
-- Non-level-4 chains keep their sky rings.
local both=copy(o);both.umbra_sky='off';both.radiance_sky='off'
local lp=P.new(P.parse({'Light','3'},R),72,0,R,both)
lp:advance(1);assert(count(lp.model:frame(72,1,2,4,both),'sky')>0,'Light keeps sky')
-- Umbra close sequence: one set flashes out sooner, one bloom at the ground.
local st=link('Umbra',o).model.states[71]
assert(M.umbra_flashed(st,uo,false)<M.umbra_flashed(st,uo,true),'single set ends sooner')
local start=M.umbra_flashed(st,uo,false)
assert(blooms(at(link('Umbra',uo),start+.3,uo))==1,'one bloom with sky off')
assert(blooms(at(link('Umbra',o),M.umbra_flashed(st,o,true)+.3,o))==2,'two blooms by default')
-- Hand-off: the previous link's sky rings drop onto the ground over .3 s.
for _,name in ipairs({'Umbra','Radiance'})do
    local off=copy(o);off[name:lower()..'_sky']='off'
    local function frame(t)
        local p=link(name,off);local s=p.model.states[71]
        local prev=copy(s);prev.previous=nil;prev.step=1;prev.created=s.created-4;prev.sc_open=s.created-1;prev.sc_close=s.created+5
        s.previous=prev
        return p.model:frame(71,s.created+t,2,4,off),s
    end
    local a=frame(.15);local b=frame(.25)
    local ga,sa=ring(a,'ground',1),ring(a,'sky',1)
    assert(sa and sa.offset>ga.offset,name..' sky still above at .15')
    local gb,sb=ring(b,'ground',1),ring(b,'sky',1)
    assert(sb and sb.offset-gb.offset<sa.offset-ga.offset,name..' sky dropping')
    assert(sb.radius>=gb.radius-1e-9,name..' sky ring never smaller than ground while dropping')
    assert(count(frame(.35),'sky')==0,name..' gone after the hand-off')
end
-- Commands and presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('umbra',{'sky','off'});assert(settings.umbra_sky=='off')
cmd('umbra',{'sky','same'});assert(settings.umbra_sky=='same')
cmd('radiance',{'sky','off'});assert(settings.radiance_sky=='off')
cmd('radiance',{'sky','bell'});assert(settings.radiance_sky=='bell')
cmd('radiance',{'sky','x'});assert(settings.radiance_sky=='bell','rejects')
assert(R.killala.radiance_sky=='bell'and R.killala.umbra_sky=='bell','killala keeps both sets')
print('PASS Test6.8 level-4 sky off: no sky rings (Umbra and Radiance, own settings only, Light unaffected), ground unchanged, single-set close and one bloom, hand-off drop, commands, presets')
