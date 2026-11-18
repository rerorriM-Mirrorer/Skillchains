-- Test5.1: Radiance MB ring like a level-3 Light middle ring (white core,
-- element-colored inner glow, strong and shifting fast); level-4
-- (Radiance/Umbra) property disc overrides with a middle point. Simulated.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
R.native_level=10
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function rgb(c)return c%16777216 end
local function run(args,t,o)
    -- `Umbra` as a preview keyword is the Umbra demo sequence, so a single
    -- level-4 Umbra link is the Radiance preview with Umbra properties.
    local umbra=args[1]=='Umbra'
    local p=P.new(P.parse(umbra and {'Radiance','4'}or args,R),71,0,R,o)
    if umbra then local st=p.model.states[71];st.properties={'Umbra'};st.elements=R.elements('Umbra')end
    p:advance(t)
    return p.model:frame(71,t,2,4,o)
end
local function mb(f)
    local r={}for _,v in ipairs(f)do if v.part=='mb'then r[v.role]=r[v.role]or {};table.insert(r[v.role],v)end end return r
end
local o=copy(R.defaults)
o.radiance_shimmer_mb=false -- Test5.2 shimmer brightens a patch; this file checks the plain 5.1 glow
-- Radiance MB ring: white core with colored glows that shift over time.
local a=mb(run({'Radiance','4'},6,o))
assert(a.core and rgb(a.core[1].color)==0xFFFFFF,'white core')
assert(#a.glow==2,'ring glow plus the SC-style glow band')
local colors={}
for _,t in ipairs({6,6.4,6.8,7.2})do colors[rgb(mb(run({'Radiance','4'},t,o)).glow[1].color)]=true end
local n=0 for _ in pairs(colors)do n=n+1 end
assert(n>=3,'glow shifts through the element colors fast (.4 s)')
-- Slower cycle shifts less over the same span.
local slow=copy(o);slow.mb_radiance_cycle=8
local function travel(opts)
    local total,prev=0,nil
    for _,t in ipairs({6,6.2,6.4,6.6,6.8})do
        local c=rgb(mb(run({'Radiance','4'},t,opts)).glow[1].color)
        if prev then for _,k in ipairs({65536,256,1})do total=total+math.abs(math.floor(c/k)%256-math.floor(prev/k)%256)end end
        prev=c
    end
    return total
end
assert(travel(slow)<travel(o)*.3,'a slow cycle shifts less')
-- Glow strength: 3 is stronger than 1, 0 leaves only the core's plain glow.
local function glow_alpha(g)local x=copy(o);x.mb_radiance_glow=g return alpha(mb(run({'Radiance','4'},6,x)).glow[2].color)end
assert(glow_alpha(3)>glow_alpha(1),'glow strength')
-- Same proportion as a level-3 Light middle SC ring at that strength:
-- ring glow = core alpha x .24 x glow x gain (the shared ring() formula).
local core=alpha(a.core[1].color)
near(alpha(a.glow[2].color),math.floor(math.min(255,core*.24*o.glow*3)+.5),2,'ring glow proportion')
-- Turns with the disc when the level-4 disc turns.
local spin=copy(o);spin.disc_speed_level4=1
local sf=run({'Radiance','4'},6,spin)
local disc_rotation
for _,d in ipairs(sf.discs)do if d.role=='property'then disc_rotation=d.rotation end end
near(mb(sf).core[1].rotation,disc_rotation,1e-9,'MB ring turns with the disc')
-- Classic: no white core / inner glow look.
local classic=copy(o);classic.mb_radiance='classic'
assert(#mb(run({'Radiance','4'},6,classic)).glow==1,'classic: plain ring glow only')
-- Umbra MB ring untouched.
assert(#(mb(run({'Umbra','4'},6,o)).glow or {})<=1,'Umbra unchanged: no SC-style glow band')
-- Level-4 disc: defaults unchanged; overrides with a middle point.
local function prop(f)local fill,trace for _,d in ipairs(f.discs)do if d.role=='property'then fill=d elseif d.role=='property-trace'then trace=d end end return fill,trace end
local base,btrace=prop(run({'Radiance','4'},6,o))
assert(base.inner==nil and base.mid==nil,'defaults untouched')
local x=copy(o);x.disc_level4_inner=.2;x.disc_level4_middle=.9;x.disc_level4_position=.7;x.disc_level4_outer=0
x.disc_level4_size=1.5;x.disc_level4_height=.1
for _,name in ipairs({'Radiance','Umbra'})do
    local fill,trace=prop(run({name,'4'},6,x))
    near(fill.inner,.2);near(fill.outer,0);near(fill.mid,.9);near(fill.mid_pos,.7)
    near(fill.radius,base.radius*1.5,1e-6,'size');near(trace.radius,btrace.radius*1.5,1e-6,'lines follow size')
    near(fill.offset,base.offset+.1,1e-6,'height');near(trace.offset,btrace.offset+.1,1e-6,'lines follow height')
end
-- Level 3 untouched by level-4 settings.
local l3=prop(run({'Light','3'},6,x))
assert(l3.mid==nil,'level 3 unaffected')
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('mb',{'radiance','classic'});assert(settings.mb_radiance=='classic')
cmd('mb',{'radiance','light'});assert(settings.mb_radiance=='light')
cmd('mb',{'radiance','glow','2'});assert(settings.mb_radiance_glow==2)
cmd('mb',{'radiance','glow','4'});assert(settings.mb_radiance_glow==2,'range')
cmd('mb',{'radiance','cycle','.2'});assert(settings.mb_radiance_cycle==.2)
cmd('discs',{'level4','inner','.3'});assert(settings.disc_level4_inner==.3)
cmd('discs',{'level4','middle','1'});assert(settings.disc_level4_middle==1)
cmd('discs',{'level4','position','.8'});assert(settings.disc_level4_position==.8)
cmd('discs',{'level4','outer','.1'});assert(settings.disc_level4_outer==.1)
cmd('discs',{'level4','size','1.4'});assert(settings.disc_level4_size==1.4)
cmd('discs',{'level4','height','-.05'});assert(settings.disc_level4_height==-.05)
cmd('discs',{'level4','middle','same'});assert(settings.disc_level4_middle==-1)
cmd('discs',{'level4','size','same'});assert(settings.disc_level4_size==-1)
cmd('discs',{'level4','height','same'});assert(settings.disc_level4_height==-.05,'height needs a number')
cmd('preset',{'killala'});assert(settings.mb_radiance=='classic')
cmd('preset',{'default'});assert(settings.mb_radiance=='light'and settings.disc_level4_middle==-1)
print('PASS Test5.1 Radiance MB ring (white core, shifting colored glow, strength, SC proportion, turns with disc, classic, Umbra unchanged) and level-4 disc inner/middle/position/outer/size/height, commands, presets')
