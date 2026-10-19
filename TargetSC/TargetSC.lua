_addon.name='TargetSC'
_addon.author='A'
_addon.version='0.2.0-test2'
_addon.commands={'tsc','targetsc'}

require('chat')
local config=require('config')
local resonance=require('resonance')
local previews=require('resonance_preview')
local defaults={enabled=true,debug=false}
for key,value in pairs(resonance.defaults)do defaults[key]=value end
local settings=config.load(defaults)
local model=resonance.new()
local native,renderer_error,renderer_started
local preview,selected_id,next_frame,last_tracking_error=nil,nil,0,nil
local requested_at,source_wait_notice=0,false
local log_size=0
local addon_path=windower.addon_path:gsub('\\','/')
package.cpath=package.cpath..';'..addon_path..'libs/?.dll'
local ok,result=pcall(require,'_TargetSC')
if ok and type(result)=='table' and type(result.version)=='function' then
    local version_ok,version=pcall(result.version)
    local api_ok=true
    for _,name in ipairs({'start','stop','clear','begin','ring','disc','commit','status'}) do
        if type(result[name])~='function' then api_ok=false end
    end
    if version_ok and version=='0.2.0' and api_ok then native=result
    else renderer_error='Native API/version mismatch; expected TargetSC 0.2.0, received '..tostring(version) end
else renderer_error=tostring(result) end

local function say(text) windower.add_to_chat(207,'TargetSC: '..text) end
local function debug(text)
    if not settings.debug then return end
    windower.debug('TargetSC '..text)
    local path=addon_path..'data/'
    if not windower.dir_exists(path) then windower.create_dir(path) end
    if log_size>1048576 then
        os.remove(path..'TargetSC-debug.log.1')
        os.rename(path..'TargetSC-debug.log',path..'TargetSC-debug.log.1')
        log_size=0
    end
    local f=io.open(path..'TargetSC-debug.log','a')
    if f then
        local line=('[%.6f] %s\n'):format(os.clock(),text)
        f:write(line) f:close() log_size=log_size+#line
    end
end
local function clear()
    if native then native.clear() end
end
local function start_renderer()
    if not native then say('Native renderer unavailable: '..tostring(renderer_error)..'. See README build/install instructions.') return false end
    if not renderer_started then
        local status=native.start()
        renderer_started=type(status)=='string' and status:match('^running')~=nil
        debug('renderer start: '..tostring(status))
        if not renderer_started then say(tostring(status)) end
    end
    return renderer_started
end
local function subscribe()
    if not settings.enabled then return end
    requested_at=os.clock() source_wait_notice=false
    windower.send_command('lua c Skillchains targetsc subscribe')
    debug('requested Skillchains bridge v1 snapshot')
end
local function selected_mob()
    local info=windower.ffxi.get_info()
    if not info or not info.logged_in then return nil end
    local player=windower.ffxi.get_player()
    if not player or player.status==4 then return nil end
    local mob=windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('bt')
    if not mob or not mob.id or mob.id==0 or not mob.index or mob.index==0 or (mob.hpp or 0)<=0 then return nil end
    -- Validate both identity and rendering eligibility. Do not attach effects to
    -- a recycled entity index, a party member, an NPC lamp, or an untargetable mob.
    local live=windower.ffxi.get_mob_by_index(mob.index)
    if not live or live.id~=mob.id or live.valid_target==false then return nil end
    if not mob.is_npc or mob.in_party or mob.in_alliance or mob.charmed then return nil end
    if tonumber(mob.spawn_type)~=16 and (tonumber(mob.claim_id) or 0)==0 then return nil end
    return mob
end
local function help()
    local lines={
        {'on|off','Enable or disable resonance drawing.'},
        {'status','Report source, timing, tracking and native renderer state.'},
        {'preview [opener|pre|chain|window|expire|closed|demo] [property] [level]','Run one explicit local scenario.'},
        {'preview opener Liquefaction,Impaction','Compare multiple opening properties.'},
        {'motion flutter|sine|legacy','Select discrete, smooth or original motion.'},
        {'layout grounded|symmetric|center','Choose how the pair moves.'},
        {'flutter period|amplitude|damping <number>','Tune flutter: seconds, model-height fraction, decay/sec.'},
        {'width <1-8>','Minimum screen-pixel core width (default 2).'},
        {'brightness <0-4>','Core alpha multiplier (default 1).'},
        {'glow <0-3>','Surrounding light without thickening the core.'},
        {'discs on|off|opacity <0-1>','Control procedural ground property glyphs.'},
        {'preset vivid|gentle|legacy','Try a complete visual preset; preserves height/debug.'},
        {'preview off','End preview and return to live state.'},
        {'opacity <0-1>','Set translucent ring opacity (default 1).'},
        {'scale <0.25-3>','Scale the model-relative rings.'},
        {'intensity <0-4>','Set vibration and flash strength.'},
        {'height <0.25-3>','Adjust the model-height estimate.'},
        {'debug on|off','Record state events in data/TargetSC-debug.log.'},
        {'sync','Request an authoritative snapshot after missing events.'},
        {'restart','Unload and reload TargetSC safely.'},
        {'unload','Release the renderer and unload TargetSC.'},
        {'help','Show this command list.'},
    }
    windower.add_to_chat(0,('TargetSC 0.2.0 — elemental resonance'):color(167))
    for _,line in ipairs(lines) do
        windower.add_to_chat(0,('//tsc '):color(200)..line[1]:color(207)..(' -> '):color(200)..line[2]:color(0))
    end
