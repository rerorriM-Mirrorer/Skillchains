-- 0.18 kill animations: Skillchains bridge detection (the WS or MB itself
-- must be the last hit before the defeat message), the model event, the MB
-- and SC kill animations. Simulated, not FFXI.
package.path='./TargetSC/?.lua;./?.lua;'..package.path
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
local gathered=at(1.5+o.kill_mb_gather+.01)
near(find(gathered,'ground').offset,mbh,1e-6,'ground ring gathered at the MB ring')
assert(alpha(find(gathered,'ground').color)<3,'and faded')
near(role(gathered,'property').offset,mbh,1e-6,'disc jumped to the MB ring')
near(role(gathered,'mb-glyph').offset,mbh,1e-6,'MB glyph meets the MB ring')
local kb=role(at(1.5+o.kill_bloom_delay+.3),'kill-bloom')
assert(kb and kb.color%16777216==R.argb(R.element_color('Ice'),1)%16777216,'second bloom in the element color')
assert(find(at(1.5+K*.9),'mb').radius<find(before,'mb').radius*.5,'collapsing')
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
cmd('kill',{'sc','split','.2'});cmd('kill',{'sc','turn','-.1'});cmd('kill',{'seam','angle','90'})
assert(settings.kill_time==2 and settings.kill_mb_gather==.5 and settings.kill_bloom_size==3)
assert(settings.kill_sc_split==.2 and settings.kill_sc_turn==-.1 and settings.kill_seam_angle==90)
cmd('preset',{'killala'});assert(settings.kill==false);cmd('preset',{'default'});assert(settings.kill==true)
print('PASS 0.18 kills: bridge detection (WS/MB last hit, same actor, falls msg, melee/plain/stale/other actor/unsubscribed rejected), model event, MB kill (gather, glyph at ring, second element bloom, collapse, end), SC kill (seam, glyph flash-out, split halves across the seam, ghost white, half arcs, sag, end, off), commands, presets')
-- The unified addon's embedded Skillchains engine (not the standalone
-- Skillchains addon) must feed the bridge.
local src=assert(io.open('TargetSC/sc_runtime.lua')):read('*a')
assert(src:find('targetsc:observe%(act%)'),'sc_runtime observes actions')
assert(src:find("if id == 0x29 then targetsc:defeat%("),'sc_runtime reports defeats')
print('PASS 0.18 kills wired into the embedded engine (sc_runtime)')
