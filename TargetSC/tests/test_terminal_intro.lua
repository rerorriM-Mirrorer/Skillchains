-- Test9: native draw descriptors, source receiver and local previews.
-- Host simulation only: no DLL or live FFXI rendering.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local Burst=require('resonance_burst')
local Controls=require('resonance_controls')
local Preview=require('resonance_preview')
local function copy(t)local o={}for k,v in pairs(t)do o[k]=v end return o end
local function near(a,b)assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function layer(f,role,part)
 for _,v in ipairs(part and f or f.discs or {})do if v.role==role and(not part or v.part==part)then return v end end
end
local function state(p)
 local level=R.level(p)
 return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,
  step=level==4 and 5 or 2,level=level,closed=level==4,properties={p},elements=R.elements(p)}
end
local function frame(s,t,o)
 local m=R.new();m.states[71]=s;return m:frame(71,t,2,4,o or R.defaults)
end
local opts=copy(R.defaults);opts.mb_overall=.6;opts.disc_outline=.6
opts.mb_style='classic';opts.ground_lift=0
local envelope=state('Fusion')
near(Burst.introduction(envelope,100.03,.24,2),1)
near(Burst.introduction(envelope,100.11,.24,2),0)
near(Burst.introduction(envelope,100.15,.24,2),1)
near(Burst.introduction(envelope,100.23,.24,2),0)
for _,p in ipairs({'Radiance','Umbra'})do
 local s=state(p);local f=frame(s,101,opts)
 local fill=assert(layer(f,'property'));local trace=assert(layer(f,'property-trace'))
 local large=assert(layer(f,'mb-glyph'))
 near(fill.radius,2*.92);near(trace.radius,fill.radius)
 assert(trace.radius<large.radius and trace.radius>large.radius*.95)
 near(trace.offset-fill.offset,.006);near(trace.rotation,fill.rotation);near(trace.rotation,0)
 assert(fill.glyph==0 and trace.glyph==2 and alpha(trace.color)==0)
 assert(fill.color%16777216==(p=='Umbra'and 0 or 16777215))
 assert(trace.outline%16777216==(p=='Umbra'and 16773836 or 0)) -- #fff2cc / black
 assert(alpha(trace.outline)==math.floor(opts.disc_outline*opts.opacity*255+.5))
 -- Trace must be submitted after its fill; larger glyph was already submitted.
 local fill_index,trace_index
 for i,d in ipairs(f.discs)do if d==fill then fill_index=i elseif d==trace then trace_index=i end end
 assert(fill_index<trace_index)
 for _,mode in ipairs({'sc','mb','both'})do
  local o=copy(opts);o.display=mode
  assert(layer(frame(s,101,o),'property-trace'))
 end
 local o=copy(opts);o.disc_style='fill'
 assert(layer(frame(s,101,o),'property')and not layer(frame(s,101,o),'property-trace'))
 o.disc_style='outline'
 assert(not layer(frame(s,101,o),'property')and layer(frame(s,101,o),'property-trace'))
 assert(not layer(frame(s,110,opts),'property-trace'))
