_addon.name='TargetSC'
_addon.author='A'
_addon.version='0.14.9-unified-test4.9'
_addon.commands={'tsc','targetsc'}

require('chat')
local config=require('config')
local resonance=require('resonance')
local previews=require('resonance_preview')
local controls=require('resonance_controls')
local local_bus=require('targetsc_local')
local sc_runtime
-- frames: world animation update cadence (not a visual preset value).
-- classic = previous now+1/30; even = fixed 30 Hz grid; full = every frame.
local defaults={enabled=true,debug=false,frames='classic'}
for key,value in pairs(resonance.defaults)do defaults[key]=value end
local settings=config.load(defaults)
local model=resonance.new()
local native,renderer_error,renderer_started,native_version
local native_level=0
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
    -- 0.7.0 adds radial disc fills (inner/outer alpha, 12th/13th arguments).
    -- 0.6.0 adds optional smooth gradient discs (11th disc argument). 0.5.0
    -- remains accepted: gradients then use a four-step Lua approximation.
    -- 0.8.0 adds opener arc fades (ring arguments 13-16).
    -- 0.9.0 adds native.arc (opener sections) and a disc hub color (arg 14).
    -- 0.10.0 adds a middle radial stop on discs (args 15-16) and 16 discs.
    local levels={['0.10.0']=10,['0.9.0']=9,['0.8.0']=8,['0.7.0']=7,['0.6.0']=6,['0.5.0']=5}
    if version_ok and levels[version] and api_ok then native=result;native_version=version;native_level=levels[version]
    else renderer_error='Native API/version mismatch; expected TargetSC 0.10.0 (or 0.9.0-0.5.0), received '..tostring(version) end
    -- Older DLLs cannot draw section arcs; the layout falls back to rings.
    resonance.native_level=native_level
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
    if not local_bus.subscribe() then debug('Embedded Skillchains engine is not ready') end
    debug('refreshed embedded Skillchains state')
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
-- Previews only: your own character, when you target yourself, have nothing
-- targeted, or ask for `preview self`. Live resonance never draws on you.
local function self_mob()
    local info=windower.ffxi.get_info()
    if not info or not info.logged_in then return nil end
    local player=windower.ffxi.get_player()
    if not player or player.status==4 then return nil end
    local me=windower.ffxi.get_mob_by_target('me')
    if not me or not me.id or me.id==0 or not me.index or me.index==0 then return nil end
    local live=windower.ffxi.get_mob_by_index(me.index)
    if not live or live.id~=me.id then return nil end
    return me
end
local function targeting_self_or_nothing()
    local t=windower.ffxi.get_mob_by_target('t')
    if not t then return true end
    local me=windower.ffxi.get_mob_by_target('me')
    return me~=nil and t.id==me.id
