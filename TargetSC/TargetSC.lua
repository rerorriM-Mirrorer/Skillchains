_addon.name='TargetSC'
_addon.author='A'
_addon.version='0.19.0-unified-test7.0'
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
-- Test5.0 target handoff (see handoff() below the commands).
local shown,outgoing,incoming
local kill_angle -- 0.18 (defined with the hand-off helpers; used when a kill event arrives)
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
    -- 0.11.0 adds native.glyph (3D property glyph for the Umbra endings).
    -- 0.12.0 adds native.shift (sideways offsets) and native.line (kill seams).
    local levels={['0.12.0']=12,['0.11.0']=11,['0.10.0']=10,['0.9.0']=9,['0.8.0']=8,['0.7.0']=7,['0.6.0']=6,['0.5.0']=5}
    if version_ok and levels[version] and api_ok then native=result;native_version=version;native_level=levels[version]
    else renderer_error='Native API/version mismatch; expected TargetSC 0.12.0 (or 0.11.0-0.5.0), received '..tostring(version) end
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
        {'mb ending <0.15-3>','Total closing interval before the MB deadline, including both styles when selected.'},
        {'mb ending style soft|hard|both|converge|off','Strong/half/strong pulses, hard on/off flickers, soft then hard, or converge (ring descends and brightens onto the emerging glyph).'},
        {'mb overall <0-1>','Master opacity for the middle ring, large MB glyph and MB flashes.'},
        {'mb intro <0-0.6>','Fresh MB-window white transition duration; 0 disables (default .6s).'},
        {'mb intro flashes 1|2','Synchronized property disc / large glyph / MB ring flashes (default 1).'},
        {'status','Report source, timing, tracking and native renderer state.'},
        {'preview [opener|pre|chain|window|expire|closed] [property] [level]','Run one explicit local scenario.'},
        {'preview burst [element]','Local MB response preview; no game actions or bridge events.'},
        {'preview demo','Five weaponskills: opener then L1/L2/L3/Umbra, no bursts.'},
        {'preview mb','Same four links with Wind/Earth/Water/Dark bursts; includes late-link overlaps.'},
        {'preview switch [preview]','The preview rides on the first two targets you pick (enemies or yourself) to try target handoffs.'},
        {'preview off','Stops a preview; it dims away like an untarget.'},
        {'mb radiance light|classic','Radiance MB ring like a level-3 Light middle ring (white, colored inner glow) or classic (default light).'},
        {'mb radiance glow <0-3>','Strength of that colored glow (default 3).'},
        {'mb radiance cycle <0.05-8>','Seconds per color shift of the glow (default .4 = fast).'},
        {'radiance opacity <0-1|same>','Radiance rings/glows/disc lines use this instead of the overall opacity (same = overall).'},
        {'radiance disc opacity <0-1|same>','Radiance disc fill, ignoring overall and discs opacity (same = as before).'},
        {'radiance look open|classic','open: rings keep their opening white; classic: turn gold (default open).'},
        {'radiance close sequence|classic | close time <0.3-6>','Rings close one at a time over this many seconds (default sequence, 3).'},
        {'radiance order lower|upper|together | direction inner|outer','Which set closes first, and from which strand (default lower, inner).'},
        {'radiance lead|fade|flash <number>','Each glow flashes (flash 0-3, 1.5) and goes out lead s (.2) before its ring fades over fade s (.5).'},
        {'radiance shimmer <0-1>','Bright patch traveling around each glow, far side to near side and back (default .6; 0 = off).'},
        {'radiance shimmer time|stagger|angle <number>','Seconds per sweep (2), offset per ring 0-1 (.12), angle offset -180..180 to aim the far side (0).'},
        {'radiance shimmer when close|all | shimmer mb on|off','Shimmer only while closing or the whole time (close); MB ring joins (on).'},
        {'radiance open time <0-8|same>','Visual length of the Radiance opening (same = the game timing, about 3 s; MB timing unchanged).'},
        {'radiance sky bell|off','Radiance sky rings flared like a bell (default) or off (one set of rings).'},
        {'radiance disc lines on|off','The Radiance disc\'s own glyph lines (default off; the large MB glyph breathes instead).'},
        {'radiance glyph breath|same','Radiance large MB glyph breathes at rest and never turns (default breath).'},
        {'radiance glyph size|opacity <number|same> | glyph buzz on|off','Its size (1), opacity replacing mb overall (same), buzzing with the rings (on).'},
        {'radiance glyph circle on|off','The circle around the Radiance floor glyph (default on; off needs native 0.11.0).'},
        {'radiance glyph wobble rings|always','Glyph wobble follows the ground rings (default) or keeps going through the MB window and exit fade.'},
        {'radiance stack on|off','Three-disc stack: white bottom, Fusion<->Fragmentation middle, the white disc on top (default on).'},
        {'radiance stack height|spacing <number>','Raise/lower all three (0), gap between them (.01).'},
        {'radiance bottom opacity|size <number>','Bottom white disc: direct opacity 0-1 (.6), size x level-4 disc size (1).'},
        {'radiance middle opacity|size|cycle|spin <number>','Middle disc: opacity (.5), size (1), seconds Fusion->Fragmentation->Fusion (4), turn x level-4 speed (1).'},
        {'umbra open time <0-8|same>','Visual length of the Umbra opening (same = game timing).'},
        {'umbra after bloom|smoke|off','After the flash-out: one ring-shaped black bloom (default), per-ring smoke, or nothing.'},
        {'umbra bloom opacity|time|size|growth <number>','Bloom opacity (.6), seconds (2.5), start size in SC ring radii (1), growth -1..2 (<0 shrinks, 0 stays, >0 grows; -.5).'},
        {'umbra bloom height rings|ground|disc|mb','rings: one bloom at each SC ring height (default); or one at the ground ring / disc / MB ring. Shape: mb bloom opacity/middle/ease/fade.'},
        {'umbra mb pulse|classic | mb strength <0-1> | mb size <0.2-4>','Umbra MB ring: white ending-style pulses all window (default pulse, 1), its size (1).'},
        {'umbra spin <0-6|same>','Umbra\'s own level-4 spin, beyond discs speed level4 (same = that).'},
        {'umbra sky same|bell|off','Sky rings the same size as the ground rings (default same), flared like a bell, or off (one set of rings).'},
        {'umbra glyph breath|same','Umbra large MB glyph breathes at rest at the disc\'s exact height, sized like the Umbra MB ring (default breath).'},
        {'umbra glyph size|opacity|spin <number> | glyph over on|off','Size x MB ring (1), opacity (same), turn x level-4 speed (1), draw it over the disc (off).'},
        {'umbra under on|off','A second turning disc just under the black one, fading Gravitation <-> Distortion (default off).'},
        {'umbra under opacity|size|spin|cycle|depth <number>','Its opacity (.6), size x the black disc (1), turn x the disc (1), seconds per fade (4), distance below (.01).'},
        {'umbra under direction same|reverse | under center|edge <0-1>','Its turn direction (same); center and edge opacity (1, 0).'},
        {'umbra haze on|off','A flickering white smoke bloom held at the MB ring height all MB window (default off).'},
        {'umbra haze opacity|size|flicker|speed <number> | haze center|edge <0-1>','Opacity (.3), size x the Umbra MB ring (1.3), flicker depth 0-1 (.5), flicker speed (1), center/edge (.6, 0).'},
        {'umbra copies on|off','Glyph copies growing out just under the disc through the opening (default on).'},
        {'umbra copies every|life|size|opacity|spin|depth <number>','New copy every .6 s, each lasting 1.2 s, growing to 1.6x, opacity .5, spin 1, .004 under the disc.'},
        {'umbra lines size <0.2-4|same> | lines opacity <0-1|same>','The disc\'s own glyph lines: size x the Umbra MB ring (same = disc size), direct opacity.'},
        {'umbra disc inner|middle|outer|position <number|same>','Umbra-only disc shape (same = discs level4).'},
        {'umbra disc steady on|off','Keep the black disc solid through window-opening and burst flashes (default on).'},
        {'umbra core <0-1|same> | flicker <0-1>','Ring cores\' direct opacity (same = opacity x brightness); flicker depth (.28).'},
        {'umbra ending off|gyro|swallow','Ending for the disc glyph (DLL 0.11.0): gyro = upright spinning; swallow = segments stand and sink in.'},
        {'umbra ending when open|mb|flash | ending time <s>','From Umbra\'s opening for ending time, during the MB ending (default), or from the flash-out for ending time (2; up to 12, always ending by the MB deadline).'},
        {'umbra lines color white|cream','The disc glyph (and its ending) pure white (default) or the old cream.'},
        {'umbra collapse on|off','Ending: everything shrinks to the center in the last seconds; MB ring does not sink, disc stays opaque (default on).'},
        {'umbra collapse curve <1-10> | collapse time <s|same>','Higher = slower start, sharper whoosh (4); seconds (same = mb ending).'},
        {'umbra glyph lift <0-0.2|same>','Floor glyph always this far above the black disc (.004; same = rises on bursts).'},
        {'umbra mb height ring|disc','Umbra MB ring at its usual height or exactly at the black disc\'s plane.'},
        {'umbra gyro speed|rise|shrink <number> | gyro below full|half','Turns/s (1.5), seconds to stand (.4), last share shrinking away (.5); half cuts the lower dome.'},
        {'umbra stand time|sink time <s>','Swallow: seconds to stand up (.5, up to 8), seconds to sink in at the end (1, up to 10).'},
        {'umbra swallow stagger|pull|lift <number> | swallow order outer|inner|together','Spread (.5), pull to center (.3), height x half the longest (1); who goes first (outer).'},
        {'umbra disc size <0.2-10|same>','Umbra disc size, beyond discs level4 size (same = that).'},
        {'umbra opacity|disc opacity <0-1|same>','Umbra rings/glows and disc fill, ignoring the overall opacity (1 = total black).'},
        {'umbra look black|classic | glow white|violet','Black cores from the opening and a white glow (default black, white).'},
        {'umbra close sequence|classic | close time <0-6>','Hold this long after opening, then each ring flashes white and vanishes (default sequence, 3).'},
        {'umbra order upper|lower|together | direction outer|inner','Which set goes first, and from which strand (default upper, outer).'},
        {'umbra gap|flash|flash time <number>','Seconds between rings (.12), flash strength 0-1 (.6), flash length (.08).'},
        {'umbra smoke|smoke opacity|smoke spread <number>','Leftover black glow: seconds (1.5), strength 0-2 (.5), spread while dissipating 0-.3 (.05).'},
        {'discs level4 inner|middle|outer <0-1|same>','Radiance/Umbra property disc opacity at center, middle point, edge (same = discs setting; middle same = none).'},
        {'discs level4 position <0.05-0.95>','Where the middle point sits along the radius (default .5; needs DLL 0.10.0).'},
        {'discs level4 size <0.2-3|same>','Radiance/Umbra disc size (fill and lines), same = discs size.'},
        {'discs level4 height <-0.2-0.5>','Raise or lower the Radiance/Umbra disc (default 0).'},
        {'detarget time <0-3>','Untarget/ordinary death: the animation keeps running and dims over this many seconds (default 1; 0 = instant).'},
        {'switch out <0-1>','Switching to an enemy with resonance: seconds the old one takes to fade (default .25).'},
        {'switch in <0-1>','Then the new enemy fades in over this many seconds (default .35).'},
        {'preview kill mb [element] | preview kill sc','Try the kill animations: an MB (default Fire) or an SC weapon skill defeats the target.'},
        {'kill on|off','Kill animations when Skillchains reports the SC weapon skill or MB itself defeated the target (default on).'},
        {'kill time <0.3-5>','Length of either kill animation (1.6 s).'},
        {'kill mb gather|mb curve <number>','MB kill: seconds for the SC rings to gather at the MB ring (.35); collapse curve (4).'},
        {'kill bloom delay|time|size|opacity <number>','MB kill second bloom: after the MB\'s own (.15 s), lasting 1.2 s, to 2x MB ring, opacity .8.'},
        {'kill sc freeze|split|turn|sag <number>','SC kill: freeze .2 s after the kill, halves drift .12 x radius, turn .15 rad ccw, sky halves sag .3 of the bell.'},
        {'kill sc flash|seam|ghost <number> | kill seam angle <deg>','Glyph flash-out (.08 s), seam flash (.35 s), ghost white opacity (.85); aim the seam (0).'},
        {'preview umbra','A Darkness window about to close is closed by Umbra; plays the full Umbra animation (old four-link demo: preview demo).'},
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
        {'awakening links on|off','Play the white disc again on every link that opens a new window (default on).'},
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
        {'mb ending shrink <0-1>','Converge only: ring and large glyph shrink toward the property glyph size (default 0).'},
        {'mb ending fade <0-1>','Converge only: seconds the converged ring and glyph take to fade out after the MB deadline (default .4).'},
        {'mb ending blooms fade|linger','fade: blooms go out with the MB ending; linger: blooms carry on past the deadline and fade over mb ending fade (any style).'},
        {'preview self [scenario]','Preview on your own character (also automatic when targeting yourself or nothing).'},
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
    -- Test5.0: `preview switch [preview...]` lends the preview's resonance to
    -- the first two targets you pick (enemies, or yourself), to try the
    -- target handoff. Default: the four-link MB demo.
    local switch=args[1]and args[1]:lower()=='switch'
    if switch then table.remove(args,1)if not args[1]then args={'mb'}end end
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
    if switch then preview.switch,preview.carriers,preview.count=true,{[mob.id]=true},1 end
    selected_id=mob.id
    shown,outgoing,incoming=nil,nil,nil
    say('Preview '..table.concat(spec.properties,'/')..' level '..spec.level..(on_self and ' on yourself' or '')..
        (switch and ' (switch: the first two targets you pick carry it)' or '')..'; '..preview.description)
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
        -- A real state replaces a preview that is still dimming away on that target.
        if args[4]=='state' and outgoing and outgoing.preview and tonumber(args[6])==outgoing.id then outgoing=nil end
        if args[4]=='offline' or args[4]=='reset' then clear() preview=nil shown,outgoing,incoming=nil,nil,nil end
        if args[4]=='kill'then
            local id=tonumber(args[6])
            local k=model.kills[id]
            if k then
                k.angle=kill_angle(k,id)
                -- The defeat may land after the death already started a plain fade.
                local now=os.clock()
                if settings.kill and outgoing and outgoing.id==id and not outgoing.kill then
                    outgoing.kill,outgoing.start,outgoing.level,outgoing.duration=true,now,1,settings.kill_time+.05
                end
            end
        end
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
        settings.enabled=false config.save(settings) preview=nil shown,outgoing,incoming=nil,nil,nil clear()
        if native then native.stop() renderer_started=false end
        local_bus.unsubscribe()
        model:clear() model.connected=false say('Disabled.')
    elseif command=='preview' then
        if args[1] and args[1]:lower()=='off' then
            -- Test5.0: the preview leaves like an untarget, dimming over `detarget time`.
            if preview and shown and shown.preview==preview and shown.mob and settings.detarget_time>0 then
                outgoing={id=shown.id,index=shown.mob.index,mob=shown.mob,preview=preview,start=os.clock(),
                    level=shown.level,duration=settings.detarget_time*shown.level}
                incoming,shown=nil,nil
            else clear() end
            preview=nil say('Preview stopped.')
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
-- Test5.0 target handoff state. `shown` = the target drawn last frame with
-- resonance; `outgoing` = a previous target fading out; `incoming` = the
-- new target's fade-in (after any outgoing fade ends); declared at the top.
local function world_blocked()
    local info=windower.ffxi.get_info()
    if not info or not info.logged_in then return true end
    local player=windower.ffxi.get_player()
    return not player or player.status==4
