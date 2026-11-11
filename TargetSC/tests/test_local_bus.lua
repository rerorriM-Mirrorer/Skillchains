-- Same-process bridge regression: original event envelopes, no Windower commands.
package.path='./TargetSC/?.lua;'..package.path
local now=100
local bus=require('targetsc_local')
local model=require('resonance').new()
local seen={}
bus.set_receiver(function(frame)
    seen[#seen+1]=frame[4]
    local ok,why=model:receive(frame,now)
    assert(ok,why)
end)
local defs={Scission={'Earth',lvl=1},Distortion={'Ice','Water',lvl=2}}
local resources={spells={[144]={element=0}}}
local bridge=require('targetsc_bridge').new(defs,resources,bus.send,function()return now end)
local states={[71]={active={'Scission'},delay=103,times=110,mb_window=0,step=1,closed=false}}
bus.set_source(function()bridge:subscribe(states)end,function()bridge.subscribed=false end)
assert(bus.subscribe()and bridge.subscribed)
assert(model.connected and model.synced and model.states[71].sc_open==103)
assert(model.states[71].sc_close==110 and model.states[71].mb_close==0)
now=105
states[71]={active={'Distortion'},delay=107,times=113,mb_window=114,step=2,closed=false,result_level=2}
bridge:state(71,states[71])
assert(model.states[71].level==2 and model.states[71].sc_close==113)
assert(model.states[71].mb_close==114)
local created=model.states[71].created
bridge:bursts({category=4,param=144,targets={{id=71,actions={{message=252}}}}})
assert(#(model.bursts[71] or {})==1,'confirmed burst delivered to local receiver')
now=106
assert(bus.subscribe())
assert(model.synced and model.states[71].created==created,'snapshot retains source clock')
assert(model.states[71].sc_close==113 and model.states[71].mb_close==114)
assert(not model.states[71].previous,'snapshot does not replay previous strike')
assert(bus.send('lua c Skillchains targetsc subscribe')==false,'no external command routing')
bridge:reset('zone')
assert(not next(model.states),'reset clears world state')
bridge:stop()
assert(not model.connected and not next(model.states),'unload clears renderer source')
bus.unsubscribe()
assert(bridge.subscribed==false)
assert(table.concat(seen,','):find('online,',1,true))
print('PASS embedded local bridge: opener, extension, burst, snapshot clocks, reset and unload')
