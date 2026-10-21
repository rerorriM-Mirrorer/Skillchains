-- Final tuning pass: analytic motion/opacity and actual command saving.
-- Host simulation only. No native DLL or live combat.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local Motion=require('resonance_motion')
local Burst=require('resonance_burst')
local Controls=require('resonance_controls')
local function copy(t)local o={}for k,v in pairs(t)do o[k]=v end return o end
local function near(a,b,e)assert(math.abs(a-b)<(e or 1e-7),tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function layer(f,role,part)
 for _,v in ipairs(part and f or f.discs or {})do if v.role==role and(not part or v.part==part)then return v end end
end
local function opacity(f,role,part)
 local v=layer(f,role,part);return v and alpha(part and v.color or v.outline)or 0
end
local opts=copy(R.defaults)
local s={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}
local function model()local m=R.new();m.states[71]=copy(s);return m end
local function frame(t,o,m)return(m or model()):frame(71,t,2,4,o or opts)end
-- Integrating the speed curve preserves the initial spin, reaches the minimum
-- continuously, then remains there until MB closes. No accumulated-frame drift.
local function speed(t,o,state)
 return(Motion.disc_rotation(state or s,t+.000001,o)-Motion.disc_rotation(state or s,t,o))/.000001/(2*math.pi)
end
for _,power in ipairs({.5,1,4})do
 local o=copy(opts);o.disc_slowdown=power
 near(speed(101,o),.2,1e-6)
 near(speed(105.5,o),.1*(.5+1.5*.5^power),1e-6)
 near(speed(108.1,o),.05,1e-6);near(speed(109.5,o),.05,1e-6)
 near(speed(110.1,o),0,1e-6)
 near(Motion.disc_rotation(s,103-1e-8,o),Motion.disc_rotation(s,103,o),1e-7)
 near(Motion.disc_rotation(s,108-1e-8,o),Motion.disc_rotation(s,108,o),1e-7)
 o.display='sc'
 for _,t in ipairs({101,105.5,108.1,109.5})do near(Motion.disc_rotation(s,t,o),Motion.rotation(s,t,o))end
end
local stationary=copy(s);stationary.level=4
near(speed(109,opts,stationary),0)
local slow=copy(opts);slow.disc_speed_level2=.2
near(speed(101,slow),.02,1e-6);near(speed(109,slow),.02,1e-6)
-- Steady configured property-disc opacity, unchanged elemental hues, a smooth
-- final exit and no post-deadline flash resurrecting the regular property disc.
for _,mode in ipairs({'mb','both'})do
 local o=copy(opts);o.display=mode
 for _,t in ipairs({100,101,105,108.5,109.3})do
  local d=layer(frame(t,o),'property')
  near(alpha(d.color),math.floor(o.disc_opacity*o.opacity*255+.5))
  near(alpha(d.outline),math.floor(o.disc_outline*o.opacity*255+.5))
 end
 local half=layer(frame(109.7,o),'property')
 near(alpha(half.color),math.floor(o.disc_opacity*o.opacity*.5*255+.5))
 assert(not layer(frame(110,o),'property'))
 local late=model();late.bursts[71]={{at=109.8,color=R.element_color('Wind')}}
 assert(not layer(frame(110.05,o,late),'property'))
end
local sc=copy(opts);sc.display='sc'
local fading=layer(frame(105.5,sc),'property')
near(alpha(fading.color),math.floor(sc.disc_opacity*sc.opacity*.5*255+.5))
assert(not layer(frame(109,sc),'property'))
-- Starting ring opacity grows to full strength INSIDE the master multiplier.
local o=copy(opts);o.mb_overall=.5;o.mb_ending_style='off'
near(opacity(frame(100,o),'core','mb'),math.floor(.39*.5*255+.5))
near(opacity(frame(105,o),'core','mb'),math.floor((.39+.61*.5)*.5*255+.5))
assert(opacity(frame(109.99,o),'core','mb')==127)
for _,style in ipairs({'soft','hard','both'})do
 o.mb_ending_style=style;o.mb_idle=0
 -- Check the whole ending's two layers against the same analytic envelope.
 for i=0,119 do
  local progress=(i+.25)/120
  local t=110-o.mb_ending+progress*o.mb_ending
  local expected=math.floor(Burst.ending(progress,style)*.5*255+.5)
  local f=frame(t,o)
  near(opacity(f,'core','mb'),expected)
  near(opacity(f,'mb-glyph'),expected)
  for _,v in ipairs(f)do if v.part=='mb'then assert(v.color%16777216==16777215)end end
 end
 assert(not layer(frame(110,o),'core','mb')and not layer(frame(110,o),'mb-glyph'))
end
near(Burst.ending(1/6,'soft'),1);near(Burst.ending(.5,'soft'),.5);near(Burst.ending(5/6,'soft'),1)
for i=0,2 do near(Burst.ending((i+.25)/3,'hard'),1);near(Burst.ending((i+.75)/3,'hard'),0)end
-- Closing wins even when a confirmed release is already rising; no reset down.
o=copy(opts);local late=model();late.bursts[71]={{at=109.2,color=R.element_color('Wind')}}
local released=layer(frame(109.5,o,late),'mb-glyph')
assert(released.offset>o.disc_height and released.outline%16777216==16777215)
near(alpha(released.outline),255)
assert(not layer(frame(110.01,o,late),'mb-glyph'),'closing lights do not resurrect after deadline')
-- The MB master affects confirmed hit overlays as well as resting signals.
o=copy(opts);o.mb_overall=.5;local hit=model();hit.bursts[71]={{at=105,color=R.element_color('Wind')}}
local f=frame(105,o,hit)
near(opacity(f,'core','mb'),128);near(opacity(f,'mb-glyph'),128)
near(alpha(layer(f,'property').color),128)
o.mb_overall=0;f=frame(105,o,model())
assert(not layer(f,'core','mb')and not layer(f,'mb-glyph'))
assert(layer(f,'property'),'shared property baseline uses its own configured opacity')
local muted_hit=model();muted_hit.bursts[71]={{at=105,color=R.element_color('Wind')}}
local muted=frame(105,o,muted_hit)
assert(layer(muted,'property').color==layer(f,'property').color and layer(muted,'property').outline==layer(f,'property').outline)
-- Hold includes .15s for the white-to-element transition; zero restores the
-- prior descent exactly. Short source windows always retain descent time.
o=copy(opts);o.hum_amplitude=0;o.amplitude=0;o.sky_hold=.5
for _,t in ipairs({103,103.15,103.4,103.65})do
 local g,sky=Motion.positions(s,t,4,o);near(sky-g,3.6)
end
local g,sky=Motion.positions(s,104,4,o);assert(sky-g<3.6)
g,sky=Motion.positions(s,108,4,o);near(sky-g,0)
local fg,fs=Motion.positions(s,108.4,4,o);near(fg,g);near(fs,sky)
o.sky_hold=0;near(Motion.descent_remaining(s,105.5,o),.5)
local short=copy(s);short.sc_close=103.3;o.sky_hold=2
near(Motion.descent_remaining(short,103.3,o),0)
near(s.sc_open,103);near(s.sc_close,108);near(s.mb_close,110)
-- Save commands validate numbers/enums and preserve the user's stage tuning.
local saved=0;o=copy(opts);o.disc_speed_opener=4;o.disc_speed_level2=3
local command=Controls.new(o,R.defaults,function()saved=saved+1 end,function()end)
command('discs',{'minimum','.7'});command('mb',{'overall','.4'});command('sky',{'hold','.8'})
for _,v in ipairs({'hard','both','soft','off'})do command('mb',{'ending','style',v})end
assert(saved==7 and o.disc_minimum==.7 and o.mb_overall==.4 and o.sky_hold==.8 and o.mb_ending_style=='off')
assert(o.disc_speed_opener==4 and o.disc_speed_level2==3)
command('discs',{'minimum','nan'});command('sky',{'hold','3'});command('mb',{'overall','-1'});command('mb',{'ending','style','invalid'})
assert(saved==7)
print('PASS Test8 steady property opacity/MB exit, minimum spin curves, SC-only compatibility, master opacity, all synchronized ending modes, late hits, held bell/deadlines and saved controls')
