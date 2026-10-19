# TargetSC — elemental resonance

## 0.3.0 Test3 — ground bell, elemental geometry and a working bridge

Read **TESTING.md first**. Author: **A**. Development branch:
`development/targetsc-resonance-test3`, based on Test2 `5d23e29`.
Lua reports `0.3.0-test3`; its matching native DLL reports `0.3.0`.
The Animation8 HUD, images, resolver and SC/MB deadlines are unchanged. Both
bridge directions now use `lua c` to deliver addon commands rather than invoke
functions. **Install both addon folders even if already using Animation8.**

Close every FFXI client before replacing the DLL. Back up both folders, merge
complete `TargetSC/` and `Skillchains/`, and preserve both `data/` directories.
Existing saved values are retained; the following explicit preset restores
Lionstag's latest submitted settings and all new Test3 visual defaults:

```text
//lua load Skillchains
//lua load TargetSC
//tsc preset default
//tsc sync
//tsc status
//sc targetsc
```

Use reload instead of load when appropriate after installation. Expected:
source Skillchains v1, synced=true; publisher subscribed=true, failures=0.
Preview works with a living enemy selected even without the source addon.

### First comparisons

```text
//tsc preview opener Fragmentation,Scission,Impaction
//tsc preview chain Fragmentation 2
//tsc preview demo
```

Run previews separately. `demo` (aliases `umbra` / `full`) runs five simulated
weaponskills with four successful links, no burst events:

| Hit time | Weaponskill | Result |
| --- | --- | --- |
| 0s | Fast Blade | Scission opener |
| 9s | Gust Slash | Detonation, L1 |
| 17s | Nightmare Scythe | Gravitation, L2 |
| 24s | Rudra's Storm | Darkness, L3 |
| 30s | Entropy, Anguta + qualifying Aeonic Aftermath | Umbra, L4 |

Each extension lands exactly one second before the preceding source-style
continuation deadline. This is a cooperative example, not a single-job TP or
weaponswap plan. Umbra is terminal: charge to 33s, rings fade in place, then the
separate MB reminder halo remains until 40s. No spell or MB event is injected.
The actual current Skillchains property resolver validates the combinations.

The other explicit scenarios remain `preview opener`, `pre`, `chain`, `window`,
`expire`, `closed`, `level1`–`level4`, and `off`. Properties with commas need no
spaces. Opener/pre accept up to three properties. `window` and `expire` can
intentionally show an experimental L4 continuation; live L4 remains closed.

### Ring language

| State | Geometry per ground/sky set |
| --- | --- |
| Opener | Main property outside; secondary/tertiary properties concentric inside it; each retains its full color palette |
| Level 1 result | One elemental ring |
| Level 2 result | Two vertically stacked rings, one for each element |
| Level 3 result | Three vertically stacked Light/Darkness-colored rings |
| Level 4 result | Four concentric white/gold or black/purple rings |

An opener appears in place and wobbles; there is no downward fall. At the real
window boundary its sky rings rise, then steadily approach the ground. Both
appearance and opening use the same strike amplitude/damping. Ground rings
settle into a smaller sustained hum; sky rings retain only the damped strike.
Hum frequency slows to zero over the window, while its settled amplitude stays
separate. Each higher result reenergizes the hum. Model size still sets radius
and sky height, but **does not multiply strike/hum displacement**.

Natural expiration freezes the existing ring positions and fades them there,
without an expiration flash. A closed result similarly fades its existing
pair without showing a continuation countdown. The separate central MB halo is
intentionally retained as a reminder for the future MB design. Confirmed bursts
still use the existing independent element shimmer/ripple and do not retime SC/MB.

### Snapshot baseline and tuning

`preset default` / `preset discson` restore sine, period .09, amplitude .3,
damping 3, intensity 1, scale 2, height 1, opacity .3, brightness 4, glow 1,
width 2px, disc opacity .3, and discs enabled. `preset discsoff` restores the
same baseline with persistent discs disabled, leaving the initial white flash.
All visual settings, including height, reset; enabled/debug do not. Presets
save to the current profile. Vivid/gentle/legacy comparisons remain available.

