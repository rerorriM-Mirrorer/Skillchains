-- Test7.22: the white awakening disc as each MB window's ending (full
-- opening size, just under the descending MB ring, ease-out rise to an
-- absolute opacity at the touch, fading with the ring), and the lit disc
-- taking the property fill's own colors plus `lit level3 light`. Simulated.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<=(e or 1e-6),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function rgb(c)return c%16777216 end
local d=R.defaults
assert(d.awakening_ending==true and d.awakening_ending_level1 and d.awakening_ending_level2 and d.awakening_ending_level3
    and d.awakening_ending_radiance==true and d.awakening_ending_umbra==true,'stage defaults')
assert(d.awakening_ending_opacity==1 and d.awakening_ending_curve==3 and d.awakening_ending_gap==.005,'tunable defaults')
assert(d.lit_level3_light==true,'lit level3 light default')
local function link(prop,level)return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=level,
    properties={prop},elements=R.elements(prop)}end
local function frame(s,t,o)R.native_level=13;local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local function role(f,name)local r={}for i,x in ipairs(f and f.discs or {})do if x.role==name then x.index=i;r[#r+1]=x end end return r end
local function mb_ring(f)for _,v in ipairs(f or {})do if v.part=='mb'and v.role=='core'then return v end end end

for _,ending in ipairs({'soft','converge'})do
    local o=copy(d);o.mb_style='clapper';o.mb_ending_style=ending;o.mb_ending=2;o.mb_ending_fade=.8
    local L=link('Scission',1)
    -- Before the ending (window still open, 3 s left): none.
    assert(#role(frame(L,107,o),'awakening-end')==0,ending..' none before the ending')
    -- Ending progress p: just below the MB ring, ease-out opacity, full opening size.
    local prev=-1
    for _,p in ipairs({.1,.25,.5,.75,.95})do
        local f=frame(L,108+2*p,o)
        local a=role(f,'awakening-end')
        assert(#a==1,ending..' one ending disc at p='..p)
        local x=a[1]
        local ring=mb_ring(f)
        assert(ring,ending..' mb ring')
        near(x.offset,ring.offset-.005,1e-6,ending..' just under the ring p='..p)
        near(x.radius,2*.96*o.awakening_size,1e-9,ending..' full opening size')
        local want=math.floor((1-(1-p)^3)*255+.5)
        assert(math.abs(alpha(x.color)-want)<=1,ending..' ease-out opacity p='..p..' '..alpha(x.color)..' vs '..want)
        assert(alpha(x.color)>prev,ending..' rising');prev=alpha(x.color)
        assert(rgb(x.color)==0xFFFFFF and x.inner==o.awakening_inner and x.outer==o.awakening_outer,ending..' white, awakening fade')
    end
    -- Fast at first: half the opacity in well under half the ending.
    assert(alpha(role(frame(L,108+2*.25,o),'awakening-end')[1].color)>=.5*255,ending..' fast at first')
    -- Absolute opacity: the addon opacity does not scale it.
    local dim=copy(o);dim.opacity=.05
    assert(alpha(role(frame(L,109.5,dim),'awakening-end')[1].color)==alpha(role(frame(L,109.5,o),'awakening-end')[1].color),ending..' absolute')
    local half=copy(o);half.awakening_ending_opacity=.5
    assert(math.abs(alpha(role(frame(L,109.99,half),'awakening-end')[1].color)-128)<=2,ending..' opacity .5 at the touch')
    -- After the deadline: soft ends with the ring; converge fades with it.
    local after=frame(L,110.4,o)
    if ending=='soft'then assert(#role(after,'awakening-end')==0,'soft: gone with the ring')
    else
        local x=role(after,'awakening-end')[1]
        assert(x and alpha(x.color)>0 and alpha(x.color)<255,'converge: fading with the ring')
        near(x.offset,mb_ring(after).offset-.005,1e-6,'converge: still under the ring')
        assert(#role(frame(L,110.9,o),'awakening-end')==0,'converge: gone after mb ending fade')
    end
    -- Toggles: global, per level, Radiance on, Umbra off.
    local off=copy(o);off.awakening_ending=false
    assert(#role(frame(L,109,off),'awakening-end')==0,ending..' off')
    local l2=copy(o);l2.awakening_ending_level2=false
    assert(#role(frame(link('Fusion',2),109,l2),'awakening-end')==0 and #role(frame(link('Fusion',2),109,o),'awakening-end')==1,ending..' level2 toggle')
    assert(#role(frame(link('Radiance',4),109,o),'awakening-end')==1,ending..' radiance on')
    local uo=copy(o);uo.awakening_ending_umbra=false;uo.umbra_collapse=false
    assert(#role(frame(link('Umbra',4),109,uo),'awakening-end')==0,ending..' umbra off')
    local um=copy(o);um.awakening_ending_umbra=true;um.umbra_collapse=false
    assert(#role(frame(link('Umbra',4),109,um),'awakening-end')==1,ending..' umbra on')
    -- Classic MB style: not drawn.
    local cl=copy(o);cl.mb_style='classic'
    assert(#role(frame(L,109,cl),'awakening-end')==0,ending..' clapper only')
end

-- Lit disc: the property fill's own final color (here mb pure Light whitening), and level3 light.
do
    local o=copy(d);o.mb_style='clapper'
    for _,t in ipairs({100.2,104,109})do
        local f=frame(link('Scission',1),t,o)
        local lit,fill=role(f,'lit')[1],role(f,'property')[1]
        if t>100.45 then assert(rgb(lit.colors[1])==rgb(fill.colors[1]),'lit = property fill color at '..t)end
        assert(lit.index<fill.index,'under the fill')
    end
    local l3=copy(o);l3.lit_level3=true
    assert(#role(frame(link('Light',3),104,l3),'lit')==1,'level3 Light')
    assert(#role(frame(link('Darkness',3),104,l3),'lit')==0,'level3 light only: no Darkness')
    local all=copy(l3);all.lit_level3_light=false
    assert(#role(frame(link('Darkness',3),104,all),'lit')==1,'level3 all')
    -- Light 'elements' look: the white center.
    local el=copy(l3);el.disc_lightdark='elements'
    local x=role(frame(link('Light',3),104,el),'lit')[1]
    assert(x and rgb(x.colors[1])==0xFFFFFF,'Light elements look: white center')
end

-- Preview (E4b): `preview mb light` (the final Light window closes) shows the
-- ending disc; `preview mb` ends on Umbra, which is off by default.
do
    local o=copy(d);o.mb_style='clapper';R.native_level=13
    local p=P.new(assert(P.parse({'mb','light'},R)),111,0,R,o)
    local seen=false
    for t=0,30,.1 do p:advance(t)
        for _,x in ipairs(p.model:frame(111,t,2,4,o).discs or {})do if x.role=='awakening-end'then seen=true end end end
    assert(seen,'preview mb light shows the awakening ending')
end

-- Commands.
do
    local s=copy(d);local said={}
    local cmd=C.new(s,d,function()end,function(m)said[#said+1]=m end)
    assert(cmd('awakening',{'ending','off'})and s.awakening_ending==false)
    assert(cmd('awakening',{'ending','on'})and s.awakening_ending==true)
    assert(cmd('awakening',{'ending','umbra','on'})and s.awakening_ending_umbra==true)
    assert(cmd('awakening',{'ending','level2','off'})and s.awakening_ending_level2==false)
    assert(cmd('awakening',{'ending','opacity','.7'})and s.awakening_ending_opacity==.7)
    assert(cmd('awakening',{'ending','curve','5'})and s.awakening_ending_curve==5)
    assert(cmd('awakening',{'ending','gap','.01'})and s.awakening_ending_gap==.01)
    assert(cmd('awakening',{'opacity','.5'})and s.awakening_opacity==.5,'plain awakening still works')
    assert(cmd('lit',{'level3','on'})and s.lit_level3==true and s.lit_level3_light==false)
    assert(cmd('lit',{'level3','light'})and s.lit_level3==true and s.lit_level3_light==true)
    assert(cmd('lit',{'level3','off'})and s.lit_level3==false)
    for _,m in ipairs(said)do assert(not m:find('[\128-\255]'),'ASCII chat')end
end
print('PASS Test7.22 awakening ending (under the descending MB ring, ease-out to absolute opacity, fades with the ring, stage toggles), lit = property fill color, lit level3 light')
