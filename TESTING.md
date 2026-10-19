# TESTING.md — Skillchains Resonance UI

**Start here.** Cumulative development and testing record; not a claim of live validation.

## TargetSC Test3 development — transport repair (2026-10-19)

`development/targetsc-resonance-test3` starts from Test2 `5d23e29`.
Corrected the optional publisher's two commands and TargetSC's three subscriber
commands from function invocation (`lua i`) to addon-command delivery (`lua c`).
The real-addon dispatch simulation passes both load orders, source reload,
snapshot age/deadlines, unsubscribe and zone reset. Prior transport simulations
accepted the wrong spelling; they did not validate Windower delivery. Live
handshake is still pending. Skillchains.lua, HUD code/assets and timers remain
unchanged. See TargetSC/TESTING.md for the evolving full test record.

## TargetSC 0.2.0 Test2 pairing and Animation8 preview acceptance (2026-10-19)

User has now tested Animation8 previews in FFXI and finds them substantially
better; accepted as the current working reference, with gameplay still needed.
Future HUD observations: slightly strengthen L2 element separation and subtly
flicker the preparing-white pre-window. Neither is implemented in this batch.

New isolated branch `development/targetsc-resonance-test2` starts from
`e3a8b632e29eeebdbd4455da470810a9574a7ddd`. **Every Skillchains runtime Lua file,
bridge and image asset is byte-identical to that Animation8 baseline.** Only
TargetSC animation/native/preview code and development/package records change.
TargetSC/TESTING.md carries the full current test guide and preserves history.
The native API update requires replacing TargetSC's DLL with FFXI closed.
Automated/static checks are distinct from the user's prior live preview
observations; new TargetSC 0.2.0 has not been tested in FFXI.

---

## Animation8 — genuine perimeter, seamless capsule halo and restored level-four electricity (2026-10-19; LIVE PENDING)

**Branch:** `development/skillchains-resonance-animation9`, forked from
Animation7 tested snapshot `a680b8b3ae4ec46a40de1e4f781cb94d81a33643`.
**Version:** `2.20.08.25-resonance.7-animation.8`.
User in-game observations of Animation7: opener confirmed excellent.
The prior high saturation washed out L2's Fusion gradient; with
`//sc anim intensity 2`, `//sc anim glow 2`, `//sc glow
rail34 .75`, `//sc glow cap34 .85`, and L4 gold, the
old electric flicker returned somewhat. L3 should have a darker
interior and a distinct flicker; L4 should recover continuous pre-window
power; all successful-chain caps still appeared geometrically detached.
The learning panel must disappear entirely when empty. User wants to
lock the 2D language then adapt it to **TargetSC 3D** later.

**Root cause found in source:** the previous frame primitive was a
**solid white/gold rectangle, full bar height**, not a perimeter.
The transparent base (`115,18,21,39`) was rendered ON TOP of
this bright sheet, so levels 2–4 looked washed out even with
`//sc glow levels off`. This batch replaces the background geometry,
not merely its alpha. The main SC/MB borders now consist of **one
top and one bottom one-pixel primitive rail, plus the two inset
endcap primitives**, leaving the center transparent to game scenery.
Default dark track is `RGB(6,8,17), alpha 155` (61% opaque);
`//sc track alpha 0-255`, `//sc track rgb R G B` and
`//sc track reset` allow independent tuning. The dark center
does not flicker or participate in countdown-opacity effects.

**New capsule halo mechanism:** old `ghost_glow_cap_l/r` assets,
and separately stretched top/bottom glow rectangles are retired
from the *runtime ZIP* in favor of a three-piece contour sharing
a single signed-distance function:
`images/resonance/capsule_halo_l.png`,
`capsule_halo_rail.png`, `capsule_halo_r.png`.
At scale 1 the exact design frame is 7px high with a 1px corner,
3px bloom margin and cap/straight join at 10px from each end.
All art is tintable alpha-only white. The rail contains two narrow
luminous lines but a nearly transparent middle. Adjacent sprites
touch *without overlap*; caps bloom slightly beyond the actual
bar, and sprites are scaled from original design units.
`python3 tools/generate_capsule_halo.py --check` validates PNG bytes
and `python3 tools/test_capsule_halo.py` independently checks
pixel mirroring, identical seam alpha, dark center, and rail profiles.

**Result-level behavior:** Opener's confirmed white grow/dim
remains unchanged; no added opener halo. Successful chains keep
a full-width white refill and 0.30s white-to-property body overlap
centered on actual decay start; source window/MB clocks unchanged.
The *actual narrow perimeter* begins white and develops resulting
property color during the pre-window, independent of body fade.
Level 1 gets the property color; L2 now uses the midpoint of its
palette rather than an opaque-white border, reducing gradient wash.
L3 keeps a restrained white rim and 11-rad/s shimmer, with pre-window
strength control. L4 defaults to **gold**, fast 23-rad/s border flicker
throughout white pre-window, plus 28-rad/s modulation in decay.
Its tuned .75 rails/.85 caps are new defaults; L3 uses a lower
multiplier. The glow still supports arbitrary nonnegative strength
settings, but as before Windower alpha saturates at 255.

**New default glow:** levels `34`, `rail12=.30`, `cap12=.35`,
`rail34=.75`, `cap34=.85`, `level1=1`, `level2=.65`,
`level3=.70`, `level4=1`, `pre12=.18`,
`pre3=.38`, `pre4=.85`, `scale=1`, `l4=gold`.
`//sc glow pre3 1`, `//sc glow pre4 1`, `//sc glow
preset balanced|capforward`, `//sc glow l4 whitegold|gold|white`.
`//sc glow reset` resets only glow, and `//sc track reset`
resets only the dark track, **without resetting saved positions**.
Previously saved glow settings are preserved; run glow/track
reset selectively to try Animation8 defaults. Empty learning
groups hide all pooled text/icons, with no "No compatible learned
actions" placeholder or empty learning box.

**Automated checks (not FFXI):** GitHub Actions Lua 5.1 parse;
seeded UI and clean-opener simulations; shadowless perimeter
geometry, dark track, source-timed white/color overlap, sprite
join, user controls, empty learning list, TargetSC native/bridge
simulators, snapshot deadline regression; strict PNG generation
and independent source-art geometry tests; PE32 native DLL
identity and complete 2-folder ZIP SHA manifest.

**Live FFXI test plan:** Preserve Skillchains `data/`, copy the
full `Skillchains` folder including three new capsule textures,
and `//lua reload Skillchains`. With TargetSC installed, leave
it alone. Preview `//sc anim preview opener` and verify no hitch,
color/timing or silhouette regression. Preview levels 1–4 at scale
1 and 2.5, with `//sc glow levels off`: confirm **all four have
equally dark translucent centers** with no white/gold center sheet.
Then `//sc glow levels 34`; on L3 compare
`//sc glow pre3 .38` vs `1`, on L4 compare
`//sc glow pre4 0` vs `.85` vs `1`, and check uninterrupted
gold electricity during white pre-window. Compare
`//sc glow rail34 .75`, `cap34 .85` with
`//sc glow preset balanced`. Check matching, seamless ends
and any halo reaching the text or crossing a short bar at scale2.5.
On L2 verify Fusion gradient remains saturated and the background
shows scenery correctly. Try `//sc track alpha 100` vs `155`,
or `//sc track rgb 0 0 0`, then `//sc track reset`.
Look for empty learned-actions panel, real SC windows and
MB timing, 4-box load, and `//tsc sync`.
**No live testing of Animation8 has been claimed.** The user's
observations above concern the preceding Animation7 only.

---

## Animation7 — rounded electric glow caps and simplified white refill (2026-10-19; LIVE PENDING)

**Repository / branch:** `rerorriM-Mirrorer/Skillchains`,
`development/skillchains-resonance-animation8`, based on Animation6
commit `011b64b0c4c92d46245caa2be21373ef7f76a62c`.
**Skillchains version:** `2.20.08.25-resonance.7-animation.7`.
This is a **Skillchains-only HUD animation change**; previous branches
and the trusted main branch are untouched. TargetSC 0.1.0 native DLL,
Lua, bridge protocol, MB observation and real source deadlines have
no changes.

