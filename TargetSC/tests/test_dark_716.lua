-- Test7.16: Dark recipe (void look: pure black Dark element, violet glows,
-- violet Dark bursts and MB ring dark phase), dark disc modes, awakening
-- opacity above 1. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
R.native_level=12
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function cioara()local a=copy(require('tests.fixture_cioara_1122'))for k,v in pairs(R.defaults)do if a[k]==nil then a[k]=v end end return a end
local function rgb(c)return c%16777216 end
local function hex(t)return t[1]*65536+t[2]*256+t[3]end
local VIOLET=hex({130,70,255})

assert(R.defaults.dark_look=='classic'and R.defaults.dark_glow=='elemental'and R.defaults.dark_disc=='black','defaults')
-- Classic: unchanged colors.
R.apply_colors(copy(R.defaults))
local dark=R.element_color('Dark')
assert(hex(dark)==hex({25,14,52})and hex(R.burst_color('Dark'))==hex({25,14,52}),'classic Dark')
assert(R.burst_color('Earth')==R.element_color('Earth'),'other bursts use the element table')

local function frame_of(args,t,o,id)
    local p=P.new(P.parse(args,R),id or 71,0,R,o);p:advance(t)
    return p.model:frame(id or 71,t,2,4,o),p
end
local function find(f,pred)local r={}for _,v in ipairs(f)do if pred(v)then r[#r+1]=v end end return r end

-- Classic look on A's profile: Compression ring core is the flat Dark.
local o=cioara();R.apply_colors(o)
local f=frame_of({'window','Compression'},5,o)
for _,v in ipairs(find(f,function(v)return v.role=='core'and (v.part=='ground'or v.part=='sky')end))do
    assert(rgb(v.color)==hex({25,14,52}),'classic core')
end

-- Void: black cores, violet glows, violet MB ring.
o.dark_look='void';R.apply_colors(o)
assert(hex(R.element_color('Dark'))==0 and hex(R.element_color('Darkness'))==0,'void: Dark is pure black')
assert(hex(R.burst_color('Dark'))==VIOLET,'void: Dark bursts violet')
f=frame_of({'window','Compression'},5,o)
local cores=find(f,function(v)return v.role=='core'and (v.part=='ground'or v.part=='sky')end)
local glows=find(f,function(v)return v.role=='glow'and (v.part=='ground'or v.part=='sky')end)
assert(#cores>=2 and #glows>=2,'rings drawn')
for _,v in ipairs(cores)do assert(rgb(v.color)==0,'void core black')end
for _,v in ipairs(glows)do assert(rgb(v.color)==VIOLET,'void glow violet')end
for _,v in ipairs(find(f,function(v)return v.part=='mb'and v.role=='core'end))do
    assert(rgb(v.color)~=0,'MB ring not black')
end
-- Opener (A's black opener glow): Gravitation's arcs glow violet, Scission's stay black.
f=frame_of({'opener','Gravitation,Scission'},5,o)
local arcs=find(f,function(v)return v.kind=='arc'and v.part=='ground'end)
local starts={}
for _,v in ipairs(arcs)do starts[v.arc_start]=starts[v.arc_start]or {};table.insert(starts[v.arc_start],v)end
local seen_violet,seen_black=false,false
for _,v in ipairs(arcs)do
    if v.role=='glow'then
        if rgb(v.color)==VIOLET then seen_violet=true elseif rgb(v.color)==0 then seen_black=true end
    end
end
assert(seen_violet and seen_black,'opener: Dark arcs violet glow, others keep the black opener glow')
-- Glow choices.
for name,t in pairs({indigo={90,60,255},tint={132,74,224}})do
    o.dark_glow=name;R.apply_colors(o)
    assert(hex(R.burst_color('Dark'))==hex(t),'burst '..name)
    local g=find(frame_of({'window','Compression'},5,o),function(v)return v.role=='glow'and v.part=='ground'end)
    assert(rgb(g[1].color)==hex(t),'glow '..name)
end
o.dark_glow='10,200,30';R.apply_colors(o);assert(hex(R.burst_color('Dark'))==hex({10,200,30}),'custom glow')
o.dark_glow='elemental';R.apply_colors(o)
-- Discs: black (default), violet, classic for Compression's property disc.
local function disc_has(mode,want)
    local x=copy(o);x.dark_disc=mode
    local fr=frame_of({'window','Compression'},5,x)
    for _,d in ipairs(fr.discs)do if d.role=='property'then
        for _,c in ipairs(d.colors)do if rgb(c)==want then return true end end end end
    return false
end
assert(disc_has('black',0),'disc black')
assert(disc_has('violet',VIOLET),'disc violet')
assert(disc_has('classic',hex({25,14,52})),'disc classic')
-- A Dark burst in a preview is violet, and reaches the MB ring tint.
local fb,pb=frame_of({'burst','Dark'},.7,o)
assert(hex(pb.model.bursts[71][1].color)==VIOLET,'preview Dark burst violet')
-- Umbra (level 4) keeps its own look: no violet lift on its rings.
local fu=frame_of({'umbra'},4,o)
assert(fu,'umbra draws')
-- Back to classic restores everything in place.
o.dark_look='classic';R.apply_colors(o)
assert(hex(dark)==hex({25,14,52})and hex(R.burst_color('Dark'))==hex({25,14,52}),'classic restored in place')

-- Awakening opacity above 1 is a stronger multiplier, capped at full alpha.
local function awake(x,t)
    local p=P.new(P.parse({'demo'},R),72,0,R,x);p:advance(t)
    local fr=p.model:frame(72,t,2,4,x);local best=0
    for _,d in ipairs(fr.discs or {})do if d.role=='awakening'then best=math.max(best,math.floor(d.color/16777216))end end
    return best
end
local a1=cioara();a1.awakening_opacity_level1=1
local a4=cioara();a4.awakening_opacity_level1=4
assert(awake(a4,9.6)>awake(a1,9.6)and awake(a4,9.6)<=255,'level1 x4 stronger, capped')

-- Commands.
local settings=copy(R.defaults);local said
local cmd=C.new(settings,R.defaults,function()end,function(m)said=m end,R.killala,R.cioara)
assert(cmd('dark',{'void'})and settings.dark_look=='void')
assert(cmd('dark',{'classic'})and settings.dark_look=='classic')
assert(cmd('dark',{'glow','indigo'})and settings.dark_glow=='indigo')
assert(cmd('dark',{'glow','120','60','255'})and settings.dark_glow=='120,60,255')
assert(cmd('dark',{'glow','999','0','0'})and settings.dark_glow=='120,60,255'and said:find('^Use'))
assert(cmd('dark',{'disc','violet'})and settings.dark_disc=='violet')
assert(cmd('dark',{'disc','grey'})and settings.dark_disc=='violet'and said:find('^Use'))
assert(cmd('dark',{})and said:find('^Use //tsc dark'))
assert(cmd('awakening',{'level2','opacity','3'})and settings.awakening_opacity_level2==3)
assert(cmd('awakening',{'opacity','2.5'})and settings.awakening_opacity==2.5)
assert(not said:find('[\128-\255]'),'ASCII')
R.apply_colors(copy(R.defaults))
print('PASS Test7.16 Dark void look (black cores, violet glows/bursts/MB), dark disc modes, awakening above 1')
