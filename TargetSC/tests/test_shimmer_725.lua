-- Test7.25: glyph shimmer on link property glyphs (riding the lit disc's lit
-- side), lit sliced per property (Darkness, Compression), and the level-2
-- under disc in the property's own colors. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance');local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<=(e or 1e-6),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function rgb(c)return c%16777216 end
local d=R.defaults
assert(d.glyph_shimmer==true and d.glyph_shimmer_spin==1 and d.glyph_shimmer_width==-1 and d.glyph_shimmer_far==.35
    and d.glyph_shimmer_gain==.8 and d.glyph_shimmer_count==1 and d.glyph_shimmer_offset==0,'shimmer defaults')
assert(d.lit_sliced_props=='Darkness,Compression'and d.level2_under==true and d.level2_under_opacity==-1,'sliced list, level2 under')
local function link(prop,level)return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=level,
    properties={prop},elements=R.elements(prop)}end
local opener={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,properties={'Scission'},elements=R.elements('Scission')}
local function frame(s,t,o)R.native_level=15;local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local function role(f,name)local r={}for i,x in ipairs(f and f.discs or {})do if x.role==name then x.index=i;r[#r+1]=x end end return r end
local function glyphs(f)local r={}for _,x in ipairs(f.discs)do if x.shimmer then r[#r+1]=x end end return r end

for _,style in ipairs({'clapper','classic'})do
    local o=copy(d);o.mb_style=style
    local f=frame(link('Scission',1),104,o)
    local g=glyphs(f)
    assert(#g>=1,style..' a shimmered glyph')
    local lit,fill=role(f,'lit')[1],role(f,'property')[1]
    for _,x in ipairs(g)do
        assert(x.glyph~=0 and x.outline>=16777216,style..' only on glyph lines')
        -- Rides the lit disc's lit side: its rotation + 90 deg (half shape).
        near(x.shimmer.angle,lit.rotation+math.pi/2,1e-9,style..' patch on the lit side')
        near(x.shimmer.width,math.rad(70),1e-9,style..' auto width (half)')
        near(x.shimmer.far,.35);near(x.shimmer.gain,.8);assert(x.shimmer.count==1)
    end
    assert(not lit.shimmer and not fill.shimmer or fill.glyph~=0,style..' fills plain')
    -- Quarter lit disc: patch at +45 deg, 45 deg half-width.
    local q=copy(o);q.lit_shape='quarter'
    local fq=frame(link('Scission',1),104,q)
    local x=glyphs(fq)[1]
    near(x.shimmer.angle,role(fq,'lit')[1].rotation+math.pi/4,1e-9,style..' quarter: +45');near(x.shimmer.width,math.rad(45),1e-9)
    -- Spin is a multiple of the lit disc's turn; offset in degrees.
    local sp=copy(o);sp.glyph_shimmer_spin=2;sp.glyph_shimmer_offset=30;sp.glyph_shimmer_width=20;sp.glyph_shimmer_count=2
    local fs=frame(link('Scission',1),104,sp)
    local y=glyphs(fs)[1]
    near(y.shimmer.angle,role(fs,'lit')[1].rotation*2+math.pi/2+math.rad(30),1e-9,style..' spin x2 + offset')
    near(y.shimmer.width,math.rad(20),1e-9);assert(y.shimmer.count==2)
    -- Every link level 1-3 (Light/Darkness too), not openers, not level 4; off removes it.
    assert(#glyphs(frame(link('Fusion',2),104,o))>=1 and #glyphs(frame(link('Darkness',3),104,o))>=1,style..' levels 2-3')
    assert(#glyphs(frame(opener,101,o))==0,style..' no opener shimmer')
    assert(#glyphs(frame(link('Radiance',4),104,o))==0,style..' no level-4 shimmer')
    local off=copy(o);off.glyph_shimmer=false
    assert(#glyphs(frame(link('Scission',1),104,off))==0,style..' off')
    -- Sliced list: Compression and Darkness sliced, others not.
    local l3=copy(o);l3.lit_level3=true;l3.lit_level3_light=false
    assert(role(frame(link('Compression',1),104,o),'lit')[1].sliced==true,style..' Compression sliced')
    assert(role(frame(link('Darkness',3),104,l3),'lit')[1].sliced==true,style..' Darkness sliced')
    assert(not role(frame(link('Scission',1),104,o),'lit')[1].sliced and not role(frame(link('Light',3),104,l3),'lit')[1].sliced,style..' others plain')
    local all=copy(o);all.lit_sliced=true
    assert(role(frame(link('Scission',1),104,all),'lit')[1].sliced==true,style..' lit sliced on = all')
    local none=copy(o);none.lit_sliced_props=''
    assert(not role(frame(link('Compression',1),104,none),'lit')[1].sliced,style..' empty list')
    -- Level-2 under disc: the fill's own palette, steady, below the fill, following darkness under.
    local u=copy(o);u.darkness_under_size=1.5;u.darkness_under_spin=1;u.darkness_under_opacity=1
    local f2a,f2b=frame(link('Fusion',2),101,u),frame(link('Fusion',2),105,u)
    local A,B,F2=role(f2a,'level2-under')[1],role(f2b,'level2-under')[1],role(f2b,'property')[1]
    assert(A and B and B.index<F2.index,style..' level2 under below the fill')
    assert(#B.colors==2 and rgb(A.colors[1])==rgb(B.colors[1])and rgb(A.colors[2])==rgb(B.colors[2]),style..' steady colors')
    assert(rgb(B.colors[1])~=rgb(B.colors[2]),style..' the property\'s two colors')
    near(B.radius,2*.78*1.5,1e-9);assert(alpha(B.colors[1])==255);near(B.rotation,F2.rotation,1e-9)
    local own=copy(u);own.level2_under_size=1;own.level2_under_direction='reverse'
    local O=role(frame(link('Fusion',2),105,own),'level2-under')[1]
    near(O.radius,2*.78,1e-9);near(O.rotation,-F2.rotation,1e-9)
    local no=copy(u);no.level2_under=false
    assert(#role(frame(link('Fusion',2),105,no),'level2-under')==0,style..' level2 under off')
    assert(#role(frame(link('Scission',1),105,u),'level2-under')==0,style..' level 2 only')
end

-- Commands.
do
    local s=copy(d);local said={}
    local cmd=C.new(s,d,function()end,function(m)said[#said+1]=m end)
    assert(cmd('glyph',{'shimmer','off'})and s.glyph_shimmer==false);assert(cmd('glyph',{'shimmer','on'})and s.glyph_shimmer==true)
    for k,v in pairs({spin='2',width='50',far='0',gain='1',count='2',offset='-30'})do
        assert(cmd('glyph',{'shimmer',k,v})and s['glyph_shimmer_'..k]==tonumber(v),k)
    end
    assert(cmd('lit',{'sliced','scission','on'})and s.lit_sliced_props=='Darkness,Compression,Scission')
    assert(cmd('lit',{'sliced','compression','off'})and s.lit_sliced_props=='Darkness,Scission')
    assert(cmd('lit',{'sliced','off'})and s.lit_sliced==false);assert(cmd('lit',{'sliced','on'})and s.lit_sliced==true)
    assert(cmd('level2',{'under','size','1.2'})and s.level2_under_size==1.2)
    assert(cmd('level2',{'under','size','same'})and s.level2_under_size==-1)
    assert(cmd('level2',{'under','direction','reverse'})and s.level2_under_direction=='reverse')
    assert(cmd('level2',{'under','off'})and s.level2_under==false)
    for _,m in ipairs(said)do assert(not m:find('[\128-\255]'),'ASCII chat')end
end
print('PASS Test7.25 glyph shimmer (rides the lit side, auto width, spin multiple, offset, count, levels, off), lit sliced per property, level-2 under disc, commands')
