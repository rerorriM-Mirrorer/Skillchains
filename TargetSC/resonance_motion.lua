-- Analytic presentation driven by source timestamps, never accumulated frames.
-- Strike displacement and the settled ground hum are in world units. Author: A.
local M={}
local Burst=require('resonance_burst')
local min,max,sin,exp,pi=math.min,math.max,math.sin,math.exp,math.pi
local function clamp(v,a,b)return max(a,min(b,v))end
local function smooth(v)v=clamp(v,0,1)return v*v*(3-2*v)end
-- Effective global + Killala profile from 2026-10-22 16:41:47 XML.
-- Existing saved settings survive; preset default deliberately restores these.
M.defaults={opacity=0.27,scale=2,height=0.66,intensity=0.3,motion='sine',layout='grounded',
    period=0.09,amplitude=0.3,damping=3,width=2,glow=1,brightness=4,discs=true,disc_opacity=1,
    hum_amplitude=0.018,hum_period=0.12,hum_slowdown=1,hum_gain=0.35,
    disc_outline=0.6,disc_style='glyph',disc_height=0.06,disc_speed=0.1,disc_slowdown=3,
    disc_speed_opener=4,disc_speed_level1=2,disc_speed_level2=3,disc_speed_level3=4,disc_speed_level4=0,mb_opacity=0.39,
    mb_idle=0.1,mb_burst=0.6,mb_floor=1,mb_ring=1,mb_period=2,mb_rise=0.01,mb_expand=0,sky_expand=0.39,
    awakening=true,awakening_opacity=0.3,ground_height=0.3,fade_duration=0.8,
    opener_gap=12,opener_glow='black',opener_muted=true,
    display='both',sky_cutoff=.5,sky_curve=3,sky_hold=.3,sky_descent=0,disc_minimum=.5,
    mb_duration=0.9,mb_effects=1,mb_ending=2,mb_ending_style='soft',mb_overall=0.66,
    mb_intro=.6,mb_intro_flashes=1,ground_lift=.04,
    mb_style='clapper',mb_size=.5,mb_position=.5,mb_spin=.025,
    mb_breath_min=.35,mb_breath_gain=3,mb_hold=.6,mb_return=2,mb_lift=.3,mb_shimmer=1,
    -- Test3 (2026-11-16): the large lower glyph rises to just above the MB
    -- ring on a confirmed burst, stays white, and lands with the property
    -- trace. glyph_height 0 / glyph_tint 1 / intro_glyph 1 restore Killala.
    mb_glyph_height=1.1,mb_glyph_tint=0,mb_glyph_rise=.15,mb_intro_glyph=.5,mb_intro_disc=1,
    -- Test6.4: opacity multiplier for the confirmed-MB response glyph only
    -- (strike, rise and its fade/fall); 1 = unchanged, 0 = hidden.
    mb_glyph_opacity=1,
    -- Two-element property discs blend smoothly instead of splitting in half.
    disc_blend='gradient',
    -- Multi-color SC rings (ground, sky and their glows) blend smoothly too.
    -- Opener rings always stay split around their two gaps.
    ring_blend='gradient',
    -- Test3.2: SC rings turn with the property disc (stage speed easing to
    -- the disc minimum), carry a soft brighter/dimmer side so the spin reads,
    -- glows may turn faster, and the MB ring settles onto the large glyph
    -- during the closing pulses.
    ring_spin='disc',ring_shade=.25,ring_glow_spin=1,mb_ending_drop=1,
    -- Test6.5 converge ending: ring and large glyph shrink toward the property
    -- glyph's size while they converge (0 = keep their size, 1 = reach it).
    mb_ending_shrink=0,
    -- Test6.6: converge fades out over this many seconds just after the real
    -- MB deadline (0 = out exactly at it). Blooms: fade (go out with the MB
    -- ending) or linger (Test6.6.2: keep drawing past the deadline and fade
    -- out over `mb ending fade`, whatever the ending style).
    mb_ending_fade=.4,mb_ending_blooms='fade',
    -- Test3.4: confirmed-MB glows on the two glyphs get a turning lit side,
    -- an added spin (turns/sec) over their glyph, and optional softening.
    mb_glow_shade=.5,mb_glow_spin=.5,mb_glow_flicker=1,mb_glow_width=1,
    -- Test3.5: the white awakening disc keeps its opacity at the center and
    -- fades toward the edge (inner/outer multiply its opacity); size scales it.
    awakening_inner=1,awakening_outer=0,awakening_size=1,
    -- Test3.6: opener-only property disc FILL (glyph lines unchanged):
    -- center/edge opacity multipliers and size. Defaults change nothing.
    opener_disc_inner=1,opener_disc_outer=1,opener_disc_size=1,
    -- When the awakening disc's fade ends: 'default' (two-thirds of the wait,
    -- as before), 'open' (window opens), 'close' (window ends) or '1'..'9'
    -- seconds after the window opens. A link fades it out over .3 s.
    awakening_until='default',
    -- Test6.7: each link that opens a new window plays the awakening disc too.
    awakening_links=true,
    -- Test3.8: opener arcs fade along their length from the bright end
    -- (lead = facing the spin); the glow band follows by opener_fade_glow.
    opener_fade=.6,opener_fade_length=1,opener_fade_curve=1,opener_fade_end='lead',opener_fade_glow=1,
    -- Test4.0: opener properties share the circle as sections (gaps 90/60/30
    -- for 1/2/3 properties); each element is one arc, stacked by height.
    opener_layout='sections',opener_spacing=.035,
    -- Test4.1: openers keep turning: gentler slowdown toward a minimum speed.
    opener_spin_slowdown=1,opener_spin_minimum=.5,
    -- Test4.2: opener property-disc glyph line opacity; -1 = follow discs outline.
    opener_disc_outline=-1,
    -- Test4.4: link property discs (all levels): fill center/edge fade, fill
    -- size, glyph-line (sigil) size; Light/Darkness disc look.
    disc_inner=1,disc_outer=1,disc_size=1,disc_size_lines=1,disc_lightdark='classic',
    -- Test4.5: level-3 Light/Darkness links: white/black outer strands, the
    -- four element colors around the middle strand, MB ring cycling them.
    ring_lightdark='elements',ring_lightdark_spin=1,ring_lightdark_tint='white',mb_lightdark_cycle=2,
    -- Test4.6: level-3 LIGHT only (Darkness keeps the elements look): all
    -- strands white; the four inner rings' glows carry the four element
    -- colors (top to bottom), slowly rotating; MB ring white breathing.
    ring_light='white',ring_light_cycle=4,ring_light_glow=1,
    -- Test4.7: Light's colored inner glows stay off until its window opens,
    -- then rise to `rings light glow`; its MB ring matches the lowest SC ring.
    ring_light_opening='off',ring_light_mb='match',
    -- Test7.5: a level-3 link opens as three strands squeezed together
    -- (spacing x ring_level3_start) that separate to their stacked spacing
    -- over the same .3 s as the glide from the previous link's heights.
    -- pop = the earlier single white ring for .16 s, then three strands.
    ring_level3_open='spread',ring_level3_start=.5,
    -- Test7.6: a level-2 link (from an opener or level 1) opens as its pair
    -- squeezed to spacing x ring_level2_start, separating to the normal .035
    -- over the .3 s glide. split = start 0 (one ring splitting in two),
    -- half = start .5; stacked = the earlier look (full pair from frame 1).
    -- A level 2 after a level 2 keeps the stacked look.
    ring_level2_open='spread',ring_level2_start=0,
    -- Test7.7: a level-4 link (Radiance/Umbra) opens by collapsing the
    -- previous level 3's rings, all white, from where they were into one ring,
    -- then expanding its four rings concentrically out of it (fast, then easing
    -- gently until the window opens). Ground rings only (no sky set).
    -- open: collapse | pop (the earlier single white ring for .16 s).
    -- collapse (where the L3 rings meet): ground = the L4 ground ring height;
    --   mb = the MB ring's height at the SC ring size (concentric with it);
    --   into = onto the MB ring itself (its glow shows through).
    -- expand (where the four rings live): mb = around the MB ring; ground.
    -- With the MB ring hidden both fall back to ground.
    -- collapse_time s (.12, capped at .3); expand_time s (-1 = until the
    -- window opens); ease = ease-out power (6; higher = faster start).
    -- Test7.8: the innermost ring grows out from the MB ring you see (for
    -- Umbra x umbra mb size) and the other three spread out from it on the
    -- same ease. gap = innermost ring's final distance outside the MB ring,
    -- spacing = distance between rings (both x the SC radius; .03, .075).
    -- expand ground keeps the earlier final sizes (1 - 1.5 spacing upward).
    ring_level4_open='collapse',ring_level4_collapse='into',ring_level4_expand='mb',
    ring_level4_collapse_time=.12,ring_level4_expand_time=-1,ring_level4_ease=6,
    ring_level4_gap=.03,ring_level4_spacing=.075,
    -- Test7.9: level-4 MB ring brightness flickers like the skillchain bar's
    -- level 3/4 border ((.37+.63 sin^2 23t)(.72+.28 sin^2 28t)) instead of
    -- breathing. flicker|breath; depth 0-1 (1 = the bar's full swing).
    mb_level4='flicker',mb_level4_depth=1,
    -- Test4.8: large breathing glyph: after a burst it stays risen and fades
    -- (instead of falling); at the floor it shows only the window-opening
    -- flash (no breathing).
    mb_glyph_after='fade',mb_glyph_rest='hidden',
    -- Test4.9: burst bloom. Each confirmed burst releases an element-colored
    -- disc (white-hot center, transparent edge) that grows and fades, from the
    -- MB ring (or property disc / risen glyph), optionally with copies of the
    -- glyph lines growing outward. Sizes are multiples of the MB ring radius.
    -- Three opacity stops (center, middle, edge) need native 0.10.0; older
    -- DLLs draw center and edge only.
    mb_bloom=true,mb_bloom_from='ring',mb_bloom_to='same',mb_bloom_start=.3,mb_bloom_end=1.5,
    mb_bloom_time=1,mb_bloom_ease=2.5,mb_bloom_fade=1.5,
    mb_bloom_center=.7,mb_bloom_middle=.35,mb_bloom_edge=0,mb_bloom_position=.5,
    mb_bloom_flash=.6,mb_bloom_core=.5,
    mb_bloom_lines=0,mb_bloom_lines_opacity=.6,mb_bloom_lines_delay=.12,mb_bloom_lines_size=1.8,
    -- Test5.0 target handoff (seconds): untarget/ordinary death keeps the
    -- animation running on the old enemy while it dims from the first moment;
    -- switching to an enemy with resonance uses the quick out, then in.
    detarget_time=1,switch_out=.25,switch_in=.35,
    -- Test5.1: Radiance MB ring drawn exactly like a level-3 Light middle SC
    -- ring (white core, element-colored inner glow) at the MB ring's place,
    -- with its own glow strength and a fast color shift.
    mb_radiance='light',mb_radiance_glow=3,mb_radiance_cycle=.4,
    -- Test5.1: level-4 (Radiance/Umbra) property disc. -1 = same as the
    -- `discs` setting; middle -1 = no middle point (needs DLL 0.10.0).
    disc_level4_inner=-1,disc_level4_middle=-1,disc_level4_position=.5,disc_level4_outer=-1,
    disc_level4_size=-1,disc_level4_height=0,
    -- Test5.2 level-4 looks. opacity/disc_opacity -1 = use the overall
    -- `opacity` (and `discs opacity`); 0-1 replaces it for that skillchain.
    -- Radiance: rings keep their opening white (look open), then close one
    -- at a time (lower set first, inner to outer) over `close time`, each
    -- glow flashing briefly and going out just before its ring; a bright
    -- patch travels around each glow from the far side to the near side and
    -- back, staggered per ring (shimmer), the MB ring joining in.
    radiance_opacity=-1,radiance_disc_opacity=-1,radiance_look='open',radiance_close='sequence',
    radiance_close_time=3,radiance_order='lower',radiance_direction='inner',radiance_lead=.2,
    radiance_fade=.5,radiance_flash=1.5,radiance_shimmer=.6,radiance_shimmer_time=2,
    radiance_shimmer_stagger=.12,radiance_shimmer_angle=0,radiance_shimmer_when='close',radiance_shimmer_mb=true,
    -- Umbra: black cores with a white glow from the opening; after `close
    -- time` each ring flashes white and vanishes (upper set first, outer to
    -- inner, `gap` apart), leaving its glow as faint black smoke that
    -- dissipates in place.
    umbra_opacity=-1,umbra_disc_opacity=-1,umbra_look='black',umbra_glow='white',umbra_close='sequence',
    umbra_close_time=3,umbra_order='upper',umbra_direction='outer',umbra_gap=.12,umbra_flash=.6,
    umbra_flash_time=.08,umbra_smoke=1.5,umbra_smoke_opacity=.5,umbra_smoke_spread=.05,
    -- Test5.4. open_time -1 = the game's window timing; otherwise the visual
    -- length of the level-4 "opening" (MB timing unchanged).
    radiance_open_time=-1,umbra_open_time=-1,
    -- Umbra flash-out leaves one ring-shaped black bloom (after bloom) instead
    -- of per-ring smoke; shaped by the MB bloom's center/middle/edge, middle
    -- position, ease and fade; own opacity, time, start size (SC ring radii),
    -- growth (-1..2: <0 shrinks inward, 0 stays, >0 grows) and height.
    umbra_after='bloom',umbra_bloom_opacity=.6,umbra_bloom_time=2.5,umbra_bloom_size=1,
    umbra_bloom_growth=-.5,umbra_bloom_height='rings',
    -- Umbra MB ring: white pulses like the ending (same rhythm, lined up with
    -- it) for the whole window; it still only sinks in the real ending.
    umbra_mb='pulse',umbra_mb_strength=1,umbra_mb_size=1,umbra_disc_size=-1,
    -- Radiance: the disc's own glyph lines hidden; the large MB floor glyph
    -- breathes at rest (as before 4.8), never turns, may buzz with the rings.
    radiance_disc_lines=false,radiance_glyph='breath',radiance_glyph_size=1,
    radiance_glyph_opacity=-1,radiance_glyph_buzz=true,
    -- Test6.8: `radiance sky off` / `umbra sky off` drop the sky rings (a
    -- level-4 link opens no new window, so one set of rings is enough).
    radiance_sky='bell',
    -- Test6.9 Radiance floor glyph: circle off drops the ring around it (drawn
    -- as a flat native 3D glyph, 0.11.0+); wobble always keeps it moving at
    -- the hum's opening speed through the whole MB window and exit fade
    -- (rings = it follows the ground rings, which settle as they close).
    radiance_glyph_circle=true,radiance_glyph_wobble='rings',
    -- Test7.0 Umbra under disc: a second turning property disc just below the
    -- black one (like Radiance's middle disc), crossfading the Gravitation and
    -- Distortion looks over `under cycle` s, opaque center to clear edge
    -- (`under center`/`under edge`), showing where the black disc thins out.
    -- Spin x the Umbra disc's turn; direction same|reverse; size x its size;
    -- depth = how far below the black disc.
    umbra_under=false,umbra_under_opacity=.6,umbra_under_size=1,umbra_under_spin=1,
    umbra_under_direction='same',umbra_under_cycle=4,umbra_under_depth=.01,
    umbra_under_center=1,umbra_under_edge=0,
    -- Test7.0 Umbra haze: a white smoke bloom held at the MB ring's height for
    -- the whole MB window, flickering (`haze flicker` depth 0-1 at `haze
    -- speed` x the level-4 buzz rate); size x the Umbra MB ring; center/edge
    -- = its radial opacity. Fades in over .3 s; shrinks with the collapse (or
    -- fades over `mb ending` without it).
    umbra_haze=false,umbra_haze_opacity=.3,umbra_haze_size=1.3,umbra_haze_flicker=.5,
    umbra_haze_speed=1,umbra_haze_center=.6,umbra_haze_edge=0,
    -- Test7.1 haze: style glow = black at the center blending to full white at
    -- the black disc's middle point (its radius x disc position), clear at the
    -- haze edge (two discs: white under, black `haze black` over). haze lift
    -- moves it up/down from the MB ring; haze order over|under the black disc.
    umbra_haze_style='soft',umbra_haze_black=1,umbra_haze_lift=0,umbra_haze_order='over',
    -- Test7.1: the black disc's middle point swings sinusoidally by `disc
    -- jitter` (radius fraction) at `jitter speed` cycles/s (0 = still).
    umbra_disc_jitter=0,umbra_jitter_speed=1,
    -- Test7.1: steady = keep the disc's opening turn speed (no slowdown).
    umbra_under_steady=false,umbra_copies_steady=false,
    -- Test7.2: under ending fade = in the collapse the under disc keeps its
    -- size and fades by the same curve (shrink = shrinks with the rest);
    -- copies until end = glyph copies keep spawning to the MB deadline
    -- (flash = they stop at the flash-out, as before).
    umbra_under_ending='fade',umbra_copies_until='flash',
    -- Test7.3 `umbra ending vanish`: at the ending start (`ending when`) the
    -- glyph lines on the black disc and the MB glyph shimmer to black and are
    -- gone within `vanish time` s (`vanish shimmer` flickers/s); nothing takes
    -- their place. `umbra burst center black`: MB burst blooms on an Umbra
    -- link get an opaque black center blending out to their color.
    umbra_vanish_time=.12,umbra_vanish_shimmer=30,umbra_burst_center='normal',
    -- Test7.4 Radiance glow: two white ring-band blooms (the MB bloom shape)
    -- around the ground ring height. Clear at landing, they ease in over
    -- `glow rise` s (-1 = from landing) and rush to full at the first ring's
    -- flash peak, hold `glow hold` s, then ease out and drop away over `glow
    -- fall` s (at most to the MB deadline). They dance in a figure eight: size
    -- +-`glow dance` at `glow speed` cycles/s, height at twice that, a quarter
    -- cycle apart. Size x the ring radius.
    radiance_glow=false,radiance_glow_opacity=.5,radiance_glow_size=1.2,radiance_glow_rise=-1,
    radiance_glow_hold=.3,radiance_glow_fall=1.5,radiance_glow_dance=.08,radiance_glow_speed=.4,
    -- Test7.1 Radiance MB ending: ride = the property discs move down with the
    -- MB ring and only fade in the final fade; ending glyph = the floor glyph
    -- brightens toward `ending peak` as the ring descends (off = as before).
    radiance_ending_ride=false,radiance_ending_glyph='off',radiance_ending_peak=1,
    -- Test5.5 Radiance three-disc stack (bottom to top): a white disc, a disc
    -- crossfading the Fusion and Fragmentation looks (own cycle, turning at
    -- the level-4 disc speed x middle spin), then the existing white disc on
    -- top. Opacities are direct (not scaled by the overall opacity); sizes
    -- multiply the level-4 disc size; stack height moves all three.
    radiance_stack=true,radiance_stack_height=0,radiance_stack_spacing=.01,
    radiance_bottom_opacity=.6,radiance_bottom_size=1,
    radiance_middle_opacity=.5,radiance_middle_size=1,radiance_middle_cycle=4,radiance_middle_spin=1,
    -- Test5.6 Umbra: own level-4 spin (-1 = discs speed level4; up to 6);
    -- sky rings the same size as the ground rings (no bell flare); a large
    -- MB floor glyph that breathes, turns with the disc and sits at the
    -- disc's exact height, sized like the Umbra MB ring; and glyph copies
    -- that appear every `copies every` s through the opening, each growing
    -- and fading over `copies life` s just under the disc, spinning.
    umbra_spin=-1,umbra_sky='same',umbra_glyph='breath',umbra_glyph_size=1,umbra_glyph_opacity=-1,
    umbra_glyph_spin=1,umbra_glyph_over=false,umbra_copies=true,umbra_copies_every=.6,umbra_copies_life=1.2,
    umbra_copies_size=1.6,umbra_copies_opacity=.5,umbra_copies_spin=1,umbra_copies_depth=.004,
    -- Test5.7 Umbra controls. lines = the disc's own glyph (cream lines on the
    -- black disc): size -1 = the disc's size, else x the Umbra MB ring
    -- radius (like the floor glyph); opacity -1 = discs outline x opacity.
    -- Disc shape -1 = discs level4; disc steady keeps its opacity through the
    -- window-opening and burst flashes. core -1 = opacity x brightness, else
    -- the ring cores' direct opacity; flicker = how deep the level-4 flicker
    -- dips them (.28 as before).
    umbra_lines_size=-1,umbra_lines_opacity=-1,umbra_disc_inner=-1,umbra_disc_middle=-1,umbra_disc_outer=-1,
    umbra_disc_position=-1,umbra_disc_steady=true,umbra_core=-1,umbra_flicker=.28,
    -- Test5.7 Umbra endings for the disc's glyph (native 0.11.0): gyro stands
    -- it upright spinning about the vertical axis (tracing a sphere/dome),
    -- shrinking away at the end; swallow stands each segment up about its
    -- midpoint then sinks them into the black disc, pulled inward, cut off at
    -- the disc's surface. when mb = the MB ending; flash = from the flash-out
    -- for `ending time`.
    umbra_ending='off',umbra_ending_when='mb',umbra_ending_time=2,
    umbra_gyro_speed=1.5,umbra_gyro_rise=.4,umbra_gyro_shrink=.5,umbra_gyro_below='full',
    umbra_stand_time=.5,umbra_sink_time=1,umbra_swallow_stagger=.5,umbra_swallow_order='outer',
    umbra_swallow_pull=.3,umbra_swallow_lift=1,
    -- Test5.8: the disc glyph's color (white, or the cream it had), and the
    -- Umbra MB ring at its usual height or exactly at the black disc's plane.
    umbra_lines_color='white',umbra_mb_height='ring',
    -- Test6.0 Umbra collapse ending: over the last `collapse time` s (-1 =
    -- mb ending) everything shrinks toward the center, radius x (1 - t^curve):
    -- a very slow start into a quick whoosh, gone at the MB deadline. The MB
    -- ring does not sink and the black disc stays opaque meanwhile. glyph lift:
    -- the floor glyph always sits this far above the black disc (-1 = it
    -- rises on bursts as before).
    umbra_collapse=true,umbra_collapse_curve=4,umbra_collapse_time=-1,umbra_glyph_lift=.004,
    -- 0.18 kill animations (only when Skillchains reports the SC weapon skill
    -- or MB itself defeated the target). MB kill: SC rings gather into the
    -- MB ring height and fade while the disc and glyphs jump there, then
    -- everything collapses (1 - t^curve) and a second, element-colored bloom
    -- bursts outward right after the MB's own. SC kill (needs native 0.12.0):
    -- the frame freezes (`sc freeze` s after the kill), turns ghostly white,
    -- a seam flashes along the killing blow, the glyphs flash out, and rings
    -- and disc split into halves drifting apart with a subtle counterclockwise
    -- turn, sky halves sagging, buzzing out with the level-4 flicker.
    -- Test6.3 MB kill (`kill mb rings freeze`): the whole animation freezes at
    -- the kill; every ring (SC and MB) and disc flickers in the element color
    -- and fades out together over `mb fade`; the MB's own bloom is drawn back
    -- in over the same time (`mb bloom in|fade`); the glyphs grow and fade
    -- with the kill bloom (`mb glyphs bloom|fade`). `gather` = the Test6.1
    -- look. The kill bloom is faster and larger than the MB's own (`bloom
    -- size` = multiple of the MB bloom's end size). Flicker 0 steady - 1 full.
    kill=true,kill_time=1.6,kill_mb_rings='freeze',kill_mb_fade=.6,kill_mb_flicker=.6,
    kill_mb_freeze=.2,kill_mb_discs='element',kill_mb_bloom='in',kill_mb_glyphs='bloom',
    kill_mb_gather=.35,kill_mb_curve=4,kill_bloom_delay=.12,kill_bloom_time=.55,
    kill_bloom_size=1.25,kill_bloom_opacity=.8,kill_sc_freeze=.2,kill_sc_split=.12,kill_sc_turn=.05,
    kill_sc_sag=.12,kill_sc_flicker=.35,kill_sc_flash=.08,kill_sc_seam=.5,kill_seam_flicker=1,
    kill_sc_ghost=.85,kill_seam_angle=0}
-- Exact 2026-10-22 Killala profile (identical to Cioara's 2026-11-16 saved
-- TargetSC settings): `//tsc preset killala` restores the pre-Test3 look.
M.killala={mb_glyph_height=0,mb_glyph_tint=1,mb_glyph_rise=0,mb_intro_glyph=1,mb_intro_disc=1,disc_blend='split',ring_blend='split',
    ring_spin='classic',ring_shade=0,ring_glow_spin=1,mb_ending_drop=0,
    mb_glow_shade=0,mb_glow_spin=0,mb_glow_flicker=1,mb_glow_width=1,
    awakening_inner=1,awakening_outer=1,awakening_size=1,
    opener_disc_inner=1,opener_disc_outer=1,opener_disc_size=1,awakening_until='default',awakening_links=false,
    opener_fade=0,opener_fade_length=1,opener_fade_curve=1,opener_fade_end='lead',opener_fade_glow=1,
    opener_layout='rings',opener_spacing=.035,opener_spin_slowdown=3,opener_spin_minimum=0,
    opener_disc_outline=-1,
    disc_inner=1,disc_outer=1,disc_size=1,disc_size_lines=1,disc_lightdark='classic',
    ring_lightdark='classic',ring_lightdark_spin=1,ring_lightdark_tint='gold',mb_lightdark_cycle=2,
    ring_light='classic',ring_light_cycle=4,ring_light_glow=1,ring_light_opening='on',ring_light_mb='white',
    ring_level3_open='pop',ring_level2_open='stacked',ring_level4_open='pop',mb_level4='breath',
    mb_glyph_after='fall',mb_glyph_rest='breath',mb_bloom=false,
    detarget_time=0,switch_out=0,switch_in=0,mb_radiance='classic',
    radiance_look='classic',radiance_close='classic',radiance_shimmer=0,
    umbra_look='classic',umbra_glow='violet',umbra_close='classic',
    umbra_after='smoke',umbra_mb='classic',radiance_disc_lines=true,radiance_glyph='same',radiance_stack=false,
    radiance_sky='bell',radiance_glyph_circle=true,radiance_glyph_wobble='rings',umbra_under=false,umbra_haze=false,radiance_ending_ride=false,radiance_ending_glyph='off',umbra_disc_jitter=0,radiance_glow=false,umbra_sky='bell',umbra_glyph='same',umbra_copies=false,umbra_disc_steady=false,umbra_lines_color='cream',
    umbra_collapse=false,umbra_glyph_lift=-1,kill=false}
local white,gold={255,255,255},{255,217,115}
-- Mix toward the brightest channel before dimming: hue is preserved while
-- saturation becomes 75% and value 82% of the ordinary elemental color.
local function muted(c)
    local value=max(c[1],c[2],c[3])
    return {(.75*c[1]+.25*value)*.82,(.75*c[2]+.25*value)*.82,(.75*c[3]+.25*value)*.82}
end
local function option(opts,k)
    if opts and opts[k]~=nil then return opts[k]end
    return M.defaults[k]
end
local function mix(a,b,t)
    t=clamp(t,0,1)return {a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t,a[3]+(b[3]-a[3])*t}
end
function M.phase(s,now,opts)
    if now<s.sc_open then return 'pre'end
    local boundary=s.closed and s.sc_open or s.sc_close
    if not s.closed and now<boundary then return 'countdown'end
    if now<boundary+option(opts,'fade_duration')then return s.closed and 'terminal' or 'expiration'end
    return now<s.mb_close and 'mb-only' or 'expired'
end
-- Integral of f*(1-t/duration)^power: zero final speed without an angle jump.
function M.slow_integral(elapsed,duration,power)
    local t=clamp(elapsed/max(.001,duration),0,1)
    return duration*(1-(1-t)^(power+1))/(power+1)
end
local function energy_time(s,now,opts,power)
    local charge=max(0,s.sc_open-s.created)
    if now<s.sc_open then return max(0,now-s.created)end
    local duration=s.closed and option(opts,'fade_duration')or max(.1,s.sc_close-s.sc_open)
    return charge+M.slow_integral(now-s.sc_open,duration,power)
end
function M.rotation(s,now,opts)
    local stage=s.step==1 and 'opener'or 'level'..s.level
    local turns=option(opts,'disc_speed_'..stage)
    if s.step==1 then
        -- Test4.1 opener spin: full speed through the wait, then ease toward
        -- a minimum (never above full) along (1-t)^slowdown; 0 = no slowing.
        -- Integrated analytically so the angle never jumps.
        local power=option(opts,'opener_spin_slowdown')
        local minimum=min(turns,option(opts,'opener_spin_minimum'))
        local charge=max(0,min(now,s.sc_open)-s.created)
        local elapsed=max(0,now-s.sc_open)
        local duration=s.closed and option(opts,'fade_duration')or max(.1,s.sc_close-s.sc_open)
        return 2*pi*option(opts,'disc_speed')*(turns*charge+minimum*elapsed+
            (turns-minimum)*M.slow_integral(elapsed,duration,power))
    end
    return 2*pi*turns*option(opts,'disc_speed')*energy_time(s,now,opts,option(opts,'disc_slowdown'))
end
-- Only the property disc carries on through an enabled MB window. Integrate
-- speed analytically so there is no angle jump as it reaches its idle speed.
-- A stationary stage remains stationary; the minimum never speeds a stage up.
function M.disc_rotation(s,now,opts)
    local display=option(opts,'display')
    if (display~='both'and display~='mb')or s.step==1 or s.mb_close<=s.created then
        return M.rotation(s,now,opts)
    end
    local turns=option(opts,'disc_speed_level'..s.level)
    local minimum=min(turns,option(opts,'disc_minimum'))
    local at=min(now,s.mb_close)
    local elapsed=max(0,at-s.sc_open)
    local energy=energy_time(s,at,opts,option(opts,'disc_slowdown'))
    return 2*pi*option(opts,'disc_speed')*((turns-minimum)*energy+
        minimum*(max(0,min(at,s.sc_open)-s.created)+elapsed))
end
-- Hold the fully unfolded bell through its color transition, then use a
-- smooth compressed descent that still reaches the source deadline exactly.
function M.descent_remaining(s,now,opts)
    local duration=max(.1,s.sc_close-s.sc_open)
    local hold=option(opts,'sky_hold')
    local held=hold>0 and min(hold+.15,max(0,duration-.1))or 0
    local t=clamp((now-s.sc_open-held)/max(.1,duration-held),0,1)
    -- Warp only presentation progress after the existing hold. Zero preserves
    -- the old linear/no-hold or smooth/held curve, with exact source endpoints.
    local curve=option(opts,'sky_descent')
    if curve>0 then t=1-(1-t)^(1+curve)
    elseif curve<0 then t=t^(1-curve)end
    return 1-(hold>0 and smooth(t)or t)
end
local function wave(cycles,opts)
    if option(opts,'motion')=='flutter'then return math.floor(cycles*2+1e-9)%2 end
    return .5+.5*sin(cycles*2*pi)
end
function M.vibration(s,now,opts)
    -- Opener appearance and window opening restart the SAME strike envelope.
    -- Closed results have no window-opening strike or fictitious countdown.
    local age=max(0,now-s.created)
    local strike_age=(now<s.sc_open or s.closed)and age or now-s.sc_open
    local decay=exp(-strike_age*option(opts,'damping'))
    local strike=option(opts,'amplitude')*option(opts,'intensity')*decay*
        wave(strike_age/(2*option(opts,'period')),opts)
    local level=s.step==1 and 1 or s.level
    local gain=1+(level-1)*option(opts,'hum_gain')
    local frequency=gain/(2*option(opts,'hum_period'))
    local hum_phase=frequency*energy_time(s,now,opts,option(opts,'hum_slowdown'))
    local hum=option(opts,'hum_amplitude')*gain*option(opts,'intensity')*(1-decay)*wave(hum_phase,opts)
    local duration=s.closed and option(opts,'fade_duration')or max(.1,s.sc_close-s.sc_open)
    local left=now<s.sc_open and 1 or clamp(1-(now-s.sc_open)/duration,0,1)
    return strike+hum,strike,{strike=strike,hum=hum,
        hum_amplitude=option(opts,'hum_amplitude')*gain*option(opts,'intensity')*(1-decay),
        hum_hz=frequency*left^option(opts,'hum_slowdown')}
end
-- Test7.1: the disc's turn at its opening speed on plain time (no slowdown).
function M.steady_rotation(s,now,opts)
    return 2*pi*option(opts,'disc_speed')*option(opts,'disc_speed_level'..s.level)*max(0,now-s.created)
end
-- Test7.1: the Umbra black disc's middle point, with its sinusoidal jitter.
function M.umbra_disc_position(s,now,opts)
    local pos=option(opts,'disc_level4_position')
    if option(opts,'umbra_disc_position')>=0 then pos=option(opts,'umbra_disc_position')end
    local amp=option(opts,'umbra_disc_jitter')
    if amp>0 then pos=pos+amp*sin(2*pi*option(opts,'umbra_jitter_speed')*max(0,now-s.created))end
    return clamp(pos,.02,.98)
end
-- Test7.1: shapes for the Radiance ending glyph.
local ending_curves={linear=function(x)return x end,quadratic=function(x)return x*x end,
    cosine=function(x)return .5-.5*math.cos(pi*x)end,exponential=function(x)return (math.exp(4*x)-1)/(math.exp(4)-1)end}
-- Test6.9: the ground wobble without the closing slowdown: the same strike
-- and hum, with the hum running on plain time (identical before sc_open).
function M.steady_wobble(s,now,opts)
    local _,_,d=M.vibration(s,now,opts)
    local level=s.step==1 and 1 or s.level
    local frequency=(1+(level-1)*option(opts,'hum_gain'))/(2*option(opts,'hum_period'))
    return d.strike+d.hum_amplitude*wave(frequency*max(0,now-s.created),opts)
end
function M.positions(s,now,height,opts)
    local phase=M.phase(s,now,opts)
    -- Natural expiry freezes the last geometry and fades it in place.
    local at=not s.closed and min(now,s.sc_close)or now
    local age=max(0,at-s.created)
    local elapsed=max(0,at-s.sc_open)
    local remaining=at<s.sc_open and 1 or s.closed and 0 or
        clamp((s.sc_close-at)/max(.1,s.sc_close-s.sc_open),0,1)
    local floor=option(opts,'ground_height')+option(opts,'ground_lift')
    local ground_wave,sky_wave,details=M.vibration(s,at,opts)
    details.ground_wave=ground_wave
    local paired=s.step>1 or phase~='pre'
    if not paired then return floor+ground_wave,nil,remaining,details end
    local unfold=s.step>1 and smooth(age/.3)or smooth(elapsed/.28)
    local descent=s.closed and 1 or M.descent_remaining(s,at,opts)
    local span=height*.90*descent*unfold
    local bottom,top=floor,floor+span
    local layout=option(opts,'layout')
    if layout~='grounded'then bottom=height*.49-span*.5;top=height*.49+span*.5 end
    if s.step>1 and s.previous and age<.3 then
        local old_bottom,old_top=M.positions(s.previous,s.created,height,opts)
        local t=smooth(age/.3)
        bottom=old_bottom+(bottom-old_bottom)*t
        top=(old_top or old_bottom)+(top-(old_top or old_bottom))*t
    end
    if layout=='center'then
        -- Comparison layout: constrain inward vibration to the current half
        -- span rather than allowing the two strands to cross each other.
        ground_wave=min(ground_wave,span*.5);sky_wave=min(sky_wave,span*.5)
    end
    -- Sky: damped strike only. Ground: strike plus its smaller sustained hum.
    bottom=bottom+ground_wave
    top=max(floor,top-sky_wave)
    return bottom,top,remaining,details
end
-- Height, not elapsed time, traces the requested bell profile. The radius
-- reaches normal after cutoff of the descent, then stays there.
function M.bell_factor(separation,height,opts)
    local descent=1-clamp(separation/max(.001,height*.9),0,1)
    local curve=max(0,1-descent/option(opts,'sky_cutoff'))
    return 1+option(opts,'sky_expand')*curve^option(opts,'sky_curve')
end
local function property_palette(name,context)
    return context.palette({properties={name},elements={},level=context.level(name)})
end
-- Test4.0 opener section arcs, top of the stack first: {lead,tail} pairs.
-- One element: one arc. Two: each color leads and trails into the other
-- (game order, first on top). Light/Darkness (and level 4): one arc per
-- element, white/black heads trailing into each element color.
local function opener_arcs(p,context)
    local elements=context.elements(p)
    local color=function(e)return context.element_color(e)or white end
    if context.level(p)>=3 then
        local head=(p=='Darkness'or p=='Umbra')and {0,0,0}or white
        local arcs={}
        for _,e in ipairs(elements)do arcs[#arcs+1]={head,color(e),head=true}end
        return arcs
    elseif #elements>=2 then
        return {{color(elements[1]),color(elements[2])},{color(elements[2]),color(elements[1])}}
    end
    local c=color(elements[1]or 'Light')
    return {{c,c}}
end
-- Test4.5: is this a level-3 Light/Darkness link drawn in the elements look?
local function lightdark(s,opts)
    if s.step<=1 or s.level~=3 then return false end
    if s.properties[1]=='Darkness'then return option(opts,'ring_lightdark')=='elements'end
    -- Light has its own mode since Test4.6 (white|elements|classic).
    return s.properties[1]=='Light'and option(opts,'ring_light')=='elements'
end
-- Test4.6 Light 'white' look: all strands white, element-colored inner glows.
local function light_white(s,opts)
    return s.step>1 and s.level==3 and s.properties[1]=='Light'and option(opts,'ring_light')=='white'
end
local function element_colors(p,context)
    local r={}
    for _,e in ipairs(context.elements(p))do r[#r+1]=context.element_color(e)or white end
    return r
end
local function specifications(s,context,opts)
    local result={}
    if light_white(s,opts)then
        return {{colors={white},radial=1,stack=0},{colors={white},radial=1,stack=.035},
            {colors={white},radial=1,stack=.07}}
    end
    if lightdark(s,opts)then
        -- Bottom and top strands white (Light) or black (Darkness); the middle
        -- strand blends around the circle through the four element colors.
        local head=s.properties[1]=='Darkness'and {0,0,0}or white
        return {{colors={head},radial=1,stack=0},
            {colors=element_colors(s.properties[1],context),radial=1,stack=.035,spin=option(opts,'ring_lightdark_spin')},
            {colors={head},radial=1,stack=.07}}
    end
    if s.step==1 then
        for j,p in ipairs(s.properties)do
            result[#result+1]={colors=property_palette(p,context),radial=1-(j-1)*.13,stack=0}
        end
    else
        local colors=context.palette(s)
        for j,c in ipairs(colors)do
            local palette={c}
            if s.level==2 and #colors==2 then
                palette=j==1 and {colors[1],colors[2]}or {colors[2],colors[1]}
            end
            result[#result+1]={colors=palette,radial=s.level>=4 and 1+(j-(#colors+1)/2)*.075 or 1,
                stack=(s.level==2 or s.level==3)and (j-1)*.035 or 0}
        end
    end
    return result
end
-- Test5.2 level-4 close sequences. Ring order index: the first set (lower =
-- ground, upper = sky, or together) then the other, each from inner or
-- outer strand (strand 1 = innermost at level 4).
local function level4_index(opts,name,part,j,n,has_top)
    local order,direction=option(opts,name..'_order'),option(opts,name..'_direction')
    local jj=direction=='inner'and j-1 or n-j
    if order=='together'or not has_top then return jj,n end
    local first=order=='lower'and 'ground'or 'sky'
    return (part==first and 0 or n)+jj,2*n
end
function M.level4_end(s,opts,name,has_top)
    local _,count=level4_index(opts,name,'ground',1,4,has_top)
    if name=='radiance'then return s.sc_open+option(opts,'radiance_close_time')end
    return s.sc_open+option(opts,'umbra_close_time')+(count-1)*option(opts,'umbra_gap')+
        option(opts,'umbra_flash_time')+(option(opts,'umbra_after')=='smoke'and option(opts,'umbra_smoke')or 0)
end
-- 0.18 kill animations (see the defaults). Mutates the finished frame.
local function scale_alpha(c,k)
    if type(c)~='number'then return c end
    return math.floor(math.floor(c/16777216)*clamp(k,0,1)+.5)*16777216+c%16777216
end
local function whiten(c,k)
    if type(c)~='number'then return c end
    return math.floor(math.floor(c/16777216)*clamp(k,0,1)+.5)*16777216+0xFFFFFF
end
-- Level-4 style flicker, scaled: strength 0 = steady 1, strength 1 = full buzz.
local function flicker(now,strength,a,b)
    local buzz=(.37+.63*sin(now*(a or 23))^2)*(.72+.28*sin(now*(b or 28))^2)
    return 1-clamp(strength,0,1)*(1-buzz)
end
local function tint(c,rgb,k)
    if type(c)~='number'then return c end
    return math.floor(math.floor(c/16777216)*clamp(k,0,1)+.5)*16777216+rgb[1]*65536+rgb[2]*256+rgb[3]
end
local kill_glyph_role={['mb-glyph']=true,['property-trace']=true,['umbra-copy']=true,awakening=true}
local function kill_bloom_disc(out,now,kill,start,opts,context,f)
    local life=max(.1,option(opts,'kill_bloom_time'))
    local age=now-(start+option(opts,'kill_bloom_delay'))
    local from=option(opts,'mb_bloom_start')
    local to=option(opts,'mb_bloom_end')*option(opts,'kill_bloom_size')
    if age<0 then return 0,0,false end
    local t=age/life
    if t>=1 then return 1,0,true end
    local e=1-(1-t)^2.5
    local fade=(1-t)^1.5
    local color=kill.color or {255,255,255}
    local before=#out.discs
    f.disc(f.mb_radius*(from+(to-from)*e),f.mb_height,0,{color},
        option(opts,'kill_bloom_opacity')*smooth(age/.05)*fade,0,0,'kill-bloom')
    if #out.discs>before then
        local d=out.discs[#out.discs]
        d.inner,d.outer=option(opts,'mb_bloom_center'),option(opts,'mb_bloom_edge')
        d.mid,d.mid_pos=option(opts,'mb_bloom_middle'),option(opts,'mb_bloom_position')
        d.hub=context.argb(mix(color,{255,255,255},option(opts,'mb_bloom_core')),option(opts,'kill_bloom_opacity'))
    end
    return e,fade,false
end
-- Test6.3: the frame arrives frozen at the kill (M.frame); `now` is real time.
function M.mb_kill_freeze(out,now,kill,start,opts,context,f)
    local K=max(.2,option(opts,'kill_time'))
    local k=now-start
    local rgb=kill.color or {255,255,255}
    local fl=flicker(now,option(opts,'kill_mb_flicker'))
    local fade=(1-smooth(k/max(.05,option(opts,'kill_mb_fade'))))*fl
    local drawn=1-smooth(k/max(.05,option(opts,'kill_mb_fade')))
    local own=option(opts,'kill_mb_discs')=='own'
    local function paint(c,a,keep)
        if keep then return scale_alpha(c,a)end
        return tint(c,rgb,a)
    end
    -- Rings: SC and MB alike flicker in the element color and fade together.
    local rings={}
    if fade>0 and k<K then
        for _,v in ipairs(out)do
            v.color,v.tail=tint(v.color,rgb,fade),tint(v.tail,rgb,fade)
            if v.colors then for i,x in ipairs(v.colors)do v.colors[i]=tint(x,rgb,fade)end end
            rings[#rings+1]=v
        end
    end
    for i=#out,1,-1 do table.remove(out,i)end
    for i,v in ipairs(rings)do out[i]=v end
    -- Kill bloom first (its growth drives the glyphs).
    local kb={discs={}}
    local e,bfade,done=kill_bloom_disc(kb,now,kill,start,opts,context,{disc=function(...)
        local saved=out.discs;out.discs=kb.discs;f.disc(...);out.discs=saved end,mb_radius=f.mb_radius,mb_height=f.mb_height})
    local grow_to=option(opts,'mb_bloom_end')*option(opts,'kill_bloom_size')
    local with_bloom=option(opts,'kill_mb_glyphs')=='bloom'
    local gscale=1+(grow_to-1)*e
    local galpha=with_bloom and (done and 0 or (k<option(opts,'kill_bloom_delay')and 1 or bfade))or fade
    local discs={}
    local function glyph_copy(d)
        d.radius=d.radius*(with_bloom and gscale or 1)
        d.color,d.outline=scale_alpha(d.color,galpha),scale_alpha(d.outline,galpha)
        if d.colors then for i,x in ipairs(d.colors)do d.colors[i]=scale_alpha(x,galpha)end end
        if d.hub then d.hub=scale_alpha(d.hub,galpha)end
        if galpha>0 then discs[#discs+1]=d end
    end
    for _,d in ipairs(out.discs)do
        if d.role=='bloom'or d.role=='umbra-bloom'then
            -- The MB's own bloom is drawn back in and fades with the rings.
            if option(opts,'kill_mb_bloom')=='in'then d.radius=d.radius*drawn end
            local a=drawn*fl
            d.color,d.hub=scale_alpha(d.color,a),d.hub and scale_alpha(d.hub,a)or nil
            if d.colors then for i,x in ipairs(d.colors)do d.colors[i]=scale_alpha(x,a)end end
            if a>0 and d.radius>0 then discs[#discs+1]=d end
        elseif kill_glyph_role[d.role]or d.glyph==2 then glyph_copy(d)
        else
            -- Disc with its own glyph lines: the fill flickers out with the
            -- rings; the lines go with the glyphs.
            if (d.glyph or 0)~=0 and (d.outline or 0)~=0 then
                local g={}for key,x in pairs(d)do g[key]=x end
                g.colors={0x00FFFFFF,0x00FFFFFF};g.color=0x00FFFFFF;g.hub=nil;g.glyph=2
                glyph_copy(g)
            end
            d.glyph=0;d.outline=0
            d.color=paint(d.color,fade,own)
            if d.colors then for i,x in ipairs(d.colors)do d.colors[i]=paint(x,fade,own)end end
            if d.hub then d.hub=paint(d.hub,fade,own)end
            if fade>0 then discs[#discs+1]=d end
        end
    end
    for _,d in ipairs(kb.discs)do discs[#discs+1]=d end
    out.discs=discs
    for i=#(out.glyphs3 or {}),1,-1 do
        local x=out.glyphs3[i]
        x.radius=x.radius*(with_bloom and gscale or 1);x.color=scale_alpha(x.color,galpha)
        if galpha<=0 then table.remove(out.glyphs3,i)end
    end
end
local function mb_kill(out,s,now,kill,start,opts,context,f)
    local K=max(.2,option(opts,'kill_time'))
    local k=now-start
    local a=max(.05,option(opts,'kill_mb_gather'))
    local g=smooth(k/a)
    local c=k>a and max(0,1-((k-a)/max(.05,K-a))^max(1,option(opts,'kill_mb_curve')))or 1
    local fill_h
    for _,d in ipairs(out.discs)do if d.role=='property'then fill_h=d.offset break end end
    local delta=fill_h and (f.mb_height-fill_h)or 0
    local bloom={bloom=true,['umbra-bloom']=true,['kill-bloom']=true}
    if option(opts,'kill_mb_rings')=='freeze'then return M.mb_kill_freeze(out,now,kill,start,opts,context,f)end
    for _,v in ipairs(out)do
        if v.part=='ground'or v.part=='sky'then
            v.offset=v.offset+(f.mb_height-v.offset)*g
            v.color,v.tail=scale_alpha(v.color,1-g),scale_alpha(v.tail,1-g)
            if v.colors then for i,x in ipairs(v.colors)do v.colors[i]=scale_alpha(x,1-g)end end
        end
        v.radius=v.radius*c
    end
    for _,d in ipairs(out.discs)do
        if d.role=='mb-glyph'or d.role=='umbra-haze'then d.offset=f.mb_height;d.radius=d.radius*c -- the MB glyph (and haze) meet the MB ring exactly
        elseif not bloom[d.role]then d.offset=d.offset+delta;d.radius=d.radius*c end
    end
    for _,x in ipairs(out.glyphs3 or {})do
        x.offset=x.role=='mb-glyph'and f.mb_height or x.offset+delta;x.radius=x.radius*c
    end
    -- Second bloom: the killing element bursting outward right after the MB's own.
    kill_bloom_disc(out,now,kill,start,opts,context,f)
    if k>=K then
        for i=#out,1,-1 do table.remove(out,i)end
        local kept={}
        for _,d in ipairs(out.discs)do if bloom[d.role]then kept[#kept+1]=d end end
        out.discs=kept;out.glyphs3=nil
    end
end
local function sc_kill(out,s,now,kill,start,opts,context,f)
    local K=max(.2,option(opts,'kill_time'))
    local k=now-start
    local flash=option(opts,'kill_sc_flash')
    local phi=(kill.angle or context.view_angle or 0)+math.rad(option(opts,'kill_seam_angle'))
    local nx,ny=math.cos(phi+pi/2),math.sin(phi+pi/2)
    local sep=option(opts,'kill_sc_split')*f.radius*smooth((k-flash)/(K*.6))
    local turn=option(opts,'kill_sc_turn')*smooth(k/K)
    local span=(f.top and f.bottom)and (f.top-f.bottom)or f.height*.3
    local sag=option(opts,'kill_sc_sag')*span*smooth(k/K)^2
    local buzz=flicker(now,option(opts,'kill_sc_flicker'))
    local vis=option(opts,'kill_sc_ghost')*(1-smooth((k-K*.3)/(K*.7)))*(k>flash and buzz or 1)
    if k>=K then vis=0 end
    -- Glyphs (MB glyphs, the disc's own lines, copies) and blooms flash out.
    local glyph_role={['mb-glyph']=true,['property-trace']=true,['umbra-copy']=true,
        bloom=true,['umbra-bloom']=true,['kill-bloom']=true,awakening=true}
    local discs={}
    for _,d in ipairs(out.discs)do
        if glyph_role[d.role]or d.glyph==2 then
            if k<flash then
                d.color,d.outline=whiten(d.color,1),whiten(d.outline,1)
                if d.colors then for i,x in ipairs(d.colors)do d.colors[i]=whiten(x,1)end end
                discs[#discs+1]=d
            end
        elseif vis>0 then
            local c=whiten(d.color,vis)
            for side=1,2 do
                local h={}for key,v in pairs(d)do h[key]=v end
                h.glyph=0;h.outline=0;h.blend=0
                h.colors={c,0x00FFFFFF};h.color=c
                h.hub=d.hub and whiten(d.hub,vis)or nil
                h.rotation=phi+(side==2 and pi or 0)+turn
                local sign=side==1 and 1 or -1
                h.dx,h.dy=nx*sep*sign,ny*sep*sign
                discs[#discs+1]=h
            end
        end
    end
    out.discs=discs
    if k>=flash then out.glyphs3=nil
    else for _,x in ipairs(out.glyphs3 or {})do x.color=whiten(x.color,1)end end
    -- Rings split into two half arcs along the seam.
    local rings={}
    for _,v in ipairs(out)do
        if vis>0 then
            local c=whiten(v.color,vis)
            local h=v.offset-((v.part=='sky')and sag or 0)
            if v.kind=='arc'then
                local mid=(v.rotation or 0)+math.rad((v.arc_start or 0)+(v.arc_span or 0)/2)
                local sign=math.cos(mid-(phi+pi/2))>=0 and 1 or -1
                local a={}for key,x in pairs(v)do a[key]=x end
                a.color,a.tail,a.colors=c,whiten(v.tail,vis),{c}
                a.offset,a.rotation=h,(v.rotation or 0)+turn
                a.dx,a.dy=nx*sep*sign,ny*sep*sign
                rings[#rings+1]=a
            else
                for side=1,2 do
                    local sign=side==1 and 1 or -1
                    rings[#rings+1]={kind='arc',radius=v.radius,offset=h,width=v.width or 0,pixels=v.pixels,
                        color=c,tail=c,colors={c},rotation=phi+turn,arc_start=side==1 and 0 or 180,arc_span=180,
                        role=v.role,part=v.part,strand=v.strand,gap=0,blend=0,fade=0,fade_length=1,fade_curve=1,
                        fade_direction=1,dx=nx*sep*sign,dy=ny*sep*sign}
                end
            end
        end
    end
    for i=#out,1,-1 do table.remove(out,i)end
    for i,v in ipairs(rings)do out[i]=v end
    -- The seam: a bright line along the killing blow at each ring height.
    local seam=option(opts,'kill_sc_seam')
    if k<seam then
        local alpha=(1-smooth(k/max(.02,seam)))*flicker(now,option(opts,'kill_seam_flicker'),31,17)
        local L=f.radius*1.3
        local ex,ey=math.cos(phi)*L,math.sin(phi)*L
        out.lines={}
        for _,h in ipairs({f.bottom or f.mb_height,f.top})do
            out.lines[#out.lines+1]={-ex,-ey,h,ex,ey,h,context.argb({255,255,255},alpha),3}
        end
    end
end
function M.apply_kill(out,s,now,kill,start,opts,context,f)
    if kill.kind=='mb'then mb_kill(out,s,now,kill,start,opts,context,f)
    else sc_kill(out,s,now,kill,start,opts,context,f)end
end
-- Test6.0: Umbra collapse factor (1 = full size, 0 = gone at the deadline).
function M.umbra_collapse(s,now,opts)
    local t=option(opts,'umbra_collapse_time')
    if t<0 then t=option(opts,'mb_ending')end
    t=max(.05,t)
    local u=clamp((now-(s.mb_close-t))/t,0,1)
    return max(.001,1-u^max(1,option(opts,'umbra_collapse_curve')))
end
-- Test5.7 Umbra endings: the window and the per-frame 3D glyph parameters.
function M.umbra_ending_window(s,opts,has_top)
    -- Test5.8: open = from the link's creation (Umbra's opening) for ending time.
    -- Test5.9: the real MB deadline is always the cap (an ending that would
    -- run past it is squeezed to end exactly there).
    if option(opts,'umbra_ending_when')=='open'then return s.created,min(s.mb_close,s.created+max(.1,option(opts,'umbra_ending_time')))end
    if option(opts,'umbra_ending_when')=='flash'then
        local a=M.umbra_flashed(s,opts,has_top)
        return a,min(s.mb_close,a+max(.1,option(opts,'umbra_ending_time')))
    end
    return s.mb_close-max(.1,option(opts,'mb_ending')),s.mb_close
end
-- Test7.4: the Radiance glow's brightness envelope (0..1) and its peak time.
function M.radiance_glow_envelope(s,now,opts)
    local peak=s.sc_open+(option(opts,'radiance_close')=='sequence'and .3*option(opts,'radiance_lead')or 0)
    local rise=option(opts,'radiance_glow_rise')
    if rise<0 then rise=peak-s.created end
    rise=max(.05,rise)
    local hold,fall=max(0,option(opts,'radiance_glow_hold')),max(.05,option(opts,'radiance_glow_fall'))
    local env
    if now<peak then local x=clamp(1-(peak-now)/rise,0,1);env=x*x*x -- slow ease-in, then a rush
    elseif now<peak+hold then env=1
    else local u=(now-peak-hold)/fall;env=u<1 and 1-u*u*u or 0 end -- ease out, then drop away
    return env*smooth(clamp((s.mb_close-now)/.3,0,1)),peak
end
-- Test7.3: visibility (1 -> 0, shimmering) and blackness (0 -> 1) of the
-- Umbra glyphs in the vanish ending.
function M.umbra_vanish(s,now,opts,has_top)
    if option(opts,'umbra_ending')~='vanish'then return 1,0 end
    local a=M.umbra_ending_window(s,opts,has_top)
    local u=(now-a)/max(.02,option(opts,'umbra_vanish_time'))
    if u<0 then return 1,0 end
    if u>=1 then return 0,1 end
    local shimmer=.5+.5*math.cos(2*pi*option(opts,'umbra_vanish_shimmer')*(now-a))
    return (1-u)*(.35+.65*shimmer),smooth(min(1,u*3))
end
function M.umbra_ending_glyph(s,now,opts,has_top,angle)
    local style=option(opts,'umbra_ending')
    if style~='gyro'and style~='swallow'then return nil end
    local a,b=M.umbra_ending_window(s,opts,has_top)
    if now<a then return nil end
    if now>=b then return nil,true end
    local u,d=now-a,b-a
    if style=='gyro'then
        -- Stand upright, then spin about the vertical axis; shrink away at the end.
        local scale=1
        local f=option(opts,'umbra_gyro_shrink')
        if f>0 and u>d*(1-f)then scale=(1-clamp((u-d*(1-f))/(d*f),0,1))^2 end
        return {tilt=pi/2*smooth(u/max(.05,option(opts,'umbra_gyro_rise'))),
            rotation=angle+2*pi*option(opts,'umbra_gyro_speed')*u,scale=scale,
            clip=option(opts,'umbra_gyro_below')=='half',circle=true,lift=1}
    end
    local orders={together=0,outer=1,inner=2}
    local sink=max(.05,option(opts,'umbra_sink_time'))
    return {rotation=angle,stand=clamp(u/max(.05,option(opts,'umbra_stand_time')),0,1),
        sink=clamp((u-(d-sink))/sink,0,1),pull=option(opts,'umbra_swallow_pull'),
        stagger=option(opts,'umbra_swallow_stagger'),order=orders[option(opts,'umbra_swallow_order')]or 1,
        lift=option(opts,'umbra_swallow_lift'),clip=true,circle=false}
end
-- Test5.6: the Umbra property disc's fill plane (as the terminal disc path).
function M.umbra_plane(opts,details)
    return option(opts,'disc_height')+(details and details.ground_wave or 0)+.006+option(opts,'disc_level4_height')
end
-- Test5.4: when Umbra's last ring has flashed (its bloom starts here).
function M.umbra_flashed(s,opts,has_top)
    local _,count=level4_index(opts,'umbra','ground',1,4,has_top)
    return s.sc_open+option(opts,'umbra_close_time')+(count-1)*option(opts,'umbra_gap')+option(opts,'umbra_flash_time')
end
-- Test5.4: the ending's pulse rhythm (soft: strong/half/strong per mb ending)
-- continued backwards across the window, so it hands over seamlessly.
function M.umbra_pulse(s,now,opts)
    local ending=max(.1,option(opts,'mb_ending'))
    local phase=(now-(s.mb_close-ending))/(ending/3)
    local pulse=math.floor(phase)
    local within=phase-pulse
    if option(opts,'mb_ending_style')=='hard'then return within<.5 and 1 or 0 end
    return (pulse%3==1 and .5 or 1)*math.sin(within*pi)^2
end
-- Returns {index, core, glow, white, smoke, spread} multipliers for one ring.
function M.level4_ring(s,now,opts,name,part,j,n,has_top)
    local index,count=level4_index(opts,name,part,j,n,has_top)
    local q={index=index}
    if option(opts,name..'_close')~='sequence'or now<s.sc_open then return q end
    if name=='radiance'then
        local close=option(opts,'radiance_close_time')
        local lead,fade=option(opts,'radiance_lead'),option(opts,'radiance_fade')
        local step=count>1 and max(0,(close-lead-fade)/(count-1))or 0
        local b=s.sc_open+index*step
        local u=(now-b)/max(.01,lead)
        local gain=option(opts,'radiance_flash')
        if u<0 then q.glow=1
        elseif u<.3 then q.glow=1+gain*smooth(u/.3)
        elseif u<1 then q.glow=(1+gain)*(1-smooth((u-.3)/.7))
        else q.glow=0 end
        q.core=1-smooth((now-(b+lead))/max(.01,fade))
    else
        local m=s.sc_open+option(opts,'umbra_close_time')+index*option(opts,'umbra_gap')
        local ft=option(opts,'umbra_flash_time')
        if now<m then return q end
        if now<m+ft then
            q.white=1
            q.core=1+option(opts,'umbra_flash')*4 -- toward full alpha (clamped)
        elseif option(opts,'umbra_after')~='smoke'then q.core,q.glow=0,0
        else
            q.core=0
            local u=clamp((now-(m+ft))/max(.05,option(opts,'umbra_smoke')),0,1)
            q.smoke=smooth(min(1,u*4)) -- white glow to black over the first quarter
            q.glow=option(opts,'umbra_smoke_opacity')*(1-smooth(u))
            q.spread=option(opts,'umbra_smoke_spread')*smooth(u)
        end
    end
    return q
end
-- Test5.2 Radiance shimmer: patch angle from the far side (view angle =
-- approximate camera direction) to the near side and back.
function M.level4_shimmer(s,now,opts,name,index,view)
    if name~='radiance'then return nil end
    local g=option(opts,'radiance_shimmer')
    if g<=0 then return nil end
    local ramp=1
    if option(opts,'radiance_shimmer_when')=='close'then ramp=smooth((now-s.sc_open)/.3)end
    if ramp<=0 then return nil end
    local period=max(.1,option(opts,'radiance_shimmer_time'))
    local phase=2*pi*(now/period+option(opts,'radiance_shimmer_stagger')*index)
    local base=(view or 0)+math.rad(option(opts,'radiance_shimmer_angle'))
    return {angle=base+pi*(.5-.5*math.cos(phase)),gain=g*ramp}
end
local function level4_name(s)
    if s.step>1 and s.level>=4 then
        if s.properties[1]=='Radiance'then return 'radiance'end
        if s.properties[1]=='Umbra'then return 'umbra'end
    end
end
-- White awakening disc level (0-1) for a wait from created to open and a
-- window ending at close: full through the grow (first third of the wait),
-- then fading until `awakening fade until` (default two-thirds of the wait).
function M.awakening_level(created,open,close,now,opts)
    local span=max(.1,open-created)
    local start=created+span/3 -- the grow ends here, as before
    local mode=tostring(option(opts,'awakening_until'))
    local finish=created+span*2/3
    if mode=='open'then finish=open
    elseif mode=='close'then finish=max(open,close or open)
    elseif tonumber(mode)then
        -- Never outlast the window: past its end the whole display clears,
        -- so cap the timed fade to finish cleanly.
        finish=min(open+tonumber(mode),max(open,close or open))
    end
    return 1-smooth((now-start)/max(.05,finish-start))
end
function M.frame(model,s,now,radius,height,opts,context)
    -- Test5.4: a level-4 link may see its own visual opening length, and
    -- Radiance's large glyph breathes at rest (and falls back after bursts).
    local l4n=level4_name(s)
    if l4n then
        local t=option(opts,l4n..'_open_time')
        if t>=0 then
            local open=s.created+t
            s=setmetatable({sc_open=open,sc_close=max(s.sc_close,open)},{__index=s})
        end
        local over,any={},false
        if option(opts,l4n..'_glyph')=='breath'then over.mb_glyph_rest,over.mb_glyph_after,any='breath','fall',true end
        if l4n=='umbra'and option(opts,'umbra_spin')>=0 then over.disc_speed_level4,any=option(opts,'umbra_spin'),true end
        if any then opts=setmetatable(over,{__index=opts})end
    end
    -- 0.18 kill: an SC kill freezes the frame at its start; progress uses real time.
    local real_now=now
    local kill=option(opts,'kill')and model.kills and model.kills[s.id]or nil
    local kill_start
    if kill then
        local mb_freeze=kill.kind=='mb'and option(opts,'kill_mb_rings')=='freeze'
        kill_start=kill.at+(kill.kind=='sc'and option(opts,'kill_sc_freeze')or mb_freeze and option(opts,'kill_mb_freeze')or 0)
        if real_now<kill_start or real_now>kill_start+option(opts,'kill_time')+2 then kill=nil
        elseif kill.kind=='sc'or option(opts,'kill_mb_rings')=='freeze'then now=kill_start end
    end
    local out={discs={}}
    local display=option(opts,'display')
    local show_sc=display=='both'or display=='sc'
    local show_mb=display=='both'or display=='mb'
    local age=max(0,now-s.created)
    local phase=s.source_expired and 'expired'or M.phase(s,now,opts)
    out.phase=phase
    local opening=model:opening_glyph(s)
    local response=Burst.sample(model,s,now,function(k)return option(opts,k)end)
    if not show_mb then response={idle=0,flash=0,rise=0,release=0,ring=0,ending=false}end
    -- Test6.6: lingering blooms (and the converge fade) may outlive the deadline.
    local linger=show_mb and option(opts,'mb_ending_blooms')=='linger'and option(opts,'mb_bloom')
    local function bloom_alive()
        for _,b in ipairs(model.bursts and model.bursts[s.id]or {})do
            if b.color and now>=b.at and now-b.at<Burst.bloom_life(nil,function(k)return option(opts,k)end)and
                now<s.mb_close+option(opts,'mb_ending_fade')then return true end
        end
    end
    if phase=='expired'and not response.responding and not response.extinguish and not (linger and bloom_alive())then
        if opening then opening.opacity=0 end
        return out
    end
    local mb_strength=not s.source_expired and s.mb_close>now and now>=s.created and clamp((s.mb_close-now)/10,0,1)or 0
    local mb_active=not s.source_expired and s.step>1 and now>=s.created and now<s.mb_close
    local mb_overall=option(opts,'mb_overall')
    local intro=not response.ending and mb_overall>0 and (response.intro or 0)or 0
    out.mb_strength=mb_strength
    -- Added glow spin (turns/sec, negative reverses) on top of each glyph's
    -- own angle; continuous clock so a re-strike never jumps the lit side.
    local glow_turn=2*pi*option(opts,'mb_glow_spin')*max(0,now-s.created)
    local bottom,top,remaining,details=M.positions(s,now,height,opts)
    local clapper=option(opts,'mb_style')=='clapper'
    local terminal=s.step>1 and s.level>=4
    local property_radius=radius*(terminal and .92 or .78)
    local mb_radius=clapper and property_radius+(radius-property_radius)*option(opts,'mb_size')or radius
    -- The MB ring shares the large glyph's steady vertical reference. Use
    -- nominal anchors, never SC vibration, descent or property-transition
    -- blending. A common property plane also avoids a height step at level 4.
    local property_top=option(opts,'disc_height')+.006
    local floor_anchor=option(opts,'ground_height')+option(opts,'ground_lift')
    local mb_height=clapper and property_top+(floor_anchor-property_top)*option(opts,'mb_position')or height*.49
    -- Test5.8: Umbra's MB ring may sit exactly at the black disc's plane.
    if l4n=='umbra'and option(opts,'umbra_mb_height')=='disc'then mb_height=M.umbra_plane(opts,details)end
    -- Test6.5: the MB ring's height for a given ending progress (0..1). Through
    -- the ending the ring settles onto the large glyph's resting plane; Umbra's
    -- collapse keeps it in place. The ring, the converge glyph cap and the
    -- converge blooms all read this one function.
    local ring_descends=clapper and option(opts,'mb_ending_style')~='off'and
        not (l4n=='umbra'and option(opts,'umbra_collapse'))
    local function ring_at(progress)
        if not ring_descends or not progress then return mb_height end
        return mb_height+(option(opts,'disc_height')-mb_height)*option(opts,'mb_ending_drop')*smooth(progress)
    end
    -- Converge: e is the shared eased ending progress (nil outside it).
    local converge=response.ending and response.converge or nil
    local function shrink_toward(r,target)
        local k=converge and option(opts,'mb_ending_shrink')*converge or 0
        return k>0 and r+(target-r)*k or r
    end
    local mb_colors=context.palette(s)
    local mb_color=mb_colors[#mb_colors]
    if clapper and s.level==2 and #mb_colors==2 then
        local cycle=.5-.5*math.cos(age*pi/option(opts,'mb_period'))
        mb_color=mix(mb_colors[1],mb_colors[2],smooth(cycle))
    end
    -- Test4.7: Light's colored inner glows: 0 before the window, rising to
    -- `rings light glow` over the same .3 s opening transition.
    local light_open=1
    if light_white(s,opts)and option(opts,'ring_light_opening')=='off'then
        light_open=smooth((now-(s.sc_open-.15))/.30)
    end
    -- Test4.7: level-3 Light MB ring matches the lowest SC ring's look:
    -- white, the same lit side and the same rotation (MB timing kept).
    local mb_like_ring=light_white(s,opts)and option(opts,'ring_light_mb')=='match'
    if light_white(s,opts)then mb_color=white end -- white breathing for Light
    -- Test5.1: Radiance MB ring = a level-3 Light middle ring (white, lit
    -- side, turns with the disc) with a strong, fast-shifting colored glow.
    local radiance_mb=s.step>1 and s.level>=4 and s.properties[1]=='Radiance'and option(opts,'mb_radiance')=='light'
    if radiance_mb then mb_like_ring,mb_color=true,white end
    if lightdark(s,opts)then
        -- Cycle through the four element colors; at multiplier 2 each color
        -- hands to the next twice as fast as level 2's two-color cycle.
        local four=element_colors(s.properties[1],context)
        local per=option(opts,'mb_period')/max(.05,option(opts,'mb_lightdark_cycle'))
        local position=(age/per)%#four
        local k=math.floor(position)
        mb_color=mix(four[k+1],four[(k+1)%#four+1],smooth(position-k))
    end
    out.ground,out.sky,out.remaining,out.vibration=bottom,top,remaining,details
    local intensity,opacity=option(opts,'intensity'),option(opts,'opacity')
    -- Test5.2 level-4 (Radiance/Umbra link) looks.
    local l4=not opener and s.step>1 and s.level>=4 and (s.properties[1]=='Radiance'or s.properties[1]=='Umbra')
    local l4name=l4 and (s.properties[1]=='Radiance'and 'radiance'or 'umbra')
    local function l4opt(k)return option(opts,l4name..'_'..k)end
    -- Test6.8: sky off = one set of rings. The previous link's sky rings drop
    -- onto the ground rings over the .3 s hand-off, then are gone; the close
    -- sequences and blooms then run as for a single set (has_top false).
    local sky_merge=false
    -- Test7.7 level-4 collapse plan (ring_level4_* defaults). c_h/c_r: where
    -- the previous level 3's rings meet (height, radius as a fraction of
    -- `radius`); h: the four rings' plane this frame; e: expansion 0..1.
    local l4c
    if l4 and option(opts,'ring_level4_open')=='collapse'then
        local target,plane=option(opts,'ring_level4_collapse'),option(opts,'ring_level4_expand')
        if not show_mb then target,plane='ground','ground'end -- no MB ring to meet
        -- Level 4 only ever follows a level 3; previous is nil in a bare
        -- `preview chain` (nothing to collapse: expand from frame 1).
        local from=s.previous
        local ct=from and clamp(option(opts,'ring_level4_collapse_time'),0,.3)or 0
        local et=option(opts,'ring_level4_expand_time')
        if et<0 then et=s.sc_open-s.created-ct end
        et=max(.05,et)
        -- The MB-plane rings keep the ground strike/hum so they still ring.
        local wave=details.ground_wave or 0
        local c_h=target=='ground'and bottom or mb_height+wave
        local final=plane=='mb'and mb_height+wave or bottom
        -- The MB ring as drawn (Umbra scales it by umbra mb size).
        local mb_drawn=mb_radius*(l4name=='umbra'and option(opts,'umbra_mb_size')or 1)
        local c_r=target=='into'and mb_drawn/radius or 1
        local e=1-(1-clamp((age-ct)/et,0,1))^max(1,option(opts,'ring_level4_ease'))
        -- Test7.8 final layout (fractions of radius): innermost ring, step out.
        local spacing=max(0,option(opts,'ring_level4_spacing'))
        local inner=plane=='mb'and mb_drawn/radius+option(opts,'ring_level4_gap')or 1-1.5*spacing
        l4c={from=from,ct=ct,c_h=c_h,c_r=c_r,h=c_h+(final-c_h)*e,e=e,target=target,plane=plane,
            inner=inner,spacing=spacing}
        -- Ground rings only: the level 3's sky rings are drawn by the collapse.
        if top then top=nil;out.sky=nil end
        out.level4_open=l4c
    end
    local umbra_black -- Test7.1: the black disc drawn this frame (haze anchor)
    if l4 and l4opt('sky')=='off'and top then
        if s.previous and age<.3 then top,sky_merge=top+(bottom-top)*smooth(age/.3),true else top=nil end
        out.sky=top
    end
    local has_top=top~=nil and not sky_merge
    if l4 and l4opt('opacity')>=0 then opacity=l4opt('opacity')end
    local px,glow=max(1,option(opts,'width')),option(opts,'glow')
    local opener=s.step==1
    local progress=clamp(age/max(.1,s.sc_open-s.created),0,1)
    local color_t=opener and smooth(progress*1.5)or smooth((now-(s.sc_open-.15))/.30)
    local flash=s.suppress_impact and 0 or clamp(1-age/.3,0,1)*min(1,intensity)
    local fading=phase=='expiration'or phase=='terminal'
    local boundary=s.closed and s.sc_open or s.sc_close
    local fade=fading and 1-smooth((now-boundary)/option(opts,'fade_duration'))or 1
    local function packed(colors,a)
        local r={}for _,c in ipairs(colors)do r[#r+1]=context.argb(c,a)end return r
    end
    local function band(r,h,colors,a,pixels,role,part,strand,rotation,lit)
        if a<=.002 or r<.01 then return end
        r=min(r,100)
        local p=packed(colors,a)
        local mode=option(opts,'ring_blend')
        local smooth_mode=mode=='gradient'or mode=='firm'
        local burst_glow=role=='burst-glow'
        local shade=burst_glow and option(opts,'mb_glow_shade')or option(opts,'ring_shade')
        local eligible=#colors<=2 and (burst_glow or (not opener and (part=='ground'or part=='sky'))
            or (part=='mb'and mb_like_ring))
        if eligible and smooth_mode and (shade>0 or (mode=='firm'and #colors==2))then
            -- Lit side: one side slightly brighter, the opposite slightly
            -- dimmer; the native gradient blends alpha too, so it turns with
            -- the ring. gradient: A+ | mid | B- | mid (even fade).
            -- firm: A+ | A | B- | B — each color holds through its half and
            -- the fade concentrates where they meet (four-stop "harder" blend).
            local c1,c2=colors[1],colors[#colors]
            if mode=='firm'then
                p={context.argb(c1,a*(1+shade)),context.argb(c1,a*(1+shade*.35)),
                    context.argb(c2,a*(1-shade)),context.argb(c2,a*(1-shade*.35))}
            elseif #colors==1 then
                p={context.argb(c1,a*(1+shade)),context.argb(c1,a*(1-shade))}
            else
                local middle=mix(c1,c2,.5)
                p={context.argb(c1,a*(1+shade)),context.argb(middle,a),
                    context.argb(c2,a*(1-shade)),context.argb(middle,a)}
            end
        end
        local forced
        if lit and lit.gain>0 then
            -- Test5.2 shimmer: a bright patch at `lit.angle` fading to a dim
            -- opposite side (native four-stop gradient, which turns with the
            -- ring rotation, so the rotation carries the patch angle).
            local c,g=colors[1],lit.gain
            p={context.argb(c,a*(1+g)),context.argb(c,a),context.argb(c,a*max(0,1-g)),context.argb(c,a)}
            rotation,forced=lit.angle,1
        end
        out[#out+1]={radius=r,offset=h,width=0,pixels=pixels,color=p[1],colors=p,
            rotation=rotation or 0,role=role,part=part,strand=strand,
            gap=opener and (part=='ground'or part=='sky')and option(opts,'opener_gap')or 0,
            blend=forced or ((burst_glow or not opener)and #p>1 and smooth_mode and 1 or 0)}
        local entry=out[#out]
        if opener and (part=='ground'or part=='sky')and entry.gap>0 then
            -- Opener arc fade (native 0.8.0). Openers spin toward increasing
            -- angle, so +1 keeps the end facing the spin bright ("lead").
            local fade=option(opts,'opener_fade')*(role=='glow'and option(opts,'opener_fade_glow')or 1)
            if fade>0 then
                entry.fade=min(1,fade)
                entry.fade_length=option(opts,'opener_fade_length')
                entry.fade_curve=option(opts,'opener_fade_curve')
                entry.fade_direction=option(opts,'opener_fade_end')=='trail'and -1 or 1
            end
        end
    end
    local function arc(r,h,lead,tail,a,pixels,role,part,strand,rotation,start,span)
        if a<=.002 or r<.01 then return end
        local fade=option(opts,'opener_fade')*(role=='glow'and option(opts,'opener_fade_glow')or 1)
        out[#out+1]={kind='arc',radius=min(r,100),offset=h,width=0,pixels=pixels,
            color=context.argb(lead,a),tail=context.argb(tail,a),colors={context.argb(lead,a)},
            rotation=rotation or 0,arc_start=start,arc_span=span,role=role,part=part,strand=strand,gap=0,blend=0,
            fade=min(1,max(0,fade)),fade_length=option(opts,'opener_fade_length'),
            fade_curve=option(opts,'opener_fade_curve'),
            fade_direction=option(opts,'opener_fade_end')=='trail'and -1 or 1}
    end
    -- extra (Test5.2): {lit=shimmer, glow=glow alpha scale, core=core alpha
    -- scale, spread=glow radius growth} for the level-4 close sequences.
    local function ring(r,h,colors,a,part,strand,rotation,light,glow_colors,glow_gain,extra)
        extra=extra or {}
        local opening=opener and (part=='ground'or part=='sky')
        local mode=opening and option(opts,'opener_glow')or 'color'
        if glow>0 and light~=false and mode~='off'then
            local surround=mode=='black'and {{0,0,0}}or glow_colors or colors
            band(r*(1+(extra.spread or 0)),h,surround,a*.24*glow*(glow_gain or 1)*(extra.glow or 1),px+4*min(glow,3),'glow',part,strand,
                opening and rotation or (rotation or 0)*option(opts,'ring_glow_spin'),extra.lit)
        end
        band(r,h,colors,a*(extra.core or 1),px,'core',part,strand,rotation)
    end
    local disc_cap=(context.native_level or 9)>=10 and 16 or 8
    local function disc(r,h,angle,colors,a,glyph,outline,role,stroke_color)
        -- Native 0.10.0 holds 16 discs (blooms and their glyph copies);
        -- earlier DLLs 8. Blooms are drawn last, so they drop first.
        if (a<=.002 and outline<=.002)or r<.01 or #out.discs>=disc_cap then return end
        r=min(r,100)
        local p=packed(colors,a)
        local mode=option(opts,'disc_blend')
        if mode=='firm'and #p==2 then p={p[1],p[1],p[2],p[2]}end -- hold, then meet
        out.discs[#out.discs+1]={radius=r,offset=h,rotation=angle,color=p[1],colors=p,
            glyph=glyph,outline=context.argb(stroke_color or white,outline),role=role,
            blend=#p>1 and (mode=='gradient'or mode=='firm')and 1 or 0}
    end
    local electric=1
    if not opener and s.level==3 then electric=.68+.32*sin(age*11)^2
    elseif not opener and s.level>=4 then electric=(.37+.63*sin(age*23)^2)*(.72+.28*sin(age*28)^2)end
    local sections=opener and option(opts,'opener_layout')=='sections'and (context.native_level or 9)>=9
    if show_sc and phase~='mb-only'and phase~='expired'and sections then
        -- Test4.0: each property owns an equal section of the circle; its
        -- elements are stacked arcs at the same radius, lifted by spacing.
        local alpha=opacity*option(opts,'brightness')*(phase=='pre'and .78 or .95)*fade
        local n=#s.properties
        local gap=({90,60,30})[n]or 30
        local section=(360-n*gap)/n
        local rotation=M.rotation(s,now,opts)
        local function shade(c,head)
            local target=(not head)and option(opts,'opener_muted')and muted(c)or c
            return mix(mix(white,target,color_t),white,flash)
        end
        local mode=option(opts,'opener_glow')
        out.strands=0
        for k,p in ipairs(s.properties)do
            local start=(k-1)*(section+gap)+gap/2
            local arcs=opener_arcs(p,context)
            for idx,pair in ipairs(arcs)do
                out.strands=out.strands+1
                local lead,tail=shade(pair[1],pair.head),shade(pair[2],false)
                local lift=(#arcs-idx)*option(opts,'opener_spacing')
                local strand=(k-1)*4+idx
                for _,place in ipairs({{bottom,'ground'},{top,'sky'}})do
                    if place[1]then
                        local h=place[1]+lift
                        local draw_radius=radius
                        if place[2]=='sky'then draw_radius=radius*M.bell_factor(top-bottom,height,opts)end
                        if glow>0 and mode~='off'then
                            local gl,gt=lead,tail
                            if mode=='black'then gl,gt={0,0,0},{0,0,0}end
                            arc(draw_radius,h,gl,gt,alpha*.24*glow,px+4*min(glow,3),'glow',place[2],strand,rotation,start,section)
                        end
                        arc(draw_radius,h,lead,tail,alpha,px,'core',place[2],strand,rotation,start,section)
                    end
                end
            end
        end
    elseif show_sc and phase~='expired'and (phase~='mb-only'or (l4 and l4opt('close')=='sequence'and now<M.level4_end(s,opts,l4name,has_top)))then
        local specs=specifications(s,context,opts)
        local l3spread=not opener and s.level==3 and option(opts,'ring_level3_open')=='spread'
        if not opener and s.level~=2 and not l3spread and not l4c and age<.16 then specs={{colors={white},radial=1,stack=0}}end
        local l2spread=not opener and s.level==2 and option(opts,'ring_level2_open')=='spread'
            and not (s.previous and s.previous.level==2)
        if (l3spread or l2spread) and age<.3 then
            -- Test7.5/7.6: the full strand list from the first frame, closer
            -- together, separating in step with the .3 s glide (same smoothstep).
            local start=clamp(option(opts,l3spread and 'ring_level3_start'or 'ring_level2_start'),0,1)
            local k=start+(1-start)*smooth(age/.3)
            local spread={}
            for j,spec in ipairs(specs)do
                local copy={}for key,v in pairs(spec)do copy[key]=v end
                copy.stack=(spec.stack or 0)*k
                spread[j]=copy
            end
            specs=spread
        end
        out.strands=#specs
        if l4c and age<l4c.ct then
            -- Test7.7: the previous level 3's rings (ground and sky), turned
            -- white where they were, collapse into one ring, accelerating into
            -- the strike. The four level-4 rings take over at that spot.
            local from=l4c.from
            local pb,pt=M.positions(from,s.created,height,opts)
            local k=(age/l4c.ct)^2
            local a=opacity*option(opts,'brightness')*(phase=='pre'and .78 or .95) -- as the L4 rings
            local n=0
            for _,spec in ipairs(specifications(from,context,opts))do
                for _,place in ipairs({{pb,'ground'},{pt,'sky'}})do
                    if place[1]then
                        local r0=radius*spec.radial
                        if place[2]=='sky'then r0=r0*M.bell_factor(pt-pb,height,opts)end
                        local h0=place[1]+spec.stack
                        n=n+1
                        ring(r0+(radius*l4c.c_r-r0)*k,h0+(l4c.c_h-h0)*k,{white},a,place[2],n,0)
                    end
                end
            end
            out.strands=n
            specs={}
        end
        local l4seq=l4 and l4opt('close')=='sequence'
        local ring_fade=l4seq and 1 or fade -- the sequence does its own fading
        local alpha=opacity*option(opts,'brightness')*(phase=='pre'and .78 or .95)*ring_fade
        if s.level>=3 and not opener then
            -- Test5.7: Umbra's flicker depth and direct core opacity.
            local depth=l4name=='umbra'and option(opts,'umbra_flicker')or .28
            if l4name=='umbra'and option(opts,'umbra_core')>=0 then alpha=option(opts,'umbra_core')*ring_fade end
            alpha=alpha*(1-depth+depth*electric)
        end
        for j,spec in ipairs(specs)do
            local colors={}
            for _,c in ipairs(spec.colors)do
                local target=opener and option(opts,'opener_muted')and muted(c)or c
                local t=color_t
                -- Test5.2: Radiance keeps its opening white; Umbra is black throughout.
                if l4 and l4name=='radiance'and l4opt('look')=='open'then t=0 end
                if l4 and l4name=='umbra'and l4opt('look')=='black'then target,t={0,0,0},1 end
                colors[#colors+1]=mix(mix(white,target,t),white,flash)
            end
            local r=radius*spec.radial
            -- Test7.7: level-4 rings expand from the collapsed ring's radius.
            -- Test7.8: the innermost grows from the collapsed ring to its place;
            -- each outer ring spreads from the innermost on the same ease.
            if l4c then r=radius*(l4c.c_r+(l4c.inner-l4c.c_r)*l4c.e+(j-1)*l4c.spacing*l4c.e)end
            -- classic: only openers and L2 turn, slowing to a stop. disc
            -- (default): every link turns with the property disc, at its stage
            -- speed easing to the disc minimum, so rings and glyph stay in step.
            local rotation=(opener or s.level==2)and M.rotation(s,now,opts)or 0
            if not opener and option(opts,'ring_spin')=='disc'then rotation=M.disc_rotation(s,now,opts)end
            rotation=rotation*(spec.spin or 1) -- Light/Darkness middle strand may turn at its own rate
            for _,place in ipairs({{bottom,'ground'},{top,'sky'}})do
                if place[1]then
                    local h=place[1]+spec.stack
                    if l4c and place[2]=='ground'then h=l4c.h end -- Test7.7 plane
                    local draw_radius=r
                    if place[2]=='sky'then
                        -- Test5.6: Umbra's sky rings keep the ground rings' size.
                        if not (l4name=='umbra'and option(opts,'umbra_sky')=='same')then
                            draw_radius=r*M.bell_factor(top-bottom,height,opts)
                        end
                    end
                    -- Test4.6: Light white look: the four inner rings (top to
                    -- bottom: sky middle, sky lower, ground upper, ground
                    -- middle) glow in the element colors, rotating slowly.
                    local inner_glow
                    if light_white(s,opts)then
                        local index=place[2]=='sky'and (j<=2 and 3-j)or (place[2]=='ground'and j>=2 and 6-j)or nil
                        if index then
                            local four=element_colors('Light',context)
                            local step=age/max(.1,option(opts,'ring_light_cycle'))
                            local k=math.floor(step)
                            local a1=four[(index-1+k)%4+1]
                            local a2=four[(index+k)%4+1]
                            inner_glow=mix(a1,a2,smooth(step-k))
                        end
                    end
                    -- Test5.2 level-4 close sequence and shimmer for this ring.
                    local q={}
                    if l4 then q=M.level4_ring(s,now,opts,l4name,place[2],j,#specs,has_top)end
                    local lit=l4 and M.level4_shimmer(s,now,opts,l4name,q.index or 0,context.view_angle)or nil
                    local umbra_white=l4 and l4name=='umbra'and l4opt('glow')=='white'
                    if glow>0 and not opener and s.level>=3 then
                        local tint=(s.properties[1]=='Darkness'or s.properties[1]=='Umbra')and {132,74,224}or gold
                        if umbra_white then tint=white end
                        if q.smoke then tint=mix(tint,{0,0,0},q.smoke)end
                        -- Light's gold glow reads close to Earth; the elements
                        -- look may use a white glow instead (rings lightdark tint).
                        if lightdark(s,opts)and s.properties[1]=='Light'and option(opts,'ring_lightdark_tint')=='white'then tint=white end
                        if light_white(s,opts)then tint=inner_glow or white end
                        band(draw_radius*(1+(q.spread or 0)),h,{tint},opacity*.32*glow*electric*ring_fade*(q.glow or 1)*
                            (inner_glow and option(opts,'ring_light_glow')*light_open or 1),px+6*min(glow,3),'glow',place[2],j,
                            rotation*option(opts,'ring_glow_spin'),lit)
                    end
                    local core_colors=colors
                    if q.white then
                        core_colors={}
                        for i,c in ipairs(colors)do core_colors[i]=mix(c,white,q.white)end
                    end
                    local glow_colors=inner_glow and {inner_glow}or nil
                    if umbra_white then glow_colors={white}end
                    if q.smoke and glow_colors then glow_colors={mix(glow_colors[1],{0,0,0},q.smoke)}
                    elseif q.smoke then glow_colors={}for i,c in ipairs(colors)do glow_colors[i]=mix(c,{0,0,0},q.smoke)end end
                    ring(draw_radius,h,core_colors,alpha,place[2],j,rotation,nil,
                        glow_colors,inner_glow and option(opts,'ring_light_glow')*light_open or nil,
                        {lit=lit,glow=q.glow,core=q.core,spread=q.spread})
                end
            end
        end
    end
    -- Test7.7: from here on "the ground rings" means the level-4 ring plane,
    -- so the Radiance glow, Umbra's ring-height blooms and the kill halves
    -- follow the rings around the MB ring.
    if l4c then bottom=l4c.h end
    -- One pooled large glyph: opener fill, continuous breath and layered MB
    -- bloom. Clapper strikes contract/settle along the property return curve.
    if opening then
        local progress=clamp((now-opening.created)/max(.1,opening.open-opening.created),0,1)
        local grow=1-(1-clamp(progress*3,0,1))^3
        local initial=0
        if show_sc and opening.opener_seen and option(opts,'awakening')then
            local level=M.awakening_level(opening.created,opening.open,opening.close,now,opts)
            -- A link takes over: finish quickly and continuously, no pop.
            if s.step>1 then level=level*(1-smooth((now-s.created)/.3))end
            initial=option(opts,'awakening_opacity')*opacity*level
        end
        if initial>0 and s.step>1 then
            -- The link's large MB glyph now owns the pooled shape, so the
            -- lingering awakening disc finishes as its own fill disc.
            local before=#out.discs
            disc(radius*.96*option(opts,'awakening_size'),option(opts,'disc_height'),0,{white},initial,0,0,'awakening')
            if #out.discs>before then
                local d=out.discs[#out.discs]
                d.inner,d.outer=option(opts,'awakening_inner'),option(opts,'awakening_outer')
            end
            initial=0
        end
        -- Test6.7: every link that leaves a new window open gets its own
        -- white awakening disc, on the opener's exact grow/fade curve measured
        -- against the link's own wait (created -> sc_open). When the next link
        -- lands, the previous disc finishes over .3 s instead of popping.
        if show_sc and s.step>1 and option(opts,'awakening')and option(opts,'awakening_links')then
            local cur=opening.link
            if not cur or cur.created~=s.created then
                if cur then opening.link_prev={created=cur.created,open=cur.open,close=cur.close,handoff=s.created}end
                cur=not s.closed and {created=s.created,open=s.sc_open,close=s.sc_close}or nil
                opening.link=cur
            end
            local function link_disc(a,level)
                local fill=option(opts,'awakening_opacity')*opacity*level
                if fill<=0 then return end
                local p=clamp((now-a.created)/max(.1,a.open-a.created),0,1)
                local g=1-(1-clamp(p*3,0,1))^3
                local before=#out.discs
                disc(radius*.96*g*option(opts,'awakening_size'),option(opts,'disc_height'),0,{white},fill,0,0,'awakening')
                if #out.discs>before then
                    local d=out.discs[#out.discs]
                    d.inner,d.outer=option(opts,'awakening_inner'),option(opts,'awakening_outer')
                end
            end
            local prev=opening.link_prev
            if prev then
                local k=1-smooth((now-prev.handoff)/.3)
                if k<=0 or now<prev.handoff then opening.link_prev=nil
                else link_disc(prev,M.awakening_level(prev.created,prev.open,prev.close,now,opts)*k)end
            end
            if cur and now>=cur.created then link_disc(cur,M.awakening_level(cur.created,cur.open,cur.close,now,opts))end
        end
        local role='mb-glyph'
        local fill=0
        local color=white -- steady neutral breath; only confirmed MBs tint it
        local resting_radius=clapper and s.step>1 and mb_radius or radius*.96
        opening.radius=resting_radius
        opening.offset=option(opts,'disc_height')
        opening.rotation=clapper and -2*pi*option(opts,'mb_spin')*max(0,now-opening.created)or 0
        -- Test5.4 Radiance glyph: still, own size, buzzing with the ground rings.
        -- Test5.6 Umbra glyph: turns with the disc, sized like the Umbra MB ring.
        local l4_glyph=l4name and option(opts,l4name..'_glyph')=='breath'
        if l4_glyph and l4name=='radiance'then
            opening.rotation=0
            resting_radius=resting_radius*option(opts,'radiance_glyph_size');opening.radius=resting_radius
        elseif l4_glyph then
            opening.rotation=M.disc_rotation(s,now,opts)*option(opts,'umbra_glyph_spin')
            resting_radius=mb_radius*option(opts,'umbra_mb_size')*option(opts,'umbra_glyph_size');opening.radius=resting_radius
        end
        opening.opacity=response.idle
        if l4_glyph and option(opts,l4name..'_glyph_opacity')>=0 then
            -- Own opacity: the breath itself (0-1 of its peak), not scaled by mb idle.
            opening.opacity=min(1,response.idle/max(.001,option(opts,'mb_idle')*option(opts,'mb_breath_gain')))
        end
        -- Test4.8 rest hidden: no floor breathing; the window-opening flash,
        -- bursts and the ending still light it.
        -- Test6.5 converge: stays hidden until the converge ramp brings it in.
        if clapper and option(opts,'mb_glyph_rest')=='hidden'and (converge or not response.ending)then opening.opacity=0 end
        local fades=clapper and option(opts,'mb_glyph_after')=='fade'
        if initial>0 then
            role='awakening';fill=initial
            opening.radius=opening.radius*grow*option(opts,'awakening_size');opening.opacity=0
        end
        if response.responding then
            fill=0;role='mb-glyph'
            if clapper then
                local energy=option(opts,'mb_burst')>0 and (response.property or 0)or 0
                local strike=energy*(1+(option(opts,'mb_burst')-1)*(1-energy))
                opening.radius=resting_radius*(1+option(opts,'mb_expand')*energy)
                local rest=option(opts,'disc_height')
                local ring_fraction=option(opts,'mb_glyph_height')
                if ring_fraction>0 then
                    -- Rise toward (or just past) the steady MB ring, using the
                    -- SAME return energy as the lifted property trace so both
                    -- land together. A re-strike continues from the current
                    -- height (response.glyph_rise) instead of dropping first.
                    -- Test4.8 fade: stay at the risen height (no fall); the
                    -- opacity below fades along the same return energy.
                    local rise=(response.glyph_rise or 1)*(fades and 1 or energy)
                    opening.offset=rest+(mb_height-rest)*ring_fraction*rise
                else
                    opening.offset=rest+height*option(opts,'mb_rise')*(fades and 1 or energy)
                end
                color=mix(color,response.element,strike*option(opts,'mb_glyph_tint'))
                opening.opacity=opening.opacity+(1-opening.opacity)*strike
            else
                color=mix(response.element,white,response.white)
                opening.radius=resting_radius*(1+option(opts,'mb_expand')*response.rise)
                opening.offset=option(opts,'disc_height')+height*option(opts,'mb_rise')*response.rise
                opening.opacity=response.release
            end
            -- Test6.4 mb glyph opacity: scales the confirmed response (and its
            -- fade/fall) here, before the window-opening intro and the closing
            -- flash, so neither of those signals is dimmed by it.
            opening.opacity=opening.opacity*option(opts,'mb_glyph_opacity')
        end
        if converge and clapper then
            -- Test6.5: a rising glyph may not pass the descending MB ring. The
            -- cap starts at the glyph's normal highest point (no jump when the
            -- ending begins) and closes onto the ring over the first quarter
            -- of the same shared progress, then is the ring's height.
            -- A glyph that has reached it is held there (and keeps its
            -- brightness) instead of fading or falling back to the floor.
            local rest=option(opts,'disc_height')
            local fraction=option(opts,'mb_glyph_height')
            local top_normal=fraction>0 and rest+(mb_height-rest)*fraction or rest+height*option(opts,'mb_rise')
            local ring_now=ring_at(response.ending_progress)
            local cap=ring_now+max(0,top_normal-mb_height)*(1-smooth((response.ending_progress or 0)*4))
            local hold=opening.converge_hold
            if hold and (hold.close~=s.mb_close or now<hold.at)then hold=nil;opening.converge_hold=nil end
            if response.responding and opening.offset>=cap-1e-4 then
                if not hold then hold={close=s.mb_close,at=now,alpha=0};opening.converge_hold=hold end
                hold.alpha=max(hold.alpha,opening.opacity)
            end
            if hold then
                opening.offset=cap;opening.opacity=max(opening.opacity,hold.alpha)
            elseif opening.offset>cap then opening.offset=cap end
        end
        local glyph_intro=intro*option(opts,'mb_intro_glyph')
        if glyph_intro>0 then
            -- A new MB window may announce itself more quietly on the large
            -- glyph than on the property disc and ring (mb intro glyph).
            role='mb-glyph';fill=0
            color=mix(color,white,glyph_intro)
            opening.opacity=opening.opacity+(1-opening.opacity)*glyph_intro
        end
        if converge then
            -- Test6.5 converge: the ground glyph emerges and whitens as the
            -- ring descends, peaking as it arrives (not scaled by mb glyph
            -- opacity, which only applies to the confirmed response above).
            local k=converge*option(opts,'mb_effects')
            color=mix(color,white,k)
            opening.opacity=(opening.opacity+(1-opening.opacity)*k)*(response.extinguish or 1)
            opening.radius=shrink_toward(opening.radius,property_radius*option(opts,'disc_size_lines'))
        elseif response.ending then
            -- A closing signal wins over a simultaneous hit's color/alpha,
            -- while an already rising glyph keeps its continuous trajectory.
            color=white
            opening.opacity=response.end_flash*option(opts,'mb_effects')
        end
        if l4_glyph and l4name=='radiance'then
            if option(opts,'radiance_glyph_wobble')=='always'then
                opening.offset=opening.offset+M.steady_wobble(s,now,opts)
            elseif option(opts,'radiance_glyph_buzz')then
                opening.offset=opening.offset+(details.ground_wave or 0)
            end
        end
        if l4_glyph and l4name=='umbra'then
            -- Rest at the black disc's exact plane (a burst still lifts it from there).
            opening.offset=opening.offset-option(opts,'disc_height')+M.umbra_plane(opts,details)
            -- Test6.0: held just above the black hole the whole time (bursts included).
            if option(opts,'umbra_glyph_lift')>=0 then opening.offset=M.umbra_plane(opts,details)+option(opts,'umbra_glyph_lift')end
        end
        if role=='mb-glyph'then
            -- Test5.4: Radiance's glyph opacity replaces the MB overall opacity.
            local own=l4_glyph and option(opts,l4name..'_glyph_opacity')or -1
            opening.opacity=opening.opacity*(own>=0 and own or mb_overall)
            -- Test7.1: the Radiance floor glyph brightens with the ring's descent.
            local curve=l4_glyph and l4name=='radiance'and response.ending and ending_curves[option(opts,'radiance_ending_glyph')]
            if curve then
                local span=mb_height-ring_at(1)
                local x=span>1e-6 and clamp((mb_height-ring_at(response.ending_progress))/span,0,1)or clamp(response.ending_progress or 0,0,1)
                local peak=option(opts,'radiance_ending_peak')*(response.extinguish or 1)
                opening.opacity=opening.opacity+(peak-opening.opacity)*curve(x)
            end
        end
        if role=='mb-glyph'and l4name=='umbra'then
            local v,blk=M.umbra_vanish(s,now,opts,has_top)
            if v<1 then opening.opacity=opening.opacity*v;color=mix(color,{0,0,0},blk)end -- Test7.3
        end
        out.awakening_glyph=opening
        local before=#out.discs
        local bare=role=='mb-glyph'and l4_glyph and l4name=='radiance'and not option(opts,'radiance_glyph_circle')
            and (context.native_level or 0)>=11
        if bare then
            -- Test6.9: the same strokes, flat, without the circle the 2D disc glyph always draws.
            if opening.opacity>.002 and opening.radius>=.01 then
                out.glyphs3=out.glyphs3 or {}
                out.glyphs3[#out.glyphs3+1]={radius=min(opening.radius,100),offset=opening.offset,rotation=opening.rotation,
                    color=context.argb(color,opening.opacity),role='mb-glyph',circle=false}
            end
        else
        disc(opening.radius,opening.offset,fill>0 and 0 or opening.rotation,{white},fill,fill>0 and 0 or 2,
            fill>0 and 0 or opening.opacity,role,color)
        end
        if role=='awakening'and #out.discs>before then
            -- Radial fill: center and rim opacity multipliers (native 0.7.0).
            local d=out.discs[#out.discs]
            d.inner,d.outer=option(opts,'awakening_inner'),option(opts,'awakening_outer')
        end
        if clapper and response.element and (response.shimmer or 0)>0 then
            -- The shimmer follows the glyph: white unless mb glyph tint > 0.
            local shimmer_color=mix(white,response.element,option(opts,'mb_glyph_tint'))
            band(opening.radius,opening.offset,{shimmer_color},mb_overall*min(1,response.shimmer)*.65,
                px+10*option(opts,'mb_glow_width'),'burst-glow','mb-glyph',0,opening.rotation+glow_turn)
        end
    end
    if option(opts,'discs')then
        local sc_life=(phase=='mb-only'or phase=='expired')and 0 or phase=='pre'and 1 or s.closed and fade or remaining
        local life=max(show_sc and sc_life or 0,show_mb and mb_strength or 0)
        if show_mb and s.step>1 and s.mb_close>s.created then
            -- Keep the elemental foundation steady, then gently extinguish
            -- it across the SAME ending interval as the white MB signals.
            life=mb_active and smooth((s.mb_close-now)/option(opts,'mb_ending'))or 0
            -- Test6.0: with the collapse, Umbra's disc stays opaque to the end (it shrinks instead).
            if l4name=='umbra'and option(opts,'umbra_collapse')then life=mb_active and 1 or 0 end
            -- Test7.1: riding Radiance discs stay until the final fade.
            if l4name=='radiance'and option(opts,'radiance_ending_ride')then life=mb_active and 1 or (response.extinguish or 0)end
        end
        local reveal=opener and smooth(progress*5)or 1
        local fill=option(opts,'disc_opacity')*opacity*life*reveal
        -- Test5.2: a level-4 disc opacity replaces discs opacity x overall opacity.
        if l4 and l4opt('disc_opacity')>=0 then fill=l4opt('disc_opacity')*life*reveal end
        -- Test4.2: opener discs may use their own line opacity (-1 = same
        -- as discs outline).
        local line=option(opts,'disc_outline')
        if opener and option(opts,'opener_disc_outline')>=0 then line=option(opts,'opener_disc_outline')end
        local outline=line*opacity*life*reveal
        local base=option(opts,'disc_height')+details.ground_wave
        if l4name=='radiance'and option(opts,'radiance_ending_ride')and response.ending then
            base=base+ring_at(response.ending_progress)-mb_height -- Test7.1: ride down with the MB ring
        end
        local glyph=option(opts,'disc_style')=='outline'and 2 or option(opts,'disc_style')=='fill'and 0 or 1
        local properties=opener and s.properties or {s.properties[1]}
        for j,p in ipairs(properties)do
            local colors=property_palette(p,context)
            local terminal=not opener and s.level>=4
            -- Test4.4 Light/Darkness 'elements' look: white/black center (hub)
            -- blending out to a rim of the four element colors.
            local hub
            if not terminal and (p=='Light'or p=='Darkness')and option(opts,'disc_lightdark')=='elements'then
                colors={}
                for _,e in ipairs(context.elements(p))do colors[#colors+1]=context.element_color(e)or white end
                hub=p=='Darkness'and {0,0,0}or white
            end
            local terminal_stroke=white
            if terminal then
                local dark=p=='Umbra'or p=='Darkness'
                colors={dark and {0,0,0}or white}
                terminal_stroke=dark and {255,242,204}or {0,0,0}
                -- Test5.8: Umbra's glyph lines pure white by default.
                if l4name=='umbra'and option(opts,'umbra_lines_color')=='white'then terminal_stroke=white end
            end
            local flash=response.flash*option(opts,'mb_floor')
            if clapper then flash=mb_overall>0 and (response.property or 0)*option(opts,'mb_floor')or 0 end
            if show_mb and s.step>1 then flash=flash*life end
            local disc_fill=fill+(max(fill,mb_overall*life)-fill)*flash
            local disc_outline=outline+(max(outline,mb_overall*life)-outline)*flash
            if clapper then
                disc_fill=fill+(mb_overall*life-fill)*flash
                disc_outline=outline+(mb_overall*life-outline)*flash
            else flash=flash*mb_overall end
            local stroke=response.element and mix(terminal_stroke,response.element,flash)or terminal_stroke
            if flash>0 then
                for i,c in ipairs(colors)do colors[i]=mix(c,clapper and response.element or white,flash)end
                if hub then hub=mix(hub,clapper and response.element or white,flash)end
            end
            local disc_intro=intro*option(opts,'mb_intro_disc')
            if disc_intro>0 then
                disc_fill=disc_fill+(mb_overall-disc_fill)*disc_intro
                disc_outline=disc_outline+(mb_overall-disc_outline)*disc_intro
                stroke=mix(stroke,white,disc_intro)
                for i,c in ipairs(colors)do colors[i]=mix(c,white,disc_intro)end
                if hub then hub=mix(hub,white,disc_intro)end
            end
            -- Test5.7: Umbra's disc may hold its opacity through the flashes.
            if l4name=='umbra'and option(opts,'umbra_disc_steady')then disc_fill=fill end
            local angle=M.disc_rotation(s,now,opts)
            -- Stage-specific fill/line sizing and radial fade (opener or links).
            local fill_size=opener and option(opts,'opener_disc_size')or option(opts,'disc_size')
            local line_size=opener and 1 or option(opts,'disc_size_lines')
            local inner=opener and option(opts,'opener_disc_inner')or option(opts,'disc_inner')
            local outer=opener and option(opts,'opener_disc_outer')or option(opts,'disc_outer')
            -- Test5.1: level-4 overrides (-1 = same as discs), optional middle point.
            local middle,lift=nil,0
            if terminal then
                local function own(key,fallback)local v=option(opts,key)return v>=0 and v or fallback end
                inner,outer=own('disc_level4_inner',inner),own('disc_level4_outer',outer)
                fill_size=own('disc_level4_size',fill_size)
                line_size=option(opts,'disc_level4_size')>=0 and fill_size or line_size
                -- Test5.4: Umbra may grow far past the shared level-4 size.
                if l4name=='umbra'and option(opts,'umbra_disc_size')>=0 then
                    fill_size=option(opts,'umbra_disc_size');line_size=fill_size
                end
                if option(opts,'disc_level4_middle')>=0 then middle=option(opts,'disc_level4_middle')end
                if l4name=='umbra'then
                    -- Test5.7: Umbra's own disc shape (-1 = discs level4).
                    inner,outer=own('umbra_disc_inner',inner),own('umbra_disc_outer',outer)
                    if option(opts,'umbra_disc_middle')>=0 then middle=option(opts,'umbra_disc_middle')end
                end
                lift=option(opts,'disc_level4_height')
            end
            local function finish_fill(d,a)
                if inner~=1 or outer~=1 or middle then d.inner,d.outer=inner,outer end -- 1 1 = untouched
                if middle then
                    local pos=option(opts,'disc_level4_position')
                    if l4name=='umbra'then pos=M.umbra_disc_position(s,now,opts)end
                    d.mid,d.mid_pos=middle,pos
                end
                if hub then d.hub=context.argb(hub,a)end
            end
            local h=base+.006+(j-1)*.008+lift
            if terminal or clapper then
                -- Separate planes let a struck trace lift while its fill
                -- remains anchored. Terminal traces keep their .006 clearance.
                local r=terminal and radius*.92 or radius*(.78-(j-1)*.11)
                local respond=flash>0 or disc_intro>0
                if l4name=='radiance'and j==1 and option(opts,'radiance_stack')then
                    -- Test5.5: bottom white, middle Fusion<->Fragmentation, then the top.
                    local base_h=h+option(opts,'radiance_stack_height')
                    local spacing=option(opts,'radiance_stack_spacing')
                    local mark=#out.discs
                    disc(r*fill_size*option(opts,'radiance_bottom_size'),base_h,angle,{white},
                        option(opts,'radiance_bottom_opacity')*life,0,0,'radiance-bottom')
                    if #out.discs>mark then finish_fill(out.discs[#out.discs],0)end
                    local fusion,frag=property_palette('Fusion',context),property_palette('Fragmentation',context)
                    local w=.5-.5*math.cos(2*pi*max(0,now-s.created)/max(.1,option(opts,'radiance_middle_cycle')))
                    local mixed={}
                    for i=1,max(#fusion,#frag)do mixed[i]=mix(fusion[i]or fusion[#fusion],frag[i]or frag[#frag],w)end
                    mark=#out.discs
                    disc(r*fill_size*option(opts,'radiance_middle_size'),base_h+spacing,
                        M.disc_rotation(s,now,opts)*option(opts,'radiance_middle_spin'),mixed,
                        option(opts,'radiance_middle_opacity')*life,0,0,'radiance-middle')
                    if #out.discs>mark then finish_fill(out.discs[#out.discs],0)end
                    h=base_h+2*spacing
                end
                if l4name=='umbra'and j==1 and option(opts,'umbra_under')then
                    -- Test7.0: Gravitation<->Distortion disc just under the black disc.
                    local grav,dist=property_palette('Gravitation',context),property_palette('Distortion',context)
                    local w=.5-.5*math.cos(2*pi*max(0,now-s.created)/max(.1,option(opts,'umbra_under_cycle')))
                    local mixed={}
                    for i=1,max(#grav,#dist)do mixed[i]=mix(grav[i]or grav[#grav],dist[i]or dist[#dist],w)end
                    local turn=(option(opts,'umbra_under_steady')and M.steady_rotation(s,now,opts)or angle)*option(opts,'umbra_under_spin')*(option(opts,'umbra_under_direction')=='reverse'and -1 or 1)
                    local mark=#out.discs
                    disc(r*fill_size*option(opts,'umbra_under_size'),h-option(opts,'umbra_under_depth'),turn,mixed,
                        option(opts,'umbra_under_opacity')*life,0,0,'umbra-under')
                    if #out.discs>mark then
                        local d=out.discs[#out.discs]
                        d.inner,d.outer=option(opts,'umbra_under_center'),option(opts,'umbra_under_edge')
                    end
                end
                local before=#out.discs
                local fill_alpha=(glyph==2 and not respond)and 0 or disc_fill
                disc(r*fill_size,h,angle,colors,fill_alpha,0,0,'property')
                if #out.discs>before then finish_fill(out.discs[#out.discs],fill_alpha)end
                if l4name=='umbra'and j==1 then
                    local d=#out.discs>before and out.discs[#out.discs]or nil
                    umbra_black={radius=r*fill_size,pos=d and d.mid_pos or M.umbra_disc_position(s,now,opts),index=d and #out.discs or nil}
                end
                local trace_height=h+(terminal and .006 or 0)
                if clapper and mb_overall>0 then
                    trace_height=trace_height+(response.lift or 0)*option(opts,'mb_floor')
                end
                -- Test5.4: Radiance's own disc lines may be hidden (its large MB glyph breathes instead).
                local hide=l4name=='radiance'and not option(opts,'radiance_disc_lines')
                local trace_radius,trace_alpha=r*line_size,disc_outline
                local trace_stroke=stroke
                if l4name=='umbra'then
                    if option(opts,'umbra_lines_size')>=0 then
                        trace_radius=mb_radius*option(opts,'umbra_mb_size')*option(opts,'umbra_lines_size')
                    end
                    if option(opts,'umbra_lines_opacity')>=0 then trace_alpha=option(opts,'umbra_lines_opacity')*life end
                    -- Test5.7 endings: the glyph leaves its flat plane (native 0.11.0).
                    local g3,gone=nil,false
                    if (context.native_level or 0)>=11 then g3,gone=M.umbra_ending_glyph(s,now,opts,has_top,angle)end
                    if gone then hide=true end -- swallowed/shrunk away: it stays gone
                    local v,blk=M.umbra_vanish(s,now,opts,has_top)
                    if v<=0 then hide=true elseif v<1 then
                        trace_alpha=trace_alpha*v;trace_stroke=mix(stroke or white,{0,0,0},blk) -- Test7.3 black shimmer
                    end
                    if g3 then
                        g3.radius=trace_radius*(g3.scale or 1);g3.offset=trace_height
                        local a=option(opts,'umbra_lines_opacity')>=0 and option(opts,'umbra_lines_opacity')or line*opacity
                        g3.color=context.argb(stroke,a)
                        out.glyphs3=out.glyphs3 or {};out.glyphs3[#out.glyphs3+1]=g3
                        hide=true
                    end
                end
                disc(trace_radius,trace_height,angle,{white},0,2,
                    ((glyph==0 and not respond)or hide)and 0 or trace_alpha,'property-trace',trace_stroke)
                if clapper and response.element and (response.shimmer or 0)>0 and option(opts,'mb_floor')>0 then
                    band(r*line_size,trace_height,{response.element},mb_overall*min(1,response.shimmer)*option(opts,'mb_floor'),
                        px+12*option(opts,'mb_glow_width'),'burst-glow','property-trace',0,angle+glow_turn)
                end
            else
                local r=radius*(.78-(j-1)*.11)
                local line_style=(flash>0 or disc_intro>0)and 1 or glyph
                local custom=fill_size~=1 or line_size~=1 or inner~=1 or outer~=1 or hub~=nil
                if custom and line_style~=2 then
                    -- Classic path: draw the fill on its own (resized, radial,
                    -- hub) and the glyph lines separately at their own size.
                    local before=#out.discs
                    disc(r*fill_size,h,angle,colors,disc_fill,0,0,'property')
                    if #out.discs>before then finish_fill(out.discs[#out.discs],disc_fill)end
                    if line_style~=0 then disc(r*line_size,h,angle,{white},0,2,disc_outline,'property',stroke)end
                else
                    disc(r,h,angle,colors,disc_fill,line_style,disc_outline,'property',stroke)
                end
            end
        end
    end
    -- MB ring remains tied to its original deadline; response overlays never
    -- reset its fade, the continuation phase, or the property-disc rotation.
    if show_mb and (mb_strength>0 or response.extinguish)then
        local color=mb_color
        local alpha=option(opts,'mb_opacity')+(1-option(opts,'mb_opacity'))*(1-mb_strength)
        if clapper and l4 and option(opts,'mb_level4')=='flicker'then
            -- Test7.9: the bar's level 3/4 electric flicker (`electric` above).
            local d=clamp(option(opts,'mb_level4_depth'),0,1)
            alpha=alpha*(1-d+d*electric)
        elseif clapper then alpha=alpha*(response.breath or 1)end
        -- Test5.4 Umbra MB ring: white ending-style pulses all window long.
        local umbra_mb=l4name=='umbra'and option(opts,'umbra_mb')=='pulse'
        if umbra_mb and not response.ending then
            local fx=option(opts,'mb_effects')
            color=mix(color,white,fx)
            alpha=alpha*(1-fx)+M.umbra_pulse(s,now,opts)*option(opts,'umbra_mb_strength')*fx
        end
        local strength=response.ring*option(opts,'mb_ring')
        if response.element and strength>0 then
            color=mix(color,mix(response.element,white,response.flicker),strength)
            alpha=alpha+(1-alpha)*strength
        end
        if intro>0 then
            color=mix(color,white,intro)
            alpha=alpha+(1-alpha)*intro
        end
        if converge then
            -- Test6.5 converge: one steady brightening toward white, keeping
            -- the ring fully visible all the way down (no pulses, no fade).
            local k=converge*option(opts,'mb_effects')
            color=mix(color,white,k)
            alpha=(alpha+(1-alpha)*k)*(response.extinguish or 1)
        elseif response.ending then
            color=mix(color,white,option(opts,'mb_effects'))
            alpha=alpha*(1-option(opts,'mb_effects'))+response.end_flash*option(opts,'mb_effects')
        end
        -- Through the closing pulses the MB ring settles down onto the large
        -- glyph's resting plane (same radius), reaching it at the real MB
        -- deadline when everything goes dark (shared ring_at above).
        local ring_height=response.ending and ring_at(response.ending_progress)or mb_height
        local mb_rotation=0
        if mb_like_ring then
            -- Same turn as the lowest SC ring (level 3 uses the disc spin
            -- unless rings spin classic, where level 3 does not turn).
            mb_rotation=option(opts,'ring_spin')=='disc'and M.disc_rotation(s,now,opts)or 0
        end
        if radiance_mb then
            -- The Light middle strand's inner glow, cycling Light's four
            -- elements at `mb radiance cycle`; the glow band keeps the SC
            -- ring's glow-to-core proportion at `mb radiance glow` strength.
            local four=element_colors('Light',context)
            local step=age/max(.05,option(opts,'mb_radiance_cycle'))
            local k=math.floor(step)
            local inner=mix(four[(1+k)%4+1],four[(2+k)%4+1],smooth(step-k))
            local gain=option(opts,'mb_radiance_glow')
            local buzz=.68+.32*sin(age*11)^2 -- level-3 electric
            local a=alpha*mb_overall
            -- Test5.2: the MB ring may join the rings' shimmer (after them in the stagger).
            local lit=option(opts,'radiance_shimmer_mb')and M.level4_shimmer(s,now,opts,'radiance',8,context.view_angle)or nil
            if glow>0 then
                band(shrink_toward(mb_radius,property_radius*option(opts,'disc_size_lines')),ring_height,{inner},a*.32*glow*buzz*gain/max(.05,option(opts,'brightness')*.95*(.72+.28*buzz)),
                    px+6*min(glow,3),'glow','mb',0,mb_rotation*option(opts,'ring_glow_spin'),lit)
            end
            ring(shrink_toward(mb_radius,property_radius*option(opts,'disc_size_lines')),ring_height,{color},a,'mb',0,mb_rotation,nil,{inner},gain,{lit=lit})
        else
            local r=mb_radius
            if l4name=='umbra'then r=r*option(opts,'umbra_mb_size')end
            r=shrink_toward(r,property_radius*option(opts,'disc_size_lines'))
            ring(r,ring_height,{color},alpha*mb_overall,'mb',0,mb_rotation)
        end
    end
    -- Test7.0 Umbra haze: a flickering white smoke bloom at the MB ring's height.
    if l4name=='umbra'and show_mb and option(opts,'umbra_haze')and mb_active then
        local presence=smooth((now-s.created)/.3)
        if not option(opts,'umbra_collapse')then presence=presence*smooth((s.mb_close-now)/max(.05,option(opts,'mb_ending')))end
        local speed=option(opts,'umbra_haze_speed')
        local a=option(opts,'umbra_haze_opacity')*presence*flicker(now,option(opts,'umbra_haze_flicker'),23*speed,28*speed)
        local h=(response.ending and ring_at(response.ending_progress)or mb_height)+option(opts,'umbra_haze_lift')
        local R=mb_radius*option(opts,'umbra_mb_size')*option(opts,'umbra_haze_size')
        local mark=#out.discs
        if option(opts,'umbra_haze_style')=='glow'and umbra_black then
            -- Test7.1 glow: white (clear center -> full at the black disc's
            -- middle point -> haze edge) under black (haze black -> clear there).
            local p=umbra_black.radius*umbra_black.pos
            R=max(R,p*1.02)
            disc(R,h,0,{white},a,0,0,'umbra-haze')
            if #out.discs>mark then
                local d=out.discs[#out.discs]
                d.inner,d.outer,d.mid,d.mid_pos=0,option(opts,'umbra_haze_edge'),1,p/R
            end
            local m2=#out.discs
            disc(p,h,0,{{0,0,0}},a,0,0,'umbra-haze')
            if #out.discs>m2 then
                local d=out.discs[#out.discs]
                d.inner,d.outer=option(opts,'umbra_haze_black'),0
            end
        else
            disc(R,h,0,{white},a,0,0,'umbra-haze')
            if #out.discs>mark then
                local d=out.discs[#out.discs]
                d.inner,d.outer=option(opts,'umbra_haze_center'),option(opts,'umbra_haze_edge')
            end
        end
        -- Test7.1 order under: move the haze discs just before the black disc.
        if option(opts,'umbra_haze_order')=='under'and umbra_black and umbra_black.index and #out.discs>mark then
            local moved={}
            for k=#out.discs,mark+1,-1 do table.insert(moved,1,table.remove(out.discs,k))end
            for k,d in ipairs(moved)do table.insert(out.discs,umbra_black.index+k-1,d)end
        end
    end
    -- Test5.4 Umbra flash-out bloom: one ring-shaped black bloom where the
    -- rings flashed out, shrinking (or holding/growing) as it fades.
    -- Test7.4 Radiance glow: two white blooms dancing around the ground rings.
    if l4name=='radiance'and show_sc and option(opts,'radiance_glow')and now<s.mb_close then
        local env=M.radiance_glow_envelope(s,now,opts)
        local a=option(opts,'radiance_glow_opacity')*env
        if a>.002 then
            local theta=2*pi*option(opts,'radiance_glow_speed')*max(0,now-s.created)
            local dance=option(opts,'radiance_glow_dance')
            local ground=bottom or option(opts,'disc_height')
            for k=0,1 do
                local phi=theta+k*pi/2
                local before=#out.discs
                disc(radius*option(opts,'radiance_glow_size')*max(.05,1+dance*math.cos(phi)),
                    ground+dance*radius*.08*sin(2*phi),0,{white},a,0,0,'radiance-glow')
                if #out.discs>before then
                    local d=out.discs[#out.discs]
                    d.inner,d.outer=option(opts,'mb_bloom_center'),option(opts,'mb_bloom_edge')
                    d.mid,d.mid_pos=option(opts,'mb_bloom_middle'),option(opts,'mb_bloom_position')
                end
            end
        end
    end
    if l4name=='umbra'and show_sc and option(opts,'umbra_close')=='sequence'and option(opts,'umbra_after')=='bloom'then
        local start=M.umbra_flashed(s,opts,has_top)
        local life=max(.05,option(opts,'umbra_bloom_time'))
        local age=now-start
        if age>=0 and age<life then
            local t=age/life
            local g=1-(1-t)^option(opts,'mb_bloom_ease')
            local a=option(opts,'umbra_bloom_opacity')*smooth(age/.05)*(1-t)^option(opts,'mb_bloom_fade')
            local where=option(opts,'umbra_bloom_height')
            local base_r=radius*option(opts,'umbra_bloom_size')*max(.01,1+option(opts,'umbra_bloom_growth')*g)
            -- Test5.6 rings: one bloom at each SC ring height (sky follows the bell if used).
            local planes={}
            if where=='rings'then
                planes[1]={bottom or option(opts,'disc_height'),1}
                if top then
                    local bell=option(opts,'umbra_sky')=='bell'and M.bell_factor(top-bottom,height,opts)or 1
                    planes[2]={top,bell}
                end
            else
                planes[1]={where=='disc'and option(opts,'disc_height')+.01 or where=='mb'and mb_height or (bottom or option(opts,'disc_height')),1}
            end
            for _,pl in ipairs(planes)do
                local before=#out.discs
                disc(base_r*pl[2],pl[1],0,{{0,0,0}},a,0,0,'umbra-bloom')
                if #out.discs>before then
                    local d=out.discs[#out.discs]
                    d.inner,d.outer=option(opts,'mb_bloom_center'),option(opts,'mb_bloom_edge')
                    d.mid,d.mid_pos=option(opts,'mb_bloom_middle'),option(opts,'mb_bloom_position')
                end
            end
        end
    end
    -- Test5.6 Umbra glyph copies: spawned every `copies every` s from the
    -- link's creation until the rings have flashed out; each grows from the
    -- floor glyph's size and fades over `copies life`, spinning with the disc
    -- (x copies spin), just under the black disc (placed before it in the
    -- draw order so the opaque disc covers what it overlaps).
    if l4name=='umbra'and show_sc and option(opts,'umbra_copies')then
        local every,life=max(.05,option(opts,'umbra_copies_every')),max(.05,option(opts,'umbra_copies_life'))
        local stop=option(opts,'umbra_copies_until')=='end'and s.mb_close or M.umbra_flashed(s,opts,has_top)
        local r0=mb_radius*option(opts,'umbra_mb_size')*option(opts,'umbra_glyph_size')
        local h=M.umbra_plane(opts,details)-option(opts,'umbra_copies_depth')
        local spin=(option(opts,'umbra_copies_steady')and M.steady_rotation(s,now,opts)or M.disc_rotation(s,now,opts))*option(opts,'umbra_copies_spin')
        local first=math.max(0,math.floor((now-life-s.created)/every))
        local made={}
        for k=first,math.floor((now-s.created)/every)do
            local born=s.created+k*every
            local age=now-born
            if born<stop and age>=0 and age<life then
                local t=age/life
                local before=#out.discs
                disc(r0*(1+(option(opts,'umbra_copies_size')-1)*(1-(1-t)^2)),h,spin,{white},0,2,
                    option(opts,'umbra_copies_opacity')*smooth(age/.05)*(1-t),'umbra-copy',white)
                if #out.discs>before then made[#made+1]=table.remove(out.discs)end
            end
        end
        local at=#out.discs+1
        for k,d in ipairs(out.discs)do if d.role=='property'then at=k break end end
        for i,d in ipairs(made)do table.insert(out.discs,at+i-1,d)end
    end
    -- Test5.6: the Umbra floor glyph may be drawn over the black disc instead.
    if l4name=='umbra'and option(opts,'umbra_glyph_over')then
        for k,d in ipairs(out.discs)do
            if d.role=='mb-glyph'then local moved=table.remove(out.discs,k);out.discs[#out.discs+1]=moved;break end
        end
    end
    -- Test4.9 burst bloom: one per confirmed burst still in its life, oldest
    -- first so the newest draws on top. Lives on its own clock (burst time),
    -- so overlapping bursts each finish their own bloom.
    if show_mb and option(opts,'mb_bloom')and model.bursts and model.bursts[s.id]then
        local life=max(.05,option(opts,'mb_bloom_time'))
        local ease,curve=option(opts,'mb_bloom_ease'),option(opts,'mb_bloom_fade')
        local effects=option(opts,'mb_effects')
        -- With a closing signal, blooms go out with the real MB deadline.
        local closing=1
        local style=option(opts,'mb_ending_style')
        if style=='converge'then
            -- Test6.6: no pre-deadline cut; out with the converge fade after it.
            closing=now<s.mb_close and 1 or response.extinguish or 0
        elseif style~='off'then closing=smooth((s.mb_close-now)/.25)end
        -- Test6.6.2 linger (A 02:15): past the deadline, out over mb ending fade.
        if linger then
            local fade=option(opts,'mb_ending_fade')
            closing=now<s.mb_close and 1 or fade>0 and 1-smooth((now-s.mb_close)/fade)or 0
        end
        -- Test6.6 converge (A 01:47): ring-plane blooms ride the descending MB
        -- ring (where a capped glyph sits) through the ending and stay on the
        -- floor after it; before the ending this is mb height, so no bloom
        -- jumps. A glyph-plane bloom still follows the large glyph.
        local converging=option(opts,'mb_ending_style')=='converge'
        local ring_plane=converging and ring_at(Burst.ending_progress(s,now,function(k)return option(opts,k)end))or mb_height
        local function plane(where)
            if where=='disc'then return option(opts,'disc_height')+.01 end -- just above the property fill
            if where=='glyph'then return opening and opening.offset or mb_height end
            return ring_plane
        end
        local from=option(opts,'mb_bloom_from')
        local to=option(opts,'mb_bloom_to')
        if to=='same'then to=from end
        local function growth(age)
            local t=clamp(age/life,0,1)
            -- Fast-then-slow expansion; fade along (1-t)^curve after a .05 s attack.
            return 1-(1-t)^ease,smooth(age/.05)*(1-t)^curve
        end
        local start,finish=option(opts,'mb_bloom_start'),option(opts,'mb_bloom_end')
        local copies=math.floor(option(opts,'mb_bloom_lines'))
        local delay=option(opts,'mb_bloom_lines_delay')
        for _,burst in ipairs(model.bursts[s.id])do
            local age=now-burst.at
            if age>=0 and age<life+max(0,copies-1)*delay and burst.color then
                local function tint(at)
                    -- White-hot at the strike, settling into the element color.
                    return mix(burst.color,white,option(opts,'mb_bloom_flash')*(1-smooth(at/(life*.3))))
                end
                if age<life then
                    local g,env=growth(age)
                    local a=mb_overall*effects*env*closing
                    local color=tint(age)
                    local before=#out.discs
                    disc(mb_radius*(start+(finish-start)*g),plane(from)+(plane(to)-plane(from))*g,0,{color},a,0,0,'bloom')
                    if #out.discs>before then
                        local d=out.discs[#out.discs]
                        d.inner,d.outer=option(opts,'mb_bloom_center'),option(opts,'mb_bloom_edge')
                        d.mid,d.mid_pos=option(opts,'mb_bloom_middle'),option(opts,'mb_bloom_position')
                        d.hub=context.argb(mix(color,white,option(opts,'mb_bloom_core')),a)
                        if l4name=='umbra'and option(opts,'umbra_burst_center')=='black'then
                            d.hub,d.inner=context.argb({0,0,0},env*closing),1 -- Test7.3 opaque black center
                        end
                    end
                end
                -- Optional copies of the glyph lines grow out from the large
                -- glyph's size, one after another, turning with the glyph.
                for k=1,copies do
                    local at=age-(k-1)*delay
                    if at>=0 and at<life then
                        local g,env=growth(at)
                        local r=mb_radius*(1+(option(opts,'mb_bloom_lines_size')-1)*g)
                        disc(r,plane(from)+(plane(to)-plane(from))*g,opening and opening.rotation or 0,{white},0,2,
                            option(opts,'mb_bloom_lines_opacity')*mb_overall*effects*env*closing,'bloom-lines',tint(at))
                    end
                end
            end
        end
    end
    -- Test6.0 Umbra collapse: every piece of this frame shrinks toward the center.
    if l4name=='umbra'and option(opts,'umbra_collapse')then
        local c=M.umbra_collapse(s,now,opts)
        if c<1 then
            for _,v in ipairs(out)do v.radius=v.radius*c end
            local fade_under=option(opts,'umbra_under_ending')=='fade'
            for _,d in ipairs(out.discs)do
                if fade_under and d.role=='umbra-under'then
                    -- Test7.2: same size, alpha follows the collapse curve.
                    for k,col in ipairs(d.colors or {})do
                        d.colors[k]=math.floor(math.floor(col/16777216)*c+.5)*16777216+col%16777216
                    end
                    if d.color then d.color=math.floor(math.floor(d.color/16777216)*c+.5)*16777216+d.color%16777216 end
                else d.radius=d.radius*c end
            end
            for _,g in ipairs(out.glyphs3 or {})do g.radius=g.radius*c end
        end
    end
    if kill then M.apply_kill(out,s,real_now,kill,kill_start,opts,context,
        {mb_height=mb_height,radius=radius,bottom=bottom,top=top,height=height,mb_radius=mb_radius,disc=disc})end
    -- Kill halves may use the DLL's full 64 rings.
    while #out>(kill and 64 or 32)do table.remove(out,1)end
    return out
end
return M
