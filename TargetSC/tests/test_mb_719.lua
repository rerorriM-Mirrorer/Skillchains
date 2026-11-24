-- Test7.19: mb pure (Light MBs pure white, Dark MBs pure black at full
-- opacity on the bloom band, property disc rims and MB glyphs, fading back),
-- A's 05:21 cioara preset. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
R.native_level=12
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function profile()local a=copy(require('tests.fixture_cioara_1122c'))for k,v in pairs(R.defaults)do if a[k]==nil then a[k]=v end end return a end
local function rgb(c)return c%16777216 end
local function alpha(c)return math.floor(c/16777216)end
local function hex(t)return math.floor(t[1]+.5)*65536+math.floor(t[2]+.5)*256+math.floor(t[3]+.5)end
local function run(element,t,o,id)
    id=id or 101
    local p=P.new(assert(P.parse({'burst',element},R)),id,0,R,o);p:advance(t)
    return p.model:frame(id,t,2,4,o),p
end
local function roles(f,role)local r={}for _,d in ipairs(f.discs or {})do if d.role==role then r[#r+1]=d end end return r end

local d=R.defaults
assert(d.mb_pure=='off'and d.mb_pure_disc==1.5 and d.mb_pure_glyph==2.5 and d.mb_pure_ring_glyph==4 and d.mb_pure_bloom_flash==0,'defaults')
local o=profile();R.apply_colors(o)
assert(o.mb_shimmer_style=='soft'and o.dark_ring_back_gain==.18 and o.mb_ring_hold==1.8,'05:21 fixture')

-- Burst entries carry their element (preview path, E4b).
local _,pl=run('Light',.7,o)
assert(pl.model.bursts[101][1].element=='Light','element kept')

-- Off: the Light bloom stays under the MB overall opacity.
local off=run('Light',.6+.3,o)
local b_off=roles(off,'bloom')[1];assert(b_off and alpha(b_off.color)<0.7*255,'off bloom scaled')

-- Light pure: bloom band white, full opacity; disc rims white, opaque, clear center; glyphs white.
local L=copy(o);L.mb_pure='both'
local fl=run('Light',.6+.3,L)
local b=roles(fl,'bloom')[1]
assert(rgb(b.color)==0xFFFFFF and alpha(b.color)>alpha(b_off.color),'Light bloom pure white, brighter')
assert(rgb(b.hub)==0xFFFFFF,'hub white')
local pd=roles(fl,'property')[1]
assert(pd and alpha(pd.color)>=200,'disc near full opacity')
for _,c in ipairs(pd.colors)do assert(rgb(c)>=0xF0F0F0,'disc white')end
assert(pd.inner<.2 and pd.outer>.95,'rims opaque, center clear')
local tr=roles(fl,'property-trace')[1];assert(tr and rgb(tr.outline)>=0xF0F0F0 and alpha(tr.outline)>=200,'trace glyph white')
local mg=roles(fl,'mb-glyph')[1];assert(mg and rgb(mg.outline)>=0xF0F0F0 and alpha(mg.outline)>=200,'large glyph white')
-- Fades back: the disc by 1.5 s, the ring glyph lasts longer.
local late=run('Light',.6+2.0,L)
for _,c in ipairs(roles(late,'property')[1].colors)do assert(rgb(c)~=0xFFFFFF,'disc back to normal')end
local mg2=roles(late,'mb-glyph')[1];assert(mg2 and alpha(mg2.outline)>100,'ring glyph still fading')

-- Dark pure: void black bloom and black hub, black disc rims and glyphs.
local fd=run('Dark',.6+.3,L)
local bd=roles(fd,'bloom')[1]
assert(rgb(bd.color)==0 and rgb(bd.hub)==0 and alpha(bd.color)>alpha(b_off.color),'Dark bloom total void')
for _,c in ipairs(roles(fd,'property')[1].colors)do assert(rgb(c)<0x101010,'disc black')end
assert(rgb(roles(fd,'mb-glyph')[1].outline)<0x101010,'glyph black')
-- Dark bloom flash option.
local Lf=copy(L);Lf.mb_pure_bloom_flash=1
assert(rgb(roles(run('Dark',.6+.02,Lf),'bloom')[1].color)~=0,'flash before the void')

-- light only ignores Dark; Fire never changes.
local Lo=copy(o);Lo.mb_pure='light'
local fo,ff=run('Fire',.6+.3,o),run('Fire',.6+.3,L)
assert(rgb(roles(fo,'bloom')[1].color)==rgb(roles(ff,'bloom')[1].color)and alpha(roles(fo,'bloom')[1].color)==alpha(roles(ff,'bloom')[1].color),'Fire untouched')
local dl=run('Dark',.6+.3,Lo);local dn=run('Dark',.6+.3,o)
assert(alpha(roles(dl,'bloom')[1].color)==alpha(roles(dn,'bloom')[1].color),'light mode leaves Dark alone')

-- Whole Requiescat Dark MB demo plays through with pure on.
local pv=P.new(P.parse({'dark','mb'},R),102,0,R,L);local t=0
while not pv:advance(t)do assert(pv.model:frame(102,t,2,4,L));t=t+.2 end

-- Commands + preset.
local settings=copy(d);local said
local cmd=C.new(settings,d,function()end,function(m)said=m end,R.killala,R.cioara)
assert(cmd('mb',{'pure','both'})and settings.mb_pure=='both')
assert(cmd('mb',{'pure','light'})and settings.mb_pure=='light')
assert(cmd('mb',{'pure','disc','2'})and settings.mb_pure_disc==2)
assert(cmd('mb',{'pure','glyph','3'})and settings.mb_pure_glyph==3)
assert(cmd('mb',{'pure','ring','6'})and settings.mb_pure_ring_glyph==6)
assert(cmd('mb',{'pure','flash','.5'})and settings.mb_pure_bloom_flash==.5)
assert(cmd('mb',{'pure','grey'})and settings.mb_pure=='light'and said:find('^Use'))
assert(not said:find('[\128-\255]'),'ASCII')
assert(cmd('preset',{'cioara'}))
for k,v in pairs(R.cioara)do assert(settings[k]==v,'preset '..k)end
assert(settings.mb_shimmer_turn==3 and settings.mb_ring_ease==3 and settings.awakening_opacity_level2==2,'05:21 preset')
R.apply_colors(copy(d))
print('PASS Test7.19 mb pure (Light white / Dark void on bloom band, disc rims, MB glyphs; fade-back clocks), cioara 05:21 preset')