**Amplitude .3 now means .3 world units before intensity, rather than .3 times
estimated model height.** This intentionally removes target-size dependence;
the numeric snapshot value is preserved, not its former size-dependent travel.
All following controls save automatically. Change one while replaying a preview.

| Command | Meaning and range |
| --- | --- |
| `//tsc strike amplitude .3` | Shared strike displacement in world units, 0–1; `flutter` remains an alias |
| `//tsc strike period .09` | Half-cycle seconds, .05–.5; full sine cycle is twice this |
| `//tsc strike damping 3` | Strike decay/sec for both events, 0–8; zero keeps the strike unattenuated |
| `//tsc hum amplitude .018` | Settled ground displacement in world units, 0–.3 |
| `//tsc hum period .12` | Starting half-cycle, .05–1; before level gain |
| `//tsc hum gain .35` | Added amplitude/frequency gain per result level above L1, 0–2 |
| `//tsc hum slowdown 1` | Frequency-decay power, .1–4; larger slows earlier, all reach zero at expiry |
| `//tsc ground height .04` | Floor-ring anchor in world units, 0–1 |
| `//tsc fade duration .8` | Existing-ring fade seconds, .1–1; does not extend a gameplay window |
| `//tsc discs on` / `off` | Persistent property layers; a bare command toggles |
| `//tsc discs opacity .3` | Elemental fill alpha, 0–1, independent of white glyph lines |
| `//tsc discs outline .45` | White glyph-line alpha, 0–1, independent of fill |
| `//tsc discs style glyph` / `outline` / `fill` | Colored glyph, transparent outline-only, or colored fill-only |
| `//tsc discs height .008` | Baseline glyph height in world units, 0–.5; shares ground vibration |
| `//tsc discs speed 1` | Starting-spin multiplier, 0–4; .5 halves it; zero keeps discs still |
| `//tsc discs slowdown 1` | Spin-decay power, .1–4; larger slows earlier; always stops at window close |
| `//tsc awakening on` / `off` | Initial white expansion independent of persistent discs; bare toggles |
| `//tsc awakening opacity .3` | Initial white-flash alpha, 0–1 |

Disc starting rotations are unchanged: opener .5 turns/sec; L1 1; L2 2; L3 4;
L4 stationary. Angles are analytic integrals of the slowing speed, so they do
not jump or reverse near expiry. Property layers reveal alongside the initial
white expansion. The unfilled circle/cross/star/central-square ground glyph
remains; primary property overlaps it, alternatives are smaller and above it.
The later little white/colored pulses have been removed. This is a procedural
interpretation of the inspected icons, not a pixel-identical texture copy.

Existing controls remain: `motion sine|flutter|legacy`, `layout grounded|symmetric|center`,
`opacity 0–1`, `brightness 0–4`, `glow 0–3`, `width 1–8`, `intensity 0–4`,
`scale .25–3`, `height .25–3`. Sine is smooth; flutter deliberately holds discrete
positions. Symmetric converges toward model center; center also limits inward
vibration to the current half-span. Legacy retains the original motion and
does not use the new glyph/hum controls. Lua submissions remain capped at 30Hz.
Use `status`, `help`, `debug on|off`, `sync`, `on|off`, `restart`, and `unload`.

Test3 has passed host simulations, portable geometry tests and a 32-bit Windows
cross-build. **Its native loading, visual feel and actual gameplay remain FFXI tests.**

---

## Historical Test2 reference (superseded by Test3 above)

## 0.2.0 Test2 — ground-first charge, flutter and visible cores

**Read TESTING.md first.** This batch develops TargetSC only. Paired Skillchains
remains Animation8 (`e3a8b63`, `resonance.7-animation.8`), including its source
state, bridge, HUD code and all assets. Author: **A.** New branch:
`development/targetsc-resonance-test2`.

The new native DLL reports **0.2.0**; Lua reports **0.2.0-test2**. Close **all
FFXI clients** before replacing `TargetSC/libs/_TargetSC.dll`, then merge the
complete `TargetSC/` folder and preserve `data/`. The full testing ZIP also
contains the complete, unchanged Animation8 Skillchains runtime. If already
running Animation8, updating only TargetSC is sufficient.

### First comparison

