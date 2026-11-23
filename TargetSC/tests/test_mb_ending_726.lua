-- Test7.26: MB ending glyph ring (the large MB glyph stays at the MB ring's
-- height, lit only by bursts), the property glyph meeting the descending
-- ring (grows to its size, final opacity/shimmer gain/half-width), and the
-- Umbra glyph shimmer (wide before the flash, narrow after, own spins).
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<=(e or 1e-6),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor((c or 0)/16777216)end
local d=R.defaults
assert(d.mb_ending_glyph=='ring'and d.glyph_meet==true and d.glyph_meet_opacity==1 and d.glyph_meet_gain==1 and d.glyph_meet_width==15,'meet defaults')
assert(d.umbra_glyph_shimmer==true and d.umbra_glyph_shimmer_before==180 and d.umbra_glyph_shimmer_after==15
    and d.umbra_glyph_shimmer_spin_before==1 and d.umbra_glyph_shimmer_spin_after==1,'umbra shimmer defaults')
local function link(prop,level)return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=level,
    properties={prop},elements=R.elements(prop)}end
local function model(s,bursts)R.native_level=15;local m=R.new();m.states[71]=copy(s);if bursts then m.bursts[71]=bursts end return m end
local function role(f,name)for _,x in ipairs(f and f.discs or {})do if x.role==name then return x end end end
local function mbring(f)for _,v in ipairs(f or {})do if v.part=='mb'and v.role=='core'then return v end end end

