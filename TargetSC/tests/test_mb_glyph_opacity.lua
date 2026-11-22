-- Test6.4: //tsc mb glyph opacity <0-1> scales only the confirmed-MB
-- response glyph (its strike, rise and fade/fall). It leaves alone the MB
-- ring, property discs, traces, glows, blooms, the window-opening intro flash,
-- the closing (ending) flash, idle breathing and Radiance's own glyph opacity.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function alpha(c)return math.floor(c/16777216)end
local fusion={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=112,step=2,level=2,
    properties={'Fusion'},elements=R.elements('Fusion')}
local radiance={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=112,step=2,level=4,
    properties={'Radiance'},elements=R.elements('Radiance')}
local function model(state,bursts)
    local m=R.new();m.states[71]=copy(state)
    if bursts then m.bursts[71]={}for i,at in ipairs(bursts)do m.bursts[71][i]={at=at,color=R.element_color('Fire')}end end
    return m
end
local function frame(state,bursts,t,o)return model(state,bursts):frame(71,t,2,4,o)end
local function glyph(f)for _,d in ipairs(f.discs)do if d.role=='mb-glyph'then return d end end end
local function with(o,k)local r=copy(o);r.mb_glyph_opacity=k;return r end
-- Everything except the mb-glyph disc, serialized for an exact comparison.
local function others(f)
    local parts={}
    local function put(prefix,t)
        local keys={}for k in pairs(t)do keys[#keys+1]=k end table.sort(keys,function(a,b)return tostring(a)<tostring(b)end)
        local r={}
        for _,k in ipairs(keys)do
            local v=t[k]
            if type(v)=='table'then local x={}for i,y in ipairs(v)do x[i]=tostring(y)end v='{'..table.concat(x,',')..'}'end
            r[#r+1]=tostring(k)..'='..tostring(v)
        end
        parts[#parts+1]=prefix..table.concat(r,';')
    end
    for i,v in ipairs(f)do put('ring'..i..':',v)end
    local j=0
    for _,d in ipairs(f.discs)do if d.role~='mb-glyph'then j=j+1;put('disc'..j..':',d)end end
    for i,g in ipairs(f.glyphs3 or {})do put('g3'..i..':',g)end
    return table.concat(parts,'\n')
end
local o=copy(R.defaults);o.mb_glyph_rise=0
assert(R.defaults.mb_glyph_opacity==1,'default 1')
local times={104,104.05,104.3,104.6,105.1,105.6,106.1,106.5,106.9}
-- 1 (and the default) preserve the current appearance exactly.
for _,t in ipairs(times)do
    local a,b=frame(fusion,{104},t,o),frame(fusion,{104},t,with(o,1))
    assert(others(a)==others(b),'default = 1 (others) '..t)
    local ga,gb=glyph(a),glyph(b)
    assert((ga==nil)==(gb==nil),'default = 1 (glyph presence) '..t)
    if ga then assert(ga.outline==gb.outline and ga.offset==gb.offset and ga.radius==gb.radius,'default = 1 (glyph) '..t)end
end
-- 0.5 halves the glyph through strike and fade; 0 hides it; nothing else changes.
local seen=0
for _,t in ipairs(times)do
    local full,half,none=frame(fusion,{104},t,o),frame(fusion,{104},t,with(o,.5)),frame(fusion,{104},t,with(o,0))
    assert(others(full)==others(half)and others(full)==others(none),'other primitives unchanged '..t)
    local g=glyph(full)
    if g and alpha(g.outline)>4 then
        seen=seen+1
        local h=glyph(half)
        assert(h,'half still visible '..t)
        assert(math.abs(alpha(h.outline)-alpha(g.outline)/2)<=1,'half opacity at '..t..': '..alpha(h.outline)..' vs '..alpha(g.outline))
        assert(h.offset==g.offset and h.radius==g.radius and h.rotation==g.rotation,'timing/motion unchanged '..t)
        assert(glyph(none)==nil,'0 hides the response glyph '..t)
    end
end
assert(seen>=5,'response observed through its fade ('..seen..')')
-- Fall option (killala-style): the same scaling through the landing.
local fall=copy(o);fall.mb_glyph_after='fall'
local g1,g5=glyph(frame(fusion,{104},105.1,fall)),glyph(frame(fusion,{104},105.1,with(fall,.5)))
assert(math.abs(alpha(g5.outline)-alpha(g1.outline)/2)<=1 and g5.offset==g1.offset,'fall scaled, landing unchanged')
-- Classic style: the release glyph is scaled as well.
local classic=copy(o);classic.mb_style='classic'
local c1,c5=glyph(frame(fusion,{104},104.3,classic)),glyph(frame(fusion,{104},104.3,with(classic,.5)))
assert(c1 and math.abs(alpha(c5.outline)-alpha(c1.outline)/2)<=1,'classic release scaled')
-- No burst: nothing changes at all (rest, intro and ending).
for _,t in ipairs({100.1,101,102.5,104,110.2,110.8,111.5})do
    local e=copy(o);e.mb_ending_style='soft'
    local a,b=frame(fusion,nil,t,e),frame(fusion,nil,t,with(e,0))
    assert(others(a)==others(b),'no burst: others '..t)
    local ga,gb=glyph(a),glyph(b)
    assert((ga==nil)==(gb==nil)and (not ga or ga.outline==gb.outline),'no burst: glyph unchanged '..t)
end
-- A burst during the window-opening intro: the intro flash is not dimmed.
local intro_only=glyph(frame(fusion,nil,100.1,o))
local intro_hit=glyph(frame(fusion,{100.05},100.1,with(o,0)))
assert(intro_only and intro_hit and alpha(intro_hit.outline)==alpha(intro_only.outline),'intro flash kept at 0')
-- A burst during the closing pulses: the ending flash is not dimmed.
local e=copy(o);e.mb_ending_style='soft'
local checked=0
for t=110.1,111.9,.1 do
    local a,b=glyph(frame(fusion,{110},t,e)),glyph(frame(fusion,{110},t,with(e,0)))
    assert((a==nil)==(b==nil),'ending presence kept '..t)
    if a then assert(a.outline==b.outline,'ending flash kept at 0 '..t);checked=checked+1 end
end
assert(checked>0,'ending flash observed')
-- Radiance: its own glyph opacity still applies; the breath at rest is
-- unchanged; the response is scaled on top of it.
local ro=copy(o);ro.radiance_glyph_opacity=.9
local rest_a,rest_b=glyph(frame(radiance,nil,104.5,ro)),glyph(frame(radiance,nil,104.5,with(ro,0)))
assert(rest_a and rest_a.outline==rest_b.outline,'Radiance breath unchanged')
local own=glyph(frame(radiance,{104},104.3,ro))
local shared=copy(ro);shared.radiance_glyph_opacity=-1
local via_overall=glyph(frame(radiance,{104},104.3,shared))
assert(alpha(own.outline)~=alpha(via_overall.outline),'Radiance own opacity still replaces mb overall')
local rhalf=glyph(frame(radiance,{104},104.3,with(ro,.5)))
assert(math.abs(alpha(rhalf.outline)-alpha(own.outline)/2)<=1,'Radiance response scaled once')
-- Command: //tsc mb glyph opacity <0-1>, existing numeric() validation.
local settings=copy(R.defaults)
local said
local cmd=C.new(settings,R.defaults,function()end,function(m)said=m end,R.killala)
assert(cmd('mb',{'glyph','opacity','0.5'})and settings.mb_glyph_opacity==.5,'set .5')
assert(said=='mb glyph opacity = 0.500',tostring(said))
assert(cmd('mb',{'glyph','opacity','0'})and settings.mb_glyph_opacity==0,'set 0')
assert(cmd('mb',{'glyph','opacity','1.5'})and settings.mb_glyph_opacity==0,'out of range rejected')
assert(said=='Use //tsc mb glyph opacity <0-1>. Now 0.000.',tostring(said)) -- Test7.10 reports the current value
assert(cmd('mb',{'glyph','opacity','x'})and settings.mb_glyph_opacity==0,'non-number rejected')
assert(cmd('mb',{'glyph','height','1'})and settings.mb_glyph_height==1,'other mb glyph settings still work')
assert(cmd('mb',{'glyph','bogus'})and said:find('opacity <0%-1>'),'usage lists opacity')
assert(cmd('preset',{'killala'})and settings.mb_glyph_opacity==1,'killala restores 1')
settings.mb_glyph_opacity=.3
assert(cmd('preset',{'default'})and settings.mb_glyph_opacity==1,'default restores 1')
print('PASS Test6.4 mb glyph opacity: response glyph only (strike, fade, fall, classic), 1 unchanged, .5 half, 0 hidden; ring/discs/glows/intro/ending/breath untouched; Radiance own opacity kept; command validation')
