-- Test7.9: the level-4 MB ring flickers like the skillchain bar's level 3/4
-- border instead of breathing (mb level4 flicker|breath, depth).
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function link(level,property,created)
    return {id=79,revision=level,created=created,sc_open=created+3,sc_close=created+8,mb_close=created+10,
        step=level==1 and 2 or level,level=level,properties={property},elements=R.elements(property)}
end
local function mb_alpha(now,o,level,p,prior)
    local m=R.new();local s=link(level,p,100);s.previous=link(level-1,prior,90);m.states[79]=s
    for _,x in ipairs(m:frame(79,now,2,4,o))do if x.part=='mb'and x.role=='core'then return math.floor(x.color/16777216)end end
end
local function electric(age)return (.37+.63*math.sin(age*23)^2)*(.72+.28*math.sin(age*28)^2)end
assert(R.defaults.mb_level4=='flicker'and R.defaults.mb_level4_depth==1)
local a=dofile('TargetSC/tests/fixture_cioara_1121.lua')
for k,v in pairs(R.defaults)do if a[k]==nil then a[k]=v end end
for _,o0 in ipairs({copy(R.defaults),a})do
    local o=copy(o0);o.mb_intro=0
    local br=copy(o);br.mb_level4='breath'
    -- Flicker: fast, deep swings within a fifth of a second.
    local lo,hi=1e9,-1e9
    for i=0,40 do local v=mb_alpha(101+i*.005,o,4,'Radiance','Light');lo,hi=math.min(lo,v),math.max(hi,v)end
    assert(lo<hi*.6,'Radiance MB ring flickers ('..lo..'..'..hi..')')
    -- Its shape follows the bar formula: the alpha ratio between two moments
    -- equals the electric ratio (other factors barely move in 5 ms).
    local t1,t2=101.0,101.005
    local r1,r2=mb_alpha(t1,o,4,'Radiance','Light'),mb_alpha(t2,o,4,'Radiance','Light')
    if r1>8 and r2>8 then near(r1/r2,electric(t1-100)/electric(t2-100),.15,'bar formula')end
    -- Breath keeps the earlier look; depth 0 = steady (no breath, no flicker).
    local d0=copy(o);d0.mb_level4_depth=0
    local s1,s2=mb_alpha(101,d0,4,'Radiance','Light'),mb_alpha(101.005,d0,4,'Radiance','Light')
    assert(math.abs(s1-s2)<=2,'depth 0 steady')
    local b1=mb_alpha(101,br,4,'Radiance','Light')
    assert(b1~=nil,'breath draws the ring')
    -- Levels 1-3 unchanged by the level 4 setting.
    for _,c in ipairs({{2,'Fusion','Liquefaction'},{3,'Light','Fusion'},{3,'Darkness','Gravitation'}})do
        for _,t in ipairs({100.5,101,102,104})do
            assert(mb_alpha(t,o,c[1],c[2],c[3])==mb_alpha(t,br,c[1],c[2],c[3]),c[2]..' unchanged '..t)
        end
    end
end
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('mb',{'level4','breath'})and settings.mb_level4=='breath')
assert(cmd('mb',{'level4','flicker'})and settings.mb_level4=='flicker')
assert(cmd('mb',{'level4','depth','.5'})and settings.mb_level4_depth==.5)
assert(cmd('mb',{'level4','depth','2'})and settings.mb_level4_depth==.5)
assert(cmd('preset',{'killala'})and settings.mb_level4=='breath')
assert(cmd('preset',{'default'})and settings.mb_level4=='flicker')
print('PASS Test7.9 level 4 MB ring flicker: bar formula, deep fast swings, depth 0 steady, breath kept, levels 1-3 unchanged, commands, presets')
-- Preview path (E4b).
local P=require('resonance_preview')
local opts=copy(R.defaults);opts.mb_intro=0
local preview=P.new(assert(P.parse({'demo','radiance'},R)),79,200,R,opts)
local at;for _,e in ipairs(preview.events)do if e.kind=='chain'and e.state.level==4 then at=e.at end end
preview:advance(at+1)
local lo,hi=1e9,-1e9
for i=0,40 do
    for _,x in ipairs(preview.model:frame(79,at+1+i*.005,2,4,opts))do
        if x.part=='mb'and x.role=='core'then local v=math.floor(x.color/16777216);lo,hi=math.min(lo,v),math.max(hi,v)end
    end
end
assert(lo<hi*.6,'demo radiance MB ring flickers')
print('PASS Test7.9 preview path: demo radiance MB ring flickers')