**Latest user feedback (live observation of Animation6):**
Opener is much smoother and L1 animation is good. However mirrored
vertical flare assets overlap awkwardly, leave exposed ends, and
center pulses are no longer useful. User prefers an elegant white
full-bar refill on successful chains, remaining white through most of
the SC pre-window, transitioning uniformly toward property color
over `0.30s` centered on the start of actual countdown (roughly
0.15s before through 0.15s after). Opener keeps its confirmed
white -> dim -> active behavior. Preserve the cool fast L4
**electrical border glow**, filling in round ends with separate
matching, tintable ghost-glow cap assets rather than flare sprites.
Default cap slightly stronger than rail; expose optional balanced
caps, lower-level glows, per-tier and per-level strengths, global
strength, L4 white-gold/gold/white and energized/uniform transition.
User requests numerical settings be freely tunable, reporting defaults
with each setting change.

**Implementation:**
- Added two real, neutral-white-alpha, mirrored PNGs:
  `images/resonance/ghost_glow_cap_l.png` and
  `ghost_glow_cap_r.png`. Their semicircular soft glowing tips
  connect to upper/lower `ghost_glow.png` rails inside the frame's
  outer X bounds, tracking bar scale. The assets are reproducible via
  `python3 tools/generate_glow_caps.py`; `--check` verifies exact
  committed bytes. Old edge/center flare textures remain in history
  but are **not instantiated or included in the new install ZIP**.
- The opener retains its single white growth and second-beat dim
  reveal and has **no flares**. On confirmed chains, white overlay
  sweeps the entire length from the left over the previous fill and
  dark track, then **holds white** until the transition around the
  actual SC-open deadline. The underlying fill still grows from the
  prior fraction; absolute continuation and MB timers remain fully
  authoritative and unmodified. White overlay narrows with the actual
  fill fraction once decay begins, avoiding a full-width leftover.
- Transition uses `smoothstep` over a default 0.30s window centered
  on the real countdown boundary. The fill fades uniformly. With
  style `energized`, border rails and matching caps briefly flicker
  to full power as the fade proceeds. Style `uniform` disables this
  special start-up flicker. The independent strong level-four border
  oscillations at 23 and 28 rad/s remain after activation. Default
  level-four glow color is pale white-gold; gold and white optional.
- Defaults: glow levels `34`, `rail12=.30 cap12=.35`,
  `rail34=.60 cap34=.75` (cap-forward ratio 1.25×), levels
  1–4 multipliers each 1, global scale 1, L4 `whitegold`;
  transition duration `.30`, style `energized`. Existing
  `//sc anim glow` and `//sc anim intensity` are independent
  upstream multipliers and saved settings are preserved. Legacy
  `//sc anim flare` remains accepted for settings compatibility,
  but retired visual flares are not rendered.
- Commands:
  `//sc glow levels 34|1234|13|off`;
  `//sc glow rail12 0.3`, `cap12 0.35`, `rail34 0.6`,
  `cap34 0.75`, `level1 1` through `level4 1`,
  `scale 1`; `//sc glow preset capforward|balanced`;
  `//sc glow l4 whitegold|gold|white`;
  `//sc transition 0.30`;
  `//sc transition style energized|uniform`.
  Commands report the defaults on change. Nonnegative finite numeric
  multiplier inputs have **no hard maximum**; Windower alpha itself
  saturates to 255 and extreme values may look flat/clipped.
  `//sc default` restores all new default fields as well.

**Automated verification, not live FFXI validation:** Lua 5.1 syntax
checks, deterministic mirrored PNG byte tests, learning icon and
bar integration simulation; a dedicated `tools/test_visual_commands.lua`
executes actual Skillchains command handlers against a simulated Windower
runtime, exercising cap presets, masks, numeric validation/unbounded
multipliers, L4 tints, transition styles, saved settings and default
reports; assert white opener unchanged, full
white successful refill from x-origin, previous fraction retained,
0.30s deadline-centered overlap, no center/side flare allocations,
empty background alpha unchanged, cap and rail inside bounds and
active together, cap-forward/balanced values, L1 opt-in, per-level
strength control, white/gold/whitegold tint, energized/uniform
difference, preserved level-four electric oscillation, effect cleanup
and no repeated hide/show. TargetSC native Lua lifespan, bridge,
missed-DLL, frame geometry and source deadline regression tests;
two-folder archive integrity, SHA256 manifest and DLL PE32/i386
identity remain part of GitHub Actions.

**User in-game checklist:** Preserve Skillchains `data/`, install
full new `Skillchains/` contents (including three runtime
`images/resonance/` PNGs), `//lua reload Skillchains`.
Try `//sc anim preview opener|level1|level2|level3|level4`
at scales 1 and 2.5 plus a small client; compare newly clean
white refill against Animation6. In level 3/4 look for continuous
bright round ends and the familiar flicker without detached flares.
Verify 0.30s color overlap exactly as countdown starts, old dark
track and previous fill beneath white successful sweeps, no
countdown hesitation. Try `//sc glow preset balanced` then
`capforward`; `//sc glow levels 1234`;
`//sc glow level1 0.4`; `//sc glow l4 gold`,
`white`, `whitegold`; and
`//sc transition style uniform` then `energized`.
Report screenshot/feel, small-client scale, border clipping,
and any regression in opener hitch or multibox responsiveness.
TargetSC's DLL does not need replacing when already installed.
**Nothing in this new batch has yet been tested in the game.**

---

## Animation6 — anchored light-leak assets and white-sweep hitch investigation (2026-10-19; LIVE PENDING)

**Branch:** `development/skillchains-resonance-animation7`, from
Animation5 commit `d26ec78c098753cd335bd31c569721f0cb2040ad`.
**Version:** `2.20.08.25-resonance.7-animation.6`.

**User's in-game observation on Animation5:** The opener's original
vertical flare still floats **above** the rounded fill end. User wants
light leaking *upward from* its bright rounded edge, with mirrorable
left/right sprite assets. Follow-up observations identify upward
flare "growth" that appears to shift position rather than growing in
place; center SC pulses should use the actual center fill color;
confirmed-chain white sweep should start at the **far left** and
traverse the entire gauge, with its previous fill and dark track
underneath. Persistent opener hitch warrants render-work reduction.
The FFXI screenshots apply to **Animation5**, not Animation6.

**This branch's implementation:**
- Two new generated, white-alpha **64×96 RGBA** images,
  `images/resonance/edge_flare_left.png` and `edge_flare_right.png`,
  have a bright rounded cap at the outer edge and a narrow translucent
  upward plume, with no alpha below the cap's lower boundary.
  The left is a pixel-perfect horizontal mirror of the right.
  `tools/generate_edge_flares.py --check` deterministically
  verifies them; both PNGs are included in test packages.
  Windower tints them via `images:color`; `texture.fit=false`.
- The white flare's **bottom raster row** is pinned to the SC fill's
  lower raster edge. Opener flare height expands upward while this
  foot remains still. New sprites render white for white wash and
  adopt result property colors as the active stage arrives. Opener
  has no left-hand flare or centered SC pulse.
- Successful skillchains retain **previous fraction** and dark track
  in the real bar, growing that underlay toward full width over one
  second. Independently, their white full-bar **overlay starts at
  x=0** and grows to full width, exactly like the opener, so the
  previous bar remains visible beneath the leading white wash.
- Keep the original three center pulses from level-four treatment
  across successful levels 1–4. Color the center pulse from the
  **middle stop(s) of the currently displayed/tweened fill palette**
  (including transitional previous property and Radiance)
  instead of a decorative level-four gold override. Glow rails
  and original 23/28 rad/s flicker remain separate.
- Fix potential unnecessary rendering work: stop hiding and
  re-showing every FX sprite/primitive every animation frame.
  Cache visibility, dimensions, position, tint and alpha; hide only
  resources no longer drawn. Skip all 24 hidden SC gradient segments
  during the first beat of the opener. Do not infer that this proves
  the observed hitch is fixed; the FFXI renderer must be tested.