end
local function help()
    local lines={
        {'on|off','Enable or disable resonance drawing.'},
        {'display sc|mb|both|off','Choose continuation, MB opportunity/effects, or both.'},
        {'sky cutoff <0.05-1>','Descent fraction at which sky rings reach normal radius (default .55).'},
        {'sky curve <1-8>','Bell taper exponent (default 2).'},
        {'sky hold <0-2>','Seconds at full bell span after colors settle; 0 restores immediate descent.'},
        {'mb duration <0.2-4>','Ring hit-flash timing; bloom/trace hold through it, then use mb return.'},
        {'mb effects <0-1>','Overall MB animation strength; normal middle-ring opacity stays separate.'},
        {'mb ending <0.15-2>','Total closing interval before the MB deadline, including both styles when selected.'},
        {'mb ending style soft|hard|both|off','Strong/half/strong pulses, hard on/off flickers, or soft then hard.'},
        {'mb overall <0-1>','Master opacity for the middle ring, large MB glyph and MB flashes.'},
        {'mb intro <0-0.6>','Fresh MB-window white transition duration; 0 disables (default .6s).'},
        {'mb intro flashes 1|2','Synchronized property disc / large glyph / MB ring flashes (default 1).'},
        {'status','Report source, timing, tracking and native renderer state.'},
        {'preview [opener|pre|chain|window|expire|closed] [property] [level]','Run one explicit local scenario.'},
        {'preview burst [element]','Local MB response preview; no game actions or bridge events.'},
        {'preview demo','Five weaponskills: opener then L1/L2/L3/Umbra, no bursts.'},
        {'preview mb','Same four links with Wind/Earth/Water/Dark bursts; includes late-link overlaps.'},
        {'preview mb light','Fusion nearly closed takes a Fire MB, Light opens; Light MB, then Wind as the ending begins.'},
        {'preview mb dark','Darkness: Ice then Dark MBs; Umbra late in the window; Ice, Earth, then Dark as the ending begins.'},
        {'mb style clapper|classic','Low breathing clapper / Test9 presentation comparison.'},
        {'ground lift <0-0.3>','Extra floor-ring clearance added to saved ground height (default .04).'},
        {'mb position|size <0-1>','Position between property and floor rings / size between their radii (default .5).'},
        {'mb breath min <0-1>','Breathing trough fraction of each layer peak (default .35).'},
        {'mb breath gain <0-8>','Large glyph breathing gain over saved idle opacity (default 3).'},
        {'mb spin <0-0.2>','Reverse large-glyph turns/sec, independent of disc speed (default .025).'},
        {'mb hold <0-0.6>','Minimum bloom/trace strike hold in seconds (default .6).'},
        {'mb return <0.1-2>','Shared bloom/trace return after hold/ring flashes (default 2s).'},
        {'mb lift <0-1>','Immediate property-trace lift in world units (default .3).'},
        {'sky descent <-4-4>','0=current; positive fast then slow, negative slow then fast; source deadline unchanged.'},
        {'mb shimmer <0-2>','Damped elemental glow strength; 0 disables (default 1).'},
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
        {'opener layout sections|rings','sections: properties share the circle (gaps 90/60/30), one stacked arc per element; rings: previous nested rings.'},
        {'opener spin slowdown <0-4>','How sharply the opener slows across its window; 0 = never (default 1, was 3).'},
        {'opener spin minimum <0-4>','Speed the opener eases toward instead of stopping, in discs speed units (default .5).'},
        {'opener spacing <0-0.2>','Height between stacked section arcs (default .035, like level 2 strands).'},
        {'opener fade <0-1>','Opener arcs fade from their bright end toward the tip; 0 = even (default .6).'},
        {'opener fade length <0.1-1>','Fraction of each arc the fade covers, from the tip (default 1).'},
        {'opener fade curve <0.5-3>','Fade shape: 1 even, >1 holds brightness longer, <1 drops early (default 1).'},
        {'opener fade lead|trail','Which end of each arc stays bright (default lead, facing the spin).'},
        {'opener fade glow <0-1>','How closely the opener glow band follows the arc fade (default 1).'},
        {'opener discs fade <inner 0-1> <outer 0-1>','Opener property-disc fill opacity at center/edge, as multipliers (default 1 1).'},
        {'opener discs outline <0-1>|same','Opener property-disc glyph line opacity; same = follow discs outline (default).'},
        {'opener discs size <0.2-2>','Opener property-disc fill size; glyph lines keep their size (default 1).'},
        {'discs on|off|opacity <0-1>','Control procedural ground property glyphs.'},
        {'discs outline <0-1>','Glyph line opacity independent of elemental fill.'},
        {'discs style glyph|outline|fill','Select filled glyph, outline only, or fill only.'},
        {'discs height|speed|slowdown <number>','Ground offset, starting-spin multiplier, slowing power.'},
        {'discs minimum <0-4>','MB-enabled property-disc idle spin before the global multiplier; default .5.'},
        {'discs speed opener|level1|level2|level3|level4 <0-4>','Initial turns/sec before the global speed multiplier.'},
        {'mb opacity <0-1>','Middle-ring starting opacity; grows toward full strength within mb overall.'},
        {'mb idle|burst <0-1>','Breathing base / release tail; clapper strike peaks at mb overall.'},
        {'mb floor|ring <0-1>','Confirmed-burst flash strength for floor disc / middle MB ring.'},
        {'mb period <0.2-6>','Large glyph full breathing cycle in seconds (default 2).'},
        {'mb rise|expand <0-2>','Burst glyph rise as model-height fraction / extra radial growth.'},
        {'awakening on|off|opacity <0-1>','Filled white opening glyph; MB breathing/burst controls are independent.'},
        {'awakening fade <inner 0-1> [outer 0-1]','Center/edge opacity of the white opening disc, as multipliers; outer defaults to 0 (default 1 0).'},
        {'awakening size <0.1-3>','White opening disc size; 1 = previous size (default 1).'},
        {'awakening fade until default|open|close|<1-9>','When the white disc finishes fading: as before, as the window opens, at window end, or N s after it opens.'},
        {'preset default|killala|discson|discsoff|vivid|gentle|legacy','Reset visuals. default = Test3 look; killala = exact pre-Test3 (Killala/Cioara) look.'},
        {'mb glyph height <0-2>','Burst rise of the large glyph as a fraction of the MB ring height; 1 = ring, 0 = old mb rise (default 1.1).'},
        {'mb glyph tint <0-1>','How much the large glyph takes the burst element color; 0 stays white (default 0).'},
        {'mb glyph after fade|fall','After a burst the large glyph stays risen and fades, or falls back as before (default fade).'},
        {'mb glyph rest hidden|breath','Large glyph at the floor: only the window-opening flash, or breathing as before (default hidden).'},
        {'mb glyph rise <0-1>','Seconds the large glyph takes to rise; 0 = instant like the trace (default .15).'},
        {'mb bloom [on|off]','Burst bloom: an element disc grows and fades from each confirmed MB (default on).'},
        {'mb bloom from ring|disc|glyph [to ring|disc|glyph|same]','Where the bloom starts, and optionally where it rises/sinks to (default ring).'},
        {'mb bloom size <start> [end]','Bloom growth in MB ring radii (default .3 to 1.5).'},
        {'mb bloom time <0.2-4>','Bloom lifetime in seconds (default 1).'},
        {'mb bloom ease <0.5-6>','Growth shape: higher = faster burst then slower spread (default 2.5).'},
        {'mb bloom fade <0.3-6>','Fade shape over its life: higher = fades sooner (default 1.5).'},
        {'mb bloom opacity <center> [middle] [edge]','Bloom opacity at three points, 0-1 each (default .7 .35 0; middle needs DLL 0.10.0).'},
        {'mb bloom middle <0.1-0.9>','Where the middle opacity point sits, as a fraction of the radius (default .5).'},
        {'mb bloom flash <0-1>','How white-hot it starts before settling into the element color (default .6).'},
        {'mb bloom core <0-1>','How white the center stays (default .5).'},
        {'mb bloom lines <0-4>','Copies of the glyph lines growing outward with it (default 0 = off).'},
        {'mb bloom lines opacity|delay|size <number>','Copy opacity 0-1 (.6), seconds between copies 0-0.5 (.12), final size 0.2-4 ring radii (1.8).'},
        {'mb intro glyph|disc <0-1>','New-MB-window white flash strength on the large glyph / property disc (default .5 / 1).'},
        {'discs fade <inner 0-1> <outer 0-1>','Link property-disc fill opacity at center/edge, all levels (default 1 1).'},
        {'discs size <0.2-2>','Link property-disc fill size; sigil lines keep theirs (default 1).'},
        {'discs size lines <0.2-2>','Link property-disc glyph lines (upper sigil) size (default 1).'},
        {'discs lightdark classic|elements','Light/Darkness discs: classic tones, or white/black center to four element colors (default classic).'},
        {'discs blend gradient|firm|split','Two-element discs: even fade, firm (each color holds, fade where they meet), or halves (default gradient).'},
        {'rings blend gradient|firm|split','SC rings: even fade, firm (colors hold, fade where they meet), or sectors; openers always split (default gradient).'},
        {'rings light white|elements|classic','Level 3 Light: white strands, inner glows in the four element colors; white MB ring (default white).'},
        {'rings light cycle <0.5-30>','Seconds for the inner glow colors to move down one ring (default 4).'},
        {'rings light glow <0-3>','Strength of the colored inner glows (default 1).'},
        {'rings light opening off|on','Light colored inner glows before its window opens: off rises to rings light glow as it opens (default off).'},
        {'rings light mb match|white','Light level 3 MB ring: match the lowest SC ring (white, lit side, rotation) or plain white (default match).'},
        {'rings lightdark classic|elements','Level 3 Darkness (and Light in its elements mode): outer strands, four element colors around the middle (default elements).'},
        {'rings lightdark spin <-2-2>','Middle (element) strand turn rate relative to the others; negative counter-turns (default 1).'},
        {'rings lightdark tint gold|white','Light level 3 glow color in the elements look (default white).'},
        {'rings lightdark cycle <0.25-6>','MB ring cycle speed through the four colors, x level 2 speed (default 2).'},
        {'rings spin disc|classic','disc: every link turns with the property disc, easing to its minimum; classic: only L2, slowing to a stop.'},
        {'rings shade <0-1>','Brighter/dimmer side that shows the ring turning; 0 = even (default .25).'},
        {'rings glow spin <0-4>','Glow rotation multiplier relative to its ring (default 1; try 2).'},
        {'mb glow shade <0-1>','Lit side on the two MB burst glows (uses rings blend gradient|firm; default .5).'},
        {'mb glow spin <-2-2>','Turns/sec added to each MB glow over its glyph; negative reverses (default .5).'},
        {'mb glow flicker <0-1>','9 Hz ripple on the MB glows; 1 original, 0 steady (default 1).'},
        {'mb glow width <0.2-2>','MB glow thickness multiplier (default 1).'},
        {'mb ending drop <0-1>','How far the MB ring settles onto the large glyph during the closing pulses (default 1).'},
        {'preview self [scenario]','Preview on your own character (also automatic when targeting yourself or nothing).'},
        {'preview off','End preview and return to live state.'},
        {'frames classic|even|full','World animation updates: previous 30 Hz, even 30 Hz steps, or every frame (default classic).'},
        {'opacity <0-1>','Set translucent ring opacity (default 0.3).'},
        {'scale <0.25-3>','Scale the model-relative rings.'},
        {'intensity <0-4>','Set vibration and flash strength.'},
        {'height <0.25-3>','Adjust the model-height estimate.'},
        {'debug on|off','Record state events in data/TargetSC-debug.log.'},
        {'sync','Refresh the shared combat state.'},
        {'sc <command>','Control Skillchains HUD and learning (e.g. //tsc sc help).'},
        {'restart','Unload and reload TargetSC safely.'},
        {'unload','Release the renderer and unload TargetSC.'},
        {'help','Show this command list.'},
    }
    windower.add_to_chat(0,('TargetSC '.._addon.version..' — elemental resonance'):color(167))
    for _,line in ipairs(lines) do
        windower.add_to_chat(0,('//tsc '):color(200)..line[1]:color(207)..(' -> '):color(200)..line[2]:color(0))
    end
