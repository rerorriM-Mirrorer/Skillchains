package.path='./TargetSC/?.lua;./?.lua;'..package.path
local R=require('resonance')
local Motion=require('resonance_motion')
local Preview=require('resonance_preview')
local opts={}for k,v in pairs(R.defaults)do opts[k]=v end
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function state(p,level,step)
    return {id=71,revision=step,created=100,sc_open=103,sc_close=step==1 and 110 or 109,
        mb_close=step>1 and 110 or 0,step=step,level=level,properties={p},elements=R.elements(p)}
end
local m=R.new();local s=state('Liquefaction',1,1);m.states[71]=s
local function frame(t,options)return m:frame(71,t,2,4,options or opts)end
assert(frame(100.5).sky==nil and frame(102.999).sky==nil,'no sky during opener pre-window')
assert(frame(102).remaining==1,'pre-window is not counted down')
assert(frame(103.4).sky~=nil and frame(104).remaining>frame(108).remaining)
assert(frame(100.3).phase=='pre' and frame(104).phase=='countdown')
assert(frame(110.1).phase=='expiration')
local f=frame(101.5)
assert(#f.discs>=2,'white/property pulses and ground disc exist in reveal phase')
assert(f.discs[#f.discs].glyph==1)
local plain=copy(opts);plain.discs=false;assert(#frame(102,plain).discs==0,'explicit discs off survives defaults')
local invisible_discs=copy(opts);invisible_discs.disc_opacity=0
assert(#frame(100.4,invisible_discs).discs==0 and #frame(102,invisible_discs).discs==0,'disc opacity zero hides charge/pulse/glyph layers')
-- Compare the same absolute window clocks under each motion/layout option.
for _,layout in ipairs({'grounded','symmetric','center'})do
    local o=copy(opts);o.layout=layout
    local before=Motion.positions(s,103.1499,4,o)
    local after=Motion.positions(s,103.1501,4,o)
    assert(math.abs(after-before)>.05,'a discrete jump must remain discontinuous: '..layout)
    o.motion='sine'
    local a=Motion.positions(s,103.1499,4,o)
    local b=Motion.positions(s,103.1501,4,o)
    assert(math.abs(b-a)<.02,'sine comparison is continuous: '..layout)
end
local o=copy(opts);o.layout='grounded';o.damping=0
local early_a=Motion.positions(s,103.2999,4,o)
local early_b=Motion.positions(s,103.3001,4,o)
local late_a=Motion.positions(s,108.9999,4,o)
local late_b=Motion.positions(s,109.0001,4,o)
assert(math.abs(early_b-early_a)>math.abs(late_b-late_a),'flutter shrinks with remaining window')
for _,p in ipairs({'Liquefaction','Fusion','Fragmentation','Distortion','Light','Darkness','Radiance','Umbra'})do
    for _,motion in ipairs({'flutter','sine','legacy'})do
        for _,layout in ipairs({'grounded','symmetric','center'})do
            local local_opts=copy(opts);local_opts.motion=motion;local_opts.layout=layout
            local model=R.new();model.states[71]=state(p,R.level(p),2)
            for i=0,1050 do
                local out=model:frame(71,100+i/100,2,4,local_opts)
                assert(#out<=32 and #(out.discs or {})<=8)
                for _,band in ipairs(out)do
                    assert(band.radius>0 and band.offset==band.offset and band.color>=0 and band.color<=4294967295)
                    if band.pixels then assert(band.pixels>=1 and band.pixels<=64)end
                end
                for _,d in ipairs(out.discs or {})do assert(d.rotation==d.rotation and d.radius>0)end
            end
        end
    end
end
s=state('Fusion',2,2);m.states[71]=s
local saved={s.sc_open,s.sc_close,s.mb_close,s.created}
local charge=frame(101);assert(charge.sky~=nil,'successful chain recharges paired rings during pre-window')
local cores={}
for _,b in ipairs(charge)do if b.role=='core' then cores[#cores+1]=b.color%16777216 end end
for _,c in ipairs(cores)do assert(c==16777215,'successful pre-window core stays white')end
local colored=frame(103.3);local distinct={}
for _,b in ipairs(colored)do if b.role=='core'then distinct[b.color%16777216]=true end end
local count=0 for _ in pairs(distinct)do count=count+1 end assert(count==2,'level 2 remains two distinct colors')
assert(frame(109.4).phase=='mb-only' and #frame(109.4).discs==0)
assert(s.sc_open==saved[1] and s.sc_close==saved[2] and s.mb_close==saved[3] and s.created==saved[4])
s=state('Umbra',4,2);s.closed=true;m.states[71]=s
assert(frame(104).phase=='mb-only' and frame(104).sky==nil)
assert(frame(104).discs[1].rotation==0,'level 4 closed disc stays still')
for _,kind in ipairs({'opener','pre','chain','window','expire','closed','demo','level1','level2','level3','level4'})do
    local spec=assert(Preview.parse({kind},R));local p=Preview.new(spec,71,200,R)
    local original=p.model.states[71];local deadline=original.sc_close
    assert(not p:advance(200))
    assert(p:advance(p.ends+.01))
    assert(original.sc_close==deadline,'preview clock is not restarted by update')
end
local spec=assert(Preview.parse({'opener','Liquefaction,Impaction,Detonation'},R))
local p=Preview.new(spec,71,300,R)
assert(#p.model.states[71].properties==3)
local out=p.model:frame(71,302.5,2,4,opts)
assert(#out.discs==4,'three glyphs plus final pre-window pulse')
assert(not Preview.parse({'chain','Liquefaction,Fusion'},R))
-- Snapshot/MB/new-opener ordering goes through the real v1 receiver.
local receiver=R.new()
local function event(seq,kind,fields,at)
    local args={'1','test',tostring(seq),kind,tostring(at)}
    for _,v in ipairs(fields or {})do args[#args+1]=tostring(v)end
    assert(receiver:receive(args,at))
end
event(1,'online',{},400)
event(2,'state',{71,1,400,403,409,410,2,2,0,'Fusion','Fire,Light',0},400)
event(3,'burst',{71,'Fire',144,'spells'},404)
local old=receiver.states[71]
local open,close,mb=old.sc_open,old.sc_close,old.mb_close
local burst_frame=receiver:frame(71,404.05,2,4,opts)
assert(#burst_frame>0 and old.sc_open==open and old.sc_close==close and old.mb_close==mb)
event(4,'state',{71,2,404.1,407.1,414.1,0,1,1,0,'Liquefaction','Fire',0},404.1)
assert(receiver.bursts[71]==nil and receiver.states[71].previous==nil,'incompatible opener clears all prior effects')
local before=receiver:frame(71,408,2,4,opts)
event(5,'state',{71,2,404.1,407.1,414.1,0,1,1,0,'Liquefaction','Fire',1},408)
local after=receiver:frame(71,408,2,4,opts)
assert(before.ground==after.ground and before.sky==after.sky and before.remaining==after.remaining,'snapshot retains exact phase/motion')
print('PASS revised motion/phase previews: ground-first opening, source-bound convergence, held jumps vs sine, L1-L4, colors, discs, independent MB lifetime')
print('PASS revised geometry sweep: 8 properties x 3 motions x 3 layouts x 1051 frames, bounded 32 bands/8 discs')
