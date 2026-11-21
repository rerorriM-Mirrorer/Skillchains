-- Test7.3: `umbra ending vanish` (glyph lines and MB glyph shimmer to black
-- and are gone at the ending start; nothing replaces them; no disc flash) and
-- `umbra burst center black`. Uses A's cioara profile. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
R.native_level=12
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor((c or 0)/16777216)end
local function rgb(c)return (c or 0)%16777216 end
local base=copy(R.defaults)for k,v in pairs(dofile('./TargetSC/tests/fixture_cioara.lua'))do base[k]=v end
local o=copy(base);o.umbra_ending='vanish'
local function umbra_link(p)for t=0,p.ends,.05 do p:advance(t)local s=p.model.states[90]if s and s.level==4 and s.step>1 then return s end end end
local function run(opts)local p=P.new(P.parse({'umbra'},R),90,0,R,opts)return p,umbra_link(p)end
local function at(p,t,opts)p:advance(t)return p.model:frame(90,t,2,4,opts)end
local function find(f,role)if f and f.discs then for _,d in ipairs(f.discs)do if d.role==role then return d end end end end
local function count(f,role)local n=0 if f and f.discs then for _,d in ipairs(f.discs)do if d.role==role then n=n+1 end end end return n end
local p,s=run(o)
-- The frame's view of the link: `umbra open time` moves its window opening.
local view=s
if o.umbra_open_time>=0 then local op=s.created+o.umbra_open_time;view=setmetatable({sc_open=op,sc_close=math.max(s.sc_close,op)},{__index=s})end
local a=M.umbra_ending_window(view,o,false)
near(a,M.umbra_flashed(view,o,false),1e-9,'ending when flash = the flash-out')
local T=o.umbra_vanish_time
-- Before: both glyphs visible, same as the gyro profile.
local f0=at(p,a-.05,o)
assert(find(f0,'property-trace')and alpha(find(f0,'property-trace').outline)>0 and find(f0,'mb-glyph')and alpha(find(f0,'mb-glyph').outline)>0,'glyphs visible before')
-- During: dimmer, darker, shimmering.
local lo,hi=255,0
for t=a+.005,a+T-.005,.004 do local f=at(p,t,o);local d=find(f,'property-trace');local x=d and alpha(d.outline)or 0;lo=math.min(lo,x)hi=math.max(hi,x)end
assert(hi<=alpha(find(f0,'property-trace').outline)and lo<hi,'shimmering down '..lo..'..'..hi)
local fm=at(p,a+T*.7,o)
local dm=find(fm,'property-trace')
assert(dm,'still shimmering at .7')
local st=rgb(dm.outline)
assert(math.floor(st/65536)<64 and math.floor(st/256)%256<64 and st%256<64,'turning black '..string.format('%06x',st))
-- After: gone for good; nothing replaces it; the black disc never flashes.
for _,t in ipairs({a+T+.01,a+1,s.mb_close-1,s.mb_close-.1})do
    local f=at(p,t,o)
    local d=find(f,'property-trace');assert(not d or alpha(d.outline)==0,'disc glyph gone at '..t)
    local g=find(f,'mb-glyph');assert(not g or alpha(g.outline)==0,'MB glyph gone at '..t)
    assert(#(f.glyphs3 or {})==0,'no gyro/swallow glyph at '..t)
end
local _,sg=run(base)
for _,t in ipairs({a-.02,a+.02,a+.06,a+.3})do
    local pv,pg=find(at(p,t,o),'property'),find(at(run(base),t,base),'property')
    assert(pv.colors[1]==pg.colors[1],'black disc identical to the gyro profile at '..t)
end
assert(count(at(p,a+1,o),'umbra-copy')>0,'copies keep coming (copies until end)')
assert(find(at(p,a+1,o),'umbra-under'),'under disc stays')
-- Other endings untouched.
local g=copy(base);local pg2,sg2=run(g)
assert(#(at(pg2,a+.5,g).glyphs3 or {})==1,'gyro still works')
-- Burst centers.
local m=copy(o);m.umbra_burst_center='black'
local pm=P.new(P.parse({'mb'},R),91,0,R,m)
local found,other=false,false
for t=0,pm.ends,.05 do pm:advance(t)local sm=pm.model.states[91]
    local f=sm and pm.model:frame(91,t,2,4,m)
    if f and f.discs then for _,d in ipairs(f.discs)do if d.role=='bloom'then
        if sm.properties[1]=='Umbra'then assert(rgb(d.hub)==0 and d.inner==1,'black opaque center');found=true;
            if alpha(d.hub)>=alpha(d.colors[1])then other=true end
            assert(alpha(d.hub)>=alpha(d.colors[1]),'center at least as opaque as the bloom')
        else assert(rgb(d.hub)~=0,'non-Umbra blooms unchanged') end
    end end end end
assert(found and other,'Umbra bursts got black centers')
-- A burst on the Umbra link outside the ending reaches a fully opaque center.
local q=P.new(P.parse({'umbra'},R),93,0,R,m)
q:advance(3)local sq=q.model.states[93]
q.model.bursts=q.model.bursts or {};q.model.bursts[93]={{at=3,color={60,60,200},element='Dark'}}
local peak=0
for t=3,4.5,.02 do q:advance(t)local f=q.model:frame(93,t,2,4,m)local d=find(f,'bloom')if d then peak=math.max(peak,alpha(d.hub))assert(rgb(d.hub)==0 and d.inner==1)end end
assert(peak>=250,'fully opaque at its peak '..peak)
local n=copy(o);local pn=P.new(P.parse({'mb'},R),92,0,R,n)
for t=38.8,39.5,.1 do pn:advance(t)local f=pn.model:frame(92,t,2,4,n)local d=find(f,'bloom')if d then assert(rgb(d.hub)~=0,'normal center by default')end end
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('umbra',{'ending','vanish'});cmd('umbra',{'vanish','time','.2'});cmd('umbra',{'vanish','shimmer','20'});cmd('umbra',{'burst','center','black'})
assert(settings.umbra_ending=='vanish'and settings.umbra_vanish_time==.2 and settings.umbra_vanish_shimmer==20 and settings.umbra_burst_center=='black')
cmd('umbra',{'burst','center','x'});assert(settings.umbra_burst_center=='black','rejects')
assert(R.defaults.umbra_ending=='off'and R.defaults.umbra_burst_center=='normal','defaults unchanged')
print('PASS Test7.3: vanish (A profile): glyphs visible before the flash, shimmer and darken over vanish time, gone after with no replacement, black disc identical to gyro, copies/under stay, gyro unaffected; burst center black opaque on Umbra only, normal by default; commands')