**Static/simulation check:** CI runs Lua 5.1 parser; seeded learning
layout and SC presentation tests (mirrored textures, alpha and
stroke fades, pinned flare bottom, continued sprite visibility,
whole-bar sweep from left, prior underlay retained, actual center
property palette, absolute countdown); TargetSC publisher/consumer
and native addon Lua lifecycle regressions; strict generated PNG
verification and two-addon archive manifest checks. These cannot
measure real in-game frame pacing.

**Live testing requested:** Install Skillchains files/assets only,
preserve `data/`, run `//lua reload Skillchains`. At 1× and 2×
scale and on a small client run `//sc anim preview opener|level1|
level2|level3|level4`. Compare first-second white motion for
stutters, check the flare grows UP from the rounded cap without
a floating stem or light below the fill, and verify that the left
flare stays absent on opener. On successful chains the prior colored
fill and dark track should remain, white should start at far left,
and all three center pulses should match the fill's central hue.
Test `//sc anim intensity 2`, `flare 2`, `glow 2`, and both
`fade on` and `fade off`. Confirm `//tsc sync`, old real
clock deadlines, and no unexpected multi-client performance hit.

**Outstanding:** only the user can verify Windower smoothness,
texture color fidelity, transparency blending, scale clipping and
whether the graphic hitch was reduced. TargetSC DLL, Lua, ring
geometry, bridge and MB behavior untouched; no actual in-game
testing of this new build is claimed.

---

## Animation5 — user visual corrections (LIVE PENDING)

User-provided opener screenshots confirm no left flare or center pulse
is desired on opener, plus a remaining white-expansion hitch.
Successful chains should retain previous dark track and previous fill,
re-expanding from their previous fraction rather than from zero.
Restore the **original three full pre-window center pulses** from
level-four Animation3 for all successful SC levels 1–4; keep the
level-four fast electrical flicker. Improve colored-edge flare entry
to begin before the final brightening, increase L1/L2 visibility,
inset vertical flares further and raise their lower body. Introduce
soft endcaps on shortened L3/L4 top/bottom glow rails, within the
bar's rounded ends. Opener has no left or center flare; white right
flare grows/shrinks with the white expansion.

Branch `development/skillchains-resonance-animation6`.
Source clocks and TargetSC protocol remain unchanged. Effects are
pure presentation. User's screenshot feedback is FFXI observation
of the **preceding Animation4**, not live verification of this build.
Synthetic Lua 5.1 tests and package CI are tracked separately.
Investigate any remaining hitch in the FFXI client; screenshots
cannot identify frame timing.

---

## Animation4 unified pre-window preview — 2026-10-19 (LIVE PENDING)

User confirms Animation3 learning icons now look better. Screenshots
show flare sprites and L3/L4 glow projecting outside rounded bar ends.
User requests a common opener/chain three-beat sequence: 1s white
expansion, 1s white wash and edge-flare fade into dim result, and
property-colored brightness/edge flares ramping during the final .3s
before actual decay. No level-2/3 traveling follow-ups; all four
levels get one centered pre-decay pulse. L4's existing 23-rad/s
flicker and 28-rad/s decay glow pulse retained. Requested initial
controls: intensity 2, flare 2, glow 2. Transparent dark empty track,
saved settings, TargetSC bridge, and absolute deadlines preserved.

Implementation branch `development/skillchains-resonance-animation5`.
Glow rail textures inset by 3*scale UI pixels from either end;
edge flare centers inset into fill. Animation clock derives from
created/sc_open and is not changed by preview. White bar is rounded
and displayed during first two seconds; original bar revealed as
white dissolves. Actual bar re-expands over one second. Source
window countdown starts at the same original time.

**Outstanding:** Real Windower FFXI preview and chain validation,
especially overlap of white/colored flares at transition, intensity
2 clipping, small-client scaling, and visual hitch. Existing
simulation tests do not substitute for in-game testing.

---

## Animation3 live hotfix — 2026-10-19

**User-reported Windower error:** On `//sc anim preview opener`,
`learning_ui.lua:92: bad argument #2 to 'tonumber' (base out of range)`.
Cause: `tonumber(row.label:extents())` forwards the second result
of the multi-return `texts:extents()` API to Lua 5.1 `tonumber`
as its optional numeric base. The mock test originally returned two
values, but did not exercise this exact conversion failure in the
same runtime. Both width reads (measurement and ellipsis loop)
now capture the first return value in a local variable before
calling `tonumber(width)`. No geometry, fade, timing, TargetSC
or existing configuration semantics changed. **User live retest pending.**

---

## Current testing batch — 2026-10-19 / Animation3 readability + alignment (LIVE PENDING)

**Branch:** `development/skillchains-resonance-animation4`, branched
from Animation2 commit `27f4927fa68fa845b30ab20d475f2ec2daa563c4`.
**Skillchains version:** `2.20.08.25-resonance.7-animation.3`.
**Scope:** HUD-only `learning_ui.lua`, `resonance_fx.lua`,
`resonance_ui.lua`, `Skillchains.lua`, Lua simulation tests, package
workflow and docs. TargetSC 0.1.0 native DLL, Lua animation, source
bridge, combat observation and SC/MB absolute deadlines unchanged.
Older test branches and master remain untouched.

**User's confirmed FFXI Animation2 feedback:** Opener looks good and
countdown correction is working. Desired rounded white opener endcaps,
text/icons fading during its *first* second, raised EnemyBar2-style
flares whose feet align with SC fill bottom, more transparent dark
track at levels 3/4 (especially with optional `anim fade on`), and
strongly reduced repeated traveling flares. Level-4 pulsing liked.
Preferred currently `anim fade off`, `glow 1`, `intensity 1`,
`flare 2`, bar caption `//sc names offset 5 -9`, and SC caption
icon an extra 2–3 pixels lower. Learning icons now look correctly
sized but can overlap bold-italic ability text: the fixed column is
too close, despite previous attempts to match measured text widths.

**Implementation:**
- Measure the **actual pooled bold-italic labels**, not an invisible
  differently rasterized probe. Cache per-row font measurements, add
  conservative visible-width estimate and stroke clearance, followed
  by at least 8px of additional breathing room. Compute one shared
  icon starting column; truncate overflowing labels before that column.
  Preserve smaller `fit=false` PNGs, scale rules and 960×540 layout.
- Add one-pixel inset white opening endcaps matching the SC bar's
  rounded silhouette. Text, icons and their dark outline begin fading
  during the **first** actual pre-window beat, completing within it.
  Preserve the single white expansion flare (no second/third opener
  pulses) and actual SC continuation countdown behavior.
- Successful chain: initial white strike and side flares unchanged.
  Remove extra moving flare entirely for level 1; use **one** follow-up
  pass throughout the entire pre-window for levels 2 and 3. Keep
  level-four's provisional three pulses and later flicker. Align all
  EnemyBar2-derived soft flare sprite **feet with the bottom of the
  SC fill**; their tips naturally rise above the top frame.
- Return bar's empty track to its constant translucent dark opacity
  even if fill oscillation/fade is enabled; only the opener reveal may
  fade it. Use two narrow soft texture strips above/below the SC bar
  rails for L3/L4 glow rather than one bright overlaid rectangle
  obscuring the empty track. Limit glow to its existing intensity
  controls.
- Opener fill continues dim until active; ramps up smoothly upon
  actual SC window opening. Successful SC brightness now eases from
  dimmer to brighter throughout the pre-window instead of switching
  on the next frame. Previous-property → result gradient interpolation
  remains intact.
- Existing `//sc names offset <x> <y>` still moves SC text and icons.
  New saved `//sc icons offset <x> <y>` moves SC icons independently.
  Built-in SC icon baseline lowered an additional 3 scaled pixels.
  New configuration defaults are names (5,-9), flare 2, glow 1,
  intensity 1, and fade off; existing saved settings are preserved.