end
local function status()
    local now=os.clock()
    say(('v%s; enabled=%s preview=%s source=%s synced=%s events=%d gaps=%d rejected=%d debug=%s'):format(
        _addon.version,tostring(settings.enabled),preview and (preview.kind..'/'..tostring(preview.phase or 'pre')) or 'off',model.connected and 'Skillchains v1' or 'waiting/absent',
        tostring(model.synced),model.events,model.gaps,model.rejected,tostring(settings.debug)))
    say(('opacity=%.2f scale=%.2f intensity=%.2f height=%.2f; target=%s; last tracking=%s; clock delta=%.3fs; unknown burst elements=%d'):format(
        settings.opacity,settings.scale,settings.intensity,settings.height,tostring(selected_id or 'none'),tostring(last_tracking_error or 'ok'),model.clock_warning,model.unknown_bursts))
    say(('motion=%s layout=%s period=%.3fs amplitude=%.3f damping=%.2f/s; width>=%.1fpx brightness=%.2f glow=%.2f discs=%s opacity=%.2f'):format(
        settings.motion,settings.layout,settings.period,settings.amplitude,settings.damping,settings.width,
        settings.brightness,settings.glow,tostring(settings.discs),settings.disc_opacity))
    local state=(preview and preview.model or model).states[selected_id]
    if state then say(('target revision=%d properties=%s; continuation=%.3fs (wait %.3fs); MB=%.3fs; closed=%s'):format(
        state.revision,table.concat(state.properties,'/'),state.closed and 0 or math.max(0,state.sc_close-math.max(now,state.sc_open)),math.max(0,state.sc_open-now),
        math.max(0,state.mb_close-now),tostring(state.closed))) end
    say(native and native.status() or 'Native module unavailable: '..tostring(renderer_error))
    if not model.connected then say('Load the compatible Skillchains folder, then //tsc sync. Preview remains available.') end
end
local function begin_preview(args)
    local mob=selected_mob()
    if not mob then say('Select a living enemy for preview.') return end
    if not settings.enabled then say('Use //tsc on first.') return end
    if not start_renderer() then return end
    local spec,err=previews.parse(args,resonance)
    if not spec then say(err..' See //tsc help.') return end
    local now=os.clock()
    preview=previews.new(spec,mob.id,now,resonance)
    selected_id=mob.id
    say('Preview '..table.concat(spec.properties,'/')..' level '..spec.level..'; '..preview.description)
    debug('preview begin target='..mob.id..' '..preview.description)
end
local function advance_preview(now)
    local prior=preview.phase
    if preview:advance(now) then preview=nil;debug('preview complete')
    elseif prior~=preview.phase then debug('preview phase '..tostring(preview.phase)) end
end
local function numeric_setting(key,value,low,high)
    local n=tonumber(value)
    if not n or n~=n or n<low or n>high then say(('Use //tsc %s <%s-%s>.'):format(key,low,high)) return end
    settings[key]=n config.save(settings) say(('%s = %.2f'):format(key,n))
