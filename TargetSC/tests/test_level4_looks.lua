-- Test5.2: level-4 looks. Radiance rings keep their opening white and close
-- one at a time (lower set first, inner to outer) over 3 s, each glow
-- flashing and going out before its ring, with a staggered far-to-near
-- shimmer (MB ring joins); Umbra rings are black with white glows, then
-- flash white and vanish (upper set first, outer to inner), leaving faint
-- black smoke. Per-skillchain opacity overrides. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
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
local function find(f,part,strand,role)
    for _,v in ipairs(f)do if v.part==part and v.strand==strand and v.role==role then return v end end
end
local o=copy(R.defaults)
local p=link('Radiance',o);local st=p.model.states[71]
local open=st.sc_open
-- Radiance look open: still white after the window opens; classic turns gold.
assert(rgb(find(at(p,open+.4,o),'ground',4,'core').color)==0xFFFFFF,'open: stays white')
local classic=copy(o);classic.radiance_look='classic';classic.radiance_close='classic'
local cp=link('Radiance',classic)
assert(rgb(find(at(cp,open+.4,classic),'ground',4,'core').color)~=0xFFFFFF,'classic: shifts toward gold')
-- Order: lower set first, inner to outer, then the upper set.
local function index(part,j,opts)return M.level4_ring(st,open+.01,opts,'radiance',part,j,4,true).index end
assert(index('ground',1,o)==0 and index('ground',4,o)==3 and index('sky',1,o)==4 and index('sky',4,o)==7)
local up=copy(o);up.radiance_order='upper';up.radiance_direction='outer'
assert(index('sky',4,up)==0 and index('ground',1,up)==7,'upper, outer first')
local tog=copy(o);tog.radiance_order='together'
assert(index('sky',2,tog)==1 and index('ground',2,tog)==1,'together')
-- Each glow flashes (above normal) then goes out before its ring fades.
local function q(part,j,t)return M.level4_ring(st,t,o,'radiance',part,j,4,true)end
local step=(3-.2-.5)/7
local b=open+step*2 -- ground strand 3
assert(q('ground',3,b-.01).glow==1 and q('ground',3,b-.01).core==1,'waits its turn')
assert(q('ground',3,b+.06).glow>1.5,'glow flashes')
assert(q('ground',3,b+.2).glow==0 and q('ground',3,b+.2).core>.99,'glow out before the ring')
assert(q('ground',3,b+.2+.5).core<1e-9,'ring faded')
-- Whole sequence over close time; rings drawn into mb-only, then gone.
local f=at(p,open+2.4,o)
assert(f.phase=='mb-only'and find(f,'sky',4,'core'),'last ring still closing in mb-only')
assert(not find(at(p,open+2.4,o),'ground',1,'core'),'first ring already gone')
assert(not find(at(p,open+3.05,o),'sky',4,'core'),'all closed after close time')
-- Shimmer: far side (view) -> near side (view+pi) and back, staggered.
local view=1.1
local function lit(t,i,opts)return M.level4_shimmer(st,t,opts or o,'radiance',i,view)end
assert(lit(open-.5,0)==nil,'when close: not before the window opens')
local all=copy(o);all.radiance_shimmer_when='all'
assert(lit(open-.5,0,all),'when all: always')
local period=o.radiance_shimmer_time
local t0=period*math.ceil((open+1)/period) -- phase 0 for index 0
near(lit(t0,0).angle,view,1e-6,'far side');near(lit(t0+period/2,0).angle,view+math.pi,1e-6,'near side')
near(lit(t0+period,0).angle,view,1e-6,'and back')
assert(math.abs(lit(t0,1).angle-lit(t0,0).angle)>.05,'staggered per ring')
local aim=copy(o);aim.radiance_shimmer_angle=90
near(lit(t0,0,aim).angle,view+math.pi/2,1e-6,'angle offset')
-- In the frame: glow bands carry the patch (four-stop gradient at that angle).
R.view_angle=view
local gf=at(link('Radiance',o),t0,o)
local g=find(gf,'ground',4,'glow')
near(g.rotation,lit(t0,3).angle,1e-6,'glow band rotation = patch angle')
assert(g.blend==1 and alpha(g.colors[1])>alpha(g.colors[3]),'bright patch, dim opposite')
-- MB ring joins (index 8) unless shimmer mb off.
local function mbglow(opts)for _,v in ipairs(at(link('Radiance',opts),t0,opts))do if v.part=='mb'and v.role=='glow'then return v end end end
near(mbglow(o).rotation,lit(t0,8).angle,1e-6,'MB ring joins the shimmer')
local nomb=copy(o);nomb.radiance_shimmer_mb=false
assert(math.abs(mbglow(nomb).rotation-lit(t0,8).angle)>1e-3,'shimmer mb off')
local off=copy(o);off.radiance_shimmer=0
assert(M.level4_shimmer(st,t0,off,'radiance',0,view)==nil,'shimmer 0 = off')
-- Opacity overrides replace the overall opacity.
local dim=copy(o);dim.radiance_opacity=.1
assert(alpha(find(at(link('Radiance',dim),1,dim),'ground',1,'core').color)<alpha(find(at(link('Radiance',o),1,o),'ground',1,'core').color),'radiance opacity')
local function fill(name,opts,t)for _,d in ipairs(at(link(name,opts),t or 1,opts).discs)do if d.role=='property'then return d end end end
local solid=copy(o);solid.umbra_disc_opacity=1
near(alpha(fill('Umbra',solid).color),255,1,'umbra disc opacity 1 = total black, ignoring overall opacity')
assert(rgb(fill('Umbra',solid).color)==0,'black')
assert(alpha(fill('Umbra',o).color)<120,'default still capped by overall opacity')
-- Umbra: black cores, white glows; hold, then flash white and vanish
-- (upper set first, outer to inner), leaving black smoke that dissipates.
local u=link('Umbra',o)
local uf=at(u,1,o)
assert(rgb(find(uf,'ground',1,'core').color)==0,'black core from the opening')
assert(rgb(find(uf,'ground',1,'glow').color)==0xFFFFFF,'white glow')
local hold=open+o.umbra_close_time
assert(rgb(find(at(u,hold-.05,o),'sky',4,'core').color)==0,'black through the hold')
local first=at(u,hold+.04,o)
assert(rgb(find(first,'sky',4,'core').color)==0xFFFFFF and alpha(find(first,'sky',4,'core').color)>200,'outer upper ring flashes white')
assert(rgb(find(first,'sky',3,'core').color)==0,'next ring waits its gap')
local later=at(u,hold+.12*1+.04,o)
assert(rgb(find(later,'sky',3,'core').color)==0xFFFFFF,'then the next')
local gone=at(u,hold+.5,o)
assert(not find(gone,'sky',4,'core'),'flashed ring vanished')
local smoke=find(gone,'sky',4,'glow')
assert(smoke and rgb(smoke.color)==0 and alpha(smoke.color)>0,'black smoke left behind')
local quiet=copy(o);quiet.umbra_smoke_opacity=.1
assert(alpha(find(at(link('Umbra',quiet),hold+.5,quiet),'sky',4,'glow').color)<alpha(smoke.color),'smoke opacity')
assert(#at(u,M.level4_end(st,o,'umbra',true)+.05,o)==0 or not find(at(u,M.level4_end(st,o,'umbra',true)+.05,o),'ground',1,'glow'),'smoke gone at the end')
local uc=copy(o);uc.umbra_look='classic';uc.umbra_glow='violet';uc.umbra_close='classic'
assert(rgb(find(at(link('Umbra',uc),1,uc),'ground',1,'core').color)==0xFFFFFF,'classic: white until the window opens')
-- Radiance/Umbra only; level 3 untouched.
local l3=P.new(P.parse({'Light','3'},R),71,0,R,o)
assert(l3.model:frame(71,1,2,4,o),'level 3 still draws')
-- Commands (table-driven).
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('radiance',{'opacity','.4'});assert(settings.radiance_opacity==.4)
cmd('radiance',{'opacity','same'});assert(settings.radiance_opacity==-1)
cmd('radiance',{'disc','opacity','.8'});assert(settings.radiance_disc_opacity==.8,'two-word setting')
cmd('radiance',{'look','classic'});assert(settings.radiance_look=='classic')
cmd('radiance',{'look','gold'});assert(settings.radiance_look=='classic','invalid choice')
cmd('radiance',{'close','time','2.5'});assert(settings.radiance_close_time==2.5)
cmd('radiance',{'close','classic'});assert(settings.radiance_close=='classic')
cmd('radiance',{'order','upper'});cmd('radiance',{'direction','outer'})
assert(settings.radiance_order=='upper'and settings.radiance_direction=='outer')
cmd('radiance',{'shimmer','.3'});cmd('radiance',{'shimmer','time','4'});cmd('radiance',{'shimmer','stagger','.25'})
cmd('radiance',{'shimmer','angle','-45'});cmd('radiance',{'shimmer','when','all'});cmd('radiance',{'shimmer','mb','off'})
assert(settings.radiance_shimmer==.3 and settings.radiance_shimmer_time==4 and settings.radiance_shimmer_stagger==.25)
assert(settings.radiance_shimmer_angle==-45 and settings.radiance_shimmer_when=='all'and settings.radiance_shimmer_mb==false)
cmd('radiance',{'shimmer','angle','200'});assert(settings.radiance_shimmer_angle==-45,'range')
cmd('umbra',{'disc','opacity','1'});cmd('umbra',{'glow','violet'});cmd('umbra',{'gap','.2'})
cmd('umbra',{'flash','time','.1'});cmd('umbra',{'smoke','opacity','.2'});cmd('umbra',{'smoke','spread','.1'})
assert(settings.umbra_disc_opacity==1 and settings.umbra_glow=='violet'and settings.umbra_gap==.2)
assert(settings.umbra_flash_time==.1 and settings.umbra_smoke_opacity==.2 and settings.umbra_smoke_spread==.1)
cmd('preset',{'killala'})
assert(settings.radiance_look=='classic'and settings.radiance_close=='classic'and settings.radiance_shimmer==0)
assert(settings.umbra_look=='classic'and settings.umbra_glow=='violet'and settings.umbra_close=='classic')
cmd('preset',{'default'})
assert(settings.radiance_look=='open'and settings.umbra_look=='black'and settings.umbra_smoke_opacity==.5)
-- Test5.3: `preview umbra` = Darkness about to close, closed by Umbra.
local pu=P.new(P.parse({'umbra'},R),71,0,R,o)
assert(pu.model.states[71].properties[1]=='Darkness'and pu.model.states[71].sc_close>0 and pu.model.states[71].sc_close<3,'Darkness window about to close')
for t=0,1.3,.1 do pu:advance(t)end
local us=pu.model.states[71]
assert(us.properties[1]=='Umbra'and us.level==4 and us.closed and math.abs(us.created-1.2)<1e-9,'Umbra lands at 1.2 s')
assert(pu.ends>us.mb_close and P.parse({'demo'},R).kind=='umbra','demo sequence still on preview demo')
print('PASS Test5.2 level-4 looks: Radiance open white, lower/inner-first close over 3 s with glow flash before each ring, staggered far-to-near shimmer (+MB ring), opacity overrides; Umbra black cores/white glow, upper/outer-first white flash-out, black smoke; commands, presets; preview umbra')
