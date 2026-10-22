-- Test11: actual Killala defaults, layered bloom, signed descent shaping.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local M=require('resonance_motion')
local B=require('resonance_burst')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b)assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b))end
local function layer(f,role)for _,v in ipairs(f.discs)do if v.role==role then return v end end end
local function alpha(c)return math.floor(c/16777216)end
local expected={opacity=.27,height=.66,intensity=.3,disc_outline=.6,disc_slowdown=3,
 disc_speed_opener=4,disc_speed_level1=2,disc_speed_level2=3,ground_height=.3,
 mb_breath_gain=3,mb_burst=.6,mb_duration=.9,mb_ending=2,mb_expand=0,
 mb_hold=.6,mb_idle=.1,mb_intro=.6,mb_intro_flashes=1,mb_lift=.3,
 mb_overall=.66,mb_return=2,mb_rise=.01,sky_curve=3,sky_cutoff=.5,
 sky_expand=.39,sky_hold=.3,sky_descent=0,display='both'}
for k,v in pairs(expected)do assert(R.defaults[k]==v,'snapshot default '..k)end
local s={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,
 step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}
local function model()local m=R.new();m.states[71]=copy(s);return m end
local o=copy(R.defaults);o.mb_expand=.4;o.mb_rise=.2;o.mb_intro=0;o.mb_ending_style='off'
local hit=model();hit.bursts[71]={{at=104,color=R.element_color('Fire')}}
local plain=model()
for _,t in ipairs({104,104.3,104.6,105.1,105.6,106.1,106.6,106.61,107})do
 local f=hit:frame(71,t,2,4,o);local base=plain:frame(71,t,2,4,o)
 local glyph=assert(layer(f,'mb-glyph'));local original=assert(layer(base,'mb-glyph'))
 local energy=B.return_energy(t-104,.6,2)
 near(glyph.radius,original.radius*(1+o.mb_expand*energy))
 near(glyph.offset,o.disc_height+4*o.mb_rise*energy)
 near(glyph.rotation,original.rotation)
 local strike=energy*(1+(o.mb_burst-1)*(1-energy))
 local option=function(k)return o[k]end
 local breath=B.sample(plain,plain.states[71],t,option).idle
 assert(alpha(glyph.outline)==math.floor((breath+(1-breath)*strike)*o.mb_overall*255+.5))
 local trace=assert(layer(f,'property-trace'));local trace_base=assert(layer(base,'property-trace'))
 near(trace.offset-trace_base.offset,o.mb_lift*energy)
 if energy==0 then assert(glyph.outline==original.outline,'breathing continues with no recovery fade')end
end
-- Repeated hits reach the peak, without an invisible-to-floor reset. A new
-- property updates the underlying palette while the common return continues.
hit.bursts[71][#hit.bursts[71]+1]={at=105.6,color=R.element_color('Wind')}
local peak=layer(hit:frame(71,105.6,2,4,o),'mb-glyph')
near(peak.offset,o.disc_height+4*o.mb_rise)
local prior=hit.states[71];local next=copy(prior);next.created=105.8;next.sc_open=108.8;next.sc_close=112;next.mb_close=115.8
next.properties={'Distortion'};next.level=2;next.step=3;next.revision=3;next.previous=prior;hit.states[71]=next
near(layer(hit:frame(71,106.1,2,4,o),'mb-glyph').offset,o.disc_height+4*o.mb_rise)
-- Master/effects off and SC-only do not add MB motion; floor response may be
-- disabled independently without disabling the large glyph's bloom.
for _,key in ipairs({'mb_overall','mb_effects','mb_burst'})do
 local muted=copy(o);muted[key]=0
 near(layer(hit:frame(71,106.1,2,4,muted),'mb-glyph')and hit.awakening_glyphs[71].offset or o.disc_height,o.disc_height)
end
local floor=copy(o);floor.mb_floor=0
near(layer(hit:frame(71,106.1,2,4,floor),'mb-glyph').offset,o.disc_height+4*o.mb_rise)
-- Shape only descent after the hold. Preserve current held/no-hold formulas
-- exactly at 0, monotonic bounds, both source endpoints and short windows.
for _,hold in ipairs({0,.3,2})do
 for _,duration in ipairs({.1,.3,5})do
  local state=copy(s);state.sc_close=state.sc_open+duration
  local held=hold>0 and math.min(hold+.15,math.max(0,duration-.1))or 0
  local previous={}
  for i=0,1000 do
   local t=state.sc_open+duration*i/1000
   local samples={}
   for _,curve in ipairs({-4,-1,0,1,4})do
    local opts=copy(o);opts.sky_hold=hold;opts.sky_descent=curve
    local v=M.descent_remaining(state,t,opts);assert(v>=0 and v<=1)
    if previous[curve]then assert(v<=previous[curve]+1e-12)end
    previous[curve]=v;samples[curve]=v
    if t<=state.sc_open+held then near(v,1)end
   end
   local u=math.max(0,math.min(1,(t-state.sc_open-held)/math.max(.1,duration-held)))
   near(samples[0],1-(hold>0 and u*u*(3-2*u)or u))
   assert(samples[4]<=samples[1]+1e-12 and samples[1]<=samples[0]+1e-12)
   assert(samples[0]<=samples[-1]+1e-12 and samples[-1]<=samples[-4]+1e-12)
  end
  for _,curve in ipairs({-4,-1,0,1,4})do
   local opts=copy(o);opts.sky_hold=hold;opts.sky_descent=curve
   near(M.descent_remaining(state,state.sc_open,opts),1)
   near(M.descent_remaining(state,state.sc_close,opts),0)
  end
 end
end
local saved=0;local settings=copy(o)
local control=C.new(settings,R.defaults,function()saved=saved+1 end,function()end)
for _,v in ipairs({'-4','-1','0','1','4'})do control('sky',{'descent',v})end
assert(saved==5 and settings.sky_descent==4)
for _,v in ipairs({'-4.1','4.1','nan','inf'})do control('sky',{'descent',v})end
assert(saved==5)
near(s.sc_open,103);near(s.sc_close,108);near(s.mb_close,110)
print('PASS Test11 Killala defaults, immediate full bloom/lift, shared return/breath/rotation, repeated hits, property transitions, suppression, signed descent bounds/hold/endpoints and controls')
