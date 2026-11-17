-- Test4.2: opener discs outline: opener-only glyph line opacity; default
-- follows discs outline exactly; links unaffected.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function alpha(c)return math.floor(c/16777216)end
local opener={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,properties={'Fusion','Liquefaction'},elements=R.elements('Fusion')}
local link={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=2,properties={'Fusion'},elements=R.elements('Fusion')}
local function frame(s,t,o)local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local function lines(f)local r={}for _,d in ipairs(f.discs)do
 if d.role=='property-trace'or (d.role=='property'and d.glyph~=0)then r[#r+1]=alpha(d.outline)end end return r end
for _,style in ipairs({'clapper','classic'})do
 local o=copy(R.defaults);o.mb_style=style
 local base,same=lines(frame(opener,104,o)),nil
 local x=copy(o);x.opener_disc_outline=-1
 same=lines(frame(opener,104,x))
 assert(#base>0 and #base==#same)
 for i=1,#base do assert(base[i]==same[i],style..' default follows discs outline')end
 local hi=copy(o);hi.opener_disc_outline=1
 local lo=copy(o);lo.opener_disc_outline=.1
 local h,l=lines(frame(opener,104,hi)),lines(frame(opener,104,lo))
 for i=1,#h do assert(h[i]>base[i] and l[i]<base[i],style..' opener lines respond')end
 -- Links ignore it.
 local lb,lh=lines(frame(link,104,o)),lines(frame(link,104,hi))
 assert(#lb==#lh)
 for i=1,#lb do assert(lb[i]==lh[i],style..' link untouched')end
end
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('opener',{'discs','outline','0.9'})and settings.opener_disc_outline==.9)
assert(cmd('opener',{'discs','outline','2'})and settings.opener_disc_outline==.9)
assert(cmd('opener',{'discs','outline','same'})and settings.opener_disc_outline==-1)
assert(cmd('opener',{'discs','size','1.1'})and settings.opener_disc_size==1.1,'size still works')
assert(cmd('preset',{'killala'})and settings.opener_disc_outline==-1)
print('PASS Test4.2 opener discs outline: follows by default, opener-only in both MB styles, same resets')