```text
//lua load Skillchains
//lua load TargetSC
//tsc preset vivid
//tsc preview opener Liquefaction,Impaction
//tsc preview chain Fragmentation 2
```

Use reload instead of load for already loaded addons after installing. The
**vivid preset** deliberately pushes this test to scale 2, opacity 1, intensity
2, 2px cores, brightness 1, glow .8 and disc opacity .32. Saved settings are
otherwise preserved. `preset gentle` gives a quieter starting point; neither
preset resets height or debug. `preset legacy` selects original motion and
turns discs off. This is for comparison, not a claim that the new native stroke
is identical to the old world-width raster.

### Phase-specific local previews

Select a living enemy. These scenarios do not send game actions or source
bridge events. `//sc anim preview ...` remains a separate HUD-only preview.

| Command | Scenario |
| --- | --- |
| `//tsc preview opener [property[,property...]]` | Ground charge 0–3s; sky enters/countdown 3–10s; no MB |
| `//tsc preview pre [property]` | Ground-only charge, stopping at 3s before countdown |
| `//tsc preview chain [property] [1-4]` | Successful white recharge 0–3s; countdown 3–9s; MB to 10s (L4 is closed) |
| `//tsc preview window [property] [level]` | Countdown begins immediately, no staged hit or pre-window |
| `//tsc preview expire [property] [level]` | Last second of continuation, then independent MB tail |
| `//tsc preview closed [property] [level]` | Closed result, charge settles into MB-only state; no SC opportunity |
| `//tsc preview demo [property] [level]` | Opener at 0, source-like opening at 3, chain at 5, new opening at 8, burst at 9, SC ends 14, MB ends 15 |
| `//tsc preview level1` through `level4` | Successful chain examples (Liquefaction/Fusion/Light/Radiance) |
| `//tsc preview off` | Return to live state |

`//tsc preview Fragmentation 2` still works and now aliases the **single chain**
scenario; chat explicitly reports its phases. No-argument preview is opener.
Only opener/pre/demo allow up to three comma-separated opening properties.
The full demo's L4 result is closed, so it has no post-chain SC countdown.
Window/expire are deliberately open-window experiments even for a chosen L4
palette. Live closed-chain semantics remain authoritative.

### Motion and readability controls

| Command | Meaning / range |
| --- | --- |
| `//tsc motion flutter` | Held alternate positions; no tween between flutter samples (default) |
| `//tsc motion sine` | Smooth oscillation on the new phase timeline |
| `//tsc motion legacy` | Original immediate paired opening and decaying 13Hz wobble |
| `//tsc layout grounded` | Lower ring near feet; sky approaches it; opposed flutter (default) |
| `//tsc layout symmetric` | Pair converges toward model center |
| `//tsc layout center` | Flutter toward the center and back toward the current separated positions |
| `//tsc flutter period 0.15` | Seconds held per alternate position, .05–.5; a full back/forth takes twice this |
| `//tsc flutter amplitude 0.28` | Fraction of model height before intensity/damping, 0–1 |
| `//tsc flutter damping 0.85` | Exponential amplitude decay per second after opening, 0–8 |
| `//tsc intensity 2` | Vibration and transient response multiplier, 0–4 |
| `//tsc width 2` | Screen-pixel minimum core thickness, 1–8, independent of model scale/distance |
| `//tsc brightness 1` | Core alpha multiplier, 0–4; opacity eventually saturates at 1 |
| `//tsc opacity 1` | Overall alpha, 0–1 |
| `//tsc glow 0.8` | Surrounding luminous width/alpha, 0–3; 0 removes halo bands |
| `//tsc discs on` / `off` | Procedural circle/star glyph layer |
| `//tsc discs opacity 0.32` | Ground disc fill alpha, 0–1 |
| `//tsc scale 2` / `height 1` | Existing model sizing controls, .25–3 |
| `//tsc status` / `debug on` | Phase/settings, source health and native diagnostics |

The native stroke projects the 3D centerline first and widens it with bounded
screen-space joins. It preserves projected depth/rhw, uses the scene depth
test, writes no depth and keeps the complete state-block restore. Visible,
unclipped arcs have at least the requested screen thickness; hidden/near-plane
or degenerate arcs are still culled. No wall-through drawing is introduced.

