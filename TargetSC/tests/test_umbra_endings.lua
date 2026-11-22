-- Test5.7: Umbra endings (gyro / swallow, native 0.11.0), Umbra disc-glyph
-- size/opacity, disc shape/steady, core/flicker. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function link(o)
    local p=P.new(P.parse({'Radiance','4'},R),71,0,R,o)
    local st=p.model.states[71];st.properties={'Umbra'};st.elements=R.elements('Umbra')
    return p,st
end
local function at(p,t,o)p:advance(t)return p.model:frame(71,t,2,4,o)end
local function role(f,r)for _,d in ipairs(f.discs)do if d.role==r then return d end end end
R.native_level=11
local o=copy(R.defaults);o.ring_level4_open='pop' -- Test7.7: these check the pre-collapse opening (sky sets on)
local _,st=link(o)
local ending=o.mb_ending
-- Off by default: no 3D glyph.
assert(not at(link(o),st.mb_close-1,o).glyphs3,'ending off by default')
-- Gyro: stands up over gyro rise, spins at gyro speed, shrinks over the last share.
local g=copy(o);g.umbra_ending='gyro'
local function g3(opts,t)local f=at(link(opts),t,opts)return f.glyphs3 and f.glyphs3[1],f end
local a0=st.mb_close-ending
local x,f=g3(g,a0+.2)
assert(x and math.abs(x.tilt-math.pi/2*(.5*.5*(3-2*.5)))<1e-6,'standing up (smooth over .4 s)')
assert(not role(f,'property-trace'),'flat glyph hidden during the ending')
near(g3(g,a0+.5).tilt,math.pi/2,1e-9,'upright')
local angle=M.disc_rotation(st,a0+.5,g)
near(g3(g,a0+.5).rotation,angle+2*math.pi*1.5*.5,1e-9,'spins at gyro speed')
assert(g3(g,a0+.5).circle and not g3(g,a0+.5).clip,'circle, full sphere')
assert(g3(g,st.mb_close-.2).radius<g3(g,a0+.5).radius*.2,'shrinks away at the end')
local half=copy(g);half.umbra_gyro_below='half'
assert(g3(half,a0+.5).clip,'half cuts the lower dome')
assert(role(at(link(g),a0-.1,g),'property-trace'),'flat before the ending')
-- Swallow: stand over stand time, sink over the last sink time, pulled, clipped.
local w=copy(o);w.umbra_ending='swallow'
near(g3(w,a0+.25).stand,.5,1e-9,'standing');near(g3(w,a0+.25).sink,0,1e-9)
near(g3(w,st.mb_close-.5).sink,.5,1e-9,'sinking over the last second')
local y=g3(w,a0+1)
assert(y.clip and not y.circle and y.order==1 and y.pull==w.umbra_swallow_pull and y.stagger==w.umbra_swallow_stagger,'swallow parameters')
local inner=copy(w);inner.umbra_swallow_order='inner'
assert(g3(inner,a0+1).order==2,'inner first')
-- When flash: from the flash-out for ending time.
local fl=copy(w);fl.umbra_ending_when='flash';fl.umbra_ending_time=1.5
local start=M.umbra_flashed(st,fl,true)
assert(not g3(fl,start-.05)and g3(fl,start+.1)and not g3(fl,start+1.6),'flash window')
-- Older DLL: no 3D glyph, the flat glyph stays.
R.native_level=10
local old=at(link(g),a0+.5,g)
assert(not old.glyphs3 and role(old,'property-trace'),'needs native 0.11.0')
R.native_level=11
-- Disc-glyph size x Umbra MB ring, own opacity.
local ls=copy(o);ls.umbra_lines_size=1.2;ls.umbra_mb_size=1.4;ls.umbra_lines_opacity=.9
local lf=at(link(ls),5,ls)
local mbr for _,v in ipairs(lf)do if v.part=='mb'and v.role=='core'then mbr=v.radius end end
near(role(lf,'property-trace').radius,mbr*1.2,1e-9,'lines size x MB ring')
near(alpha(role(lf,'property-trace').outline),math.floor(.9*255+.5),1,'lines opacity')
-- Umbra disc shape overrides discs level4.
local sh=copy(o);sh.disc_level4_middle=.5;sh.umbra_disc_middle=1;sh.umbra_disc_position=.8;sh.umbra_disc_inner=1;sh.umbra_disc_outer=0
local d=role(at(link(sh),5,sh),'property')
near(d.mid,1);near(d.mid_pos,.8);near(d.inner,1);near(d.outer,0)
-- Steady: the opening flash does not pull the disc toward mb overall.
local sd=copy(o);sd.umbra_disc_opacity=1
local intro=role(at(link(sd),.1,sd),'property')
near(alpha(intro.color),255,1,'solid through the window-opening flash')
local un=copy(sd);un.umbra_disc_steady=false
assert(alpha(role(at(link(un),.1,un),'property').color)<250,'without steady it dips')
-- Core opacity and flicker depth.
local function core(opts,t)for _,v in ipairs(at(link(opts),t,opts))do if v.part=='ground'and v.strand==1 and v.role=='core'then return alpha(v.color)end end end
local c=copy(o);c.umbra_core=.5;c.umbra_flicker=0
near(core(c,1),math.floor(.5*(1+o.ring_shade)*255+.5),1,'direct core opacity (lit side +ring shade), no flicker')
local samples={}for t=1,1.4,.03 do samples[#samples+1]=core(c,t)end
assert(math.max(unpack(samples))==math.min(unpack(samples)),'flicker 0 = steady')
local fk=copy(o);fk.umbra_core=.8;fk.umbra_flicker=.6
local s2={}for t=1,1.4,.03 do s2[#s2+1]=core(fk,t)end
assert(math.max(unpack(s2))-math.min(unpack(s2))>60,'deeper flicker')
-- Commands, presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('umbra',{'ending','gyro'});assert(settings.umbra_ending=='gyro')
cmd('umbra',{'ending','when','flash'});cmd('umbra',{'ending','time','3'})
assert(settings.umbra_ending_when=='flash'and settings.umbra_ending_time==3)
cmd('umbra',{'gyro','speed','-3'});cmd('umbra',{'gyro','rise','.8'});cmd('umbra',{'gyro','shrink','0'});cmd('umbra',{'gyro','below','half'})
assert(settings.umbra_gyro_speed==-3 and settings.umbra_gyro_rise==.8 and settings.umbra_gyro_shrink==0 and settings.umbra_gyro_below=='half')
cmd('umbra',{'stand','time','.3'});cmd('umbra',{'sink','time','1.5'});cmd('umbra',{'swallow','stagger','.2'})
cmd('umbra',{'swallow','order','inner'});cmd('umbra',{'swallow','pull','.6'});cmd('umbra',{'swallow','lift','2'})
assert(settings.umbra_stand_time==.3 and settings.umbra_sink_time==1.5 and settings.umbra_swallow_stagger==.2)
assert(settings.umbra_swallow_order=='inner'and settings.umbra_swallow_pull==.6 and settings.umbra_swallow_lift==2)
cmd('umbra',{'lines','size','1.1'});cmd('umbra',{'lines','opacity','.7'});cmd('umbra',{'lines','size','same'})
assert(settings.umbra_lines_size==-1 and settings.umbra_lines_opacity==.7)
cmd('umbra',{'disc','middle','.95'});cmd('umbra',{'disc','position','.9'});cmd('umbra',{'disc','steady','off'})
assert(settings.umbra_disc_middle==.95 and settings.umbra_disc_position==.9 and settings.umbra_disc_steady==false)
cmd('umbra',{'core','.6'});cmd('umbra',{'flicker','.1'});assert(settings.umbra_core==.6 and settings.umbra_flicker==.1)
cmd('preset',{'killala'});assert(settings.umbra_disc_steady==false and settings.umbra_ending=='off')
cmd('preset',{'default'});assert(settings.umbra_disc_steady==true and settings.umbra_ending=='off'and settings.umbra_flicker==.28)
print('PASS Test5.7 Umbra endings (gyro stand/spin/shrink/half, swallow stand/sink/order/pull, mb or flash window, needs 0.11.0), lines size/opacity, disc shape, steady disc, core/flicker, commands, presets')
-- Test5.8: white glyph, ending from the opening, stays gone, MB ring at the disc plane.
do
    local w2=copy(R.defaults);w2.umbra_ending='swallow';w2.umbra_ending_when='open';w2.umbra_ending_time=4.2
    w2.umbra_stand_time=2;w2.umbra_sink_time=2.2
    local p2,s2=link(w2)
    local x=at(p2,.5,w2).glyphs3
    assert(x and x[1].stand>0 and x[1].stand<1,'swallow starts with the opening')
    assert(x[1].color%16777216==0xFFFFFF,'pure white')
    local late=at(p2,5,w2)
    assert(not late.glyphs3 and not role(late,'property-trace'),'stays gone after the ending')
    local cream=copy(w2);cream.umbra_lines_color='cream'
    assert(at(link(cream),.5,cream).glyphs3[1].color%16777216==0xFFF2CC,'cream option')
    local flat=role(at(link(R.defaults),5,R.defaults),'property-trace')
    assert(flat.outline%16777216==0xFFFFFF,'flat Umbra lines white too')
    local mh=copy(R.defaults);mh.umbra_mb_height='disc'
    local mf=at(link(mh),5,mh)
    local ring;for _,v in ipairs(mf)do if v.part=='mb'and v.role=='core'then ring=v end end
    near(ring.offset,role(mf,'property').offset,1e-9,'MB ring at the disc plane')
    print('PASS Test5.8 white glyph, ending when open, stays gone, cream option, MB ring at the disc')
end
-- Test5.9: longer ranges; the MB deadline caps the ending window.
do
    local settings=copy(R.defaults)
    local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
    cmd('umbra',{'ending','time','10'});cmd('umbra',{'sink','time','8'});cmd('umbra',{'stand','time','6'})
    assert(settings.umbra_ending_time==10 and settings.umbra_sink_time==8 and settings.umbra_stand_time==6,'longer ranges')
    local w3=copy(R.defaults);w3.umbra_ending='swallow';w3.umbra_ending_when='open';w3.umbra_ending_time=12;w3.umbra_sink_time=8
    local p3,s3=link(w3)
    local a,b=M.umbra_ending_window(s3,w3,true)
    near(b,s3.mb_close,1e-9,'capped at the MB deadline')
    near(at(p3,s3.mb_close-.01,w3).glyphs3[1].sink,1,.01,'fully swallowed right at the end')
    print('PASS Test5.9 ending/sink/stand ranges, MB deadline cap')
end
