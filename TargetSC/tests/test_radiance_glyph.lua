-- Test6.9: Radiance floor glyph `circle off` (flat native 3D glyph, no ring)
-- and `wobble always` (keeps moving through the MB window and exit fade).
-- Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function link(o)return P.new(P.parse({'Radiance','4'},R),71,0,R,o)end
local function at(p,t,o)p:advance(t)return p.model:frame(71,t,2,4,o)end
local function gdisc(f)for _,d in ipairs(f.discs)do if d.role=='mb-glyph'then return d end end end
local function g3(f)for _,g in ipairs(f.glyphs3 or {})do if g.role=='mb-glyph'then return g end end end
R.native_level=12
local o=copy(R.defaults)
assert(o.radiance_glyph_circle==true and o.radiance_glyph_wobble=='rings','defaults')
-- Default: the 2D disc glyph (with its circle), no 3D glyph.
local times={1,2.5,5,7,9.25}
for _,t in ipairs(times)do
    local f=at(link(o),t,o)
    assert(gdisc(f)and not g3(f),'default disc glyph at '..t)
end
-- Circle off: the same glyph as a flat 3D glyph without a circle.
local off=copy(o);off.radiance_glyph_circle=false
for _,t in ipairs(times)do
    local a,b=at(link(o),t,o),at(link(off),t,off)
    local d,g=gdisc(a),g3(b)
    assert(not gdisc(b)and g,'3D glyph at '..t)
    assert(g.circle==false and not g.tilt and not g.stand and not g.sink,'flat, no circle')
    near(g.radius,d.radius,1e-9,'radius');near(g.offset,d.offset,1e-9,'offset');near(g.rotation,d.rotation,1e-9,'rotation')
    assert(g.color==d.outline,'same color and alpha at '..t)
    assert(#b.discs==#a.discs-1,'nothing else changes')
end
-- Older DLLs fall back to the disc (circle stays).
R.native_level=10
assert(gdisc(at(link(off),2.5,off))and not g3(at(link(off),2.5,off)),'native 0.10 fallback')
R.native_level=12
-- Other chains and Umbra are untouched.
local um=link(off);local st=um.model.states[71];st.properties={'Umbra'};st.elements=R.elements('Umbra')
um:advance(2.5);assert(not g3(um.model:frame(71,2.5,2,4,off)),'Umbra glyph unchanged')
-- Wobble: default freezes once the rings settle; always keeps moving.
local function heights(opts,a,b)
    local hs={}local p=link(opts)
    for t=a,b,.05 do p:advance(t)local f=p.model:frame(71,t,2,4,opts)
        local d=gdisc(f)or g3(f);if d then hs[#hs+1]=d.offset end end
    return hs
end
local function spread(hs)local lo,hi=1e9,-1e9 for _,h in ipairs(hs)do lo=math.min(lo,h)hi=math.max(hi,h)end return hi-lo end
assert(spread(heights(o,4.5,7.5))<1e-6,'default: still after the rings settle')
local wob=copy(o);wob.radiance_glyph_wobble='always'
assert(spread(heights(wob,4.5,7.5))>.004,'always: keeps wobbling in the MB window')
assert(spread(heights(wob,8.3,9.9))>.004,'always: through the ending')
-- Identical before the window opens; no jump at the switch-over.
local a0,b0=heights(o,.05,2.9),heights(wob,.05,2.9)
for i=1,#a0 do near(a0[i],b0[i],1e-9,'same before sc_open')end
local p=link(wob);local last
for t=2.9,3.6,.01 do p:advance(t)local d=gdisc(p.model:frame(71,t,2,4,wob))
    if d and last then assert(math.abs(d.offset-last)<.003,'continuous at '..t)end
    last=d and d.offset or last
end
-- Exit fade (linger/converge keep the glyph past the deadline): still moving.
local cv=copy(wob);cv.mb_ending_style='converge';cv.mb_ending_fade=.8
local s=link(cv).model.states[71]
local hs=heights(cv,s.mb_close+.05,s.mb_close+.7)
assert(#hs>3 and spread(hs)>.0005,'always: through the exit fade')
-- Both together.
local both=copy(off);both.radiance_glyph_wobble='always'
assert(spread((function()local r={}local q=link(both)for t=4.5,7.5,.05 do q:advance(t)local g=g3(q.model:frame(71,t,2,4,both))if g then r[#r+1]=g.offset end end return r end)())>.004,'3D glyph wobbles too')
-- Buzz off still means still unless wobble always.
local still=copy(o);still.radiance_glyph_buzz=false
assert(spread(heights(still,.05,2.9))<1e-9,'buzz off: still')
-- Gather kill: the 3D MB glyph meets the MB ring like the disc does.
local kg=copy(off);kg.kill_mb_rings='gather'
local kp=P.new(P.parse({'kill','mb','Ice'},R),71,0,R,kg)
local ks=kp.model.states[71];ks.properties={'Radiance'};ks.level=4;ks.elements=R.elements('Radiance')
local function kat(t)kp:advance(t)return kp.model:frame(71,t,2,4,kg)end
local kf=kat(1.5+kg.kill_mb_gather+.05)
local kr;for _,v in ipairs(kf)do if v.part=='mb'and v.role=='core'then kr=v end end
assert(g3(kf)and kr,'kill frame has the 3D glyph and the MB ring')
near(g3(kf).offset,kr.offset,1e-9,'3D glyph gathers onto the MB ring')
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('radiance',{'glyph','circle','off'});assert(settings.radiance_glyph_circle==false)
cmd('radiance',{'glyph','circle','on'});assert(settings.radiance_glyph_circle==true)
cmd('radiance',{'glyph','wobble','always'});assert(settings.radiance_glyph_wobble=='always')
cmd('radiance',{'glyph','wobble','x'});assert(settings.radiance_glyph_wobble=='always','rejects')
cmd('radiance',{'glyph','wobble','rings'});assert(settings.radiance_glyph_wobble=='rings')
assert(R.killala.radiance_glyph_circle==true and R.killala.radiance_glyph_wobble=='rings','killala')
print('PASS Test6.9 Radiance glyph: circle off = flat 3D glyph (same size/height/turn/color, no circle; 0.10 fallback; Umbra untouched); wobble always keeps moving through the window, ending and exit fade, identical before sc_open, continuous; buzz off still; commands, presets')
