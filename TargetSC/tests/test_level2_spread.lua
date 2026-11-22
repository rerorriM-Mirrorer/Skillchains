-- Test7.6: a level-2 link from an opener or level 1 opens as its pair
-- squeezed together (split: one ring, half: half the gap) that separates to
-- the normal .035 over the .3 s glide. stacked = the earlier full pair.
-- A level 2 after a level 2 keeps the stacked look.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function link(level,property,created,step)
    return {id=76,revision=step,created=created,sc_open=created+3,sc_close=created+8,mb_close=created+10,
        step=step,level=level,properties={property},elements=R.elements(property)}
end
-- prior: nil (plain preview path, no previous), 1 (opener), 'L1' or 'L2'.
local function frame(now,o,prior)
    local m=R.new()
    local s=link(2,'Fusion',100,3)
    if prior=='opener'then s.previous=link(1,'Scission',97,1)
    elseif prior=='L1'then s.previous=link(1,'Liquefaction',94,2)
    elseif prior=='L2'then s.previous=link(2,'Fragmentation',94,2)end
    m.states[76]=s
    return m:frame(76,now,2,4,o)
end
local function ground(f)
    local h={}
    for _,x in ipairs(f)do if x.role=='core'and x.part=='ground'then h[x.strand]=x.offset end end
    local list={}for j=1,#h do list[j]=h[j]end
    return list
end
local base=copy(R.defaults);base.mb_intro=0
local cioara=dofile('TargetSC/tests/fixture_cioara.lua');cioara.mb_intro=0
assert(R.defaults.ring_level2_open=='spread'and R.defaults.ring_level2_start==0)
for _,o in ipairs({base,cioara})do
    for _,prior in ipairs({'none','opener','L1'})do
        local p=prior~='none'and prior or nil
        for _,mode in ipairs({{'split',0},{'half',.5}})do
            local opt=copy(o);opt.ring_level2_open='spread';opt.ring_level2_start=mode[2]
            local tag=prior..' '..mode[1]
            local first=ground(frame(100,opt,p))
            assert(#first==2,tag..': two strands from the first frame')
            near(first[2]-first[1],.035*mode[2],1e-9,tag..' start gap')
            local last=first[2]-first[1]
            for _,t in ipairs({100.05,100.1,100.16,100.2,100.25,100.29})do
                local g=ground(frame(t,opt,p))
                local gap=g[2]-g[1]
                assert(gap>last-1e-12 and gap<.035+1e-12,tag..': gap grows within the stack at '..t)
                last=gap
            end
            assert(last>.03,tag..': nearly open by .29')
            for _,t in ipairs({100.3,101,102.5,104})do
                local g=ground(frame(t,opt,p));near(g[2]-g[1],.035,1e-9,tag..' settled '..t)
            end
            -- Same lowest-strand glide as stacked.
            local st=copy(o);st.ring_level2_open='stacked'
            for _,t in ipairs({100,100.1,100.2,100.5})do
                near(ground(frame(t,opt,p))[1],ground(frame(t,st,p))[1],1e-9,tag..' same glide '..t)
            end
        end
        -- stacked: full gap from the first frame.
        local st=copy(o);st.ring_level2_open='stacked'
        local g=ground(frame(100,st,p));near(g[2]-g[1],.035,1e-9,prior..' stacked frame 1')
    end
    -- Level 2 after level 2 keeps the stacked look under every setting.
    for _,start in ipairs({0,.5})do
        local opt=copy(o);opt.ring_level2_open='spread';opt.ring_level2_start=start
        local g=ground(frame(100,opt,'L2'));near(g[2]-g[1],.035,1e-9,'L2 after L2 frame 1')
    end
end
-- Commands and presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('rings',{'level2','open','half'})and settings.ring_level2_open=='spread'and settings.ring_level2_start==.5)
assert(cmd('rings',{'level2','open','split'})and settings.ring_level2_open=='spread'and settings.ring_level2_start==0)
assert(cmd('rings',{'level2','open','stacked'})and settings.ring_level2_open=='stacked')
assert(cmd('rings',{'level2','open','spread'})and settings.ring_level2_open=='spread')
assert(cmd('rings',{'level2','open','wobble'})and settings.ring_level2_open=='spread')
assert(cmd('rings',{'level2','start','.25'})and settings.ring_level2_start==.25)
assert(cmd('rings',{'level2','start','3'})and settings.ring_level2_start==.25)
assert(cmd('preset',{'killala'})and settings.ring_level2_open=='stacked')
assert(cmd('preset',{'default'})and settings.ring_level2_open=='spread'and settings.ring_level2_start==0)
print('PASS Test7.6 level 2 spread: split/half pairs separate over the .3 s glide (opener, level 1, no-previous preview path); stacked keeps the old look; level 2 after level 2 unchanged; commands and presets')
-- Preview path (E4b): the demo's L1 -> Gravitation (L2) link and the plain
-- `preview chain Fusion 2` (no previous link) both split open.
local P=require('resonance_preview')
local opts=copy(R.defaults);opts.mb_intro=0
for _,args in ipairs({{'demo'},{'demo','radiance'}})do
    local preview=P.new(assert(P.parse(args,R)),76,200,R,opts)
    local at
    for _,e in ipairs(preview.events)do if e.kind=='chain'and e.state.level==2 then at=e.at end end
    assert(at,'demo has a level 2 link')
    preview:advance(at)
    local s=preview.model.states[76]
    assert(s.level==2 and s.previous and s.previous.level==1,'chained from level 1')
    local g0=ground(preview.model:frame(76,at,2,4,opts))
    local g1=ground(preview.model:frame(76,at+.15,2,4,opts))
    local g2=ground(preview.model:frame(76,at+.4,2,4,opts))
    near(g0[2]-g0[1],0,1e-9,'demo split frame 1')
    assert(g1[2]-g1[1]>0 and g1[2]-g1[1]<.035,'demo mid split')
    near(g2[2]-g2[1],.035,1e-9,'demo settled')
end
local plain=P.parse({'chain','Fusion','2'},R)
if plain then
    local preview=P.new(plain,76,200,R,opts);preview:advance(200)
    local g=ground(preview.model:frame(76,200,2,4,opts))
    if #g==2 then near(g[2]-g[1],0,1e-9,'plain preview split frame 1')end
end
print('PASS Test7.6 preview path: demo and demo radiance level 2 links split open')
