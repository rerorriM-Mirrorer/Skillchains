_addon.name='TargetSC'
_addon.author='A'
_addon.version='0.9.0-test9'
_addon.commands={'tsc','targetsc'}

require('chat')
local config=require('config')
local resonance=require('resonance')
local previews=require('resonance_preview')
local controls=require('resonance_controls')
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
    if version_ok and version=='0.5.0' and api_ok then native=result
    else renderer_error='Native API/version mismatch; expected TargetSC 0.5.0, received '..tostring(version) end
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
        {'display sc|mb|both|off','Choose continuation, MB opportunity/effects, or both.'},
        {'sky cutoff <0.05-1>','Descent fraction at which sky rings reach normal radius (default .55).'},
        {'sky curve <1-8>','Bell taper exponent (default 2).'},
        {'sky hold <0-2>','Seconds at full bell span after colors settle; 0 restores immediate descent.'},
        {'mb duration <0.2-4>','Burst-response duration in seconds; does not change the MB window.'},
        {'mb effects <0-1>','Overall MB animation strength; normal middle-ring opacity stays separate.'},
        {'mb ending <0.15-2>','Total closing interval before the MB deadline, including both styles when selected.'},
        {'mb ending style soft|hard|both|off','Strong/half/strong pulses, hard on/off flickers, or soft then hard.'},
        {'mb overall <0-1>','Master opacity for the middle ring, large MB glyph and MB flashes.'},
        {'mb intro <0-0.6>','Fresh MB-window white transition duration; 0 disables (default .24s).'},
        {'mb intro flashes 1|2','Synchronized property disc / large glyph / MB ring flashes (default 2).'},
        {'status','Report source, timing, tracking and native renderer state.'},
        {'preview [opener|pre|chain|window|expire|closed] [property] [level]','Run one explicit local scenario.'},
        {'preview burst [element]','Local MB response preview; no game actions or bridge events.'},
        {'preview demo','Five weaponskills: opener then L1/L2/L3/Umbra, no bursts.'},
        {'preview opener Liquefaction,Impaction','Compare multiple opening properties.'},
        {'motion flutter|sine|legacy','Select discrete, smooth or original motion.'},
        {'layout grounded|symmetric|center','Choose how the pair moves.'},
        {'strike period|amplitude|damping <number>','Strike: half-cycle seconds, world displacement, decay/sec. Also: flutter.'},
        {'hum amplitude|period|slowdown|gain <number>','Ground hum: displacement, half-cycle, slowing power, level gain.'},
        {'ground height <0-1>','Floor-ring anchor above model ground, in world units.'},
        {'discs height <0-0.5>','Independent glyph anchor above model ground; original default 0.008.'},
        {'sky expand <0-2>','Extra sky radius at the top of the bell; 0 disables.'},
        {'fade duration <0.1-1>','Fade existing rings in place after the source deadline.'},
        {'width <1-8>','Minimum screen-pixel core width (default 2).'},
        {'brightness <0-4>','Core alpha multiplier (default 4).'},
        {'glow <0-3>','Surrounding light without thickening the core.'},
        {'opener preset original|gap|black|muted|combined|quiet','Compare opener treatments without resetting other visuals.'},
        {'opener gap <0-60>|on|off','Two opposite opener gaps, each this many degrees; on=12.'},
        {'opener glow color|black|off','Opener surround color; uses the global glow strength.'},
        {'opener muted [on|off]','Quieter elemental hues on opener rings.'},
        {'discs on|off|opacity <0-1>','Control procedural ground property glyphs.'},
        {'discs outline <0-1>','Glyph line opacity independent of elemental fill.'},
        {'discs style glyph|outline|fill','Select filled glyph, outline only, or fill only.'},
        {'discs height|speed|slowdown <number>','Ground offset, starting-spin multiplier, slowing power.'},
        {'discs minimum <0-4>','MB-enabled property-disc idle spin before the global multiplier; default .5.'},
        {'discs speed opener|level1|level2|level3|level4 <0-4>','Initial turns/sec before the global speed multiplier.'},
        {'mb opacity <0-1>','Middle-ring starting opacity; grows toward full strength within mb overall.'},
        {'mb idle|burst <0-1>','Large glyph breathing / burst opacity; closing flashes use mb overall.'},
        {'mb floor|ring <0-1>','Confirmed-burst flash strength for floor disc / middle MB ring.'},
        {'mb period <0.2-6>','Large glyph full breathing cycle in seconds (default 2).'},
        {'mb rise|expand <0-2>','Burst glyph rise as model-height fraction / extra radial growth.'},
        {'awakening on|off|opacity <0-1>','Filled white opening glyph; MB breathing/burst controls are independent.'},
        {'preset default|discson|discsoff|vivid|gentle|legacy','Reset visual settings; default is your latest snapshot.'},
        {'preview off','End preview and return to live state.'},
        {'opacity <0-1>','Set translucent ring opacity (default 0.3).'},
        {'scale <0.25-3>','Scale the model-relative rings.'},
        {'intensity <0-4>','Set vibration and flash strength.'},
        {'height <0.25-3>','Adjust the model-height estimate.'},
        {'debug on|off','Record state events in data/TargetSC-debug.log.'},
        {'sync','Request an authoritative snapshot after missing events.'},
        {'restart','Unload and reload TargetSC safely.'},
        {'unload','Release the renderer and unload TargetSC.'},
        {'help','Show this command list.'},
    }
    windower.add_to_chat(0,('TargetSC 0.9.0 — elemental resonance'):color(167))
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
    say(('world strike amplitude=%.3f; ground height=%.3f; hum amplitude=%.3f period=%.3fs slowdown=%.2f gain=%.2f; fade=%.2fs'):format(
        settings.amplitude,settings.ground_height,settings.hum_amplitude,settings.hum_period,settings.hum_slowdown,settings.hum_gain,settings.fade_duration))
    say(('discs style=%s outline=%.2f height=%.3f speed=%.2f slowdown=%.2f; awakening=%s opacity=%.2f'):format(
        settings.disc_style,settings.disc_outline,settings.disc_height,settings.disc_speed,settings.disc_slowdown,tostring(settings.awakening),settings.awakening_opacity))
    say(('opener gap=%.1f degrees glow=%s muted=%s; L2=opposed two-color halves'):format(
        settings.opener_gap,settings.opener_glow,tostring(settings.opener_muted)))
    say(('initial turns/sec: opener=%.2f L1=%.2f L2=%.2f L3=%.2f L4=%.2f; MB opacity=%.2f'):format(
        settings.disc_speed_opener,settings.disc_speed_level1,settings.disc_speed_level2,
        settings.disc_speed_level3,settings.disc_speed_level4,settings.mb_opacity))
    say(('glyph anchor=%.3f; MB idle=%.2f burst=%.2f period=%.2fs rise=%.2f expand=%.2f; sky bell=%.2f'):format(
        settings.disc_height,settings.mb_idle,settings.mb_burst,settings.mb_period,settings.mb_rise,settings.mb_expand,settings.sky_expand))
    say(('display=%s; bell cutoff=%.2f curve=%.2f; MB response=%.2fs effects=%.2f ending=%.2fs'):format(
        settings.display,settings.sky_cutoff,settings.sky_curve,settings.mb_duration,settings.mb_effects,settings.mb_ending))
    say(('MB start=%.2f overall=%.2f ending style=%s; disc minimum=%.2f (before speed multiplier); sky hold=%.2fs'):format(
        settings.mb_opacity,settings.mb_overall,settings.mb_ending_style,settings.disc_minimum,settings.sky_hold))
    say(('MB intro=%.2fs / %d flashes; terminal star=black on white / white-gold on black, lifted .006'):format(
        settings.mb_intro,settings.mb_intro_flashes))
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
    preview=previews.new(spec,mob.id,now,resonance,settings)
    selected_id=mob.id
    say('Preview '..table.concat(spec.properties,'/')..' level '..spec.level..'; '..preview.description)
    debug('preview begin target='..mob.id..' '..preview.description)
end
local function advance_preview(now)
    local prior=preview.phase
    local stage=preview.stage
    if preview:advance(now) then preview=nil;debug('preview complete')
    else
        if stage~=preview.stage then say(preview.stage)end
        if prior~=preview.phase then debug('preview phase '..tostring(preview.phase))end
    end
end
local visual_command=controls.new(settings,resonance.defaults,config.save,say)
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
    elseif visual_command(command,args) then
        -- Visual handlers never alter source state or gameplay deadlines.
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
    for _,disc in ipairs(frame.discs or {})do
        local colors=disc.colors or {disc.color}
        native.disc(disc.radius,disc.offset,disc.rotation,disc.color,disc.glyph,disc.outline or 0,
            #colors,colors[2]or disc.color,colors[3]or disc.color,colors[4]or disc.color)
    end
    for _,ring in ipairs(frame) do
        local colors=ring.colors or {ring.color}
        native.ring(ring.radius,ring.offset,ring.width,ring.color,ring.pixels or settings.width,
            #colors,colors[2]or ring.color,colors[3]or ring.color,colors[4]or ring.color,ring.rotation or 0,ring.gap or 0)
    end
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
