-- Test5.4: level-4 open time; Umbra flash-out bloom (ring-shaped black,
-- shrink/stay/grow), Umbra MB ring ending-style pulses all window (lined up
-- with the real ending) and its size, Umbra disc size; Radiance disc lines
-- hidden and a still, breathing large MB glyph with its own size/opacity/buzz.
-- Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion');local B=require('resonance_burst')
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
local function disc(f,role)for _,d in ipairs(f.discs)do if d.role==role then return d end end end
local function mbcore(f)for _,v in ipairs(f)do if v.part=='mb'and v.role=='core'then return v end end end
local o=copy(R.defaults)
local st=link('Umbra',o).model.states[71]
-- Open time: the visual opening ends at created + open time.
local early=copy(o);early.umbra_open_time=1.5
assert(at(link('Umbra',early),1.6,early).phase=='terminal'and at(link('Umbra',o),1.6,o).phase=='pre','umbra open time')
local re=copy(o);re.radiance_open_time=5
assert(at(link('Radiance',re),4,re).phase=='pre','radiance open time can stretch')
assert(link('Umbra',early).model.states[71].sc_open==st.sc_open,'real state untouched')
-- Umbra bloom: starts when the last ring has flashed; black; shaped by the
-- MB bloom stops; shrinks with growth < 0, stays at 0, grows > 0.
local start=M.umbra_flashed(st,o,true)
local u=link('Umbra',o)
assert(not disc(at(u,start-.01,o),'umbra-bloom'),'not before the flash-out')
local b1=disc(at(u,start+.3,o),'umbra-bloom')
local b2=disc(at(u,start+1.5,o),'umbra-bloom')
assert(b1 and b2 and rgb(b1.color)==0,'black bloom')
assert(b2.radius<b1.radius,'shrinks inward by default')
assert(alpha(b2.color)<alpha(b1.color),'fades')
near(b1.inner,o.mb_bloom_center);near(b1.mid,o.mb_bloom_middle);near(b1.mid_pos,o.mb_bloom_position);near(b1.outer,o.mb_bloom_edge)
assert(not disc(at(u,start+o.umbra_bloom_time+.01,o),'umbra-bloom'),'gone after bloom time')
local stay=copy(o);stay.umbra_bloom_growth=0
near(disc(at(link('Umbra',stay),start+1.5,stay),'umbra-bloom').radius,disc(at(link('Umbra',stay),start+.3,stay),'umbra-bloom').radius,1e-9,'0 stays')
local grow=copy(o);grow.umbra_bloom_growth=1
assert(disc(at(link('Umbra',grow),start+1.5,grow),'umbra-bloom').radius>disc(at(link('Umbra',grow),start+.3,grow),'umbra-bloom').radius,'>0 grows')
local strong=copy(o);strong.umbra_bloom_opacity=1
assert(alpha(disc(at(link('Umbra',strong),start+.3,strong),'umbra-bloom').color)>alpha(b1.color),'own opacity')
local up=copy(o);up.umbra_bloom_height='mb'
assert(math.abs(disc(at(link('Umbra',up),start+.3,up),'umbra-bloom').offset-b1.offset)>.01,'height choice')
-- No per-ring smoke in bloom mode; smoke mode still works; off leaves nothing.
local smokef=at(link('Umbra',o),start+.3,o)
for _,v in ipairs(smokef)do assert(v.part=='mb'or v.role~='glow','no smoke glows with after bloom')end
local sm=copy(o);sm.umbra_after='smoke'
local found=false for _,v in ipairs(at(link('Umbra',sm),start+.3,sm))do if v.part~='mb'and v.role=='glow'then found=true end end
assert(found and not disc(at(link('Umbra',sm),start+.3,sm),'umbra-bloom'),'smoke mode')
local none=copy(o);none.umbra_after='off'
assert(not disc(at(link('Umbra',none),start+.3,none),'umbra-bloom'),'off')
-- Umbra MB ring: white ending-style pulses all window, seamless into the ending.
local ending=o.mb_ending
local function pulse(t)return M.umbra_pulse(st,t,o)end
local function real(t)return B.ending(math.max(0,math.min(1,1-(st.mb_close-t)/ending)),o.mb_ending_style)end
for _,d in ipairs({.05,.2,.4,.6,.9,1.3,1.7})do near(pulse(st.mb_close-ending+d),real(st.mb_close-ending+d),1e-9,'same rhythm as the ending')end
near(pulse(st.mb_close-ending-.001),0,.001,'meets the ending at a pulse boundary')
assert(pulse(4.35)>.3 and math.abs(pulse(4.35)-pulse(4.35-ending))<1e-9,'repeats across the window')
local mid=mbcore(at(link('Umbra',o),5,o))
assert(rgb(mid.color)==0xFFFFFF,'white pulses instead of the purple ring')
local cl=copy(o);cl.umbra_mb='classic'
assert(rgb(mbcore(at(link('Umbra',cl),5,cl)).color)~=0xFFFFFF,'classic purple')
local function mb_at(t,opts)return mbcore(at(link('Umbra',opts),t,opts))end
local h1=mb_at(5,o).offset;local h2=mb_at(st.mb_close-.5,o).offset
assert(h2<h1,'sinks only in the real ending');near(mb_at(5.7,o).offset,h1,1e-9,'no sinking before')
local big=copy(o);big.umbra_mb_size=2
near(mb_at(5,big).radius,mb_at(5,o).radius*2,1e-9,'umbra mb size')
-- Umbra disc size beyond the level-4 size.
local huge=copy(o);huge.umbra_disc_size=8
near(disc(at(link('Umbra',huge),1,huge),'property').radius,disc(at(link('Umbra',o),1,o),'property').radius*8,1e-6,'umbra disc size')
local r4=copy(o);r4.umbra_disc_size=8
near(disc(at(link('Radiance',r4),1,r4),'property').radius,disc(at(link('Radiance',o),1,o),'property').radius,1e-9,'Radiance unaffected')
-- Radiance: disc lines hidden by default; glyph still, breathing, own size/opacity/buzz.
assert(not disc(at(link('Radiance',o),5,o),'property-trace'),'disc lines hidden')
local lines=copy(o);lines.radiance_disc_lines=true
assert(disc(at(link('Radiance',lines),5,lines),'property-trace'),'disc lines on')
local spin=copy(o);spin.disc_speed_level4=3
local rp=link('Radiance',spin)
local g=disc(at(rp,5,spin),'mb-glyph');local g2=disc(at(rp,6.2,spin),'mb-glyph')
assert(g and g.rotation==0 and g2.rotation==0,'never turns')
local seen={}for _,t in ipairs({4.2,4.7,5.2,5.7})do seen[#seen+1]=alpha(disc(at(link('Radiance',o),t,o),'mb-glyph').outline)end
assert(math.max(unpack(seen))>math.min(unpack(seen)),'breathes at rest')
local size=copy(o);size.radiance_glyph_size=1.5
near(disc(at(link('Radiance',size),5,size),'mb-glyph').radius,disc(at(link('Radiance',o),5,o),'mb-glyph').radius*1.5,1e-9,'glyph size')
local own=copy(o);own.radiance_glyph_opacity=1
local peak=0 for t=4,6,.05 do peak=math.max(peak,alpha(disc(at(link('Radiance',own),t,own),'mb-glyph').outline))end
assert(peak>230,'own opacity 1 reaches full at the breath peak')
local nobuzz=copy(o);nobuzz.radiance_glyph_buzz=false
local hs={}for _,t in ipairs({.5,.7,.9,1.1})do hs[#hs+1]=disc(at(link('Radiance',o),t,o),'mb-glyph').offset end
local hn={}for _,t in ipairs({.5,.7,.9,1.1})do hn[#hn+1]=disc(at(link('Radiance',nobuzz),t,nobuzz),'mb-glyph').offset end
assert(math.max(unpack(hs))-math.min(unpack(hs))>math.max(unpack(hn))-math.min(unpack(hn)),'buzzes with the rings')
local same=copy(o);same.radiance_glyph='same';same.mb_spin=.1
assert(disc(at(link('Radiance',same),5,same),'mb-glyph')==nil or disc(at(link('Radiance',same),5,same),'mb-glyph').rotation~=0,'same: back to the normal glyph')
-- Commands and presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('radiance',{'open','time','2'});assert(settings.radiance_open_time==2)
cmd('radiance',{'open','time','same'});assert(settings.radiance_open_time==-1)
cmd('umbra',{'open','time','1.5'});assert(settings.umbra_open_time==1.5)
cmd('umbra',{'after','smoke'});assert(settings.umbra_after=='smoke')
cmd('umbra',{'bloom','opacity','.9'});cmd('umbra',{'bloom','time','4'});cmd('umbra',{'bloom','size','1.3'})
cmd('umbra',{'bloom','growth','-1'});cmd('umbra',{'bloom','height','disc'})
assert(settings.umbra_bloom_opacity==.9 and settings.umbra_bloom_time==4 and settings.umbra_bloom_size==1.3)
assert(settings.umbra_bloom_growth==-1 and settings.umbra_bloom_height=='disc')
cmd('umbra',{'mb','classic'});assert(settings.umbra_mb=='classic')
cmd('umbra',{'mb','pulse'});assert(settings.umbra_mb=='pulse','mb pulse is the look, not a number')
cmd('umbra',{'mb','strength','.5'});cmd('umbra',{'mb','size','1.6'});cmd('umbra',{'disc','size','9'})
assert(settings.umbra_mb_strength==.5 and settings.umbra_mb_size==1.6 and settings.umbra_disc_size==9)
cmd('umbra',{'disc','size','same'});assert(settings.umbra_disc_size==-1)
cmd('radiance',{'disc','lines','on'});assert(settings.radiance_disc_lines==true)
cmd('radiance',{'glyph','same'});assert(settings.radiance_glyph=='same')
cmd('radiance',{'glyph','size','2'});cmd('radiance',{'glyph','opacity','.7'});cmd('radiance',{'glyph','buzz','off'})
assert(settings.radiance_glyph_size==2 and settings.radiance_glyph_opacity==.7 and settings.radiance_glyph_buzz==false)
cmd('preset',{'killala'})
assert(settings.umbra_after=='smoke'and settings.umbra_mb=='classic'and settings.radiance_disc_lines==true and settings.radiance_glyph=='same')
cmd('preset',{'default'})
assert(settings.umbra_after=='bloom'and settings.umbra_mb=='pulse'and settings.radiance_disc_lines==false and settings.radiance_glyph=='breath')
print('PASS Test5.4 level-4: open times; Umbra flash-out bloom (black, MB bloom shape, shrink/stay/grow, own opacity, height, smoke/off modes); Umbra MB ring pulses all window in the ending rhythm, sinks only in the ending, size; Umbra disc size; Radiance disc lines hidden, glyph still/breathing/size/own opacity/buzz; commands; presets')
