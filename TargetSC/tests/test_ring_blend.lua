-- Test3 follow-up: gradient SC rings (ground, sky, glows); openers stay split;
-- level-2 strands keep their opposite color order.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function rings(f,part,role)local r={}for _,v in ipairs(f)do if v.part==part and v.role==role then r[#r+1]=v end end return r end
local o=copy(R.defaults);o.mb_intro=0;o.ring_shade=0 -- structure only; shading has its own test
local function frame(state,t,opts)local m=R.new();m.states[71]=state;return m:frame(71,t,2,4,opts or o)end
local l2={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,
 step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}
local f=frame(l2,104)
for _,part in ipairs({'ground','sky'})do
 local core=rings(f,part,'core')
 assert(#core==2,'two level-2 strands at '..part)
 for _,r in ipairs(core)do assert(#r.colors==2 and r.blend==1,part..' strand blends')end
 -- Strand 1 runs A->B, strand 2 runs B->A: gradient keeps that orientation.
 assert(core[1].colors[1]==core[2].colors[2] and core[1].colors[2]==core[2].colors[1],part..' strands opposite')
 for _,g in ipairs(rings(f,part,'glow'))do if #g.colors>1 then assert(g.blend==1,part..' glow blends')end end
end
-- Sky and ground strand j share orientation (same palette order).
local ground,sky=rings(f,'ground','core'),rings(f,'sky','core')
assert(ground[1].colors[1]%16777216==sky[1].colors[1]%16777216,'ground/sky strand 1 same order')
-- Openers stay split, even with the gap removed.
local opener={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,
 step=1,level=1,properties={'Fusion','Liquefaction'},elements=R.elements('Fusion')}
for _,gap in ipairs({12,0})do
 local og=copy(o);og.opener_gap=gap
 for _,r in ipairs(frame(opener,104,og))do
  if r.part=='ground'or r.part=='sky'then assert(r.blend==0,'opener ring split at gap '..gap)end
 end
end
-- Single-color rings never blend; split setting restores sectors.
for _,r in ipairs(f)do if #r.colors==1 then assert(r.blend==0)end end
local split=copy(o);split.ring_blend='split'
for _,r in ipairs(frame(l2,104,split))do assert(r.blend==0,'split restores sectors')end
-- Firm: four stops A,A,B,B (colors hold, fade concentrated where they meet).
local firm=copy(o);firm.ring_blend='firm';firm.disc_blend='firm'
local ff=frame(l2,104,firm)
for _,part in ipairs({'ground','sky'})do
 local core=rings(ff,part,'core')
 for j,r in ipairs(core)do
  assert(#r.colors==4 and r.blend==1,part..' firm four stops')
  assert(r.colors[1]%16777216==r.colors[2]%16777216 and r.colors[3]%16777216==r.colors[4]%16777216,'A,A,B,B')
 end
 assert(core[1].colors[1]%16777216==core[2].colors[3]%16777216,part..' firm strands still opposite')
end
local fdisc;for _,d in ipairs(ff.discs)do if d.role=='property'then fdisc=d end end
assert(#fdisc.colors==4 and fdisc.blend==1 and fdisc.colors[1]==fdisc.colors[2]and fdisc.colors[3]==fdisc.colors[4],'firm disc A,A,B,B')
local shaded=copy(firm);shaded.ring_shade=.25
local sr=rings(frame(l2,104,shaded),'ground','core')[1]
assert(math.floor(sr.colors[1]/16777216)>math.floor(sr.colors[3]/16777216),'firm keeps the lit side')
for _,r in ipairs(frame(opener,104,firm))do if r.part=='ground'or r.part=='sky'then assert(r.blend==0)end end
-- Commands and presets.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('rings',{'blend','split'})and settings.ring_blend=='split')
assert(cmd('rings',{'blend','firm'})and settings.ring_blend=='firm')
assert(cmd('rings',{'blend','split'})and settings.ring_blend=='split')
assert(cmd('discs',{'blend','firm'})and settings.disc_blend=='firm')
assert(cmd('rings',{'blend','swirl'})and settings.ring_blend=='split')
assert(cmd('rings',{})and settings.ring_blend=='split')
assert(cmd('preset',{'default'})and settings.ring_blend=='gradient')
assert(cmd('preset',{'killala'})and settings.ring_blend=='split')
print('PASS gradient SC rings: level-2 strands blend with opposite orientation, glows match, openers split, split/killala restore')
