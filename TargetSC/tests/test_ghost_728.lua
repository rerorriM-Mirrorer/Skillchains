-- Test7.28: the frame's ghost ceiling is the MB ring's height (Radiance/Umbra:
-- + ghost_level4_lift); ground pieces sit below it, the MB ring does not
-- count, and the ghost command. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b,e,m)assert(math.abs(a-b)<=(e or 1e-9),(m or '')..' '..tostring(a)..' ~= '..tostring(b))end
local d=R.defaults
local function mbcore(f)for _,v in ipairs(f)do if v.part=='mb'and v.role=='core'then return v end end end
local function link(prop,level)return {id=71,revision=2,created=100,sc_open=103,sc_close=108,mb_close=110,step=2,level=level,
    properties={prop},elements=R.elements(prop)}end
local function frame(s,t,o)R.native_level=16;local m=R.new();m.states[71]=copy(s);return m:frame(71,t,2,4,o)end
for _,style in ipairs({'clapper','classic'})do
    local o=copy(d);o.mb_style=style
    for _,t in ipairs({104,108.5,109.5})do
        local f=frame(link('Scission',1),t,o)
        local ring=mbcore(f)
        assert(ring and f.ghost_ceiling,style..' ceiling with an MB ring')
        near(f.ghost_ceiling,ring.offset,1e-9,style..' ceiling = MB ring height at '..t)
        for _,x in ipairs(f.discs)do
            if x.role=='property'or x.role=='lit'or x.role=='property-trace'or x.role=='awakening-end'then
                assert(x.offset<f.ghost_ceiling or t>109,style..' '..x.role..' below the MB ring')
            end
        end
    end
end
-- Radiance/Umbra: lifted by .003 (and by the setting).
for _,p in ipairs({'Radiance','Umbra'})do
    local o=copy(d);o.mb_style='clapper'
    local f,ring,at
    for t=100,112,.25 do f=frame(link(p,4),t,o);ring=mbcore(f);if ring then at=t break end end
    assert(ring,p..' MB ring')
    near(f.ghost_ceiling,ring.offset+.003,1e-9,p..' +.003')
    local l=copy(o);l.ghost_level4_lift=.01
    near(frame(link(p,4),at,l).ghost_ceiling,ring.offset+.01,1e-9,p..' lift setting')
end
-- Opener (no MB ring): no ceiling, nothing ghosts.
local op={id=71,revision=1,created=100,sc_open=103,sc_close=110,mb_close=0,step=1,level=1,properties={'Scission'},elements=R.elements('Scission')}
assert(not frame(op,101,copy(d)).ghost_ceiling,'opener: no ceiling')
-- Commands.
local s=copy(d);local said={}
local cmd=C.new(s,d,function()end,function(m)said[#said+1]=m end)
assert(cmd('ghost',{'.5'})and s.ghost==.5);assert(cmd('ghost',{'off'})and s.ghost==0)
assert(cmd('ghost',{'lift','.01'})and s.ghost_level4_lift==.01);assert(cmd('ghost',{'2'})and s.ghost==0,'range')
for _,m in ipairs(said)do assert(not m:find('[\128-\255]'),'ASCII chat')end
print('PASS Test7.28 ghost ceiling = MB ring height (+.003 Radiance/Umbra), ground pieces below it, opener none, commands')
