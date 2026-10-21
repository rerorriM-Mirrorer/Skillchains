# TargetSC TESTING.md — start here

## TargetSC 0.7.0 Test7 — configurable bell taper and SC/MB display (2026-10-21)

Branch `development/targetsc-display-bell`, based on published Test6 `582301e7`.
Lua-only cumulative patch over Test5/Test6; native API/DLL 0.5.0 and the full
Skillchains Animation8.6 source/bridge/assets stay unchanged. Merge TargetSC/
into Windower/addons, preserve data/, then `//lua reload TargetSC`.

Sky radius follows height: `1 + sky_expand * max(0, 1 - descent / sky_cutoff)^sky_curve`.
Descent is 0 at full separation and 1 when the pair meets. Default cutoff .55,
curve 2: normal floor-ring radius from 55% descent onward. Higher curve values
contract sooner. `//tsc sky cutoff 0.6`, `//tsc sky curve 3`, `//tsc sky expand 1`.
Post-deadline SC closure restores the stationary .8s fade after meeting.

`//tsc display sc|mb|both|off` selects the modern sine/flutter layers. SC includes
continuation rings and plain white filled opener expansion. MB includes the
middle ring, breathing/rising large glyph and confirmed-burst overlays. The
small property disc is shared while either enabled opportunity is alive.
Its normal property palette no longer whitens/mutes with the SC rings; confirmed
MB flashes still overlay it. Historical legacy motion remains a comparison.

Middle-ring opacity increases from 25% to its configured peak as the original
MB deadline approaches. Both middle ring and breathing glyph end with three
white pulses of decreasing opacity within the final .6s, then disappear exactly
at the deadline. No source clocks change. Confirmed late bursts can complete
their visual response tail without extending either opportunity.

`//tsc mb duration 1.2` sets confirmed-burst response seconds (.2–4).
`//tsc mb ending 0.6` sets final deadline-flash duration (.15–2).
`//tsc mb effects 1` scales MB animated overlays and breathing (0–1), separately
from normal middle-ring `mb opacity`, small-disc opacity and global opacity.
`mb period` still controls the breathing cycle. `preview burst Wind` tests an
actual response locally; `preview demo` retains the full no-burst Umbra timeline.

Resettable defaults adopt the effective global + Killala values in the supplied
2026-10-21 08:18:23 settings: disc fill 1, trace .3, height .06, global spin .1,
opener spin 2, middle opacity .39, idle .06, release rise .01 and expansion .03,
sky expansion 1, ground height .39. Existing saved values are preserved; use
`//tsc preset default` only to deliberately restore this complete visual profile.
The personal XML is neither modified nor shipped.

Verification: Lua 5.1 parse, motion/geometry sweep, actual addon/transport
simulations, burst pooling/deadline tests and new Test7 cutoff/curve, display,
three-pulse, duration/opacity and command validation tests. This is host
simulation; the changed appearance still needs Max's live FFXI evaluation.

## TargetSC 0.6.0 Test6 — bell profile and MB expression (2026-10-21)

Branch `development/targetsc-bell-burst`, based on published Test5 `700bef12`.
User likes MB ring opacity .3 and wants to explore expressive layers, then pare
back their independent strengths. Restore pre-Test5 low floor glyph anchor.
Current Skillchains Animation8.6 source/bridge/assets and native API/DLL 0.5.0
remain byte-identical to Test5. No gameplay resolver or protocol change.

Install `TargetSC-0.6.0-Test6-Bell-Burst-Lua-Patch.zip` over working Test5 by
merging TargetSC/ into Windower/addons, preserving data/. Then
`//lua reload TargetSC`. No DLL is included or replaced; no need to close FFXI
for this Lua-only patch. Expect Lua 0.6.0-test6 with native 0.5.0. All required
changed Lua modules are included, particularly new resonance_burst.lua.
Old native 0.3/0.4 installations must first install the complete Test5 pairing.

Sky rings widen smoothly with height, reaching their full bell-profile width
at MB-ring height and keeping that width above it. `//tsc sky expand 0.6`
means an extra 60% radius; 0 restores equal-radius rings. Ground rings keep
their normal radius until the existing natural close. AFTER sc_close, within
the same fade_duration (.8s default), continuation rings move downward/inward
to the floor property glyph's location/radius. No extra continuation time or
replacement flash. Closed terminal chains retain their previous timing.

Floor property/opening/MB glyphs return to the original low anchor:
`//tsc discs height 0.008` above model ground, independent of the floor-ring
`ground height .39`. The small property disc retains its existing extra .006
spacing and ground vibration. Saved disc_height is respected; reset default
is .008. Only Test5's added ground_height contribution is removed.

The pooled large glyph has three roles: filled white expansion only for the
opener (same .96 final radius factor as before); stationary outlined breathing
through the MB window; nonspinning rising/expanding release on a confirmed MB.
Breathing defaults to a two-second full cycle (one second in, one second out),
with a deadline-aligned last-second fade and restrained white flutter. Late
snapshots do not replay an opening flash. Mid-chain snapshots still get a
resting pooled glyph, but never invent a missing opener animation.

Confirmed MB overlays the small floor disc with fully opaque white fill and
fully opaque elemental trace, blending back over .4s without restarting its
normal colors, spin or lifetime. Middle MB ring briefly flickers between white
and that element, then resumes its original opacity/fade. Large glyph flickers
white into element color, rises .65 model height and expands by .25 over 1.2s,
then returns to floor ONLY while invisible and fades back into idle breathing.
Overlapping hits recolor/rebrighten the same release without teleporting it
downward or allocating a train of glyph copies. No extra trailing copy.
Old generic burst ripples are replaced by this coordinated response.

SC and MB source clocks remain unchanged. A confirmed burst immediately before
MB expiry can finish its 1.2s visual release after the deadline; source expiry
then retains visual-tail ownership only, with no MB/SC opportunity drawn.
Reset/offline/zone still clear immediately. New opener cancels old bursts.