end
local function targeting_self()
    local t=windower.ffxi.get_mob_by_target('t')
    local me=windower.ffxi.get_mob_by_target('me')
    return t~=nil and me~=nil and t.id==me.id
end
-- A switch preview lends its resonance to the first two targets you pick;
-- other previews belong to the target they started on.
local function carries(p,id)
    if p.switch then return p.carriers[id]==true end
    return p.id==id
end
-- Test5.2: approximate camera direction for the Radiance shimmer: from you
-- toward the target (the far side of its rings); 0 on yourself.
local function view_toward(mob)
    local me=windower.ffxi.get_mob_by_target('me')
    if me and mob and me.id~=mob.id and mob.x and me.x and mob.y and me.y then
        resonance.view_angle=math.atan2(mob.y-me.y,mob.x-me.x)
    else resonance.view_angle=0 end
end
local function frame_for(id,now,radius,height,p)
    if p and carries(p,id)then return p.model:frame(p.id,now,radius,height,settings)end
    return model:frame(id,now,radius,height,settings)
end
local function current_mob()
    if preview and preview.switch then
        local mob=selected_mob()
        if mob then return mob end
        if targeting_self()then return self_mob()end
        return nil
    end
    -- A self preview keeps drawing on you whatever you target meanwhile.
    if preview and preview.on_self then return self_mob()end
    return selected_mob()
