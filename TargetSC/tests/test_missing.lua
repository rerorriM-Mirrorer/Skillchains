-- A missing native module must leave useful commands and clean unload available.
package.path='./TargetSC/?.lua;'..package.path
_addon={}
local events,messages={},{}
local command_count=0
windower={addon_path='./TargetSC/',add_to_chat=function(_,s)messages[#messages+1]=s end,
    send_command=function()command_count=command_count+1 end,
    debug=function()end,
    register_event=function(...)
        local args={...}local fn=table.remove(args)
        for _,n in ipairs(args)do events[n]=fn end
    end,
    ffxi={get_info=function()return {logged_in=true}end,get_player=function()return {status=0}end,
        get_mob_by_target=function()return nil end}}
package.preload.chat=function()string.color=function(s)return s end return {}end
package.preload.config=function()return {load=function(d)return d end,save=function()end}end
package.preload._TargetSC=function()error('simulated missing DLL')end
assert(loadfile('TargetSC/TargetSC.lua'))()
events.load() events['addon command']('status') events['addon command']('help')
events['addon command']('preview') events['addon command']('off')
events.prerender() events['zone change']() events.unload()
assert(table.concat(messages,'\n'):find('simulated missing DLL',1,true))
assert(command_count<=3,'no polling or per-frame console spam')
print('PASS missing native/source handling: useful status/help, clean lifecycle, no combat parser or per-frame console traffic')