end
-- One or two shared full-white introductions, capped by MB master opacity.
for _,p in ipairs({'Liquefaction','Fusion','Darkness','Radiance','Umbra'})do
 local s=state(p)
 for _,mode in ipairs({'both','mb'})do
  local o=copy(opts);o.display=mode;o.mb_idle=0
  for _,flashes in ipairs({1,2})do
   o.mb_intro_flashes=flashes
   for n=0,flashes-1 do
    local t=100+n*o.mb_intro/flashes+1e-9
    local f=frame(s,t,o)
    local fill=assert(layer(f,'property'));local trace=layer(f,'property-trace')or fill
    local large=assert(layer(f,'mb-glyph'));local ring=assert(layer(f,'core','mb'))
    for _,v in ipairs({fill.color,trace.outline,large.outline,ring.color})do
     assert(v%16777216==16777215,'all three intro layers share white')
     assert(alpha(v)==153,'full intro is capped by .6 master, not idle/global opacity')
    end
    near(Burst.introduction(s,t,o.mb_intro,flashes),1)
   end
   local after=frame(s,100+o.mb_intro+.01,o)
   assert(not layer(after,'mb-glyph'),'idle zero returns to hidden after intro')
   near(Burst.introduction(s,100+o.mb_intro+.01,o.mb_intro,flashes),0)
  end
 end
 -- SC-only and master/effects off must not invent MB flashes.
 local o=copy(opts);o.display='sc'
 local comparison=copy(o);comparison.mb_intro=0
 assert(layer(frame(s,100,o),'property').color==layer(frame(s,100,comparison),'property').color)
 assert(not layer(frame(s,100,o),'mb-glyph'))
 o=copy(opts);o.mb_overall=0
 assert(not layer(frame(s,100,o),'mb-glyph')and not layer(frame(s,100,o),'core','mb'))
 o=copy(opts);o.mb_effects=0;o.mb_idle=0
 assert(not layer(frame(s,100,o),'mb-glyph'))
 near(s.sc_open,103);near(s.sc_close,108);near(s.mb_close,110)
end
-- A new live source state flashes; a fresh snapshot of the SAME state does not.
local function receiver(snapshot)
 local m=R.new();assert(m:receive({'1','test9','1','online','100'},100))
 assert(m:receive({'1','test9','2','state','100','71','2','100','103','108','110','2','2','0','Fusion','Light,Fire',snapshot and '1'or '0'},100))
 return m
end
local fresh=receiver(false):frame(71,100,2,4,opts)
assert(alpha(layer(fresh,'core','mb').color)==153)
local snapshot=receiver(true):frame(71,100,2,4,opts)
assert(alpha(layer(snapshot,'core','mb').color)==math.floor(.39*.6*255+.5))
assert(not layer(snapshot,'mb-glyph'))
local switching=receiver(false)
switching:frame(71,101,2,4,opts)
local pooled=switching.awakening_glyphs[71]
assert(switching:receive({'1','test9','3','state','105','71','3','105','108','113','115','3','2','0','Distortion','Water,Ice','0'},105))
local changed=switching:frame(71,105,2,4,opts)
assert(switching.awakening_glyphs[71]==pooled and alpha(layer(changed,'core','mb').color)==153)
assert(layer(changed,'property').color%16777216==16777215)
assert(alpha(layer(changed,'mb-glyph').outline)==153)
local settled=switching:frame(71,105.25,2,4,opts)
assert(layer(settled,'core','mb').color%16777216==R.argb(R.element_color('Ice'),0))
assert(switching.states[71].mb_close==115)
local opener=state('Liquefaction');opener.step=1;opener.mb_close=0
near(Burst.introduction(opener,100,.24,2),0)
-- Preview chains use the same timing without changing transport/source clocks.
local preview=Preview.new(assert(Preview.parse({'demo'},R)),71,200,R,opts)
preview:advance(209)
assert(alpha(layer(preview.model:frame(71,209,2,4,opts),'core','mb').color)==153)
assert(preview.model.states[71].mb_close==219)
-- Integer flash count, duration validation and independent saved settings.
local saved=0;local o=copy(opts)
local control=Controls.new(o,R.defaults,function()saved=saved+1 end,function()end)
control('mb',{'intro','.3'});control('mb',{'intro','flashes','1'})
assert(saved==2 and o.mb_intro==.3 and o.mb_intro_flashes==1)
for _,v in ipairs({'0','3','1.5','nan'})do control('mb',{'intro','flashes',v})end
control('mb',{'intro','nan'});control('mb',{'intro','.7'});assert(saved==2)
control('mb',{'intro','0'});assert(saved==3 and o.mb_intro==0)
print('PASS Test9 lifted contrasting terminal stars, matched larger radii, draw order/styles, shared white MB introductions, master caps, live/snapshot/preview handling and saved controls')