Independent saved controls (all full syntax uses //tsc):
- `mb opacity 0.3`: normal middle-ring opacity (new resettable default .3).
- `discs opacity 0.4`, `discs outline 0.6`: small property fill/trace; existing
  global opacity and lifetime factors still apply to these baseline values.
- `mb idle 0.18`: large glyph idle opacity; 0 hides it between bursts.
- `mb burst 0.8`: large glyph release opacity; independent of idle/global alpha.
- `mb floor 1`, `mb ring 1`: floor-disc / middle-ring hit-flash strength; 0
  removes that response without affecting other layers. At 1 the floor fill
  and elemental trace reach alpha 1 regardless of global baseline opacity.
- `mb period 2`: full breathing cycle seconds (.2–6).
- `mb rise 0.65`, `mb expand 0.25`: model-height rise / extra release radius.
- `sky expand 0.6`: bell width; 0 disables it (range 0–2).
- `discs height 0.008`: independent low anchor (range 0–.5).

Try `//tsc preview burst Wind` (also Fire/Ice/Water/Earth/Lightning/Light/Dark).
It creates only a local synthetic response at .6s, using normal model/render
paths, with no game action or bridge publication. SC/MB preview clocks remain
unchanged. `//tsc preview chain Fusion 2` shows breathing and bell/closing
motion without bursts. Full `preview demo` still injects NO bursts, preserving
its established five-WS source-style timeline. `preview off` returns to live.

Completed host checks: Lua 5.1 parse, actual addon controls/invalid values and
new preview dispatch, all prior motion/MB/transport/HUD regressions, new bell
and burst tests (all eight preview elements, separate alpha strengths, white
fill/elemental trace at hit, unchanged normal spin/positions and deadlines,
release recovery, two-hit overlap, late-burst cleanup, low anchor and exact
post-deadline closure). Existing native DLL/source are unchanged; package
validates identity, CRC and manifests, and excludes DLL/settings from patch.
These are host simulations. FFXI rendering, feel, depth occlusion and multibox
performance still require live testing. New effects are for sine/flutter;
legacy remains the historical animation comparison path.

---


## TargetSC 0.5.0 Test5 — retained glyph, opposed gaps, L2 spin and full MB window (2026-10-21)

**Branch:** `development/targetsc-mb-glyph-spin`. Combines user-tested Test4
`c186d765` with current Animation8.6 `3d96aeac`. Skillchains runtime, assets and
bridge are byte-identical to Animation8.6. Source-clock/protocol-v1 deadlines
are unchanged. User likes combined opener treatment and opposed L2 palettes,
and prefers ground height .39 and global disc-speed multiplier .1.

**Install:** Close every FFXI client. Back up TargetSC, preserve data/settings,
merge TargetSC/ from `TargetSC-0.5.0-Test5-MB-Glyph-Spin-Patch.zip` into
Windower/addons. This is cumulative over Test3/Test4, with all five changed
runtime files: TargetSC.lua, resonance.lua, resonance_motion.lua,
resonance_controls.lua, libs/_TargetSC.dll. New Lua/native must match 0.5.0;
status reports 0.5.0-test5/native 0.5.0, glyph=traced. Do not replace Skillchains
for this TargetSC-only patch. SceneHook ABI remains 2. Source/tests/docs included.

**Changes:** Each opener ground/sky ring and surround now has two opposite
gaps, each 12 degrees by default. Exact native open arcs are 6–174 and 186–354
degrees, 64 segments total, with no connecting segment or joined cap across
either gap. Combined remains the preferred initial opener treatment (black
surround, hue-preserving muted colors); all Test4 comparison controls remain.
Both reversed-palette L2 rings on ground/sky now share property-disc rotation.

The stationary base glyph is removed at every level. Its role moves to the
larger (.96 radius-factor) white outline glyph that expands and fades without
spinning during the opening weaponskill, replacing the plain filled white
expansion. The same logical glyph object and native shared geometry remain
available after alpha reaches zero; it is NOT destroyed just because its
animation faded. Hidden glyphs submit no native vertices. The retained object
survives subsequent chain states and ordinary visual expiry; explicit source
expiry, reset, zone/logout, or a new opener releases/replaces its ownership.
This reserves it for future effects without inventing a new burst animation.

Property discs retain their colored fill/white design and now live through the
MB opportunity (taking the greater SC/MB fade while they overlap). After the
opening expansion disappears, there is no stationary glyph beneath them.
Ground height now anchors the property/opening glyphs as well as floor rings,
so .39 clears floor geometry for the whole ground design.

**MB ring:** Visible from the successful chain's source `created` timestamp
through `mb_close`, including preparation and continuation overlap; no MB ring
is invented for an opener with mb_close=0. Same time-based linear fade as before:
remaining seconds / 10, clamped to [0,1], now multiplied by independent
`//tsc mb opacity <0-1>` (default 1). Global opacity/brightness do not multiply
this core. At registration of a ten-second window it is opaque, then gradually
fades. Opacity 0 hides the MB ring; master off still disables all drawing.
Its midpoint position and element choice are preserved. Actual confirmed burst
rings still use their existing behavior and do not change source deadlines.

**Speed/defaults:** Global `//tsc discs speed 0.1`, ground height .39 are new
resettable defaults, never overwriting existing saved tuning. New per-stage
initial turns/sec before that multiplier: `//tsc discs speed opener 0.5`,
`level1 1`, `level2 2`, `level3 4`, `level4 0`. Each command requires its own
`//tsc discs speed` prefix. Global speed/slowdown still apply; L2 ring pair follows
the same analytic angle as its disc and stops with it. Other successful-level
outline rings retain their previous rotation behavior. Legacy motion remains
an explicitly historical comparison path; use sine/flutter for new presentation.

**Live test:** Select a living enemy; `//tsc opener preset combined`,
`//tsc preview opener Fusion`: two gaps on opposite ends; larger white outlined
glyph expands/fades without rotation, then only property disc remains. Compare
`//tsc preview chain Fusion 2` and all other L2 properties: two complete palettes,
reversed halves, rotating together on ground/sky and matched to property disc.
`//tsc mb opacity 1`, then .4: MB ring visible during white charge, countdown and
MB-only tail, fading to its original deadline. Property glyph should persist
through that tail. Run `//tsc preview demo`, then `//tsc preview off` for real
opener/chain/MB checks, subscriber/load-order/reload and multiclient checks.
Preserve the preferred .39/.1 saved settings; no global preset is necessary.

**Completed host checks:** Lua 5.1 parser; updated full motion sweep and Test4
comparisons; new MB/glyph test checks opacity at registration/overlap/tail,
independence from global alpha, unchanged MB deadline, retained object identity
through fade and chain advance, no stationary base/replayed expansion, MB-lived
property disc, matched L2 angles and stage speeds, explicit source cleanup;
actual addon controls/selective presets/invalid inputs; real-addon bridge
transport; latest HUD/terminal renderer, commands and demo regression; portable
stroke and two-gap geometry tests; warning-clean PE32 x86 cross-build.
Package builder protects current Animation8.6 and validates manifests/CRC.
New Test5 appearance/gameplay/multibox performance await FFXI validation.
Native maximum remains 18,048 vertices, one draw call, no hidden-glyph draw cost.

---


## Skillchains Animation8.6 terminal display only (2026-10-21)

TargetSC is unchanged. Skillchains now suppresses its misleading terminal continuation countdown; its MB numerical countdown disappears during 0.8s terminal monochrome effect and resumes afterward. Radiance gets pure-white text glyph/strokes, Umbra retains black, and the filled terminal SC track is hidden then restored for ordinary play. TargetSC continues showing its independent closed-chain floor/sky rings through preparation and terminal fade, plus MB reminder. Its source deadlines, bridge and native DLL are unchanged. Install only Skillchains, retain both `data/` directories, confirm subscriber status.

---

## Skillchains Animation8.5 companion — 2026-10-21

No TargetSC source/native changes, no bridge protocol changes or synthesized game events. Skillchains adds a separately adjustable countdown fade period (`//sc anim fade period 0.24` approximately matches TargetSC default `hum_period=.12`; not phase-locking), stronger L2 pre-window border glow, black Umbra / white Radiance terminal HUD fade and local preview. The current real FFXI TargetSC ring timing remains unaltered. Existing companion `//tsc preview demo` also remains independent. Keep TargetSC and its DLL installed as-is; only Skillchains-only folder needs update, and keep character `data/`. Check in-game bridge and visuals.

---


## TargetSC 0.4.0 Test4 — opener comparisons and opposed L2 halves (2026-10-21)

**Branch:** `development/targetsc-opener-options`. Baseline: current Skillchains
pulse/pre2 commit `0b1c6c7`; retain the user-approved traced glyph from `d981e9d7`.
User confirmed the traced design looks awesome in FFXI and now prefers ground
height .39. That is visual acceptance of the glyph, not all combat/lifecycle tests.

**Install patch:** Close ALL FFXI clients; back up TargetSC and preserve data/.
Merge `TargetSC/` from `TargetSC-0.4.0-Test4-Opener-Options-Patch.zip` into
Windower/addons. Four runtime files change together: TargetSC.lua,
resonance_controls.lua, resonance_motion.lua and libs/_TargetSC.dll.
No Skillchains files or settings are shipped in this patch. New Lua/native
API 0.4.0 must match. Status reports 0.4.0-test4/native 0.4.0, glyph=traced.
Bridge v1 and SceneHook ABI 2 are unchanged; latest HUD runtime is preserved.

**New settings:** opener_gap=12 degrees, opener_glow=black, opener_muted=true
are the initial combined treatment. Existing height, glyph opacity, movement
and other saved tuning survive. No global preset is needed for installation.
`//tsc opener preset original|gap|black|muted|combined|quiet` changes only these
three opener controls; original restores the prior opener treatment. Individual
controls: `//tsc opener gap 12` (on=12, off=0, numeric range 0–60),
`//tsc opener glow color|black|off`, `//tsc opener muted [on|off]` (bare toggles).
They save immediately and affect active previews/live openers. Global glow 0
still suppresses all surrounds, including black; preset black does not raise it.

Gap applies only to opener ground/sky rings and their surrounds, rotating with
them. Native geometry emits 64 segments over 348 degrees, using exact 6-degree
and 354-degree endpoints at gap=12; no closing segment bridges the gap.
Glyph rims, awakening, MB reminder and burst effects remain complete circles.
Black surround uses normal source-alpha blending, behind the core; it darkens
background rather than automatically desaturating the colored core. Muted
colors preserve hue with 75% saturation and 82% value, on opener rings and
colored disc fills. The white activation transition and white glyph lines stay.

**L2:** Fusion/Fragmentation/Distortion/Gravitation each draw two vertically
stacked rings on ground AND sky, every ring split into the full two-element
palette, second ring reversed. Both remain present from initial white charge
through countdown/fade; ring offsets, motion and source clocks are preserved.

**Comparison:** Select a living target; `//tsc preview opener Fusion`, then
switch opener presets while visible (replay preview if it expires). Compare
`original`, each individual option, `combined`, and `quiet`. Ground .39 remains
saved. `//tsc preview chain Fusion 2` compares opposed halves; repeat with
Fragmentation, Distortion and Gravitation, then `//tsc preview demo` for all
levels and `//tsc preview off` for live state. Check a real opener/extension,
both load orders, reloads and multiclient frame pacing. `//sc targetsc` and
`//tsc status` should retain subscribed/synced. Synthetic HUD and TargetSC demos
remain independently launched; no new demo synchronization is implied.

**Completed host checks:** Lua 5.1 parse; actual addon commands/settings with
invalid-input guards and selective presets; all 12 opener combinations;
all four L2 opposed palettes at registration/charge/countdown/fade;
existing motion sweep/deadlines/demo/lifecycle; current Skillchains HUD command,
FX, learning and demo tests; actual-handler bridge load orders/reload/unsubscribe;
portable geometry with exact 12-degree endpoints; warning-clean x86 DLL build.
These are static/simulated: new appearance, dark surround/readability and
in-game/multibox performance remain pending. Native storage remains 18,048
vertices and one draw call. Package BUILD_INFO records source and DLL hash.

---

## Traced disc glyph patch — 2026-10-20 (A)

User selected the exact merged-outline preview: diagonal star (45 degrees),
cross width .24, central square half-size .15, and existing outer circle.
Native geometry now traces the 20-edge exterior plus four square edges;
internal cross/star overlap lines are removed. Both stationary and rotating
copies use it. The colored disc fill remains the existing full property disc.

Runtime installation is DLL-only over working TargetSC 0.3.0 Test3, including
its Animation8.1 paired installation. Close ALL FFXI clients, back up
`TargetSC/libs/_TargetSC.dll`, then merge this patch's TargetSC folder into
`Windower/addons/`. Keep existing Lua, Skillchains and data/settings.
The native API stays 0.3.0; `//tsc status` includes `glyph=traced` in native
status to identify this build. Use `//tsc discs style glyph` (or `outline`),
select a living enemy and run `//tsc preview opener Fragmentation`.
Check diagonal points, wide arms, square opening, stationary/spinning copies,
then `//tsc preview off` and a real chain. Saved ground height .33 is retained.

Host checks passed: portable geometry (closure, diagonal tips, square, radius,
sector coverage), warning-clean x86 DLL build, actual-handler paired bridge
transport, TargetSC lifecycle/commands and full motion sweep, Animation8.1 HUD
simulation. Live rendering and gameplay verification remain pending.
Working baseline: paired commit 721242f. Skillchains and all TargetSC Lua are
byte-identical to that baseline. Source/portable test accompany the DLL;
README/WORKFLOW/TESTING are included. Package BUILD_INFO identifies source
commit and DLL hash. Native maximum storage decreases to 18,048 vertices.

---



## Companion Skillchains Animation8.4 visual tiers (2026-10-20)

Skillchains promotes its white border shimmer to L2 and gold electrical glow to L3 (immediate pre-window appearance) while keeping L4 unchanged. **TargetSC Test3 Lua, native DLL, 3D rings, preview demo, source deadlines and `lua c` bridge are not modified.** The standalone `//sc demo` remains independent; do not assume a synchronized startup handshake has been added. Test `//sc targetsc`/`//tsc status` after installing the Skillchains-only folder, preserving `data/`. Host regression is separate from the pending live visuals.

---

## Independent Skillchains Animation8.3 HUD demo (2026-10-20)

Skillchains adds `//sc demo`, a **local HUD-only** five-stage sequence matching TargetSC Test3's `//tsc preview demo` timeline. There is **no automatic launch, shared clock handshake or demo event traffic** in this batch; do not assume typing the two commands independently synchronizes them. TargetSC 0.3.0 Test3 Lua, native DLL, ring animation, source-clock and `lua c` publisher/consumer transport remain unchanged. Existing live Skillchains → TargetSC events still flow during the standalone HUD preview. The new parity/transport checks are host simulations; real FFXI confirmation is pending.

---

## Skillchains Animation8.2 companion compatibility (2026-10-20; LIVE PENDING)

Skillchains removes the ambiguous typed glow-level default and saves future selections under nonnumeric `level_mask`; legacy XML remains supported. TargetSC Lua Test3, native API/DLL 0.3.0, bridge-v1 protocol, `lua c` command transport, rings/discs and authoritative deadlines are **unchanged**. Existing Test3 users should update Skillchains only, preserving both `data` folders. Confirm `//sc status`, `//sc targetsc`, `//tsc status` and optionally `//tsc sync` on reload. New pairing requires live validation; CI is static/simulated.

---

## Paired repair — TargetSC Test3 with Skillchains Animation8.1 (2026-10-20; LIVE PENDING)

Use the complete **TargetSC-0.3.0-Test3-Animation8.1-Paired-Full** package. TargetSC Lua, native 0.3.0 DLL, ring/disc presentation, source deadline handling and `lua c` subscriber are unchanged from published Test3. Skillchains Lua/HUD uses exact Animation8.1, while **its publisher must retain Test3's `lua c TargetSC` delivery**. Installing standalone Animation8.1 over the pair can silently revert the bridge to `lua i` and break synchronization. This new pairing makes that compatibility explicit and tests it through the existing real-handler transport suite.

Back up and preserve both `data/` directories. Close every game client before changing `_TargetSC.dll`. After installing, run `//sc status`, `//tsc sync`, `//sc targetsc`, and `//tsc status`. Expect Animation8.1, TargetSC 0.3.0-test3/native 0.3.0, subscribed=true, synced=true, send failures=0. No FFXI in-game validation of the *new pairing* yet. Skillchains' numeric glow-level mask errors were corrected in 8.1 but its startup config type warnings may still appear; they do not drive TargetSC transport. User's private Cioara XML is not included in the public archive.

---

## Test3 published and first preview feedback — 2026-10-19

User explicitly authorized publishing and described the Test3 preview as beautiful.
Actual battle-condition and multibox testing remain pending. Floor rings can be
partially hidden by uneven terrain; use `//tsc ground height 0.10`, or try `0.15`.
This existing saved command raises the floor anchor and the sky's landing point
together, preserving separation and vibration. The `.04` resettable snapshot
baseline remains unchanged; no new runtime patch is required.

The connected GitHub account published the same three source trees on
`development/targetsc-resonance-test3`. Command-line credentials were unavailable,
so the API created new commit identities; every blob and tree hash matched the
local tested source. Original IDs are retained in commit messages and here:

| Original local commit | Published equivalent |
| --- | --- |
| `aaf233f` | `8b9c58c` |
| `0d40912` | `2590450` |
| `c99741c` | `9389252` |

The earlier blocked/local-only publication entries below describe the initial
delivery and are superseded by this record. GitHub Actions run 39280803606 was
triggered for published source `9389252`; its status must be checked separately
before claiming a CI pass. This entry changes documentation only. The package's
BUILD_INFO.json records its exact current source commit and unchanged DLL hash.

## 0.3.0 Test3 — struck ground bell, elemental sectors and complete Umbra demo (2026-10-19)

**Author:** A. **Branch:** `development/targetsc-resonance-test3`.
**Base:** Test2 `5d23e29c5800254bc4aeb853e190c481e4433411`.
**Bridge correction:** `aaf233f`. The package BUILD_INFO.json identifies the
exact final source commit, renderer DLL hash, protocol and HUD reference.
Lua `0.3.0-test3`, native API `0.3.0`, bridge v1, unchanged SceneHook ABI 2.
All new automated results below are host checks, not FFXI/native runtime tests.

### User observations and design decisions carried forward

User tested Test2 previews in FFXI, liked the direction and sine vibration, and
used Fragmentation as the comparison baseline. Observations: discs should be
closer to ground and slower; .2–.3 disc opacity preserves element readability;
strong strike wobble should settle into quieter countdown motion. A property
can itself contain multiple elements, including on an opener. Test2 discarded
all but the first opener palette color, and its star lacked the full cross and
central square. The opener fall and subsequent small ground pulses were
unwanted. Existing MB-lifetime ghost halo stays deliberately for future design.

Latest user snapshot: `settings(20261019-131605).xml`, Lionstag profile merged
with global.
Motion=sine, period=.09, amplitude=.3, damping=3, intensity=1, scale=2,
opacity=.3, brightness=4, glow=1, disc_opacity=.3; global height=1, width=2,
layout=grounded, discs=true. These exact numeric visual values are hardcoded
as Test3 defaults. Saved values are preserved until `preset default` is used.
**Amplitude has intentionally changed from model-height fraction to world
units.** Its numeric value is retained; the former target-dependent travel is
not. Strike and hum now stay consistent across model heights and user scales.

User log `Lionstag_2026.10.19.log` contains old-version preset failures
and later sync diagnostics. The bridge's `lua i` commands invoked functions
rather than reaching either real `addon command` receiver. Both directions,
ready and unsubscribe now use `lua c`. The old simulations shared the wrong
spelling; this build adds actual handler routing with distinct dispatch rules.
Raw character XML/combat logs are not distributed in the testing package.

### Install the complete paired package

Archive: `TargetSC-0.3.0-Test3-Animation8-Full.zip`; only `TargetSC/` and
`Skillchains/` installable folders, each with README, WORKFLOW, TESTING and
BUILD_INFO. Native source, portable tests, licenses and verification records
are included. No user data/settings or extra workflow copies at the ZIP root.

1. Close **every FFXI client** before replacing `_TargetSC.dll`. Back up both
   addon folders and preserve both `data/` directories.
2. Merge **both complete folders**, even if already using Animation8: its
   `targetsc_bridge.lua` needs the two dispatch corrections. TargetSC's new Lua
   rejects the old DLL; do not mix files from different versions.
3. Load Skillchains then TargetSC. Run `//tsc preset default`, `//tsc sync`,
   `//sc targetsc`, `//tsc status`. Expect TargetSC Lua 0.3.0-test3/native 0.3.0,
   source Skillchains v1, synced=true, subscribed=true and send failures=0.
   Native device may initially be pending before scene callbacks run.
4. Select a living enemy and run previews separately. `//tsc preview off`
   returns to actual source state; no preview sends game actions or HUD events.

### Main in-game comparisons — all still pending for Test3

1. **Connection first:** real opener/chain, both load orders, reload Skillchains
   while TargetSC runs, then `sync`. A healthy idle source must answer even
   with no active SC. Confirm events increment only on transitions, with no
   per-frame command spam. Verify original deadlines survive snapshot/reload.
2. **Default motion:** `//tsc preview opener Fragmentation`. Appears in place,
   without falling. No sky during the 3s pre-window. Same initial strike at
   appearance/opening, then sky rises and descends while the ground settles
   into a small hum. Compare small, large, tall and floating models. Strike
   displacement must not scale with estimated height, scale or height commands.
3. **Independent bell tuning:** compare `strike damping 0`, `3`, `8`; `hum
   amplitude 0` vs `.018`; `hum period .12` vs `.2`; `hum slowdown 1` vs `2`.
   Sky strike should settle while ground hum persists and slows. Hum settled
   amplitude is separate from slowing speed; level gain strengthens/restarts
   it after successive successful chains. `flutter` is an alias for `strike`.
4. **Requested hierarchy:** opener `Fragmentation,Scission,Impaction` gives
   main outer ring plus two smaller concentric alternatives, each in its full
   palette. L1 one ring; L2 two vertical elemental strands; L3 three vertical
   Light/Darkness strands; L4 four concentric rings. Each ground/sky set uses
   that count. Two-color opener arcs must meet without a visible geometry gap.
5. **Ground design:** `discs on`, `discs style glyph`, `discs opacity .3`,
   `discs outline .45`. Compare `style outline` and `style fill`. Circle, full
   border-reaching cross, pointed star and central square should read. Primary
   layer overlaps the unfilled glyph; secondary/tertiary layers are smaller
   and slightly above it. `discs height .008` is a world-space baseline. Fill
   opacity zero must leave the independently adjustable outline visible.
6. **Spin and awakening:** starting speeds remain .5/1/2/4 turns/sec for opener/
   L1/L2/L3; L4 is still white or black. Rotation continuously slows to a full
   stop as the sky reaches the floor and discs fade. Try `discs speed .5` and
   `discs slowdown 2`. With `discs off`, the single initial white expansion
   remains; `awakening off` removes it. No later small pulses should appear.
7. **Expiration and MB reminder:** `preview expire Fusion 2`, `preview closed
   Umbra 4`. Normal expiry fades existing positions without a white flash or
   replacement geometry. Closed results settle/fade their existing four-ring
   pair without a continuation countdown. The separate MB ghost halo stays
   until its independent source deadline. No new MB ripple style is introduced.
8. **Complete demo:** `//tsc preview demo` (or `umbra` / `full`) runs Fast Blade
   0s → Gust Slash 9s → Nightmare Scythe 17s → Rudra's Storm 24s → Entropy 30s.
   Results: Scission opener → Detonation L1 → Gravitation L2 → Darkness L3 →
   Umbra L4. Entropy assumes Anguta + qualifying Aeonic Aftermath. This is a
   cooperative example. Every hit is one second before the prior source-style
   deadline. Final charge ends 33s, rings fade, MB reminder ends 40s. **No
   confirmed burst events are injected.** Milestones are reported in chat.
9. **Resettable comparison:** `preset discsoff`, `preview demo`, then `preset
   discson`, replay. `preset default` restores the numeric snapshot plus the
   new Test3 controls, including height. Enabled/debug remain unchanged.
10. Repeat identity reuse, target switch, death/despawn, zoning, cutscene,
    off/on, restart/unload, SceneHook owner handoff, device reset and 4–6-client
    frame pacing from Test1 below. Native device/scene lifecycle code and
    identity gates are preserved, but these remain live regression checks.

### Delivery register — Test3

| Commit | Work | Publication |
| --- | --- | --- |
| `aaf233f` | Correct real command dispatch; initial real-handler transport checks | Local; push blocked by automatic approval review |
| `0d40912` | Paired Lua/native 0.3.0, bell/glyph/level hierarchy, controls, full demo and current guides | Local; not pushed |
| Package source commit | See BUILD_INFO.json for the exact final verification/package commit | Reported separately at delivery |

All completed local check output is recorded in `docs/verification/test3-*`.
GitHub Actions is configured, but no run for these unpushed commits is claimed.

### Automated coverage and practical limits

- Lua 5.1 parse of all delivered runtime/tests; actual TargetSC command/lifecycle
  simulation now validates expanded native submission arguments and saved
  presets, invalid tuning input and all new visual handlers.
- Real Skillchains + TargetSC handler simulation: both load orders, ready,
  subscribe, exact source ages/deadlines, snapshots, source reload, unsubscribe,
  off/on, zone reset and no polling. Full demo combinations are checked against
  current `skills.lua`, `aeonic_prop` and `check_props`; no duplicate resolver.
- Motion sweep: 8 properties × 3 motions × 3 layouts × 1051 frames; bounded
  32 bands/8 discs. Request-level checks cover matched strike envelopes,
  model-independent displacement, constant settled hum amplitude, slowing
  frequency, complete opener palettes, concentric/stacked level hierarchy,
  independent fill/outline/awakening, spin integrals, in-place fades and MB tail.
- Existing Animation8 HUD/learning/visual controls and original source-deadline
  regressions are rerun. Skillchains.lua, skills, UI modules, FX modules and all
  images remain byte-identical to `e3a8b63`. Publisher changes are restricted to
  the two `lua i TargetSC` → `lua c TargetSC` strings by the package builder.
- Native: x86 C++17 cross-build with warnings treated as errors; portable stroke
  and property geometry tests (full cross/star/square/sector coverage). New
  sectors use a shared joined centerline. Depth testing, no depth writes,
  stateblock restore, SceneHook header, stale-frame watchdog and bounded one-call
  geometry submission remain. Maximum vertex storage is 18,240 vertices.
- `docs/verification/test3-*` records exact completed checks. DLL loading, D3D
  rendering, actual timing/appearance and multibox performance are **not run on
  this host**. Test2 preview feedback is not Test3 gameplay approval.
- GitHub publishing status is reported separately at delivery. A local commit
  and curated package do not establish that the development branch was pushed
  or that GitHub Actions ran. Do not promote this build to master before live
  evaluation. Later MB presentation changes remain deferred.

---

## Test3 development — live bridge repair (2026-10-19)

Branch `development/targetsc-resonance-test3`, based on Test2 `5d23e29`.
Both bridge directions now deliver `lua c` addon commands, including ready and
unsubscribe. `lua i` invoked a global function and never reached the receivers.
The user's `Lionstag_2026.10.19.log` confirms the failure: subscribed=false,
zero received events. Earlier publisher/consumer tests accepted the same wrong
spelling; their transport claim is superseded, not proof of in-game delivery.

Completed host simulation: new real-addon transport test passes both load
orders, state publication, source timestamps, snapshot age, source reload,
unsubscribe/off/on and zone reset. Existing receiver and addon simulations pass.
Live sync remains pending. Animation8 HUD and combat logic are unchanged; the
bridge file is intentionally changed by the two dispatch corrections.
The full Test3 motion/renderer guide will precede this development entry.

## 0.2.0 Test2 — ground-first resonance, phase previews and visible strokes (2026-10-19)

**Author:** A. **Branch:** `development/targetsc-resonance-test2`.
**Base:** Animation8 `e3a8b632e29eeebdbd4455da470810a9574a7ddd` on
`development/skillchains-resonance-animation9`.
**TargetSC versions:** Lua `0.2.0-test2`, native API `0.2.0`; SceneHook ABI 2.
**Native commit:** `cb634e94e1fc76c82c50b16591e3f59303a076de`.
**Motion/preview commit:** `bd873b365a23251b364baf89448c7ca1daf3996a`.
The package BUILD_INFO.json records the exact final delivery commit/hash.

### User-confirmed observations carried forward

2026-10-18: TargetSC 0.1.0 rendered successfully in FFXI. Rings were faint even
at opacity/intensity 1; scale 2 fit ground/sky more appropriately, including
floating models. Intensity 2's opening wobble was liked; Fragmentation 2 looked
particularly good and concentric strands were legible. This confirms actual
rendering/partial preview behavior, not all timing, lifecycle or multibox tests.

2026-10-19: User tested **Skillchains Animation8 previews in FFXI**, found them
substantially improved and accepted them as the current working reference.
Gameplay and TargetSC may refine them later. L2 gradient strengthening and
subtle preparing-white flicker are future HUD observations; **no HUD changes
are made here**. Earlier historical delivery statements below remain intact.

### New testing payload and installation

Complete `TargetSC-0.2.0-Test2-Animation8-Full.zip`, containing only two
installable folders: TargetSC 0.2.0 and the byte-identical Animation8 Skillchains
runtime/assets/bridge. Both carry README, WORKFLOW, TESTING and BUILD_INFO.
Native source, licenses, portable stroke test and recorded checks accompany
TargetSC. No user data/settings are shipped.

**Close all FFXI clients before replacing the DLL.** Back up TargetSC/Skillchains
and preserve data. Replace the complete TargetSC addon together; new Lua
requires native 0.2.0. If already on Animation8, Skillchains need not be changed.
Load/reload Skillchains first, then TargetSC. Run `//tsc preset vivid` to try
new defaults rather than retaining saved Test1 values; it preserves height and
debug. Expect `//tsc status` to report Lua 0.2.0-test2/native 0.2.0, bridge v1.

### First live comparison — do this before extending effects

1. `//tsc preset vivid`; `//tsc discs off`; `//tsc preview pre Liquefaction`.
   White/concentric **ground** rings should charge/flutter; no sky or shrinking
   separation should appear before this preview stops at 3s.
2. `//tsc preview opener Liquefaction,Impaction`. Ground charge 0–3s, then sky
   entry/rise and continuation 3–10s. Watch feet/head anchoring on moving models.
   Ground and sky should flutter oppositely with larger early jumps, smaller
   late jumps; separation must not count down during charge.
3. Compare `//tsc motion flutter`, `sine`, `legacy` and rerun opener/chain.
   Compare layouts `grounded`, `symmetric`, `center`. Set
   `//tsc flutter period .1` vs `.2`; amplitude `.15` vs `.28`, damping `.5`
   vs `1.5`. Held offsets should jump without interpolation. A full back/forth
   is twice the hold period; L3 slows it by 1.5, L4 speeds it by .7.
4. `//tsc preview chain Fragmentation 2`; then `Light 3`, `Darkness 3`,
   `Radiance 4`, `Umbra 4`. Successful charge holds a white core until the
   0.30s color transition around the opening boundary. L2 strands must remain
   distinguishable; L3 has slower light/purple shimmer; L4 has strong gold/purple
   perimeter flicker even during white charge. L4 chains are closed: after
   charge only their independent MB tail is eligible.
5. Width/readability: `//tsc width 1`, `2`, `3` at different distances and
   resolutions. Cores stay narrow and transparent inside. Compare
   `//tsc glow 0`, `.8`, `1.5` and `//tsc brightness .7`, `1`, `1.5`.
   Correctly occluded/clipped arcs remain hidden. Look for joins/spikes or
   uneven width at grazing camera angles. D3D viewport pixels are used.
6. `//tsc discs on`; `//tsc preview opener Liquefaction,Impaction,Detonation`.
   White awakening disc should reveal three larger/lower circle/star property
   glyphs, a white ground pulse and then a primary-color pulse. Try disc
   opacity `.15` vs `.32`. Confirm opener rotation every 2s, L1 1s, L2 .5s,
   L3 .25s and still white/black L4. Discs are procedural, not exact game art.
7. `//tsc preview window Fusion 2` starts at countdown; `expire Fusion 2`
   demonstrates final convergence/exit and MB tail. `closed Radiance 4`
   demonstrates no continuation. The full `demo` is now 15s, explicitly
   reporting opener 0, first opening 3, chain 5, new opening 8, burst 9,
   continuation end 14 and MB end 15. These previews never affect HUD/game.
8. Return to live state with `//tsc preview off`, then compare actual opener,
   extension, incompatible WS and MB against Animation8. Source delays may
   differ from 3s; all charge stages scale to the actual source interval.
   Confirm no reset/replay on sync or target switch and no false continuation
   on a closed chain. Confirm old geometry disappears on an incompatible WS.

MB geometry/origin redesign is **deferred** as requested. Existing central
spell-element shimmer/ripple and separate MB expiry remain supported. Exact
icon textures, paired-ring burst ripples and per-model dimension databases
remain future work.

### Completed automated verification / remaining live checks

- Lua 5.1 parsing and existing HUD/visual command, bridge, missing/mismatched
  native and TargetSC lifecycle simulations; production bridge unchanged.
- Revised motion sweep: 8 properties × 3 motions × 3 layouts × 1051 frames;
  bounded finite geometry/colors, at most 32 bands/8 discs. Phase-specific
  previews, no pre-window countdown, distinct L2 colors, ground-first sky
  gating, discontinuous flutter vs continuous sine, disc toggle/spin and
  closed/MB-only state verified through CPU simulation.
- Snapshot continuity, incompatible-opener cleanup and confirmed burst
  SC/MB-deadline invariance verified; historical source snapshot regression
  retains original absolute combat deadlines.
- Portable native stroke math: 2304 ellipse/width cases with finite bounded
  joins, 1/2/8px floors and degenerate points. **Not D3D/DLL execution.**
- New 32-bit Windows DLL cross-compiled with GCC 13.2, C++17, -O2,
  -Wall/-Wextra/-Wpedantic/-Werror, statically linked runtimes. PE32/i386,
  sole luaopen__TargetSC export, system-only imports. SceneHook header unchanged.
- Full package validates both folders, committed source, full manifests/CRC,
  14 property icons, 3 capsule-halo textures and exact Animation8 runtime/asset
  identity. This batch does not alter Skillchains data/config/code defaults.
- Records: `docs/verification/test2-*`. **No new native loader, D3D, SceneHook
  or FFXI runtime test has been performed here.**

Still live-pending: visual/phase feel, real model movement/floating/large/small
sizing, depth and stroke joins, glyph visibility/rotation, extension timing,
target loss/reuse, death/despawn, zoning, cutscene, source/addon reload,
SceneHook owner handoff with TargetRing/TargetLines, device reset and 4–6-client
frame pacing. Keep this testing branch separate from known-good main.

For evidence: `//tsc debug on`, run one short scenario, `//tsc status`, return
`TargetSC/data/TargetSC-debug.log` and complete status text with model/phase,
resolution, client count and the settings you preferred.

---


## Paired Skillchains Animation8 compatibility — 2026-10-19

`development/skillchains-resonance-animation9` replaces HUD-only
border rendering with actual thin top/bottom perimeter primitives
instead of a full white/gold rectangle behind the dark track.
Three PNG halo sections follow one capsule outline; no overlap.
The separate 2D color/charge behaviors (L3 slow flutter, L4 fast
pre-window electricity) will inform a **future** TargetSC 3D
design pass once FFXI testing confirms the 2D result. This test
does **not** modify TargetSC 0.1.0 native DLL, Lua, rings,
burst logic, protocol or source clocks. CI tests compare original
and modified Skillchains' absolute deadlines and TargetSC publisher/
consumer state. **No new live in-game TargetSC testing is claimed.**

Only copy changed Skillchains files/assets if TargetSC is already
installed. Never replace `_TargetSC.dll` while FFXI is running.

---

## Paired Skillchains Animation7 compatibility (2026-10-19)

The testing package for Skillchains branch
`development/skillchains-resonance-animation8` adds the new
ghost-glow endcap textures, level-based glow/transition controls,
and removes vertical flare sprites from **Skillchains' HUD only**.
This does not affect TargetSC 0.1.0 native DLL, Lua, world-space
rings, Magic Burst observation, targeting, event bridge, or
authoritative SC/MB deadline timers. Static/simulated publisher,
consumer and lifecycle tests are run as before. **No new live
FFXI TargetSC testing is claimed.**

A machine already running TargetSC 0.1.0 should install updated
Skillchains files/assets only and reload Skillchains. Always close
FFXI before replacing TargetSC's DLL.

---

## Skillchains Animation6 visual-only compatibility (2026-10-19)

The independent Skillchains `development/skillchains-resonance-animation7`
branch pairs newly generated rounded flare textures and a more
efficient HUD painter with the **unchanged TargetSC 0.1.0** native
library, Lua driver and bridge. It neither publishes new combat
events nor extends/simulates the authoritative SC or MB deadlines.
The paired full installation archive includes both addon folders
and cumulative tests. With TargetSC already installed, update
Skillchains files and PNGs only, retaining `data/`, then
`//lua reload Skillchains`. If replacing the native DLL, close
FFXI first. Actual TargetSC ring/MB live verification is still
outstanding; only static/simulated compatibility was checked.

---

## Skillchains Animation4 paired compatibility

The paired Skillchains Animation4 test updates only Skillchains HUD
rendering and configuration defaults. TargetSC native DLL, Lua,
rings, bridge and MB behavior remain unchanged. No new TargetSC
in-game verification is claimed.

---

## Skillchains Animation3 paired package — 2026-10-19

The `development/skillchains-resonance-animation4` branch contains
the newest Skillchains-only opener/flare/glow/learn-column iteration,
packaged with the *unchanged* TargetSC companion. The TargetSC Lua,
native DLL, event bridge, 3D rings and MB behavior are not modified.
The Skillchains change holds the same absolute continuation/burst
deadlines and source state, so TargetSC's synchronization contract is
unchanged. Source-only simulated regressions passed; **no new
in-game TargetSC validation** has occurred. The user's separate
ring/disc and Magic Burst directions remain outstanding.

When installing, leave TargetSC in place if already up to date and
replace Skillchains Lua/assets only, preserving data and reloading
Skillchains. If replacing TargetSC's DLL, close FFXI first.
After addon reload, `//tsc sync` requests the current authoritative
Skillchains state without replaying a strike.

---

## Skillchains Animation2 compatibility — 2026-10-19

The independent Skillchains refinement branch
`development/skillchains-resonance-animation3` packages the
updated Skillchains HUD with TargetSC 0.1.0 unchanged.
The native renderer, TargetSC Lua state model, bridge
protocol, world rings, and MB handling have **no new
changes**. New HUD-only original EnemyBar2 procedural
soft-alpha flare and glow textures are under
`Skillchains/images/resonance/`; no new native
dependencies. The existing `//tsc sync` recovery
operation still requests authoritative active deadlines
without replaying historical strikes. Do not treat
Skillchains HUD synthetic tests as TargetSC live validation.

---

## Skillchains Animation1 compatibility note — 2026-10-18

The development branch `development/skillchains-resonance-animation2`
changes only Skillchains' HUD animation and icon alignment. TargetSC
0.1.0 Lua, native DLL, ring geometry, bridge protocol, Magic Burst
observation and deadlines are **unchanged**. Its paired package
`Skillchains-TargetSC-Animation1-test` ships both complete addons.
If TargetSC is already correctly installed, only Skillchains files
need copying/reloading. Replacing any loaded native DLL still
requires closing FFXI first.

The local `//sc anim preview` command does not publish new world
events. `//tsc sync` still requests the current Skillchains snapshot
from the existing bridge and must not replay an old impact or reset
any window clocks. The detailed user-proposed ground/sky ring and
spinning property-disc redesign is **deferred** to TargetSC's own
development conversation. Existing 0.1.0 in-game checks remain
outstanding; do not regard these HUD tests as their completion.

---

## Current integration package — Grid1 (2026-10-18)

The `development/targetsc-resonance-grid` branch supplies a complete
two-addon Grid1 test package while leaving TargetSC's native DLL, bridge
protocol, 3D motion, source clocks and 0.1.0 runtime unchanged. Skillchains
now supports independent Ctrl+drag 10px HUD anchor snapping. The option
is local to Skillchains; TargetSC's model-anchored rings have no screen-grid
coordinate system and are intentionally unaffected.

**Test:** install the full paired `Skillchains-TargetSC-Grid1-test`
artifact (close FFXI before touching the native DLL); test ordinary/left
Ctrl/right Ctrl drag, separate learning anchor, saved positions, boundaries,
multi-client resolutions, 0.5/2.5 scales, and `//sc grid 16`. Then confirm
`//tsc status`, subscription/resync, ring behavior, confirmed MB effects
and lifecycle exactly as described in the original Test1 below.

**Verification:** Lua syntax, synthetic HUD layout and existing TargetSC
simulations, complete packaging and source baseline comparisons via Actions.
Not yet live tested in Windower/FFXI.
**Next visual phase:** See `docs/SHARED_RESONANCE_PLAN.md` for one common
struck-bell event timeline driving both the HUD and rings, with a pale
independent-clock MB underbar. No new animation or SC/MB timer changes are
shipped in Grid1.

---

## Previous delivery — 2026-10-18 / 0.1.0 Test1

**Author:** A. **Repository:** `rerorriM-Mirrorer/Skillchains`.
**Branch:** `targetsc-companion-v0.1`. Dedicated companion branch based on the
personal `resonance-ui-v0.1-test` at
`e095657a2e7ecc5a49d05e96c1b78523a4860af5`. Personal branch and master unchanged.
Skillchains bridge commit: `43943483518847f317228d0f0fc3ba472d642685`.
Native renderer/source commit: `2dfd6b2f92e7f400cc1ffcbefe2f7823c9efd7a2`.
Lua motion/controls/tests commit: `3c445d5adabc0ce7aa4e57f4f116618dbad154fc`.
Each curated package's `BUILD_INFO.json` identifies its exact final commit and
native binary hash. All work is testing-branch work, **not a live-validated baseline**.

**Delivery:** `TargetSC-0.1.0-Test1-Full.zip`, containing exactly `TargetSC/`
and `Skillchains/`. Both have README, WORKFLOW, TESTING and BUILD_INFO inside
their installable folders. The native DLL and its complete buildable source,
SceneHook, licenses and diagnostics are inside TargetSC. Complete compatible
Skillchains files and 14 icons are included. No `data/` or character settings.

Close FFXI before replacing a DLL. Back up the existing Skillchains folder and
preserve its data. Merge both folders into `Windower/addons/`; load Skillchains
first, then TargetSC. Existing Skillchains resonance.6 tests/history remain in
`Skillchains/TESTING.md`; that history is not reset by this new addon.

## Checks completed here

| Verification layer | Result | Scope / limits |
| --- | --- | --- |
| Lua 5.1 parsing | PASS | All delivered runtime Lua and new test scripts |
| Existing learning/bar simulations | PASS | Existing learning layout, property icons, labels, drag, pooling and cleanup |
| Actual Skillchains baseline comparison | PASS | 14 identical bar snapshots against e095657: opener, successful chain, MB, MB-only, closed chain, expiry, zone/logout |
| Publisher→consumer simulation | PASS | Exact SC/MB deadlines, revisions, snapshots, subscription, duplicate/gap detection, all-target MB, no burst timer mutation, unknown elements, independent client state |
| Ring animation sweep | PASS | 7 palettes × 1121 samples: finite geometry/colors, bounded count, convergence, MB tail, scale clamps |
| Actual TargetSC Lua with simulated Windower/native sink | PASS | Preview phases, command handling, native frame submission, identity reuse gate, death/despawn, target switching, cutscene, zoning, off/on, restart/unload |
| Missing native/source simulation | PASS | Helpful commands, clean unload, no per-frame console traffic or fallback combat parser |
| Native Windows compilation | PASS | MinGW-w64 GCC 13.2, C++17, x86, -O2, -Wall -Wextra -Wpedantic -Werror; statically linked MinGW runtimes |
| Native binary inspection | PASS | PE32/i386 DLL; sole export luaopen__TargetSC; imports KERNEL32.dll and msvcrt.dll |
| SceneHook comparison | PASS | Vendored ABI 2 header byte-identical to both inspected references |
| ZIP structure / CRC / hashes | PASS in curated package builder | Complete manifests, source, licenses, 14 PNG signatures, no user data; generated BUILD_INFO identifies commit |
| Native loading and graphical rendering | **NOT RUN** | No Windows/Windower/FFXI runtime on this host |
| Live timing, motion, visual quality and multibox FPS | **NOT RUN** | User testing required |

Evidence: `docs/verification/lua-tests.txt`, `native-build.txt`,
`native-inspection.txt`, `source-review.md`. All are static/simulated build
records, **not in-game logs or screenshots**.

## First in-game sequence — primary priority

1. `//lua load Skillchains` (or reload the updated addon), then
   `//lua load TargetSC`. Run `//tsc status` and `//sc targetsc`.
   Expect TargetSC 0.1.0, source Skillchains v1, synced true; after scene callbacks,
   native device/frames should become ready/nonzero. Record any LuaCore or DLL
   errors verbatim. A device may still be pending at the instant of loading.
2. Select a living small enemy. `//tsc debug on` then
   `//tsc preview Liquefaction 1`. Watch one 13-second cycle:
   central strike → thin vibrating separated pair → collapse/reopen at 3s →
   burst shimmer/ripple at 6s → convergence/exit at 10s → central MB halo until 13s.
   Check that the rings are horizontal in world space and remain attached as
   you and the enemy move or as the camera rotates.
3. Adjust only if necessary: `//tsc opacity 0.65`, `//tsc intensity 0.65`,
   `//tsc scale 1`, `//tsc height 1`. Report whether the upper ring reads as
   sky/head height and lower ring as feet. Tall/flat/floating models use a
   height estimate; exact animated mesh bounds are not implemented.
4. `//tsc preview off`. Generate a real opener and successful extension.
   Compare against `//sc display both`. The rings hold apart during the same
   opening delay and converge over the same absolute continuation interval.
   A successful extension must collapse/reopen once, with fresh colors and the
   newly shortened source window. Switching targets must not retrigger it.
5. Generate a confirmed spell Magic Burst. The spell's element should flash
   with a quick outward ripple while the existing ring motion continues.
   Watch the bar and `//tsc status`: neither deadline restarts. Test a burst
   after continuation ends but while the independent MB window remains.
6. Return the debug log and status text with one short clip if practical.
   Describe target/model, character/client resolution, number of clients,
   and whether separation, vibration, convergence or brightness feels wrong.

## Color and lifetime tests

- Preview `Fusion 2`, `Fragmentation 2`, `Gravitation 2`, `Distortion 2`:
  each height should have two closely stacked strands in the requested colors.
- Preview `Light 3` / `Darkness 3`: three subtle concentric strands.
  Black/purple/blue should remain visible through standard alpha rather than
  additive-black invisibility; report lighting/backdrop problems.
- Preview `Radiance 4` / `Umbra 4`: four concentric white-gold/black-purple strands.
  The standard preview timeline still demonstrates an ordinary continuation;
  an actual closed level-4 chain instead settles into the MB-only halo.
- Let a real opener expire with no chain: no invented MB halo.
- Let a successful chain's SC deadline expire first: only the faint central
  MB halo remains. It must disappear at the source MB deadline.
- Confirm a closed chain has no false continuation opportunity. Existing
  Skillchains ten-second MB timing remains inherited/provisional; discrepancies
  should be fixed in Skillchains after evidence, never independently in TargetSC.
- Very early/multiple bursts should neither erase the pair nor stack unlimited
  geometry. Unknown-element nonspell bursts increment diagnostics and skip
  color rather than selecting a guessed element.

## Entity, lifecycle and SceneHook tests

- Move a target continuously at varying speed; examine projected arcs from
  above/behind/close to the floor. Check walls/terrain occlude rings and no
  depth writes obscure the enemy or later UI.
- Select two enemies with different active states; switch back before expiry.
  Each should retain its own remaining life, with no replayed strike.
- Clear target, kill/despawn target, zone, log out, enter a cutscene, then
  return. No effect should remain attached to a reused entity index.
- Preview a very small, very large and floating/custom-DAT model. Record
  model/scale/height problems. Sizing uses estimates and clamps.
- `//tsc off`, `on`, `restart`, `unload`; repeated reloads should not duplicate
  geometry or leave callbacks. Test both Skillchains/TargetSC load orders and
  reloading Skillchains while TargetSC runs. Use `//tsc sync` if delivery fails.
- Run with Skillchains absent: one source notice, no live combat interpretation;
  preview still works. Missing DLL should leave useful help/status and unload.
- Load TargetRing and TargetLines with TargetSC in every useful order. Unload
  the hook owner first, then reload; each survivor must continue drawing.
  Test the user's D3D wrapper, fullscreen/window switching and device reset.
- Test 1 then 4–6 clients. Record FPS/frame pacing with TargetSC off/on,
  stationary/active targets and bursts. Each client must show only its own
  observed state; no cross-client transport exists in this build.

## Delivery register

| Date | Batch | References | Status |
| --- | --- | --- | --- |
| 2026-10-18 | Test1 interface | Bridge 4394348; personal baseline e095657 | Committed/pushed on isolated branch; simulated baseline preserved |
| 2026-10-18 | Test1 companion | Native 2dfd6b2; motion/controls 3c445d5; exact final package source commit in BUILD_INFO.json | Native cross-compiled; static/simulated checks pass; live pending |

## User materials and requests

- 2026-10-18: User specification: separate companion dependent on personal
  Skillchains; authoritative per-client state; SceneHook references; delicate
  struck-bell separation/convergence; collapse/rebirth on confirmed chains;
  independent MB tail, confirmed spell-element ripples; L1–L4 strands;
  preview/status/debug/settings; complete native source/build instructions,
  licensing and traceable pushed commits. Primary priority is paired motion.
- References inspected directly: TargetRing at e45fdf7 and TargetLines at
  548b0e2. Full references/licenses are in THIRD_PARTY_NOTICES.md.
- ~~No TargetSC live observations or user test logs have yet been received.~~
  Superseded 2026-10-19: user confirmed Test1 rendering/preview behavior; see
  the new Test2 record above. Detailed gameplay/lifecycle validation remains pending.

Preserve this cumulative record. Corrections use strikethrough, reason and
replacement rather than deleting history.
