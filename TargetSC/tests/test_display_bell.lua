-- Test7 controls and deadline presentation. Host simulation, not live FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local Motion=require('resonance_motion')
local Burst=require('resonance_burst')
local Controls=require('resonance_controls')
local function copy(t)local o={}for k,v in pairs(t)do o[k]=v end return o end
local function near(a,b)assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b))end
local opts=copy(R.defaults)
local s={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}
local function model()local m=R.new();m.states[71]=copy(s);return m end
local function layer(f,role,part)
 for _,v in ipairs(part and f or f.discs or {})do if v.role==role and(not part or v.part==part)then return v end end
end
for _,cutoff in ipairs({.05,.55,1})do
 for _,curve in ipairs({1,2,8})do
  local o=copy(opts);o.sky_cutoff=cutoff;o.sky_curve=curve
  near(Motion.bell_factor(3.6,4,o),1+o.sky_expand)
  near(Motion.bell_factor(3.6*(1-cutoff),4,o),1)
  near(Motion.bell_factor(3.6*(1-cutoff/2),4,o),1+o.sky_expand*.5^curve)
  near(Motion.bell_factor(0,4,o),1)
 end
end
for _,mode in ipairs({'sc','mb','both','off'})do
 local o=copy(opts);o.display=mode
 local f=model():frame(71,101,2,4,o)
 assert((layer(f,'core','ground')~=nil)==(mode=='sc'or mode=='both'))
 assert((layer(f,'core','mb')~=nil)==(mode=='mb'or mode=='both'))
 assert((layer(f,'mb-glyph')~=nil)==(mode=='mb'or mode=='both'))
 if mode=='off'then assert(#f==0 and #f.discs==0)end
end
local m=model()
local a=layer(m:frame(71,101,2,4,opts),'core','mb')
local b=layer(m:frame(71,109,2,4,opts),'core','mb')
assert(b.color>a.color,'middle-ring alpha increases toward deadline')
local previous=math.huge
for i=0,2 do
 local t=110-opts.mb_ending+(i+.5)*opts.mb_ending/3
 local response=Burst.sample(m,s,t,function(k)return opts[k]end)
 near(response.end_flash,1-i/3)
 local f=m:frame(71,t,2,4,opts)
 local ring=layer(f,'core','mb');local glyph=layer(f,'mb-glyph')
 assert(ring.color%16777216==16777215 and glyph.outline%16777216==16777215)
 assert(ring.color<previous);previous=ring.color
end
assert(not layer(m:frame(71,110,2,4,opts),'core','mb'))
assert(not layer(m:frame(71,110,2,4,opts),'mb-glyph'))
for _,duration in ipairs({.2,1.2,4})do
 local o=copy(opts);o.mb_duration=duration;o.mb_idle=0
 local x=model();x.bursts[71]={{at=105,color=R.element_color('Wind')}}
 assert(layer(x:frame(71,105+duration*.5,2,4,o),'mb-glyph'))
 assert(not layer(x:frame(71,105+duration+.001,2,4,o),'mb-glyph'))
 near(x.states[71].mb_close,110)
end
local o=copy(opts);o.mb_effects=0
local x=model();x.bursts[71]={{at=105,color=R.element_color('Wind')}}
assert(not layer(x:frame(71,105,2,4,o),'mb-glyph'))
local saves=0
local control=Controls.new(o,R.defaults,function()saves=saves+1 end,function()end)
for _,v in ipairs({{'display',{'mb'}},{'sky',{'cutoff','.6'}},{'sky',{'curve','3'}},{'mb',{'duration','2'}},{'mb',{'effects','.4'}},{'mb',{'ending','.9'}}})do assert(control(v[1],v[2]))end
assert(saves==6 and o.display=='mb'and o.sky_cutoff==.6 and o.sky_curve==3 and o.mb_duration==2 and o.mb_effects==.4 and o.mb_ending==.9)
control('sky',{'cutoff','0'});control('display',{'bad'});assert(saves==6)
print('PASS Test7 bell cutoff/curve, SC/MB visibility, increasing middle opacity, three decreasing white deadline flashes, response duration/opacity and saved command validation')
