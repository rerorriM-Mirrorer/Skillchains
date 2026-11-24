-- Test7.7: a level-4 link (Radiance/Umbra) from a level 3 opens by collapsing
-- the level 3's rings (white, from where they were) into one ring, then the
-- four level-4 rings expand concentrically out of it (ease-out until the
-- window opens). Ground rings only. `rings level4 open pop` keeps the earlier
-- single white ring for .16 s. Levels 1-3 are unchanged.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance')
local M=require('resonance_motion')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function link(level,property,created)
    return {id=77,revision=level,created=created,sc_open=created+3,sc_close=created+8,mb_close=created+10,
        step=level==1 and 2 or level,level=level,properties={property},elements=R.elements(property)}
end
local function frame(now,o,level,property,prior_level,prior_property)
    local m=R.new()
    local s=link(level,property,100)
    if prior_level then s.previous=link(prior_level,prior_property,90)end
    m.states[77]=s
    return m:frame(77,now,2,4,o)
end
local function cores(f,part)
    local list={}
    -- No part: the SC rings (ground and sky), never the MB ring.
    for _,x in ipairs(f)do if x.role=='core'and (part and x.part==part or not part and (x.part=='ground'or x.part=='sky'))then list[#list+1]=x end end
    return list
end
local function mb_ring(f)
    for _,x in ipairs(f)do if x.part=='mb'and x.role=='core'then return x end end
end
local base=copy(R.defaults);base.mb_intro=0
local cioara=dofile('TargetSC/tests/fixture_cioara.lua');cioara.mb_intro=0
assert(R.defaults.ring_level4_open=='collapse'and R.defaults.ring_level4_collapse=='into'and R.defaults.ring_level4_expand=='mb')
assert(R.defaults.ring_level4_collapse_time==.12 and R.defaults.ring_level4_expand_time==-1 and R.defaults.ring_level4_ease==6)
for _,o in ipairs({base,cioara})do
    for _,c in ipairs({{'Radiance','Light'},{'Umbra','Darkness'}})do
        local p,prior=c[1],c[2]
        local l3=cores(frame(100,copy(o),3,prior,2,'Fusion')) -- the L3 at the strike moment (for counts)
        for _,target in ipairs({'ground','mb','into'})do
            for _,plane in ipairs({'ground','mb'})do
                local opt=copy(o);opt.ring_level4_collapse,opt.ring_level4_expand=target,plane
                local tag=p..' '..target..'/'..plane
                -- Frame 1: the previous level 3's rings, all white, nothing in the sky set.
                local f0=frame(100,opt,4,p,3,prior)
                local c0=cores(f0)
                assert(#c0>=3,tag..': L3 strands drawn on frame 1')
                for _,x in ipairs(c0)do assert(x.color%16777216==0xFFFFFF,tag..': white collapse')end
                -- Collapse converges: radius/height spread shrinks to zero.
                local plan=frame(100.11999,opt,4,p,3,prior)
                local cc=cores(plan)
                local lo,hi,rlo,rhi=1e9,-1e9,1e9,-1e9
                for _,x in ipairs(cc)do lo,hi=math.min(lo,x.offset),math.max(hi,x.offset);rlo,rhi=math.min(rlo,x.radius),math.max(rhi,x.radius)end
                assert(hi-lo<.01 and rhi-rlo<.02,tag..': nearly one ring at the end of the collapse')
                -- Just after: four rings, overlapping at the collapse spot.
                local f1=frame(100.121,opt,4,p,3,prior)
                local g1=cores(f1,'ground')
                assert(#g1==4,tag..': four L4 rings after the collapse')
                assert(#cores(f1,'sky')==0,tag..': ground only')
                local r1=g1[4].radius-g1[1].radius
                assert(r1>=0 and r1<.05,tag..': four rings start overlapping')
                -- Expansion: spacing grows monotonically, fast first then gently.
                local last,gaps=r1,{}
                for _,t in ipairs({100.2,100.4,100.8,101.5,102.5,102.99})do
                    local g=cores(frame(t,opt,4,p,3,prior),'ground')
                    assert(#g==4,tag..': four at '..t)
                    local gap=g[4].radius-g[1].radius
                    assert(gap>=last-1e-9,tag..': expanding at '..t)
                    gaps[#gaps+1]=gap;last=gap
                end
                assert(gaps[1]-r1>(gaps[6]-gaps[5])*3,tag..': ease-out (fast start)')
                -- Window open: normal concentric radii (1 +/- .075 steps).
                local g=cores(frame(103.05,opt,4,p,3,prior),'ground')
                if #g==4 then near(g[4].radius-g[1].radius,2*3*.075,1e-6,tag..' settled spread')end
                -- Plane: mb = steady MB height reference, ground = the old ground height.
                local mb=mb_ring(frame(101,opt,4,p,3,prior))
                local pl=cores(frame(101,opt,4,p,3,prior),'ground')[1]
                if plane=='mb'and mb then assert(math.abs(pl.offset-mb.offset)<.05,tag..': rings around the MB ring')end
            end
        end
        -- into collapses onto the MB ring radius; mb/ground at the SC size.
        local into=copy(o);into.ring_level4_collapse='into'
        local mbm=copy(o);mbm.ring_level4_collapse='mb'
        local ri=cores(frame(100.121,into,4,p,3,prior),'ground')[1].radius
        local rm=cores(frame(100.121,mbm,4,p,3,prior),'ground')[1].radius
        assert(ri<rm,p..': into starts at the (smaller) MB ring size')
        -- MB ring hidden: falls back to ground for both.
        local hidden=copy(o);hidden.display='sc'
        local gr=copy(o);gr.display='sc';gr.ring_level4_collapse='ground';gr.ring_level4_expand='ground'
        for _,t in ipairs({100.05,100.2,101})do
            local a,b=cores(frame(t,hidden,4,p,3,prior)),cores(frame(t,gr,4,p,3,prior))
            assert(#a==#b,p..' fallback count '..t)
            for i=1,#a do near(a[i].offset,b[i].offset,1e-9,p..' fallback height '..t);near(a[i].radius,b[i].radius,1e-9,p..' fallback radius '..t)end
        end
        -- No previous level 3 (preview chain): no collapse, expansion from frame 1.
        local g=cores(frame(100,copy(o),4,p),'ground')
        assert(#g==4,p..': no previous -> four rings from frame 1')
        -- pop: the earlier look (one white ring for .16 s).
        local pop=copy(o);pop.ring_level4_open='pop'
        assert(#cores(frame(100.05,pop,4,p,3,prior),'ground')==1,p..': pop one ring')
    end
    -- Levels 1-3 unchanged by the level-4 settings.
    local a,b=copy(o),copy(o);b.ring_level4_open='pop'
    for _,c in ipairs({{1,'Liquefaction',2,'Fusion'},{2,'Fusion',2,'Fusion'},{3,'Light',2,'Fusion'}})do
        for _,t in ipairs({100,100.05,100.2,100.5})do
            local x,y=frame(t,a,c[1],c[2],c[3],c[4]),frame(t,b,c[1],c[2],c[3],c[4])
            assert(#x==#y,c[2]..' same band count '..t)
            for i=1,#x do assert(x[i].offset==y[i].offset and x[i].radius==y[i].radius and x[i].color==y[i].color,c[2]..' unchanged '..t)end
        end
    end
end
print('PASS Test7.7 level 4 collapse: L3 rings white -> one ring (ground|mb|into), four rings expand ease-out (mb|ground plane), ground only, MB-hidden fallback, pop keeps the old look, levels 1-3 unchanged')
-- Commands and presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('rings',{'level4','open','pop'})and settings.ring_level4_open=='pop')
assert(cmd('rings',{'level4','open','collapse'})and settings.ring_level4_open=='collapse')
assert(cmd('rings',{'level4','collapse','ground'})and settings.ring_level4_collapse=='ground')
assert(cmd('rings',{'level4','collapse','mb'})and settings.ring_level4_collapse=='mb')
assert(cmd('rings',{'level4','collapse','into'})and settings.ring_level4_collapse=='into')
assert(cmd('rings',{'level4','expand','ground'})and settings.ring_level4_expand=='ground')
assert(cmd('rings',{'level4','expand','mb'})and settings.ring_level4_expand=='mb')
assert(cmd('rings',{'level4','collapse','time','.2'})and settings.ring_level4_collapse_time==.2)
assert(cmd('rings',{'level4','collapse','time','1'})and settings.ring_level4_collapse_time==.2)
assert(cmd('rings',{'level4','expand','time','1.5'})and settings.ring_level4_expand_time==1.5)
assert(cmd('rings',{'level4','ease','4'})and settings.ring_level4_ease==4)
assert(cmd('rings',{'level4','wobble'})and settings.ring_level4_open=='collapse')
assert(cmd('preset',{'killala'})and settings.ring_level4_open=='pop')
assert(cmd('preset',{'default'})and settings.ring_level4_open=='collapse'and settings.ring_level4_collapse=='into')
print('PASS Test7.7 commands and presets')
-- Preview path (E4b): demo and demo radiance chain L3 -> L4 and collapse.
local P=require('resonance_preview')
local opts=copy(R.defaults);opts.mb_intro=0
for _,args in ipairs({{'demo'},{'demo','radiance'}})do
    local preview=P.new(assert(P.parse(args,R)),77,200,R,opts)
    local at
    for _,e in ipairs(preview.events)do if e.kind=='chain'and e.state.level==4 then at=e.at end end
    assert(at,'demo has a level 4 link')
    preview:advance(at)
    assert(preview.model.states[77].previous.level==3,'chained from level 3')
    local c0=cores(preview.model:frame(77,at,2,4,opts))
    assert(#c0>=3,'demo collapse frame 1 shows the L3 rings')
    for _,x in ipairs(c0)do assert(x.color%16777216==0xFFFFFF,'demo collapse white')end
    local g=cores(preview.model:frame(77,at+.5,2,4,opts),'ground')
    assert(#g==4 and #cores(preview.model:frame(77,at+.5,2,4,opts),'sky')==0,'demo four ground rings')
end
print('PASS Test7.7 preview path: demo and demo radiance level 4 links collapse and expand')
