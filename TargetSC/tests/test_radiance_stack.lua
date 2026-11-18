-- Test5.5: Radiance three-disc stack (bottom white, middle Fusion<->
-- Fragmentation crossfade turning at the level-4 speed, existing white disc
-- on top), and the glyph's own opacity range. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
R.native_level=10
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function rgb(c)return c%16777216 end
local function link(name,o)
    local p=P.new(P.parse({'Radiance','4'},R),71,0,R,o)
    if name=='Umbra'then local st=p.model.states[71];st.properties={'Umbra'};st.elements=R.elements('Umbra')end
    return p
end
local function at(p,t,o)p:advance(t)return p.model:frame(71,t,2,4,o)end
local function roles(f)local r,i={},{}for k,d in ipairs(f.discs)do r[d.role]=d;i[d.role]=k end return r,i end
local o=copy(R.defaults);o.disc_speed_level4=2
local f=at(link('Radiance',o),1,o)
local d,i=roles(f)
assert(d['radiance-bottom']and d['radiance-middle']and d.property,'three discs')
assert(i['radiance-bottom']<i['radiance-middle']and i['radiance-middle']<i.property,'drawn bottom, middle, top')
near(d['radiance-middle'].offset-d['radiance-bottom'].offset,.01,1e-9,'spacing');near(d.property.offset-d['radiance-middle'].offset,.01,1e-9)
assert(rgb(d['radiance-bottom'].color)==0xFFFFFF and rgb(d.property.color)==0xFFFFFF,'white bottom and top')
near(alpha(d['radiance-bottom'].color),math.floor(.6*255+.5),1,'direct bottom opacity')
near(alpha(d['radiance-middle'].color),math.floor(.5*255+.5),1,'direct middle opacity')
-- Stack height moves all three; spacing spreads them.
local up=copy(o);up.radiance_stack_height=.1;up.radiance_stack_spacing=.03
local u=roles(at(link('Radiance',up),1,up))
near(u['radiance-bottom'].offset,d['radiance-bottom'].offset+.1,1e-9,'stack height')
near(u.property.offset,u['radiance-bottom'].offset+.06,1e-9,'spacing')
-- Middle crossfade: Fusion at the start of each cycle, Fragmentation halfway.
local R0=link('Radiance',o).model.states[71].created
local function palette(name)local r={}for _,e in ipairs(R.elements(name))do r[#r+1]=R.element_color(e)end return r end
local fusion,frag=palette('Fusion'),palette('Fragmentation')
local function packed(c)return math.floor(c[1]+.5)*65536+math.floor(c[2]+.5)*256+math.floor(c[3]+.5)end
local cycle=o.radiance_middle_cycle
local m0=roles(at(link('Radiance',o),R0+cycle,o))['radiance-middle']
local m1=roles(at(link('Radiance',o),R0+cycle*1.5,o))['radiance-middle']
near(rgb(m0.colors[1]),packed(fusion[1]),1,'Fusion at the cycle start')
near(rgb(m1.colors[#m1.colors]),packed(frag[#frag]),1,'Fragmentation halfway')
-- Turns at the level-4 disc speed x middle spin.
local st=link('Radiance',o).model.states[71]
near(roles(at(link('Radiance',o),2,o))['radiance-middle'].rotation,M.disc_rotation(st,2,o),1e-9,'level-4 speed')
local fast=copy(o);fast.radiance_middle_spin=-2
near(roles(at(link('Radiance',fast),2,fast))['radiance-middle'].rotation,-2*M.disc_rotation(st,2,o),1e-9,'middle spin')
-- Sizes; shared level-4 shape.
local sz=copy(o);sz.radiance_bottom_size=1.5;sz.radiance_middle_size=.5;sz.disc_level4_middle=.9
local s2=roles(at(link('Radiance',sz),1,sz))
near(s2['radiance-bottom'].radius,d.property.radius*1.5,1e-9);near(s2['radiance-middle'].radius,d.property.radius*.5,1e-9)
near(s2['radiance-middle'].mid,.9,1e-9,'level-4 shape applies')
-- Off, Umbra, killala.
local off=copy(o);off.radiance_stack=false
assert(not roles(at(link('Radiance',off),1,off))['radiance-middle'],'stack off')
assert(not roles(at(link('Umbra',o),1,o))['radiance-middle'],'Umbra has no stack')
-- Glyph own opacity: breath peaks at the setting, dims to setting x breath min.
local g=copy(o);g.radiance_glyph_opacity=.9;g.mb_breath_min=.7;g.mb_breath_gain=1
local lo,hi=1,0
local gp=link('Radiance',g)
for t=3.5,7.5,.02 do gp:advance(t)for _,x in ipairs(gp.model:frame(71,t,2,4,g).discs)do if x.role=='mb-glyph'then
    lo=math.min(lo,alpha(x.outline)/255);hi=math.max(hi,alpha(x.outline)/255)end end end
near(hi,.9,.01,'peak = glyph opacity');near(lo,.63,.01,'trough = glyph opacity x breath min')
-- Commands, presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('radiance',{'stack','off'});assert(settings.radiance_stack==false)
cmd('radiance',{'stack','on'});assert(settings.radiance_stack==true)
cmd('radiance',{'stack','height','.05'});cmd('radiance',{'stack','spacing','.02'})
cmd('radiance',{'bottom','opacity','.3'});cmd('radiance',{'bottom','size','1.4'})
cmd('radiance',{'middle','opacity','.7'});cmd('radiance',{'middle','size','.8'})
cmd('radiance',{'middle','cycle','2'});cmd('radiance',{'middle','spin','-1'})
assert(settings.radiance_stack_height==.05 and settings.radiance_stack_spacing==.02 and settings.radiance_bottom_opacity==.3)
assert(settings.radiance_bottom_size==1.4 and settings.radiance_middle_opacity==.7 and settings.radiance_middle_size==.8)
assert(settings.radiance_middle_cycle==2 and settings.radiance_middle_spin==-1)
cmd('preset',{'killala'});assert(settings.radiance_stack==false)
cmd('preset',{'default'});assert(settings.radiance_stack==true)
print('PASS Test5.5 Radiance three-disc stack: order, spacing, direct opacities, stack height, Fusion/Fragmentation crossfade, level-4 turn x spin, sizes, shape, off/Umbra/killala; glyph opacity peak/trough; commands')