end
local function status()
    local now=os.clock()
    say(('v%s; enabled=%s preview=%s source=%s synced=%s events=%d gaps=%d rejected=%d debug=%s'):format(
        _addon.version,tostring(settings.enabled),preview and (preview.kind..'/'..tostring(preview.phase or 'pre')) or 'off',model.connected and 'embedded Skillchains' or 'not synchronized',
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
    say(('Sky descent=%.2f: 0=original, positive=fast/slow, negative=slow/fast; hold and deadline preserved.'):format(settings.sky_descent))
    say(('MB start=%.2f overall=%.2f ending style=%s; disc minimum=%.2f (before speed multiplier); sky hold=%.2fs'):format(
        settings.mb_opacity,settings.mb_overall,settings.mb_ending_style,settings.disc_minimum,settings.sky_hold))
    say(('MB intro=%.2fs / %d flashes; terminal star=black on white / white-gold on black, lifted .006'):format(
        settings.mb_intro,settings.mb_intro_flashes))
    say(('MB style=%s size=%.2f position=%.2f reverse=%.3f turns/s breath min=%.2f gain=%.2f; floor lift=%.3f'):format(
        settings.mb_style,settings.mb_size,settings.mb_position,settings.mb_spin,settings.mb_breath_min,settings.mb_breath_gain,settings.ground_lift))
    say(('MB hold=%.2fs return=%.2fs trace lift=%.3f shimmer=%.2f; large release tail strength=%.2f'):format(
        settings.mb_hold,settings.mb_return,settings.mb_lift,settings.mb_shimmer,settings.mb_burst))
    local state=(preview and preview.model or model).states[selected_id]
    if state then say(('target revision=%d properties=%s; continuation=%.3fs (wait %.3fs); MB=%.3fs; closed=%s'):format(
        state.revision,table.concat(state.properties,'/'),state.closed and 0 or math.max(0,state.sc_close-math.max(now,state.sc_open)),math.max(0,state.sc_open-now),
        math.max(0,state.mb_close-now),tostring(state.closed))) end
    say(native and native.status() or 'Native module unavailable: '..tostring(renderer_error))
    if not model.connected then say('Embedded Skillchains not synchronized; use //tsc sync. Preview remains available.') end
end
local function begin_preview(args)
    local on_self=args[1]and (args[1]:lower()=='self'or args[1]:lower()=='me')
    if on_self then table.remove(args,1)end
    local mob=not on_self and selected_mob()
    if not mob and (on_self or targeting_self_or_nothing())then mob=self_mob();on_self=mob~=nil end
    if not mob then say('Select a living enemy, target yourself, or use //tsc preview self.') return end
    if not settings.enabled then say('Use //tsc on first.') return end
    if not start_renderer() then return end
    local spec,err=previews.parse(args,resonance)
    if not spec then say(err..' See //tsc help.') return end
    local now=os.clock()
    preview=previews.new(spec,mob.id,now,resonance,settings)
    preview.on_self=on_self
    selected_id=mob.id
    say('Preview '..table.concat(spec.properties,'/')..' level '..spec.level..(on_self and ' on yourself' or '')..'; '..preview.description)
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
local visual_command=controls.new(settings,resonance.defaults,config.save,say,resonance.killala)
local function receive_frame(args)
    local accepted,why=model:receive(args,os.clock())
    if accepted then
        debug(('event %s seq=%s entity=%s clock_delta=%.6f'):format(tostring(why),tostring(args[3]),tostring(args[6]),model.clock_warning))
        if args[4]=='state' and preview and tonumber(args[6])==preview.id then preview=nil end
        if args[4]=='offline' or args[4]=='reset' then clear() preview=nil end
        if math.abs(model.clock_warning)>.20 then debug('TIMING WARNING: source clock delta exceeds 200ms; absolute deadlines retained') end
    else debug('rejected event: '..tostring(why)) end
    if model.needs_sync and os.clock()-requested_at>1 then subscribe() end
end
local_bus.set_receiver(receive_frame)
windower.register_event('addon command',function(command,...)
    local args={...} command=(command or 'help'):lower()
    if command=='_event' then
        -- Legacy test/protocol entry point; live traffic uses the direct local bus.
        receive_frame(args)
    elseif command=='sc' then
        if sc_runtime then
            sc_runtime.command(args[1] or 'help',unpack(args,2))
        else say('Embedded Skillchains engine is not ready.') end
    elseif command=='_ready' then if settings.enabled then subscribe() end
    elseif command=='help' then help()
    elseif command=='status' then status()
    elseif command=='sync' then subscribe() say('Refreshed embedded Skillchains state.')
    elseif command=='on' then
        settings.enabled=true config.save(settings) start_renderer() subscribe() say('Enabled.')
    elseif command=='off' then
        settings.enabled=false config.save(settings) preview=nil clear()
        if native then native.stop() renderer_started=false end
        local_bus.unsubscribe()
        model:clear() model.connected=false say('Disabled.')
    elseif command=='preview' then
        if args[1] and args[1]:lower()=='off' then preview=nil clear() say('Preview stopped.')
        else begin_preview(args) end
    elseif command=='frames' then
        local mode=(args[1]or ''):lower()
        if mode~='classic'and mode~='even'and mode~='full'then
            say('Frames '..tostring(settings.frames)..'. Use //tsc frames classic|even|full.') return
        end
        settings.frames=mode config.save(settings)
        say('Frames '..mode..({classic=' (previous 30 Hz).',even=': even 30 Hz steps.',full=': every game frame (more CPU).'})[mode])
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
    -- even: 2 ms tolerance so frame-time jitter landing a hair early does
    -- not skip a beat (which would make a 3-frame step).
    if now<next_frame-(settings.frames=='even'and .002 or 0)then return end
    if settings.frames=='full'then next_frame=0
    elseif settings.frames=='even'then
        -- Fixed 1/30 s grid: a 60 fps client updates every other frame
        -- evenly instead of alternating 2- and 3-frame steps.
        next_frame=next_frame+1/30
        if next_frame<=now then next_frame=now+1/30 end
    else next_frame=now+1/30 end
    -- Retry once the subscription throttle permits if the last event was the
    -- only one that revealed a gap. No request is sent during healthy frames.
    if model.needs_sync and now-requested_at>1 then subscribe() end
    if not model.connected and not source_wait_notice and now-requested_at>2 then
        source_wait_notice=true say('Waiting for compatible Skillchains. Load it, then //tsc sync; preview is available.')
    end
    -- A self preview keeps drawing on you whatever you target meanwhile.
    local mob=(preview and preview.on_self)and self_mob()or selected_mob()
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
        local blend=disc.blend or 0
        if native_version=='0.5.0'then
            -- Older DLL has no gradient: approximate two colors with
            -- A | A+B | B | A+B; three or four colors stay as sectors.
            if blend==1 and #colors==2 then
                local middle=resonance.mix_argb(colors[1],colors[2])
                colors={colors[1],middle,colors[2],middle}
            end
            blend=0
        end
        local inner,outer=disc.inner or 1,disc.outer or 1
        if native_level<7 and (inner~=1 or outer~=1)then
            -- Pre-0.7.0 DLL has no radial fill: use the average, evenly.
            local k=(inner+outer)/2
            for i,c in ipairs(colors)do colors[i]=resonance.scale_alpha(c,k)end
        end
        if native_level>=10 and disc.mid then
            -- 0.10.0 middle radial stop (burst bloom): hub -1 = averaged center.
            native.disc(disc.radius,disc.offset,disc.rotation,colors[1]or disc.color,disc.glyph,disc.outline or 0,
                #colors,colors[2]or disc.color,colors[3]or disc.color,colors[4]or disc.color,blend,inner,outer,
                disc.hub or -1,math.max(0,math.min(1,disc.mid)),math.max(.05,math.min(.95,disc.mid_pos or .5)))
        elseif native_level>=9 and disc.hub then
            -- 0.9.0 hub (center) color, e.g. Light/Darkness 'elements' discs.
            native.disc(disc.radius,disc.offset,disc.rotation,colors[1]or disc.color,disc.glyph,disc.outline or 0,
                #colors,colors[2]or disc.color,colors[3]or disc.color,colors[4]or disc.color,blend,inner,outer,disc.hub)
        elseif native_level>=7 then
            native.disc(disc.radius,disc.offset,disc.rotation,colors[1]or disc.color,disc.glyph,disc.outline or 0,
                #colors,colors[2]or disc.color,colors[3]or disc.color,colors[4]or disc.color,blend,inner,outer)
        else
            native.disc(disc.radius,disc.offset,disc.rotation,colors[1]or disc.color,disc.glyph,disc.outline or 0,
                #colors,colors[2]or disc.color,colors[3]or disc.color,colors[4]or disc.color,blend)
        end
    end
    for _,ring in ipairs(frame) do
      if ring.kind=='arc'then
        if native_level>=9 then
            native.arc(ring.radius,ring.offset,ring.width,ring.color,ring.tail,ring.pixels or settings.width,
                ring.rotation or 0,ring.arc_start,ring.arc_span,ring.fade or 0,ring.fade_length or 1,
                ring.fade_curve or 1,ring.fade_direction or 1)
        end
      else
        local colors=ring.colors or {ring.color}
        local blend=ring.blend or 0
        if native_version=='0.5.0'then
            -- Same four-step fallback as discs on the older DLL.
            if blend==1 and #colors==2 then
                local middle=resonance.mix_argb(colors[1],colors[2])
                colors={colors[1],middle,colors[2],middle}
            end
            blend=0
        end
        if native_level>=8 and (ring.fade or 0)>0 then
            native.ring(ring.radius,ring.offset,ring.width,colors[1]or ring.color,ring.pixels or settings.width,
                #colors,colors[2]or ring.color,colors[3]or ring.color,colors[4]or ring.color,ring.rotation or 0,ring.gap or 0,blend,
                ring.fade,ring.fade_length or 1,ring.fade_curve or 1,ring.fade_direction or 1)
        else
            -- No arc fade (or a pre-0.8.0 DLL): today's even arcs, exactly.
            native.ring(ring.radius,ring.offset,ring.width,colors[1]or ring.color,ring.pixels or settings.width,
                #colors,colors[2]or ring.color,colors[3]or ring.color,colors[4]or ring.color,ring.rotation or 0,ring.gap or 0,blend)
        end
      end
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
    local_bus.unsubscribe()
    clear() if native then native.stop() end
end)

-- One-time, non-destructive import of the previous companion's complete XML,
-- including character-specific sections. Never overwrite integrated data.
local function import_skillchains_settings()
    local destination=addon_path..'data/skillchains-settings.xml'
    local present=io.open(destination,'rb')
    if present then present:close() return end
    local original=io.open(addon_path..'../Skillchains/data/settings.xml','rb')
    if not original then return end
    local bytes=original:read('*a') original:close()
    if not bytes or #bytes>2097152 or not bytes:find('<',1,true) then return end
    local dir=addon_path..'data/'
    if not windower.dir_exists(dir) then windower.create_dir(dir) end
    local output=io.open(destination,'wb')
    if output then output:write(bytes) output:close() debug('imported legacy Skillchains settings') end
end
import_skillchains_settings()
sc_runtime=require('sc_runtime')
