-- Test7.1: Radiance demo previews, Radiance ending ride/glyph, Umbra haze
-- glow/lift/order, Umbra disc jitter, steady under disc and glyph copies.
-- Simulated, not FFXI.
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
    if name=='Umbra'then local st=p.model.states[71];st.properties={'Umbra'};st.elements=R.elements('Umbra')end
    return p
end
local function at(p,t,o)p:advance(t)return p.model:frame(71,t,2,4,o)end
local function all(f,role)local r={}if f and f.discs then for k,d in ipairs(f.discs)do if d.role==role then d.index=k;r[#r+1]=d end end end return r end
local function find(f,role)return all(f,role)[1]end
local function mbring(f)for _,v in ipairs(f)do if v.part=='mb'and v.role=='core'then return v end end end
local function glyph(f)for _,g in ipairs(f.glyphs3 or {})do if g.role=='mb-glyph'then return g end end return find(f,'mb-glyph')end
local o=copy(R.defaults)
for _,k in ipairs({'radiance_ending_ride','umbra_under_steady','umbra_copies_steady'})do assert(o[k]==false,k)end
assert(o.radiance_ending_glyph=='off'and o.umbra_haze_style=='soft'and o.umbra_disc_jitter==0 and o.umbra_haze_lift==0 and o.umbra_haze_order=='over','defaults')

-- Radiance demo: five real weaponskills, the Light-side chain, same clocks as the Umbra demo.
local seq=P.radiance_sequence
local names={'Fast Blade','Burning Blade','Flat Blade','Savage Blade'}
for i,n in ipairs(names)do assert(seq[i].name==n,n)end
assert(seq[5].name:find('^Resolution')and seq[5].property=='Radiance'and seq[5].level==4,'Resolution closes Radiance')
-- Properties and levels follow sc_runtime's chain table and skills.lua.
local Sk=dofile('./TargetSC/skills.lua')
local function has(id,prop)local w=Sk.weapon_skills[id] assert(w,'weapon skill '..id) for _,p in ipairs(w.skillchain or {})do if p==prop then return true end end return w.aeonic==prop end
for _,row in ipairs(seq)do assert(has(row.weapon,row.used),row.name..' has '..row.used)end
for _,kind in ipairs({{'demo','radiance'},{'mb','radiance'},{'demo','radiance','mb'},{'full','light'}})do
    local spec=P.parse(kind,R)
    assert(spec.kind=='radiancedemo'or spec.kind=='radiancemb',table.concat(kind,' '))
end
assert(P.parse({'demo'},R).kind=='umbra'and P.parse({'mb'},R).kind=='mbdemo'and P.parse({'mb','light'},R).kind=='mblight','old previews unchanged')
local um,rd=P.new(P.parse({'demo'},R),80,0,R,o),P.new(P.parse({'demo','radiance'},R),81,0,R,o)
assert(math.abs(um.ends-rd.ends)<1e-9 and #um.events==#rd.events,'same clocks as the Umbra demo')
local props,levels={}, {}
for t=0,rd.ends,.1 do rd:advance(t)local s=rd.model.states[81]if s then props[s.step]=s.properties[1];levels[s.step]=s.level end end
assert(props[2]=='Liquefaction'and props[3]=='Fusion'and props[4]=='Light'and props[5]=='Radiance','links '..tostring(props[5]))
assert(levels[5]==4,'Radiance is level 4')
local rm=P.new(P.parse({'mb','radiance'},R),82,0,R,o)
local hits={}
for _,e in ipairs(rm.events)do if e.kind=='burst'then hits[#hits+1]=e.element..'@'..e.at end end
assert(table.concat(hits,',')=='Fire@12.6,Light@23.8,Lightning@29.8,Light@38.8','bursts '..table.concat(hits,','))
-- Both demos play to the end without errors.
for _,p in ipairs({rd,rm})do for t=0,p.ends,.05 do p:advance(t)p.model:frame(p.id,t,2,4,o)end end
assert(rd.description:find('Radiance demo')and rm.description:find('Radiance MB demo'),'descriptions')

-- Radiance ending ride + glyph.
local ro=copy(o);ro.mb_ending_style='converge';ro.mb_ending_fade=.8
local st=link(ro).model.states[71]
local function prop(f)return find(f,'property')end
local base=at(link(ro),st.mb_close-2.2,ro)
local before=prop(at(link(ro),st.mb_close-.6,ro))
near(before.offset,prop(base).offset,1e-9,'default: discs stay at their plane')
local ride=copy(ro);ride.radiance_ending_ride=true
local p0=prop(at(link(ride),st.mb_close-2.2,ride))
near(p0.offset,prop(base).offset,1e-9,'ride: same before the ending')
for _,t in ipairs({-1.4,-.8,-.2})do
    local f=at(link(ride),st.mb_close+t,ride)
    near(prop(f).offset-p0.offset,mbring(f).offset-mbring(base).offset,1e-9,'rides with the ring at '..t)
    assert(alpha(prop(f).colors[1])==alpha(p0.colors[1]),'no fade in the ending at '..t)
end
local after=prop(at(link(ride),st.mb_close+.3,ride))
assert(after and alpha(after.colors[1])<alpha(p0.colors[1])and alpha(after.colors[1])>0,'fades in the final fade')
for _,role in ipairs({'radiance-bottom','radiance-middle'})do
    local d=find(at(link(ride),st.mb_close-.6,ride),role)
    if d then assert(d.offset<find(at(link(ride),st.mb_close-2.2,ride),role).offset,role..' rides')end
end
-- Glyph brightening: off = as before; curves reach the peak at the deadline; order by curve.
local off=glyph(at(link(ro),st.mb_close-.05,ro))
local function ga(curve,t,peak)local q=copy(ro);q.radiance_ending_glyph=curve;q.radiance_ending_peak=peak or 1
    local g=glyph(at(link(q),st.mb_close+t,q))return g and alpha(g.outline or g.color)end
assert(ga('off',-.05)==alpha(off.outline or off.color),'off unchanged')
for _,c in ipairs({'linear','quadratic','cosine','exponential'})do
    assert(ga(c,-.02)>=250,c..' reaches the peak')
    near(ga(c,-2.05),ga('off',-2.05),1,c..' same before the descent')
end
assert(ga('linear',-1)>ga('quadratic',-1)and ga('quadratic',-1)>ga('exponential',-1),'curve shapes')
assert(ga('quadratic',-.02,.5)<140,'peak scales')
assert(ga('quadratic',.4)<ga('quadratic',-.02),'fades with the final fade')

-- Umbra haze glow.
local hz=copy(o);hz.umbra_haze=true;hz.umbra_haze_style='glow';hz.umbra_haze_flicker=0
hz.umbra_disc_middle=1;hz.umbra_disc_position=.93
local f=at(link(hz,'Umbra'),5,hz)
local hs,black=all(f,'umbra-haze'),find(f,'property')
assert(#hs==2,'two haze discs')
local white,dark=hs[1],hs[2]
assert(rgb(white.colors[1])==0xFFFFFF and rgb(dark.colors[1])==0,'white under, black over')
near(dark.radius,black.radius*.93,1e-9,'black ends at the disc middle point')
assert(dark.inner==1 and dark.outer==0,'black: center 1 -> clear')
assert(white.inner==0 and white.mid==1 and white.outer==0,'white: clear -> full -> edge')
near(white.radius*white.mid_pos,black.radius*.93,1e-9,'white peaks at the disc middle point')
near(white.offset,mbring(f).offset,1e-9,'at the MB ring')
-- Lift and order.
local lo=copy(hz);lo.umbra_haze_lift=-.05;lo.umbra_haze_order='under'
local g=at(link(lo,'Umbra'),5,lo)
local lh,lb=all(g,'umbra-haze'),find(g,'property')
near(lh[1].offset,mbring(g).offset-.05,1e-9,'lift')
assert(lh[2].index<lb.index and lh[1].index<lh[2].index,'under: both before the black disc, white first')
assert(find(at(link(hz,'Umbra'),5,hz),'property').index<all(at(link(hz,'Umbra'),5,hz),'umbra-haze')[1].index,'over: after it')
-- Soft style unchanged by the new settings.
local so=copy(o);so.umbra_haze=true
assert(#all(at(link(so,'Umbra'),5,so),'umbra-haze')==1,'soft = one disc')

-- Jitter.
local j0=copy(o);j0.umbra_disc_middle=1;j0.umbra_disc_position=.8
local j1=copy(j0);j1.umbra_disc_jitter=.05;j1.umbra_jitter_speed=.5
near(find(at(link(j0,'Umbra'),3,j0),'property').mid_pos,.8,1e-9,'jitter 0 still')
local lo2,hi2=1,0
for t=1,5,.1 do local m=find(at(link(j1,'Umbra'),t,j1),'property').mid_pos lo2=math.min(lo2,m)hi2=math.max(hi2,m)end
assert(hi2>.84 and lo2<.76 and hi2<=.85+1e-9 and lo2>=.75-1e-9,'swings +-.05: '..lo2..' '..hi2)
near(find(at(link(j1,'Umbra'),2.5,j1),'property').mid_pos,.8+.05*math.sin(2*math.pi*.5*2.5),1e-6,'sinusoidal')
local jh=copy(j1);jh.umbra_haze=true;jh.umbra_haze_style='glow'
local jf=at(link(jh,'Umbra'),2.5,jh)
near(all(jf,'umbra-haze')[2].radius,find(jf,'property').radius*find(jf,'property').mid_pos,1e-9,'haze follows the jitter')

-- Steady spin.
local sp=copy(o);sp.umbra_under=true;sp.umbra_copies=true;sp.umbra_spin=3
local function under_turn(opts,t)return find(at(link(opts,'Umbra'),t,opts),'umbra-under').rotation end
local st2=link(sp,'Umbra').model.states[71]
local sd=copy(sp);sd.umbra_under_steady=true
near(under_turn(sd,.5),under_turn(sp,.5),1e-6,'same speed before the slowdown')
local late=st2.mb_close-1.5
local rate_default=under_turn(sp,late+.1)-under_turn(sp,late)
local rate_steady=under_turn(sd,late+.1)-under_turn(sd,late)
local early=under_turn(sd,.6)-under_turn(sd,.5)
near(rate_steady,early,1e-6,'steady keeps the opening speed')
assert(math.abs(rate_default)<math.abs(rate_steady)*.9,'default slows')
local cs=copy(sp);cs.umbra_copies_steady=true
local function copy_turn(opts,t)local d=find(at(link(opts,'Umbra'),t,opts),'umbra-copy')return d and d.rotation end
local cstop=M.umbra_flashed(st2,cs,true)-.4
local c1,c2=copy_turn(cs,cstop),copy_turn(cs,cstop+.1)
assert(math.abs(copy_turn(sp,cstop+.1)-copy_turn(sp,cstop))<math.abs(early)*.9,'default copies slow by then')
assert(c1 and c2,'a glyph copy is live late in the window');near(c2-c1,early,1e-6,'copies keep the opening speed')
local spo=copy(sp);spo.disc_speed_level4=3
near(M.steady_rotation(st2,2,spo)-M.steady_rotation(st2,1,spo),early*10,1e-6,'steady_rotation rate')

-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('umbra',{'haze','style','glow'});cmd('umbra',{'haze','black','.8'});cmd('umbra',{'haze','lift','-.1'});cmd('umbra',{'haze','order','under'})
assert(settings.umbra_haze_style=='glow'and settings.umbra_haze_black==.8 and settings.umbra_haze_lift==-.1 and settings.umbra_haze_order=='under')
cmd('umbra',{'disc','jitter','.04'});cmd('umbra',{'jitter','speed','2'})
assert(settings.umbra_disc_jitter==.04 and settings.umbra_jitter_speed==2)
cmd('umbra',{'under','steady','on'});cmd('umbra',{'copies','steady','on'})
assert(settings.umbra_under_steady==true and settings.umbra_copies_steady==true)
cmd('radiance',{'ending','ride','on'});cmd('radiance',{'ending','glyph','cosine'});cmd('radiance',{'ending','peak','.7'})
assert(settings.radiance_ending_ride==true and settings.radiance_ending_glyph=='cosine'and settings.radiance_ending_peak==.7)
cmd('radiance',{'ending','glyph','log'});assert(settings.radiance_ending_glyph=='cosine','rejects')
assert(R.killala.radiance_ending_ride==false and R.killala.radiance_ending_glyph=='off'and R.killala.umbra_disc_jitter==0,'killala')
print('PASS Test7.1: Radiance demo (real WS, chain levels, clocks, bursts, old previews unchanged), Radiance ending ride (rides with ring, no fade until final fade) and glyph curves (peak, shapes, fade), haze glow (two discs, black to the middle point, white peak there), lift, order, jitter (sinusoid, haze follows), steady under/copies, commands, killala')