**Checks:** GitHub Actions Lua 5.1 parser and simulated
`tools/test_learning_ui.lua` verify long/multi-property text
ellipsis before icon column, cached positioning, separate icon
offset, Ctrl/grid drag, scaled layouts, rounded white cap geometry,
first-beat text and stroke fade, independent dark trough opacity,
one level-2/3 flare traversal, no level-1 follow flare, feet aligned
with fill, top/bottom rail halo, pooled visual cleanup. Existing
TargetSC publisher/consumer, animations, native Lua lifecycle,
missing-DLL and actual Skillchains source-deadline comparison
regressions continue. Package validates Windows DLL, two copied
EnemyBar2 procedural sprites, 14 property PNGs, docs and manifests.
All are **static/simulated checks**. **Not tested live in FFXI.**

**Next FFXI test checklist:** Back up both addons and data. If updating
Skillchains alone, copy all files/assets inside `Skillchains/`,
preserve `data/`, and `//lua reload Skillchains`; only close the game
if replacing TargetSC's DLL. `//sc status` should report
`resonance.7-animation.3`. Preview opener, L1, L2, L3 and provisional
L4 at 0.5, 1, 2.5 scales; check white rounded endcap expansion,
early smooth caption/learning entry, stable dark track, both
rail glows, steady decreasing countdown and flare timing. Try
`//sc names offset 5 -9` then `//sc icons offset 0 0`,
`//sc icons offset 0 2`, returning to 0 0 to compare. Test long
ability names, dual/multi-property icons in Learn at small
960×540 and larger resolutions. `//sc anim fade on` must
change the fill but not brighten or erase the empty track;
`//sc anim flare 2` should retain the pleasing contact.
Verify TargetSC `//tsc sync`, source timers, switching targets,
multibox costs and existing Ctrl+drag. Collect screenshots
and note observed FFXI font/raster differences.

**Known limitations:** Real Windower text extents may differ from the
synthetic measurement. Level-four appearance is a *preview*;
no actual Radiance/Umbra in-game validation. TargetSC ring/disc
redesign and MB underbar shimmer remain separate future changes.

---

## Current testing batch — 2026-10-19 / Animation2 refinements (LIVE PENDING)

**Repository / branch:** `rerorriM-Mirrorer/Skillchains`,
`development/skillchains-resonance-animation3`. Branched from
`development/skillchains-resonance-animation2` at
`176b0898db1365af1ea29560afbeddc7f08f4279`.
**Version:** `2.20.08.25-resonance.7-animation.2`.
**Scope:** Skillchains HUD renderer, HUD effects, learning icons,
tests and package documentation. **TargetSC DLL/Lua/3D motion and
bridge event protocol untouched**; `master` and previous testing
branches untouched. No FFXI gameplay verification of this build.

**Live user feedback (screenshot provided):** Learning-panel property
icons remained much larger than text despite prior size adjustments.
Icon column's distance to longest name was improved. Ability text
appearance itself was praised, but labels turned dark during the
fade. SC bar countdown was confirmed behaving much better.
Opener's dark/white outline and extra pulses were unwanted; user
requested a single expanding, free-standing white bar and flare,
fading into a dim primary-only property. Pre-window label fade should
start in second beat. Skillchain result colors should blend instead
of switching, and traveling flares should occur **before** the
continuation opens, with N=level passes across that delay.
Previous rectangular flares/glows should resemble EnemyBar2's
soft tapered alpha sprites. Level-four behavior remains undecided.

**Findings:**
- `images.new(... texture.fit=true)` was kept from the original icon
  helper and can size to the PNG's native dimensions. Smaller numeric
  `image:size()` alone did not ensure smaller visible icons. Changed
  Learn and SC caption texture fitting to `false` and reduced Learn
  icon design size to 78% of current text font size with scaled gaps.
- `texts:alpha()` does NOT change `texts:stroke_alpha()`, hence
  visible black outlines during text fade. Update both for learning
  action labels, property label/timer, and compact caption when fading.
- EnemyBar2's original procedural `assets/ffxi/ghost_flare.png` and
  `ghost_glow.png` were copied byte-for-byte to
  `Skillchains/images/resonance/`. They are runtime-tintable soft-
  alpha gradients; no DAT extraction or additional input hooks.

**New visual behavior:** One solid white opener overlay expands
left→right across the first phase; the real SC bar/outline is hidden
until reveal. White overlay fades in the second phase, with text,
stroke and icon opacity appearing smoothly in that same second.
No additional opener pulses. Primary property alone is the opener
palette; a multi-element *single primary property* can still make
a gradient. Same dim palette brightens after the actual SC window
opens. Successful-chain gradient is interpolated from the prior
active property to new result over a short initial interval.
Paired side flares and N prewindow traversals (1, 2, 3 for
level 1,2,3 respectively) use the reusable soft-alpha EnemyBar2
textures. Level 4 preview tentatively pulses three times and
flickers, no user-validated live level-4 effect.
Controls `//sc anim intensity|flare|glow <0-2>` are persistent;
opener countdown still does not decrease until the real delay expires.

**Verification:** CI parses all Lua as Lua 5.1; runs the actual
Skillchains HUD renderer against simulated Win­dower text, image and
primitive APIs; asserts fit=false, smaller icons, common icon
start column, stroke/foreground fading together, initial white
wash with invisible real border, zero extra opener pulses,
second-beat label reveal, color-blend progression, two
prewindow flare passes, cessation of travel when SC opens,
and legacy drag/viewport/scale/cleanup behavior. TargetSC
publisher/consumer, native-addon Lua lifecycle simulations,
missing native tests, and the Skillchains authoritative deadline
comparison remain in CI. Full two-addon ZIP construction checks
all PNG signatures and SHA-256 manifests with original DLL.
No actual 3D rendering/FFXI test was performed.

**Test in-game:** Use HUD-only
`//sc anim preview opener`, `level1`, `level2`, `level3`;
verify icon sizes at scale 0.5/1/2.5 and small 960x540
client, absence of initial dark outlines, primary-only
opener fill, gradual successful-chain color blend and the
changed prewindow flare rates. Try `//sc anim flare .5`,
`//sc anim glow 1.5` and overall `//sc anim intensity 2`.
Trigger real openers/skillchains to confirm visual phases
scale with the reported delay, continued good countdown,
no UI stutter across four clients, Ctrl+drag persistence
and no change to `//tsc sync`. Confirm former TargetSC
0.1.0 rings remain unchanged. Preserve `data/` when
installing; close clients if replacing the native DLL.

**Outstanding visual investigations:** Native Windower font
metrics can differ from Lua synthetic extents. If text still
appears too dark, collect a screenshot at the transition.
The original bar's fractional gradient segments may show
minor 1px rounding at unusual scales, independent of this
fix. Fade timing needs real weapon-skill delays for
sub-3-second windows. MB and TargetSC spatial redesign
are specifically deferred.

---

## Current testing batch — 2026-10-18 / Skillchains Animation1 (LIVE PENDING)

**Branch:** `development/skillchains-resonance-animation2` in
`rerorriM-Mirrorer/Skillchains`, based on Grid1 commit
`3f3be78e3b977701488e8e9610134d312b59b9a0`.
**Version:** `2.20.08.25-resonance.7-animation.1`.
**Runtime scope:** `Skillchains.lua`, `learning_ui.lua`,
`resonance_ui.lua`, new `resonance_fx.lua`; tests, package builder
and documentation updated. **TargetSC runtime DLL/Lua/bridge protocol
are unchanged.** `master` and original testing branches remain intact.
Author A. No in-game acceptance yet.

**User observations motivating this batch:** ability font looked good
but the property icons were oversized, overlapping, too far right.
SC-caption glyph needed to sit lower/closer to text. Requested strong
three-beat opening strike and progressive level-1/2/3/4 chain effects;
strictly SC-only implementation now, world-space TargetSC animation and
Magic Burst phase to be developed in their own future batches.

