-- Test12 (2026-11-16): large glyph rises to just above the MB ring, stays
-- white, lands with the property trace, never dips on a re-strike; quieter
-- intro flash on the large glyph; gradient two-element discs; killala preset.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local B=require('resonance_burst')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-7),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function layer(f,role)for _,v in ipairs(f.discs)do if v.role==role then return v end end end
local function ring(f,part)for _,v in ipairs(f)do if v.part==part and v.role=='core'then return v end end end
local function rgb(c)return c%16777216 end
local function alpha(c)return math.floor(c/16777216)end
local s={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,
 step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}
local function model()local m=R.new();m.states[71]=copy(s);return m end
local o=copy(R.defaults);o.mb_intro=0;o.mb_ending_style='off'
local hit=model();hit.bursts[71]={{at=104,color=R.element_color('Fire')}}
local plain=model()
local rest=o.disc_height
local mb=assert(ring(plain:frame(71,104,2,4,o),'mb'),'steady MB ring present')
local peak=rest+(mb.offset-rest)*o.mb_glyph_height
assert(peak>mb.offset,'default peak sits slightly above the MB ring')
-- Rise ramp, hold at peak, then land together with the lifted trace.
local start=layer(hit:frame(71,104,2,4,o),'mb-glyph')
near(start.offset,rest,1e-9,'starts at rest (ramp)')
local previous=rest
for _,t in ipairs({104.03,104.08,104.15,104.3,104.6,105.1,105.6,106.1,106.6,107})do
 local f=hit:frame(71,t,2,4,o);local base=plain:frame(71,t,2,4,o)
 local glyph=assert(layer(f,'mb-glyph'))
 local energy=B.return_energy(t-104,.6,2)
 local ramp=math.min(1,(t-104)/o.mb_glyph_rise);ramp=ramp*ramp*(3-2*ramp)
 near(glyph.offset,rest+(peak-rest)*energy*ramp,1e-7,'glyph height at '..t)
 if t>=104.15 then
  local trace=layer(f,'property-trace');local trace_base=layer(base,'property-trace')
  local trace_share=(trace.offset-trace_base.offset)/o.mb_lift
  near((glyph.offset-rest)/(peak-rest),trace_share,1e-7,'lands with trace at '..t)
 end
 assert(rgb(glyph.outline)==0xFFFFFF,'large glyph stays white at '..t)
 if t<=104.6 then assert(glyph.offset>=previous-1e-12,'monotone rise/hold')end
 previous=glyph.offset
end
-- Re-strike while aloft: continues from its height, no drop to the floor.
hit.bursts[71][#hit.bursts[71]+1]={at=105.1,color=R.element_color('Wind')}
local before=layer(hit:frame(71,105.0999,2,4,o),'mb-glyph').offset
for _,t in ipairs({105.1,105.12,105.16,105.3})do
 local now=layer(hit:frame(71,t,2,4,o),'mb-glyph').offset
 assert(now>=before-1e-6,'re-strike never dips: '..t)
 before=now
end
near(layer(hit:frame(71,105.3,2,4,o),'mb-glyph').offset,peak,1e-9,'re-strike returns to peak')
-- Tint 1 recovers the elemental glyph; height 0 recovers the old rise.
local tinted=copy(o);tinted.mb_glyph_tint=1
assert(rgb(layer(hit:frame(71,105.3,2,4,tinted),'mb-glyph').outline)~=0xFFFFFF,'tint 1 colors the glyph')
local old=copy(o);old.mb_glyph_height=0
near(layer(hit:frame(71,105.3,2,4,old),'mb-glyph').offset,rest+4*o.mb_rise,1e-9,'height 0 = legacy mb rise')
-- Intro: the large glyph flashes at mb_intro_glyph of the disc strength.
local intro=copy(R.defaults);intro.mb_ending_style='off';intro.mb_idle=0
local fresh=model()
local f=fresh:frame(71,100.05,2,4,intro)
local glyph=layer(f,'mb-glyph');local full=copy(intro);full.mb_intro_glyph=1
local glyph_full=layer(fresh:frame(71,100.05,2,4,full),'mb-glyph')
assert(alpha(glyph.outline)<alpha(glyph_full.outline),'intro glyph is dimmer than before')
near(alpha(glyph.outline),alpha(glyph_full.outline)*intro.mb_intro_glyph,1.01,'intro glyph strength scales')
-- Gradient flag for two-element property discs only; split restores halves.
local disc=layer(plain:frame(71,104,2,4,o),'property')
assert(#disc.colors==2 and disc.blend==1,'Fusion disc blends')
local split=copy(o);split.disc_blend='split'
assert(layer(plain:frame(71,104,2,4,split),'property').blend==0,'split keeps halves')
assert(layer(plain:frame(71,104,2,4,o),'mb-glyph').blend==0,'single-color glyph never blends')
-- ARGB midpoint used by the 0.5.0 DLL fallback.
assert(R.mix_argb(0xFF0000FF,0x00FF0000)==0x80800080)
-- Commands and presets.
local saved,said=0,{}
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()saved=saved+1 end,function(t)said[#said+1]=t end,R.killala)
assert(cmd('mb',{'glyph','height','1.3'})and settings.mb_glyph_height==1.3)
assert(cmd('mb',{'glyph','tint','0.4'})and settings.mb_glyph_tint==.4)
assert(cmd('mb',{'glyph','rise','0'})and settings.mb_glyph_rise==0)
assert(cmd('mb',{'glyph','height','9'})and settings.mb_glyph_height==1.3,'out of range rejected')
assert(cmd('mb',{'intro','glyph','0.2'})and settings.mb_intro_glyph==.2)
assert(cmd('mb',{'intro','disc','0.7'})and settings.mb_intro_disc==.7)
assert(cmd('mb',{'intro','flashes','2'})and settings.mb_intro_flashes==2,'flashes still works')
assert(cmd('mb',{'intro','0.3'})and settings.mb_intro==.3,'intro duration still works')
assert(cmd('discs',{'blend','split'})and settings.disc_blend=='split')
assert(cmd('discs',{'blend','rainbow'})and settings.disc_blend=='split')
assert(cmd('preset',{'killala'}))
for k,v in pairs(R.defaults)do
 local want=R.killala[k];if want==nil then want=v end
 assert(settings[k]==want,'killala '..k)
end
assert(settings.mb_glyph_height==0 and settings.disc_blend=='split')
assert(cmd('preset',{'default'})and settings.mb_glyph_height==1.1 and settings.disc_blend=='gradient')
print('PASS Test12 glyph rise to MB ring, white glyph, synced landing, re-strike continuity, intro glyph, gradient discs, killala preset')
