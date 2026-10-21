-- Test5 presentation requirements; host simulation, not DLL/game execution.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local Motion=require('resonance_motion')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function near(a,b)assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b))end
local function state(created,step,level,property)
    return {id=71,revision=step,created=created,sc_open=created+3,sc_close=created+8,
        mb_close=step>1 and created+10 or 0,step=step,level=level,
        properties={property},elements=R.elements(property)}
end
local function layer(frame,kind,role,part)
    for _,item in ipairs(kind=='disc'and frame.discs or frame)do
        if item.role==role and (not part or item.part==part)then return item end
    end
end
local opts=copy(R.defaults)
assert(opts.disc_speed==.1 and opts.ground_height==.39 and opts.mb_opacity==1)
local m=R.new()
local opener=state(100,1,1,'Scission');m.states[71]=opener
local early=m:frame(71,100.3,2,4,opts)
local glyph=early.awakening_glyph
local first=layer(early,'disc','awakening')
assert(glyph and first and first.glyph==2 and first.rotation==0)
assert(first.color<16777216 and first.outline>=16777216,'opening glyph is outline-only')
near(first.offset,.39+.008)
local radius=glyph.radius
local later=m:frame(71,101.5,2,4,opts)
assert(later.awakening_glyph==glyph and glyph.radius>radius and glyph.rotation==0)
local hidden=m:frame(71,102.5,2,4,opts)
assert(hidden.awakening_glyph==glyph and glyph.opacity==0)
assert(not layer(hidden,'disc','awakening')and not layer(hidden,'disc','ground-glyph'))
near(glyph.radius,2*.96)
-- Hidden opening object survives a successful chain; it must not replay.
local chain=state(103,3,2,'Fusion');m.states[71]=chain
for _,time in ipairs({103,103.2,104,107,111,112.5})do
    local f=m:frame(71,time,2,4,opts)
    assert(f.awakening_glyph==glyph and glyph.opacity==0 and m.awakening_glyphs[71]==glyph)
    assert(not layer(f,'disc','ground-glyph')and not layer(f,'disc','awakening'))
    local mb=layer(f,'ring','core','mb')
    assert(mb,'MB exists during preparation, continuation and independent tail')
    assert(math.floor(mb.color/16777216)==math.floor((113-time)/10*255+.5))
    local disc=layer(f,'disc','property')
    assert(disc,'property glyph survives until MB fade')
    for _,band in ipairs(f)do
        if band.part=='ground'or band.part=='sky'then near(band.rotation,disc.rotation)end
    end
end
-- Its own opacity bypasses the global ring opacity and still fades linearly.
local faint=copy(opts);faint.opacity=0
local full=m:frame(71,103,2,4,faint)
assert(math.floor(layer(full,'ring','core','mb').color/16777216)==255)
faint.mb_opacity=.4
local half=m:frame(71,108,2,4,faint)
assert(math.floor(layer(half,'ring','core','mb').color/16777216)==51)
faint.mb_opacity=0
assert(not layer(m:frame(71,108,2,4,faint),'ring','core','mb'))
assert(not layer(m:frame(71,113,2,4,opts),'ring','core','mb'))
assert(m.awakening_glyphs[71]==glyph,'natural visual expiry does not destroy cached opening glyph')
-- Stage controls retain level progression and share rotation with L2 rings.
local tuned=copy(opts);tuned.disc_speed_level2=.7
local angle=Motion.rotation(chain,103.4,tuned)
near(angle,2*math.pi*.7*.1*.4)
tuned.disc_speed=2
near(Motion.rotation(chain,103.4,tuned),angle*20)
-- Disc visibility does not disable the opening glyph.
local solo=R.new();solo.states[71]=opener
local no_discs=copy(opts);no_discs.discs=false
assert(layer(solo:frame(71,100.4,2,4,no_discs),'disc','awakening'))
no_discs.awakening=false
assert(#solo:frame(71,100.4,2,4,no_discs).discs==0)
-- Explicit source expiry/reset, unlike an animation fade, releases ownership.
local receiver=R.new()
assert(receiver:receive({'1','test','1','online','100'},100))
assert(receiver:receive({'1','test','2','state','100','71','1','100','103','110','0','1','1','0','Scission','Earth','0'},100))
assert(receiver.awakening_glyphs[71])
assert(receiver:receive({'1','test','3','expire','111','71'},111))
assert(not receiver.awakening_glyphs[71])
receiver:clear();assert(not next(receiver.awakening_glyphs))
print('PASS Test5 MB full-window opacity/fade, retained nonspinning opening glyph, no stationary base, MB-lived property disc, matched L2 rotations, stage speed tuning and source cleanup')
