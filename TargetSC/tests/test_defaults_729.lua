-- Test7.29: Cioara's 2026-11-23 look is the default; preset classic = Test7.28.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local M=require('resonance_motion')
local C=require('resonance_controls')
assert(R.defaults==M.defaults and R.base==M.base and R.cioara==M.cioara)
local n,changed=0,0
for k,v in pairs(M.base)do
    n=n+1
    if M.cioara[k]~=nil then assert(M.defaults[k]==M.cioara[k],'default follows cioara: '..k)
    else assert(M.defaults[k]==v,'default keeps base: '..k)end
    if M.defaults[k]~=v then changed=changed+1 end
end
for k in pairs(M.defaults)do assert(M.base[k]~=nil,'no new default key '..k)end
assert(changed>200,'expected most visuals to change, got '..changed)
-- spot checks from A's settings.xml (cioara section over global)
local d=M.defaults
assert(d.disc_blend=='firm'and d.ring_blend=='firm'and d.dark_look=='void'and d.lit_light=='mix')
assert(d.kill_time==3.1 and d.ghost==.09 and d.glyph_shimmer_width==60 and d.lit_shape=='half')
assert(d.awakening_until=='open'and d.umbra_ending=='vanish'and d.lit_sliced_props=='Darkness,Compression')
assert(M.cioara.frames=='full'and d.frames==nil)
-- presets: default and cioara give the same look; classic restores Test7.28
local said
local function run(preset)
    local s={enabled=true,debug=false}
    local cmd=C.new(s,R.defaults,function()end,function(m)said=m end,R.killala,R.cioara,R.base)
    cmd('preset',{preset})
    return s
end
local a,b,c=run('default'),run('cioara'),run('classic')
for k,v in pairs(M.base)do
    assert(a[k]==b[k],'default == cioara: '..k)
    assert(c[k]==v,'classic restores base: '..k)
end
assert(b.frames=='full'and a.enabled==true)
-- HUD ribbons off by default (data/skillchains-settings.xml)
local f=io.open('TargetSC/sc_runtime.lua','rb')local src=f:read('*a')f:close()
assert(src:find("mode='learn', display='off'",1,true),'HUD display default off')
assert(src:find("opts.display,opts.mode,opts.names,opts.scale='off'",1,true),'sc default resets display off')
local g=io.open('TargetSC/TargetSC.lua','rb')local tsc=g:read('*a')g:close()
assert(tsc:find("frames='full'}",1,true),'frames default full')
print(('PASS Test7.29 defaults: %d of %d visuals follow Cioara; presets default/cioara/classic.'):format(changed,n))
