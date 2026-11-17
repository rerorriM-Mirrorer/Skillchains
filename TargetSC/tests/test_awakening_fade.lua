-- Test3.5: white awakening disc center-to-edge fade and size.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function find(f,role)for _,d in ipairs(f.discs)do if d.role==role then return d end end end
local s={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,
 properties={'Fusion','Liquefaction'},elements=R.elements('Fusion')}
local function frame(t,o)local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local o=copy(R.defaults)
-- Default: center keeps its opacity, edge transparent.
local d=assert(find(frame(100.6,o),'awakening'),'awakening disc present')
near(d.inner,1);near(d.outer,0)
-- Old look via killala: even fill.
local k=copy(o);for key,v in pairs(R.killala)do k[key]=v end
local dk=find(frame(100.6,k),'awakening')
near(dk.inner,1);near(dk.outer,1)
assert(dk.colors[1]==d.colors[1],'fill opacity itself is unchanged; only the radial multipliers differ')
-- Size scales the radius at every moment of the grow/fade.
for _,t in ipairs({100.2,100.6,101.2,101.8})do
 local base=find(frame(t,o),'awakening')
 local big=copy(o);big.awakening_size=1.5
 local scaled=find(frame(t,big),'awakening')
 if base then near(scaled.radius,base.radius*1.5,1e-9,'size at '..t)end
end
-- Only the awakening disc carries radial values.
for _,disc in ipairs(frame(100.6,o).discs)do
 if disc.role~='awakening'then assert(disc.inner==nil and disc.outer==nil,'no radial on '..disc.role)end
end
-- Pre-0.7.0 fallback alpha helper.
assert(R.scale_alpha(0xFF123456,.5)==0x80123456)
assert(R.scale_alpha(0x80123456,0)==0x00123456)
-- Commands.
local settings=copy(R.defaults)
local said={}
local cmd=C.new(settings,R.defaults,function()end,function(t)said[#said+1]=t end,R.killala)
assert(cmd('awakening',{'fade','0.8'})and settings.awakening_inner==.8 and settings.awakening_outer==0,'outer defaults to 0')
assert(cmd('awakening',{'fade','1','0.4'})and settings.awakening_inner==1 and settings.awakening_outer==.4)
assert(cmd('awakening',{'fade','2'})and settings.awakening_inner==1,'out of range rejected')
assert(cmd('awakening',{'fade','0.5','x'})and settings.awakening_outer==.4,'bad outer rejected')
assert(cmd('awakening',{'fade'})and settings.awakening_inner==1,'missing inner rejected')
assert(cmd('awakening',{'size','1.4'})and settings.awakening_size==1.4)
assert(cmd('awakening',{'size','9'})and settings.awakening_size==1.4)
assert(cmd('awakening',{'opacity','0.5'})and settings.awakening_opacity==.5,'opacity still works')
assert(cmd('awakening',{'off'})and settings.awakening==false,'toggle still works')
assert(cmd('preset',{'killala'})and settings.awakening_outer==1 and settings.awakening_size==1)
assert(cmd('preset',{'default'})and settings.awakening_inner==1 and settings.awakening_outer==0)
print('PASS Test3.5 awakening fade (center/edge multipliers, outer default 0), size, fallback alpha, killala')