### What to look for

An opener starts with concentric ground strands, a white expansion and fall,
then reveals its property colors and ground glyphs. Source pre-window thirds
map to the white awakening, property reveal/white pulse, and colored pulse.
At the source `sc_open` deadline the sky appears, rises quickly, and converges
through exactly the source continuation lifetime. Countdown does not run in
the pre-window. Opposed flutter is strongest around opening and shrinks with
both exponential damping and remaining separation. L3 uses a slower flutter
and 11-rad/s light modulation; L4 uses faster flutter and 23/28-rad/s gold or
purple perimeter flicker, including its white charge.

Successful chains briefly consolidate strands/discs, recharge the paired
resonance white and restore sky separation. Their core color transition spans
0.30s centered on `sc_open`, matching Animation8's white recharge. New openers
replace all earlier geometry and pending burst visuals on that enemy.

The discs are **procedural circle/four-point-star glyphs**, inspired by the
property icons; they do not load or reproduce the icons' exact artwork. They
spin every 2s for openers, 1s for L1 chains, .5s for L2, .25s for L3, and remain
still white/black for L4. Secondary/tertiary discs are larger/lower. Disc alpha
follows the source continuation fraction; a closed L4 can retain its still
MB-only disc until the independent source MB deadline. Turn discs off to
compare ring movement alone. Custom elemental assets and model databases
remain future work.

MB shimmer/ripple origin is retained from Test1 in this batch. Confirmed
bursts remain independent and cannot reset SC/MB deadlines; paired-ring MB
ripples will be revisited after motion/readability testing.

Static Lua/native geometry tests and x86 compilation are distinct from live
FFXI tests. The original rings have user-confirmed live rendering at scale 2;
**this new 0.2.0 animation/native revision has not been tested in FFXI**.

---


## Historical Test1 reference (retained)

Windower 4 companion to the personal Skillchains fork. Author: **A.**
Version **0.1.0 / testing batch 1**. New work is on `targetsc-companion-v0.1`
in the Skillchains repository; neither master nor the personal resonance branch
is changed. This branch keeps TargetSC in its own directory so a later merge
or extraction into a separate repository remains straightforward.

TargetSC draws extremely thin, translucent ground/sky rings around the selected
living enemy. An opening property strikes at the creature's center; two rings
separate, briefly vibrate, and converge using Skillchains' continuation deadline.
A confirmed chain collapses the old pair in 0.12s and reopens the new elemental
strands. Confirmed spell bursts add a short shimmer and outward ripple without
changing either deadline. A subdued central halo carries the independent MB tail.

**Start with TESTING.md.** The supplied DLL has been cross-compiled and inspected
as PE32/i386. Lua and simulated event/lifecycle tests passed. **It has not been
loaded in Windower or tested in FFXI.** No screenshot or render is presented as a
live result.

## Skillchains Animation8 paired package — 2026-10-19

The sibling Skillchains addon now uses a true dark-center
capsule perimeter and three seamless rim-halo textures.
A faster 2D L4 electrical cadence, slower L3 shimmer, and
user-controllable pre-window glow may guide later native 3D
ring revisions. The TargetSC 0.1.0 DLL, Lua, 3D effects,
authoritative deadlines and bridge are **unchanged** in this
paired test archive; see TESTING.md for the new 2D FFXI checklist.

## Skillchains Animation7 paired package — 2026-10-19

Skillchains adds white-refill/color-fade timing and new 64px mirrored
rounded ghost-glow border caps. Its HUD no longer instantiates
vertical/center flare sprites; glow is configurable by skillchain
level. The paired TargetSC 0.1.0 addon remains unchanged:
native binary, Lua, 3D rings, bridge, MB and deadline behavior.
See the cumulative TESTING.md files before in-game testing.

## Skillchains Animation6 paired package

The new Animation6 package contains Skillchains-only rounded end
flaring and renderer optimizations, with TargetSC 0.1.0 unchanged.
All TargetSC native/DLL files, world rings, SC/MB clocks and bridge
protocol remain compatible. See both `TESTING.md` files. Close
FFXI only if replacing TargetSC's loaded DLL.

