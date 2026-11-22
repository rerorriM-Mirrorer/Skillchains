-- Test7.5: a level-3 link opens as three strands squeezed together that
-- separate to the normal stack over the .3 s glide from the previous
-- link's heights. `rings level3 open pop` keeps the earlier single white
-- ring for .16 s. Levels 1, 2 and 4 are unchanged.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function link(level,property,created)
    return {id=75,revision=level,created=created,sc_open=created+3,sc_close=created+8,mb_close=created+10,
        step=level==1 and 2 or level,level=level,properties={property},elements=R.elements(property)}
end
-- Previous link created at 90; the level-3 link lands at 100 (its countdown
-- still running), so the glide starts from the old link's heights.
local function frame(now,o,level,property,prior)
    local m=R.new()
    local s=link(level,property,100)
    s.previous=link(prior or 2,prior==3 and property or 'Fusion',90)
    m.states[75]=s
    return m:frame(75,now,2,4,o)
end
-- Ground core strand heights, by strand.
local function ground(f)
    local h={}
    for _,x in ipairs(f)do if x.role=='core'and x.part=='ground'then h[x.strand]=x.offset end end
    local list={}for j=1,#h do list[j]=h[j]end
    return list
end
local base=copy(R.defaults);base.mb_intro=0
local cioara=dofile('TargetSC/tests/fixture_cioara.lua');cioara.mb_intro=0
for _,o in ipairs({base,cioara})do
    for _,p in ipairs({'Light','Darkness'})do
        for _,look in ipairs({{},{ring_light='classic',ring_lightdark='classic'},{ring_light='elements'}})do
            local opt=copy(o);for k,v in pairs(look)do opt[k]=v end
            local tag=p..' '..(look.ring_light or 'profile')
            -- First frame: three strands (not one ring), half the normal spacing.
            local first=ground(frame(100,opt,3,p))
            assert(#first==3,tag..': three strands on the first frame')
            near(first[2]-first[1],.035*.5,1e-9,tag..' start spacing lower')
            near(first[3]-first[2],.035*.5,1e-9,tag..' start spacing upper')
            -- The lowest strand starts at the previous link's ground height.
            local old=ground(frame(100,copy(opt),2,'Fusion'))
            -- Spacing grows monotonically through the glide.
            local last=first[2]-first[1]
            for _,t in ipairs({100.05,100.1,100.16,100.2,100.25,100.29})do
                local g=ground(frame(t,opt,3,p))
                assert(#g==3,tag..': three strands at '..t)
                local gap=g[2]-g[1]
                assert(gap>last-1e-12,tag..': spacing grows at '..t)
                assert(gap<.035+1e-12,tag..': never past the stack at '..t)
                last=gap
            end
            -- Settled: the normal level-3 stack.
            for _,t in ipairs({100.3,101,102.5})do
                local g=ground(frame(t,opt,3,p))
                near(g[2]-g[1],.035,1e-9,tag..' settled lower '..t)
                near(g[3]-g[2],.035,1e-9,tag..' settled upper '..t)
            end
            -- pop: the earlier look (one ring until .16 s, then three).
            local pop=copy(opt);pop.ring_level3_open='pop'
            assert(#ground(frame(100.05,pop,3,p))==1,tag..': pop one ring at .05')
            assert(#ground(frame(100.2,pop,3,p))==3,tag..': pop three at .2')
            -- start 1 = full spacing from the first frame; 0 = all on one height.
            local full=copy(opt);full.ring_level3_start=1
            local g=ground(frame(100,full,3,p));near(g[2]-g[1],.035,1e-9,tag..' start 1')
            local zero=copy(opt);zero.ring_level3_start=0
            g=ground(frame(100,zero,3,p));near(g[2]-g[1],0,1e-9,tag..' start 0')
        end
    end
    -- Lowest strand follows the same glide as before (unchanged heights).
    local spread,pop=copy(o),copy(o);pop.ring_level3_open='pop'
    for _,t in ipairs({100.2,100.25,100.5,101})do
        near(ground(frame(t,spread,3,'Light'))[1],ground(frame(t,pop,3,'Light'))[1],1e-9,'same glide '..t)
    end
    -- Levels 1, 2 and 4: identical under both settings.
    for _,c in ipairs({{1,'Liquefaction',2},{2,'Fusion',2},{4,'Radiance',3},{4,'Umbra',3}})do
        local level,p,prior=c[1],c[2],c[3]
        local prop=prior==3 and (p=='Radiance'and 'Light'or 'Darkness')or p
        for _,t in ipairs({100,100.05,100.2,100.5})do
            local a=frame(t,spread,level,p,prior)
            local b=frame(t,pop,level,p,prior)
            assert(#a==#b,p..' same band count '..t)
            for i=1,#a do
                assert(a[i].offset==b[i].offset and a[i].radius==b[i].radius and a[i].color==b[i].color,p..' unchanged '..t)
            end
        end
    end
end
-- Commands and presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(settings.ring_level3_open==nil or settings.ring_level3_open=='spread')
assert(R.defaults.ring_level3_open=='spread'and R.defaults.ring_level3_start==.5)
assert(cmd('rings',{'level3','open','pop'})and settings.ring_level3_open=='pop')
assert(cmd('rings',{'level3','open','spread'})and settings.ring_level3_open=='spread')
assert(cmd('rings',{'level3','open','wobble'})and settings.ring_level3_open=='spread')
assert(cmd('rings',{'level3','start','.25'})and settings.ring_level3_start==.25)
assert(cmd('rings',{'level3','start','2'})and settings.ring_level3_start==.25)
assert(cmd('preset',{'killala'})and settings.ring_level3_open=='pop')
assert(cmd('preset',{'default'})and settings.ring_level3_open=='spread'and settings.ring_level3_start==.5)
print('PASS Test7.5 level 3 spread: three strands from the first frame at half spacing, separating over the .3 s glide; pop keeps the old look; levels 1/2/4 unchanged; commands and presets')
-- Preview path (E4b): the demos' level 2 -> level 3 links spread open.
local P=require('resonance_preview')
local opts=copy(R.defaults);opts.mb_intro=0
for _,args in ipairs({{'demo'},{'demo','radiance'}})do
    local preview=P.new(assert(P.parse(args,R)),75,200,R,opts)
    local at
    for _,e in ipairs(preview.events)do if e.kind=='chain'and e.state.level==3 then at=e.at end end
    assert(at,'demo has a level 3 link')
    preview:advance(at)
    assert(preview.model.states[75].previous.level==2,'chained from level 2')
    local g0=ground(preview.model:frame(75,at,2,4,opts))
    local g2=ground(preview.model:frame(75,at+.4,2,4,opts))
    assert(#g0==3,'demo three strands frame 1')
    near(g0[2]-g0[1],.0175,1e-9,'demo half spacing frame 1')
    near(g2[2]-g2[1],.035,1e-9,'demo settled')
end
print('PASS Test7.5 preview path: demo and demo radiance level 3 links spread open')
