-- Test6.7: every link that opens a new window plays the white awakening disc
-- on the opener's curve (against the link's own wait); a closing link plays
-- none; the next link hands the previous disc off over .3 s; the opener is
-- unchanged; `awakening links off` and preset killala remove it.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function smooth(v)v=math.max(0,math.min(1,v))return v*v*(3-2*v)end
local opener={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,
 properties={'Fusion','Liquefaction'},elements=R.elements('Fusion')}
local link={id=71,revision=2,created=104,sc_open=107,sc_close=113,mb_close=114,step=2,level=2,
 properties={'Fusion'},elements=R.elements('Fusion')}
local function awakenings(m,t,o)
 local f=m:frame(71,t,2,4,o);local r={}
 for _,d in ipairs(f.discs)do if d.role=='awakening'then
  r[#r+1]={alpha=math.floor(d.colors[1]/16777216)/255,radius=d.radius,inner=d.inner,outer=d.outer}end end
 return r
end
local base=copy(R.defaults)
assert(base.awakening_links==true,'default on')
local peak=base.awakening_opacity*base.opacity
-- 1. Opener disc identical to the previous formula (helper refactor).
for _,t in ipairs({100.5,101,101.4,101.7,102})do
 local m=R.new();m.states[71]=copy(opener)
 local a=awakenings(m,t,base)
 local p=(t-100)/3;local want=peak*(1-smooth((math.min(1,p)-1/3)*3))
 if want>1/255 then assert(#a==1,'one opener disc at '..t);near(a[1].alpha,want,1/255+1e-9,'opener at '..t)end
end
-- 2. A link: disc grows over the first third of its own wait, fades over the
--    middle third, gone at two-thirds; radial fill and size as the opener.
local function linkmodel()local m=R.new();m.states[71]=copy(opener);m:frame(71,103.5,2,4,base);m.states[71]=copy(link);return m end
local m=linkmodel()
local function lone(t,o)
 local list=awakenings(m,t,o or base);local best
 for _,d in ipairs(list)do if not best or d.radius>best.radius then best=d end end
 return best,#list
end
local early=lone(104.3)
assert(early and early.radius>0,'link disc visible early')
local grown=lone(105)
near(grown.alpha,peak,1/255+1e-9,'full at end of grow')
near(grown.radius,2*.96*base.awakening_size,1e-6,'full size = opener size')
assert(early.radius<grown.radius,'expands')
near(grown.inner,base.awakening_inner);near(grown.outer,base.awakening_outer)
local mid=lone(105.5);near(mid.alpha,peak*(1-smooth(.5)),1/255+1e-9,'fading')
assert(lone(106.05)==nil,'gone at two-thirds of the wait')
-- 3. Size and until settings apply to links too.
local big=copy(base);big.awakening_size=1.5
near(lone(105,big).radius,2*.96*1.5,1e-6,'size applies')
local cl=copy(base);cl.awakening_until='close'
local mm=linkmodel();m=mm
assert(lone(110,cl),'until close lingers on a link')
-- 4. Closing link: no new window, no new disc.
m=R.new();m.states[71]=copy(opener);m:frame(71,103.5,2,4,base)
local closing=copy(link);closing.closed=true;m.states[71]=closing
for _,t in ipairs({104.3,105,105.5})do
 for _,d in ipairs(awakenings(m,t,base))do assert(d.alpha<=peak*.01+1/255,'closing link draws no awakening at '..t)end
end
-- 5. Hand-off: next link while the previous disc lingers (until close).
m=R.new();m.states[71]=copy(opener);m:frame(71,103.5,2,4,cl);m.states[71]=copy(link)
m:frame(71,108,2,4,cl)
local link3=copy(link);link3.revision=3;link3.created=109;link3.sc_open=112;link3.sc_close=117;link3.step=3
m.states[71]=link3
local just=awakenings(m,109.05,cl)
assert(#just>=1,'previous disc still finishing right after the next link')
local after=awakenings(m,109.35,cl)
for _,d in ipairs(after)do assert(d.radius<2*.96*.9,'old full-size disc gone after .3 s')end
assert(#after==1,'only the new link disc after hand-off')
-- 6. Off switch and killala.
local off=copy(base);off.awakening_links=false
m=linkmodel();assert(lone(105,off)==nil,'links off')
local k=copy(base);for key,v in pairs(R.killala)do k[key]=v end
m=linkmodel();assert(lone(105,k)==nil,'killala has no link disc')
local noawake=copy(base);noawake.awakening=false
m=linkmodel();assert(lone(105,noawake)==nil,'awakening off removes link disc too')
-- 7. Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('awakening',{'links','off'})and settings.awakening_links==false)
assert(cmd('awakening',{'links','on'})and settings.awakening_links==true)
assert(cmd('awakening',{'links','maybe'})and settings.awakening_links==true,'reject')
assert(cmd('awakening',{'size','1.2'})and settings.awakening_size==1.2,'size still works')
assert(cmd('preset',{'killala'})and settings.awakening_links==false)
assert(cmd('preset',{'default'})and settings.awakening_links==true)
print('PASS Test6.7 awakening links: link disc on opener curve (own wait), size/until apply, closing link none, .3 s hand-off, opener unchanged, off/killala/awakening off, commands')