## Skillchains Animation3 paired test — 2026-10-19

This paired package contains Skillchains' updated rounded opener,
first-beat caption entrance, dark-track/halo refinements, smaller
well-spaced learning icons, and the independent `//sc icons offset`
command. The complete TargetSC companion is included **unchanged**:
its DLL, world-space rings, event bridge and Magic Burst handling
are exactly the same as the preceding paired build. This is a
compatibility build, not an in-game-verified TargetSC update.
See both copies of `TESTING.md` for installation and testing steps.

## Paired Skillchains Animation2 test (2026-10-19)

The latest testing branch `development/skillchains-resonance-animation3`
only updates Skillchains HUD appearance, including smaller
properly scaled property icons, simultaneous stroke/text
fading, single white opener expansion, gradual skillchain
color changes and EnemyBar2-derived soft-alpha flares.
TargetSC 0.1.0's DLL, Lua, rings and bridge protocol
are unchanged. The two-folder test package is named
`Skillchains-TargetSC-Animation2-test`; future
ring/disc redesign belongs in TargetSC's separate
development conversation. Existing native and gameplay
tests remain pending. If TargetSC is already installed,
only Skillchains Lua/assets require replacement and
`//lua reload Skillchains` is sufficient. Otherwise
close FFXI before replacing a DLL.

## Related Skillchains HUD animation test — 2026-10-18

The paired `Skillchains-TargetSC-Animation1-test` package
contains a newer Skillchains HUD with stronger source-clocked
resonance effects and compact learning icons. **TargetSC's own code
and DLL are unchanged in this batch.** The companion still receives
the same Skillchains event/deadline snapshots. Its requested ground/
sky rings and property discs will be developed independently after
the Skillchains in-game check. No level-4 or native live validation is
claimed. The existing `//tsc sync` command requests an authoritative
source state snapshot, useful after load/reload ordering or missed
events, without inventing another animation event.

## Current development: Skillchains Grid1 (2026-10-18)

The branch `development/targetsc-resonance-grid` carries a layout-only
Skillchains Ctrl+drag update. The existing TargetSC 0.1.0 DLL and bridge
remain unmodified. A paired full test package with both addon folders is
produced by `.github/workflows/targetsc-grid-testing.yml`.
The shared struck-bell and composite MB-underbar design is recorded in
[`docs/SHARED_RESONANCE_PLAN.md`](docs/SHARED_RESONANCE_PLAN.md).
Those animations have **not** been implemented here.

## Historical 0.1.0 installation/reference

1. Close the FFXI clients before replacing native DLL files. Back up existing
   `Windower/addons/Skillchains/` and its `data/` folder.
2. Merge the testing ZIP's **two folders**, `TargetSC/` and `Skillchains/`, into
   `Windower/addons/`, preserving all existing `data/`. Do not create an extra
   nested addon folder. Do not install the repository ZIP as an addon.
3. The complete Skillchains update includes **five Lua files**:
   `Skillchains.lua`, `skills.lua`, `resonance_ui.lua`, `learning_ui.lua`, and
   `targetsc_bridge.lua`, plus all 14 property icons. No DLL goes in Skillchains.
4. Confirm `TargetSC/libs/_TargetSC.dll` is present, then load:

   ```text
   //lua load Skillchains
   //lua load TargetSC
   //tsc status
   ```

   If Skillchains was already loaded, use `//lua reload Skillchains` before
   loading TargetSC. `//sc status` reports `resonance.6-targetsc.1`.
5. Select a living enemy, then `//tsc preview Liquefaction 1`. No weapon skill,
   spell, input injection or server action is generated by preview.

TargetSC does not auto-load Skillchains. If the source is absent, live effects
wait quietly after one explanatory notice; controlled preview still works.
Use `//tsc sync` after correcting load order or `//tsc status` to diagnose.
The native module and Skillchains are independent: unloading TargetSC leaves
Skillchains' existing UI active. Unloading Skillchains clears live TargetSC
state; reloading it announces availability and requests a fresh snapshot.

## Historical 0.1.0 commands

