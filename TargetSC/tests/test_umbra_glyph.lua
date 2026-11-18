-- Test5.6: Umbra own spin, same-size sky rings, two ring-height blooms, the
-- breathing turning floor glyph at the black disc's plane, and the glyph
-- copies under the disc through the opening. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
R.native_level=10
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function link(o,name)
    local p=P.new(P.parse({'Radiance','4'},R),71,0,R,o)
    if name~='Radiance'then local st=p.model.states[71];st.properties={'Umbra'};st.elements=R.elements('Umbra')end
    return p
end
local function at(p,t,o)p:advance(t)return p.model:frame(71,t,2,4,o)end
local function all(f,role)local r={}for k,d in ipairs(f.discs)do if d.role==role then r[#r+1]=d;d.index=k end end return r end
local function ring(f,part,j)for _,v in ipairs(f)do if v.part==part and v.strand==j and v.role=='core'then return v end end end
local o=copy(R.defaults);o.disc_speed_level4=3
-- Own spin: faster than the level-4 setting.
local function rot(opts,name)return all(at(link(opts,name),1,opts),'property')[1].rotation end
local six=copy(o);six.umbra_spin=6
assert(rot(six)>rot(o)*1.9,'umbra spin 6 vs level4 3')
near(rot(six,'Radiance'),rot(o,'Radiance'),1e-9,'Radiance keeps level-4 speed')
-- Sky rings same size as ground rings; bell flares.
local f=at(link(o),1,o)
near(ring(f,'sky',4).radius,ring(f,'ground',4).radius,1e-9,'same circumference')
local bell=copy(o);bell.umbra_sky='bell'
assert(ring(at(link(bell),1,bell),'sky',4).radius>ring(at(link(bell),1,bell),'ground',4).radius,'bell flares')
assert(ring(at(link(o,'Radiance'),1,o),'sky',4).radius>ring(at(link(o,'Radiance'),1,o),'ground',4).radius,'Radiance still flares')
-- Two blooms at the ground and sky ring heights.
local st=link(o).model.states[71]
local start=M.umbra_flashed(st,o,true)
local bf=at(link(o),start+.3,o)
local b=all(bf,'umbra-bloom')
assert(#b==2 and b[2].offset>b[1].offset,'two blooms, ground then sky')
near(b[1].radius,b[2].radius,1e-9,'same size with sky same')
local one=copy(o);one.umbra_bloom_height='ground'
assert(#all(at(link(one),start+.3,one),'umbra-bloom')==1,'single bloom for ground')
-- Floor glyph: at the black disc's exact plane, MB ring size, turns with the disc.
local g=copy(o);g.umbra_mb_size=1.4;g.umbra_glyph_size=1.2
local gf=at(link(g),5,g)
local glyph=all(gf,'mb-glyph')[1];local fill=all(gf,'property')[1]
near(glyph.offset,fill.offset,1e-9,'same height as the disc')
local mbr for _,v in ipairs(gf)do if v.part=='mb'and v.role=='core'then mbr=v.radius end end
near(glyph.radius,mbr*1.2,1e-9,'MB ring size x glyph size')
near(glyph.rotation,fill.rotation,1e-9,'turns with the disc')
local gs=copy(g);gs.umbra_glyph_spin=-2
near(all(at(link(gs),5,gs),'mb-glyph')[1].rotation,-2*fill.rotation,1e-9,'glyph spin')
assert(glyph.index<fill.index,'drawn under the disc by default (same plane)')
local ov=copy(g);ov.umbra_glyph_over=true
local of=at(link(ov),5,ov)
assert(all(of,'mb-glyph')[1].index>all(of,'property')[1].index,'glyph over')
local seen={}for _,t in ipairs({4.2,4.7,5.2,5.7})do seen[#seen+1]=math.floor(all(at(link(o),t,o),'mb-glyph')[1].outline/16777216)end
assert(math.max(unpack(seen))>math.min(unpack(seen)),'breathes')
-- Copies: every .6 s from creation until the flash-out, each 1.2 s, under the disc.
local c=at(link(o),.3,o)
assert(#all(c,'umbra-copy')==1,'first copy at creation')
local c2=at(link(o),1.3,o)
local cc=all(c2,'umbra-copy')
assert(#cc==2 and cc[1].radius>cc[2].radius,'older copy further out')
assert(cc[2].index<all(c2,'property')[1].index,'copies before the disc in draw order')
near(cc[1].offset,all(c2,'property')[1].offset-o.umbra_copies_depth,1e-9,'just under the disc')
assert(cc[1].glyph==2,'glyph lines')
assert(#all(at(link(o),start+o.umbra_copies_life+.05,o),'umbra-copy')==0,'none after the flash-out once the last ends')
local slow=copy(o);slow.umbra_copies_every=2;slow.umbra_copies_life=3
assert(#all(at(link(slow),1.3,slow),'umbra-copy')==1,'every and life adjustable')
local off=copy(o);off.umbra_copies=false
assert(#all(at(link(off),1.3,off),'umbra-copy')==0,'copies off')
assert(#all(at(link(o,'Radiance'),1.3,o),'umbra-copy')==0,'Umbra only')
-- Commands, presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('umbra',{'spin','6'});assert(settings.umbra_spin==6)
cmd('umbra',{'spin','7'});assert(settings.umbra_spin==6,'range 0-6')
cmd('umbra',{'spin','same'});assert(settings.umbra_spin==-1)
cmd('umbra',{'sky','bell'});assert(settings.umbra_sky=='bell')
cmd('umbra',{'bloom','height','rings'});assert(settings.umbra_bloom_height=='rings')
cmd('umbra',{'glyph','same'});cmd('umbra',{'glyph','breath'});assert(settings.umbra_glyph=='breath')
cmd('umbra',{'glyph','size','1.3'});cmd('umbra',{'glyph','opacity','.8'});cmd('umbra',{'glyph','spin','2'});cmd('umbra',{'glyph','over','on'})
assert(settings.umbra_glyph_size==1.3 and settings.umbra_glyph_opacity==.8 and settings.umbra_glyph_spin==2 and settings.umbra_glyph_over==true)
cmd('umbra',{'copies','off'});cmd('umbra',{'copies','on'})
cmd('umbra',{'copies','every','.8'});cmd('umbra',{'copies','life','2'});cmd('umbra',{'copies','size','2'})
cmd('umbra',{'copies','opacity','.7'});cmd('umbra',{'copies','spin','-1'});cmd('umbra',{'copies','depth','.01'})
assert(settings.umbra_copies and settings.umbra_copies_every==.8 and settings.umbra_copies_life==2 and settings.umbra_copies_size==2)
assert(settings.umbra_copies_opacity==.7 and settings.umbra_copies_spin==-1 and settings.umbra_copies_depth==.01)
cmd('preset',{'killala'});assert(settings.umbra_sky=='bell'and settings.umbra_glyph=='same'and settings.umbra_copies==false)
cmd('preset',{'default'});assert(settings.umbra_sky=='same'and settings.umbra_copies==true and settings.umbra_bloom_height=='rings')
print('PASS Test5.6 Umbra: own spin, same-size sky rings, two ring-height blooms, floor glyph at the disc plane (size, turn, spin, under/over, breath), copies (timing, order, depth, adjustable, off, Umbra only), commands, presets')
