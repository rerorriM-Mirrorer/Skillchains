-- Test7.13: Earth color choices (`earth_color`, `//tsc earth`) and the
-- Requiescat / Earth MB previews. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end

-- Defaults keep the earlier look.
assert(R.defaults.earth_color=='classic','default earth_color')
local earth=R.element_color('Earth')
assert(earth[1]==176 and earth[2]==114 and earth[3]==48,'classic Earth unchanged')

-- Choices change the shared table in place (held references follow).
local held=R.element_color('Earth')
local want={classic={176,114,48},gold={230,190,70},scission={255,165,0},crystal={216,146,64}}
for name,rgb in pairs(want)do
    R.apply_colors({earth_color=name})
    assert(held[1]==rgb[1]and held[2]==rgb[2]and held[3]==rgb[3],'earth '..name)
end
R.apply_colors({earth_color='10,20,30'})
assert(held[1]==10 and held[2]==20 and held[3]==30,'custom rgb')
R.apply_colors({earth_color='nonsense'})
assert(held[1]==176 and held[2]==114,'bad value falls back to classic')
R.apply_colors({})
assert(held[1]==176,'missing setting = classic')
-- Other elements untouched.
local wind=R.element_color('Wind');assert(wind[1]==115 and wind[2]==245 and wind[3]==145,'Wind unchanged')

-- Command: names, r g b, bad input keeps the value.
local settings=copy(R.defaults);local said
local cmd=C.new(settings,R.defaults,function()end,function(m)said=m end,R.killala,R.cioara)
assert(cmd('earth',{'gold'})and settings.earth_color=='gold','earth gold')
assert(cmd('earth',{'Crystal'})and settings.earth_color=='crystal','case-insensitive')
assert(cmd('earth',{'230','190','70'})and settings.earth_color=='230,190,70','earth r g b')
assert(cmd('earth',{'300','0','0'})and settings.earth_color=='230,190,70'and said:find('Now 230,190,70'),'bad rgb rejected')
assert(cmd('earth',{})and said:find('^Use //tsc earth'),'bare shows usage')
assert(not said:find('[\128-\255]'),'ASCII chat')
assert(cmd('preset',{'killala'})and settings.earth_color=='classic','presets reset Earth to classic')
assert(cmd('preset',{'cioara'})and settings.earth_color=='scission','Test7.18: cioara preset carries scission')

-- Requiescat chain: resolve each link with Skillchains' own chain table and
-- check_props/aeonic_prop (sliced from sc_runtime.lua, not a second resolver).
local src=io.open('./TargetSC/sc_runtime.lua'):read('*a')
local tbl=assert(src:match('\nsc_info = (%b{})'),'sc_info table')
local cp=assert(src:match('\n(function check_props%(old, new%).-\nend)\n'),'check_props')
local ap=assert(src:match('\n(function aeonic_prop%(ability, actor%).-\nend)\n'),'aeonic_prop')
local env={unpack=unpack,info={aeonic='Sequence',player=1},settings={aeonic=false}}
setfenv(assert(loadstring('sc_info='..tbl..'\n'..cp..'\n'..ap)),env)()
local Sk=dofile('./TargetSC/skills.lua').weapon_skills
local seq=P.requiescat_sequence
local rq=Sk[seq[1].weapon]
assert(rq.en=='Requiescat'and rq.skillchain[1]=='Gravitation'and rq.skillchain[2]=='Scission','Requiescat props')
assert(Sk[seq[5].weapon].en=='Requiescat'and Sk[seq[5].weapon].aeonic=='Darkness','Requiescat closes (Sequence)')
local old=P.requiescat_opener
for step=2,#seq do
    local row=seq[step]
    local props=env.aeonic_prop(Sk[row.weapon],1)
    local level,result,ultimate=env.check_props(old,props)
    assert(level==row.level and (ultimate or result)==row.property,'resolver disagrees at '..row.name..' '..tostring(result))
    old={row.property}
end

-- Previews: parse forms, old forms unchanged.
assert(P.parse({'demo','requiescat'},R).kind=='requiescatdemo'and P.parse({'requiescat'},R).kind=='requiescatdemo')
for _,a in ipairs({{'earth','mb'},{'mb','earth'},{'mb','requiescat'}})do assert(P.parse(a,R).kind=='earthmb',table.concat(a,' '))end
assert(P.parse({'earth'},R).kind=='chain'and P.parse({'earth'},R).properties[1]=='Scission','preview earth = Scission chain as before')
assert(P.parse({'demo'},R).kind=='umbra'and P.parse({'mb'},R).kind=='mbdemo'and P.parse({'mb','dark'},R).kind=='mbdark','old previews unchanged')

local o=copy(R.defaults)
local um=P.new(P.parse({'demo'},R),80,0,R,o)
local rd=P.new(P.parse({'demo','requiescat'},R),81,0,R,o)
local em=P.new(P.parse({'earth','mb'},R),82,0,R,o)
assert(math.abs(um.ends-rd.ends)<1e-9 and math.abs(rd.ends-em.ends)<1e-9,'same clocks as the Umbra demo')
local opener=rd.model.states[81]
assert(opener.properties[1]=='Gravitation'and opener.properties[2]=='Scission'and opener.properties[3]=='Darkness'and opener.level==3,'Sequence opener: three properties, level 3')
assert(table.concat(opener.elements,',')=='Earth,Dark,Ice,Water','live element order')
-- The live bridge builds the same level/elements from these properties (sc_runtime opener path).
local sc_src=io.open('./TargetSC/sc_runtime.lua'):read('*a')
assert(sc_src:find("aeonic_prop(chosen.ability,actor),chosen.ability.delay or 3,1)",1,true),'opener uses aeonic_prop')
local props,levels,windows={}, {}, {}
for t=0,em.ends,.05 do
    em:advance(t)
    local s=em.model.states[82]
    if s then props[s.step]=s.properties[1];levels[s.step]=s.level;windows[s.step]=windows[s.step]or s end
end
assert(props[2]=='Detonation'and props[3]=='Gravitation'and props[4]=='Darkness'and props[5]=='Umbra','links')
assert(levels[3]==2 and levels[4]==3 and levels[5]==4,'levels')
-- Ten Earth bursts, each inside a window where Earth really bursts
-- (window opened, not yet replaced by the next link or past its MB deadline).
local bursts=em.model.bursts[82]
assert(#bursts==10,'ten Earth bursts, got '..#bursts)
for _,b in ipairs(bursts)do
    assert(b.color==R.element_color('Earth'),'Earth color reference')
    local live
    for step=3,5 do
        local w=windows[step];local nxt=windows[step+1]
        if b.at>=w.sc_open and b.at<(nxt and nxt.created or w.mb_close)then live=w end
    end
    assert(live,'burst at '..b.at..' outside a Gravitation/Darkness/Umbra window')
    local els=R.elements(live.properties[1]);local ok
    for _,e in ipairs(els)do ok=ok or e=='Earth'end
    assert(ok,'Earth bursts on '..live.properties[1])
end
assert(not rd.model.bursts[81],'demo requiescat has no bursts')
assert(em.description:find('Earth MB demo')and not em.description:find('[\128-\255]'),'ASCII description')
-- Earth choice reaches a running preview's bursts (shared table).
R.apply_colors({earth_color='scission'})
assert(bursts[1].color[1]==255 and bursts[1].color[2]==165,'running preview follows the earth choice')
R.apply_colors({earth_color='classic'})
print('PASS Test7.13 Earth color choices, earth command, Requiescat chain vs Skillchains resolver, demo requiescat, earth mb')