| Command | Effect |
| --- | --- |
| `//tsc on` / `//tsc off` | Enable or disable drawing and subscription |
| `//tsc status` | Version, source/session health, SC/MB time left, target, native hook/device counters |
| `//tsc preview [property] [level]` | Timed local preview on the selected living enemy |
| `//tsc preview off` | Return to live state |
| `//tsc opacity 0.65` | Translucency, range 0–1 |
| `//tsc scale 1` | Overall model-relative scale, range 0.25–3 |
| `//tsc height 1` | Vertical estimate multiplier, range 0.25–3 |
| `//tsc intensity 0.65` | Vibration, strike and burst intensity, range 0–2 |
| `//tsc debug on` / `off` | Event/lifecycle log; off by default |
| `//tsc sync` | Recover from an interrupted/missing event stream |
| `//tsc restart` / `unload` | Graceful local lifecycle commands |
| `//tsc help` or `//tsc` | Full chat-only help |
| `//sc targetsc` | Publisher subscription, sequence and send-failure status |

`//targetsc` is also accepted. Numeric settings persist through Windower `config`
under the addon's `data/`; no user's settings are shipped in the package.

Preview defaults to Liquefaction and infers its normal tier. Property names are
case-insensitive; elemental aliases such as `fire`, `ice`, `wind` are accepted.
Try `Fusion 2`, `Distortion 2`, `Light 3`, `Darkness 3`, `Radiance 4`, `Umbra 4`.
An optional explicit level selects the visual tier for experimentation.
Each preview strikes immediately, chains at 3s, bursts at 6s, ends continuation
at 10s and ends MB at 13s. Rerun the command to repeat it. Switching target,
losing the entity, death, zoning or entering a cutscene cancels preview. A real
new state for that enemy also returns control to live combat.

## Palette and separate windows

- Level 1: individual elemental strands; a multi-property opener may expose
  several colors without claiming a successful higher-level chain.
- Level 2: closely stacked strands at both heights: Fusion light/fire,
  Fragmentation lightning/wind, Gravitation dark/earth, Distortion water/ice.
- Level 3: three subtle concentric rings, white/off-white/gold for Light or
  black/black-purple/black-blue for Darkness.
- Level 4: four concentric white-gold or black-purple rings. An aeonic tier
  already resolved by Skillchains is preserved even if the action animation's
  property name is Light/Darkness.

Separation holds during Skillchains' opening delay, then shrinks over its exact
continuation interval. A brief white-tinted exit flash surrounds expiry. The
visual flash can last up to 0.22s beyond that deadline; it does not extend the
window. A closed chain has no continuing SC opportunity: its opening flourish
settles into the central MB halo after 0.65s. MB expiry is independent; a burst
never reopens a continuation window.

## Integration and rendering

Skillchains alone observes combat and defines properties/timers. The optional
bridge sends short process-local `lua i` messages on state transitions,
snapshots and lifecycle changes. There is **no cross-client IPC**, filesystem
polling, per-frame console traffic, or combat interpretation in TargetSC.
The receiver detects sequence gaps, keeps absolute `os.clock()` deadlines and
records latency/clock differences rather than introducing competing timers.
See [docs/BRIDGE.md](docs/BRIDGE.md) for the versioned interface.

Lua generates a bounded frame of thin ring geometry at 30 Hz; native functions
submit that complete frame under a lock. The native scene callback reads the
model's display position each scene frame, using the same reference strategy
as TargetRing, then projects rings using the game's view/projection matrices
and real depth. Depth writes are off. A complete D3D8 state block restores
render states, textures, shaders and stream 0. No textures or shader compilation
are needed. At most 24 ring bands, 64 segments each and one draw submission
are used for the current enemy; inactive frames draw nothing. A 250ms native
watchdog hides a frozen Lua snapshot. Normal unload drains/unregisters the
callback; DLL detach also unregisters without waiting under the loader lock.

The SceneHook ABI 2 header is byte-identical to both reference addons. Loading,
unloading and owner handoff alongside TargetRing/TargetLines still require
live validation. Older private draw_scene hooks may fail to initialize; status
reports the hook failure instead of installing a competing patch.