end
local function level_of(o,now)
    -- A kill plays at full strength (the kill animation does its own fading).
    if o.kill then return now<o.start+o.duration and 1 or 0 end
    return o.level*(1-math.min(1,(now-o.start)/math.max(o.duration,1e-6)))
end
-- TargetSC 0.18 kills: a recent SC/MB kill of this enemy replaces its detarget fade.
local function recent_kill(id,now)
    local k=settings.kill and model.kills[id]
    return k and now-k.at>=-.1 and now-k.at<1.5 and k or nil
end
-- Seam direction for the SC kill: from the killer toward the target.
kill_angle=function(k,id)
    local by_id=windower.ffxi.get_mob_by_id
    if not by_id then return 0 end
    local actor=k.actor and k.actor>0 and by_id(k.actor)
    local target=by_id(id)
    if actor and target and actor.x and target.x and actor.id~=target.id then
        return math.atan2(target.y-actor.y,target.x-actor.x)
    end
    return 0
end
local function has_resonance(id,mob,now)
    if not mob then return false end
    local radius,height=resonance.dimensions(mob,settings)
    local f=frame_for(id,now,radius,height,preview)
    return #f>0 or #(f.discs or {})>0
end
-- Untarget/ordinary death: the last target keeps animating as normal while
-- it dims over `detarget time`. Switching to a target that has resonance
-- uses the quick `switch out`, then the new one fades in over `switch in`.
local function handoff(id,mob,now,blocked)
    local p=preview
    if p and p.switch and mob and not p.carriers[id] and p.count<2 then p.carriers[id]=true;p.count=p.count+1 end
    if p and not p.switch then preview=nil end
    local new_has=not blocked and has_resonance(id,mob,now)
    incoming=nil
    if outgoing and outgoing.id==id then
        -- Back to the enemy that is fading: brighten from where it is (a
        -- preview fading away on it comes back too).
        local level=level_of(outgoing,now)
        if outgoing.preview and not preview then preview=outgoing.preview end
        outgoing=nil
        if settings.switch_in>0 then incoming={start=now,duration=settings.switch_in*(1-level),from=level}end
        shown=nil return
    end
    if blocked then outgoing,shown=nil,nil return end
    if outgoing then
        if new_has then
            local level=level_of(outgoing,now)
            outgoing.start,outgoing.level,outgoing.duration=now,level,settings.switch_out*level
        end
    elseif shown and shown.id==selected_id and shown.mob and shown.mob.index then
        local duration=(new_has and settings.switch_out or settings.detarget_time)*shown.level
        local killed=recent_kill(shown.id,now)
        if killed then
            outgoing={id=shown.id,index=shown.mob.index,mob=shown.mob,preview=shown.preview,start=now,level=1,
                duration=settings.kill_time+.05,kill=true}
        elseif duration>0 then
            outgoing={id=shown.id,index=shown.mob.index,mob=shown.mob,preview=shown.preview,start=now,level=shown.level,duration=duration}
        end
    end
    shown=nil
    if new_has and settings.switch_in>0 then
        incoming={start=outgoing and outgoing.start+outgoing.duration or now,duration=settings.switch_in,from=0}
    end