**Implementation:** Learning property glyphs use text size, 4px scaled
gaps, fixed leading icon column after longest eligible ability, and
screenshot-width containment. Pooled SC caption icons shrink and sit
2 scaled pixels lower. Separate `resonance_fx.lua` owns 11 pooled
Windower primitives (wash, edge, pulses, paired flares, travelers,
border glow), independent of combat packets. Opening phases are
proportional to each action's actual delay (three nominal 1-second beats).
Pre-window SC countdown stays at maximum until the reported opening
time, then follows absolute deadline. Brief white extension and flares
for a successful chain with persistent level-based border. Optional
`//sc anim intensity 0–2` and `//sc anim fade on|off`; local HUD-only
`//sc anim preview opener|level1|level2|level3|level4|off`.
No new art, DLL, element guesses, input hooks, or game commands.

**Checks:** GitHub Actions runs Lua 5.1 parser on all addon/test files;
`tools/test_learning_ui.lua` checks glyph font match, spacing, fixed
column, caption attachment, independent Ctrl-drag, viewports 960x540
and 1280x720, extreme 0.5/2.5 scales, pooled effect lifecycle, three
opener beats, pre-window timer hold, success fill and flares, opacity
control. Existing TargetSC producer/consumer, ring simulation,
command/lifecycle and missing-DLL tests are preserved. Updated
Skillchains regression verifies existing combat property/deadline,
MB and TargetSC source behavior against the pinned baseline while
**explicitly allowing the requested presentation change** in the
pre-window countdown. Package builder validates both installable
folders, hashes, docs, icons and unchanged Windows DLL.
All checks are synthetic/static. Not a Windower rendering or FFXI test.

### Live test requests — currently outstanding

1. **Backup:** Preserve Skillchains/data and TargetSC/data. Install
   full paired test package, OR update Skillchains only when compatible
   TargetSC 0.1.0 already installed. Close FFXI if replacing any DLL.
   Load Skillchains first, TargetSC second (or `//tsc sync`).
   `//sc status` should include `resonance.7-animation.1`.
2. **Learn glyphs:** Confirm smaller text-height icons, spacing between
   two/multiple properties, fixed column after longest displayed ability
   (not too far right), no collisions/clipping at 960x540 and 1280x720.
   Reconfirm independent Ctrl+drag and saved positions.
3. **Bar caption:** Confirm property icons now lie lower and just beside
   the ability/property label even with `//sc names offset 0 -11` and
   at scales 0.5/1/2.5.
4. **Opener preview:** `//sc anim preview opener`; verify the initial
   ~1s white left-to-right sweep and edge, next white fade and pulse,
   final property-colored pulse and fading names/icons; no timer
   shrink before the opening delay. Test an actual opener and no-chain
   expiration; note that a pre-window delay other than 3 seconds will
   proportionally compress/stretch these visual beats.
5. **Chain preview:** `//sc anim preview level1`, `level2`,
   `level3` at each scale; compare actual resulting chains.
   Check white expansion/flash, level-specific persistent outline,
   paired property flares and traveling flares; ensure no false
   chain reset on retarget, no visual tearing and no frame spikes.
   Level4 is a provisional visual preview, not validated gameplay.
6. **Tuning:** `//sc anim intensity 0`, `1`, `2`;
   `//sc anim off/on`; `//sc anim fade on/off`.
   Report readability of timer and effects, including multiple clients.
   Verify combat events and `//tsc sync` remain correct.
7. **Deferred:** TargetSC ring/disc redesign and all new MB
   shimmer/underbar changes; user explicitly allocated those to
   separate iterations. Do not confuse still-running previous MB
   display with the upcoming unified underbar.

**Current verification:** Lua parsing and simulated regression PASS.
Native/FFXI live testing NOT RUN.

**Separate existing layout questions:** At extreme scales font
baselines and independently rounded gradient segments may differ by
one pixel; the Grid1 position anchor fix does not silently redesign
those. Learn column now follows longest currently available action,
so it can reposition when the eligible action list changes. Long
names on very narrow client viewports are truncated deliberately,
and this needs actual in-game font-metric validation.

---

## Current testing batch — 2026-10-18 / Grid1 Ctrl+drag (not game-tested)

**Source:** `rerorriM-Mirrorer/Skillchains` branch
`development/targetsc-resonance-grid`, branched from the current
`targetsc-companion-v0.1` at `c8778a358ae42c0c68ddc8b00f60ee8307c0fc7d`.
Both original testing branches and `master` remain unchanged.
**Install:** Use the complete `Skillchains-TargetSC-Grid1-test` GitHub Actions
artifact (two installable folders: `Skillchains/`, `TargetSC/`). Back up
the current Skillchains folder and data; **close FFXI before replacing
TargetSC's DLL**. Preserve existing per-character settings.
The addon's status version adds `-grid.1`. No DLL/native source changes.

**Changes:** Both Ctrl keys (Windower DirectInput 29/157) independently
request snapping only while an existing Windower draggable handle moves.
Grid anchored at screen/UI (0,0), floor to 10 pixels by default (configurable
1–200 via `//sc grid [pixels]`). Bar uses `Resonance.bar.x/y` as its
top-left reference; the learning list uses independent
`Resonance.list.x/y`, with Y at its **bottom**. Every bar/text/icon position
continues to derive from its respective saved anchor. Scale handle still
means resizing, **not** snapping or moving the widget. Native mouse/keyboard
input is not suppressed. Existing TargetSC bridge/events and combat state
are unchanged. A dedicated shared struck-bell animation and composite
SC/MB-underbar **plan** is in
`TargetSC/docs/SHARED_RESONANCE_PLAN.md`; those visual features are not part
of Grid1.

**Source inspection:** Current `AGENTS.md`, `WORKFLOW.md`, `TESTING.md`
from both Skillchains branches and TargetSC were read directly from GitHub;
BarFiller2 `docs/ALIGNMENT.md` and its Ctrl implementation and EnemyBar2
working instructions were consulted. This patch does not borrow EnemyBar2
mouse interception; Skillchains already uses draggable Windower `texts`.

**Automated verification:** GitHub Actions runs Lua5.1 parser, synthetic
learning/drag tests (free movement, both Ctrl keys independently, Ctrl-without-
movement nonjump, 10/16/1 grids, 960x540 and 1280x720 viewports, offscreen
clamps, scale 0.5/2.5, icon/frame layout), existing TargetSC bridge/ring/
lifecycle simulations, original Skillchains bar snapshot comparison, and
complete package validation (including Windows DLL, 14 PNGs, docs, hashes).
All are **static or simulated checks**, not actual FFXI gameplay tests.

### Live checks requested — pending

1. Before touching files, back up addon and `data/`; close game clients
   before replacing the TargetSC DLL. Load `Skillchains` then `TargetSC`.
   Check `//sc status` includes `grid.1`, `//sc grid` displays 10, and
   `//sc targetsc` / `//tsc status` still report a connected bridge.
2. In `//sc edit`, drag the **SC bar** with no modifier in both axes: smooth
   1px positioning and correct icon/text/frame alignment. With **left Ctrl**
   drag from non-grid coordinates and check 10px screen-origin floor
   multiples; release Ctrl to resume free movement. Repeat **right Ctrl**,
   both held then release one, and press Ctrl without moving the mouse
   (must not jump).
3. Repeat on independent **learning-panel handle**; ensure the list grows
   upward without jumping and still follows the handle. Test short vs long
   suggestion lists and an empty list. Drag near each edge and ensure saved
   anchors remain on screen.
4. Try `//sc grid 16`, then Ctrl+drag. Observe actual 16px positioning
   unrelated to scale; `//sc grid` and `//sc status` report correctly.
   Reset with `//sc grid 10`. Test `//sc default` only after saving your
   character's layout if you intend to restore it.
5. Repeat at scale 0.5, 1, 2.5 and on the small 960x540 Lionstag client
   versus larger client. Test drag while the bar is active and preview edit.
   Confirm `//sc scale edit` still resizes, not relocates/snaps.
6. Exit edit, reload and confirm positions/grid survived. Compare SC/MB
   bars, countdown captions, pool icons, Learn/Compact/Minimal, and
   TargetSC's in-world rings. Test with 1 and several clients and report
   whether any controller or menu keystroke is unexpectedly intercepted.