Radius uses TargetRing's model-size/scale approach. Height is a **model-size
estimate**, not a measured animated mesh or exact head bone. Very tall, wide,
floating or custom DAT models may need `height`/`scale` tuning. Lua validates
ID/index, health and target eligibility at 30 Hz; native reads that index every
scene frame. A missing entity-array signature suppresses drawing and increments
tracking failures; it never draws at a guessed world origin.

## Diagnostics and evidence

Run `//tsc debug on`, reproduce a short sequence, then `//tsc status` and
`//sc targetsc`. Return `TargetSC/data/TargetSC-debug.log` and the status text.
The transition-only log rotates at approximately 1 MiB to `.log.1`.

- `source=waiting/absent`: compatible Skillchains not loaded or subscription
  reply missing. Load it and `//tsc sync`.
- `events` stays unchanged during actual WS: inspect `//sc targetsc`, bridge
  file installation, and Skillchains console errors. It normally stays unchanged
  between state transitions; there is no heartbeat per frame.
- `gaps`/`rejected`: missing or malformed frames. Resync is requested after gaps;
  `//tsc sync` also recovers manually.
- `clock delta` over 0.20s: processing latency or a clock discrepancy; inspect
  the log. TargetSC retains the source deadlines and does not silently retime.
- Native `device=pending`, zero `frames`, hook/signature errors: initialization
  or SceneHook compatibility issue. Include the complete status text.
- Rising `tracking_failures`: entity array or model-position lookup failure.
- Rising `state_failures`: D3D state capture/configuration/restore issue.
- `unknown burst elements`: a confirmed ability/WS burst lacked a reliable
  resource element. This build deliberately skips its color instead of guessing;
  confirmed spell bursts with known resource elements are supported.

## Source and build

All native source, the unchanged SceneHook header and licenses are included.
See [docs/BUILD.md](docs/BUILD.md). Use a **32-bit** toolchain; a 64-bit DLL cannot
load into FFXI. Build information and source commit are in `BUILD_INFO.json` in
curated packages. The tests and build commands are reproducible without FFXI;
none substitutes for actual game testing.

## Credits

Broguypal's TargetRing supplies the BSD-licensed SceneHook, device discovery,
projection and display-position reference code. MogSafe's MIT-licensed
TargetLines informs native state submission, ring/halo layering, motion and
lifecycle design. See `THIRD_PARTY_NOTICES.md` and `licenses/` for exact source
commits and full notices. Existing Skillchains credits and license are retained
inside its own folder.

## Changelog

### 2026-10-19 — 0.3.0 Test3 (A)

- Fix bidirectional command delivery; test real addon handlers in both load orders.
- Same world-space strike for appearance/opening, independent sustained slowing
  ground hum, no opener fall, source-timed in-place natural/terminal fades.
- Full opener palettes and requested concentric/stacked L1–L4 hierarchy.
- Joined native color sectors; circle/full-cross/star/central-square outlines,
  separate fill/line alpha, smaller/higher secondary layers, spin-to-stop.
- Independent awakening switch, snapshot-default/discs comparison presets,
  coherent tuning handlers and complete no-burst four-link Umbra demo.
- Animation8 HUD/assets/combat preserved; complete paired package and x86 source.
- Local automated verification only; Test3 FFXI/live performance pending.


### 2026-10-19 — 0.2.0 Test2 (A.)

- Ground-first source-relative charge, delayed sky entry, explicit phase previews,
  configurable held-position flutter/sine/legacy and three pair layouts.
- Projected minimum-pixel cores, independent brightness/glow controls, vivid
  comparison preset and bounded procedural property discs.
- Animation8 HUD and bridge remain byte-identical; MB redesign deferred.
- Automated Lua/native geometry checks and Windows cross-build; live pending.


### 2026-10-18 — 0.1.0 / testing batch 1 (A.)

- First standalone Lua-loaded SceneHook renderer with delicate paired rings,
  bell vibration, deadline-driven convergence and collapse/reopening.
- Optional Skillchains v1 state bridge, independent MB tail, confirmed spell
  burst shimmer/ripple, L1–L4 palettes, preview, settings and diagnostics.
- Windows i386 cross-compilation and simulated/static checks completed;
  Windower loading, visual quality and multibox performance remain live tests.
