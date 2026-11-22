-- Test7.18: MB ring hold (pure burst color, paused cycle, ease back), soft
-- shimmer, dark back compression + glow spin, opener glow white, A's 04:10
-- cioara preset. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local B=require('resonance_burst')
R.native_level=12
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function profile()local a=copy(require('tests.fixture_cioara_1122b'))for k,v in pairs(R.defaults)do if a[k]==nil then a[k]=v end end return a end
local function rgb(c)return c%16777216 end
local function alpha(c)return math.floor(c/16777216)end
local function hex(t)return math.floor(t[1]+.5)*65536+math.floor(t[2]+.5)*256+math.floor(t[3]+.5)end
local function near(a,b,e)return math.abs(a-b)<=(e or 1e-6)end
local function find(f,pred)local r={}for _,v in ipairs(f)do if pred(v)then r[#r+1]=v end end return r end
local function run(args,t,o,id)
    id=id or 91
    local p=P.new(assert(P.parse(args,R)),id,0,R,o);p:advance(t)
    return p.model:frame(id,t,2,4,o),p
end

-- Defaults keep Test7.17.
local d=R.defaults
assert(d.mb_ring_hold==0 and d.mb_ring_ease==-1 and d.mb_shimmer_style=='ripple'and d.mb_shimmer_decay==3
    and d.mb_shimmer_turn==.5 and d.mb_shimmer_soft==.8 and d.dark_back_spin==1 and d.opener_glow=='black','defaults')

-- A's 04:10 profile loads as the fixture.
local o=profile();R.apply_colors(o)
assert(o.dark_look=='void'and o.dark_glow_burst=='0,0,0'and o.earth_color=='scission'and o.awakening_opacity_level3==4,'fixture')

-- MB ring hold: Fire burst at .6 s on a Fragmentation window.
local function option(x)return function(k)if x[k]~=nil then return x[k]end return d[k]end end
local h=copy(o);h.mb_ring_hold=1.5;h.mb_ring_ease=.5
local f,p=run({'burst','Fire'},.6+1.0,h)
local s=p.model.states[91]
local r=B.sample(p.model,s,.6+1.0,option(h))
assert(near(r.ring,1)and r.ring_element==R.element_color('Fire'),'held at 1.0 s')
assert(r.flicker<1e-6,'pure after the strike')
local core=find(f,function(v)return v.part=='mb'and v.role=='core'end)[1]
assert(rgb(core.color)==hex(R.element_color('Fire')),'MB ring core is the pure burst color')
r=B.sample(p.model,s,.6+1.75,option(h));assert(r.ring>0 and r.ring<1,'easing back')
r=B.sample(p.model,s,.6+2.2,option(h));assert(not r.ring_element,'released')
assert(near(r.cycle_pause,1.5+.25,1e-6),'pause = hold + ease/2 ('..tostring(r.cycle_pause)..')')
-- Back-to-back bursts: the first only holds until the second lands.
local p2=P.new(P.parse({'mb','dark'},R),92,0,R,h)
local t=0;while t<12 do p2:advance(t);p2.model:frame(92,t,2,4,h);t=t+.1 end
-- Pause never exceeds the elapsed time.
local s2=p2.model.states[92];local r2=B.sample(p2.model,s2,t,option(h))
assert((r2.cycle_pause or 0)<=t-s2.created+1e-6,'pause bounded')
-- Hold 0 (default): exact Test7.17 ring numbers.
local z=copy(o)
local _,pz=run({'burst','Fire'},.8,z,93)
local rz=B.sample(pz.model,pz.model.states[93],.8,option(z))
assert(rz.cycle_pause==nil and rz.ring_element==nil and near(rz.ring,1-(function(x)x=math.max(0,math.min(1,x))return x*x*(3-2*x)end)(.2/(z.mb_duration*.375))),'hold off = old ring')

-- Soft shimmer: lit four-stop glow that turns with time; ripple path untouched.
local so=copy(o);so.mb_shimmer_style='soft'
local function glyph_glow(x,tt)
    local fr=run({'burst','Fire'},tt,x,94)
    return find(fr,function(v)return v.role=='burst-glow'end)
end
local g1,g2=glyph_glow(so,.7),glyph_glow(so,.9)
assert(#g1>=1 and g1[1].blend==1 and #g1[1].colors==4,'soft = lit gradient')
assert(alpha(g1[1].colors[1])>alpha(g1[1].colors[3]),'bright side')
assert(not near(g1[1].rotation,g2[1].rotation,1e-4),'lit side turns')
local rp=glyph_glow(copy(o),.7);assert(#rp>=1,'ripple glow still drawn')

-- Dark back compression: Compression has it, Gravitation does not; glow spins 3x.
local c=copy(o);c.dark_ring_back='compression';c.dark_back_spin=3;c.dark_ring_back_gain=.5
local VIOLET=hex({130,70,255})
local fc=run({'window','Compression'},5,c,95)
local gc=find(fc,function(v)return v.role=='glow'and v.part=='ground'end)[1]
local cc=find(fc,function(v)return v.role=='core'and v.part=='ground'end)[1]
assert(rgb(gc.colors[3])==VIOLET,'Compression back violet')
assert(math.abs(cc.rotation)>1e-3 and near(gc.rotation,cc.rotation*3*c.ring_glow_spin,1e-6),'glow spins x3')
for _,v in ipairs(find(run({'window','Gravitation'},5,c,96),function(v)return v.role=='glow'and v.part=='ground'end))do
    for _,col in ipairs(v.colors)do assert(rgb(col)~=VIOLET,'Gravitation off')end
end

-- Opener glow white: every opener arc glow is white.
local w=copy(o);w.opener_glow='white'
local arcs=find(run({'opener','Gravitation,Scission,Darkness'},5,w,97),function(v)return v.kind=='arc'and v.role=='glow'end)
assert(#arcs>=6,'arcs');for _,v in ipairs(arcs)do assert(rgb(v.color)==0xFFFFFF,'white opener glow')end

-- Preview path (E4b): `preview dark mb` on the new preset plays through with hold + soft.
local settings=copy(d);local said
local cmd=C.new(settings,d,function()end,function(m)said=m end,R.killala,R.cioara)
assert(cmd('preset',{'cioara'}))
for k,v in pairs(R.cioara)do assert(settings[k]==v,'preset '..k)end
assert(settings.opener_glow=='white'and settings.dark_ring_back=='compression'and settings.dark_back_spin==3 and settings.earth_color=='scission','A 04:10 picks')
local pv=copy(settings);pv.mb_ring_hold=1.2;pv.mb_shimmer_style='soft';R.apply_colors(pv)
local pr=P.new(P.parse({'dark','mb'},R),98,0,R,pv);t=0
while not pr:advance(t)do assert(pr.model:frame(98,t,2,4,pv));t=t+.2 end

-- Commands.
assert(cmd('mb',{'ring','hold','1.5'})and settings.mb_ring_hold==1.5)
assert(cmd('mb',{'ring','ease','.4'})and settings.mb_ring_ease==.4)
assert(cmd('mb',{'ring','ease','-1'})and settings.mb_ring_ease==-1)
assert(cmd('mb',{'ring','hold','9'})and settings.mb_ring_hold==1.5 and said:find('^Use'))
assert(cmd('mb',{'ring','.5'})and settings.mb_ring==.5,'mb ring <n> unchanged')
assert(cmd('mb',{'shimmer','style','soft'})and settings.mb_shimmer_style=='soft')
assert(cmd('mb',{'shimmer','style','wavy'})and settings.mb_shimmer_style=='soft'and said:find('^Use'))
assert(cmd('mb',{'shimmer','decay','2'})and settings.mb_shimmer_decay==2)
assert(cmd('mb',{'shimmer','turn','-1'})and settings.mb_shimmer_turn==-1)
assert(cmd('mb',{'shimmer','soft','.6'})and settings.mb_shimmer_soft==.6)
assert(cmd('mb',{'shimmer','1.5'})and settings.mb_shimmer==1.5,'mb shimmer <n> unchanged')
assert(cmd('dark',{'back','compression'})and settings.dark_ring_back=='compression')
assert(cmd('dark',{'back','spin','4'})and settings.dark_back_spin==4)
assert(cmd('dark',{'back','.3'})and settings.dark_ring_back_gain==.3)
assert(cmd('opener',{'glow','white'})and settings.opener_glow=='white')
assert(not said:find('[\128-\255]'),'ASCII')
R.apply_colors(copy(d))
print('PASS Test7.18 MB ring hold (pure, paused cycle, ease), soft shimmer, dark back compression + spin, opener glow white, cioara 04:10 preset')