for _,ending in ipairs({'converge','soft'})do
    local o=copy(d);o.mb_style='clapper';o.mb_ending_style=ending;o.mb_ending=2;o.mb_ending_fade=.8
    -- MB glyph: hidden with no burst, through the ending too (no whitening).
    for _,t in ipairs({105,108.5,109.5,109.95})do
        local g=role(model(link('Scission',1)):frame(71,t,2,4,o),'mb-glyph')
        assert(not g or alpha(g.outline)==0,ending..' MB glyph clear without a burst at '..t)
    end
    -- A burst in the ending lights it at the descending ring's height.
    local f=model(link('Scission',1),{{at=109,color=R.element_color('Fire')}}):frame(71,109.2,2,4,o)
    local g,ring=role(f,'mb-glyph'),mbring(f)
    assert(g and alpha(g.outline)>0 and ring,ending..' burst lights the MB glyph')
    near(g.offset,ring.offset,1e-6,ending..' MB glyph at the ring height in the ending')
    local fb=model(link('Scission',1),{{at=105,color=R.element_color('Fire')}}):frame(71,105.2,2,4,o)
    near(role(fb,'mb-glyph').offset,mbring(fb).offset,1e-6,ending..' MB glyph at the ring height in the window')
    -- Glyph meet: the property glyph grows to the ring radius and brightens.
    local base=role(model(link('Scission',1)):frame(71,107.9,2,4,o),'property-trace')
    local prev=base.radius
    for _,p in ipairs({.25,.5,.75})do
        local fp=model(link('Scission',1)):frame(71,108+2*p,2,4,o)
        local t,r=role(fp,'property-trace'),mbring(fp)
        near(t.radius,base.radius+(r.radius-base.radius)*p,1e-6,ending..' grows toward the ring p='..p)
        assert(t.radius>prev,ending..' growing');prev=t.radius
        assert(t.shimmer,ending..' shimmer on the meeting glyph')
        near(t.shimmer.gain,.8+(1-.8)*p,1e-6,ending..' gain toward the meet gain')
        near(t.shimmer.width,math.rad(70)+(math.rad(15)-math.rad(70))*p,1e-6,ending..' width toward the meet width')
    end
    -- Touchdown (the soft ending's frame ends just before the deadline).
    local touch=ending=='soft'and 109.98 or 109.99
    local fe=model(link('Scission',1)):frame(71,touch,2,4,o)
    local te=role(fe,'property-trace')
    near(te.radius,mbring(fe).radius,.01,ending..' meets the ring')
    assert(alpha(te.outline)>=245,ending..' final opacity 1 at touchdown '..alpha(te.outline))
    local half=copy(o);half.glyph_meet_opacity=.5;half.glyph_meet_gain=.5;half.glyph_meet_width=40
    local th=role(model(link('Scission',1)):frame(71,touch,2,4,half),'property-trace')
    assert(math.abs(alpha(th.outline)-128)<=4,ending..' final opacity .5');near(th.shimmer.gain,.5,.02);near(th.shimmer.width,math.rad(40),.02)
    if ending=='converge'then
        local ta=role(model(link('Scission',1)):frame(71,110.4,2,4,o),'property-trace')
        assert(ta and alpha(ta.outline)>0 and alpha(ta.outline)<250,'converge: fades with the ring after the deadline')
    end
    -- Off / converge glyph: the property glyph keeps its size.
    local off=copy(o);off.glyph_meet=false
    near(role(model(link('Scission',1)):frame(71,109.5,2,4,off),'property-trace').radius,base.radius,1e-9,ending..' meet off')
    local cv=copy(o);cv.mb_ending_glyph='converge'
    near(role(model(link('Scission',1)):frame(71,109.5,2,4,cv),'property-trace').radius,base.radius,1e-9,ending..' converge glyph: no meet')
end

-- Umbra glyph shimmer (A's cioara profile, umbra ending vanish).
do
    local o=copy(d)for k,v in pairs(dofile('./TargetSC/tests/fixture_cioara.lua'))do o[k]=v end
    o.umbra_ending='vanish';o.umbra_glyph_shimmer_spin_after=3
    R.native_level=15
    local p=P.new(P.parse({'umbra'},R),90,0,R,o)
    local s
    for t=0,p.ends,.05 do p:advance(t)local x=p.model.states[90]if x and x.level==4 and x.step>1 then s=x break end end
    assert(s,'umbra link')
    local view=s
    if o.umbra_open_time>=0 then local op=s.created+o.umbra_open_time;view=setmetatable({sc_open=op,sc_close=math.max(s.sc_close,op)},{__index=s})end
    local fl=M.umbra_flashed(view,o,false)
    local function trace(t)p:advance(t)return role(p.model:frame(90,t,2,4,o),'property-trace')end
    local before=trace(fl-.05)
    assert(before and before.shimmer,'shimmer before the flash');near(before.shimmer.width,math.pi,1e-6,'180 before')
    local after=trace(fl+o.umbra_vanish_time+.3)
    assert(after and alpha(after.outline)>0,'still visible after the vanish time')
    near(after.shimmer.width,math.rad(15),1e-6,'15 after')
    -- After the flash it turns at the "after" spin from where it was.
    local a1,a2=trace(fl+.5).shimmer.angle,trace(fl+.7).shimmer.angle
    local r1,r2=M.disc_rotation(s,fl+.5,o),M.disc_rotation(s,fl+.7,o)
    near(a2-a1,3*(r2-r1),1e-6,'after spin x3')
    local off=copy(o);off.umbra_glyph_shimmer=false
    p:advance(fl+o.umbra_vanish_time+.3)
    local g=role(p.model:frame(90,fl+o.umbra_vanish_time+.3,2,4,off),'property-trace')
    assert(not g or alpha(g.outline)==0,'off: vanishes as before')
end

-- Commands.
do
    local s=copy(d);local said={}
    local cmd=C.new(s,d,function()end,function(m)said[#said+1]=m end)
    assert(cmd('mb',{'ending','glyph','converge'})and s.mb_ending_glyph=='converge')
    assert(cmd('mb',{'ending','glyph','ring'})and s.mb_ending_glyph=='ring')
    assert(cmd('glyph',{'meet','off'})and s.glyph_meet==false);assert(cmd('glyph',{'meet','on'})and s.glyph_meet==true)
    assert(cmd('glyph',{'meet','opacity','.7'})and s.glyph_meet_opacity==.7)
    assert(cmd('glyph',{'meet','gain','.9'})and s.glyph_meet_gain==.9)
    assert(cmd('glyph',{'meet','width','25'})and s.glyph_meet_width==25)
    assert(cmd('umbra',{'glyph','shimmer','off'})and s.umbra_glyph_shimmer==false)
    assert(cmd('umbra',{'glyph','shimmer','on'})and s.umbra_glyph_shimmer==true)
    assert(cmd('umbra',{'glyph','shimmer','before','120'})and s.umbra_glyph_shimmer_before==120)
    assert(cmd('umbra',{'glyph','shimmer','after','10'})and s.umbra_glyph_shimmer_after==10)
    assert(cmd('umbra',{'glyph','shimmer','spin','before','-1'})and s.umbra_glyph_shimmer_spin_before==-1)
    assert(cmd('umbra',{'glyph','shimmer','spin','after','2'})and s.umbra_glyph_shimmer_spin_after==2)
    assert(cmd('umbra',{'glyph','breath'}),'other umbra glyph commands still route')
    for _,m in ipairs(said)do assert(not m:find('[\128-\255]'),'ASCII chat')end
end
print('PASS Test7.26 MB ending glyph ring (clear without bursts, at the ring height), glyph meet (grows to the ring, final opacity/gain/width, fades with it), Umbra glyph shimmer (180 before, 15 after, own spins), commands')
