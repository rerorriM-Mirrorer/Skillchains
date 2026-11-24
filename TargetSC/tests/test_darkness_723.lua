-- Test7.23: level-3 lit disc colors (Light white|mix, Darkness black|mix),
-- Darkness void awakening / void flash, the Darkness under disc, and the
-- awakening ending on for Umbra by default. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<=(e or 1e-6),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function rgb(c)return c%16777216 end
local d=R.defaults
assert(d.awakening_ending_umbra==true,'umbra ending on')
assert(d.lit_light=='white'and d.lit_darkness=='black','lit level-3 colors')
assert(d.darkness_awakening_void==false and d.darkness_flash_void==false,'void looks off')
assert(d.darkness_under==true and d.darkness_under_opacity==.6 and d.darkness_under_size==1.3 and d.darkness_under_spin==2
    and d.darkness_under_direction=='same'and d.darkness_under_cycle==3 and d.darkness_under_depth==.006
    and d.darkness_under_center==1 and d.darkness_under_edge==0,'darkness under defaults')
local function link(prop,level)return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=level,
    properties={prop},elements=R.elements(prop)}end
local function frame(s,t,o)R.native_level=13;local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local function role(f,name)local r={}for i,x in ipairs(f and f.discs or {})do if x.role==name then x.index=i;r[#r+1]=x end end return r end
local function avg(cs)local t={0,0,0}for _,c in ipairs(cs)do t[1]=t[1]+math.floor(c/65536)%256/#cs;t[2]=t[2]+math.floor(c/256)%256/#cs;t[3]=t[3]+c%256/#cs end return t end

for _,style in ipairs({'clapper','classic'})do
    local o=copy(d);o.mb_style=style;o.lit_level3=true;o.lit_level3_light=false
    -- Darkness: black lit disc, the under disc below it, both under the fill.
    local f=frame(link('Darkness',3),104,o)
    local lit,under,fill=role(f,'lit')[1],role(f,'darkness-under')[1],role(f,'property')[1]
    assert(lit and under and fill,style..' darkness discs')
    assert(under.index<lit.index and lit.index<fill.index,style..' order: under, lit, fill')
    assert(rgb(lit.colors[1])==0,style..' black lit disc')
    near(under.offset,fill.offset-.006,1e-9,style..' under depth')
    near(under.radius,2*.78*1.3,1e-9,style..' under size')
    near(under.rotation,fill.rotation*2,1e-9,style..' under spin')
    assert(alpha(under.colors[1])==math.floor(.6*255+.5),style..' under absolute opacity')
    near(under.inner,1);near(under.outer,0)
    local dim=copy(o);dim.opacity=.05
    assert(alpha(role(frame(link('Darkness',3),104,dim),'darkness-under')[1].colors[1])==alpha(under.colors[1]),style..' under ignores addon opacity')
    local rev=copy(o);rev.darkness_under_direction='reverse'
    near(role(frame(link('Darkness',3),104,rev),'darkness-under')[1].rotation,-fill.rotation*2,1e-9,style..' reverse')
    -- Color swings Gravitation <-> Distortion over the cycle.
    local u0=role(frame(link('Darkness',3),100,o),'darkness-under')[1]
    local u1=role(frame(link('Darkness',3),101.5,o),'darkness-under')[1]
    assert(rgb(u0.colors[1])~=rgb(u1.colors[1]),style..' under color cycles')
    local off=copy(o);off.darkness_under=false
    assert(#role(frame(link('Darkness',3),104,off),'darkness-under')==0,style..' under off')
    assert(#role(frame(link('Light',3),104,o),'darkness-under')==0 and #role(frame(link('Fusion',2),104,o),'darkness-under')==0,style..' Darkness only')
    -- lit darkness mix = the fill's colors averaged.
    local mx=copy(o);mx.lit_darkness='mix'
    local fm=frame(link('Darkness',3),104,mx)
    assert(rgb(role(fm,'lit')[1].colors[1])~=0,style..' darkness mix not black')
    -- Light: white center with the elements look; mix = average of its sectors.
    local el=copy(o);el.disc_lightdark='elements'
    local lw=role(frame(link('Light',3),104,el),'lit')[1]
    assert(rgb(lw.colors[1])==0xFFFFFF,style..' light white')
    local lm=copy(el);lm.lit_light='mix'
    local fl=frame(link('Light',3),104,lm)
    local want=avg(role(fl,'property')[1].colors)
    local got=role(fl,'lit')[1].colors[1]
    assert(math.abs(math.floor(got/65536)%256-want[1])<=1 and math.abs(got%256-want[3])<=1 and rgb(got)~=0xFFFFFF,style..' light mix = average')
    -- Void flash: the Darkness fill flashes toward black at the window intro (not white).
    local plain=role(frame(link('Darkness',3),100.1,o),'property')[1]
    local vo=copy(o);vo.darkness_flash_void=true
    local vf=frame(link('Darkness',3),100.1,vo)
    local void=role(vf,'property')[1]
    local function bright(c)return math.floor(c/65536)%256+math.floor(c/256)%256+c%256 end
    assert(bright(void.colors[1])<bright(plain.colors[1]),style..' void flash darker than the white flash')
    assert(rgb(role(vf,'lit')[1].colors[1])==0,style..' darkness lit flashes in black with void')
    -- Light is unaffected by the Darkness void flash.
    local lp=role(frame(link('Light',3),100.1,o),'property')[1]
    assert(rgb(role(frame(link('Light',3),100.1,vo),'property')[1].colors[1])==rgb(lp.colors[1]),style..' Light flash unchanged')
end

-- Void awakening: a Darkness link's awakening disc is black; others stay white.
do
    local o=copy(d);o.mb_style='clapper';o.darkness_awakening_void=true
    local function aw(prop,level)
        for _,t in ipairs({100.3,100.6,101})do local x=role(frame(link(prop,level),t,o),'awakening')[1] if x then return x end end
    end
    local a=aw('Darkness',3);assert(a and rgb(a.colors[1])==0,'void awakening on Darkness')
    local b=aw('Light',3);assert(b and rgb(b.colors[1])==0xFFFFFF,'Light awakening stays white')
    local w=copy(o);w.darkness_awakening_void=false
    local c;for _,t in ipairs({100.3,100.6,101})do c=c or role(frame(link('Darkness',3),t,w),'awakening')[1]end
    assert(c and rgb(c.colors[1])==0xFFFFFF,'white by default')
end

-- Preview (E4b): `preview mb dark` plays a Darkness link with the under disc.
do
    local o=copy(d);R.native_level=13
    local p=P.new(assert(P.parse({'mb','dark'},R)),111,0,R,o)
    local seen=false
    for t=0,20,.1 do p:advance(t)
        for _,x in ipairs(p.model:frame(111,t,2,4,o).discs or {})do if x.role=='darkness-under'then seen=true end end end
    assert(seen,'preview mb dark shows the darkness under disc')
end

-- Commands.
do
    local s=copy(d);local said={}
    local cmd=C.new(s,d,function()end,function(m)said[#said+1]=m end)
    assert(cmd('lit',{'light','mix'})and s.lit_light=='mix');assert(cmd('lit',{'darkness','mix'})and s.lit_darkness=='mix')
    assert(cmd('lit',{'darkness','pink'})and s.lit_darkness=='mix','bad value kept')
    assert(cmd('darkness',{'awakening','void'})and s.darkness_awakening_void==true)
    assert(cmd('darkness',{'flash','void'})and s.darkness_flash_void==true)
    assert(cmd('darkness',{'flash','white'})and s.darkness_flash_void==false)
    assert(cmd('darkness',{'under','off'})and s.darkness_under==false);assert(cmd('darkness',{'under','on'})and s.darkness_under==true)
    assert(cmd('darkness',{'under','opacity','.9'})and s.darkness_under_opacity==.9)
    assert(cmd('darkness',{'under','size','1.1'})and s.darkness_under_size==1.1)
    assert(cmd('darkness',{'under','spin','-3'})and s.darkness_under_spin==-3)
    assert(cmd('darkness',{'under','cycle','5'})and s.darkness_under_cycle==5)
    assert(cmd('darkness',{'under','depth','.01'})and s.darkness_under_depth==.01)
    assert(cmd('darkness',{'under','direction','reverse'})and s.darkness_under_direction=='reverse')
    assert(cmd('darkness',{'under','fade','.5','.2'})and s.darkness_under_center==.5 and s.darkness_under_edge==.2)
    assert(cmd('lit',{'shape','quarter'})and s.lit_shape=='quarter','other lit commands still work')
    for _,m in ipairs(said)do assert(not m:find('[\128-\255]'),'ASCII chat')end
end
print('PASS Test7.23 lit light white|mix, lit darkness black|mix, darkness under (order, size, spin, cycle, absolute opacity), void flash/awakening, umbra ending default on, preview mb dark, commands')
