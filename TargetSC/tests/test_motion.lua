-- Request-level motion/geometry regressions. Pure Lua; no DLL or game rendering.
package.path='./TargetSC/?.lua;./?.lua;'..package.path
local R=require('resonance')
local Motion=require('resonance_motion')
local Preview=require('resonance_preview')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local opts=copy(require('tests.historical_defaults'))
opts.mb_style='classic';opts.ground_lift=0 -- retain the historical geometry comparison
local function near(a,b,epsilon)assert(math.abs(a-b)<(epsilon or 1e-8),tostring(a)..' ~= '..tostring(b))end
local function state(p,level,step)
    return {id=71,revision=step,created=100,sc_open=103,sc_close=step==1 and 110 or 109,
        mb_close=step>1 and 110 or 0,step=step,level=level,properties={p},elements=R.elements(p)}
end
local m=R.new();local s=state('Liquefaction',1,1);m.states[71]=s
local function frame(t,o)return m:frame(71,t,2,4,o or opts)end
local function cores(f,part)
    local r={}for _,b in ipairs(f)do if b.role=='core'and b.part==part then r[#r+1]=b end end return r
end
local function discs(f,role)
    local r={}for _,d in ipairs(f.discs or {})do if d.role==role then r[#r+1]=d end end return r
end
for k,v in pairs({motion='sine',period=.09,amplitude=.3,damping=3,intensity=1,scale=2,
    opacity=.3,brightness=4,glow=1,disc_opacity=1,width=2,height=1})do assert(opts[k]==v,'snapshot default '..k)end
assert(frame(100.5).sky==nil and frame(102.999).sky==nil,'opener is ground-only before source opening')
assert(frame(102).remaining==1,'no pre-window countdown')
assert(frame(103.4).sky and frame(104).remaining>frame(108).remaining)
local _,strike_a=Motion.vibration(s,100.04,opts)
local _,strike_b=Motion.vibration(s,103.04,opts)
near(strike_a,strike_b,1e-10)
local small=Motion.positions(s,100.04,.7,opts)
local large=Motion.positions(s,100.04,40,opts)
near(small,large)
near(Motion.positions(s,100,4,opts),opts.ground_height+opts.amplitude/2)
local o=copy(opts);o.damping=0;o.hum_amplitude=0
near(Motion.positions(s,100.01,4,o),Motion.positions(s,100.01+2*o.period*5,4,o))
o=copy(opts);o.damping=8
local _,_,early=Motion.vibration(s,104.5,o)
local _,_,late=Motion.vibration(s,108,o)
near(early.hum_amplitude,late.hum_amplitude,1e-6)
assert(early.hum_hz>late.hum_hz and late.hum_hz>0,'hum slows without reducing settled amplitude')
local higher=state('Darkness',3,4)
local _,_,energized=Motion.vibration(higher,104.5,o)
assert(energized.hum_hz>early.hum_hz and energized.hum_amplitude>early.hum_amplitude)
-- Deliberate held jumps remain available; sine stays continuous.
for _,layout in ipairs({'grounded','symmetric','center'})do
    o=copy(opts);o.layout=layout;o.motion='flutter';o.period=.15
    local a=Motion.positions(s,103.1499,4,o);local b=Motion.positions(s,103.1501,4,o)
    assert(math.abs(a-b)>.05,'held offset is discrete')
    o.motion='sine';a=Motion.positions(s,103.1499,4,o);b=Motion.positions(s,103.1501,4,o)
    assert(math.abs(a-b)<.02,'sine stays continuous')
end
-- Full opener property palettes, main ring outside the smaller alternatives.
s=state('Fragmentation',2,1);s.properties={'Fragmentation','Scission','Impaction'};m.states[71]=s
local f=frame(102.5);local ground=cores(f,'ground')
assert(#ground==3 and #ground[1].colors==2,'Fragmentation remains one two-color opener ring')
assert(ground[1].colors[1]%16777216~=ground[1].colors[2]%16777216)
assert(ground[1].radius>ground[2].radius and ground[2].radius>ground[3].radius)
near(ground[1].offset,ground[3].offset)
local layers=discs(f,'property')
assert(#layers==3 and #layers[1].colors==2)
assert(layers[1].radius>layers[2].radius and layers[2].radius>layers[3].radius)
assert(layers[1].offset<layers[2].offset and layers[2].offset<layers[3].offset)
assert(#discs(f,'ground-glyph')==0,'stationary base glyph removed at every level')
-- Filled, outline-only and discs-off comparisons; awakening stays independent.
o=copy(opts);o.discs=false
assert(#discs(frame(100.25,o),'awakening')==1 and #discs(frame(100.25,o),'property')==0)
assert(#frame(102.9,o).discs==0,'no follow-up small pulses')
o.awakening=false;assert(#frame(100.25,o).discs==0)
o=copy(opts);o.disc_opacity=0
layers=discs(frame(102.5,o),'property')
assert(math.floor(layers[1].color/16777216)==0 and math.floor(layers[1].outline/16777216)>0,'fill and outline independent')
o.disc_style='outline';assert(discs(frame(102.5,o),'property')[1].glyph==2)
-- Successful-chain ring count indicates level, never the number of links.
for level,p in ipairs({'Liquefaction','Fragmentation','Darkness','Umbra'})do
    s=state(p,level,5);m.states[71]=s
    ground=cores(frame(103.4),'ground')
    assert(#ground==level,'level hierarchy '..level)
    if level==2 or level==3 then
        near(ground[1].radius,ground[level].radius)
        assert(ground[1].offset<ground[level].offset,'L2/L3 are vertically stacked')
    elseif level==4 then
        assert(ground[1].radius<ground[4].radius)
        near(ground[1].offset,ground[4].offset)
    end
    local turns=level==1 and 1 or level==2 and 2 or level==3 and 4 or 0
    near((Motion.rotation(s,100.01,opts)-Motion.rotation(s,100,opts))/.01,2*math.pi*turns*opts.disc_speed,1e-8)
    local function speed(t)return (Motion.rotation(s,t+.00001,opts)-Motion.rotation(s,t,opts))/.00001 end
    if level<4 then
        assert(speed(103.1)>speed(106) and speed(106)>speed(108.999))
        near(speed(109.1),0)
    else near(Motion.rotation(s,107,opts),0)end
end
-- All eight combinations are independently viewable and presentation-only.
local function glows(f,part)
    local r={}for _,b in ipairs(f)do if b.role=='glow'and b.part==part then r[#r+1]=b end end return r
end
s=state('Fusion',2,1);m.states[71]=s
local original=copy(opts);original.opener_gap=0;original.opener_glow='color';original.opener_muted=false
local original_frame=frame(104,original)
for _,gap in ipairs({0,12})do
 for _,mode in ipairs({'color','black','off'})do
  for _,muted in ipairs({false,true})do
    o=copy(original);o.opener_gap=gap;o.opener_glow=mode;o.opener_muted=muted
    local current=frame(104,o)
    near(current.ground,original_frame.ground);near(current.sky,original_frame.sky)
    near(current.remaining,original_frame.remaining)
    for _,part in ipairs({'ground','sky'})do
        local core=cores(current,part)[1];assert(core.gap==gap and #core.colors==2)
        local glow=glows(current,part)
        if mode=='off'then assert(#glow==0)
        else
            assert(#glow==1 and glow[1].gap==gap and glow[1].rotation==core.rotation)
            if mode=='black'then assert(glow[1].color%16777216==0 and glow[1].color>=16777216)
            else assert(glow[1].color==core.color-(math.floor(core.color/16777216)-math.floor(glow[1].color/16777216))*16777216)end
        end
    end
    if muted then assert(cores(current,'ground')[1].color%16777216~=cores(original_frame,'ground')[1].color%16777216)end
  end
 end
end
-- Every L2 property has both palettes on each vertically stacked ring,
-- in reverse order, from the initial white charge through countdown/fade.
for _,property in ipairs({'Fusion','Fragmentation','Distortion','Gravitation'})do
 s=state(property,2,3);m.states[71]=s
 for _,at in ipairs({100,100.1,102.9,103,104,109.2})do
  local current=frame(at)
  for _,part in ipairs({'ground','sky'})do
   local pair=cores(current,part);assert(#pair==2 and #pair[1].colors==2 and #pair[2].colors==2)
   assert(pair[1].colors[1]==pair[2].colors[2]and pair[1].colors[2]==pair[2].colors[1])
   assert(pair[1].gap==0 and pair[2].gap==0 and pair[1].rotation==pair[2].rotation)
   assert(pair[1].offset<pair[2].offset)
  end
 end
 -- Opener toggles cannot alter a completed chain or its discs.
 assert(require('resonance_motion').phase(s,104)=='countdown')
 o=copy(opts);o.opener_gap=0;o.opener_glow='off';o.opener_muted=false
 local a,b=frame(104),frame(104,o)
 for i,band in ipairs(a)do assert(band.color==b[i].color and band.gap==b[i].gap)end
 for i,d in ipairs(a.discs)do assert(d.color==b.discs[i].color and d.outline==b.discs[i].outline)end
end
print('PASS opener comparisons: all 12 combinations, exact gap metadata, black/off/color surround, preserved motion and completed chains; all four L2 opposed palettes on ground/sky from charge through fade')
-- A normal expiry keeps its fade, adding downward/inward closure after the deadline.
s=state('Liquefaction',1,1);m.states[71]=s
local end_frame=frame(110);local faded=frame(110.3)
local end_ground=cores(end_frame,'ground')[1];local fade_ground=cores(faded,'ground')[1]
near(fade_ground.radius,end_ground.radius);near(fade_ground.offset,end_ground.offset)
assert(end_ground.color%16777216==fade_ground.color%16777216 and faded.phase=='expiration')
assert(math.floor(fade_ground.color/16777216)<math.floor(end_ground.color/16777216))
assert(#frame(110.81)==0,'no MB halo invented for an expired opener')
s=state('Umbra',4,5);s.closed=true;m.states[71]=s
local terminal=frame(103.3)
assert(terminal.phase=='terminal'and terminal.remaining==0 and #cores(terminal,'ground')==4)
assert(#cores(terminal,'mb')==1,'MB reminder can coexist with terminal fade')
local tail=frame(104)
assert(tail.phase=='mb-only'and #cores(tail,'ground')==0 and #cores(tail,'mb')==1 and #discs(tail,'property')==1)
-- Demo has actual source-style shrinking windows and NO burst event.
local spec=assert(Preview.parse({'demo'},R));local p=Preview.new(spec,71,200,R)
local times={0,9,17,24,30}
for step,at in ipairs(times)do
    assert(not p:advance(200+at+.01))
    local current=p.model.states[71]
    assert(current.step==step and current.created==200+at)
    assert(current.level==(step==1 and 1 or step-1))
    if step>1 then near(p.events[step-1].at,current.previous.sc_close-1)end
    assert(not next(p.model.bursts),'full demo does not inject MB events')
end
assert(p.model.states[71].closed and p.ends==240.05)
assert(p:advance(p.ends+.01))
for _,kind in ipairs({'opener','pre','chain','window','expire','closed','umbra','full','level1','level2','level3','level4'})do
    local q=Preview.new(assert(Preview.parse({kind},R)),71,300,R)
    assert(not q:advance(300));assert(q:advance(q.ends+.01))
end
assert(not Preview.parse({'chain','Liquefaction,Fusion'},R))
-- Finite and bounded frames across every presentation, including legacy.
for _,property in ipairs({'Liquefaction','Fusion','Fragmentation','Distortion','Light','Darkness','Radiance','Umbra'})do
    for _,motion in ipairs({'flutter','sine','legacy'})do
        for _,layout in ipairs({'grounded','symmetric','center'})do
            o=copy(opts);o.motion=motion;o.layout=layout
            local model=R.new();model.states[71]=state(property,R.level(property),2)
            for i=0,1050 do
                local out=model:frame(71,100+i/100,2,4,o)
                assert(#out<=32 and #(out.discs or {})<=8)
                for _,b in ipairs(out)do
                    assert(b.radius>0 and b.offset==b.offset and b.color>=0 and b.color<=4294967295)
                    if b.pixels then assert(b.pixels>=1 and b.pixels<=64)end
                    for _,c in ipairs(b.colors or {})do assert(c>=0 and c<=4294967295)end
                end
                for _,d in ipairs(out.discs or {})do assert(d.rotation==d.rotation and d.radius>0 and #d.colors<=4)end
            end
        end
    end
end
-- Snapshot, incompatible opener and real burst ordering through v1 receiver.
local receiver=R.new()
local function event(seq,kind,fields,at)
    local args={'1','test',tostring(seq),kind,tostring(at)}
    for _,v in ipairs(fields or {})do args[#args+1]=tostring(v)end
    assert(receiver:receive(args,at))
end
event(1,'online',{},400)
event(2,'state',{71,1,400,403,409,410,2,2,0,'Fusion','Fire,Light',0},400)
event(3,'burst',{71,'Fire',144,'spells'},404)
local old=receiver.states[71];local deadlines={old.sc_open,old.sc_close,old.mb_close,old.created}
assert(#receiver:frame(71,404.05,2,4,opts)>0)
assert(old.sc_open==deadlines[1]and old.sc_close==deadlines[2]and old.mb_close==deadlines[3]and old.created==deadlines[4])
event(4,'state',{71,2,404.1,407.1,414.1,0,1,1,0,'Liquefaction','Fire',0},404.1)
assert(receiver.bursts[71]==nil and receiver.states[71].previous==nil)
local before=receiver:frame(71,408,2,4,opts)
event(5,'state',{71,2,404.1,407.1,414.1,0,1,1,0,'Liquefaction','Fire',1},408)
local after=receiver:frame(71,408,2,4,opts)
near(before.ground,after.ground);near(before.sky,after.sky);near(before.remaining,after.remaining)
print('PASS Test3 motion: snapshot defaults, equal world-space strikes, no fall, independent steady-amplitude slowing hum, segmented opener colors, level hierarchy, glyph layers, spin-to-stop, in-place fades, MB reminder')
print('PASS full Umbra demo: 0/9/17/24/30s, four links, shrinking source-style windows, no bursts; exact snapshots/deadlines preserved')
print('PASS geometry sweep: 8 properties x 3 motions x 3 layouts x 1051 frames, <=32 bands/8 discs')
