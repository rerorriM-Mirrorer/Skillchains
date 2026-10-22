# TargetSC — elemental resonance

## 0.11.0 Test11 — Killala defaults, layered MB bloom and signed SC descent

Merge **TargetSC-0.11.0-Test11-Bloom-Descent-Lua-Patch.zip** into Windower/addons, preserve TargetSC/data/, then `//lua reload TargetSC`. Cumulative Lua-only patch over Test5–10.1; native 0.5.0 and latest Skillchains Animation8.8 are unchanged. Existing saved settings are preserved. `//tsc preset default` deliberately resets all visual values to the effective global + Killala profile in **settings(20261022-164147).xml**, including display both, global opacity .27, height .66, ground height .3 plus lift .04, trace opacity .6, disc slowdown 3, speeds opener/L1/L2/L3/L4 = 4/2/3/4/0 at multiplier .1, MB master .66, idle .1 × gain 3, MB duration .9, hold .6, return 2, ending soft/2s, introduction one flash/.6s, rise .01, expansion 0, property lift .3 and shimmer 1. No personal XML is modified or included.

On a confirmed MB, the existing large breathing glyph immediately reaches its full configured **mb expand** and **mb rise** offsets, holds alongside the small trace, then contracts and settles along the same quintic return. It keeps its underlying opacity breath and reverse rotation; the burst brightening and elemental color blend return to that continuing breath instead of fading the glyph away and recovering later. Positive mb burst keeps a full initial strike and shapes the return strength; 0 disables the large-glyph strike. Further bursts immediately re-strike the full configured peak. The large glyph remains independent of mb floor, which can disable the small trace response. Master/effects settings and real-window endings still apply; classic style retains its earlier rising/fading comparison.

