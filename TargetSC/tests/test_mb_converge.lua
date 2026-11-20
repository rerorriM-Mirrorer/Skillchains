-- Test6.5: //tsc mb ending style converge. Over the last `mb ending` s the MB
-- ring descends onto the ground glyph and brightens toward white (no pulses,
-- stays visible); the ground glyph emerges on the same shared progress;
-- rising glyphs are capped (and held) at the ring; ring-plane blooms start at
-- the ring's height at their burst; everything ends at the real MB deadline.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local Burst=require('resonance_burst')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function alpha(c)return math.floor(c/16777216)end
local function rgb(c)return c%16777216 end
local fusion={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=112,step=2,level=2,
    properties={'Fusion'},elements=R.elements('Fusion')}
-- One persistent model per run (the converge hold lives on the glyph).
local function run(bursts,o)
    local m=R.new();m.states[71]=copy(fusion);m.bursts[71]={}
    for i,at in ipairs(bursts or {})do m.bursts[71][i]={at=at,color=R.element_color('Fire')}end
    return function(t)
        local f=m:frame(71,t,2,4,o)
        if type(f)~='table'or not f.discs then f={discs={}}end
        local p={blooms={}}
        for _,v in ipairs(f)do if v.part=='mb'and v.role=='core'then p.ring=v end end
        for _,d in ipairs(f.discs)do
            if d.role=='mb-glyph'then p.glyph=d
            elseif d.role=='bloom'then p.blooms[#p.blooms+1]=d
            elseif d.role=='property'and alpha(d.color)>0 then p.disc=d end
        end
        return p
    end
end
local o=copy(R.defaults);o.mb_ending_style='converge'
local peak=math.floor(255*o.mb_overall+.5)
local rest=o.disc_height
local times={}
for t=110,111.999,.01 do times[#times+1]=t end
times[#times+1]=111.999

-- Shared progress: 0 at the start of the ending, 1 at the deadline.
local opt=function(k)return o[k]end
assert(Burst.ending_progress(fusion,110,opt)==0 and Burst.ending_progress(fusion,109,opt)==0,'progress 0 before/at start')
assert(math.abs(Burst.ending_progress(fusion,111,opt)-.5)<1e-9 and Burst.ending_progress(fusion,112,opt)==1,'progress .5 / 1')
assert(Burst.ending(.999,'converge')>.99 and Burst.ending(0,'converge')==0,'converge ramp')

-- 1. No burst: the ring descends steadily and brightens to white, never
-- fading; the ground glyph emerges from transparent to the same peak.
do
    local f=run(nil,o)
    local before=f(109.99)
    assert(math.abs(before.ring.offset-f(110).ring.offset)<1e-6,'ring: no step when the ending begins')
    assert(before.glyph==nil or alpha(before.glyph.outline)==0,'glyph transparent before the ending (rest hidden)')
    local last_h,last_g=math.huge,-1
    for _,t in ipairs(times)do
        local p=f(t)
        assert(p.ring,'ring visible through the ending '..t)
        assert(alpha(p.ring.color)>=40,'ring keeps its visibility '..t)
        assert(p.ring.offset<=last_h+1e-9,'ring only descends '..t)
        last_h=p.ring.offset
        local g=p.glyph and alpha(p.glyph.outline)or 0
        assert(g>=last_g-1,'glyph opacity never drops (no flashing) '..t)
        last_g=g
        if t>=111 then assert(alpha(p.ring.color)>=150,'ring bright late in the descent '..t)end
    end
    local p=f(111.999)
    assert(math.abs(p.ring.offset-rest)<.002,'ring arrives at the ground glyph plane')
    assert(math.abs(p.glyph.offset-rest)<1e-6,'ground glyph stays on the floor')
    assert(math.abs(alpha(p.ring.color)-peak)<=3 and rgb(p.ring.color)==0xFFFFFF,'ring brightest and white on arrival')
    assert(math.abs(alpha(p.glyph.outline)-peak)<=2,'glyph at peak opacity on arrival')
    -- Final expiration: all of it at the real deadline.
    for _,t in ipairs({112,112.05,113})do
        local q=f(t)
        assert(not q.ring and (not q.glyph or alpha(q.glyph.outline)==0)and #q.blooms==0 and not q.disc,'all out at the deadline '..t)
    end
end

-- 2. Synchronized with the ending duration: mb ending 1 starts at 111.
do
    local o1=copy(o);o1.mb_ending=1
    local f=run(nil,o1)
    local mb_h=f(110.5).ring.offset
    assert(math.abs(f(110.99).ring.offset-mb_h)<1e-6,'mb ending 1: nothing before 111')
    assert(f(111.5).ring.offset<mb_h-.01 and math.abs(f(111.999).ring.offset-rest)<.002,'mb ending 1: full descent in 1 s')
end

-- 3. A glyph already risen when the ending begins: no jump, then it is capped
-- at the ring and arrives with it (held at full strength, no fade).
do
    local f=run({109.5},o)
    local prev=f(109.99).glyph.offset
    local glyph_peak=alpha(f(109.99).glyph.outline)
    for _,t in ipairs(times)do
        local p=f(t)
        assert(math.abs(p.glyph.offset-prev)<.006,'glyph moves continuously '..t)
        prev=p.glyph.offset
        assert(p.glyph.offset<=p.ring.offset+.0145,'glyph never above its normal overshoot '..t)
        if t>=110.5 then assert(math.abs(p.glyph.offset-p.ring.offset)<1e-6,'glyph at the ring height '..t)end
        assert(alpha(p.glyph.outline)>=glyph_peak-1,'held glyph keeps its brightness '..t)
    end
    assert(math.abs(f(111.999).glyph.offset-rest)<.002,'held glyph arrives at the floor')
    -- Its bloom (born before the ending) keeps the steady MB ring plane.
    local h0=f(109.99).blooms[1].offset
    for t=110,110.45,.05 do local b=f(t).blooms[1];if b then assert(math.abs(b.offset-h0)<1e-6,'old bloom: no jump '..t)end end
end

-- 4. A burst during the ending: the rise stops at the ring and stays there;
-- its bloom starts at the ring's height at the burst and fades in place.
do
    local f=run({110.8},o)
    local reached=false
    local born=f(110.81).ring.offset
    local first
    for t=110.8,111.999,.01 do
        local p=f(t)
        assert(p.glyph.offset<=p.ring.offset+1e-6,'rise capped at the ring '..t)
        if math.abs(p.glyph.offset-p.ring.offset)<1e-6 then reached=true
        else assert(not reached,'held once reached (no fall back) '..t)end
        if p.blooms[1]then
            first=first or p.blooms[1].offset
            assert(math.abs(p.blooms[1].offset-first)<1e-6,'bloom stays at its height '..t)
        end
    end
    assert(reached,'glyph reached the ring')
    assert(first and math.abs(first-born)<.002,'bloom born at the ring height ('..tostring(first)..' vs '..born..')')
    assert(alpha(f(111.999).glyph.outline)>=peak-2,'held glyph at peak on arrival')
end

-- 5. mb glyph opacity does not dim the converge glyph.
do
    local o0=copy(o);o0.mb_glyph_opacity=0
    local a,b=run(nil,o)(111.9),run(nil,o0)(111.9)
    assert(a.glyph.outline==b.glyph.outline,'mb glyph opacity 0: converge glyph unchanged')
    local h=run({110.5},o0)(111.9)
    assert(math.abs(alpha(h.glyph.outline)-alpha(a.glyph.outline))<=2,'mb glyph opacity 0: still emerges to peak')
end

-- 6. Optional shrink (default 0 = sizes unchanged).
do
    local base=run(nil,copy(R.defaults))(109.99)
    local plain=run(nil,o)(111.9)
    assert(math.abs(plain.ring.radius-base.ring.radius)<1e-9,'shrink 0: ring size unchanged')
    local s1=copy(o);s1.mb_ending_shrink=1
    local p=run(nil,s1)
    assert(math.abs(p(110).ring.radius-base.ring.radius)<1e-9,'shrink: no step at the start')
    local target=2*.78*o.disc_size_lines
    assert(math.abs(p(111.999).ring.radius-target)<.01 and math.abs(p(111.999).glyph.radius-target)<.01,'shrink 1: property glyph size on arrival')
end

-- 7. Other styles are unaffected by the converge-only code paths.
do
    local soft=copy(R.defaults)
    local f=run({110.8},soft)
    local p=f(111.5)
    local exp=f(109).ring.offset+(rest-f(109).ring.offset)*(function(x)return x*x*(3-2*x)end)(.75)
    assert(math.abs(p.ring.offset-exp)<1e-6,'soft: ring descent unchanged')
    assert(math.abs(p.blooms[1].offset-f(109).ring.offset)<1e-6,'soft: bloom keeps the steady MB height')
end

-- 8. Commands.
local settings=copy(R.defaults)
local said
local cmd=C.new(settings,R.defaults,function()end,function(m)said=m end,R.killala)
assert(cmd('mb',{'ending','style','converge'})and settings.mb_ending_style=='converge','style converge')
assert(said=='MB ending style converge.',tostring(said))
assert(cmd('mb',{'ending','style','bogus'})and settings.mb_ending_style=='converge'and said:find('converge'),'usage lists converge')
assert(cmd('mb',{'ending','shrink','0.5'})and settings.mb_ending_shrink==.5,'shrink .5')
assert(cmd('mb',{'ending','shrink','2'})and settings.mb_ending_shrink==.5,'shrink out of range rejected')
assert(cmd('preset',{'default'})and settings.mb_ending_shrink==0 and settings.mb_ending_style=='soft','default restores')
print('PASS Test6.5 converge: shared progress; ring descends + brightens to white without fading; glyph emerges to peak; deadline ends all; duration respected; cap/hold at the ring without jumps; blooms at the ring height at their burst; mb glyph opacity ignored; optional shrink; soft unchanged; commands')
