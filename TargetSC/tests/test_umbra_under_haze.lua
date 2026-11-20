-- Test7.0: Umbra under disc (Gravitation<->Distortion, just below the black
-- disc, turning) and Umbra haze (flickering white bloom at the MB ring
-- height all MB window). Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
R.native_level=12
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function rgb(c)return c%16777216 end
local function link(o,name)
    local p=P.new(P.parse({'Radiance','4'},R),71,0,R,o)
    if name~='Radiance'then local st=p.model.states[71];st.properties={'Umbra'};st.elements=R.elements('Umbra')end
    return p
end
local function at(p,t,o)p:advance(t)return p.model:frame(71,t,2,4,o)end
local function find(f,role)if not (f and f.discs) then return nil end for k,d in ipairs(f.discs)do if d.role==role then d.index=k return d end end end
local function mbring(f)for _,v in ipairs(f)do if v.part=='mb'and v.role=='core'then return v end end end
local o=copy(R.defaults)
assert(o.umbra_under==false and o.umbra_haze==false,'off by default')
for _,t in ipairs({1,3,6,9})do
    local f=at(link(o),t,o)
    assert(not find(f,'umbra-under')and not find(f,'umbra-haze'),'nothing new by default at '..t)
end
-- Under disc.
local u=copy(o);u.umbra_under=true
local f=at(link(u),2,u)
local d,black=find(f,'umbra-under'),find(f,'property')
assert(d and black,'under disc drawn')
assert(d.index<black.index,'drawn before the black disc (it covers the overlap)')
near(black.offset-d.offset,u.umbra_under_depth,1e-9,'just below the black disc')
near(d.radius,black.radius,1e-9,'size 1 = black disc size')
near(d.rotation,black.rotation,1e-9,'spin 1 same direction = black disc turn')
assert(d.inner==1 and d.outer==0,'opaque center, clear edge')
assert(alpha(d.color)>0,'visible')
-- Crossfade: Gravitation at the start of a cycle, Distortion half a cycle later.
local function palette(name)local r={}for _,e in ipairs(R.elements(name))do r[#r+1]=R.element_color(e)end return r end
local grav,dist=palette('Gravitation'),palette('Distortion')
local function first(t)return rgb(find(at(link(u),t,u),'umbra-under').colors[1])end
local c0=first(u.umbra_under_cycle)          -- w=0 at whole cycles from created (0)
local c1=first(u.umbra_under_cycle*1.5)      -- w=1
local function packed(c)return math.floor(c[1]+.5)*65536+math.floor(c[2]+.5)*256+math.floor(c[3]+.5)end
near(c0,packed(grav[1]),1,'Gravitation at the cycle start');near(c1,packed(dist[1]),1,'Distortion halfway')
assert(first(u.umbra_under_cycle*1.25)~=c0 and first(u.umbra_under_cycle*1.25)~=c1,'blends between')
-- Spin, direction, size, depth, center/edge, opacity.
local v=copy(u);v.umbra_under_spin=2;v.umbra_under_direction='reverse';v.umbra_under_size=1.5
v.umbra_under_depth=.03;v.umbra_under_center=.8;v.umbra_under_edge=.2;v.umbra_under_opacity=.3
local g=at(link(v),2,v);local dv,bv=find(g,'umbra-under'),find(g,'property')
near(dv.rotation,-2*bv.rotation,1e-9,'spin 2 reversed')
near(dv.radius,bv.radius*1.5,1e-9,'size');near(bv.offset-dv.offset,.03,1e-9,'depth')
assert(dv.inner==.8 and dv.outer==.2,'center/edge')
assert(alpha(dv.colors[1])<alpha(d.colors[1]),'opacity')
-- Radiance unaffected; collapse shrinks it with everything else.
assert(not find(at(link(u,'Radiance'),2,u),'umbra-under'),'Umbra only')
local st=link(u).model.states[71]
local sh=copy(u);sh.umbra_under_ending='shrink'
local late=at(link(sh),st.mb_close-.1,sh)
assert(find(late,'umbra-under').radius<d.radius*.5,'under ending shrink: collapses with the black disc')
-- Haze.
local hz=copy(o);hz.umbra_haze=true
local hf=at(link(hz),5,hz)
local h,ring=find(hf,'umbra-haze'),mbring(hf)
assert(h and ring,'haze drawn')
near(h.offset,ring.offset,1e-9,'at the MB ring height')
near(h.radius,ring.radius*hz.umbra_haze_size,1e-9,'size x the Umbra MB ring')
assert(rgb(h.colors[1])==0xFFFFFF and h.inner==.6 and h.outer==0,'white soft bloom')
-- Persistent through the window, flickering, gone at the deadline.
local lo,hi,seen=255,0,0
for t=.5,st.mb_close-.05,.05 do
    local x=find(at(link(hz),t,hz),'umbra-haze')
    assert(x,'present at '..t);seen=seen+1
    lo=math.min(lo,alpha(x.colors[1]));hi=math.max(hi,alpha(x.colors[1]))
end
assert(hi>lo+10,'flickers '..lo..'..'..hi)
assert(hi<=math.floor(.3*255+.5)+1,'never above its opacity')
assert(not find(at(link(hz),st.mb_close+.05,hz),'umbra-haze'),'gone after the window')
local steady=copy(hz);steady.umbra_haze_flicker=0
local a1=alpha(find(at(link(steady),4,steady),'umbra-haze').colors[1])
local a2=alpha(find(at(link(steady),4.37,steady),'umbra-haze').colors[1])
assert(a1==a2,'flicker 0 = steady');near(a1,math.floor(.3*255+.5),1,'steady at its opacity')
local big=copy(hz);big.umbra_haze_size=2
near(find(at(link(big),5,big),'umbra-haze').radius,ring.radius*2,1e-9,'size')
-- mb height disc: the haze follows the ring down to the black disc plane.
local low=copy(hz);low.umbra_mb_height='disc'
local lf=at(link(low),5,low);near(find(lf,'umbra-haze').offset,mbring(lf).offset,1e-9,'follows mb height disc')
-- Without the collapse it fades over the mb ending.
local nc=copy(hz);nc.umbra_collapse=false
nc.umbra_haze_flicker=0
local e0=alpha(find(at(link(nc),5,nc),'umbra-haze').colors[1])
local e1=find(at(link(nc),st.mb_close-nc.mb_ending*.25,nc),'umbra-haze')
assert(not e1 or alpha(e1.colors[1])<e0*.5,'fades over the mb ending without the collapse')
-- Both together stay inside the native disc cap and the black disc still draws.
local both=copy(u);both.umbra_haze=true
for t=.5,st.mb_close-.05,.25 do
    local bf=at(link(both),t,both)
    assert(#bf.discs<=16,'disc cap at '..t)
    assert(find(bf,'property')and find(bf,'umbra-under')and find(bf,'umbra-haze'),'all three at '..t)
end
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('umbra',{'under','on'});assert(settings.umbra_under==true)
cmd('umbra',{'under','spin','2'});cmd('umbra',{'under','direction','reverse'});cmd('umbra',{'under','size','1.4'})
assert(settings.umbra_under_spin==2 and settings.umbra_under_direction=='reverse'and settings.umbra_under_size==1.4)
cmd('umbra',{'under','cycle','6'});cmd('umbra',{'under','opacity','.4'});assert(settings.umbra_under_cycle==6 and settings.umbra_under_opacity==.4)
cmd('umbra',{'haze','on'});cmd('umbra',{'haze','flicker','.8'});cmd('umbra',{'haze','size','2'});cmd('umbra',{'haze','opacity','.5'})
assert(settings.umbra_haze==true and settings.umbra_haze_flicker==.8 and settings.umbra_haze_size==2 and settings.umbra_haze_opacity==.5)
cmd('umbra',{'haze','speed','2'});assert(settings.umbra_haze_speed==2)
cmd('umbra',{'under','direction','x'});assert(settings.umbra_under_direction=='reverse','rejects')
cmd('umbra',{'haze','flicker','2'});assert(settings.umbra_haze_flicker==.8,'rejects out of range')
assert(R.killala.umbra_under==false and R.killala.umbra_haze==false,'killala off')
print('PASS Test7.0 Umbra under disc (below and before the black disc, Gravitation<->Distortion, spin/direction/size/depth/center/edge/opacity, collapses, Umbra only) and haze (MB ring height and size, white soft, whole window, flickers, flicker 0 steady, mb height disc, gone after), disc cap, commands, killala')