Shared hold = maximum of **mb hold** and **37.5% of mb duration** (the ring's hit-flash interval), followed by **mb return** seconds. Killala's defaults therefore hold .6s and return over 2s. Expansion 0 is faithfully preserved: to see a size bloom, try `//tsc mb expand 0.2`; `//tsc mb rise 0.01` remains the saved lift fraction of calculated effect height. `mb lift` remains the separate small-trace world-space offset. The MB ring stays vertically steady.

`//tsc sky descent <-4..4>` shapes only the SC pair's descent after the existing top hold. **0 preserves the exact previous curve**; positive values move farther early then slow toward the close, negative values linger higher early then accelerate. Try `//tsc sky descent 1`, `2`, `-1`, and `0`. No hold, deadline, color timing, disc spin or vibration clock is changed. The sky radius continues following actual separation through the existing bell profile, so a faster initial descent also brings its wide bell radius inward sooner. Closed level-four results have no continuation descent and retain their terminal animation. MB-only mode hides the SC pair as before.

For normalized post-hold time t, the new control k remaps time to 1−(1−t)^(1+k) when k>0, t^(1−k) when k<0, or t when k=0. The previous held smoothstep (or no-hold linear curve) then uses that time. Both endpoints remain exact, including shortened source windows. New control defaults to 0.

Use `//tsc preview mb` to compare overlapping bursts and property changes; use `//tsc preview demo` with display both/sc to inspect descent. Host simulations are not live FFXI visual acceptance.

## 0.10.1 Test10.1 — vertically steady MB ring

The MB ring now stays at a fixed height in both `display mb` and `display both`, including during property changes and confirmed MBs. `mb position` interpolates between the nominal property plane (`discs height + .006`) and nominal floor-ring anchor (`ground height + ground lift`), without inheriting vibration, SC descent, transition blending or the property trace's burst lift. The same plane is used at all levels, so terminal properties do not cause a small height jump. The property disc keeps its existing wobble and MB lift/return; the large glyph retains its resting height and burst rise. Ring breathing, colors, flashes and endings remain intact. No new setting or opacity-default change.

Merge **TargetSC-0.10.1-Test10.1-Steady-MB-Lua-Patch.zip** into Windower/addons, preserve `TargetSC/data/`, then `//lua reload TargetSC`. Cumulative Lua-only patch; native 0.5.0 and Skillchains remain unchanged. Try `//tsc preview mb` in `display mb` or `display both`. Live visual acceptance pending.

## 0.10.0 Test10 — expressive MB clapper and four-link MB demo

Merge **TargetSC-0.10.0-Test10-Clapper-MB-Lua-Patch.zip** into Windower/addons, preserving TargetSC/data/, then `//lua reload TargetSC`. This is cumulative from Test5 through Test9; native 0.5.0 stays installed. No DLL replacement or game restart. Saved tuning is preserved; do not use a reset preset unless wanted. The paired full install includes the latest unchanged Skillchains Animation8.8.

Select a living enemy and run **`//tsc preview mb`**. It reuses the original Fast Blade → Gust Slash → Nightmare Scythe → Rudra's Storm → Entropy/Anguta demo at 0/9/17/24/30 seconds. Four successful links receive Wind at 12.6s, Earth at 23.8s, Water at 29.8s, and Dark at 38.8s. Earth and Water intentionally precede the next link by .2s; watch the release meet the next window's white flash. Ends at 40s. These are local visuals only, without game actions or source events. `//tsc preview demo` still runs without bursts; `//tsc preview off` returns to live state.

The new default `clapper` presentation lowers the MB ring halfway between the property trace and floor ring. Both MB shapes have a radius halfway between the property disc and main ring: .89R ordinarily and .96R at level four. The main rings gain .04 world units of clearance independently of the saved ground height. The breathing glyph keeps its low resting anchor, slowly turns backward at .025 turns/second, and shares its breathing phase with the MB ring. Level-two MB colors travel smoothly between both elements. Breathing never fully vanishes during ordinary idle: default trough 35% of peak; large-glyph peak is existing mb idle × gain 5 (default .30 before the master).

A confirmed MB immediately strikes both glyphs and the property fill in its element color, peaking at mb overall. The property trace immediately lifts .12 world units; fill remains anchored. A damped shimmer reinforces the strike. After the MB ring flash (37.5% of mb duration, or mb hold if longer), a quintic smootherstep returns trace height, trace color and fill/trace opacity together over .85s. The large glyph keeps the existing rise/expand settings; its positive burst setting shapes the release tail while the initial strike reaches the master. Existing terminal black/white-gold traces return as they settle. Closing flashes still win at the real MB deadline; SC-only mode keeps its prior fading/spinning behavior.

| Command | Default / purpose |
| --- | --- |
| `//tsc mb style clapper` | New arrangement; `classic` compares with Test9 |
| `//tsc ground lift 0.04` | Extra main-ring clearance, 0–.3; 0 restores saved ground height |
| `//tsc mb position 0.5` | Height between property trace (0) and floor ring (1) |
| `//tsc mb size 0.5` | Radius between property disc (0) and main ring (1) |
| `//tsc mb spin 0.025` | Reverse breathing-glyph turns/second, 0–.2 |
| `//tsc mb breath min 0.35` | Idle breathing trough fraction, 0–1 |
| `//tsc mb breath gain 5` | Large-glyph idle gain, 0–8; preserves saved mb idle |
| `//tsc mb lift 0.12` | Immediate property-trace lift, 0–1 |
| `//tsc mb hold 0.12` | Minimum strike hold, 0–.6 seconds |
| `//tsc mb return 0.85` | Property return duration, .1–2 seconds |
| `//tsc mb shimmer 1` | Damped strike glow strength, 0–2; 0 removes it |
| `//tsc mb overall 1` | Master MB opacity, 0–1; property baseline keeps its own alpha |

For a quieter comparison, try lift .04, shimmer .25 and breath gain 2. To restore the previous layout and ring height, use mb style classic and ground lift 0. Existing mb period, duration, effects, floor, ring, rise, expand and ending controls remain available; duration affects the rising release/ring, while return separately controls property settling. All effects remain bounded to the real source window; none extends combat timing. New appearances require in-game acceptance.

## 0.9.0 Test9 — terminal stars and MB introductions

Merge the Lua patch's TargetSC/ folder into Windower/addons, preserve data/,
then `//lua reload TargetSC`. Keep native 0.5.0 and your installed Skillchains.
Saved settings stay intact; the latest paired Animation8.7 HUD is preserved.

Umbra: white-gold star over black. Radiance: black star over white. Both use
our existing traced design, enlarged to just below the breathing glyph's size,
with the trace lifted slightly above a separate fill disc. Existing disc
opacity/outline and style controls still apply.

Each fresh MB window announces its property with synchronized white flashes
on the large glyph, property disc and middle ring, bounded by mb overall.
Normal breathing opacity and all Test8 timing controls stay unchanged.
Reload/sync snapshots do not replay the announcement.

- `//tsc mb intro 0.24`: total white introduction duration; 0 disables.
- `//tsc mb intro flashes 2`: two quick flashes; 1 selects a single flash.
- `//tsc preview Radiance 4` or `//tsc preview Umbra 4`: inspect terminal designs.
- `//tsc preview demo`: inspect introductions through the full Umbra sequence.

## 0.8.0 Test8 — the last animation pass for now

Merge the Lua patch's TargetSC/ folder into Windower/addons, preserve data/,
then `//lua reload TargetSC`. Keep native 0.5.0 and your installed Skillchains.
Your saved stage speeds and tuning stay intact; no preset reset is required.

- `//tsc discs minimum 0.5`: MB-enabled floor-disc minimum before global speed.
  At speed .1 this is one turn per 20 seconds. Stage 0 remains stationary.
- `//tsc mb opacity 0.39`: middle-ring starting strength, increasing toward 1.
- `//tsc mb overall 1`: MB master opacity, including full-strength white flashes.
- `//tsc mb ending style soft`: strong/half/strong smooth white pulses.
  Other choices: hard (three on/off flashes), both (soft then hard), off.
- `//tsc mb ending 0.9`: total ending duration; useful for inspecting both styles.
- `//tsc sky hold 0.5`: hold full nominal bell span after color settles;
  0 restores immediate descent. Rings still meet at the original deadline.

With display both or mb, the regular property glyph stays at configured opacity
until the closing interval, then fades gently under the synchronized larger-glyph
and middle-ring white flashes. Display sc retains its earlier disc behavior.
Selected endings finish dark at the MB deadline, even following a late burst.
All settings remain available whenever you want to return to this.

## 0.7.0 Test7 — bell taper and separate SC/MB display

Merge the Lua patch's TargetSC/ folder into Windower/addons, preserve data/,
then `//lua reload TargetSC`. Native 0.5.0 stays installed.

- `//tsc sky cutoff 0.55`: reach floor-ring size 55% of the way down.
- `//tsc sky curve 2`: stronger values narrow earlier; range 1–8.
- `//tsc display sc|mb|both|off`: select continuation and MB layers (modern motion).
- `//tsc mb duration 1.2`: confirmed-burst response seconds, not window length.
- `//tsc mb effects 1`: overall MB animation opacity; `mb opacity` controls the middle ring.
- `//tsc mb ending 0.6`: seconds for three decreasing white deadline flashes.

The middle MB ring grows more opaque toward the deadline; it and the breathing
glyph flash out together. The opener expansion is plain white fill. Normal
floor glyphs keep their property colors. SC closing rings fade while stationary.
New resettable defaults reflect Killala's supplied profile; saved settings stay
intact unless you deliberately run `//tsc preset default`.

## 0.6.0 Test6 — bell shape, breathing glyph and confirmed MB response

Lua-only patch for Test5: merge TargetSC/, preserve data/, then
`//lua reload TargetSC`. Native DLL remains 0.5.0; Lua reports 0.6.0-test6.
The installed Skillchains folder stays untouched.

Sky rings broaden with height into a bell profile; normal continuation expiry
keeps its existing fade but now descends/contracts to the floor glyph AFTER
the deadline. The floor glyph returns to its old low placement, independent
of floor-ring height. The opener gets its filled white expansion back.

During MB opportunity, the larger outlined glyph breathes in/out without
spinning. On a confirmed burst, the small disc flashes opaque white with an
opaque elemental trace; the larger glyph flickers white/element, rises and
expands while fading, then returns invisibly to rest. The middle ring briefly
flashes white/element and resumes its time-based fade. Source timers and
normal disc rotation are never restarted by these responses.

| Command | Tuning |
| --- | --- |
| `//tsc preview burst Wind` | Local MB preview; try any of the eight elements |
| `//tsc mb idle 0.18` | Large glyph breathing opacity; 0 hides idle breathing |
| `//tsc mb burst 0.8` | Large glyph rising-release opacity |
| `//tsc mb floor 1` | Floor hit-flash strength; 0 disables only this flash |
| `//tsc mb ring 1` | Middle-ring hit-flash strength; 0 disables only this flash |
| `//tsc mb period 2` | Full breath cycle in seconds: one in, one out |
| `//tsc mb rise 0.65` | Rise as a fraction of model height |
| `//tsc mb expand 0.25` | Extra radius during release |
| `//tsc mb opacity 0.3` | Normal middle MB ring opacity, separate from glyphs |
| `//tsc discs height 0.008` | Glyph height above model ground; original low default |
| `//tsc sky expand 0.6` | Bell widening; 0 restores constant-radius sky rings |

Small-disc baseline fill and trace remain `discs opacity` and `discs outline`,
multiplied by global opacity/lifetime. MB idle, release, ring opacity and flash
strengths are independent so you can pare back individual layers. Existing
saved settings survive. `preview demo` remains burst-free; use `preview off`
to restore live rendering. See TESTING.md for verification and late-burst tails.


## 0.5.0 Test5 — two gaps, opening glyph, L2 rotation and full MB window

Install the cumulative TargetSC patch with every FFXI client closed. Preserve
settings; new driver/model/motion/controls and native DLL must be installed
together. Skillchains stays installed as-is (tested against Animation8.6).

Opener combined now has two opposite 12-degree gaps, black surround and muted
hues. The larger white outline glyph expands/fades without spinning, replacing
the plain white expansion. It stays retained but hidden after fading, ready
for future work; there is no permanent stationary glyph under property discs.
The property glyph continues through the MB window. Ground glyphs now share
the floor-ring anchor for terrain clearance.

L2 ground and sky pairs retain their reversed elemental halves while rotating
in time with the property disc. Initial speeds still progress by level and
slow to a stop; each stage can now be tuned separately.

| Command | Effect |
| --- | --- |
| `//tsc mb opacity 1` | MB ring begins opaque; independent of overall opacity |
| `//tsc mb opacity 0.4` | Reduce MB ring opacity; its original gradual fade remains |
| `//tsc discs speed 0.1` | Global speed multiplier (new default) |
| `//tsc discs speed opener 0.5` | Opener initial turns/sec before global multiplier |
| `//tsc discs speed level1 1` | L1 initial turns/sec |
| `//tsc discs speed level2 2` | L2 initial turns/sec, shared with both ring pairs |
| `//tsc discs speed level3 4` | L3 initial turns/sec |
| `//tsc discs speed level4 0` | L4 initially stationary |
| `//tsc ground height 0.39` | Floor rings and glyph anchor (new default) |

MB ring is present during preparation, continuation and MB-only tail; alpha is
its own opacity times remaining MB seconds / 10. Existing saved values survive
installation. New defaults .39/.1 apply to fresh settings and explicit visual
preset resets. Do not reset all visuals just to install this patch.
`//tsc preview opener Fusion`, `//tsc preview chain Fusion 2`, and
`//tsc preview demo` exercise the changes; `//tsc preview off` restores live state.
See TESTING.md for simulated results, retained-effect ownership and live checks.


## 0.4.0 Test4 — optional opener treatments and paired L2 colors

Install the patch over working TargetSC; close every FFXI client before replacing
the DLL. Lua 0.4.0-test4 requires native 0.4.0. Preserve data/settings and your
installed Skillchains. The approved traced glyph is retained on both layers.
Initial opener options are combined: 12-degree gap, black surround, muted hue.

| Command | Comparison |
| --- | --- |
| `//tsc opener preset original` | Full rings, elemental glow, ordinary colors |
| `//tsc opener preset gap` | Only a 12-degree opener gap |
| `//tsc opener preset black` | Only a black opener surround |
| `//tsc opener preset muted` | Only quieter opener colors |
| `//tsc opener preset combined` | Gap, black surround and muted colors |
| `//tsc opener preset quiet` | Gap, no surround and muted colors |
| `//tsc opener gap 12` / `on` / `off` | Exact gap degrees (0–60); on=12, off=0 |
| `//tsc opener glow color` / `black` / `off` | Surround choice; global glow strength still applies |
| `//tsc opener muted on` / `off` | Same hues, reduced saturation/brightness; bare toggles |

Opener presets change only the three opener controls; saved height, motion,
glyph opacity and all other settings survive. Compare on a living target with
`//tsc preview opener Fusion`. Controls update the active drawing immediately.
The gap rotates with opener ground/sky rings and applies to their surrounds;
disc rims and activation/MB/burst effects remain complete circles. Muting also
affects opener disc fills, while glyph lines and activation white stay white.
Black is normal alpha transparency: a dark surround behind the narrow core.

L2 ground and sky pairs each show both elements with reversed halves. Both rings
remain present during white charge, then reveal their two-color palettes.
Try `//tsc preview chain Fusion 2` and the other three L2 properties.
`//tsc preview off` restores live display. Check bridge with `//tsc status`.
See TESTING.md for completed checks and pending FFXI comparisons.


## Skillchains Animation8.2 — paired configuration update

Skillchains' `glow.levels` numeric/string merge warning has been addressed at its config default and save command. Existing settings survive. TargetSC 0.3.0 Test3 Lua, DLL, rings and `lua c` synchronization remain unchanged. If Test3 is already installed, update Skillchains only; check `//sc targetsc` and `//tsc status` after reload. New build needs live verification.

## Paired Skillchains Animation8.1 + TargetSC 0.3.0 Test3 (2026-10-20)

Install **both** addon folders from the matched pairing, not standalone Animation8.1 over Test3. Skillchains reports `2.20.08.25-resonance.7-animation.8.1`, TargetSC reports `0.3.0-test3` with native `0.3.0`. The companion bridge uses Windower `lua c` commands in both directions (subscription, readiness, events, unsubscribe). The prior standalone Animation8.1 publisher contains `lua i` and cannot synchronize with Test3 if copied over the fixed publisher. The renderer tolerates numeric `glow.levels`, but saved XML may still trigger harmless load-time schema warnings. Preserve both `data/` folders and close FFXI before replacing TargetSC's DLL. Verify with `//sc status`, `//tsc sync`, `//sc targetsc`, `//tsc status`; see TESTING.md.

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

### 2026-10-22 — TargetSC 0.11.0 Test11 (A)

Adopt the complete effective Killala 16:41:47 profile as visual defaults; layer immediate full MB bloom/lift and shared trace return over continuous breathing; add signed -4..4 post-hold SC descent with exact old motion at 0. Preserve saved settings, steady MB ring, source clocks and native/HUD runtime.

### 2026-10-22 — TargetSC 0.10.1 Test10.1 (A)

Keep the MB ring vertically steady through idle hum, property transitions and burst responses, using nominal anchors at every level. Preserve property-disc wobble/lift and all other animation/settings. Host simulation; live acceptance pending.

### 2026-10-22 — 0.10.0 Test10 (A)

Low clapper MB ring/glyph, shared nonzero breathing, L2 color cycling, independent reverse spin, immediate master-capped elemental strike/lift, damped shimmer and shared quintic return; configurable restraint and classic comparison; unchanged four-link timeline with valid local MBs. Preserve latest Skillchains Animation8.8 and native 0.5.0.

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

### 2026-10-21 — 0.4.0 Test4 (A)

Optional exact opener gap, black/colored/no surround, muted hue-preserving colors, selective comparison presets; complete reversed L2 palettes on ground/sky. Retain user-approved traced glyph from d981e9d7. Native/Lua API 0.4.0; current Skillchains/bridge unchanged.

### 2026-10-21 — 0.5.0 Test5 (A)

Two opposite opener gaps; retained expanding opening glyph replaces filled flash and permanent base; shared L2 disc/ring rotation; independent stage speeds and full-window MB opacity; property glyph follows MB life; resettable .39 height/.1 speed. Current Animation8.6 HUD/bridge preserved.

### 2026-10-21 — 0.6.0 Test6 (A)

Bell-profile sky rings and post-deadline down/in close; independent original low glyph anchor; filled opener expansion; MB breathing and coordinated confirmed-hit floor/ring/rising-glyph response; independent strengths and eight-element local preview. Native 0.5.0 and Animation8.6 unchanged.


2026-10-21 Test7: configurable height-driven bell taper, separate SC/MB display, deadline pulses and MB response controls; Killala defaults; plain opener fill and stationary SC fade. Author: A.


2026-10-21 Test8: sustained MB property glyph, minimum spin, separate MB starting/master opacity, synchronized selectable endings and optional bell hold; preserved saved tuning. Author: A.


2026-10-21 Test9: lifted black/white-gold terminal stars, larger terminal discs, synchronized source-driven MB white introductions; preserved Animation8.7 and native 0.5.0. Author: A.
