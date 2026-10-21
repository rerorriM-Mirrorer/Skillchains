-- Request-level Test6 checks; simulated geometry and real receiver, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance')
local P=require('resonance_preview')
local function copy(t)local out={}for k,v in pairs(t)do out[k]=v end return out end
local function near(a,b)assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b))end
local function layer(f,kind,role,part)
    for _,v in ipairs(kind=='disc'and f.discs or f)do
        if v.role==role and (not part or v.part==part)then return v end
    end
end
local opts=copy(R.defaults)
local function model()
    local m=R.new()
    assert(m:receive({'1','bell','1','online','100'},100))
    assert(m:receive({'1','bell','2','state','100','71','2','100','103','108','110','2','2','0','Fragmentation','Lightning,Wind','0'},100))
    return m
end
local m=model()
local s=m.states[71]
local deadlines={s.created,s.sc_open,s.sc_close,s.mb_close}
local function frame(t,o)return m:frame(71,t,2,4,o or opts)end
-- Independent low glyph anchor and height-limited bell profile.
local f=frame(101)
local floor=layer(f,'disc','property')
assert(floor.offset<.1 and layer(f,'ring','core','ground').offset>.39)
local sky=layer(f,'ring','core','sky')
near(sky.radius,2*require('resonance_motion').bell_factor(f.sky-f.ground,4,opts))
local no_bell=copy(opts);no_bell.sky_expand=0
near(layer(frame(101,no_bell),'ring','core','sky').radius,2)
local raised=copy(opts);raised.disc_height=.2
near(layer(frame(101,raised),'disc','property').offset-floor.offset,.2-opts.disc_height)
near(layer(frame(101,raised),'ring','core','ground').offset,layer(f,'ring','core','ground').offset)
local at_end=frame(108);local closing=frame(108.4)
assert(closing.remaining==0 and closing.phase=='expiration')
near(closing.ground,at_end.ground);near(closing.sky,at_end.sky)
near(layer(closing,'ring','core','ground').radius,layer(at_end,'ring','core','ground').radius)
assert(not layer(frame(108.81),'ring','core','ground'))
-- One-second fade in, one-second fade out; idle 0 preserves burst responses.
assert(layer(frame(101),'disc','mb-glyph').outline>layer(frame(100.3),'disc','mb-glyph').outline)
local quiet=copy(opts);quiet.mb_idle=0
assert(not layer(frame(101,quiet),'disc','mb-glyph'))
assert(m:receive({'1','bell','3','burst','105','71','Wind','144','spells'},105))
local burst=frame(105,quiet)
local struck=layer(burst,'disc','property')
assert(struck.color==4294967295 and struck.outline==R.argb(R.element_color('Wind'),1))
near(struck.rotation,require('resonance_motion').rotation(s,105,opts))
local restrained=copy(quiet);restrained.mb_floor=0;restrained.mb_ring=0
local subdued=frame(105,restrained)
assert(layer(subdued,'disc','property').color~=4294967295)
assert(math.floor(layer(subdued,'ring','core','mb').color/16777216)==math.floor(opts.mb_opacity*.625*255+.5))
local lifted=layer(burst,'disc','mb-glyph')
assert(lifted and lifted.rotation==0 and lifted.outline%16777216==16777215)
assert(math.floor(layer(burst,'ring','core','mb').color/16777216)==255)
local midway=frame(105.6,quiet)
local release=layer(midway,'disc','mb-glyph')
assert(release.offset>lifted.offset and release.radius>lifted.radius and release.rotation==0)
assert(release.outline%16777216==R.argb(R.element_color('Wind'),0))
local baseline=model():frame(71,105.6,2,4,quiet)
local restored=layer(midway,'disc','property')
local normal=layer(baseline,'disc','property')
assert(restored.color==normal.color and restored.outline==normal.outline)
near(restored.rotation,normal.rotation);near(restored.offset,normal.offset)
local invisible=frame(106.2,quiet)
assert(not layer(invisible,'disc','mb-glyph'))
frame(106.21,quiet);near(m.awakening_glyphs[71].offset,opts.disc_height)
assert(s.created==deadlines[1]and s.sc_open==deadlines[2]and s.sc_close==deadlines[3]and s.mb_close==deadlines[4])
-- A late confirmed burst may finish its release, without extending MB/SC.
assert(m:receive({'1','bell','4','burst','109.8','71','Fire','144','spells'},109.8))
assert(m:receive({'1','bell','5','expire','110','71'},110))
local tail=frame(110.2,quiet)
assert(tail.phase=='expired'and not layer(tail,'ring','core','mb')and not layer(tail,'ring','core','ground'))
assert(layer(tail,'disc','mb-glyph'))
frame(111.01,quiet);assert(not m.states[71]and not m.awakening_glyphs[71])
-- Overlapping confirmed hits reuse the release without a visible downward reset.
local multi=model();multi.bursts[71]={{at=104,color=R.element_color('Wind')}}
local old=layer(multi:frame(71,104.5,2,4,opts),'disc','mb-glyph')
multi.bursts[71][2]={at=104.6,color=R.element_color('Fire')}
local again=multi:frame(71,104.6,2,4,opts)
assert(layer(again,'disc','mb-glyph').offset>=old.offset and #again.discs<=2)
-- Local previews inject only into their own model and preserve all demo clocks.
for _,element in ipairs({'Wind','Fire','Ice','Water','Earth','Lightning','Light','Dark'})do
    local spec=assert(P.parse({'burst',element},R))
    local preview=P.new(spec,71,200,R,opts)
    local state=preview.model.states[71];local mb=state.mb_close
    preview:advance(200.6)
    assert(preview.model.bursts[71][1].at==200.6 and state.mb_close==mb)
    local out=preview.model:frame(71,200.6,2,4,opts)
    assert(layer(out,'disc','property').outline==R.argb(R.element_color(element),1))
end
assert(not P.parse({'burst','invalid'},R))
print('PASS bell profile/stationary closure, independent low anchor, idle breathing, opaque white/element floor strike, pooled rising release/recovery, MB ring flash, late-burst cleanup, eight local previews and unchanged source clocks')
