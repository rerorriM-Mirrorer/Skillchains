-- Test7.8: level-4 rings grow out from the MB ring as drawn (Umbra x umbra mb
-- size): the innermost ring from the collapse ring to gap outside the MB
-- ring, the outer three spreading from the innermost on the same ease.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function link(level,property,created)
    return {id=78,revision=level,created=created,sc_open=created+3,sc_close=created+8,mb_close=created+10,
        step=level==1 and 2 or level,level=level,properties={property},elements=R.elements(property)}
end
local function frame(now,o,p,prior)
    local m=R.new();local s=link(4,p,100);if prior then s.previous=link(3,prior,90)end
    m.states[78]=s;return m:frame(78,now,2,4,o)
end
local function ground(f)local g={}for _,x in ipairs(f)do if x.role=='core'and x.part=='ground'then g[x.strand]=x end end return g end
local function mb(f)for _,x in ipairs(f)do if x.role=='core'and x.part=='mb'then return x end end end
assert(R.defaults.ring_level4_gap==.03 and R.defaults.ring_level4_spacing==.075)
local base=copy(R.defaults);base.mb_intro=0
local a=dofile('TargetSC/tests/fixture_cioara_1121.lua');a.mb_intro=0
for k,v in pairs(R.defaults)do if a[k]==nil then a[k]=v end end -- new settings merge like Windower config
for _,o in ipairs({base,a})do
    for _,c in ipairs({{'Radiance','Light'},{'Umbra','Darkness'}})do
        local p,prior=c[1],c[2]
        local tag=p..(o==a and ' cioara'or ' default')
        local ct=o.ring_level4_collapse_time
        -- into: the four rings start on the MB ring as drawn.
        local f=frame(100+ct+.001,o,p,prior)
        local g,m=ground(f),mb(f)
        assert(m and #g==4,tag..': MB ring and four rings')
        near(g[1].radius,m.radius,.01,tag..' start on the MB ring')
        -- Settled (well past the expansion): innermost = MB + gap, steps = spacing.
        local late=copy(o);late.ring_level4_expand_time=.5
        local fl=frame(102.9,late,p,prior)
        local gl,ml=ground(fl),mb(fl)
        near(gl[1].radius,ml.radius+2*late.ring_level4_gap,1e-6,tag..' innermost outside the MB ring')
        for j=2,4 do near(gl[j].radius-gl[j-1].radius,2*late.ring_level4_spacing,1e-6,tag..' spacing '..j)end
        -- Every ring grows (none shrinks); spacing grows in step with the innermost.
        local last
        for _,t in ipairs({100.2,100.5,101,101.6,102.4})do
            local x=ground(frame(t,o,p,prior))
            if last then for j=1,4 do assert(x[j].radius>=last[j].radius-1e-9,tag..' ring '..j..' never shrinks at '..t)end end
            local e=(x[1].radius-g[1].radius)/(gl[1].radius-g[1].radius)
            if o.ring_level4_expand_time==-1 or o.ring_level4_expand_time==.5 then
                near(x[2].radius-x[1].radius,2*o.ring_level4_spacing*e,.002,tag..' same ease '..t)
            end
            last=x
        end
        -- gap and spacing settings.
        local wide=copy(late);wide.ring_level4_gap=.1;wide.ring_level4_spacing=.05
        local gw,mw=ground(frame(102.9,wide,p,prior)),mb(frame(102.9,wide,p,prior))
        near(gw[1].radius,mw.radius+.2,1e-6,tag..' gap .1');near(gw[4].radius-gw[1].radius,.3,1e-6,tag..' spacing .05')
        -- expand ground keeps the earlier final sizes.
        local gr=copy(late);gr.ring_level4_expand='ground'
        local gg=ground(frame(102.9,gr,p,prior))
        near(gg[1].radius,2*(1-1.5*.075),1e-6,tag..' ground innermost');near(gg[4].radius,2*(1+1.5*.075),1e-6,tag..' ground outermost')
    end
end
-- Umbra's into collapse aims at the drawn (scaled) MB ring.
local u=copy(a);u.umbra_mb_size=.7
local fu=frame(100+u.ring_level4_collapse_time-.001,u,'Umbra','Darkness')
local mu=mb(fu)
for _,x in ipairs(fu)do if x.role=='core'and (x.part=='ground'or x.part=='sky')then near(x.radius,mu.radius,.02,'Umbra collapse onto scaled MB ring')end end
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('rings',{'level4','gap','.05'})and settings.ring_level4_gap==.05)
assert(cmd('rings',{'level4','gap','1'})and settings.ring_level4_gap==.05)
assert(cmd('rings',{'level4','spacing','.1'})and settings.ring_level4_spacing==.1)
assert(cmd('rings',{'level4','spacing','-1'})and settings.ring_level4_spacing==.1)
print('PASS Test7.8 level 4 geometry: innermost grows from the drawn MB ring to gap outside it, outer rings spread from it on the same ease, Umbra size respected, gap/spacing, expand ground unchanged (defaults and A\'s 11-21 profile)')
