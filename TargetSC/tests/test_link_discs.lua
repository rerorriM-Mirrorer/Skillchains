-- Test4.4: link property discs: fill fade/size, sigil line size, Light/Darkness
-- 'elements' look (white/black hub to four element colors). Defaults change
-- nothing; opener controls stay separate.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local function rgb(c)return c%16777216 end
local function link(prop,level)return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=level,
 properties={prop},elements=R.elements(prop)}end
local opener={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,properties={'Fusion'},elements=R.elements('Fusion')}
local function frame(s,t,o)local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
local function strip(f)local r={}for _,d in ipairs(f.discs)do local c={}for k,v in pairs(d)do c[k]=v end;r[#r+1]=c end return r end
local function same(a,b,m)
 assert(#a==#b,m..' count')
 for i=1,#a do for k,v in pairs(a[i])do
  if type(v)=='table'then for x,y in ipairs(v)do assert(b[i][k][x]==y,m..' '..k)end
  else assert(b[i][k]==v,m..' '..k..' '..tostring(v)..' vs '..tostring(b[i][k]))end end end
end
local function fills(f)local r={}for _,d in ipairs(f.discs)do if d.role=='property'and d.glyph==0 then r[#r+1]=d end end return r end
local function lines(f)local r={}for _,d in ipairs(f.discs)do if d.role=='property-trace'or (d.role=='property'and d.glyph~=0)then r[#r+1]=d end end return r end
for _,style in ipairs({'clapper','classic'})do
 local o=copy(R.defaults);o.mb_style=style
 -- Defaults (1/1/1/1, classic) are byte-identical to an explicit copy.
 local x=copy(o);x.disc_inner,x.disc_outer,x.disc_size,x.disc_size_lines=1,1,1,1
 same(strip(frame(link('Fusion',2),104,o)),strip(frame(link('Fusion',2),104,x)),style..' defaults')
 -- Fill size/fade and line size, independently.
 local base=frame(link('Fusion',2),104,o)
 local base_line=lines(base)[1].radius
 local c=copy(o);c.disc_size=1.3;c.disc_inner=.2;c.disc_outer=.9
 local f=frame(link('Fusion',2),104,c)
 local fill=fills(f)[1]
 near(fill.radius,2*.78*1.3,1e-9,style..' fill size');near(fill.inner,.2);near(fill.outer,.9)
 near(lines(f)[1].radius,base_line,1e-9,style..' lines keep size')
 local l=copy(o);l.disc_size_lines=.7
 near(lines(frame(link('Fusion',2),104,l))[1].radius,base_line*.7,1e-9,style..' lines size')
 -- Level 4 terminal discs follow too.
 local t=frame(link('Radiance',4),104,c)
 near(fills(t)[1].radius,2*.92*1.3,1e-9,style..' terminal fill size')
 -- Opener ignores link settings; link ignores opener settings.
 same(strip(frame(opener,104,o)),strip(frame(opener,104,c)),style..' opener untouched by link settings')
 local op=copy(o);op.opener_disc_size=1.5;op.opener_disc_inner=.3;op.opener_disc_outer=1
 same(strip(frame(link('Fusion',2),104,o)),strip(frame(link('Fusion',2),104,op)),style..' link untouched by opener settings')
 -- Light/Darkness elements look.
 local e=copy(o);e.disc_lightdark='elements'
 for prop,hub in pairs({Light=0xFFFFFF,Darkness=0})do
  local d=fills(frame(link(prop,3),104,e))[1]
  assert(d and #d.colors==4 and rgb(d.hub)==hub,style..' '..prop..' hub')
  for i,el in ipairs(R.elements(prop))do assert(rgb(d.colors[i])==rgb(R.argb(R.element_color(el),1)),style..' '..prop..' rim '..el)end
  assert(d.blend==1,style..' rim blends')
 end
 -- Only Light/Darkness; classic leaves them as before; Radiance terminal untouched.
 for _,d in ipairs(frame(link('Fusion',2),104,e).discs)do assert(d.hub==nil)end
 for _,d in ipairs(frame(link('Light',3),104,o).discs)do assert(d.hub==nil,'classic: no hub')end
 for _,d in ipairs(frame(link('Radiance',4),104,e).discs)do assert(d.hub==nil,'terminal keeps its look')end
 -- Opener with a Light property also gets it.
 local lo={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,properties={'Light'},elements=R.elements('Light')}
 local found=false;for _,d in ipairs(frame(lo,104,e).discs)do if d.hub then found=true end end
 assert(found,style..' opener Light hub')
end
local settings=copy(R.defaults)
local cmd=C.new(settings,R.defaults,function()end,function()end,R.killala)
assert(cmd('discs',{'fade','0.4','1'})and settings.disc_inner==.4 and settings.disc_outer==1)
assert(cmd('discs',{'fade','0.4'})and settings.disc_outer==1,'both numbers required')
assert(cmd('discs',{'size','1.4'})and settings.disc_size==1.4)
assert(cmd('discs',{'size','lines','0.8'})and settings.disc_size_lines==.8)
assert(cmd('discs',{'size','3'})and settings.disc_size==1.4)
assert(cmd('discs',{'lightdark','elements'})and settings.disc_lightdark=='elements')
assert(cmd('discs',{'lightdark','rainbow'})and settings.disc_lightdark=='elements')
assert(cmd('discs',{'opacity','0.5'})and settings.disc_opacity==.5,'discs opacity still works')
assert(cmd('discs',{'speed','level2','3'})and settings.disc_speed_level2==3,'discs speed still works')
assert(cmd('preset',{'killala'})and settings.disc_size==1 and settings.disc_lightdark=='classic')
print('PASS Test4.4 link discs: fade/size/lines in both MB styles, terminal, opener separate, Light/Darkness elements, commands')
