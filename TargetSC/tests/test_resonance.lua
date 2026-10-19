-- Lua 5.1 simulated publisher -> consumer -> geometry integration.
package.path='./?.lua;./TargetSC/?.lua;'..package.path
local Bridge=require('targetsc_bridge')
local R=require('resonance')
local now=100
local opts={opacity=.65,scale=1,height=1,intensity=.65,motion='legacy'}
local definitions={Liquefaction={'Fire',lvl=1},Fusion={'Fire','Light',lvl=2},
    Distortion={'Ice','Water',lvl=2},Light={'Fire','Wind','Lightning','Light',lvl=3},
    Darkness={'Earth','Ice','Water','Dark',lvl=3},Radiance={'Fire','Wind','Lightning','Light',lvl=4},
    Umbra={'Earth','Ice','Water','Dark',lvl=4}}
local consumer=R.new()
local wire={}
local bridge=Bridge.new(definitions,{spells={[1]={element=0},[2]={element=1}}},function(command)
    assert(not command:find(';',1,true))
    assert(command:match('^lua i TargetSC _event '))
    local args={}
    for token in command:gsub('^lua i TargetSC _event ',''):gmatch('%S+') do args[#args+1]=token end
    wire[#wire+1]=args
    local ok,why=consumer:receive(args,now)
    assert(ok,why)
end,function()return now end)
local states={}
local state={active={'Liquefaction'},delay=103,times=110,mb_window=0,step=1}
states[71]=state
bridge:state(71,state)
assert(#wire==0,'no messages while unsubscribed')
bridge:subscribe(states)
assert(consumer.connected and consumer.synced and consumer.states[71].sc_close==110)
local frame=consumer:frame(71,100.5,1,2,opts)
assert(#frame==4,'one strand per ground/sky ring, with two restrained glows')
local function span(t)
    local f=consumer:frame(71,t,1,2,opts)
    return math.abs(f[2].offset-f[4].offset)
end
assert(span(104)>span(107) and span(107)>span(109.5),'convergence follows authoritative expiry')
local expired=R.new() expired.states[71]=consumer.states[71]
assert(#expired:frame(71,110.3,1,2,opts)==0,'opener disappears without invented MB window')
now=104
local chain={active={'Fusion'},delay=107,times=113,mb_window=114,step=2}
bridge:state(71,chain)
local s=consumer.states[71]
assert(s.previous and s.sc_open==107 and s.sc_close==113 and s.mb_close==114)
assert(#consumer:frame(71,104.06,1,2,opts)>0,'collapse frame exists')
assert(#consumer:frame(71,104.6,1,2,opts)==8,'two element strands at both heights')
local sc,mb,created=s.sc_close,s.mb_close,s.created
now=108
bridge:bursts({category=4,param=1,targets={{id=71,actions={{message=252},{message=252}}},
    {id=72,actions={{message=265}}}}})
assert(#consumer.bursts[71]==1,'one burst per target despite duplicate hits')
assert(not consumer.bursts[72],'untracked target not invented')
assert(s.sc_close==sc and s.mb_close==mb and s.created==created,'burst changes no deadline or revision')
assert(#consumer:frame(71,108.05,1,2,opts)>8,'shimmer and outward ripple added')
assert(#consumer:frame(71,113.4,1,2,opts)==2,'MB-only halo remains after continuation')
now=113.5
bridge:bursts({category=4,param=2,targets={{id=71,actions={{message=265}}}}})
assert(#consumer:frame(71,113.55,1,2,opts)>2,'burst during MB-only tail')
assert(#consumer:frame(71,114.3,1,2,opts)==0,'independent final expiry')
now=120
bridge:state(71,{active={'Light'},delay=123,times=126,mb_window=130,step=4,closed=true,result_level=4})
assert(consumer.states[71].level==4,'publisher uses already-resolved aeonic tier')
assert(#consumer:frame(71,120.4,1,2,opts)>=16,'four strands per halo at tier 4')
assert(#consumer:frame(71,121,1,2,opts)==2,'closed chain has no false continuation')
bridge:reset('zone')
assert(next(consumer.states)==nil and next(consumer.bursts)==nil)
bridge:stop() assert(not consumer.connected)
assert(consumer:receive(wire[#wire-1],now)==false,'stale event after offline rejected')
bridge:subscribe({}) assert(consumer.connected and consumer.synced)
local probe=R.new()
assert(probe:receive({'1','probe','1','online',tostring(now)},now))
local accepted=probe:receive({'1','probe','3','synced',tostring(now)},now)
assert(accepted and probe.gaps==1 and probe.needs_sync and not probe.synced)
assert(consumer:receive({'2','bad','0','state','0'},now)==false)
bridge:state(71,{active={'Fusion'},delay=123,times=129,mb_window=130,step=2})
local original=consumer.states[71]
now=121 bridge:subscribe({[71]={active={'Fusion'},delay=123,times=129,mb_window=130,step=2}})
assert(not consumer.states[71].previous and consumer.states[71].created==original.created,'snapshot cannot replay strike')
local other=R.new() assert(next(other.states)==nil,'second client state remains independent')
for _,p in ipairs({'Liquefaction','Fusion','Distortion','Light','Darkness','Radiance','Umbra'}) do
    local m=R.new()
    m.states[1]={id=1,created=0,sc_open=3,sc_close=10,mb_close=11,step=2,level=R.level(p),properties={p},elements=R.elements(p)}
    for t=0,1120 do
        local f=m:frame(1,t/100,1.5,3,opts)
        assert(#f<=24)
        for _,r in ipairs(f) do
            assert(r.radius>0 and r.width>0 and r.offset==r.offset)
            assert(r.color>=0 and r.color<=4294967295)
        end
    end
end
local small_r,small_h=R.dimensions({model_size=.1,model_scale=1},opts)
local big_r,big_h=R.dimensions({model_size=500,model_scale=1},opts)
assert(small_r>=.4 and small_h>=.65 and big_r<=12 and big_h<=30)
-- Unknown-element ability bursts are counted, never assigned a guessed color.
now=140 bridge:bursts({category=13,param=99,targets={{id=71,actions={{message=379}}}}})
assert(consumer.unknown_bursts==1)
print('PASS publisher/consumer integration: deadlines, transitions, AoE MB, closed chains, lifecycle, snapshots, client isolation')
print('PASS animation sweep: 7 palettes x 1121 frames, finite/bounded geometry, model scale clamps')
