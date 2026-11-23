-- Test7.21 lit disc: a fill disc just under a link's property disc, one side
-- lit (half / firm half / quarter), flashing in white and fading to the
-- property color; own spin, side swap, size, absolute opacity, radial fade.
-- Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<=(e or 1e-6),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function rgb(c)return c%16777216 end
local d=R.defaults
assert(d.lit==true and d.lit_level1==true and d.lit_level2==false and d.lit_level3==false,'level defaults')
assert(d.lit_bursts==true and d.lit_shape=='half'and d.lit_start=='both'and d.lit_flash==.4 and d.lit_spin==2 and d.lit_cycle==0,'shape defaults')
assert(d.lit_size==1 and d.lit_opacity==.6 and d.lit_inner==1 and d.lit_outer==1 and d.lit_depth==.003,'size defaults')

local function link(prop,level)return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=level,
    properties={prop},elements=R.elements(prop)}end
local opener={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,properties={'Scission'},elements=R.elements('Scission')}
local function frame(s,t,o)R.native_level=13;local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local function role(f,name)local r={}for i,x in ipairs(f and f.discs or {})do if x.role==name then x.index=i;r[#r+1]=x end end return r end

for _,style in ipairs({'clapper','classic'})do
    local o=copy(d);o.mb_style=style
    -- Level 1 link: one lit disc, drawn just before (under) the property fill.
    local f=frame(link('Scission',1),104,o)
    local lit,prop=role(f,'lit'),role(f,'property')
    assert(#lit==1 and #prop>=1,style..' one lit disc')
    local L,F=lit[1],prop[1]
    assert(L.index<F.index,style..' lit drawn under the property fill')
    near(L.offset,F.offset-.003,1e-9,style..' depth')
    near(L.radius,2*.78,1e-9,style..' size = property fill')
    assert(L.blend==1 and L.glyph==0 and L.outline==0 and #L.colors==2,style..' soft half, gradient, no lines')
    -- Settled (4 s after the link): lit side at .6 absolute, other side clear, property color.
    assert(alpha(L.colors[1])==math.floor(.6*255+.5)and alpha(L.colors[2])==0,style..' half lit '..alpha(L.colors[1])..'/'..alpha(L.colors[2]))
    local sc=rgb(F.colors[1])
    assert(rgb(L.colors[1])==sc and sc~=0xFFFFFF,style..' property color')
    -- Absolute opacity: the addon opacity does not scale it.
    local dim=copy(o);dim.opacity=.1
    assert(alpha(role(frame(link('Scission',1),104,dim),'lit')[1].colors[1])==alpha(L.colors[1]),style..' ignores addon opacity')
    -- Spin: 2x the property disc.
    near(L.rotation,F.rotation*2,1e-9,style..' spin x2')
    -- Flash in: white with both sides lit at the link moment.
    local f0=role(frame(link('Scission',1),100,o),'lit')[1]
    assert(rgb(f0.colors[1])==0xFFFFFF and alpha(f0.colors[2])==alpha(f0.colors[1]),style..' both sides white at landing')
    local one=copy(o);one.lit_start='one'
    local f1=role(frame(link('Scission',1),100,one),'lit')[1]
    assert(rgb(f1.colors[1])==0xFFFFFF and alpha(f1.colors[2])==0,style..' start one: only the lit side')
    -- After lit_flash it is the property color.
    -- After lit_flash: the property color, through the same MB intro whitening
    -- as the property fill (lit bursts on), or the plain color (lit bursts off).
    local fa=frame(link('Scission',1),100.41,o)
    assert(rgb(role(fa,'lit')[1].colors[1])==rgb(role(fa,'property')[1].colors[1]),style..' follows the property fill')
    local nb=copy(o);nb.lit_bursts=false
    assert(rgb(role(frame(link('Scission',1),100.41,nb),'lit')[1].colors[1])==sc,style..' bursts off: plain color')
    -- Shapes.
    local q=copy(o);q.lit_shape='quarter'
    local Q=role(frame(link('Scission',1),104,q),'lit')[1]
    assert(#Q.colors==4 and alpha(Q.colors[1])>0 and alpha(Q.colors[2])==0 and alpha(Q.colors[3])==0 and alpha(Q.colors[4])==0,style..' quarter')
    local fi=copy(o);fi.lit_shape='firm'
    local FI=role(frame(link('Scission',1),104,fi),'lit')[1]
    assert(#FI.colors==4 and alpha(FI.colors[2])>0 and alpha(FI.colors[3])==0,style..' firm half')
    -- Side swap: half a cycle later the other side is lit.
    local cy=copy(o);cy.lit_cycle=2
    local a1=role(frame(link('Scission',1),104,cy),'lit')[1]   -- t=4 s: whole cycles, side 1
    local a2=role(frame(link('Scission',1),105,cy),'lit')[1]   -- t=5 s: half cycle, side 2
    assert(alpha(a1.colors[1])>0 and alpha(a1.colors[2])==0,style..' cycle side 1')
    assert(alpha(a2.colors[1])==0 and alpha(a2.colors[2])>0,style..' cycle side 2')
    local qc=copy(q);qc.lit_cycle=2
    local q2=role(frame(link('Scission',1),105,qc),'lit')[1]
    assert(alpha(q2.colors[3])>0 and alpha(q2.colors[1])==0,style..' quarter swaps to the opposite quarter')
    -- Size, opacity, fade, depth.
    local z=copy(o);z.lit_size=1.5;z.lit_opacity=1;z.lit_inner=.5;z.lit_outer=0;z.lit_depth=.01
    local Z=role(frame(link('Scission',1),104,z),'lit')[1]
    near(Z.radius,2*.78*1.5,1e-9,style..' size');assert(alpha(Z.colors[1])==255,style..' opacity 1')
    near(Z.inner,.5);near(Z.outer,0);near(Z.offset,F.offset-.01,1e-9,style..' depth')
    -- Levels: 2/3 off by default; on when asked. Opener and level 4 never.
    assert(#role(frame(link('Fusion',2),104,o),'lit')==0,style..' level 2 off')
    local l2=copy(o);l2.lit_level2=true
    assert(#role(frame(link('Fusion',2),104,l2),'lit')==1,style..' level 2 on')
    assert(#role(frame(opener,101,o),'lit')==0,style..' no lit disc on the opener')
    local l4=copy(o);l4.lit_level3=true
    assert(#role(frame(link('Radiance',4),104,l4),'lit')==0,style..' no lit disc on level 4')
    -- Off: the frame is the old frame exactly (no other disc changes).
    local off=copy(o);off.lit=false
    local fo=frame(link('Scission',1),104,off)
    assert(#fo.discs==#f.discs-1 and #role(fo,'lit')==0,style..' lit off')
    -- Fades with the property disc after the MB window.
    local gone=frame(link('Scission',1),130,o)
    assert(#role(gone,'lit')==0,style..' gone after the window')
end

-- Preview path (E4b): `preview mb` (level-1 Scission link) shows the lit disc.
do
    local o=copy(d);R.native_level=13
    local p=P.new(assert(P.parse({'mb'},R)),111,0,R,o)
    local seen=false
    for t=0,12,.25 do
        p:advance(t)
        local f=p.model:frame(111,t,2,4,o)
        for _,x in ipairs(f.discs or {})do if x.role=='lit'then seen=true end end
    end
    assert(seen,'preview mb shows the lit disc')
end

-- Commands.
do
    local s=copy(d);local said={}
    local cmd=C.new(s,d,function()end,function(m)said[#said+1]=m end)
    assert(cmd('lit',{'off'})and s.lit==false);assert(cmd('lit',{'on'})and s.lit==true)
    assert(cmd('lit',{'bursts','off'})and s.lit_bursts==false)
    assert(cmd('lit',{'level2','on'})and s.lit_level2==true)
    assert(cmd('lit',{'shape','quarter'})and s.lit_shape=='quarter')
    assert(cmd('lit',{'start','one'})and s.lit_start=='one')
    assert(cmd('lit',{'flash','.8'})and s.lit_flash==.8)
    assert(cmd('lit',{'spin','3'})and s.lit_spin==3)
    assert(cmd('lit',{'cycle','1.5'})and s.lit_cycle==1.5)
    assert(cmd('lit',{'size','1.2'})and s.lit_size==1.2)
    assert(cmd('lit',{'opacity','.9'})and s.lit_opacity==.9)
    assert(cmd('lit',{'opacity','2'})and s.lit_opacity==.9,'opacity range 0-1')
    assert(cmd('lit',{'fade','1','.2'})and s.lit_inner==1 and s.lit_outer==.2)
    assert(cmd('lit',{'depth','.01'})and s.lit_depth==.01)
    assert(cmd('lit',{'shape','oval'})and s.lit_shape=='quarter','bad shape kept')
    for _,m in ipairs(said)do assert(not m:find('[\128-\255]'),'ASCII chat')end
end
print('PASS Test7.21 lit disc: half/firm/quarter, white flash-in (both|one), color, spin, side swap, size, absolute opacity, fade, depth, levels, preview, commands')
