-- Test3.4: MB burst glows on the large glyph and lifted trace: lit side,
-- added spin over each glyph, flicker and width controls; killala restores.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function glow(f,part)for _,v in ipairs(f)do if v.role=='burst-glow'and v.part==part then return v end end end
local function disc(f,role)for _,v in ipairs(f.discs)do if v.role==role then return v end end end
local function alpha(c)return math.floor(c/16777216)end
local s={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,
 step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}
local function frame(t,o)local m=R.new();m.states[71]=copy(s);m.bursts[71]={{at=104,color=R.element_color('Fire')}};return m:frame(71,t,2,4,o)end
local o=copy(R.defaults);o.mb_intro=0;o.mb_ending_style='off'
for _,mode in ipairs({'gradient','firm'})do
 local m=copy(o);m.ring_blend=mode
 local f=frame(104.2,m)
 for _,part in ipairs({'mb-glyph','property-trace'})do
  local g=assert(glow(f,part),part..' glow present')
  assert(g.blend==1 and #g.colors>=2,part..' '..mode..' blends')
  assert(alpha(g.colors[1])>alpha(g.colors[#g.colors==4 and 3 or 2]),part..' lit side')
 end
end
local split=copy(o);split.ring_blend='split'
assert(#glow(frame(104.2,split),'mb-glyph').colors==1,'split: even glow')
local even=copy(o);even.mb_glow_shade=0
assert(#glow(frame(104.2,even),'property-trace').colors==1,'shade 0: even glow')
-- Added spin: glow angle = glyph angle + 2*pi*spin*(now-created).
for _,spin in ipairs({.5,-1,0})do
 local m=copy(o);m.mb_glow_spin=spin
 local f=frame(104.2,m)
 near(glow(f,'mb-glyph').rotation,f.awakening_glyph.rotation+2*math.pi*spin*4.2,1e-9,'large glyph glow spin '..spin)
 near(glow(f,'property-trace').rotation,disc(f,'property-trace').rotation+2*math.pi*spin*4.2,1e-9,'trace glow spin '..spin)
end
-- Flicker 0 removes the 9 Hz ripple; 1 keeps the original value.
local function strength(t,flicker)local m=copy(o);m.mb_glow_flicker=flicker;m.mb_glow_shade=0
 return alpha(glow(frame(t,m),'property-trace').colors[1])end
local steady={}for i=0,6 do steady[#steady+1]=strength(104.2+i*.011,0)end
for i=2,#steady do assert(steady[i]<=steady[i-1],'flicker 0 decays without ripple')end
local rippled,dips=strength(104.2,1),0
for i=1,6 do local v=strength(104.2+i*.011,1);if v>rippled then dips=dips+1 end;rippled=v end
assert(dips>0,'flicker 1 still ripples')
-- Width multiplier.
local thin=copy(o);thin.mb_glow_width=.5
near(glow(frame(104.2,thin),'mb-glyph').pixels,math.max(1,o.width)+5,1e-9,'large glow width')
near(glow(frame(104.2,thin),'property-trace').pixels,math.max(1,o.width)+6,1e-9,'trace glow width')
near(glow(frame(104.2,o),'mb-glyph').pixels,math.max(1,o.width)+10,1e-9,'default width unchanged')
-- Commands and presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('mb',{'glow','shade','0.8'})and settings.mb_glow_shade==.8)
assert(cmd('mb',{'glow','spin','-0.5'})and settings.mb_glow_spin==-.5)
assert(cmd('mb',{'glow','flicker','0'})and settings.mb_glow_flicker==0)
assert(cmd('mb',{'glow','width','0.6'})and settings.mb_glow_width==.6)
assert(cmd('mb',{'glow','width','5'})and settings.mb_glow_width==.6,'range enforced')
assert(cmd('mb',{'glyph','tint','0.6'})and settings.mb_glyph_tint==.6,'mb glyph still works')
assert(cmd('preset',{'killala'})and settings.mb_glow_shade==0 and settings.mb_glow_spin==0 and settings.mb_glow_flicker==1)
assert(cmd('preset',{'default'})and settings.mb_glow_shade==.5 and settings.mb_glow_spin==.5)
print('PASS Test3.4 MB burst glows: lit side (gradient/firm), added spin over each glyph, flicker, width, killala')
