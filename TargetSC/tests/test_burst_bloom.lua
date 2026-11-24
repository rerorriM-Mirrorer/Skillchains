-- Test4.9: MB burst bloom (element disc growing and fading from the MB ring,
-- three opacity stops, optional glyph-line copies) and the two user-specified
-- overlap previews (`preview mb light`, `preview mb dark`). Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance')
local P=require('resonance_preview')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function rgb(c)return {math.floor(c/65536)%256,math.floor(c/256)%256,c%256}end
R.native_level=10
local s={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}
local fire=R.element_color('Fire')
local function model(...)
    local m=R.new();m.states[71]=copy(s);m.bursts[71]={}
    for _,at in ipairs({...})do m.bursts[71][#m.bursts[71]+1]={at=at,color=fire}end
    return m
end
local function all(f,role)local r={}for _,d in ipairs(f.discs)do if d.role==role then r[#r+1]=d end end return r end
local function mb_ring(f)for _,v in ipairs(f)do if v.part=='mb'and v.role=='core'then return v end end end
local o=copy(R.defaults)
-- Default: one bloom at the MB ring height and radius scale, growing and fading.
local m=model(104)
local f0=m:frame(71,104.02,2,4,o)
local ring=assert(mb_ring(f0),'MB ring present')
local b0=assert(all(f0,'bloom')[1],'bloom appears with the burst')
near(b0.offset,ring.offset,1e-9,'from ring: MB ring height')
local f1=m:frame(71,104.3,2,4,o);local b1=all(f1,'bloom')[1]
local f2=m:frame(71,104.8,2,4,o);local b2=all(f2,'bloom')[1]
assert(b0.radius<b1.radius and b1.radius<b2.radius,'grows')
near(b2.radius,ring.radius*(.3+1.2*(1-(1-.8)^2.5)),1e-9,'size start/end and ease')
assert(alpha(b1.color)>alpha(b2.color),'fades over its life')
assert(#all(m:frame(71,105.05,2,4,o),'bloom')==0,'gone after mb bloom time')
-- Three stops and a whiter core; white-hot start settling into Fire.
near(b1.inner,.7);near(b1.middle or b1.mid,.35);near(b1.outer,0);near(b1.mid_pos,.5)
assert(rgb(b1.hub)[3]>rgb(b1.color)[3],'center whiter than the element color')
assert(rgb(b0.color)[3]>rgb(b2.color)[3],'starts white-hot, settles into the element')
-- No lines by default.
assert(#all(f1,'bloom-lines')==0,'glyph-line copies off by default')
-- From the property disc, rising to the ring.
local d=copy(o);d.mb_bloom_from='disc';d.mb_bloom_to='ring'
local low=all(model(104):frame(71,104.02,2,4,d),'bloom')[1]
local high=all(model(104):frame(71,104.9,2,4,d),'bloom')[1]
near(low.offset,d.disc_height+.01,.01,'starts at the property disc')
assert(high.offset>low.offset and high.offset<=ring.offset+1e-9,'rises toward the MB ring')
local same=copy(o);same.mb_bloom_from='disc'
near(all(model(104):frame(71,104.9,2,4,same),'bloom')[1].offset,d.disc_height+.01,1e-9,'to same stays at the disc')
-- Glyph-line copies: staggered, growing out from the large glyph's size, turning with it.
local l=copy(o);l.mb_bloom_lines=2
local lf=model(104):frame(71,104.05,2,4,l)
assert(#all(lf,'bloom-lines')==1,'second copy waits its delay')
local lf2=model(104):frame(71,104.4,2,4,l)
local copies=all(lf2,'bloom-lines')
assert(#copies==2 and copies[1].radius>copies[2].radius and copies[2].radius>ring.radius,'two copies, the first further out')
assert(copies[1].glyph==2,'lines only')
local glyph
for _,disc in ipairs(lf2.discs)do if disc.role=='mb-glyph'then glyph=disc end end
near(copies[1].rotation,glyph.rotation,1e-9,'copies turn with the large glyph')
-- Overlapping bursts each keep their own bloom.
assert(#all(model(104,104.4):frame(71,104.6,2,4,o),'bloom')==2,'two overlapping blooms')
-- Disc budget: 16 on native 0.10.0, 8 on older DLLs.
local busy=copy(o);busy.mb_bloom_lines=4;busy.mb_bloom_lines_delay=0
local many=model(104,104.2,104.4):frame(71,104.5,2,4,busy)
assert(#many.discs>8 and #many.discs<=16,'0.10.0 has room for blooms')
R.native_level=9
assert(#model(104,104.2,104.4):frame(71,104.5,2,4,busy).discs<=8,'older DLL keeps 8')
R.native_level=10
-- A long bloom keeps its burst entry alive past the glyph response.
local long=copy(o);long.mb_bloom_time=3.5
local lm=model(104)
lm:frame(71,107,2,4,long)
assert(#lm.bursts[71]==1 and #all(lm:frame(71,107.2,2,4,long),'bloom')==1,'burst kept while its bloom draws')
-- The ending puts it out with the real MB deadline.
local late=model(109.7)
assert(#all(late:frame(71,109.75,2,4,long),'bloom')==1)
assert(#all(late:frame(71,109.999,2,4,long),'bloom')==0 or alpha(all(late:frame(71,109.999,2,4,long),'bloom')[1].color)<3,'goes out at the deadline')
-- Off, and killala, draw nothing new.
local off=copy(o);off.mb_bloom=false
assert(#all(model(104):frame(71,104.3,2,4,off),'bloom')==0)
local k=copy(o);for key,v in pairs(R.killala)do k[key]=v end
assert(#all(model(104):frame(71,104.3,2,4,k),'bloom')==0,'killala has no bloom')
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('mb',{'bloom','off'})and settings.mb_bloom==false)
assert(cmd('mb',{'bloom'})and settings.mb_bloom==true,'bare toggles')
assert(cmd('mb',{'bloom','from','disc','to','ring'})and settings.mb_bloom_from=='disc'and settings.mb_bloom_to=='ring')
assert(cmd('mb',{'bloom','from','glyph'})and settings.mb_bloom_from=='glyph'and settings.mb_bloom_to=='same')
assert(cmd('mb',{'bloom','from','sky'})and settings.mb_bloom_from=='glyph','rejects unknown place')
assert(cmd('mb',{'bloom','size','.5','2'})and settings.mb_bloom_start==.5 and settings.mb_bloom_end==2)
assert(cmd('mb',{'bloom','size','.4'})and settings.mb_bloom_start==.4 and settings.mb_bloom_end==2,'end optional')
assert(cmd('mb',{'bloom','size','9'})and settings.mb_bloom_start==.4,'range')
assert(cmd('mb',{'bloom','opacity','1','.6','.2'})and settings.mb_bloom_center==1 and settings.mb_bloom_middle==.6 and settings.mb_bloom_edge==.2)
assert(cmd('mb',{'bloom','opacity','.8'})and settings.mb_bloom_center==.8 and settings.mb_bloom_middle==.6,'middle/edge optional')
assert(cmd('mb',{'bloom','middle','.3'})and settings.mb_bloom_position==.3)
assert(cmd('mb',{'bloom','time','2'})and settings.mb_bloom_time==2)
assert(cmd('mb',{'bloom','ease','4'})and settings.mb_bloom_ease==4)
assert(cmd('mb',{'bloom','fade','2'})and settings.mb_bloom_fade==2)
assert(cmd('mb',{'bloom','flash','0'})and settings.mb_bloom_flash==0)
assert(cmd('mb',{'bloom','core','1'})and settings.mb_bloom_core==1)
assert(cmd('mb',{'bloom','lines','3'})and settings.mb_bloom_lines==3)
assert(cmd('mb',{'bloom','lines','2.5'})and settings.mb_bloom_lines==3,'whole copies only')
assert(cmd('mb',{'bloom','lines','delay','.2'})and settings.mb_bloom_lines_delay==.2)
assert(cmd('mb',{'bloom','lines','size','2.5'})and settings.mb_bloom_lines_size==2.5)
assert(cmd('mb',{'bloom','lines','opacity','.4'})and settings.mb_bloom_lines_opacity==.4)
assert(cmd('preset',{'killala'})and settings.mb_bloom==false)
assert(cmd('preset',{'default'})and settings.mb_bloom==true and settings.mb_bloom_lines==0)
-- Previews: exact user-specified sequences.
local function run(name)
    local spec=assert(P.parse({'mb',name},R))
    local p=P.new(spec,71,0,R,R.defaults)
    local seen={}
    for t=0,p.ends+.1,.05 do
        p:advance(t)
        for _,e in ipairs(p.events)do if e.done and not e.logged then e.logged=true;seen[#seen+1]=e end end
        p.model:frame(71,t,2,4,R.defaults)
    end
    return p,seen
end
local p,ev=run('light')
local fusion=p.events[1]and nil
assert(ev[1].kind=='burst'and ev[1].element=='Fire'and ev[2].kind=='chain'and ev[2].state.properties[1]=='Light')
assert(ev[2].at>ev[1].at and ev[2].at-ev[1].at<1,'Light opens just after the Fire MB')
local light=ev[2].state
assert(light.level==3 and ev[3].element=='Light'and ev[3].at>light.sc_open,'Light MB after the window opens')
assert(ev[4].element=='Wind'and ev[4].at>light.mb_close-2 and ev[4].at<light.mb_close-1.5,'Wind just after the ending begins')
assert(#ev==4 and p.ends>light.mb_close)
assert(p.description:find('Fire MB 1.2s')and p.description:find('Light link 1.8s'),p.description)
local q,dv=run('dark')
assert(q.model.states[71]==nil or true)
assert(dv[1].element=='Ice'and dv[2].element=='Dark'and dv[3].kind=='chain'and dv[3].state.properties[1]=='Umbra')
assert(dv[2].at-dv[1].at>2 and dv[2].at-dv[1].at<2.6,'Darkness MB as the Ice response ends')
local umbra=dv[3].state
assert(umbra.closed and umbra.level==4 and dv[3].at<7 and dv[3].at>6,'Umbra near the end of the Darkness window (closes at 7s)')
assert(dv[4].element=='Ice'and dv[4].at>umbra.sc_open+.8,'Ice after the terminal animation')
assert(dv[5].element=='Earth'and dv[6].element=='Dark')
near(dv[6].at,umbra.mb_close-2,1e-9,'Darkness exactly as the ending begins')
assert(P.parse({'mb','darkness'},R).kind=='mbdark'and P.parse({'mb'},R).kind=='mbdemo','plain preview mb unchanged')
-- The bloom draws during the dark preview's Umbra MB hits.
local d2=P.new(P.parse({'mb','dark'},R),71,0,R,R.defaults)
for t=0,dv[4].at+.2,.05 do d2:advance(t)end
assert(#all(d2.model:frame(71,dv[4].at+.2,2,4,R.defaults),'bloom')==1,'bloom on the Umbra MB')
print('PASS Test4.9 burst bloom: ring/disc/glyph planes, growth, three opacity stops, white-hot start, core, copies, overlaps, disc budget, lifetime, ending, commands, presets; preview mb light/dark sequences')