end
-- Test5.0 target handoff: the frame is sent at `level` (0-1) by scaling
-- every color's alpha; the animation itself runs exactly as normal.
local function dim(c,level)
    if type(c)~='number'or level>=1 then return c end
    return resonance.scale_alpha(c,level)
end
local function dim_frame(frame,level)
    if level>=1 then return frame end
    local out={discs={},phase=frame.phase,glyphs3=frame.glyphs3,lines=frame.lines} -- 3D glyph/line colors are dimmed when sent
    for i,disc in ipairs(frame.discs or {})do
        local d={}for k,v in pairs(disc)do d[k]=v end
        if disc.colors then d.colors={}for j,c in ipairs(disc.colors)do d.colors[j]=dim(c,level)end end
        d.color,d.outline,d.hub=dim(disc.color,level),dim(disc.outline,level),dim(disc.hub,level)
        out.discs[i]=d
    end
    for i,ring in ipairs(frame)do
        local r={}for k,v in pairs(ring)do r[k]=v end
        if ring.colors then r.colors={}for j,c in ipairs(ring.colors)do r.colors[j]=dim(c,level)end end
        r.color,r.tail=dim(ring.color,level),dim(ring.tail,level)
        out[i]=r
    end
    return out
end
local function draw(frame,mob,level)
    frame=dim_frame(frame,level)
    native.begin(mob.index,mob.id)
    -- Test5.7: 3D glyphs (Umbra endings) need native 0.11.0; older DLLs skip them.
    if native_level>=11 and native.glyph then
        for _,g in ipairs(frame.glyphs3 or {})do
            if native_level>=12 and native.shift then native.shift(g.dx or 0,g.dy or 0)end
            native.glyph(g.radius,g.offset,g.rotation,dim(g.color,level),g.tilt or 0,g.stand or 0,g.lift or 1,
                g.sink or 0,g.pull or 0,g.stagger or 0,g.order or 0,g.clip and 1 or 0,g.circle and 1 or 0)
        end
    end
    for _,disc in ipairs(frame.discs or {})do
        if native_level>=12 and native.shift then native.shift(disc.dx or 0,disc.dy or 0)end
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
    if native_level>=12 and native.shift then native.shift(0,0)end
    local shift_e,shift_n=0,0
    local function shift(piece)
        if native_level<12 or not native.shift then return end
        local e,n=piece.dx or 0,piece.dy or 0
        if e~=shift_e or n~=shift_n then native.shift(e,n);shift_e,shift_n=e,n end
    end
    for _,ring in ipairs(frame) do
      shift(ring)
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
    -- 0.12.0: kill seams (straight lines).
    if native_level>=12 and native.line then
        native.shift(0,0)
        for _,l in ipairs(frame.lines or {})do
            native.line(l[1],l[2],l[3],l[4],l[5],l[6],dim(l[7],level),l[8]or 2)
        end
    end
    native.commit()
