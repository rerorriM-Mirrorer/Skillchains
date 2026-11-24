-- Test3.6: opener-only property-disc fill fade (center/edge) and size;
-- glyph lines and every non-opener disc are unchanged.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function all(f,role)local r={}for _,d in ipairs(f.discs)do if d.role==role then r[#r+1]=d end end return r end
local opener={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,
 properties={'Fusion','Liquefaction'},elements=R.elements('Fusion')}
local link={id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=2,
 properties={'Fusion'},elements=R.elements('Fusion')}
local function frame(s,t,o)local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local function strip(f)
 local out={}for _,d in ipairs(f.discs)do
  local c={}for k,v in pairs(d)do c[k]=v end;out[#out+1]=c end return out
end
for _,style in ipairs({'clapper','classic'})do
 local base=copy(R.defaults);base.mb_style=style
 local custom=copy(base);custom.opener_disc_inner=.2;custom.opener_disc_outer=.9;custom.opener_disc_size=1.4
 -- Defaults leave every disc byte-for-byte as before.
 local plain,again=frame(opener,101.5,base),frame(opener,101.5,copy(base))
 for i,d in ipairs(all(plain,'property'))do assert(d.inner==nil and d.outer==nil,style..' default untouched')end
 local before,after=all(plain,'property'),all(frame(opener,101.5,custom),'property')
 local fills_before,fills_after={},{}
 for _,d in ipairs(before)do if d.glyph==0 then fills_before[#fills_before+1]=d end end
 for _,d in ipairs(after)do if d.glyph==0 then fills_after[#fills_after+1]=d end end
 assert(#fills_after==#opener.properties,style..' one fill per opener property')
 for i,d in ipairs(fills_after)do
  near(d.inner,.2);near(d.outer,.9)
  near(d.radius,2*(.78-(i-1)*.11)*1.4,1e-9,style..' fill size '..i)
 end
 -- Glyph lines stay at their usual size.
 local function lines(f)local r={}
  for _,d in ipairs(f.discs)do if (d.role=='property-trace'or (d.role=='property'and d.glyph~=0))then r[#r+1]=d end end return r end
 local lb,la=lines(plain),lines(frame(opener,101.5,custom))
 assert(#lb==#la and #lb>0,style..' same glyph line discs')
 for i=1,#lb do near(la[i].radius,lb[i].radius,1e-9,style..' glyph size unchanged');assert(la[i].inner==nil)end
 -- After the opener (a link), nothing changes.
 local lp,lc=all(frame(link,104,base),'property'),all(frame(link,104,custom),'property')
 assert(#lp==#lc)
 for i=1,#lp do near(lc[i].radius,lp[i].radius);assert(lc[i].inner==nil and lc[i].outer==nil,style..' link untouched')end
end
-- Commands.
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('opener',{'discs','fade','0.3','1'})and settings.opener_disc_inner==.3 and settings.opener_disc_outer==1)
assert(cmd('opener',{'discs','fade','0.3'})and settings.opener_disc_outer==1,'both numbers required')
assert(cmd('opener',{'discs','fade','2','0'})and settings.opener_disc_inner==.3,'range enforced')
assert(cmd('opener',{'discs','size','1.5'})and settings.opener_disc_size==1.5)
assert(cmd('opener',{'discs','size','5'})and settings.opener_disc_size==1.5)
assert(cmd('opener',{'gap','60'})and settings.opener_gap==60,'opener gap still works')
assert(cmd('preset',{'killala'})and settings.opener_disc_inner==1 and settings.opener_disc_size==1)
print('PASS Test3.6 opener discs: fill fade/size opener-only (clapper+classic), glyph lines and links unchanged, defaults untouched')
