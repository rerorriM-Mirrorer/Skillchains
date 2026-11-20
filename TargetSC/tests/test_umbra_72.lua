-- Test7.2: under disc fades (same size) in the Umbra collapse; glyph copies
-- may keep spawning until the MB deadline. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
R.native_level=12
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function alpha(c)return math.floor(c/16777216)end
local function link(o)local p=P.new(P.parse({'Radiance','4'},R),71,0,R,o)local st=p.model.states[71];st.properties={'Umbra'};st.elements=R.elements('Umbra')return p end
local function at(p,t,o)p:advance(t)return p.model:frame(71,t,2,4,o)end
local function all(f,role)local r={}if f and f.discs then for _,d in ipairs(f.discs)do if d.role==role then r[#r+1]=d end end end return r end
local o=copy(R.defaults)
assert(o.umbra_under_ending=='fade'and o.umbra_copies_until=='flash','defaults')
local u=copy(o);u.umbra_under=true;u.umbra_collapse_time=3;u.umbra_collapse_curve=2
local st=link(u).model.states[71]
local early=all(at(link(u),st.mb_close-4,u),'umbra-under')[1]
local mid=at(link(u),st.mb_close-1,u)
local d,black=all(mid,'umbra-under')[1],all(mid,'property')[1]
local c=M.umbra_collapse(st,st.mb_close-1,u)
assert(c<.8,'collapsing')
near(d.radius,early.radius,1e-9,'fade: same size')
assert(black.radius<all(at(link(u),st.mb_close-4,u),'property')[1].radius*.9,'black disc still shrinks')
near(alpha(d.colors[1]),alpha(early.colors[1])*c,1.01,'alpha follows the collapse')
assert(d.color==d.colors[1],'color kept in step')
local late=all(at(link(u),st.mb_close-.05,u),'umbra-under')[1]
assert(not late or alpha(late.colors[1])<=alpha(early.colors[1])*.05+1,'nearly gone by the deadline')
local sh=copy(u);sh.umbra_under_ending='shrink'
local ds=all(at(link(sh),st.mb_close-1,sh),'umbra-under')[1]
near(ds.radius,early.radius*c,1e-9,'shrink: old behavior')
assert(alpha(ds.colors[1])==alpha(early.colors[1]),'shrink keeps alpha')
-- Copies until end.
local cp=copy(o);cp.umbra_copies=true
local stop=M.umbra_flashed(st,cp,true)
local function copies(opts,t)return #all(at(link(opts),t,opts),'umbra-copy')end
local tl=stop+cp.umbra_copies_life+.5
assert(tl<st.mb_close-.2,'test time inside the window')
assert(copies(cp,tl)==0,'flash: no copies after the flash-out')
local ce=copy(cp);ce.umbra_copies_until='end'
assert(copies(ce,tl)>0,'end: copies keep coming')
assert(copies(ce,st.mb_close-.1)>0,'end: still there near the deadline')
assert(copies(ce,stop-.3)==copies(cp,stop-.3),'same before the flash-out')
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
cmd('umbra',{'under','ending','shrink'});assert(settings.umbra_under_ending=='shrink')
cmd('umbra',{'copies','until','end'});assert(settings.umbra_copies_until=='end')
cmd('umbra',{'copies','until','x'});assert(settings.umbra_copies_until=='end','rejects')
print('PASS Test7.2: under disc fades at full size in the collapse (shrink keeps the old look), copies until end keep spawning to the deadline (flash unchanged), commands')
