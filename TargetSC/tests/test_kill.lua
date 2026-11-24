-- 0.18 kill animations: Skillchains bridge detection (the WS or MB itself
-- must be the last hit before the defeat message), the model event, the MB
-- and SC kill animations. Simulated, not FFXI.
package.path='./TargetSC/?.lua;./?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local now=100
local sent={}
local res={spells={[144]={element=1},[150]={element=0}}}
local B=assert(loadfile('TargetSC/targetsc_bridge.lua'))()
local bridge=B.new({},res,function(text)sent[#sent+1]=text end,function()return now end)
local function last()return sent[#sent]or ''end
bridge:subscribe({})
local function act(category,actor,target,message,param)
    return {category=category,actor_id=actor,param=param or 0,targets={{id=target,actions={{message=message}}}}}
end
-- Weapon skill (category 3) then "defeats" from the same actor: SC kill.
bridge:observe(act(3,500,71,185));now=100.3;bridge:defeat(500,71,6)
assert(last():find(' kill [%d.]+ 71 sc None 500$'),last())
-- Magic burst (category 4 with a burst message) then defeat: MB kill with element.
now=110;bridge:observe(act(4,500,72,252,144));now=110.2;bridge:defeat(500,72,6)
assert(last():find(' kill [%d.]+ 72 mb Ice 500$'),last())
-- "falls to the ground" (20) names no killer: accepted.
now=120;bridge:observe(act(4,500,73,252,150));now=120.1;bridge:defeat(0,73,20)
assert(last():find(' kill [%d.]+ 73 mb Fire 500$'),last())
local count=#sent
-- Melee after the weapon skill: the WS did not drive HP to 0.
now=130;bridge:observe(act(3,500,74,185));bridge:observe(act(1,501,74,1));bridge:defeat(501,74,6)
assert(#sent==count,'melee kill is plain')
-- Ordinary spell (no burst message): plain.
bridge:observe(act(4,500,75,2,144));bridge:defeat(500,75,6)
assert(#sent==count,'plain spell kill')
-- Too late, or another actor's defeat message: plain.
bridge:observe(act(3,500,76,185));now=133;bridge:defeat(500,76,6)
assert(#sent==count,'stale action')
bridge:observe(act(3,500,77,185));bridge:defeat(502,77,6)
assert(#sent==count,'different killer')
-- Not a defeat message: ignored, and the record survives for the real one.
bridge:observe(act(3,500,78,185));bridge:defeat(500,78,206);assert(#sent==count)
bridge:defeat(500,78,6);assert(#sent==count+1,'record kept until the defeat')
-- Unsubscribed: nothing.
bridge:stop();count=#sent;bridge:observe(act(3,500,79,185));bridge:defeat(500,79,6);assert(#sent==count)
-- Model receives the kill.
local R=require('resonance');local P=require('resonance_preview');local M=require('resonance_motion')
local C=require('resonance_controls')
R.native_level=12
local model=R.new()
assert(model:receive({'1','s1','1','online','100'},100))
assert(model:receive({'1','s1','2','kill','100.5','71','mb','Ice','500'},100.5))
assert(model.kills[71].kind=='mb'and model.kills[71].element=='Ice'and model.kills[71].at==100.5)
assert(not model:receive({'1','s1','3','kill','100.6','71','zap','Ice','500'},100.6),'invalid kind rejected')
-- MB kill animation.
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local o=copy(R.defaults)
local p=P.new(P.parse({'kill','mb','Ice'},R),71,0,R,o)
local function at(t)p:advance(t)return p.model:frame(71,t,2,4,o)end
local function find(f,part)for _,v in ipairs(f)do if v.part==part and v.role=='core'then return v end end end
local function role(f,r)for _,d in ipairs(f.discs)do if d.role==r then return d end end end
local K=o.kill_time
local before=at(1.45)
local mbh=find(before,'mb').offset
-- Test6.3 default: the whole MB animation freezes (`mb freeze` after the
-- kill); all rings and discs flicker in the element color and fade together;
-- the MB's own bloom draws back in; the glyphs grow and fade with the kill bloom.
assert(o.kill_mb_rings=='freeze'and o.kill_mb_bloom=='in'and o.kill_mb_glyphs=='bloom')
local ice=R.argb(R.element_color('Ice'),1)%16777216
local z=1.5+o.kill_mb_freeze
local f1,f2=at(z+.05),at(z+.15)
local m1,m2=find(f1,'mb'),find(f2,'mb')
near(m1.offset,m2.offset,1e-9,'frozen MB ring')
near(m1.radius,m2.radius,1e-9,'no motion')
assert(m1.color%16777216==ice and find(f1,'ground').color%16777216==ice,'MB and SC rings in the element color')
assert(math.abs(find(f1,'ground').offset-m1.offset)>.01,'nothing gathers')
assert(role(f1,'property').colors[1]%16777216==ice and role(f1,'property').glyph==0,'disc fill flickers in the element color')
near(role(f1,'property').offset,role(at(z+.3),'property').offset,1e-9,'disc frozen in place')
local b1,b2=role(f1,'bloom'),role(f2,'bloom')
assert(b1 and b2 and b2.radius<b1.radius,'MB bloom drawn back in')
local done=at(1.5+o.kill_mb_freeze+o.kill_mb_fade+.02)
assert(#done==0 and not role(done,'property')and not role(done,'bloom'),'rings, discs and MB bloom fade out together')
-- Second bloom: element color, faster and larger than the MB's own; glyphs grow with it.
assert(o.kill_bloom_time<o.mb_bloom_time and o.kill_bloom_size>1)
local before_bloom=role(at(z+o.kill_bloom_delay-.01),'mb-glyph').radius
local fb=at(z+o.kill_bloom_delay+o.kill_bloom_time*.5)
local kb=role(fb,'kill-bloom')
assert(kb and kb.color%16777216==ice,'second bloom in the element color')
assert(role(fb,'mb-glyph').radius>before_bloom*1.3,'glyph grows with the kill bloom')
assert(not role(at(z+o.kill_bloom_delay+o.kill_bloom_time+.02),'mb-glyph'),'glyph gone with the bloom')
-- Variants.
local ov=copy(o);ov.kill_mb_glyphs='fade';ov.kill_mb_bloom='fade';ov.kill_mb_discs='own'
local pv=P.new(P.parse({'kill','mb','Ice'},R),71,0,R,ov)
local function vat(t)pv:advance(t)return pv.model:frame(71,t,2,4,ov)end
local v1,v2=vat(z+.05),vat(z+.15)
near(role(v1,'bloom').radius,role(v2,'bloom').radius,1e-9,'mb bloom fade: stays its size')
near(role(v2,'mb-glyph').radius,role(v1,'mb-glyph').radius,1e-9,'mb glyphs fade: no growth')
do
    local plain=copy(ov);plain.kill=false
    local pp=P.new(P.parse({'kill','mb','Ice'},R),71,0,R,plain);pp:advance(z)
    local ref=role(pp.model:frame(71,z,2,4,plain),'property')
    for i,c in ipairs(role(v1,'property').colors)do assert(c%16777216==ref.colors[i]%16777216,'mb discs own: keeps its colors')end
end
-- Test6.1 look: kill mb rings gather.
local og=copy(o);og.kill_mb_rings='gather'
local pg=P.new(P.parse({'kill','mb','Ice'},R),71,0,R,og)
pg:advance(1.5+og.kill_mb_gather+.01)
local gathered=pg.model:frame(71,1.5+og.kill_mb_gather+.01,2,4,og)
near(find(gathered,'ground').offset,mbh,1e-6,'ground ring gathered at the MB ring')
assert(alpha(find(gathered,'ground').color)<3,'and faded')
pg:advance(1.5+K*.9)
assert(find(pg.model:frame(71,1.5+K*.9,2,4,og),'mb').radius<find(before,'mb').radius*.5,'gather: collapsing')
assert(#at(1.5+K+.05)==0,'gone after kill time')
-- SC kill animation.
R.view_angle=0
local q=P.new(P.parse({'kill','sc'},R),71,0,R,o)
local function sat(t)q:advance(t)return q.model:frame(71,t,2,4,o)end
local start=2+o.kill_sc_freeze
local f1=sat(start+.05)
assert(f1.lines and #f1.lines==2,'seam at both ring heights')
near(f1.lines[1][2],0,1e-9,'seam along the killing blow (angle 0: east-west)')
local f2=sat(start+.6)
assert(not f2.lines,'seam flash over')
for _,d in ipairs(f2.discs)do assert(d.role~='mb-glyph'and d.role~='property-trace'and d.glyph~=2,'glyphs flashed out')end
local halves={}for _,d in ipairs(f2.discs)do if d.role=='property'then halves[#halves+1]=d end end
assert(#halves==2 and halves[1].colors[2]==0x00FFFFFF and halves[1].blend==0,'disc split into two halves')
assert(halves[1].dy>0 and halves[2].dy<0 and math.abs(halves[1].dx)<1e-9,'drifting apart across the seam')
assert(halves[1].color%16777216==0xFFFFFF,'ghostly white')
local arcs=0 for _,v in ipairs(f2)do assert(v.kind=='arc');arcs=arcs+1 end
assert(arcs>0 and arcs%2==0,'rings as half arcs')
local sky0,sky1
for _,v in ipairs(sat(start+.1))do if v.part=='sky'then sky0=v.offset break end end
for _,v in ipairs(sat(start+1.2))do if v.part=='sky'then sky1=v.offset break end end
assert(sky1<sky0,'sky halves sag')
local frozen1,frozen2=sat(start-.01),nil
assert(#sat(start+K+.05)==0,'gone after kill time')
local off=copy(o);off.kill=false
local qo=P.new(P.parse({'kill','sc'},R),71,0,R,off)
qo:advance(start+.6)
assert(not qo.model:frame(71,start+.6,2,4,off).lines,'kill off')
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('kill',{'off'});assert(settings.kill==false);cmd('kill',{'on'});assert(settings.kill==true)
cmd('kill',{'time','2'});cmd('kill',{'mb','gather','.5'});cmd('kill',{'bloom','size','3'})
cmd('kill',{'mb','rings','gather'});assert(settings.kill_mb_rings=='gather')
cmd('kill',{'mb','freeze','.3'});cmd('kill',{'mb','bloom','fade'});cmd('kill',{'mb','glyphs','fade'});cmd('kill',{'mb','discs','own'})
assert(settings.kill_mb_freeze==.3 and settings.kill_mb_bloom=='fade'and settings.kill_mb_glyphs=='fade'and settings.kill_mb_discs=='own')
cmd('kill',{'sc','flicker','.2'});cmd('kill',{'seam','flicker','.5'});assert(settings.kill_sc_flicker==.2 and settings.kill_seam_flicker==.5)
cmd('kill',{'sc','split','.2'});cmd('kill',{'sc','turn','-.1'});cmd('kill',{'seam','angle','90'})
assert(settings.kill_time==2 and settings.kill_mb_gather==.5 and settings.kill_bloom_size==3)
assert(settings.kill_sc_split==.2 and settings.kill_sc_turn==-.1 and settings.kill_seam_angle==90)
cmd('preset',{'killala'});assert(settings.kill==false);cmd('preset',{'default'});assert(settings.kill==true)
print('PASS 0.18 kills: bridge detection (WS/MB last hit, same actor, falls msg, melee/plain/stale/other actor/unsubscribed rejected), model event, MB kill (6.3 freeze: frozen rings/discs in element color fading together, MB bloom drawn in, glyphs growing with the kill bloom, variants; 6.1 gather and collapse; end), SC kill (seam, glyph flash-out, split halves across the seam, ghost white, half arcs, sag, end, off), commands, presets')
-- The unified addon's embedded Skillchains engine (not the standalone
-- Skillchains addon) must feed the bridge.
local src=assert(io.open('TargetSC/sc_runtime.lua')):read('*a')
assert(src:find('targetsc:observe%(act%)'),'sc_runtime observes actions')
assert(src:find("if id == 0x29 then targetsc:defeat%("),'sc_runtime reports defeats')
print('PASS 0.18 kills wired into the embedded engine (sc_runtime)')