**Alignment observations separate from Grid1:** The bar already uses one
`opts.bar` anchor and derives frame/caps/segments/captions/icons from it.
Its configured width is intentionally NOT scaled, while bar thickness,
font and icon sizes ARE scaled. Fractional fill segments are rounded
independently and font glyph baselines follow their own metrics, so a
1-pixel local offset is possible across scales; this patch does not silently
redesign those visuals. The learning list is bottom-anchored on purpose.
Existing `rescue()` and edit-time horizontal list clamps use different
right-edge safeguards (`w-135` vs `w-215`), worth harmonizing only after
live layout evidence. The new grid changes positions, not those local
design-space offsets. TargetSC rings use world/model coordinates and are
not HUD-grid objects.

**Live FFXI verification:** NOT RUN.

---

## Current Development Status — 2026-10-18 (attribution normalization)

- **Repository / branch:** `rerorriM-Mirrorer/Skillchains` / `targetsc-companion-v0.1`; starting source `0b1f920410107e6fe4cb1cd9346d967d8c047e37`.
- **Change:** Use **A** alone in the README's resonance UI attribution. Bridge, renderer, TargetSC and other runtime sources are unchanged.
- **Verification:** The one prior reference was removed; exact-word search, strict substitution-only diff review, and Git whitespace check passed.
- **Live FFXI status:** No new in-game test. Existing TargetSC integration acceptance remains pending below.
- **Next:** Resume the documented TargetSC live integration tests; confirm published branch head after the documentation commit.

---

## TargetSC companion interface — 2026-10-18 / targetsc.1

**Working branch:** `targetsc-companion-v0.1`, based on personal
`resonance-ui-v0.1-test` at `e095657a2e7ecc5a49d05e96c1b78523a4860af5`.
The personal branch and master are unchanged. Authoring identity: **A.**

- Optional `targetsc_bridge.lua` publishes existing absolute continuation/MB
  deadlines, properties/elements and the already-resolved aeonic tier.
- Uses `lua i TargetSC _event ...` only on state changes and snapshot/lifecycle
  events. No cross-client IPC, packet injection, filesystem polling or per-frame
  commands. `//sc targetsc` reports subscription/event/send-failure counters.
- Confirmed Magic Burst message observation is inside Skillchains' existing
  action callback, across all targets; it never modifies either timer. Known
  spell resource elements are published; unidentified ability/WS burst elements
  are explicitly marked Unknown, not guessed.
- Install the complete compatible `Skillchains/` folder, including the new
  fifth Lua file, preserving `data/`; load it before TargetSC. Skillchains has
  no native dependency and continues operating without TargetSC.
- **Completed (simulated):** actual modified Skillchains compared with pinned
  baseline over opener, successful chain, MB, MB-only, closed chain, expiration,
  zoning and logout: **14 identical bar-render snapshots**. Existing learning
  and resonance UI simulations pass. All runtime Lua parses as Lua 5.1.
- **Remaining (live FFXI):** confirm subscription/load/reload ordering, bar/ring
  synchronization with a real extension, confirmed MB detection and no UI
  regressions. Existing resonance.6 live tests below remain outstanding.
- **Published conceptual commits:** bridge `4394348`, native renderer `2dfd6b2`,
  Lua motion/controls and simulation tests `3c445d5`.
- Package names, branch and final commit references are in
  `TargetSC/TESTING.md` and each package's `BUILD_INFO.json`.

## Current testing batch — 2026-10-18 / resonance.6 (ability-first color and icon layout)

