-- Test7.20: SC kill = frozen ghost-white Light skillchain (kill sc look),
-- the property glyph split with the halves (native 0.13.0 disc clip), the
-- upright seam glyph styles and their size. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local M=require('resonance_motion')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function profile()local a=copy(require('tests.fixture_cioara_1122c'))for k,v in pairs(R.defaults)do if a[k]==nil then a[k]=v end end return a end
local function near(a,b,e)return math.abs(a-b)<=(e or 1e-6)end
local d=R.defaults
assert(d.kill_sc_look=='light'and d.kill_sc_glyph=='split'and d.kill_seam_style=='line'and d.kill_seam_size==1,'defaults')

-- `preview kill sc`: Scission opener; Fragmentation defeats the target at 2 s.
local function kill_frame(o,t,level)
    R.native_level=level or 13
    local p=P.new(assert(P.parse({'kill','sc'},R)),111,0,R,o)
    p:advance(t)
    return p.model:frame(111,t,2,4,o),p
end
local o=profile();R.apply_colors(o)
local ks=2+1e-6+o.kill_sc_freeze+.01 -- just after the kill (preview kill at 2 s + 1e-6)
local kstart=2+1e-6+o.kill_sc_freeze
local function ring_set(f)
    local r={}for _,v in ipairs(f)do r[#r+1]=('%.4f@%.4f'):format(v.radius,v.offset)end table.sort(r)return table.concat(r,' ')
end

-- Light look: at the freeze the halves sit exactly on a level-3 Light link's
-- rings at its window opening with the bell unfolded.
local f0,p0=kill_frame(o,ks)
local light=M.kill_light_state(p0.model.states[111],kstart,o)
assert(light.properties[1]=='Light'and light.level==3,'synthetic Light link')
assert(near(M.descent_remaining(light,kstart,o),1),'sky bell fully unfolded')
local plain=copy(o);plain.kill=false
local saved=p0.model.states[111];p0.model.states[111]=light
local ref=p0.model:frame(111,kstart,2,4,plain) -- the kill freezes the frame at its start
p0.model.states[111]=saved
local halves={}for _,v in ipairs(f0)do halves[('%.4f@%.4f'):format(v.radius,v.offset)]=true end
local covered=0 for _,v in ipairs(ref)do if halves[('%.4f@%.4f'):format(v.radius,v.offset)]then covered=covered+1 end end
assert(covered>=4,'kill halves follow the Light link rings ('..covered..')')
-- Ghost white everywhere.
for _,v in ipairs(f0)do assert(v.color%16777216==0xFFFFFF,'ghost white ring')end
-- Frozen: no ring changes radius as the kill plays (only the sideways split and sky sag move).
local f1=kill_frame(o,ks+.4)
local r0,r1={},{}
for _,v in ipairs(f0)do r0[#r0+1]=('%.4f'):format(v.radius)end
for _,v in ipairs(f1)do r1[#r1+1]=('%.4f'):format(v.radius)end
table.sort(r0);table.sort(r1)
assert(table.concat(r0,' ')==table.concat(r1,' '),'no movement but the split')
-- current: the chain's own (Fragmentation) frame, as before.
local cur=copy(o);cur.kill_sc_look='current'
assert(ring_set(kill_frame(cur,ks))~=ring_set(f0),'current keeps the old look')

-- Split glyph: two clipped property-trace copies, opposite halves, riding apart.
local fs=kill_frame(o,ks+.4)
local tr={}for _,x in ipairs(fs.discs)do if x.role=='property-trace'then tr[#tr+1]=x end end
assert(#tr==2 and tr[1].clip and tr[2].clip and near(math.abs(tr[1].clip-tr[2].clip),math.pi),'two clipped halves')
assert(tr[1].glyph==2 and tr[1].outline>=16777216,'glyph lines drawn')
assert(near(tr[1].dx,-tr[2].dx)and near(tr[1].dy,-tr[2].dy)and (math.abs(tr[1].dx)+math.abs(tr[1].dy))>0,'apart with the halves')
-- The clip keeps the half that moves: its normal points along its own shift.
for _,x in ipairs(tr)do assert(math.cos(x.clip)*x.dx+math.sin(x.clip)*x.dy>0,'kept half faces its shift')end
-- DLL 0.12.0 (no clip): the glyph flashes out as before.
local f12=kill_frame(o,ks+.4,12)
for _,x in ipairs(f12.discs)do assert(x.role~='property-trace'and not x.clip,'0.12: no split glyph')end
local fl=copy(o);fl.kill_sc_glyph='flash'
for _,x in ipairs(kill_frame(fl,ks+.4).discs)do assert(not x.clip,'flash mode')end

-- Seam styles.
local function seam(style,t,size)
    local x=copy(o);x.kill_seam_style=style;x.kill_seam_size=size or 1
    local f=kill_frame(x,t)
    local g={}for _,v in ipairs(f.glyphs3 or {})do if v.role=='kill-seam'then g[#g+1]=v end end
    return g,f
end
local g,f=seam('line',ks+.05)
assert(#g==0 and f.lines and #f.lines>0,'line seam')
g,f=seam('glyph',ks+.05)
assert(#g==1 and not f.lines and near(g[1].tilt,math.pi/2)and g[1].circle and g[1].dx==0,'one upright glyph in place of the line')
assert(#seam('glyph',ks+o.kill_sc_seam+.05)==0,'flashes out with the seam time')
g,f=seam('glyphs',ks+.4)
assert(#g==2 and not f.lines and near(g[1].dx,-g[2].dx)and math.abs(g[1].dx)+math.abs(g[1].dy)>0,'two glyphs ride apart')
assert(near(g[1].rotation,g[2].rotation),'both stand in the cut plane')
local g2=seam('glyphs',ks+.4,2)
assert(near(g2[1].radius,2*g[1].radius,1e-6),'size scales')

-- Commands.
local settings=copy(d);local said
local cmd=C.new(settings,d,function()end,function(m)said=m end,R.killala,R.cioara)
assert(cmd('kill',{'sc','look','current'})and settings.kill_sc_look=='current')
assert(cmd('kill',{'sc','glyph','flash'})and settings.kill_sc_glyph=='flash')
assert(cmd('kill',{'seam','style','glyphs'})and settings.kill_seam_style=='glyphs')
assert(cmd('kill',{'seam','size','1.5'})and settings.kill_seam_size==1.5)
assert(cmd('kill',{'seam','style','wavy'})and settings.kill_seam_style=='glyphs'and said:find('^Use'))
assert(not said:find('[\128-\255]'),'ASCII')
R.native_level=12
print('PASS Test7.20 SC kill ghost Light look (frozen, unfolded), split property glyph (0.13.0 clip), upright seam glyphs + size')