end
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
    local blocked=world_blocked()
    if blocked then outgoing,incoming,shown=nil,nil,nil end
    local mob=current_mob()
    local id=mob and mob.id
    if id~=selected_id then
        debug('target changed '..tostring(selected_id)..' -> '..tostring(id))
        handoff(id,mob,now,blocked)
        selected_id=id
    end
    -- The previous target, still fading, has the frame until it is done
    -- (the DLL draws one target per frame, so the handoff is sequential).
    if outgoing then
        local o=outgoing
        local live=windower.ffxi.get_mob_by_index(o.index)
        local level=level_of(o,now)
        if not live or live.id~=o.id or level<=0 then outgoing=nil
        else
            if o.preview then o.preview:advance(now)end
            local radius,height=resonance.dimensions(o.mob,settings)
            view_toward(live.x and live or o.mob)
            draw(frame_for(o.id,now,radius,height,o.preview),o.mob,level)
            return
        end
    end
    if not mob then
        if not last_tracking_error then last_tracking_error='no living rendered enemy/cutscene/logged out' debug(last_tracking_error) end
        clear() return
    end
    last_tracking_error=nil
    if preview then advance_preview(now) end
    local radius,height=resonance.dimensions(mob,settings)
    view_toward(mob)
    local frame=frame_for(id,now,radius,height,preview)
    local level=1
    if incoming then
        if now<incoming.start then clear() return end
        level=incoming.from+(1-incoming.from)*math.min(1,(now-incoming.start)/math.max(incoming.duration,1e-6))
        if level>=1 then incoming,level=nil,1 end
    end
    if #frame>0 or #(frame.discs or {})>0 then
        shown={id=id,mob=mob,level=level,preview=(preview and carries(preview,id))and preview or nil}
    else shown=nil end
    draw(frame,mob,level)
end)
windower.register_event('load',function()
    if settings.enabled then start_renderer() subscribe() end
end)
windower.register_event('zone change','logout',function()
    preview=nil selected_id=nil shown,outgoing,incoming=nil,nil,nil model:clear() clear() debug('world state cleared')
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
