-- Test7.4: Radiance glow, two white ring-band blooms around the ground rings:
-- ease in from landing to the first ring's flash peak, hold, ease out and
-- drop away (up to the MB deadline), dancing in a figure eight. Uses A's
-- cioara profile. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
R.native_level=12
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor((c or 0)/16777216)end
local base=copy(R.defaults)for k,v in pairs(dofile('./TargetSC/tests/fixture_cioara.lua'))do base[k]=v end
assert(R.defaults.radiance_glow==false and R.killala.radiance_glow==false,'off by default')
local o=copy(base);o.radiance_glow=true
local function link(opts)return P.new(P.parse({'Radiance','4'},R),71,0,R,opts)end
local function at(opts,t)local p=link(opts)p:advance(t)return p.model:frame(71,t,2,4,opts),p.model.states[71]end
local function glows(f)local r={}if f and f.discs then for _,d in ipairs(f.discs)do if d.role=='radiance-glow'then r[#r+1]=d end end end return r end
assert(#glows(at(base,3))==0,'nothing with glow off')
local _,s=at(o,0)
local view=s
if o.radiance_open_time>=0 then local op=s.created+o.radiance_open_time;view=setmetatable({sc_open=op,sc_close=math.max(s.sc_close,op)},{__index=s})end
local env0,peak=M.radiance_glow_envelope(view,s.created,o)
near(peak,view.sc_open+.3*o.radiance_lead,1e-9,'peak = first ring flash peak')
-- Envelope: clear at landing, slow ease-in, rush to full, hold, ease out, drop.
local function env(t)return (M.radiance_glow_envelope(view,t,o))end
near(env(s.created),0,1e-9,'clear at landing')
local half=s.created+(peak-s.created)*.5
assert(env(half)<.2,'still faint halfway '..env(half))
assert(env(peak-(peak-s.created)*.1)>.6,'rushing up near the peak')
near(env(peak),1,1e-9,'full at the flash');near(env(peak+o.radiance_glow_hold*.9),1,1e-9,'holds')
local f1=env(peak+o.radiance_glow_hold+o.radiance_glow_fall*.3)
local f2=env(peak+o.radiance_glow_hold+o.radiance_glow_fall*.9)
assert(f1>.9 and f2<.35,'eases out then drops '..f1..' '..f2)
near(env(peak+o.radiance_glow_hold+o.radiance_glow_fall+.01),0,1e-9,'gone after the fall')
-- Frames: two white ring-band discs around the ground rings at the peak.
local f=at(o,peak)
local g=glows(f)
assert(#g==2,'two glows')
for _,d in ipairs(g)do
    assert(d.colors[1]%16777216==0xFFFFFF,'white')
    assert(d.inner==o.mb_bloom_center and d.outer==o.mb_bloom_edge and d.mid==o.mb_bloom_middle and d.mid_pos==o.mb_bloom_position,'MB bloom ring band')
    near(alpha(d.colors[1]),o.radiance_glow_opacity*255,1.01,'peak opacity')
end
local ground;for _,v in ipairs(f)do if v.part=='ground'then ground=v.offset break end end
-- Figure eight: size ~ cos(theta), height ~ sin(2 theta), a quarter cycle apart.
local rr={}
for _,t in ipairs({peak-.2,peak,peak+.2})do
    local fr=at(o,t);local gg=glows(fr)
    local gh;for _,v in ipairs(fr)do if v.part=='ground'then gh=v.offset break end end
    local theta=2*math.pi*o.radiance_glow_speed*(t-s.created)
    for k=0,1 do
        local phi=theta+k*math.pi/2
        local d=gg[k+1]
        near(d.radius,2*o.radiance_glow_size*(1+o.radiance_glow_dance*math.cos(phi)),1e-6,'size dance')
        near(d.offset,gh+o.radiance_glow_dance*2*.08*math.sin(2*phi),.03,'height dance around the ground rings')
    end
    near(gg[1].offset-gg[2].offset,o.radiance_glow_dance*2*.08*(math.sin(2*theta)-math.sin(2*(theta+math.pi/2))),1e-9,'height difference = figure eight')
    assert(math.abs(gg[1].radius-gg[2].radius)>1e-6 or math.abs(gg[1].offset-gg[2].offset)>1e-6,'they differ (weave)')
end
-- Long fall lingers through the MB window and ends at the deadline.
local long=copy(o);long.radiance_glow_fall=30
local lv=M.radiance_glow_envelope(view,s.mb_close-1,long)
assert(lv>.5,'lingers in the MB window '..lv)
assert(#glows(at(long,s.mb_close+.05))==0,'gone at the deadline')
-- Hold and rise settings.
local h=copy(o);h.radiance_glow_hold=2
near(M.radiance_glow_envelope(view,peak+1.9,h),1,1e-9,'hold 2')
local r=copy(o);r.radiance_glow_rise=.5
near(M.radiance_glow_envelope(view,peak-.6,r),0,1e-9,'rise .5: clear before')
assert(M.radiance_glow_envelope(view,peak-.25,r)>0,'rise .5: rising')
-- Umbra and other chains: nothing.
local up=link(o);local us=up.model.states[71];us.properties={'Umbra'};us.elements=R.elements('Umbra')
up:advance(3);assert(#glows(up.model:frame(71,3,2,4,o))==0,'Umbra: no Radiance glow')
-- Demo path plays.
local d=P.new(P.parse({'mb','radiance'},R),95,0,R,o);local seen=0
for t=0,d.ends,.05 do d:advance(t)local fr=d.model:frame(95,t,2,4,o)seen=seen+#glows(fr)assert(not fr or not fr.discs or #fr.discs<=16)end
assert(seen>0,'appears in preview mb radiance')
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('radiance',{'glow','on'});cmd('radiance',{'glow','hold','1'});cmd('radiance',{'glow','fall','6'});cmd('radiance',{'glow','rise','2'})
cmd('radiance',{'glow','dance','.15'});cmd('radiance',{'glow','speed','.8'});cmd('radiance',{'glow','size','1.5'});cmd('radiance',{'glow','opacity','.7'})
assert(settings.radiance_glow and settings.radiance_glow_hold==1 and settings.radiance_glow_fall==6 and settings.radiance_glow_rise==2)
assert(settings.radiance_glow_dance==.15 and settings.radiance_glow_speed==.8 and settings.radiance_glow_size==1.5 and settings.radiance_glow_opacity==.7)
cmd('radiance',{'glow','dance','3'});assert(settings.radiance_glow_dance==.15,'rejects')
print('PASS Test7.4 Radiance glow (A profile): peak at the first ring flash, clear at landing, slow ease-in then rush, hold, ease out then drop, two white MB-bloom ring bands, figure-eight dance a quarter cycle apart, long fall lingers to the deadline, hold/rise settings, Radiance only, demo path, commands')