end
windower.register_event('addon command',function(command,...)
    local args={...} command=(command or 'help'):lower()
    if command=='_event' then
        local accepted,why=model:receive(args,os.clock())
        if accepted then
            debug(('event %s seq=%s entity=%s clock_delta=%.6f'):format(tostring(why),tostring(args[3]),tostring(args[6]),model.clock_warning))
            if args[4]=='state' and preview and tonumber(args[6])==preview.id then preview=nil end
            if args[4]=='offline' or args[4]=='reset' then clear() preview=nil end
            if math.abs(model.clock_warning)>.20 then debug('TIMING WARNING: bridge latency/clock delta exceeds 200ms; absolute deadlines retained') end
        else debug('rejected event: '..tostring(why)) end
        if model.needs_sync and os.clock()-requested_at>1 then subscribe() end
    elseif command=='_ready' then if settings.enabled then subscribe() end
    elseif command=='help' then help()
    elseif command=='status' then status()
    elseif command=='sync' then subscribe() say('Requested Skillchains state.')
    elseif command=='on' then
        settings.enabled=true config.save(settings) start_renderer() subscribe() say('Enabled.')
    elseif command=='off' then
        settings.enabled=false config.save(settings) preview=nil clear()
        if native then native.stop() renderer_started=false end
        windower.send_command('lua c Skillchains targetsc unsubscribe')
        model:clear() model.connected=false say('Disabled.')
    elseif command=='preview' then
        if args[1] and args[1]:lower()=='off' then preview=nil clear() say('Preview stopped.')
        else begin_preview(args) end
    elseif command=='debug' then
        local option=(args[1] or ''):lower()
        if option~='on' and option~='off' then say('Use //tsc debug on|off.') return end
        settings.debug=option=='on' config.save(settings)
        if settings.debug then
            local f=io.open(addon_path..'data/TargetSC-debug.log','r')
            if f then log_size=f:seek('end') or 0 f:close() end
            debug('debug enabled; '..(native and native.status() or tostring(renderer_error)))
        end
        say('Debug '..option..'. Log: TargetSC/data/TargetSC-debug.log')
    elseif command=='opacity' then numeric_setting(command,args[1],0,1)
    elseif command=='scale' or command=='height' then numeric_setting(command,args[1],.25,3)
    elseif command=='intensity' then numeric_setting(command,args[1],0,4)
    elseif command=='width' then numeric_setting(command,args[1],1,8)
    elseif command=='brightness' then numeric_setting(command,args[1],0,4)
    elseif command=='glow' then numeric_setting(command,args[1],0,3)
    elseif command=='motion' or command=='layout' then
        local values=command=='motion' and {flutter=true,sine=true,legacy=true} or {grounded=true,symmetric=true,center=true}
        local value=(args[1] or ''):lower()
        if not values[value] then say('See //tsc help for '..command..' choices.') return end
        settings[command]=value;config.save(settings);say(command..' = '..value)
    elseif command=='flutter' then
        local key=(args[1] or ''):lower()
        if key=='period' then numeric_setting(key,args[2],.05,.5)
        elseif key=='amplitude' then numeric_setting(key,args[2],0,1)
        elseif key=='damping' then numeric_setting(key,args[2],0,8)
        else say('Use //tsc flutter period|amplitude|damping <number>.') end
    elseif command=='discs' then
        local value=(args[1] or ''):lower()
        if value=='opacity' then numeric_setting('disc_opacity',args[2],0,1)
        elseif value=='on' or value=='off' then settings.discs=value=='on';config.save(settings);say('Discs '..value..'.')
        else say('Use //tsc discs on|off|opacity <0-1>.') end
    elseif command=='preset' then
        local value=(args[1] or ''):lower()
        if value~='vivid' and value~='gentle' and value~='legacy' then say('Use //tsc preset vivid|gentle|legacy.') return end
        for key,v in pairs(resonance.defaults)do if key~='height' then settings[key]=v end end
        if value=='gentle' then settings.opacity=.7;settings.intensity=1;settings.amplitude=.16;settings.glow=.4
        elseif value=='legacy' then settings.motion='legacy';settings.discs=false;settings.scale=1;settings.opacity=.65;settings.intensity=.65;settings.width=1 end
        config.save(settings);say('Visual preset '..value..'. Height and debug preserved.')
    elseif command=='restart' or command=='unload' then
        say(command=='restart' and 'Restarting.' or 'Unloading.')
        clear() if native then native.stop() renderer_started=false end
        windower.send_command(command=='restart' and 'lua reload TargetSC' or 'lua unload TargetSC')
    else say('Unknown command: '..command) help() end
end)
windower.register_event('prerender',function()
    if not settings.enabled or not native or not renderer_started then return end
    local now=os.clock()
    if now<next_frame then return end
    next_frame=now+1/30
    -- Retry once the subscription throttle permits if the last event was the
    -- only one that revealed a gap. No request is sent during healthy frames.
    if model.needs_sync and now-requested_at>1 then subscribe() end
    if not model.connected and not source_wait_notice and now-requested_at>2 then
        source_wait_notice=true say('Waiting for compatible Skillchains. Load it, then //tsc sync; preview is available.')
    end
    local mob=selected_mob()
    local id=mob and mob.id
    if id~=selected_id then
        debug('target changed '..tostring(selected_id)..' -> '..tostring(id))
        if preview then preview=nil end
        selected_id=id clear()
    end
    if not mob then
        if not last_tracking_error then last_tracking_error='no living rendered enemy/cutscene/logged out' debug(last_tracking_error) end
        clear() return
    end
    last_tracking_error=nil
    if preview then advance_preview(now) end
    local radius,height=resonance.dimensions(mob,settings)
    local frame=(preview and preview.model or model):frame(id,now,radius,height,settings)
    native.begin(mob.index,mob.id)
    for _,disc in ipairs(frame.discs or {})do native.disc(disc.radius,disc.offset,disc.rotation,disc.color,disc.glyph) end
    for _,ring in ipairs(frame) do native.ring(ring.radius,ring.offset,ring.width,ring.color,ring.pixels or settings.width) end
    native.commit()
end)
windower.register_event('load',function()
    if settings.enabled then start_renderer() subscribe() end
end)
windower.register_event('zone change','logout',function()
    preview=nil selected_id=nil model:clear() clear() debug('world state cleared')
end)
windower.register_event('unload',function()
    windower.send_command('lua c Skillchains targetsc unsubscribe')
    clear() if native then native.stop() end
end)
