-- Skillchains-only visual timeline regression (no Windower or FFXI runtime).
-- Cross-checks TargetSC Test3's demo definitions without loading TargetSC at runtime.
package.path='./TargetSC/?.lua;./?.lua;'..package.path
local M=require('skillchains_demo')
local paired=require('resonance_preview')
assert(#M.sequence==#paired.umbra_sequence and #M.sequence==5)
for i,row in ipairs(M.sequence) do
    local other=paired.umbra_sequence[i]
    assert(row.weapon==other.weapon and row.name==other.name
        and row.property==other.property and row.used==other.used,
        'Skillchains and TargetSC demo diverged at step '..i)
    assert(row.level==(i==1 and 0 or other.level))
end

local demo=M.new(100)
local times={0,9,17,24,30}
local windows={110,118,125,131,136}
local results={'Scission','Detonation','Gravitation','Darkness','Umbra'}
for i=1,5 do
    local step=demo.stages[i]
    assert(step.created==100+times[i] and step.times==windows[i],
        'Unexpected stage deadline for '..i)
    assert(step.delay==step.created+3)
    assert(step.mb_window==(i==1 and 0 or step.created+10))
    local frame=assert(demo:frame(step.created))
    assert(frame.active[1]==results[i] and frame.step==i)
    assert(frame.level==(i==1 and 0 or i-1))
    assert(frame.sc_wait==3 and frame.sc_left==8-i)
    if i>1 then
        assert(step.created==demo.stages[i-1].times-1)
        assert(frame.from_active[1]==results[i-1])
        assert(math.abs(frame.from_fraction-1/(9-i))<1e-8)
    end
end

for i=1,4 do
    local stage=demo.stages[i]
    local frame=assert(demo:frame(stage.created+.5))
    assert(frame.step==i and frame.active[1]==results[i])
end
local last=assert(demo:frame(130))
assert(last.step==5 and not last.closed and last.sc_wait==3
    and last.mb_left==10,'Terminal charge must remain visible')
last=assert(demo:frame(133))
assert(last.closed and last.mb_left==7,
    'After terminal charge only the burst window remains')
last=assert(demo:frame(139.9))
assert(last.closed and last.mb_left>0 and last.mb_left<.11)
assert(demo:frame(140.05)==nil and demo:status(140.05)=='finished')
local jumped=M.new(100)
local f,a=jumped:frame(124)
assert(f.step==4 and a:find('Rudra',1,true),
    'Late frames must catch up to the correct absolute phase')
local f2,a2=jumped:frame(124.4)
assert(f2.step==4 and a2==nil,'Milestones must only announce once')
assert(M.new(100).stages[5].mb_window==140)
print('PASS standalone Skillchains Umbra demo: Test3 parity, timeline, terminal charge, MB tail, late frames')
