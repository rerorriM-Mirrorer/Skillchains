-- Test5.0: target handoff. Untarget/ordinary death dims from the first moment
-- over `detarget time` with the animation running as normal; switching to a
-- target with resonance uses the quick `switch out` then `switch in`;
-- `preview off` dims like an untarget; `preview switch` lends a preview to the
-- first two targets. Simulated native sink and Windower API; no DLL loaded.
package.path='./TargetSC/?.lua;'..package.path
local now=0
os.clock=function()return now end
local events,messages={}, {}
local native={rings={},discs={}}
function native.version()return '0.10.0'end
function native.start()return 'running'end
function native.stop()end
function native.clear()native.rings={};native.discs={};native.id=nil end
function native.begin(index,id)native.index=index;native.id=id;native.rings={};native.discs={}end
function native.ring(...)native.rings[#native.rings+1]={...}end
function native.arc()end
function native.disc(...)native.discs[#native.discs+1]={...}end
function native.commit()end
function native.status()return 'simulated'end
local function enemy(id,index)return {id=id,index=index,hpp=100,is_npc=true,spawn_type=16,model_size=1.5,model_scale=1,valid_target=true}end
local A,B,C=enemy(71,12),enemy(72,13),enemy(73,14)
local me={id=500,index=300,hpp=100,is_npc=false,in_party=true,model_size=1,model_scale=1,valid_target=true}
local target
local at_index={[12]=71,[13]=72,[14]=73,[300]=500}
local player={status=0}
windower={addon_path='./TargetSC/',add_to_chat=function(_,t)messages[#messages+1]=t end,send_command=function()end,
    debug=function()end,dir_exists=function()return true end,
    ffxi={get_info=function()return{logged_in=true}end,get_player=function()return player end,
        get_mob_by_target=function(which)if which=='me'then return me end if which=='t'then return target end end,
        get_mob_by_index=function(i)return at_index[i]and {id=at_index[i],valid_target=true}or nil end},
    register_event=function(...)local args={...}local fn=table.remove(args)for _,n in ipairs(args)do events[n]=fn end end}
_addon={}
local saved
package.preload.chat=function()string.color=function(s)return s end return {}end
package.preload.config=function()return {load=function(d)return d end,save=function(s)saved=s end}end
package.preload._TargetSC=function()return native end
package.preload.sc_runtime=function()return {command=function()end}end
assert(loadfile('TargetSC/TargetSC.lua'))()
events.load()
local command=events['addon command']
local R=require('resonance')
local P=require('resonance_preview')
local function near(a,b,e,m)assert(math.abs(a-b)<=(e or .02),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
-- An undimmed twin of a preview started at `start`, to read the exact level.
local function twin(args,start,id)
    return P.new(P.parse(args,R),id,start,R,R.defaults)
end
local function level(t,mob,ref)
    ref:advance(t)
    local radius,height=R.dimensions(mob,R.defaults)
    local f=ref.model:frame(ref.id,t,radius,height,R.defaults)
    local best,got=0,0
    for i,r in ipairs(f)do
        local a=math.floor(((r.colors and r.colors[1])or r.color or 0)/16777216)
        if a>best and native.rings[i]then best,got=a,math.floor(native.rings[i][4]/16777216)end
    end
    assert(best>20,'reference ring visible')
    return got/best
end
local function frame(t)now=t;events.prerender()end
-- (a) Untarget dims from the first moment over 1 s on the same enemy.
target=A;now=10;command('preview','Fusion','2')
local ref=twin({'Fusion','2'},10,71)
frame(11);near(level(11,A,ref),1,.01,'full before')
target=nil;frame(11.5)
assert(native.id==71,'still drawn on the old enemy');near(level(11.5,A,ref),1,.02,'starts dimming at the switch frame')
frame(12);near(level(12,A,ref),.5,.03,'half way after .5 s')
frame(12.4);near(level(12.4,A,ref),.1,.03,'linear')
frame(12.55);assert(native.id==nil and #native.rings==0,'gone after detarget time')
-- (b) Retargeting the fading enemy brightens it back from where it was.
target=A;now=20;command('preview','Fusion','2');ref=twin({'Fusion','2'},20,71)
frame(21);target=nil;frame(21.1);frame(21.5)
near(level(21.5,A,ref),.6,.03)
target=A;frame(21.55)
local back=level(21.55,A,ref)
assert(back>=.5 and back<.95,'brightens from its fading level, no restart: '..back)
frame(21.75);near(level(21.75,A,ref),1,.01,'back to full after switch in')
-- (c) An ordinary preview does not move: switching to a plain enemy B (no
-- resonance) dims A over the full detarget time, not the quick one.
target=B;frame(22.0);frame(22.5)
assert(native.id==71,'A still fading');near(level(22.5,A,ref),.5,.03,'full detarget duration')
frame(23.05);assert(#native.rings==0 and #native.discs==0,'B has nothing of its own')
-- (d) Switch preview: A and B carry it; quick handoff A->B, slow B->C.
target=A;now=30;command('preview','switch','Fusion','2');ref=twin({'Fusion','2'},30,71)
assert(messages[#messages]:find('switch'),messages[#messages])
frame(31);near(level(31,A,ref),1,.01)
target=B;frame(31.1)
assert(native.id==71,'A goes first');frame(31.225);near(level(31.225,A,ref),.5,.04,'quick switch out (.25)')
frame(31.36);assert(native.id==72,'then B');frame(31.35+.175);near(level(31.525,B,ref),.5,.05,'B fades in over .35')
frame(31.75);near(level(31.75,B,ref),1,.01,'B full')
target=C;frame(32);assert(native.id==72,'C has no resonance: B dims slowly')
frame(32.5);near(level(32.5,B,ref),.5,.03,'full detarget duration toward a plain enemy')
-- Back to A (a carrier) while B is fading: B hurries, then A fades in.
target=A;frame(32.6)
frame(32.6+.25*.4+.01);assert(native.id==71 or #native.rings==0,'B hurried out')
frame(33.2);assert(native.id==71);near(level(33.2,A,ref),1,.01,'A in')
-- Third enemy never becomes a carrier.
target=C;frame(33.3);frame(34.4);assert(#native.rings==0,'C stays plain')
-- (e) Despawn or recycled index mid-fade cuts it.
target=A;frame(34.5);frame(35);target=nil;frame(35.1);assert(native.id==71)
at_index[12]=99;frame(35.2);assert(#native.rings==0,'recycled index cuts the fade');at_index[12]=71
-- (f) Cutscene cuts it.
target=A;now=40;command('preview','Fusion','2');frame(41);target=nil;frame(41.1);assert(native.id==71)
player.status=4;frame(41.2);assert(#native.rings==0,'cutscene cuts');player.status=0
-- (g) preview off dims like an untarget.
target=A;now=50;command('preview','Fusion','2');ref=twin({'Fusion','2'},50,71)
frame(51);command('preview','off');frame(51.5);near(level(51.5,A,ref),.5,.03,'preview off dims over 1 s')
frame(52.05);assert(#native.rings==0)
-- (h) Commands and presets.
command('detarget','time','3');assert(saved.detarget_time==3)
command('detarget','3.5');assert(saved.detarget_time==3,'range 0-3')
command('detarget','2');assert(saved.detarget_time==2)
command('switch','out','.4');command('switch','in','.6');assert(saved.switch_out==.4 and saved.switch_in==.6)
command('switch','in','2');assert(saved.switch_in==.6,'range 0-1')
command('preset','killala');assert(saved.detarget_time==0 and saved.switch_in==0 and saved.switch_out==0)
target=A;now=60;command('preview','Fusion','2');frame(61);target=nil;frame(61.05);assert(#native.rings==0,'killala: instant as before')
command('preset','default');assert(saved.detarget_time==1 and saved.switch_out==.25 and saved.switch_in==.35)
print('PASS Test5.0 target handoff: untarget dims linearly from the first moment, retarget brightens back, plain-enemy switch uses detarget time, switch preview carriers with quick out/in, slow fade toward a plain enemy, hurried by a carrier, despawn/cutscene cut, preview off dims, commands, presets')
