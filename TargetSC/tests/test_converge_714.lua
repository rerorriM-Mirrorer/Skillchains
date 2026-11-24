-- Test7.14: L2/L3 strands and opener arcs close into one ring as the sky
-- ring lands; Umbra under-slow curve in|out; dark palette for aeonic openers.
-- Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local M=require('resonance_motion')
R.native_level=12
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
assert(R.defaults.ring_converge==true and R.defaults.ring_converge_from==.35,'converge defaults')
assert(R.defaults.umbra_slow_curve=='in'and R.defaults.umbra_slow_power==3,'slow curve defaults')

local function cores(f,part)
    local r={}
    for _,v in ipairs(f)do if v.role=='core'and v.part==part and v.kind~='arc'then r[#r+1]=v end end
    table.sort(r,function(a,b)return a.offset<b.offset end)
    return r
end
local function spread(f,part)local c=cores(f,part)return c[#c].offset-c[1].offset,#c end
local function run(args,o,id)
    local p=P.new(P.parse(args,R),id,0,R,o)
    local st=p.model.states[id]
    return p,st
end
local function frame(p,id,t,o)p:advance(t)return p.model:frame(id,t,2,4,o)end

-- Strands: L2 (Fusion) and L3 (Darkness), defaults and A's profile.
for _,o in ipairs({copy(R.defaults),(function()local a=copy(require('tests.fixture_cioara_1122'))for k,v in pairs(R.defaults)do if a[k]==nil then a[k]=v end end return a end)()})do
    for _,prop in ipairs({'Fusion','Darkness'})do
        local p,st=run({'chain',prop},o,71)
        local mid=st.sc_open+.4*(st.sc_close-st.sc_open)
        local d_mid,n=spread(frame(p,71,mid,o),'ground')
        assert(n>=2,prop..' has strands')
        local off=copy(o);off.ring_converge=false
        local q=run({'chain',prop},off,72)
        local d_off=spread(frame(q,72,mid,off),'ground')
        near(d_mid,d_off,1e-9,prop..' full spacing mid-window')
        -- Shrinking as the sky lands, meeting at the close.
        local late=st.sc_close-.05
        local d_late=spread(frame(p,71,late,o),'ground')
        local d_late_off=spread(frame(q,72,late,off),'ground')
        assert(d_late<d_late_off*.5,prop..' strands converging late '..d_late..' vs '..d_late_off)
        local f=frame(p,71,st.sc_close+.01,o)
        local d_end=spread(f,'ground')
        near(d_end,0,1e-6,prop..' one ring at the close')
        assert(d_late_off>0,'off keeps the stack')
    end
end

-- Opener arcs: gaps and lifts close into one ring (Requiescat-style opener).
local o=copy(R.defaults)
o.ring_converge_opener=-1 -- Test7.15: this block checks the shared .35 start
local p,st=run({'opener','Gravitation,Scission'},o,73)
local function arcs(f)local r={}for _,v in ipairs(f)do if v.kind=='arc'and v.role=='core'and v.part=='ground'then r[#r+1]=v end end return r end
local function coverage(f)local a=arcs(f);local total,lifts=0,{}
    local seen={}
    for _,v in ipairs(a)do local key=v.arc_start;if not seen[key]then seen[key]=true;total=total+v.arc_span end;lifts[#lifts+1]=v.offset end
    table.sort(lifts)return total,lifts[#lifts]-lifts[1],#a end
local mid=st.sc_open+.3*(st.sc_close-st.sc_open)
local cov_mid,lift_mid,na=coverage(frame(p,73,mid,o))
assert(na>=3,'opener arcs drawn '..na)
near(cov_mid,360-2*60,1e-6,'two sections keep 60 deg gaps mid-window')
assert(lift_mid>0,'element arcs lifted mid-window')
local cov_end,lift_end=coverage(frame(p,73,st.sc_close+.01,o))
near(cov_end,360,1e-6,'arcs meet into one ring at the close')
near(lift_end,0,1e-6,'element arcs on one height at the close')
local off=copy(o);off.ring_converge=false
local q=run({'opener','Gravitation,Scission'},off,74)
local cov_off=coverage(frame(q,74,st.sc_close-.01,off))
near(cov_off,240,1e-6,'off keeps the gaps')
-- Before the window opens nothing changes.
near(M.converge(st,st.sc_open-1,o),1,1e-9,'pre-window untouched')
-- Closed (level-4) results never converge.
near(M.converge({closed=true,sc_open=0,sc_close=5,created=0},4,o),1,1e-9,'closed untouched')

-- Commands.
local settings=copy(R.defaults);local said
local cmd=C.new(settings,R.defaults,function()end,function(m)said=m end,R.killala,R.cioara)
assert(cmd('rings',{'converge','off'})and settings.ring_converge==false)
assert(cmd('rings',{'converge','on'})and settings.ring_converge==true)
assert(cmd('rings',{'converge','from','.5'})and settings.ring_converge_from==.5)
assert(cmd('rings',{'converge','bogus'})and said:find('^Use //tsc rings converge'))
assert(cmd('umbra',{'slow','curve','out'})and settings.umbra_slow_curve=='out')
assert(cmd('umbra',{'slow','power','5'})and settings.umbra_slow_power==5)

-- Umbra under slow: 'in' stays faster early, both end at the same rate,
-- and the angle is continuous (no jump at the flash or at the slow end).
local u=copy(R.defaults);u.umbra_under_slow=true;u.umbra_slow_time=2;u.umbra_slow_to=0;u.disc_speed_level4=1
local s4={created=0,sc_open=3,sc_close=10,mb_close=13,step=5,level=4,properties={'Umbra'},closed=true}
local f0=M.umbra_flashed(s4,u,false)
local function rate(opts,t)local h=1e-4 return (M.umbra_under_turn(s4,t+h,opts,false)-M.umbra_under_turn(s4,t-h,opts,false))/(2*h)end
local out=copy(u);out.umbra_slow_curve='out'
local w=rate(u,f0-.5)
assert(rate(u,f0+.5)>.9*w,'in: still near full speed .5 s after the flash')
assert(rate(out,f0+.5)<.6*w,'out: Test7.12 slows at once')
assert(rate(u,f0+1.8)<rate(u,f0+1)and rate(u,f0+1)<rate(u,f0+.5),'in: slowing harder toward the end')
near(rate(u,f0+3),0,1e-3,'in: stopped after slow time (slow to 0)')
near(M.umbra_under_turn(s4,f0+1e-6,u,false),M.umbra_under_turn(s4,f0-1e-6,u,false),1e-3,'continuous at flash')
local half=copy(u);half.umbra_slow_to=.5
near(rate(half,f0+3),.5*w,1e-3*w,'slow to .5 holds half speed')

-- Aeonic opener palette: Gravitation, Scission, Darkness (Requiescat + Sequence) is dark.
local spec=P.parse({'demo','requiescat'},R)
local rq=P.new(spec,75,0,R,copy(R.defaults))
local op=rq.model.states[75]
assert(op.level==3 and op.properties[3]=='Darkness','Sequence opener')
local frame0=rq.model:frame(75,.1,2,4,copy(R.defaults))
assert(frame0,'opener draws')
-- Each property gets its own disc; the third (Darkness) uses the level-3 dark set.
local found
for _,d in ipairs(frame0.discs or {})do
    if d.role=='property'and #d.colors==3 and d.colors[1]%16777216==R.argb({5,5,8},1)%16777216 then found=true end
end
assert(found,'Darkness property disc in the Sequence opener')
print('PASS Test7.14 strands/opener arcs converge at the close, umbra slow curve in|out, aeonic opener dark palette')
