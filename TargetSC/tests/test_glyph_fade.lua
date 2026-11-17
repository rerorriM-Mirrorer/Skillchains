-- Test4.8: large breathing glyph: stays risen and fades after a burst (no
-- fall); hidden at the floor except the window-opening flash; ending kept.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local B=require('resonance_burst')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local s={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=112,step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}
local function model(burst)local m=R.new();m.states[71]=copy(s);if burst then m.bursts[71]={{at=burst,color=R.element_color('Fire')}}end;return m end
local function glyph(m,t,o)local f=m:frame(71,t,2,4,o);for _,d in ipairs(f.discs)do if d.role=='mb-glyph'then return d,f end end end
local o=copy(R.defaults);o.mb_glyph_rise=0
-- Rest hidden: after the window-opening flash, nothing at the floor.
local m=model()
assert(glyph(m,100.1,o),'window-opening flash visible')
for _,t in ipairs({101,102.5,104,106})do assert(glyph(m,t,o)==nil,'hidden at rest '..t)end
local br=copy(o);br.mb_glyph_rest='breath'
assert(glyph(model(),102.5,br),'breath option still breathes')
-- Fade after a burst: height constant at the peak, opacity follows the return energy.
local hit=model(104)
local peak
for _,t in ipairs({104,104.3,104.6,105.1,105.6,106.1,106.5})do
 local g=glyph(hit,t,o)
 local energy=B.return_energy(t-104,.6,2)
 if energy>.01 then
  assert(g,'visible while fading '..t)
  peak=peak or g.offset
  near(g.offset,peak,1e-9,'stays risen at '..t)
  assert(g.offset>o.disc_height+.1,'risen, not at the floor')
 end
end
local early,late=alpha(glyph(hit,104.3,o).outline),alpha(glyph(hit,105.5,o).outline)
assert(late<early,'fades over the return period')
assert(glyph(hit,106.7,o)==nil,'gone after the return (no fall to the floor)')
-- Fall option keeps the old landing.
local fall=copy(o);fall.mb_glyph_after='fall'
assert(glyph(model(104),105.5,fall).offset<glyph(model(104),104.3,fall).offset,'fall option still falls')
-- Re-strike while fading: back to full at the same height.
local re=model(104);re.bursts[71][2]={at=105.5,color=R.element_color('Wind')}
local before=alpha(glyph(re,105.49,o).outline)
local after=glyph(re,105.5,o)
assert(alpha(after.outline)>before,'re-strike brightens');near(after.offset,peak,1e-9,'re-strike at the same height')
-- Ending still lights it (interim behavior).
local e=copy(o);e.mb_ending_style='soft'
local lit=false
for t=110.05,111.95,.1 do if glyph(model(),t,e)then lit=true end end
assert(lit,'ending pulses still show the glyph')
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('mb',{'glyph','after','fall'})and settings.mb_glyph_after=='fall')
assert(cmd('mb',{'glyph','rest','breath'})and settings.mb_glyph_rest=='breath')
assert(cmd('mb',{'glyph','after','drift'})and settings.mb_glyph_after=='fall')
assert(cmd('mb',{'glyph','height','1'})and settings.mb_glyph_height==1,'mb glyph height still works')
assert(cmd('preset',{'killala'})and settings.mb_glyph_after=='fall'and settings.mb_glyph_rest=='breath')
assert(cmd('preset',{'default'})and settings.mb_glyph_after=='fade'and settings.mb_glyph_rest=='hidden')
print('PASS Test4.8 MB glyph: hidden at rest after the opening flash, stays risen and fades after a burst, re-strike, fall/breath options, ending kept')
