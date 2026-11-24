-- Test7.24: level-2 lit disc (two lit quarters in the property's two colors,
-- opposite or half, sliced center), lit sliced for level 1/3, and the
-- level-3 Light under disc following the darkness under settings. Simulated.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance');local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<=(e or 1e-6),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function rgb(c)return c%16777216 end
local d=R.defaults
assert(d.lit2_shape=='opposite'and d.lit2_opacity==.6 and d.lit2_size==1 and d.lit2_spin==2 and d.lit2_depth==.003
    and d.lit2_inner==1 and d.lit2_outer==0 and d.lit_sliced==false,'lit2 defaults')
assert(d.light_under==true and d.light_under_opacity==-1 and d.light_under_direction=='darkness','light under follows darkness')
local function link(prop,level)return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=level,
    properties={prop},elements=R.elements(prop)}end
local function frame(s,t,o)R.native_level=14;local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local function role(f,name)local r={}for i,x in ipairs(f and f.discs or {})do if x.role==name then x.index=i;r[#r+1]=x end end return r end

for _,style in ipairs({'clapper','classic'})do
 for _,blend in ipairs({'gradient','firm'})do
    local o=copy(d);o.mb_style=style;o.disc_blend=blend;o.lit_level2=true
    local f=frame(link('Fusion',2),104,o)
    local L,F=role(f,'lit')[1],role(f,'property')[1]
    local m=style..'/'..blend
    assert(L and F and L.index<F.index,m..' level-2 lit disc under the fill')
    assert(L.sliced==true and L.blend==1 and #L.colors==4,m..' sliced, gradient, four quarters')
    near(L.inner,1);near(L.outer,0)
    near(L.offset,F.offset-.003,1e-9,m..' depth');near(L.radius,2*.78,1e-9,m..' size')
    near(L.rotation,F.rotation*2,1e-9,m..' spin')
    -- Opposite: quarters 1 and 3 lit in the fill's two colors, 2 and 4 clear.
    local fc=F.colors
    assert(rgb(L.colors[1])==rgb(fc[1])and rgb(L.colors[3])==rgb(fc[#fc])and rgb(fc[1])~=rgb(fc[#fc]),m..' two property colors, facing')
    assert(alpha(L.colors[1])==math.floor(.6*255+.5)and alpha(L.colors[3])==alpha(L.colors[1]),m..' lit quarters at .6 (absolute)')
    assert(alpha(L.colors[2])==0 and alpha(L.colors[4])==0,m..' clear quarters')
    -- Half: side by side.
    local h=copy(o);h.lit2_shape='half'
    local H=role(frame(link('Fusion',2),104,h),'lit')[1]
    assert(rgb(H.colors[1])==rgb(fc[1])and rgb(H.colors[2])==rgb(fc[#fc])and alpha(H.colors[2])>0
        and alpha(H.colors[3])==0 and alpha(H.colors[4])==0,m..' half: two lit quarters side by side')
    -- Own settings.
    local z=copy(o);z.lit2_opacity=1;z.lit2_size=1.2;z.lit2_spin=-1;z.lit2_depth=.01;z.lit2_inner=.8;z.lit2_outer=.1
    local Z=role(frame(link('Fusion',2),104,z),'lit')[1]
    assert(alpha(Z.colors[1])==255);near(Z.radius,2*.78*1.2,1e-9);near(Z.rotation,-F.rotation,1e-9);near(Z.offset,F.offset-.01,1e-9)
    near(Z.inner,.8);near(Z.outer,.1)
    local dim=copy(o);dim.opacity=.05
    assert(alpha(role(frame(link('Fusion',2),104,dim),'lit')[1].colors[1])==alpha(L.colors[1]),m..' ignores addon opacity')
    -- Flash-in (lit start both): white, all quarters lit, at landing.
    local f0=role(frame(link('Fusion',2),100,o),'lit')[1]
    assert(rgb(f0.colors[1])==0xFFFFFF and alpha(f0.colors[2])==alpha(f0.colors[1]),m..' white flash-in, all quarters')
    -- Off by lit_level2; level 1 is the half disc without slicing by default.
    local off=copy(o);off.lit_level2=false
    assert(#role(frame(link('Fusion',2),104,off),'lit')==0,m..' level2 off')
    local l1=role(frame(link('Scission',1),104,o),'lit')[1]
    assert(l1 and #l1.colors==2 and not l1.sliced,m..' level 1 unchanged')
    local sl=copy(o);sl.lit_sliced=true
    assert(role(frame(link('Scission',1),104,sl),'lit')[1].sliced==true,m..' lit sliced on')
 end
end

-- Light under: Fusion<->Fragmentation under level-3 Light, following darkness under.
do
    local o=copy(d);o.mb_style='clapper';o.darkness_under_opacity=1;o.darkness_under_size=1.5;o.darkness_under_spin=1
    local f=frame(link('Light',3),104,o)
    local U,F=role(f,'light-under')[1],role(f,'property')[1]
    assert(U and U.index<F.index,'light under below the fill')
    assert(alpha(U.colors[1])==255,'follows darkness opacity');near(U.radius,2*.78*1.5,1e-9,'follows darkness size')
    near(U.rotation,F.rotation,1e-9,'follows darkness spin');near(U.offset,F.offset-.006,1e-9,'follows darkness depth')
    near(U.inner,1);near(U.outer,0)
    -- Its colors are Fusion/Fragmentation, not Gravitation/Distortion.
    local D=role(frame(link('Darkness',3),104,o),'darkness-under')[1]
    assert(rgb(U.colors[1])~=rgb(D.colors[1]),'own colors')
    -- Own values override.
    local own=copy(o);own.light_under_opacity=.5;own.light_under_size=1;own.light_under_spin=3;own.light_under_direction='reverse'
    local V=role(frame(link('Light',3),104,own),'light-under')[1]
    assert(alpha(V.colors[1])==128);near(V.radius,2*.78,1e-9);near(V.rotation,-3*F.rotation,1e-9)
    local off=copy(o);off.light_under=false
    assert(#role(frame(link('Light',3),104,off),'light-under')==0,'light under off')
    assert(#role(frame(link('Fusion',2),104,o),'light-under')==0,'Light only')
    -- With lit level3 on: under, lit, fill.
    local l3=copy(o);l3.lit_level3=true
    local g=frame(link('Light',3),104,l3)
    assert(role(g,'light-under')[1].index<role(g,'lit')[1].index and role(g,'lit')[1].index<role(g,'property')[1].index,'order')
end

-- Commands.
do
    local s=copy(d);local said={}
    local cmd=C.new(s,d,function()end,function(m)said[#said+1]=m end)
    assert(cmd('lit2',{'shape','half'})and s.lit2_shape=='half')
    assert(cmd('lit2',{'opacity','.8'})and s.lit2_opacity==.8)
    assert(cmd('lit2',{'size','1.1'})and s.lit2_size==1.1)
    assert(cmd('lit2',{'spin','3'})and s.lit2_spin==3)
    assert(cmd('lit2',{'depth','.005'})and s.lit2_depth==.005)
    assert(cmd('lit2',{'fade','1','.2'})and s.lit2_inner==1 and s.lit2_outer==.2)
    assert(cmd('lit',{'sliced','on'})and s.lit_sliced==true)
    assert(cmd('lit',{'level2','on'})and s.lit_level2==true)
    assert(cmd('light',{'under','opacity','.7'})and s.light_under_opacity==.7)
    assert(cmd('light',{'under','opacity','same'})and s.light_under_opacity==-1)
    assert(cmd('light',{'under','direction','reverse'})and s.light_under_direction=='reverse')
    assert(cmd('light',{'under','fade','same','.3'})and s.light_under_center==-1 and s.light_under_edge==.3)
    assert(cmd('light',{'under','off'})and s.light_under==false)
    for _,m in ipairs(said)do assert(not m:find('[\128-\255]'),'ASCII chat')end
end
print('PASS Test7.24 level-2 lit disc (opposite/half quarters, sliced, own settings), lit sliced, light under (follows darkness, own overrides), commands')
