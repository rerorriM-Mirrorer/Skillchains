-- Test7.15: per-stage awakening disc opacity and fade end; opener arcs'
-- own converge start. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
R.native_level=12
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function cioara()local a=copy(require('tests.fixture_cioara_1122'))for k,v in pairs(R.defaults)do if a[k]==nil then a[k]=v end end return a end

for _,st in ipairs({'opener','level1','level2','level3'})do
    assert(R.defaults['awakening_opacity_'..st]==-1 and R.defaults['awakening_until_'..st]=='same',st..' defaults')
end
assert(R.defaults.ring_converge_opener==1,'opener converge default 1')

-- Defaults: identical to the overall settings.
for _,o in ipairs({copy(R.defaults),cioara()})do
    for _,st in ipairs({'opener','level1','level2','level3'})do
        near(M.awakening_opacity(o,st),o.awakening_opacity,1e-12,st)
        for t=0,3,.25 do near(M.awakening_level(0,3,9,t,o,st),M.awakening_level(0,3,9,t,o),1e-12,st..' level')end
    end
end
-- Own values.
local o=copy(R.defaults);o.awakening_opacity_level2=.8;o.awakening_until_level2='open';o.awakening_until='default'
near(M.awakening_opacity(o,'level2'),.8);near(M.awakening_opacity(o,'level1'),o.awakening_opacity)
assert(M.awakening_level(0,3,9,2.5,o,'level2')>M.awakening_level(0,3,9,2.5,o,'level1'),'open fades later than default')
near(M.awakening_level(0,3,9,3,o,'level2'),0,1e-9,'gone by the window opening')
o.awakening_until_level3='close'
assert(M.awakening_level(0,3,9,5,o,'level3')>0,'close lasts into the window')

-- In a running preview (demo: opener 0, L1 9, L2 17, L3 24): a stage at 0
-- draws no awakening disc; other stages still do.
local function awake(opts,t)
    local p=P.new(P.parse({'demo'},R),71,0,R,opts)
    p:advance(t)local f=p.model:frame(71,t,2,4,opts)
    local best=0
    for _,d in ipairs(f.discs or {})do if d.role=='awakening'then best=math.max(best,math.floor(d.color/16777216))end end
    if f.awakening_glyph and f.awakening_glyph.role=='awakening'then best=math.max(best,1)end
    return best
end
local base=cioara()
local probes={opener=.6,level1=9.6,level2=17.6,level3=24.6}
for st,t in pairs(probes)do assert(awake(base,t)>0,st..' draws by default at '..t)end
for st,t in pairs(probes)do
    local x=cioara();x['awakening_opacity_'..st]=0
    assert(awake(x,t)==0,st..' opacity 0 hides it')
    for other,u in pairs(probes)do if other~=st then assert(awake(x,u)>0,st..'=0 leaves '..other)end end
end
-- A stage's own opacity scales its disc.
local half=cioara();half.awakening_opacity_level2=.5
assert(awake(half,17.6)<awake(base,17.6),'level2 .5 dimmer than 1')

-- Opener converge start: 1 starts at the top of the descent; strands keep theirs.
local d=copy(R.defaults)
local op={created=0,sc_open=3,sc_close=10,step=1,level=1,closed=false}
local link={created=0,sc_open=3,sc_close=9,step=2,level=2,closed=false}
local t=3+.5*7
assert(M.converge(op,t,d)<1,'opener converging mid-descent with from 1')
near(M.converge(link,3+.3*6,d),1,1e-9,'strands still apart early')
d.ring_converge_opener=-1
near(M.converge(op,3+.3*7,d),1,1e-9,'same = converge from (.35)')

-- Commands.
local settings=copy(R.defaults);local said
local cmd=C.new(settings,R.defaults,function()end,function(m)said=m end,R.killala,R.cioara)
assert(cmd('awakening',{'level2','opacity','.6'})and settings.awakening_opacity_level2==.6)
assert(cmd('awakening',{'level2','opacity','same'})and settings.awakening_opacity_level2==-1)
assert(cmd('awakening',{'opener','fade','until','open'})and settings.awakening_until_opener=='open')
assert(cmd('awakening',{'level3','fade','until','4'})and settings.awakening_until_level3=='4s')
assert(cmd('awakening',{'level3','fade','until','soon'})and settings.awakening_until_level3=='4s'and said:find('^Use'))
assert(cmd('awakening',{'level1','fade','until','same'})and settings.awakening_until_level1=='same')
assert(cmd('awakening',{'opacity','.4'})and settings.awakening_opacity==.4,'overall still works')
assert(cmd('awakening',{'fade','until','close'})and settings.awakening_until=='close','overall until still works')
assert(cmd('rings',{'converge','opener','.7'})and settings.ring_converge_opener==.7)
assert(cmd('rings',{'converge','opener','same'})and settings.ring_converge_opener==-1)
assert(not said:find('[\128-\255]'),'ASCII')
print('PASS Test7.15 per-stage awakening opacity/fade, opener converge start')