**Branch:** `resonance-ui-v0.1-test`; master remains at its previous live baseline.
**Status:** User confirmed earlier `//sc edit` dragging and liked the bar appearance; `//sc names offset 0 -11` looked good. The new ability-first Learn layout, local PNG icons, and revised drag guide are **not yet tested in FFXI**. Earlier resonance.5 runtime tests also remain pending.
**Delivery:** Download the artifact named `Skillchains-resonance.6-test` from the
latest successful [GitHub Actions packaging run](https://github.com/rerorriM-Mirrorer/Skillchains/actions/workflows/package-testing.yml),
rather than using GitHub's auto-generated repository source ZIP.
The packaging workflow verifies the archive layout and CRC checks. Archive
root: exactly one `Skillchains/` folder containing `README.md`,
`WORKFLOW.md`, `TESTING.md`, four Lua files (`Skillchains.lua`,
`skills.lua`, `resonance_ui.lua`, `learning_ui.lua`), and
`images/skillchain/` containing 14 PNG icons. This follows the latest
canonical NPCMirror workflow; earlier packages placed development docs
outside the addon folder.
Install only that `Skillchains/` folder, preserving existing `data/`.
**Conventions:** `WORKFLOW.md` is the consolidated canonical document from
NPCMirror, containing AGATHOS, DESIGN and WORKFLOW. The retired
`AGATHOS.md` and `DESIGN.md` documents are intentionally absent.
**Runtime:** No `settings.xml`, launcher scripts, or EnemyBar2 modifications
are included.
**Precaution:** Back up your current Skillchains folder and its `data` before replacing files.

### Current targeted test: resonance.6 ability-first Learn mode (LIVE PENDING)
- Back up the installed Skillchains folder and character settings. Copy the
  complete updated addon folder with all **four Lua files** and the included
  `images/skillchain/` directory. Do not run incomplete two-file patches.
  `//sc status` should report `resonance.6`. The working branch is
  `resonance-ui-v0.1-test`; master stays unchanged.
- On a character with different learned weapon skills, trigger an opening
  skillchain property. In `//sc mode learn`, verify each compatible learned
  **ability name comes first**, tinted by the resulting skillchain palette.
  The result name/level should not be printed. Property icons on the **right**
  show the action's own properties, not the predicted result, and their final
  right edge aligns between rows of different name lengths.
- Confirm the same predicted result is used as in resonance.5, using FFXI
  skillchain property-priority rules. An ability is not duplicated merely
  because multiple theoretical pairings might exist. Group ordering remains
  by higher resulting skillchain level first.
- Switch target or advance a skillchain while Learn is visible: old rows and
  icons should disappear immediately; no stale artifacts, blank icons, or
  source-path errors. `//sc edit` should show a small handle ABOVE the list,
  not a tinted background behind the suggestions. Dragging should move the
  whole list, preserve its bottom anchor, and survive addon reload.
- Verify a transparent learning background, Arial bold italic with black
  stroke matching our existing SC bar caption, and readable light/dark result
  colors over both bright scenery and dark backgrounds.
- Confirm tiny property icons ALSO precede property labels on the SC
  resonance bar (possibly several icons for an opening WS) and the MB label.
  Test `//sc names full|short|off`, `//sc names offset 0 -11`,
  `//sc mode minimal`, `//sc display sc|mb|both`. Bar countdowns,
  rounded ends, gradients, edit and drag must continue working.
- On Lionstag's small client, test long names, 1/2/3-property abilities,
  many learned compatible actions, and an anchor low on screen.
  The list should grow upward; when too long to fit, display `+N more`
  instead of running offscreen. Do not interpret this as losing actions.
- Test with 1 and 4–6 concurrent clients for FPS and cleanup after unload.
  Nothing in this simulation proves real Windower image loading is correct.
- The original addon shows MB burst **elements**, not an eligible learned
  burst spell list. That feature remains unimplemented.
- **Evidence:** screenshots of a multi-property action, a Light/Dark result,
  drag/edit view, and any console log showing a Lua error.
- **Packaging convention update (2026-10-18):** NPCMirror's current
  `WORKFLOW.md` requires `WORKFLOW.md` and `TESTING.md` inside the
  installable addon folder. This change supersedes the older root-docs layout
  for this and future Skillchains test packages; historical test records
  remain below. A repository-root `AGENTS.md` was added.
- **Verification:** GitHub Actions Lua 5.1 parser passes all four addon files;
  synthetic Windower tests passed for learning layout, right-edge icon
  alignment, anchored rows, object pooling, bar/MB captions, drag delta and
  cleanup; ZIP validation checks 14 PNG signatures and complete content.
  These are **simulated and static checks, NOT in-game testing**.
- **Security precaution:** A previous GitHub Actions ZIP raised a Firefox
  malware warning. Do not bypass future warnings. Individual source Lua
  files and PNG assets can be inspected on GitHub and scanned before install.

### Previous targeted test: resonance.5 learning layout, timers and edit
- `//sc status` should report `resonance.5`. On an existing client,
  `//sc names offset` should retain the user's previously saved custom value.
  On a new character with no custom value, default should be `0 -11`.
  `//sc default` should restore `0 -11`.
- While a real SC window is active, verify the attached caption says
  e.g. `LQF / DET  5.4s`. Watch the timer count down in tenths while
  the bar shrinks smoothly. Test long property names for wrapping.
- Use `//sc display mb` and `//sc display both` after a valid chain:
  verify a separate `Magic Burst: 9.8s` caption follows the MB bar,
  counts down, and does not overlap the SC label. Test MB-only after
  the SC continuation expires and after a closed chain.
- `//sc mode learn` should show `Light: Savage Blade`,
  `Gravitation: Swift Blade`, and any other genuinely available learned
  actions grouped by resulting skillchain, highest levels first, without
  `Step`, `AVAILABLE SKILLCHAINS`, or `Lv.` prefixes. Do not
  mistake these example names for guaranteed skills of a particular job.
- Place the Learning panel near the lower screen, then create a
  different skillchain with a longer list. Verify the panel's **bottom
  edge stays fixed**, additional rows extend upward, and
  `//sc edit` still drags the panel smoothly and saves its position.
- `//sc edit` should show its SC BAR drag box **above**, not over
  the resonance gradient. `//sc scale edit` must retain an accessible
  scale handle on different resolutions.
- `//sc mode minimal` must still mean bars only. The Compact panel
  should still work, pending a future icon/color redesign.
- The learning panel remains RGB (16,18,38) at alpha 175;
  the bar track remains RGB (18,21,39) at alpha 115. This
  build should **not** homogenize the two backgrounds.
- Validate FPS and UI behavior with 1 client and several clients;
  no new artwork, character settings, or unrelated addons are included.
- **These changes are not yet verified in-game.**

### Previous targeted test: property-caption offset (resonance.4)

- After installing updated `Skillchains.lua` and `resonance_ui.lua`, reload
  Skillchains. Confirm `//sc status` reports `resonance.4`.
- Use `//sc names offset` (without numbers) to report the saved X/Y values.
  Then use `//sc names offset 0 -4` and perform a weapon skill. Verify the
  property names rise approximately four pixels and slightly overlap the SC
  bar; the bar itself must not move.
- Use `//sc names short` and `//sc names full` to confirm both use the same
  saved offsets. Drag the SC bar, reload, and confirm its caption follows.
- Test `//sc display both` with an upward offset and also `//sc names offset 0 5`
  to confirm the MB bar remains clear of the caption.
- Use `//sc default` to reset offsets to `0 0` (this also resets other UI choices).
  No Lua runtime testing has yet been performed for this change.

### Previous packaging verification (2026-10-13; superseded convention)

- ~~Confirm the published GitHub Actions artifact ZIP has one `Skillchains/`
  directory with README and three Lua files, with WORKFLOW.md and TESTING.md
  at the ZIP root.~~ Superseded 2026-10-18: current ZIP has four Lua files,
  14 icons and both development documents **inside** `Skillchains/`.
- Confirm `WORKFLOW.md` matches NPCMirror's consolidated reference,
  containing Agathos, Design, and Workflow in a single file.
- Confirm no `AGATHOS.md` or `DESIGN.md`, no settings.xml and no
  redundant parent folder inside the curated ZIP.
- Installation: copy or merge the entire `Skillchains/` folder into
  `Windower/addons/`, preserving an existing `Skillchains/data/` directory.
- No Lua or addon behavior is changed by this packaging correction. The
  reproducible script is `tools/package_testing.py`; the GitHub Action
  publishes the prepared package contents as one downloadable archive.
  Initial GitHub Actions run `38449553310` completed successfully.

### First checks for v0.1.2

1. **Lionstag off-screen recovery:** Reload and use `//sc edit`. Confirm the SC
   bar handle appears *on screen* even when the saved position originally fell
   below the small client's viewport. Drag bar and learning panel independently,
   exit edit, reload, confirm positions persisted. Try `//sc center` and
   `//sc pos 100 200` as additional recovery commands.
2. **Label choices:** Test `//sc names full`, `short`, `off`.
   Level 1 abbreviation examples: `LQF / DET`; level 2: `FUS`, `FRG`,
   `DST`, `GRV`; level 3: `LGT`, `DRK`; level 4: `RAD`, `UMB`.
   Confirm white Arial bold italic text, black stroke, and wrapping.
   Minimal mode should have no label irrespective of `names`.
3. **Learning panel:** Names of currently resonating properties should be
   under the bar, not repeated at the top of the learning panel. Available
   resulting chains and all learned candidate actions must remain intact.
4. **Countdown smoothness:** Watch a long SC window; motion should update at
   roughly 30 Hz, with substantially smaller steps than the prior 0.1s cycle.
   Check that a new WS/skillchain *snaps* to the new duration rather than
   slowly interpolating between two different windows.
5. **Rounded/translucent graphics:** On Lionstag and Cioara, inspect the 1px
   rounded ends, dark translucent tracks, gradient integrity while shrinking,
   and frame pacing with 4–6 clients. Report CPU use or rendering hitching.
6. **Scale:** Check `//sc scale edit` remains visible on the small resolution
   and that `//sc width` still independently controls bar length.

### Previous v0.1.1 checks for attached property captions

- In Learn/Compact mode, perform a first weapon skill without making a
  skillchain. Confirm all of its property names appear slightly below the
  SC bar in smaller Arial bold italic text with a dark stroke.
- Try a two-property opener (such as Red Lotus Blade); verify the comma-separated
  list. Try a completed chain and confirm the label changes to the result.
- With `//sc display both`, confirm MB bar sits **below** the property
  caption, not on top of it. For a long set of chainbound properties,
  verify wrapping and spacing.
- In `//sc mode minimal`, verify the caption disappears, leaving bars only.
  In `//sc display mb`, verify SC caption stays hidden.
- Check how much space is available below EnemyBar2 on Franklet's small client.
  If the text is clipped, move the SC bar upward using `//sc edit`.

### First in-game tests

1. **Load without combat:** `//lua reload Skillchains` (or load it fresh).
   Confirm one status/error-free start, then run `//sc` and `//sc help`.
2. **Independent dragging:** `//sc edit`; move `SC BAR` and the learning panel
   independently, exit edit; reload and confirm positions persist. The edit screen
   shows a *static placeholder* for positioning, **not** a simulated skillchain sequence.
3. **Scaling:** `//sc scale edit`; drag horizontal scale handle left/right;
   `//sc edit off`; try `//sc scale 0.8`; verify panel and bars resize without
   changing the manually chosen bar width. Try `//sc width 310`.
4. **Display choices:** On a melee character verify `//sc display sc` (default),
   `//sc display mb`, `//sc display both`; switching main/subjob must **not**
   automatically change the choice.
5. **Actual chain:** With a living targeted monster, perform two compatible weapon
   skills. Look for muted waiting resonance, brighter open state, diminishing bar,
   then separate Magic Burst window after the chain. Check time with a stopwatch
   if available; neither countdown is yet live-calibrated.
6. **Learning panel:** `//sc mode learn` should list **all learned compatible**
   actions grouped by result, not by weapon or alphabet alone. Confirm `compact`
   drops actions and `minimal` displays only bars.
7. **Window independence:** `display both`; allow the SC continuation to end
   while the MB opportunity remains. If a chain is closed, verify MB still appears.
8. **Target lifecycle:** Switch among live mobs during a window and switch back;
   kill the target; zone; reload; log out; enter/exit a cutscene. Report any stale
   graphical objects, wrong target, failure to hide, or console errors.
9. **Resolutions:** Validate separately on Franklet's ~1280×709 client and a larger
   client such as Cioara. Verify positions and that the learning panel isn't offscreen.
10. **Multibox:** With several instances, check no cross-client state bleed,
    UI lag, or duplicate/stacked primitives after reload.

### Evidence to return

The most useful first feedback is one in-combat screenshot of Skillchain-only Learn
mode, one screenshot in `display both` after completing a chain, and **any Windower
console errors copied verbatim**. Note character/job/target and whether timing
felt early or late. We can adjust colors and alignment from the screenshots.

## Checks completed before delivery

- **resonance.5:** A GitHub Actions run using the Lua 5.1 compiler
  (`luac5.1 -p`) passed for `Skillchains.lua`, `skills.lua`, and
  `resonance_ui.lua` after correcting a previously inherited string-literal
  method call to use parenthesized Lua 5.1-compatible syntax. Packaging
  validation also passed. This is **not an in-game runtime or regression test**.

- Compared original and posimagi action tables; refreshed the fork's `skills.lua`.
- Reviewed Windower `texts` APIs for draggable text, positioning, font size,
  and text updates; reviewed XIVCrossbar's previous skillchain timing implementation.
- Performed a **lightweight source lexical/bracket/block-balance check** against
  all three Lua files (passed). This is **not** Lua 5.1 compilation, full
  syntax validation, a runtime smoke test, or proof of timer correctness.
- Source review also corrected an older unguarded equipment lookup and verified primitive API names.
- GitHub branch writes were verified after editing; no private FFXI instance
  was accessible for runtime testing.

### Known limitations / questions

- EnemyBar2 attachment is visual/manual, not live position synchronization.
- Gradient palette remains provisional pending comparison to actual FFXI effects.
- Original timing heuristics are retained where practical; separate MB expiry
  is currently modeled as 10 seconds after the skillchain result. Verify live.
- Skill suggestions reflect learned ability lists, **not** TP/recast readiness.
- Large suggestion groups may extend past small-screen boundaries; report layout.
- Cutscene and zone hiding need live confirmation; addon has no direct
  EnemyBar2 cutscene-state dependency.
- No automatic magic-job detection (explicitly deferred).
- No Japanese names or timed preview/simulation (explicitly excluded).

## Previous tests and checks

- **2026-10-13, user-confirmed in-game smoke test:** Skillchains loaded and basic commands worked. Exact commands were not specified. The user later observed the previous bar's choppy expiration animation and the SC drag handle inaccessible at Lionstag's small resolution; those are firsthand, *partial* live-rendering observations, not verification of the new changes.
- **2026-10-13, v0.1.1 caption change:** Implemented after smoke feedback.
  No claim of in-game validation of this new label yet. Previous master behavior has not been
reconstructed as a verified regression baseline; preserve master until a live pass
is accepted.

## Delivered packages and commits

| 2026-10-18 | resonance.6 ability-first Learn UI | Local property PNGs, colored/transparent rows with right-aligned icons, SC/MB icon captions, pooling and anchored edit guide | `af53257`, `a5c0ecf`, `79fd425`, `e634d41`, `fd6b1c5`, `91b18f4` | Lua 5.1 and synthetic smoke passed; FFXI pending |

| Date | Batch | Work | Reference | Status |
| --- | --- | --- | --- | --- |
| 2026-10-13 | resonance.5 layout | Bar and MB captions with countdowns, upward-growing Learn panel, lifted edit handle, default Y -11; Lua 5.1 compatibility and parser check | `da28cda`, `677de95`, `7c6b178`, `a2784c6`, `c2f848c` | Committed / Lua 5.1 syntax passed / live untested |
| 2026-10-13 | v0.1.2 offset | Add bar-relative property-label offset in `//sc names offset <x> <y>` | `15ec5e4`, `39323f9`, `ea1c5e8` | Committed / live untested |
| 2026-10-13 | v0.1.2 README location | Place README inside installable folder, keep WORKFLOW/TESTING at ZIP root and sync NPCMirror guide | Canonical NPCMirror `WORKFLOW.md`; package builder updated | Documentation/package-only change |
| 2026-10-13 | v0.1.2 packaging | Adopt consolidated NPCMirror workflow, retire duplicate docs; CI produces one-addon-directory artifact | `5831d2b`, `2da4ec1`, `d97ee94`, `d64e819`, `df535cc` | GitHub Actions run 38449553310 succeeded, artifact 11838873673; no Lua behavior changes |
| 2026-10-13 | v0.1.2 | Smooth rendering, short labels, rounded dark tracks and off-screen edit recovery | `f989b8a`, `d6b13f0`, `32dca6d`, `6ae3365`, `a9f3ca3` | Committed / live untested |
| 2026-10-13 | v0.1.1 | Add attached property label and MB clearance in `resonance_ui.lua` | `9544346` | Committed / live untested |
| 2026-10-13 | v0.1 | posimagi skill database refresh | `25513fb` | Committed / live untested |
| 2026-10-13 | v0.1 | first standalone gradient renderer and independent timers | `a1ad1d3`, `b3238f3` | Committed / live untested |
| 2026-10-13 | v0.1 | manual display, Light/Dark simplification, scale handle, schema correction, and load-time guard | `d0056c6`, `d021e08`, `71902d3`, `0308a9e`, `5522303`, `9f62963` | Committed / live untested |

## User-provided materials, observations, and requests

- **2026-10-18:** User chose ability-first, left-aligned names, colored by the
  resulting FFXI-resolved skillchain, with each ability's own property PNGs in
  a fixed right-aligned icon column. Confirmed one expected result per ability
  using existing FFXI priority logic, rather than enumerating speculative
  combinations; requested transparent styling and typography consistent with
  bar labels, reusing XIVCrossbar property icon assets. Explicitly authorized
  implementation. MB spells inventory recommendations are separate/future.

| Date | Material or instruction | Provenance |
| --- | --- | --- |
| 2026-10-08–13 | Skillchains design dialogue: eventual UI-free play, resonance under target HP, three information levels, separate learning panel, gradients, independent timing windows | Project conversation |
| 2026-10-13 | Franklet EnemyBar2 setup-mode screenshot, approximately 1280×709; main Target HP bar low on screen, subtarget and focus stacked above | User-provided screenshot in project conversation |
| 2026-10-13 | Explicitly disable job/subjob MB detection; default SC only, `display sc|mb|both`; `sc edit` drag, add scaling mode; no Japanese nomenclature or simulated sequences | Project conversation |
| 2026-10-13 | Addon loaded and basic commands worked; broader testing environment still being prepared | User report in project conversation |
| 2026-10-13 | Requested a smaller EnemyBar2-style Arial bold italic label under the SC bar listing currently resonating properties, including the properties of the opening WS | Project conversation |
| 2026-10-13 | Requested white caption with black stroke, future level colors, L1–L4 property abbreviations, less stutter during countdown, rounded bar corners and darker translucent tracks; reported SC bar off-screen and unmovable on Lionstag's small resolution | User report in project conversation |
| 2026-10-13 | Reported ambiguous Skillchains versus Skillchains-resonance-ui-test folders in previous archive; pointed out retired AGATHOS/DESIGN documents and requested compliance with consolidated NPCMirror WORKFLOW.md | User report and document review |
| 2026-10-13 | Requested that future testing ZIPs put README.md inside the installable addon folder, while WORKFLOW.md and TESTING.md remain at the ZIP root | User-approved convention |
| 2026-10-13 | Asked for a command to move the property name text upward until it slightly overlaps the resonance bar | User request in project conversation |
| 2026-10-13 | Confirmed `//sc edit` dragging works, liked current bar appearance, found name offset Y=-11 suitable; requested edit handle above bar, bar-attached timers, simplified result-grouped learning list growing upward, and asked whether bar and panel backgrounds match | Direct user report in project conversation |

Preserve this record; corrections use strike-through with the reason and replacement,
rather than silently deleting prior entries.
