## Current Development Status — 2026-11-23 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-lit-disc`. Pushed through Test7.22 (`77abce8`, verified with ls-remote 02:37); Test7.23 on top. Stack: `master@9476226` -> `development/targetsc-mb-rise-gradient@8624248` -> `development/targetsc-level4-collapse@446362f` -> `development/targetsc-lit-disc`.
- installed_base: Test7.22 (`77abce8`; A tested it at 02:37, Live). Package `TargetSC-0.19.23-Test7.23.zip` = files changed since `77abce8` (Lua only; DLL 0.13.0 unchanged).
- Live (A, 02:37): Test7.22 "looking awesome"; awakening ending liked on Umbra too; wants the old averaged Light lit color as an option, a pure black lit disc for level-3 Darkness, Umbra's under disc reused under Darkness with its own settings, and optional void (black) awakening and property flash for Darkness. DLL work held: A is reviewing the level-2 lighting disc and the glyph shimmer.
- Changes: Test7.23. `awakening_ending_umbra` default true. `lit_light` white|mix, `lit_darkness` black|mix (lit disc color source: hub vs sector average; Darkness black overrides). Darkness (level-3 link, not terminal): `darkness_flash_void` = fill/hub flash and intro target black (not the clapper burst element color; strokes unchanged), the lit disc's flash-in target too; `darkness_awakening_void` = link awakening disc black (link state carries `void`). `darkness_under` role `darkness-under`: Gravitation<->Distortion mixed by .5-.5cos(2pi age/cycle), alpha absolute x life, radius .78 x radius x fill size x size, rotation property angle x spin x direction, offset h - depth, inner/outer = center/edge; inserted at the property's first index after the lit disc (order: under, lit, fill). Version `0.19.23-unified-test7.23`.
- Tunables (defaults): `lit_light` white, `lit_darkness` black, `darkness_awakening_void` false, `darkness_flash_void` false, `darkness_under` true, `darkness_under_opacity` .6, `_size` 1.3, `_spin` 2, `_direction` same, `_cycle` 3, `_depth` .006, `_center` 1, `_edge` 0.
- Checks: 83/83 CI lua5.1 invocations PASS incl. new `test_darkness_723.lua` (both mb styles; order under<lit<fill, black lit, under depth/size/spin/reverse/cycle/absolute opacity/off, Darkness only, darkness mix, Light white/mix average, void flash darker + black lit flash-in, Light unaffected, void awakening; `preview mb dark`; commands). `test_awakening_ending_722.lua` updated for the umbra default. Host only.
- Pending: Test7.23 in game (`//tsc preview mb dark`, `//tsc preview mb light`).
- OPEN_Q level-2 lighting disc: which color arrangement looks best under two-element discs: split / cycle / alternate (likely: try all three Lua-only first; radial edge feathering of split/cycle quarters needs DLL 0.14.0 sliced center).
- OPEN_Q glyph shimmer: speed source, width/count, color, behavior during bursts, which glyphs (likely: follows the lit disc angle; ~90 deg, one patch; toward white + opacity; keeps running; property glyph only).

## Current Development Status — 2026-11-23 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-lit-disc`. NOT PUSHED (push attach denied); local Test7.21 `2c125f3`, Test7.22 on top; delivered as `git format-patch` (both commits). Stack: `master@9476226` -> `development/targetsc-mb-rise-gradient@8624248` -> `development/targetsc-level4-collapse@446362f` -> `development/targetsc-lit-disc` (local).
- installed_base: Test7.21 (`2c125f3`; A's 01:52 settings.xml carries the lit_* keys, Live). Package `TargetSC-0.19.22-Test7.22.zip` = files changed since `2c125f3` (Lua only; DLL 0.13.0 unchanged).
- Live (A, 01:15-02:10): lit disc "feeling good", kept as is for level 1 and Light at level 3 (cioara: lit_flash .3, opacity .81, size .97, spin 3.6, start one, level3 on); level 2 off. Wants the lit disc to match the property disc colors exactly and fade with it. MB ending: the white opening awakening disc returns at its grown size just under the descending MB ring, opacity rising fast and easing out to full (absolute) as the ring meets the ground glyph, fading with ring and glyph; every MB window, per-level toggles, Radiance/Umbra separate, Umbra off. Sliced-center lighting discs (level 2, Darkness, maybe Radiance) and the glyph-line shimmer: design under discussion (OPEN_Q below).
- Verified in code: the level 1-3 property fill never whitens at the window's end (its `life` fades over `mb_ending`); the converge whitening is the large MB glyph's. No "no whitening" option was needed.
- Changes: Test7.22. Lit disc emitted after the property's discs and inserted at that property's first index (still under); color = average of the first non-glyph `property` fill's final ARGB (its hub when it has one: Light/Darkness elements look) when `lit_bursts` (default), else the plain palette/hub captured before any flash. `lit_level3_light` (true): level 3 only for Light. Awakening ending: role `awakening-end`, clapper, `response.ending`, stage = level1-3 | radiance | umbra; radius = radius x .96 x awakening_size; offset = ring_at(p) - gap; alpha = opacity x (1-(1-p)^curve) x (response.extinguish or 1); awakening inner/outer. Kills: flashes out (sc), follows the MB glyph to the MB height (mb). Version `0.19.22-unified-test7.22`.
- Tunables (defaults): `lit_level3_light` true; `awakening_ending` on, `awakening_ending_level1/2/3` on, `_radiance` on, `_umbra` off, `awakening_ending_opacity` 1, `awakening_ending_curve` 3, `awakening_ending_gap` .005.
- Checks: 82/82 CI lua5.1 invocations PASS incl. new `test_awakening_ending_722.lua` (soft + converge: under the ring at every p, ease-out values, absolute opacity, converge fade after the deadline, stage toggles, clapper only; lit = fill color, level3 light, elements white center; `preview mb light`; commands). Host only.
- Pending: Test7.22 in game (`//tsc preview mb light`).
- OPEN_Q lighting discs: what level 2 / Darkness / Radiance lighting discs depict (likely: L2 two opposed lit sides in its two colors; Darkness a feathered shadow; Radiance four element quarters around white).
- OPEN_Q glyph shimmer: speed source, width/count, color, behavior during bursts, which glyphs (likely: follows the lit disc angle; ~90 deg, one patch; toward white + opacity; keeps running; property glyph only).

## Current Development Status — 2026-11-23 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-lit-disc` (new, on `development/targetsc-level4-collapse@446362f`). NOT PUSHED: push attach denied this session; delivered as `git format-patch`. Stack: `master@9476226` -> `development/targetsc-mb-rise-gradient@8624248` -> `development/targetsc-level4-collapse@446362f` -> `development/targetsc-lit-disc` (local).
- installed_base: Test7.20 (`446362f`, Inferred: A's 00:40 message discusses the 7.20 glyph). Package `TargetSC-0.19.21-Test7.21.zip` = files changed since `446362f` (Lua only; DLL unchanged, 0.13.0).
- Live (A, 00:40/00:53): glyph is the crunchiest part now; asked for a lit disc test: separate from the awakening disc, gradient blend, flashes in white (one or both sides) with the property disc and fades to its color on a half or quarter, between the property disc and the awakening disc, with side cycling, size and opacity that ignore the addon opacity. Next: small DLL change for a shimmer along the glyph lines.
- Changes: Test7.21 lit disc (`role='lit'`), drawn just before the link property fill at its height minus `lit_depth`, radius .78 x radius x property fill size x `lit_size`, rotation = property disc angle x `lit_spin`, blend 1. Color = average of the property palette (after the void Dark mapping), through the property disc's burst flash and MB intro whitening when `lit_bursts`, then white by 1-smooth(age/`lit_flash`). Sectors: half {lit1,lit2}, firm {lit1,lit1,lit2,lit2}, quarter {lit1,rest,lit2,rest}; lit1=a*max(1-w,b), lit2=a*max(w,b), rest=a*b, a=`lit_opacity` x property life (absolute, not x opacity/disc_opacity), b=white fraction when `lit_start`=both, w=.5-.5cos(2pi age/`lit_cycle`). Not on openers or level 4. SC kill: flashes out with the glyphs. Commands `//tsc lit ...`, help and status lines. Version `0.19.21-unified-test7.21`.
- Tunables (defaults): `lit` on, `lit_level1` on, `lit_level2` off, `lit_level3` off, `lit_shape` half, `lit_start` both, `lit_bursts` on, `lit_flash` .4, `lit_spin` 2, `lit_cycle` 0, `lit_size` 1, `lit_opacity` .6, `lit_inner` 1, `lit_outer` 1, `lit_depth` .003.
- Checks: 81/81 CI lua5.1 invocations PASS (lupa lua51 runner) incl. new `test_lit_721.lua` (both mb styles; shapes, flash-in both/one, follows the property fill color, absolute opacity, spin, cycle, levels, off = one disc fewer, `preview mb`, commands); loadstring parse of every changed .lua. Host only.
- Pending: Test7.21 in game (`//tsc preview mb`); then DLL 0.14.0 glyph-line shimmer.

## Current Development Status — 2026-11-22 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. NOT PUSHED: remote head `ff4a134`; local 7.17 `9a4e0e4`, 7.18 `f944e51`, 7.18.1 `17ceaf4`, 7.19 `9bceb01`, Test7.20 on top. Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (local).
- installed_base: Test7.19 (`9bceb01`, Inferred: A's 05:46 message follows the 7.19 delivery). Package `TargetSC-0.19.20-Test7.20.zip` cumulative since `ff4a134`, now including `libs/_TargetSC.dll` (native 0.13.0; close every client before replacing it).
- Live (A, 05:46): asked for the cross-end fix, the SC kill as a frozen ghost-white Light skillchain, the property glyph split with the halves, and seam glyph options with a size.
- Changes: Test7.20. DLL 0.13.0: glyph cap lines removed (20 lines); `native.disc` arg 17 clip angle (glyph + rim halves; `targetsc::half_clip`). Lua: levels add 0.13.0; sender passes disc.clip on 0.13.0. `kill_sc_look` light (default; `M.kill_light_state` = level-3 Light link with its window opened (sky_hold+.15)x.9 s before the kill start, bell unfolded, frozen; substituted at the top of `M.frame`) | current. `kill_sc_glyph` split (default, native 13) | flash: two clipped property-trace copies, rotation + turn, clip phi±pi/2, shifted with the halves. `kill_seam_style` line (default) | glyphs (two upright glyph3s, tilt pi/2, rotation phi, on the cut faces, riding apart, ghost-faded) | glyph (one upright glyph with the seam's flash envelope); `kill_seam_size` 1 x half the ring span. Version `0.19.20-unified-test7.20`.
- Tunables (defaults): `kill_sc_look` light, `kill_sc_glyph` split, `kill_seam_style` line, `kill_seam_size` 1.
- Checks: DLL built with `i686-w64-mingw32-g++` 13-win32 (BUILD.md command, -Werror clean), objdump PE32 / sole export / KERNEL32+msvcrt, sha256 `b3ceb95b6a905dbd…`; `test_property.cpp` (20-line glyph, no rim-to-rim segment, half_clip) and `test_stroke.cpp` PASS; 80/80 CI lua5.1 invocations PASS incl. new `test_kill_720.lua` and `test_native_kill.lua 0.13.0`. Host only; DLL drawing not seen in game.
- Pending: Test7.20 in game (DLL load, cross ends, split glyph, seam styles, ghost Light look).

## Current Development Status — 2026-11-22 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. NOT PUSHED: remote head `ff4a134`; local 7.17 `9a4e0e4`, 7.18 `f944e51`, 7.18.1 `17ceaf4`, Test7.19 on top. Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (local).
- installed_base: Test7.18.1 (`17ceaf4`; A's 05:21 settings.xml saved by it, Live). Package `TargetSC-0.19.19-Test7.19.zip` cumulative since `ff4a134`.
- Live (A, 05:21): soft shimmer loved ("so much nicer"); picks in settings.xml: dark back compression gain .18, spin 3; mb ring hold 1.8, ease 3; shimmer soft .39, turn 3, decay 1.5; opener glow white; awakening opacity level1/2/3 = 1/2/3 (per-stage fade-until back to same). Wants Light MBs white-hot and Dark MBs total void.
- Changes: Test7.19 `mb_pure` off|light|dark|both. For a Light (Dark) burst: the MB bloom is pure white (black) with no white core, its alpha ignores mb overall (the bright band reaches full opacity; the radial stops keep the rest clear); property disc fills go pure white (black) toward full opacity with the center forced clear and rims opaque, fading over `mb_pure_disc` 1.5 s; the lifted trace glyphs and bloom glyph copies over `mb_pure_glyph` 2.5 s; the large glyph at the MB ring over `mb_pure_ring_glyph` 4 s; `mb_pure_bloom_flash` 0 (Dark bloom white-hot strike). Envelope smooth(age/.08)*(1-smooth(age/T)), max over Light/Dark bursts. Burst entries now carry `element` (resonance.lua and preview). Terminal (L4) discs untouched. Preset `cioara` = A's 05:21 settings; fixture `tests/fixture_cioara_1122c.lua`. Version `0.19.19-unified-test7.19`.
- Tunables (defaults): `mb_pure` off, `mb_pure_disc` 1.5, `mb_pure_glyph` 2.5, `mb_pure_ring_glyph` 4, `mb_pure_bloom_flash` 0.
- Checks: 78/78 CI lua5.1 invocations PASS incl. new `test_mb_719.lua` (A's 05:21 profile; Fire untouched; light mode leaves Dark alone; plays `preview dark mb`). Host only.
- Pending: Test7.19 in game; next: white SC rings full white for Light MBs (not glows), Radiance's dancing double bloom as the Light MB bloom; then the DLL batch (glyph cross ends, filled glyph, glyph line glow, tracing).

## Current Development Status — 2026-11-22 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. NOT PUSHED: remote head `ff4a134`; local Test7.17 `9a4e0e4`, Test7.18 `f944e51`, Test7.18.1 on top. Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (local).
- installed_base: Test7.18 (`f944e51`; A loaded 0.19.18 at 04:22, Live). Package `TargetSC-0.19.18.1-Test7.18.1.zip` cumulative since `ff4a134`.
- Live (A, 04:22): Windower config warnings on load and on every save: `awakening_until_level1/2/3` string expected (default same), got number (1, 4, 9); "Mismatched setting types".
- Cause (Verified in code): the fade-until command saved timed values as text '4', which settings.xml reads back as a number. Changes: Test7.18.1 saves '4s'; `M.until_seconds` reads 4, '4' and '4s'; TargetSC.lua rewrites numeric awakening_until* values as text on load and on every config reload (`config.register`, Windower Config Library docs), saving once only when something changed. Version `0.19.18.1-unified-test7.18.1`.
- Checks: 77/77 CI lua5.1 invocations PASS incl. new `test_until_7181.lua` (A's 1/'4'/9 values through the real addon loader). `test_awakening_715.lua`/`test_awakening_until.lua` expect '4s'. Host only.
- Pending: confirm the warnings are gone in game; A may need to re-enter level1/2/3 fade-until values if Windower dropped them at the 04:22 load (Unknown which value it kept). Test7.18 checklist still open.

## Current Development Status — 2026-11-22 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. NOT PUSHED: remote head `ff4a134`; local Test7.17 `9a4e0e4`, Test7.18 on top. Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (local).
- installed_base: Test7.17 (`9a4e0e4`, local; A's 04:10 settings.xml carries its dark_* keys, Live). Package `TargetSC-0.19.18-Test7.18.zip` cumulative since `ff4a134` (the last pushed commit).
- Live (A, 04:10): `dark back` liked on Compression rings at gain .18-.9 with the glow turning 2-3x+ faster than the ring; back off on Gravitation and Darkness. Wants white glow on all opener properties to try. A's look = attached settings.xml (black Dark bursts `dark_glow_burst 0,0,0`; awakening level1-3 opacity 4, level3 until close). Next focus: MB burst animations, Light and Dark first.
- Changes: Test7.18. `dark_ring_back` compression (Compression rings only) + `dark_back_spin` (x ring glow spin for back-side glows). `opener_glow` white (every opener arc/ring glow white, overrides the void Dark arcs). MB ring hold: `mb_ring_hold` s (0 off), `mb_ring_ease` (-1 = mb duration x .375); burst color pure on the MB ring after the usual 12 Hz strike, ring cycle clock paused by the integral of the ring strength (`response.cycle_pause`, persistent `model.mb_ledger`), burst entries kept until hold+ease ends (glyph response timing unchanged; held color via `response.ring_element`). Soft shimmer: `mb_shimmer_style` ripple|soft, `mb_shimmer_decay` 3, `mb_shimmer_turn` .5 turns/s, `mb_shimmer_soft` .8 (lit band on the glyph and trace burst glows). Preset `cioara` = A's 04:10 settings + opener glow white, dark back compression, gain .5, spin 3; new fixture `tests/fixture_cioara_1122b.lua`. Version `0.19.18-unified-test7.18`.
- Tunables (defaults): `dark_back_spin` 1, `mb_ring_hold` 0, `mb_ring_ease` -1, `mb_shimmer_style` ripple, `mb_shimmer_decay` 3, `mb_shimmer_turn` .5, `mb_shimmer_soft` .8; `opener_glow` black. Defaults reproduce Test7.17.
- Checks: 76/76 CI lua5.1 invocations PASS incl. new `test_mb_718.lua` (A's profile; plays `preview dark mb` with hold + soft). `test_earth_713.lua` preset-reset check moved to killala (cioara now carries scission). Host only.
- Pending: Test7.18 in game; A's gain (.18-.9) and spin picks; push of 7.17 + 7.18.

## Current Development Status — 2026-11-22 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (Test7.16 `ff4a134`, Test7.17 on top).
- installed_base: Test7.16 (`ff4a134`; A ran `//tsc dark void` / `dark glow` 03:40, Live). Package `TargetSC-0.19.17-Test7.17.zip` = files changed since `ff4a134` + README.md.
- Live (A, 03:40): void liked. `dark glow 255 255 255` liked for the opener's Dark arcs, `dark glow 0 0 0` for everything else; wants the MB ring's Dark phase pure black with a violet (elemental) glow, SC rings and their glows pure black; asks to also try the Dark transparent side of ring glows in the violet. Awakening discs looking good (opacity/duration still being tuned).
- Changes: Test7.17 per-surface Dark glows `dark_glow_opener|ring|mb` ('same' = `dark_glow`) and `dark_glow_burst` ('mb' default = follow the MB glow; `resonance.apply_colors` keys on it); `dark_mb_core` glow|black (black skips the MB core lift, the MB ring glow still lifts toward `dark_glow_mb`); `dark_ring_back` off|on + `dark_ring_back_gain` 1 (SC ring glows of <=2 colors whose dim stop is dark take the MB glow there; gain scales that side's alpha in firm/gradient blends). `M.dark_glow_color(opts,where)`, `M.dark_lift(c,opts,target)`, band() `back` arg. Commands `//tsc dark glow [opener|rings|mb|burst] <choice|same>`, `dark mb core black|glow`, `dark back on|off|<0-3>`. New preview `preview dark mb` (alias `preview requiescat dark`): Requiescat links with 15 Dark MBs at 18.4, 20.6, 22.2, 23.8, 25.0, 26.4, 27.5, 29.6, 31.2, 32.6, 33.6, 34.4, 36.5, 38.0, 38.8 s. Version `0.19.17-unified-test7.17`.
- Note (Verified): Gravitation's two strands are mirrored, so with `dark back on` only the strand with Dark on its dim side shows the violet; the other keeps a black glow on its lit side.
- Tunables (defaults): `dark_glow_opener` same, `dark_glow_ring` same, `dark_glow_mb` same, `dark_glow_burst` mb, `dark_mb_core` glow, `dark_ring_back` off, `dark_ring_back_gain` 1. Defaults reproduce Test7.16 exactly.
- Checks: 75/75 CI lua5.1 invocations PASS incl. new `test_dark_717.lua` (A's profile; plays `preview dark mb` to the end). Host only (lupa runner).
- Pending: Test7.17 in game (option 1 back off vs option 2 back on); Umbra second violet MB ring idea; MB ring hold + soft shimmer; later awakening ideas.

## Current Development Status — 2026-11-22 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (Test7.15 `2697238`, Test7.16 on top).
- installed_base: Test7.15 (`2697238`; A tested it 03:01, Live). Package `TargetSC-0.19.16-Test7.16.zip` cumulative since `76cf0e6`.
- Live (A, 03:01): opener property arcs closing liked. Awakening discs far too faint even at opacity 1 (cause Verified: alpha = awakening opacity x addon opacity .27 x curve). A wants the Dark element as pure black cores with a pure-hue violet / violet-blue glow (Dark Elemental), switchable.
- Changes: Test7.16 `dark_look` classic|void, `dark_glow` elemental|indigo|tint|r,g,b, `dark_disc` black|violet|classic. Void: `apply_colors` sets E.Dark/E.Darkness to black in place; `resonance.burst_color` gives Dark bursts/kills their own table (violet in void); `M.dark_lift` turns glow colors with max channel < 60 toward violet (ring glow bands, non-L4); opener arcs touching the Dark element or in a Darkness section glow violet (overrides `opener_glow black` for those only); L3 Darkness tint band uses the violet; MB ring base color lifted (non-L4); property disc Dark parts per `dark_disc`. Awakening opacity ranges 0-4.
- Tunables (defaults): `dark_look` classic, `dark_glow` elemental (130,70,255), `dark_disc` black.
- Checks: 74/74 CI lua5.1 invocations PASS incl. new `test_dark_716.lua` (A's profile). Host only.
- Pending: Test7.16 in game; Umbra second violet MB ring idea; MB ring hold + soft shimmer; later awakening ideas.

## Current Development Status — 2026-11-22 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (Test7.14 `b4a2773`, Test7.15 on top).
- installed_base: Test7.14 (`b4a2773`; A tested it 02:39, Live). Package `TargetSC-0.19.15-Test7.15.zip` cumulative since `76cf0e6`.
- Live (A, 02:39): Umbra slow curve "looks really good". `rings converge from .09` for strands (earlier merging got in the way of the animations); converge from 1 liked for opener arcs. Dark violets rejected as the Dark element color; direction now = black core with a pure-hue violet glow (discussion, no code yet).
- Changes: Test7.15 `awakening_opacity_<stage>` (-1) and `awakening_until_<stage>` ('same') for opener/level1/level2/level3 (`M.awakening_opacity`, stage arg to `M.awakening_level`; link discs carry their level); `ring_converge_opener` 1 (-1 = converge from).
- Checks: 73/73 CI lua5.1 invocations PASS incl. new `test_awakening_715.lua` (defaults identical; stage 0 hides only that stage in `preview demo` on A's profile). `test_opener_sections.lua` pins converge off; `test_converge_714.lua` opener block pins opener -1. Host only.
- Pending: Test7.15 in game; Dark recipe (black core + violet glow); MB ring burst-color hold and shimmer look (discussion).

## Current Development Status — 2026-11-22 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (Test7.13 `358dfc3`, Test7.14 on top).
- installed_base: Test7.13 (`358dfc3`; A tried it 02:02, Live: Earth candidates seen). Package `TargetSC-0.19.14-Test7.14.zip` cumulative since `76cf0e6`.
- Live (A, 02:02): Earth gold > classic; `scission` (255,165,0) "feels GOOD", the pick for now (may revisit with the Darkness color). Crystal "cool".
- Changes: Test7.14 `rings converge on|off | from` (L2/L3 strand stacks and opener section gaps/element lifts scale by smooth(descent left / from), meeting as the sky lands; closed/L4 untouched); `umbra slow curve in|out | slow power` (in: speed to+(1-to)(1-u^p)); Requiescat preview opener = Gravitation, Scission, Darkness (Sequence; level 3; Earth, Dark, Ice, Water); `palette()` treats any Darkness/Umbra property as dark (aeonic openers; default sections layout already colors per property, so no default-look change).
- Tunables (defaults): `ring_converge` true, `ring_converge_from` .35; `umbra_slow_curve` in, `umbra_slow_power` 3. Earlier: `earth_color` classic.
- Checks: 72/72 CI lua5.1 invocations PASS incl. new `test_converge_714.lua` (defaults + A's 11-22 profile); `test_motion.lua` L2 stack assertion allows the merge at 109.2 s. `tests/test_transport.lua` fails before and after (superseded, not in CI). Host only.
- Pending: Test7.14 in game; Darkness color direction; xivcrossbar Earth to match (scission 255,165,0 pending A's final word).

## Current Development Status — 2026-11-22 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (Test7.12 `6375d8f`, docs `8d5e932`, Test7.13 on top).
- installed_base: Test7.11 (`e756eb2`, Live 00:48); Test7.12 install Unknown, so the package stays cumulative since `76cf0e6`.
- Changes: Test7.13 color pass, Earth only. `earth_color` setting + `//tsc earth classic|gold|scission|crystal|<r g b>` changes the shared Earth color table in place (rings, discs, bursts, running previews). New previews `preview demo requiescat` (Requiescat Gravitation+Scission opener > Gust Slash Detonation > Nightmare Scythe Gravitation > Rudra's Storm Darkness > Requiescat/Sequence Umbra; no bursts) and `preview earth mb` (same links, Earth MBs at 20.6, 22.2, 23.8, 27.5, 29.6, 33.6, 34.4, 36.5, 38.0, 38.8 s). Version `0.19.13-unified-test7.13`.
- Reference colors (Verified from `TargetSC/images/skillchain/*.png`): Scission/Earth 255,165,0; Detonation/Wind 0,128,0; Impaction/Lightning 128,0,128; Induration/Ice 0,206,206; Reverberation/Water 0,0,255; Liquefaction/Fire 255,0,0; Compression/Dark 0,0,0; Transfixion/Light 128,128,128. Earth elemental crystal (A's screenshot): body ~215,145,64, core ~250,214,149.
- Tunables (defaults): `earth_color` classic (176,114,48). Presets reset it to classic.
- Checks: 71/71 CI lua5.1 invocations PASS incl. new `test_earth_713.lua` (Requiescat chain checked against `check_props`/`aeonic_prop` sliced from `sc_runtime.lua`; bursts only in Earth-bursting windows). Host only.
- Pending: Test7.12 and Test7.13 in game; A's Earth pick; then xivcrossbar Earth to match; then Wind green, Lightning purple, Darkness in Compression/Gravitation.

## Current Development Status — 2026-11-22 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (Test7.12 `6375d8f`).
- installed_base: Test7.11 (`e756eb2`; A tested it 00:48, Live). Package `TargetSC-0.19.12-Test7.12.zip` cumulative since `76cf0e6`.
- Live (A, 00:48): flicker on the Umbra pulse liked; wobble after "looks so cool"; A tuning bloom sizes (radiance glow size 1.33, umbra bloom size 1.27, ring_level4_gap .09). Umbra classic MB glow is purple, which A doesn't want, so A stays on pulse.
- Changes: Test7.12 `umbra mb floor` + `umbra mb strength` up to 3; `umbra under slow` + `slow time|to`; `umbra disc flash` + `flash fade`; `preset cioara` (A's 11-22 profile; fixture `tests/fixture_cioara_1122.lua`).
- Tunables (defaults): `umbra_mb_floor` 0; `umbra_under_slow` false, `umbra_slow_time` 2, `umbra_slow_to` 0; `umbra_disc_flash` false, `umbra_flash_fade` .3.
- Checks: 70/70 CI lua5.1 invocations PASS incl. new `test_umbra_712.lua` (A's profile; preview demo). Host only.
- Pending: Test7.12 in game; making cioara the shipped defaults (offered as its own batch); color pass; glyph cross ends (DLL).

## Current Development Status — 2026-11-22 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (Test7.11 `e756eb2`).
- installed_base: Test7.10 (`c868a3c` code; A tested it 00:01, Live). Package `TargetSC-0.19.11-Test7.11.zip` cumulative since `76cf0e6`.
- Live (A, 00:01): Test7.8-7.10 "looking good"; `mb level4 depth .3` liked for Radiance; bare-setting values welcome. A asked for Umbra to grow from the MB ring like Radiance: host sim with A's profile (`preview demo`) shows the same geometry on Umbra (innermost 1.73 -> 1.79 against the MB ring 1.73; Verified host), so the difference A sees is Inferred to be the dim/pulsing Umbra MB ring; observation requested.
- Changes: Test7.11 `radiance mb flicker` / `umbra mb flicker <0-1|same>` (Umbra on top of its pulse); `umbra wobble after on|off` + `wobble peak|curve|speed`.
- Tunables (defaults): `radiance_mb_flicker` -1, `umbra_mb_flicker` -1 (= `mb_level4_depth` 1); `umbra_wobble_after` false, `umbra_wobble_peak` 4, `umbra_wobble_curve` 2, `umbra_wobble_speed` 2.
- Checks: 69/69 CI lua5.1 invocations PASS incl. new `test_level4_mb_own.lua` (A's 11-21 profile; preview demo). Host only.
- Pending: Test7.11 in game; bloom sizes for the wider ring sets (A tuning); color pass; glyph cross ends (DLL).

## Current Development Status — 2026-11-21 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse`. Runtime TargetSC (Lua only; native DLL stays 0.12.0). Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248` → `development/targetsc-level4-collapse` (Test7.7 `095b38e`, Test7.8 `b6766a3`, Test7.9 `bfe55cf`, Test7.10 `c868a3c`).
- installed_base: Test7.7 (`095b38e` content; A tested it at 22:43: collapse time good, expand mb better, L2/L3 single-ring starts preferred). Package `TargetSC-0.19.10-Test7.10.zip` is cumulative since `76cf0e6` (covers any earlier install).
- Live (A, 22:43): L2 split and L3 spread starts look much better ("so much better"); `rings level4 collapse time` good; `expand mb` preferred; ground/mb/into hard to tell apart; rings spread apart at full size instead of growing out of the MB ring; Radiance rings overlapped its MB ring.
- Changes: Test7.8 innermost L4 ring grows from the drawn MB ring (Umbra x `umbra mb size`) to `gap` outside it, outer rings spread at `spacing` on the same ease; collapse `into` aims at the drawn MB ring. Test7.9 L4 MB ring flicker (bar's L3/L4 border formula) instead of breath. Test7.10 bare number settings report the current value with the range.
- Tunables (defaults): `ring_level4_gap` .03 (-.2-.3), `ring_level4_spacing` .075 (0-.2); `mb_level4` flicker (breath; killala breath), `mb_level4_depth` 1 (0-1). Earlier: `ring_level4_open` collapse, `_collapse` into, `_expand` mb, `_collapse_time` .12, `_expand_time` -1, `_ease` 6.
- Checks: lupa `lua5.1` runner; parse of changed `.lua` OK; 68/68 CI invocations PASS incl. new `test_level4_geometry.lua` (defaults + A's 11-21 profile fixture `tests/fixture_cioara_1121.lua`), `test_mb_level4_flicker.lua` (incl. `preview demo radiance`), `test_bare_setting.lua`; `test_mb_glyph_opacity.lua` message pin updated. Host only.
- Pending: Test7.8-7.10 in game; Test7.4 radiance glow; Test7.6 split vs half pick.
- Next: A tries Test7.10; then the color pass (Earth, Darkness in Compression/Gravitation) with A's images; then the glyph cross ends (native DLL batch).

## TargetSC 0.19.8-0.19.10 unified Test7.8-7.10 — Level 4 rings from the MB ring, L4 MB flicker, bare-setting values (Lua only) (2026-11-21)

**Request (22:43, 23:34):** the L4 rings should grow out from the MB ring, the outer three spreading from the innermost on the same ease (they were spreading apart at full size); Radiance rings overlapped the MB ring; L4 MB ring should flicker like the skillchain bar's L4 border instead of breathing; bare settings should report their current value with the range. A's 11-21 settings attached.

**Before (Verified):** rings went from one radius `c_r` to `1+(j-2.5)x.075`, so the innermost shrank; `into` used `mb_radius` (ignoring `umbra mb size`); with A's profile Radiance's MB ring is .96 x radius, inside the rings' .89-1.11 span. The bar flicker (`resonance_fx.lua`) is `(.37+.63 sin^2 23t)(.72+.28 sin^2 28t)` for L3+, the same as the rings' L4 `electric`. `numeric()` reported only the range.

**Changes:** radius `c_r+(inner-c_r)e+(j-1)spacing e` with `inner = drawn MB/radius + gap` (expand mb) or `1-1.5 spacing` (ground). MB ring alpha `x (1-d+d electric)` on L4 with `mb level4 flicker`. `numeric()` adds `Now <value>` (saved, else default).

**Host verification (not FFXI):** 68/68 CI. **Live pending.**

## Current Development Status — 2026-11-21 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-level4-collapse` (new, stacked). Runtime TargetSC (Lua only; native DLL stays 0.12.0). Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@8624248 (Test7.6)` → `development/targetsc-level4-collapse (Test7.7)`. ~~**NOT PUSHED:** attaching the repo with push access was refused in this session (2026-11-21 21:25), so per B3 the commits are local and delivered as `git format-patch` files.~~ (**2026-11-21 21:57 correction:** A re-authorized push; the patch was re-applied on `8624248` and pushed as `095b38e`, ls-remote verified.)
- installed_base: `76cf0e6` (Test7.3) is the last Live-tagged install; Test7.4-7.6 installs are Unknown, so the package stays cumulative since `76cf0e6`.
- Changes: Test7.7 level 4 collapse. A Radiance/Umbra link after a level 3 turns the level 3 rings (ground and sky) white where they were and collapses them into one ring in .12 s (accelerating), then its four rings expand concentrically out of that ring (ease-out until the window opens). Ground rings only (sky sets off while collapse is on, whatever `radiance sky` / `umbra sky` say). Radiance glow, Umbra ring-height blooms and kill halves follow the ring plane. Version `0.19.7-unified-test7.7`.
- Tunables (defaults): `ring_level4_open` collapse (killala pop), `ring_level4_collapse` into (ground|mb|into), `ring_level4_expand` mb (ground|mb), `ring_level4_collapse_time` .12 (0-.3), `ring_level4_expand_time` -1 (= until the window opens; up to 5), `ring_level4_ease` 6 (1-8). MB ring hidden (`display sc`) = ground for both.
- Checks: lupa runner `lua5.1`; parse of every changed `.lua` OK; 65/65 CI `lua5.1` invocations PASS incl. new `test_level4_collapse.lua` (all six collapse/expand combos on defaults and A's cioara profile, MB-hidden fallback, no-previous, pop, levels 1-3 unchanged, commands/presets, `preview demo` and `preview demo radiance`). Six older level-4 tests now pin `ring_level4_open='pop'` because they check the sky-set opening. Host only.
- Live: none for Test7.4-7.7. Pending: Test7.4 radiance glow; Test7.5 L3 spread; Test7.6 L2 split/half; Test7.7 collapse look.
- Next: A pushes or re-authorizes push, installs Test7.7, tries `preview demo` / `preview demo radiance` with each `rings level4 collapse` and `expand` setting.

## TargetSC 0.19.7 unified Test7.7 — Level 4 collapse (Lua only) (2026-11-21)

**Request (21:09-21:21):** a level 4 starts from a level 3, so on its first frame turn all level 3 rings white where they are and collapse them very quickly into one ring, replace it with the four level 4 rings overlapping as one, then expand them into their concentric arrangement, fast at first and easing gently until their flashes. Ground rings only. Three collapse targets (ground ring height; MB ring height, concentric with it; into the MB ring, its glow showing) and two expand planes (around the MB ring, which sits below the SC rings, or the ground ring height). No extra MB flare.

**Before (Verified):** level 4 drew one white ring for .16 s, then four rings at the same height (radial `1 + (j-2.5) x .075`), gliding from the previous link's heights over .3 s; `s.previous` is cleared at .3 s.

**Changes:** in `M.frame`, `l4c` plan: collapse for `ring_level4_collapse_time` (previous L3 rings from `M.positions(previous, created)` and `specifications(previous)`, white, radius/height lerped by `(age/ct)^2` to the target); then the four rings at radius `c_r + (radial - c_r) x e` and height `c_h + (final - c_h) x e`, `e = 1-(1-u)^ease` over the expand time. MB plane = `mb_height` plus the ground strike/hum. `bottom = l4c.h` after the rings so later ring-relative effects follow. Command `rings level4 ...`, help, README.

**Host verification (not FFXI):** 65/65 CI. **Live pending.**

## Current Development Status — 2026-11-21 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0). Stack: `master@9476226` → `development/targetsc-mb-rise-gradient@fa610f9 (Test7.6)`.
- installed_base: `76cf0e6` (Test7.3) is the last Live-tagged install; whether Test7.5 (`b17bbb2`) was installed is Unknown, so the package is cumulative since `76cf0e6`.
- Live (A, 15:42): the level 3 opening rises from the previous link's heights. Test7.5 spread in game: Pending.
- Changes: Test7.5 (`b17bbb2`, pushed 2026-11-21 20:12) level 3 spread; `8b0b010` docs-only AGENTS shared sync to canon 2026-11-21.3; Test7.6 level 2 spread: `rings level2 open split|half|stacked`, `rings level2 start <0-1>`. Version `0.19.6-unified-test7.6`.
- Tunables (defaults): `ring_level2_open` spread (split), `ring_level2_start` 0 (half = .5; killala = stacked); `ring_level3_open` spread (killala pop), `ring_level3_start` .5. A level 2 after a level 2 stays stacked.
- Checks: `python3 -m pip install --break-system-packages lupa` + runner `lua5.1` (lupa.lua51); parse of 86 `.lua` files, 0 errors; 64/64 CI `lua5.1` invocations PASS incl. new `test_level2_spread.lua` and the preview-path cases (`preview demo`, `preview demo radiance`) in both spread tests. `test_motion.lua` L2 stacking assertion now allows equal heights on frame 1 (split). Mutations (no L2 spread; no L3 spread) fail. Host only.
- Pending: both looks in game.
- Next: A picks split vs half (and level 3 start); then Level 4 collapse.

## TargetSC 0.19.6 unified Test7.6 — Level 2 rings split open (Lua only) (2026-11-21)

**Request (20:12):** push Test7.5; try two level 2 openings: each SC ring a single ring splitting into the pair, and the pair starting at half its normal gap.

**Changes:** with `ring_level2_open == 'spread'` and the previous link not level 2, the pair's `stack` is multiplied by `start + (1-start) x smooth(age/.3)` while `age < .3` (shared with the Test7.5 level 3 code). `rings level2 open split` = start 0 (default), `half` = .5, `stacked` = the earlier look.

**Host verification (not FFXI):** 64/64 CI. New test: split/half gaps on frame 1 (0 / .0175), monotonic to .035 by .3 s and holding, from an opener, a level 1, and no previous link; stacked .035 on frame 1; level 2 after level 2 stays stacked; lowest-strand glide identical to stacked; demo and demo radiance previews split open; commands, bad values rejected, killala = stacked. **Live pending.**

## TargetSC 0.19.5 unified Test7.5 — Level 3 rings spread open (Lua only) (2026-11-21)

Root copy of the TargetSC/TESTING.md entry (added 2026-11-21 with Test7.6; it was only in TargetSC/TESTING.md). `rings level3 open spread|pop` (default spread; killala pop), `rings level3 start <0-1>` (default .5): three strands from the first frame at start x .035, separating over the .3 s glide. Commit `b17bbb2`. Host: 63/63 CI, new `test_level3_spread.lua`. **Live pending.**

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0).
- installed_base: `76cf0e6` (Test7.3).
- Live (A, 18:50): Test7.3 vanish ending + black burst centers "looks good"; **the Umbra animation is settled for now** (A's cioara profile, see `tests/fixture_cioara.lua` plus vanish/burst center black).
- Change: Test7.4, `radiance glow` (+ opacity, size, rise, hold, fall, dance, speed). Off by default and in killala. Version `0.19.4-unified-test7.4`.
- Checks: Lua 5.1 (lupa) parse of every TargetSC `.lua`; 69/69 CI invocations PASS incl. new `test_radiance_glow.lua` (A's profile). Mutation (no height dance) fails it. `preview mb radiance` stays within 16 discs (host only).
- Pending: the glow look in game; Test7.1/7.2 Radiance items.
- Next: A tries `radiance glow on` with `preview Radiance 4` / `preview mb radiance`, then tunes rise/hold/fall/dance.

## TargetSC 0.19.4 unified Test7.4 — Radiance glow (Lua only) (2026-11-20)

**Request (18:50, details 18:54):** two white blooms like the Umbra after-bloom (ring-band shape), both around the ground ring height, dancing around each other. They start clear, slowly ease in, rush to full brightness as the first Radiance SC ring flashes, hold (setting), then ease out and fade quickly; the fade-out is a setting and may linger through the MB window. Motion: cosine growth and up/down, like a figure eight.

**Before (Verified):** Radiance's first ring (index 0 of `level4_ring`) brightens from `sc_open` and peaks at `sc_open + .3 x radiance lead` (with `radiance close sequence`). The Umbra after-bloom uses the `mb bloom center/edge/middle/position` ring band.

**Changes:** `M.radiance_glow_envelope`: peak as above (sc_open without sequence); before it `x^3` over `glow rise` (-1 = from landing); 1 for `glow hold`; then `1-u^3` over `glow fall`; times `smooth((mb_close-now)/.3)`. Frame: two `radiance-glow` discs at the ground ring height, white, MB bloom shape, radius `radius x glow size x (1 + dance cos phi)`, height `+ dance x radius x .08 x sin 2phi`, with `phi = 2pi speed age + k pi/2`.

**Host verification (not FFXI):** 69/69 CI. New test (A's profile): peak = sc_open (open time 3) + .3 x lead; 0 at landing, <.2 halfway, >.6 at 90%, 1 at peak and through the hold, >.9 at 30% of the fall, <.35 at 90%, 0 after; two white discs with the MB bloom shape at the peak opacity; size and height-difference dance exact; a 30 s fall lingers at deadline-1 s and is gone after the deadline; hold 2 and rise .5; none on Umbra; `preview mb radiance` shows them within 16 discs; commands and rejects. **Live pending.**

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0). Test7.1/7.2 pushed at 18:25 (`4a7b067`); A authorized pushes indefinitely for this conversation (18:23).
- installed_base: `4a7b067` (Test7.2; A's settings.xml of 18:23 carries its settings, so Inferred installed).
- Change: Test7.3, `umbra ending vanish` (+ `vanish time`, `vanish shimmer`) and `umbra burst center normal|black`. Defaults unchanged. Version `0.19.3-unified-test7.3`.
- Checks: Lua 5.1 (lupa) parse of every TargetSC `.lua`; 68/68 CI invocations PASS incl. new `test_umbra_vanish.lua` (uses A's cioara profile as `tests/fixture_cioara.lua`). Mutation (MB glyph not vanishing) fails it (host only).
- Live: none for 7.1-7.3 looks yet. A plans to settle the Umbra animation after this batch if it looks right.
- Next: A sets `umbra ending vanish` and `umbra burst center black`, then `preview umbra` / `preview mb`.

## TargetSC 0.19.3 unified Test7.3 — Umbra vanish ending, black burst centers (Lua only) (2026-11-20)

**Request (18:23, confirmed 18:35):** an Umbra ending where the glyph (what would have become the gyro/lines) disappears at the flash with a very fast black shimmer and nothing replaces it, with no flash of the black disc; in that ending the MB glyph (which shrinks and brightens at the end) is gone too; and the centers of MB blooms during Umbra black and opaque.

**Before (Verified, host sim with A's 18:23 settings):** with `umbra ending gyro` + `when flash`, the disc glyph lines were replaced at the flash-out (about link+4.05 s with `umbra open time 2`) by an upright spinning glyph3; the MB glyph stayed on the disc plane and brightened to about 253 alpha while collapsing. Bloom discs carry `hub` (the strike color mixed toward white by `mb bloom core`); native center alpha = hub alpha x `inner`.

**Changes:** `M.umbra_vanish` gives visibility `(1-u)(.35+.65 x shimmer)` and blackness `smooth(3u)` over `vanish time` from `M.umbra_ending_window`'s start, then 0. The disc glyph (`property-trace`) and the Umbra MB glyph multiply their alpha by it and mix their stroke/color to black, hidden after. `umbra_ending_glyph` returns nothing for vanish, so no glyph3. Umbra burst blooms with `burst center black`: `hub = black at env x closing`, `inner = 1`.

**Host verification (not FFXI):** 68/68 CI. New test (A's profile + vanish): the ending start equals the flash-out in the frame's view (`umbra open time`); both glyphs visible just before; the trace shimmers (min < max) and is near-black at 70%; after: no trace, no MB glyph, no glyph3 at +0.13 s, +1 s, deadline-1 s, deadline-0.1 s; the black disc's color is identical to the gyro profile around the flash; copies and the under disc stay; gyro still makes its glyph3. Bursts: on Umbra the hub is black, inner 1, at least the bloom's alpha, 250+ at peak outside the ending; non-Umbra and default unchanged. Commands and rejects. **Live pending.**

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0). Remote tip `6235b58` (Test7.0); Test7.1 `7b1260a` and Test7.2 are local until A OKs the push.
- installed_base: `7b1260a` (Test7.1 zip, 15:40; A is testing it).
- Live (A, 15:43): `umbra copies steady on` keeps the speed but the copies still stop at the flash-out (A wanted them through the whole animation); the haze glow does not look right yet (A drew it over the black disc, `haze order over`); A is trying `umbra after bloom`.
- Change: Test7.2, `umbra under ending fade|shrink` (default fade: full size, alpha x the collapse factor) and `umbra copies until flash|end` (default flash). Version `0.19.2-unified-test7.2`. The default under ending changes the Test7.0/7.1 look when `umbra under` is on (A's request).
- Checks: Lua 5.1 (lupa) parse of every TargetSC `.lua`; 67/67 CI invocations PASS incl. new `test_umbra_72.lua` (Test7.0 test now checks shrink explicitly). Previews with A's settings + copies until end: at most 9 discs (host only).
- Pending: A's haze description (message cut off); Test7.1/7.2 looks in game.

## TargetSC 0.19.2 unified Test7.2 — Umbra under disc fades, copies until the end (Lua only) (2026-11-20)

**Request (15:43):** copies steady should keep the copies running through the whole animation; the under disc should fade out at the same size instead of shrinking, all else the same.

**Before (Verified):** copies spawn only while `born < M.umbra_flashed(...)`; the collapse multiplies every ring, disc and glyph3 radius by `M.umbra_collapse` (1 - u^curve over the collapse time).

**Changes:** copies stop at `s.mb_close` with `umbra copies until end`; in the collapse loop, an `umbra-under` disc with `umbra under ending fade` keeps its radius and has the alpha of `colors[]` and `color` multiplied by the same factor.

**Host verification (not FFXI):** 67/67 CI. New test: fade keeps the radius while the black disc shrinks, alpha = early alpha x the collapse factor, `color` in step, nearly gone at the deadline; shrink = old radius x factor with unchanged alpha; flash: no copies after the flash-out + life; end: copies after it and near the deadline, same count before it; commands. **Live pending.**

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0).
- installed_base: `6235b58` (Test7.0; Live, A 14:55: "Test7 loaded without issues"). A's local sink/stand edit to `resonance_motion.lua` is overwritten with A's OK (15:08).
- Live (A, 14:55): Test6.8 `umbra sky off` / `radiance sky off` look good on both. Test6.9 `radiance glyph circle off` / `wobble always` work; A is undecided on the look and is leaving them on for now.
- Change: Test7.1, `preview demo radiance` / `preview mb radiance`; `radiance ending ride` and `radiance ending glyph <curve>` / `ending peak`; `umbra haze style glow` / `haze black` / `haze lift` / `haze order`; `umbra disc jitter` / `jitter speed`; `umbra under steady`, `umbra copies steady`. Defaults and killala unchanged. Version `0.19.1-unified-test7.1`.
- Checks: Lua 5.1 (lupa) parse of every TargetSC `.lua`; 66/66 CI invocations PASS incl. new `test_level4_71.lua`. Previews `demo`, `mb`, `umbra`, `demo radiance` and `mb radiance` with A's cioara settings plus every new option on: at most 9 of the 16 disc slots and 1 glyph3 (host only). Mutation (no ride) fails the test.
- Correction: on 2026-11-20 (15:00 reply) the `umbra after bloom` was described to A as white. The sim shows it black (a faint dark puff, 2.3 radius, ring height, link+2.2 s, 1 s fade), mostly hidden by the black disc.
- Pending: every Test7.1 look in game; Test7.0 under/haze looks; earlier items.
- Next: A tries `preview demo radiance`, `preview mb radiance`, `radiance ending ride on` + `ending glyph quadratic`, `umbra haze style glow`.

## TargetSC 0.19.1 unified Test7.1 — Radiance demo and ending, Umbra haze glow, jitter, steady spin (Lua only) (2026-11-20)

**Request (14:55, 15:08):** a Radiance preview demo (a four-link real chain from an opener, plus a variant with bursts at overlapping times); Radiance property discs lower with the MB ring in the ending and fade only in the final fade, while the floor glyph brightens in proportion to the descent (curve choice); haze as black center to white at the disc's set middle point to clear edge (two discs, since one disc has one color set); a sinusoidal jitter of the Umbra disc middle point; haze height and order controls; steady spin for the under disc and glyph copies.

**Before (Verified, host sim with A's settings):** Radiance discs stayed at .198 while the MB ring descended to .060, fading over the 2 s ending; the floor glyph rose only from about 89 to 128 alpha (capped by `radiance glyph opacity .5`). The under disc and copies turned at `disc_rotation`, which slows to `disc minimum` after the window opens. Native disc = one angular color set and a radial alpha profile with center, one middle stop and edge (`struct Disc`).

**Changes:** `M.radiance_sequence` (weapon ids 32/33/35/42/60; properties from skills.lua, links from sc_runtime `sc_info`); kinds `radiancedemo`/`radiancemb` reuse the Umbra demo builder and burst times. Ride: Radiance disc `life` = 1 while `mb_active`, else `response.extinguish`; `base += ring_at(p) - mb_height` during the ending. Ending glyph: after the glyph-opacity scaling, `opacity += (peak x extinguish - opacity) x curve(descent fraction)`. Haze glow: white disc R = max(haze R, 1.02 p) (inner 0, mid 1 at p/R, outer = haze edge) then black disc radius p (inner = haze black, outer 0), with p = black disc radius x its middle position (jittered); lift adds to the height; order under moves the haze discs to just before the black disc. `M.umbra_disc_position` adds `jitter x sin(2pi speed age)`, clamped .02-.98. `M.steady_rotation` = `2pi disc_speed x disc_speed_level<n> x age`.

**Host verification (not FFXI):** 66/66 CI invocations PASS. New test: the demo names, properties checked against skills.lua, links Liquefaction/Fusion/Light/Radiance, L4; same clocks and event count as the Umbra demo; bursts Fire@12.6, Light@23.8, Lightning@29.8, Light@38.8; old preview names unchanged; both play to the end. Ride: unchanged before the ending, offset delta equals the ring's at -1.4/-0.8/-0.2 s, no fade before the deadline, fades after. Glyph curves: off unchanged, each curve reaches 250+ at the deadline, equals off before the descent, linear > quadratic > exponential mid-way, peak scales, fades after. Haze glow: two discs, white then black, black radius = disc radius x .93, white peak there, at the MB ring; lift; order under/over; soft still one disc. Jitter: still at 0, +-.05 sinusoid, haze follows. Steady: equal before the slowdown, keeps the opening rate late; default slows; copies too. Commands and rejects; killala. **Live pending.**

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0).
- installed_base: `cd390bf` (Test6.9 zip delivered 05:30 over `f3800fe`; Inferred that A installed it, not live-confirmed).
- Change: Test7.0, `//tsc umbra under ...` (Gravitation<->Distortion disc turning just under the black disc, opaque center, clear edge; spin, direction, size, cycle, opacity, depth, center/edge) and `//tsc umbra haze ...` (flickering white bloom at the MB ring height all MB window; opacity, size, flicker, speed, center/edge). Both off by default and in killala. Version `0.19.0-unified-test7.0`.
- Checks: Lua 5.1 (lupa) parse of every TargetSC `.lua`; 65/65 CI invocations PASS incl. new `test_umbra_under_haze.lua`; previews `preview umbra`, `preview Umbra 4` and `preview kill mb Ice`, 0-40 s: at most 9 of the 16 native disc slots, same burst-bloom frames with both on (host only). Mutation (no haze flicker) fails the test.
- Live: none for Test6.8-7.0. Pending: the Test6.8 one-set look, the Test6.9 glyph look, the Test7.0 under disc and haze looks; earlier items unchanged.
- Next: A tries `umbra under on` and `umbra haze on` with `preview umbra`.

## TargetSC 0.19.0 unified Test7.0 — Umbra under disc and haze (Lua only) (2026-11-20)

**Request (05:55):** (1) an option for a second rotating property disc just below Umbra's black disc, matching Radiance's stacked middle disc: opaque center, transparent edge, fading between Gravitation and Distortion, with spin speed, direction and size; (2) an option for a flickering persistent white "smoke" bloom at the MB ring's level, with flicker, size and opacity settings.

**Before (Verified):** Radiance's middle disc (`radiance_stack`) crossfades Fusion and Fragmentation on a cosine cycle, turning at `disc_rotation x middle spin`. Umbra had no stack. The MB ring height is `mb_height` (the black disc's plane with `umbra mb height disc`); the collapse scales every disc at the end of the frame.

**Changes:** `umbra-under` disc drawn just before the black disc (so the black disc covers the overlap) at `h - under depth`, radius `black x under size`, turn `black turn x under spin x (-1 if reverse)`, colors from the Gravitation/Distortion palettes mixed by `.5-.5cos(2pi age/cycle)`, `inner/outer = under center/edge`, alpha `under opacity x life`. `umbra-haze` disc at the MB ring height (`ring_at` during the ending), radius `mb_radius x umbra mb size x haze size`, white, `inner/outer = haze center/edge`, alpha `haze opacity x smooth(age/.3) x flicker(now, haze flicker, 23 x speed, 28 x speed)` while `mb_active` (x the mb-ending fade when the collapse is off). The gather kill puts the haze on the MB ring like the MB glyph. Commands/help/README; version.

**Host verification (not FFXI):** 65/65 CI invocations PASS. New test: off by default; under disc ordered before the black disc, .01 below, same size and turn at defaults, center 1/edge 0, Gravitation at whole cycles and Distortion halfway, blended between; spin 2 reverse, size, depth, center/edge, opacity; Umbra only; collapses. Haze at the MB ring's height and x1.3 its radius, white, present .5 s to the deadline, flickers, at most its opacity, gone after; flicker 0 steady at opacity; size; follows mb height disc; fades without the collapse; both together under 16 discs. Commands and range rejects; killala off. **Live pending:** both looks in previews and a real chain.

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0).
- installed_base: `bdca0c1` (Test6.8, delivered 05:20; Inferred that A installed it, not live-confirmed yet).
- Change: Test6.9, `//tsc radiance glyph circle on|off` (off = the floor MB glyph drawn as a flat native 3D glyph with no circle) and `//tsc radiance glyph wobble rings|always` (always = keeps moving through the MB window and exit fade). Defaults and killala unchanged. Version `0.18.7-unified-test6.9`.
- Checks: Lua 5.1 (lupa) parse of every TargetSC `.lua`; 64/64 CI invocations PASS incl. new `test_radiance_glyph.lua` (runs through `preview Radiance 4` and `preview kill mb`); two mutations each fail it (host only).
- Live: none for Test6.8 or Test6.9. Pending: Test6.8 one-set look; Test6.9 glyph look; earlier items (link disc and converge in battle, Test6.3 kill items, vertical seam, merge to master).
- Next: A tries `radiance glyph circle off` and `radiance glyph wobble always` with `preview Radiance 4`.

## TargetSC 0.18.7 unified Test6.9 — Radiance floor glyph: no circle, steady wobble (Lua only) (2026-11-20)

**Request (05:20):** an option for Radiance's stationary MB glyph near the ground to have no circle around it, and an option for it to keep wobbling after the sky rings disappear, for the whole MB window and exit fade.

**Before (Verified):** the floor glyph is a 2D disc with glyph style 2, and native 0.12.0 always draws a 1-px rim ring with those strokes (`src/TargetSC.cpp`, `if(!disc.glyph...)` then `emit_ring`). Its wobble is `details.ground_wave` (with `radiance glyph buzz on`). On a closing link the hum speed eases to zero over `fade duration` after sc_open (`energy_time`), so the wave froze, in the Radiance preview at .0070 from about 4 s to the deadline.

**Changes:** `radiance_glyph_circle=false` (with native >= 11) sends the glyph as a `glyphs3` entry: same radius, offset, rotation and argb, all motion params 0 (flat), `circle=false`, role `mb-glyph`, no disc. Gather kill moves a 3D `mb-glyph` onto the MB ring like the disc. `M.steady_wobble` = vibration's strike plus its hum amplitude on plain time (equal to ground_wave before sc_open); `radiance_glyph_wobble='always'` uses it instead of ground_wave (buzz not needed). Help/README; version.

**Host verification (not FFXI):** 64/64 CI invocations PASS. New `test_radiance_glyph.lua`: default draws the disc; circle off gives the 3D glyph with radius, offset, rotation and color identical to the disc at 1/2.5/5/7/9.25 s, one fewer disc, nothing else changed; native 10 falls back; Umbra untouched; rings mode still 4.5-7.5 s; always moves 4.5-7.5 and 8.3-9.9 s and through a converge exit fade, identical before sc_open, continuous across it; works with circle off; buzz off still; gather kill puts the 3D glyph on the MB ring; commands; killala. Mutations (no gather fix; ground_wave for always) each fail. **Live pending:** the look in previews and a real chain.

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0).
- installed_base: `f3800fe` (Test6.7 zip over `a650e43`, per the 2026-11-20c handoff; Inferred, not re-diffed against A's folder).
- Change: Test6.8, `//tsc umbra sky same|bell|off` and new `//tsc radiance sky bell|off`: off draws only the ground SC rings for that level-4 link; the previous link's sky rings drop onto the ground over the .3 s hand-off; close sequences and blooms run as one set. Defaults and killala unchanged. Version `0.18.6-unified-test6.8`.
- Correction: `test_integrated_loader.lua` still pinned `0.18.4-unified-test6.6.2`, so it failed at the Test6.7 head (Verified by running it on the unmodified tree); the Test6.7 "56/56 PASS" was wrong for that test. Pin updated.
- Checks: Lua 5.1 (lupa) parse of every TargetSC `.lua`; 63/63 CI invocations PASS incl. new `test_level4_sky.lua`; preview path: `preview umbra`, `preview Radiance 4`, `preview Umbra 4` run 0-40 s with both off, no level-4 frame has sky rings after the hand-off (host only).
- Live: none. Pending: the one-set look in previews and a real chain; earlier pending items unchanged (link disc in battle, converge in battle, Test6.3 kill items, vertical seam, merge to master).
- Next: A tries `umbra sky off` / `radiance sky off` with `preview umbra` and `preview Radiance 4`.

## TargetSC 0.18.6 unified Test6.8 — Umbra and Radiance without sky rings (Lua only) (2026-11-20)

**Request (05:08):** an option to hide the sky SC rings in the Umbra and Radiance animations, since a level-4 link has no window to close.

**Before (Verified):** every link draws a ground set and a sky set (`M.positions` returns `bottom,top`); Umbra's sky could be `same` or `bell`, Radiance's always used the bell. The close sequences, `umbra_flashed`, `level4_end` and the umbra endings already supported a single set through `has_top` (used for openers before they pair).

**Changes:** in `M.frame`, for a level-4 link with `<name>_sky=off`, `top` becomes nil (one set), except during the .3 s hand-off from a previous link, where the sky rings are drawn moving from the interpolated top down onto the ground (bell factor returns to 1 as they meet) while `has_top` is already false. Every `top~=nil` passed to the level-4 helpers now passes `has_top`. New default `radiance_sky='bell'`, killala `radiance_sky='bell'`; `umbra sky` accepts `off`; help/README; version.

**Host verification (not FFXI):** 63/63 CI invocations PASS. New `test_level4_sky.lua`: defaults draw both sets; off removes sky rings for Umbra and Radiance at .5/1/2.5 s with ground count, height and size unchanged; each setting only touches its own chain; Light keeps its sky; Umbra single set flashes out sooner with one bloom (two by default); hand-off: sky above ground at .15, lower at .25, never smaller than ground, gone at .35; commands set/reject; killala keeps both. Mutation (no hand-off drop) fails the test. Preview path as in the status block. **Live pending:** the look in previews and a real chain.

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0).
- installed_base: `a650e43` (Test6.6.2, per the 2026-11-20b handoff; Inferred, not re-diffed against A's folder).
- Change: Test6.7, the white awakening disc now plays on every link that opens a new window (opener curve against the link's own wait; closing links none; .3 s hand-off); `//tsc awakening links on|off` (default on, killala off); version `0.18.5-unified-test6.7`.
- Checks: Lua 5.1 parse on changed files; 56/56 CI invocations PASS incl. new `test_awakening_links.lua`; preview path: `preview mb demo` plays it at 0, 9, 17, 24 s (host only).
- Live: ~~none for Test6.7. Pending: the link disc look;~~ (02:42: A, all preview tests pass, "very subtle but I like it".) Pending: link disc in a real battle; converge in battle; Test6.3 kill items; vertical seam; merge to master.
- Next: A tries `preview mb demo` and a real chain.

## TargetSC 0.18.5 unified Test6.7 — awakening disc on every new window (Lua only) (2026-11-20)

**Request (02:30):** the small white awakening disc that expands and quickly fades when an opening weapon skill lands (center opaque, transparent edge) should play on every newly opened skillchain.

**Before (Verified):** only the opener drew it (`opening.opener_seen`); at a link the opener's disc finished over .3 s and the pooled glyph became the MB glyph, so links never had one (`test_mb_glyph` asserted no replay).

**Changes:** the opener's timing moved into `M.awakening_level(created,open,close,now,opts)` (same numbers). For `step>1`, unless the link closes the chain, a separate `awakening` disc is drawn from the link's `created`/`sc_open`/`sc_close`: grows (cubic ease-out) over the first third of the wait to `radius*.96*awakening size`, fades per `awakening fade until`, radial `awakening fade` inner/outer, opacity `awakening opacity × opacity`. Tracked on the pooled glyph (`opening.link`); when the next link lands the previous one finishes over .3 s (`link_prev`). Role `awakening`, so kills treat it like the opener's. `awakening links on|off` (default on; killala off). Help/README; version `0.18.5-unified-test6.7`. `test_mb_glyph` and `test_awakening_until` now check their old no-replay assertions with links off.

**Host verification (not FFXI):** 56/56 CI invocations PASS; new `test_awakening_links.lua`: opener unchanged, link disc grows/full/fades/gone at two-thirds, opener size, size/until apply, closing link none, hand-off, off/killala/awakening off, commands. Preview path: `preview mb demo` plays it at 0, 9, 17, 24 s; `preview Fusion 2` at 0. ~~**Live pending:** the link disc look in previews and a real chain.~~ **Live (A, 2026-11-20 02:42):** all Test6.7 preview tests pass; "very subtle but I like it". Still pending: a real chain in battle.

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0).
- installed_base: `e9c2e83` (Test6.6.1; A tested it 02:15).
- Change: Test6.6.2, `mb ending blooms linger` fades blooms over `mb ending fade` after the deadline (any style); version `0.18.4-unified-test6.6.2`.
- Checks: 54/54 CI invocations PASS (host only).
- Live (A, 02:15): Test6.6.1 fades look great in previews incl. `preview mb light`; A uses `mb ending fade 0.8`, `mb ending shrink 0.3`. (02:26: Test6.6.2 confirmed, looks good.) Pending: converge in battle; Test6.3 kill items; vertical seam; merge to master.
- Next: A plays with converge in battle.

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0).
- installed_base: `bf2ee4a` (Test6.6, A's status showed test6.6 at 02:00; Verified by A's report).
- Change: Test6.6.1, previews run until the converge fade (and lingering blooms) finish instead of stopping .05 s after the MB deadline; version `0.18.4-unified-test6.6.1`.
- Checks: 54/54 CI invocations PASS (host only).
- Live (A, 02:00): Test6.6 fade did not show in `preview burst` / `preview mb light` (fixed here); `mb ending 3` works, prefers 2. Pending: the fade, linger, shrink decision; Test6.3 kill items; vertical seam.
- Next: A retries the fade in previews and in a real fight.

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0).
- installed_base: `40176af` (Test6.5 zip over `ec26042`, A loaded it 01:47; Inferred from A's report).
- Change: TargetSC unified Test6.6: converge fades out over `mb ending fade` (.4 s) after the MB deadline; ring-plane blooms ride the ring during converge; `mb ending blooms fade|linger`; `mb ending` up to 3 s; version `0.18.4-unified-test6.6`.
- Checks: Lua 5.1 parse; 54/54 CI test invocations PASS (host only).
- Live (A, 01:47): Test6.5 converge works as intended (details in the Test6.6 entry). Pending: Test6.6 look; shrink decision; Test6.3 kill look and real-packet detection; vertical-glyph seam decision.
- Next: A tries Test6.6.

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0).
- installed_base: `ec26042` (Test6.4, per the 2026-11-20 handoff; Inferred, not re-diffed against A's folder).
- Change: TargetSC unified Test6.5, `//tsc mb ending style converge` + `//tsc mb ending shrink <0-1>`; version `0.18.3-unified-test6.5` (details in the Test6.5 entry below and in `TargetSC/TESTING.md`).
- Checks: Lua 5.1 parse; 54/54 CI test invocations PASS incl. new `test_mb_converge.lua`; packaging script PASS (host only).
- Live: ~~none for Test6.5. Pending: the converge look;~~ (2026-11-20 01:47: Test6.5 confirmed live, see the Test6.6 entry.) Pending: Test6.3 kill look and real-packet detection; vertical-glyph seam decision.
- Next: A tries converge (and shrink) in game.

## Current Development Status — 2026-11-20 (America/Chicago)

- Repo/branch: `rerorriM-Mirrorer/Skillchains` `development/targetsc-mb-rise-gradient`. Runtime TargetSC (Lua only; native DLL stays 0.12.0).
- installed_base: A's local `resonance_motion.lua`/`resonance_controls.lua` = `45246e6` (Test6.3) + A's own trial edits (Verified by diff); rest of the install Inferred `45246e6`.
- Change: TargetSC unified Test6.4, `//tsc mb glyph opacity <0-1>` (details in the Test6.4 entry below and in `TargetSC/TESTING.md`).
- Checks: Lua 5.1 parse of all TargetSC Lua; 53/53 CI test invocations PASS incl. new `test_mb_glyph_opacity.lua` (host only).
- Live: ~~none for Test6.4. Pending: Test6.4 look;~~ (2026-11-20 01:07: Test6.4 confirmed live, below.) Pending: Test6.3 kill look and real-packet detection; vertical-glyph seam decision.
- Live (A, 2026-11-20 01:07): Test6.4 loaded without errors; opacity 1 same as before; 0.5 and 0 "work great"; window flash still shows at 0; closing flashes full strength; 2 and x refused, old value kept; Umbra MB floor glyph works the same. "It looks great!"
- GitHub CI: `ec26042` failed only in packaging (`tools/package_targetsc_unified.py` still required the removed `TargetSC/WORKFLOW.md`/`AGENTS.md`); fixed in `ff2f7fa`, CI success (Verified). Lua tests were not affected.
- Next: new batch in a new conversation; merge to master when A is ready.

## Current Development Status — 2026-11-20 (America/Chicago)

- Docs-only: removed the stale `TargetSC/AGENTS.md` and `TargetSC/WORKFLOW.md` (pre-canon copies; the TargetSC AGENTS still told agents to zip WORKFLOW/TESTING, which canon 2026-11-20.1 forbids). Root copies are canonical. `TargetSC/TESTING.md` kept as history. `tools/package_targetsc.py` no longer expects `TargetSC/WORKFLOW.md` (it would have failed CI otherwise). No runtime change, no FFXI test.
- Docs sync to canon 2026-11-20.1 (`agents_shared_version` and `workflow_version`); project-specific lines moved to the AGENTS REPO block: none; no runtime change, no FFXI test.

---

# TESTING.md — Skillchains Resonance UI

## TargetSC 0.18.4 unified Test6.6.2 — lingering blooms fade over `mb ending fade` (Lua only) (2026-11-20)

**User feedback (02:15):** "The fades look great!" (Test6.6.1 in previews, incl. `preview mb light`). Settling on `mb ending fade 0.8` to match the SC rings' end fade; keeping `mb ending shrink 0.3` to try in battle. Request: lingering MB blooms should last only as long as, and fade out with, the MB ending fade. Author: A.

**Answer (Verified):** with converge, `mb ending blooms fade` already drew blooms past the deadline and faded them with the ring and glyph over `mb ending fade`; only `linger` let them run their full own life (≈1 s).

**Changes:** `linger` now: blooms keep drawing past the deadline (no pre-deadline cut) and fade out over `mb ending fade` (closing = 1 − smooth((now − mb_close)/fade)), any ending style; with converge it equals `fade`, with soft/hard it replaces their .25 s pre-deadline cut. Expired-phase keep-alive and the preview tail use mb ending fade for linger. Defaults unchanged (`mb ending fade` .4; A's saved .8 stays). Help/README; version `0.18.4-unified-test6.6.2`.

**Host verification (not FFXI):** 54/54 CI invocations PASS; `test_mb_converge.lua`: converge linger = fade frame for frame, out after the fade, follows fade .8; soft linger fades after the deadline and is out at +.4; preview tail = fade + .05. The old full-life linger fails the new checks. ~~**Live pending:** linger with soft/hard; converge 0.8 + shrink 0.3 in battle.~~ **Live (A, 2026-11-20 02:26):** Test6.6.2 "looks good", "I love ittttt". Still pending: linger with soft/hard; converge in battle.

## TargetSC 0.18.4 unified Test6.6.1 — previews play the converge fade (Lua only) (2026-11-20)

**User report (02:00):** no reload errors; `//tsc status` showed 0.18.4 unified test6.6; with `mb ending fade 1` and `0.3` the animation still cut out instead of fading in `//tsc preview burst` and `//tsc preview mb light`. `mb ending 3` worked (prefers 2). Shrink decision waits for a working fade. Author: A.

**Cause (Verified):** every preview ends itself .05 s after its last MB deadline (`resonance_preview.lua`, `self.ends`) and is then dropped at once, so Test6.6's post-deadline fade (drawn by the model up to mb_close + fade) was never reached in previews. ~~Test6.6 host check covered the model, not the preview path.~~ (2026-11-20: the Test6.6 tests drove the model directly; the preview runner was not tested.) Live combat goes through the model and was not checked by A (Inferred to fade).

**Changes:** `resonance_preview.lua`: `M.mb_tail(opts,resonance)` = .05, or converge fade + .05, or a lingering bloom's life + .05 (largest); read live each frame so a setting changed mid-preview applies. Each preview remembers its MB deadline (`mb_end`: the window, the four-link demos' last link, `mb light`/`mb dark`'s final link; kill previews keep their fixed end) and finishes at max(old end, mb_end + tail). Version `0.18.4-unified-test6.6.1`.

**Host verification (not FFXI):** 54/54 CI invocations PASS; `test_mb_converge.lua` section 9 runs the real `preview burst` and `preview mb light` with converge: the MB ring is still drawn between the deadline and +.35 s, and the preview ends .4-.6 s after the deadline; with soft both end ≤.065 s after it as before; tail values for fade/linger. Without the fix, section 9 fails. **Live pending:** the fade in previews and in combat.

## TargetSC 0.18.4 unified Test6.6 — converge fade after the deadline, blooms ride the ring (Lua only) (2026-11-20)

**User feedback on Test6.5 (01:47):** loaded without errors; converge worked; rings meet; everything disappeared as the MB window closed; risen glyph slides onto the ring with no jump and rides to the floor without fading; glyph rises only to the ring and stays; bloom opened at ring height and stayed; mb ending 1 / 2 worked; shrink works (still deciding); Radiance and Umbra endings fine; soft unchanged. **Requests:** extend the extinguish just past the deadline with a clean .3-.5 s fade; blooms should follow the ring's (capped) height during the ending while keeping `mb bloom from ring` (`from glyph` almost worked but drops with the glyph during normal bursts); allow mb ending up to 3 s; maybe let blooms linger and fade naturally. Asked how long the old fades were and whether the SC ending fades inside or after its window. Author: A.

**Answers (Verified by reading `40176af`):** SC rings meet exactly at the SC deadline (`descent_remaining` reaches 0 at sc_close; geometry frozen there) and then fade over `fade_duration` (.8 s) after it, i.e. already the requested order. The old MB endings fade before the deadline: soft's last pulse falls to dark over its last sixth (≈.33 s at a 2 s ending), blooms go out over the last .25 s, property discs fade across the whole ending; nothing remains after the deadline. Test6.5 converge cut ring and glyph at peak exactly at the deadline.

**Changes:** `resonance_burst.lua`: for converge, `mb_close ≤ now < mb_close + mb ending fade` returns `ending`, progress 1, `converge` 1 and `extinguish = 1 − smooth(t/fade)`. `resonance.lua`: the model keeps the state through `mb_close + mb ending fade` for converge (the engine's own expire fires 1 s after the deadline, Verified in `sc_runtime.lua`). `resonance_motion.lua`: the expired-phase early return and the MB ring gate let the extinguish through; converge ring and glyph × extinguish; converge blooms: no .25 s pre-deadline cut, out with the extinguish; ring-plane blooms use the live `ring_at(progress now)` (mb height before the ending, the floor after it) instead of Test6.5's height at burst time; `mb ending blooms linger` (any style) sets the closing multiplier to 1 and keeps the frame alive while a bloom lives. Defaults `mb_ending_fade=.4`, `mb_ending_blooms='fade'`; commands `mb ending fade`, `mb ending blooms`; `mb ending` range .15-3; help/README; version `0.18.4-unified-test6.6`.

**Host verification (not FFXI):** 54/54 CI test invocations PASS; `test_mb_converge.lua` updated: discs out at the deadline, ring and glyph at peak at it and fading together on the floor over .4 s, gone at 112.41; fade 0 = out at the deadline; an older bloom has no jump at the ending start and then rides the ring; a mid-ending bloom tracks the ring every frame; blooms fade vs linger (linger outlives the fade on the floor, ends with its life); soft linger; mb ending 3; new commands. Mutations (ring gate without extinguish; linger ignored) each fail. **Live pending:** the post-deadline fade, blooms riding the ring, linger, 3 s ending.

## TargetSC 0.18.3 unified Test6.5 — `mb ending style converge` (Lua only; DLL stays 0.12.0) (2026-11-20)

**User request (01:17):** new MB ending `//tsc mb ending style converge` on the existing `mb ending` duration and the real MB deadline: the MB ring descends onto the ground MB glyph, brightening steadily toward white (no repeated flashes, stays visible), brightest on arrival; the ground glyph goes from its default transparency to peak opacity (and white) on the same normalized progress, not reduced by `mb glyph opacity`; while converging, a burst's rising glyph is capped at the descending ring (no jump when the ending starts or ends) and, once it reaches the ring, held there instead of fading/falling; burst blooms originate at the ring's current height and stay/fade there with their usual growth/color/size/timing; everything (ring, glyph and response, property discs, blooms) out at the real deadline; one shared progress value through the burst/response data. Shrink toward the property glyph size optional. Author: A.

**Trace (Verified, `4c98bfa`):** `disc_height` = floor plane of the large glyph and property disc; `mb_height` = steady MB ring height (clapper: property top + (ground anchor − property top) × `mb position`; Umbra `mb height disc` = the black disc plane); `opening.offset` = live large-glyph height, rising on a burst to `rest + (mb_height − rest) × mb glyph height` (1.1); bloom `from/to`: `ring` = fixed `mb_height`, `glyph` = live `opening.offset`, `disc` = floor + .01. The soft/hard ending already descended the ring by `smooth(progress) × mb ending drop` with its own progress calculation in the ring code; blooms stayed at `mb_height`; a held/risen glyph went dark at the ending (end_flash overrode its opacity).

**Changes:** `resonance_burst.lua`: `Burst.ending_progress(state,t,option)` (0 at ending start, 1 at the deadline) is the one progress; `sample()` exposes `ending_progress` and, for converge, `converge = smooth(progress)` (= `end_flash`); converge keeps the breathing idle's own fade (no override). `resonance_motion.lua`: `ring_at(progress)` = the existing descent formula, now the single source for the ring (all styles, unchanged result), the converge cap and converge blooms. Converge ring: `color → white`, `alpha + (1 − alpha) × converge × mb effects` (never dimmed). Glyph: `mb glyph rest hidden` stays hidden into converge (emerges from transparent), then `opacity + (1 − opacity) × converge`, color → white; applied after the Test6.4 multiplier, so `mb glyph opacity` does not reduce it; peak = `mb overall` like every MB signal. Cap = ring height + the glyph's normal overshoot above the ring × (1 − smooth(4 × progress)), i.e. it starts at the glyph's normal top (no jump) and is the ring height from a quarter of the way in; a glyph at the cap is held there (per glyph, per MB window, keeps its brightest response opacity) and rides the ring down. Ring-plane blooms (and their line copies) use `ring_at(progress at the burst time)` (= `mb_height` for bursts before the ending, so no bloom jumps); `glyph` blooms follow the capped glyph. Blooms still go out over the last .25 s before the deadline (existing `closing`). `mb ending shrink <0-1>` (default 0, converge only): ring and glyph radius → property radius × `disc size lines` by `shrink × converge`. Commands `mb ending style …|converge|…`, `mb ending shrink`; help lines; README; version `0.18.3-unified-test6.5` (loader test, CI zip name).

**Host verification (not FFXI):** Lua 5.1 (lupa) parse; 54/54 CI test invocations PASS incl. new `TargetSC/tests/test_mb_converge.lua` (added to CI): shared progress values; no burst: ring only descends, never below alpha 40, ends white at `mb overall` on the glyph plane, glyph opacity never drops and reaches peak, all gone at 112.00; `mb ending 1` starts at 111; a glyph risen before the ending moves continuously (<.006/10 ms), sits on the ring from 110.5, keeps its brightness, lands on the floor; an older bloom doesn't jump; a burst at 110.8 is capped at the ring, held once reached, its bloom born at the ring height (.152) and stays there; `mb glyph opacity 0` doesn't change the converge glyph; shrink 0 unchanged, 1 reaches the property size, no step; soft ring descent and bloom height unchanged; commands/usage/preset. Mutation runs (no hold / blooms on the fixed plane / no glyph emergence) each fail the test. `tools/package_targetsc_unified.py` PASS. **Live pending:** everything in game.

## TargetSC unified Test6.4 — `mb glyph opacity` (Lua only; version string still 0.18.2-unified-test6.3) (2026-11-20)

**User request (00:24):** add `//tsc mb glyph opacity <0-1>`: 0 hides the confirmed MB response glyph, .5 halves it, 1 unchanged; only that glyph incl. its fade/release; not the MB ring, property discs, idle breathing glyph or other primitives; timing unchanged; Radiance's per-glyph opacity intact; limited to `resonance_motion.lua` and `resonance_controls.lua`. User chose the plain multiply (accepts a blink of a visible resting breath glyph, keeps `mb glyph rest hidden`), no scaling of the burst glow (shimmer), and accepts that a kill landing mid-response inherits the scaled glyph. Author: A.

**Changes:** default `mb_glyph_opacity=1`. In `M.frame` the multiplier is applied at the end of the `if response.responding then` block (clapper and classic), not in the later `role=='mb-glyph'` block as first proposed: there it would also have dimmed the window-opening intro flash and the closing (ending) flash whenever a burst overlapped them (Verified by a mutation run: the new test fails with that placement). Applied once per frame; the Test5.4 Radiance/Umbra `glyph opacity` vs `mb overall` logic is unchanged. Command: `opacity={0,1}` added to the existing `mb glyph` ranges (existing `numeric()` validation) and to its usage message; `TargetSC/README.md` line. A's local `resonance_motion.lua` edit was missing a comma after `mb_glyph_opacity=1` (defaults table failed to parse, Verified); superseded by this commit.

**Host verification (not FFXI):** Lua 5.1 (lupa runtime; no system lua5.1 here) parse of every `TargetSC/*.lua` and `TargetSC/tests/*.lua`; all 53 CI test invocations PASS incl. the Skillchains regression against its baseline. New `TargetSC/tests/test_mb_glyph_opacity.lua` (added to CI): default = 1 exact; .5 halves the glyph alpha (±1/255) through strike and fade, same offset/radius/rotation; 0 removes it; every other ring/disc/trace/glow/bloom identical across 1/.5/0; fall and classic scaled; no-burst frames (rest, intro, ending) unchanged; intro and ending flashes unchanged when a burst overlaps them; Radiance breath unchanged, own glyph opacity still replaces mb overall, response scaled once; command set/reject/usage, presets restore 1. ~~**Live pending:** everything in game.~~ **Live (A, 2026-11-20 01:07):** loaded without errors; 1 = as before; .5 and 0 work great; window flash kept at 0; closing flashes full strength; 2 and x refused; Umbra MB floor glyph unchanged. "It looks great!"

## TargetSC 0.18.2 unified Test6.3 — MB kill freezes (Lua only) (2026-11-18)

**User request (15:30):** "not have everything gather at the mb ring, rather have any rotation or whatever stop, animation freezes, and have MB ring flicker exactly like sc rings... and fade out with them. (or if multiple discs) also flicker the same way and fade out at same time as sc rings also... I want to try having the glyphs grow and fade out with the mb kill bloom. The regular mb bloom would be drawn in by the mb gathering with the other elements, also fading out in time with the sc rings." Interpreted "drawn in" as the MB bloom shrinking back inward while it fades (`kill mb bloom fade` keeps its size). Author: A.

**Changes:** MB freeze mode now freezes the whole frame at kill + `kill mb freeze` (new, .2 s, so the MB's own bloom, which starts at the same moment as the kill, is already open). `M.mb_kill_freeze`: all rings tinted to the element color, alpha × (1 − smooth(k/`mb fade`)) × flicker; non-glyph discs: fill tinted (or `mb discs own`) and faded the same way, their glyph lines split off as an outline-only copy treated as a glyph; glyph roles (mb-glyph, property-trace, umbra-copy, awakening, glyph 2) and `glyphs3` scale 1 → `mb bloom end` × `bloom size` with the kill bloom's ease and take its fade (or, `mb glyphs fade`, fade with the rings); MB bloom radius × (1 − smooth) and alpha with the rings (`mb bloom fade` keeps the radius). The 6.2 ring-only freeze (second frame) is removed. `kill_bloom_disc` shared by both modes.

**Host verification (not FFXI):** suite ALL PASS; `test_kill.lua` MB section rewritten (frozen MB ring and disc, MB and SC rings in the element color, nothing gathers, disc fill element-tinted, MB bloom shrinking, rings/discs/bloom gone after freeze + fade, kill bloom element color, glyph grows ≥1.3× with it and is gone with it, variants fade/fade/own, 6.1 gather and collapse); probe timeline: freeze 1.7, MB bloom 1.45 → .11, glyph 1.78 → 3.25 with the kill bloom, empty by 2.6 s. **Live pending:** the look.

## TargetSC 0.18.1 unified Test6.2 — kill tuning (Lua only) (2026-11-18)

**User feedback (05:23):** "The animations are pretty cool." SC halves' flicker too strong, rotation too much, sky sag too much; seam should be flickery like the halves; seam pointed the right way. MB: "maybe instead the sc rings should likewise freeze but flickering in the color of the element as they fade out"; second bloom should expand and fade faster and slightly larger than the first, overtaking it. Asked whether a vertical glyph could be the seam or go alongside it (answered as a plan, not built). Author: A.

**Changes:** shared `flicker(now,strength)` (level-4 buzz scaled; 0 steady, 1 = Test6.1). New `kill sc flicker` (.35), `kill seam flicker` (1, own frequencies), `kill mb rings freeze|gather` (freeze default), `kill mb fade` (.6), `kill mb flicker` (.6). Defaults: `sc turn` .15→.05, `sc sag` .3→.12, `sc seam` .35→.5, `bloom delay` .15→.12, `bloom time` 1.2→.55, `bloom size` now a multiple of `mb bloom end` (1.25; starts at `mb bloom start`). Freeze renders the ground/sky rings from a second frame at the kill time (kill disabled), tinted to the element color, alpha × fade × flicker; MB ring, disc and glyphs behave as in 6.1.

**Host verification (not FFXI):** suite ALL PASS; `test_kill.lua` extended (frozen ring height, not gathered, element color, fading, gone after `mb fade`; disc/glyph at the MB ring; bloom faster/larger and wider than the MB bloom late in its life; `mb rings gather` keeps the 6.1 gather; new commands). Probe: kill bloom passes the MB bloom ≈.2 s after it starts. **Live pending:** the look.

## TargetSC 0.18.0 unified Test6.1 — kill animations (native 0.12.0; Skillchains bridge) (2026-11-18)

**Branch:** `development/targetsc-mb-rise-gradient`. **Includes a new native DLL (0.12.0).** Kill detection is in the embedded engine (`sc_runtime.lua` + `TargetSC/targetsc_bridge.lua`); a first cut wrongly edited the standalone root `Skillchains.lua`/`targetsc_bridge.lua` and was moved (user caught it, 05:08); root files restored. Author: A.

**User request (spec 04:50–04:52, then "I thought you'd go ahead and build it"):** kill animations only when the MB or WS itself drove HP to 0, else the plain detarget fade. MB kill: sky and ground rings collapse to the MB ring height, fading; property disc and glyphs appear instantly there with their usual animations; then a quick Umbra-style collapse; a second bloom in the element's color bursting outward right after the first; no element signatures; no special level-4 kills; nothing stands up. SC kill: freeze, flash ghostly white, seam along the killing blow, MB glyphs and the disc's own glyph lines flash out and disappear, rings/disc halves float apart with a very subtle counterclockwise motion, sky halves sag, halves buzz out with the level-4 flicker. "Each animation uses what relates to its function."

**Changes:** embedded engine (`sc_runtime.lua`): `action_handler` also calls `targetsc:observe(act)`; the 0x029 handler calls `targetsc:defeat(actor, target, message)`. Bridge: `observe` records per target the last hit (category 3 = `sc`, category 4 with a burst message = `mb` with the spell element, anything else `other`); `defeat` on messages 6/20/97 emits `kill <id> <sc|mb> <element|None> <actor>` when the last hit was sc/mb within 2 s and (when the message names one) from the same actor. TargetSC model stores `kills[id]`; the addon computes the seam angle (killer → target bearing), and a recent kill (<1.5 s) turns the death's outgoing fade into a full-strength kill of `kill time` (also converting a plain fade already started). Motion: frame-start freeze for SC kills (render time = kill + `sc freeze`); `M.apply_kill` post-processes the frame (MB: gather/fade of SC rings to the MB height over `mb gather`, discs/glyphs offset to it with the MB glyph exactly at it, collapse 1 − t^curve, second `kill-bloom` in the element color after `bloom delay`, empty after kill time keeping blooms; SC: glyph roles/lines/blooms white for `sc flash` then removed, disc fills → two sector halves {white, transparent} rotated φ / φ+π plus turn and shifted ±perpendicular, rings → two 180° white arcs each (opener arcs shifted by side), sky offset − sag, alpha × ghost × fade-out × level-4 flicker, seam lines for `sc seam`). Kill frames may use 64 rings. Native 0.12.0: `native.shift(east,north)` stamps a sideways offset on every following ring/arc/disc/glyph (begin resets), `native.line(x1,y1,z1,x2,y2,z2,color,pixels)` (≤8), storage 44,400; earlier calls unchanged. Previews `kill mb [element]` (Fusion open, MB + kill at 1.5 s) and `kill sc` (Scission opener, Fragmentation WS + kill at 2 s). `kill …` commands; killala/historical kill off.

**Host verification (not FFXI):** 0.12.0 `-Werror` build; full suite PASS (incl. the Skillchains regression against its baseline); new `test_kill.lua` (bridge: WS→defeat = sc, MB→defeat = mb + element, "falls" without killer accepted, melee in between / plain spell / stale / different killer / unsubscribed rejected, non-defeat message keeps the record; model kill event + invalid kind; MB kill gather, fade, disc and glyph at the MB ring, element bloom, collapse, empty after; SC kill seam at both ring heights along angle 0, gone after its flash, glyphs flashed out, two disc halves {white, transparent} split, drifting across the seam, ghost white, rings as half arcs, sky sag, empty after, kill off; commands; presets) PASS; new `test_native_kill.lua` (0.12.0 receives 8-arg `native.line` and non-zero `native.shift`; 0.11.0 never; a real kill event followed by death draws the kill on the dead enemy and ends after kill time) PASS for both versions. **Live pending:** detection against real packets (message ids 6/20/97, category 3 for all weapon skills incl. trusts), seam direction (`kill seam angle` to tune), the look of both animations.

## TargetSC 0.17.0 unified Test6.0 — Umbra collapse ending, glyph lift (2026-11-18)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (DLL 0.11.0). Author: A.

**User request:** revisit the ending: in the last two seconds (the three flashes) everything shrinks rapidly to nothing, "easing in very slowly to a quick WHOOSH"; the black hole's disc stays opaque through those seconds; those seconds are the true cap for the swallow ending; only shrink inward (no sinking); the MB glyph's flash height capped just above the black hole (possibly the same height), and that lift applies the whole time for all MBs. Tried `umbra glyph lift 0` before it existed (the parser fell back to `umbra glyph breath|same`); explained.

**Changes:** `M.umbra_collapse` = 1 − u^curve over the last collapse time (−1 = mb ending); applied at the end of an Umbra frame to every ring, disc and 3D glyph radius (MB ring, black disc, floor glyph, copies, blooms, swallow glyph). With the collapse on, Umbra's MB ring skips the ending sink and the disc's life stays 1 while the MB window is active. `umbra glyph lift` ≥ 0 places the floor glyph at the disc plane + lift at all times (after any burst rise). Defaults on/.004; killala/historical off/−1; two older tests pin them off where they check earlier behavior.

**Host verification (not FFXI):** full suite PASS; new `test_umbra_collapse.lua` PASS (factor 1 before, >.9 half way, <.15 at the end; disc and MB ring scaled exactly by it, glyph smaller; MB ring height held vs sinking without collapse; disc alpha ≥254; swallow glyph shrinks; Radiance keeps its normal ending; curve 8 later whoosh; collapse time 4; glyph at disc + lift at rest and during a burst; commands incl. `same`; presets). **Live pending:** the whoosh feel and the glyph showing above the disc.

## TargetSC 0.16.2 unified Test5.9 — longer Umbra swallow (2026-11-18)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only. Author: A.

**User feedback:** loves that the swallowed lines still take the MB's color on bursts. **Request:** let the swallow last to the very end (ending time ~10 s) with a longer sink. Ending revisit discussed next (collapse in the final two seconds; see the next batch).

**Changes:** ranges ending time .3–12, stand time .05–8, sink time .05–10; the Umbra ending window's end is `min(MB deadline, start + ending time)` for `open` and `flash`.

**Host verification (not FFXI):** full suite PASS; `test_umbra_endings.lua` adds the new ranges and a 12 s request capped at the MB deadline with sink ≈1 just before it.

## TargetSC 0.16.1 unified Test5.8 — Umbra swallow from the opening; white glyph; MB ring height (2026-11-18)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (DLL 0.11.0). Author: A.

**User feedback/request (Cioara 03:13):** "settling on swallow"; swallow should begin with Umbra's opening; make the swallowed/gyro'd glyph pure white; asked for timing suggestions; asked how to put the MB ring exactly at the property disc's height; ending animation to be revisited next. Cioara: umbra ending swallow, when flash, time 6, stand 1, sink 4, stagger .6, lift .6, lines size 1 / opacity 1, core 1, flicker .3, disc middle 1, gyro below half / rise .05 / shrink 0 / speed .6.

**Changes:** `umbra ending when open` (window = link creation → + ending time). Ending glyph and Umbra's flat trace stroke white unless `umbra lines color cream`. After its window the glyph stays hidden (`umbra_ending_glyph` returns a gone flag) instead of the flat trace reappearing (affected `when flash` with a short time). `preset killala` and the historical fixture keep the cream lines (`test_terminal_intro` checks them). `umbra mb height disc`: Umbra's `mb_height` = the black disc's fill plane (`M.umbra_plane`); MB-ring-relative pieces (glyph rise target, MB bloom from ring) follow it. Answer recorded: `mb position` 0 only reaches the normal disc plane (all levels), not Umbra's raised level-4 disc, hence the Umbra option.

**Host verification (not FFXI):** full suite PASS; `test_umbra_endings.lua` adds: swallow under way at .5 s with `when open`, pure white, stays gone at 5 s, cream option, flat Umbra lines white, MB ring offset = the disc fill's offset with `mb height disc`. **Live pending:** the timing suggestion (open 2 / close 2.18: `ending time 4.2`, `stand time 2`, `sink time 2.2`).

## TargetSC 0.16.0 unified Test5.7 — Umbra endings (native 0.11.0) and Umbra controls (2026-11-18)

**Branch:** `development/targetsc-mb-rise-gradient`. **Includes a new native DLL (0.11.0).** Author: A.

**User request:** the upright spinning glyph (Umbra only) and the vertical line segments sinking, as **two separate Umbra ending animations to test** (not one sequence). Controls: the disc glyph over Umbra the same size as the floor glyph + MB ring, with its own opacity; opacity of the disc's middle part; the disc's opacity throughout the animation ("seems to fade out a bit"); opacity of the darkest part of the ring cores. Cioara (02:42): umbra bloom growth .1 / height rings / opacity .666 / size 1.15 / time 3, close 2.18 (equalized with Radiance's 4.2 s), copies depth 0 / every .3 / life .6 / size 1.1 / spin −1, glyph opacity 1 / spin −.3, spin 6.

**Changes:** native 0.11.0: `native.glyph(radius,height,rotation,color,tilt,stand,lift,sink,pull,stagger,order,clip,circle)` (≤4 per frame): the 24 property-glyph segments (and optional circle) in 3D — `tilt` stands the whole glyph up about its local x axis; per segment, `stand` turns it vertical about its midpoint (axis level and perpendicular), midpoints at lift × half the longest segment; `sink` (eased in) lowers it fully below the plane and `pull` moves the midpoint inward; `stagger` by order key (outer/inner distance); `clip` keeps z ≥ 0. Geometry in `PropertyGeometry.h` (`glyph3_segment`, `glyph3_clip`, `glyph3_tilt`, `glyph3_local`, `glyph3_key`), host-tested; storage 44,352 vertices; existing calls unchanged. Lua: accepts 0.11.0; sends `frame.glyphs3` only to 0.11.0 (dimmed with the hand-off level). Umbra ending window = MB ending or flash-out + ending time; during it the flat trace is hidden and one 3D glyph is sent at the trace's radius/height/color (gyro: tilt = π/2·smooth(u/rise), rotation = disc rotation + 2π·speed·u, radius × (1−k)² over the last shrink share, circle, clip with `below half`; swallow: stand = u/stand time, sink over the last sink time, pull/stagger/order/lift, clip, no circle). Umbra lines size (× MB ring × umbra mb size) and opacity (direct × disc life); Umbra disc inner/middle/outer/position overrides; `disc steady` sets the fill to its base opacity (no pull toward mb overall on intro/burst flashes); ring cores: `umbra core` replaces opacity × brightness and `umbra flicker` sets the depth (alpha × (1−d+d·electric)). killala/historical: steady off.

**Host verification (not FFXI):** 0.11.0 `-Werror` DLL build; `test_property.cpp` adds 3D glyph cases (flat at rest, vertical at the midpoint with center .4/length .4, fully below after sinking and clipped away, pulled inward, clip cut at z=0, tilt stands a segment upright, outer-first stagger) PASS; full suite PASS; new `test_umbra_endings.lua` PASS (off by default; gyro tilt/upright/spin rate/circle/full vs half/shrink, flat glyph hidden only during the ending; swallow stand/sink/pull/stagger/order outer|inner; flash window; no 3D glyph and flat trace kept on 0.10.0; lines size × MB ring and opacity; Umbra disc shape; steady disc solid through the window-opening flash vs dipping without; direct core opacity with lit side, flicker 0 steady, deeper flicker; commands; presets); new `test_native_glyph.lua` (0.11.0 receives 13-arg `native.glyph`, clipped, no circle for swallow; 0.10.0 never) PASS. Host probe: gyro stands in .4 s, spins, shrinks r1.92 → .02 over the last second; swallow stands by .5 s and sinks over the last second. **Live pending:** both endings (projection of upright/vertical lines, the lower dome under the floor), all new controls.

## TargetSC 0.15.6 unified Test5.6 — Umbra spin, sky rings, blooms, floor glyph, copies (2026-11-18)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only. Author: A.

**User feedback (Cioara 01:43):** "the three discs look greatttt"; Cioara: radiance bottom .3 / .9, middle .6 / .96 / cycle 3.6 / spin −.6, close 1.2, fade .09, glyph opacity .9, open time 3; umbra bloom growth 2, height mb, opacity 1, time 6, close .9, disc size 1.5, mb size 1.36, open time 2. Asked how to equalize Radiance/Umbra totals (answer: Radiance rings end at open + close time; Umbra's at open + close time + flash time + gaps; e.g. `umbra close time 2.18` matches Radiance's 4.2 s).

**User request:** Umbra bloom: two, at the SC ring heights. Umbra sky rings the same circumference as the ground rings (no expansion). Umbra special ending later (shrinking, pulling, sinking rather than fading). Glyph copies for Umbra next; Umbra's breathing floor glyph at the property disc's height, sized like the Umbra MB ring, and it **turns**; drawn "at the exact same level as the black disc, I wanna see what that looks like". Copies every .6 s lasting about 1.2 s, both adjustable. An Umbra spin above the level-4 maximum ("up to 6 … like a supermassive spinning black hole"; level-4 speed is 0 global / 3 Cioara, command range 0–4). Upright spinning property-disc glyph tracing a dome: needs a DLL (answer later). "THIS IS FEELING SO AWESOME".

**Changes:** frame-start option view for Umbra: `umbra spin` ≥ 0 replaces `disc_speed_level4`; `umbra glyph breath` → rest breath / after fall (the Radiance glyph code generalized per level-4 name). Umbra floor glyph: rotation = level-4 disc rotation × `glyph spin`; radius = MB ring radius × `umbra mb size` × `glyph size`; offset moved from the disc height to `M.umbra_plane` (the terminal fill plane: disc height + ground wave + .006 + level-4 height), so bursts still lift it from there; `glyph over` moves it after the discs. Sky ring radius skips the bell factor with `umbra sky same`. Flash-out bloom `rings`: one disc at the ground ring height and one at the sky ring height (× bell factor only with `umbra sky bell`). Copies: spawned at created + k·every while before `M.umbra_flashed`; each age < life drawn as a glyph-lines disc, radius = floor-glyph radius × (1 + (size−1)(1−(1−t)²)), alpha = opacity × attack × (1−t), rotation = disc rotation × copies spin, height = plane − depth, inserted before the first property disc in draw order. Defaults on; killala/historical: bell, glyph same, copies off.

**Host verification (not FFXI):** full suite PASS; new `test_umbra_glyph.lua` PASS (spin 6 ≈ 2× level-4 3, Radiance unchanged; sky = ground radius, bell flares, Radiance still flares; two blooms ground < sky, one for ground; glyph at the fill's height, MB ring radius × size, turns with the disc, × −2, before the disc in draw order, over → after, breathes; copies: one at .3 s, two at 1.3 s with the older further out, before the disc, at the depth, glyph lines, none after the flash-out ends, every/life adjustable, off, Umbra only; commands incl. range; presets). Host probe with Cioara-like values + spin 6: glyph r2.61 inside the r2.76 disc at h.182 turning with it; copies r3.3–4.2 visible outside the rim, stopping after the flash-out; two blooms growing (growth 2). **Live pending:** all of it; the floor glyph is mostly hidden by the opaque disc at the same plane (try `umbra glyph over on`) and is faint unless `umbra glyph opacity` is set.

## TargetSC 0.15.5 unified Test5.5 — Radiance three-disc stack (2026-11-18)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only. Author: A.

**User request:** add the three-disc stack (from the 2026-11-17 notes: another rotating property disc beneath the current one, tied to the level-4 speed, fading between Fusion and Fragmentation appearances "like colored lights under cloud cover", with a third white disc beneath — "a different form of an opening weaponskill with transfixion, radiance, transfixion properties"; the lowest disc has an opacity override and controls the overall height of the three; the Fusion/Fragmentation crossfade gets its own setting). Asked what the current disc becomes (answer: the top of the stack, unchanged) and whether `radiance glyph opacity .9` makes the glyph's maximum .9 with the breath gain (answer: yes — with its own opacity the breath gain no longer matters; it breathes from .9 × `mb breath min` up to .9; Cioara's .7 → .63–.90).

**Changes:** in the terminal (level-4) disc path for Radiance (first property) with `radiance stack`: a white `radiance-bottom` disc at the disc height + `stack height`, a `radiance-middle` disc one `stack spacing` above it whose colors blend pairwise Fusion → Fragmentation → Fusion (½−½cos over `middle cycle` from the link's creation) and which turns at `M.disc_rotation` × `middle spin`, then the existing top disc and its trace one spacing higher; bottom/middle opacity = setting × the disc's life (ending fade), not the overall opacity; sizes × the level-4 fill size; the level-4 inner/middle/outer shape applies to all three. Drawn bottom → middle → top. Defaults on; killala/historical off. The Test5.1 test pins the stack off where it compares Radiance and Umbra heights.

**Host verification (not FFXI):** full suite PASS; new `test_radiance_stack.lua` PASS (three discs in draw order, .01 spacing, white bottom/top, direct opacities .6/.5, stack height +.1 moves all, spacing .03, Fusion colors at a cycle start and Fragmentation halfway, middle rotation = level-4 disc rotation and × −2, sizes, shared middle stop, off/Umbra/killala, glyph own opacity peak .90 and trough .63 with breath min .7, commands, presets). Host probe: bottom/middle/top at .073/.083/.093, middle shifting through the Light↔Lightning and Fire↔Wind pairs. **Live pending:** the look; how the white top disc's opacity over the colored middle reads (try `radiance disc opacity` .3–.6).

## TargetSC 0.15.4 unified Test5.4 — level-4 open time, Umbra bloom and MB ring, Radiance glyph (2026-11-18)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only. Author: A.

**User feedback (Cioara settings 00:28):** "THIS IS FEELING SO COOL!"; likes `umbra close time` as a separate hold. Cioara: detarget .15, switch .1/.1, `disc_level4` inner 1 / middle .9 at .9 / outer 0 / size 1.2 / height .11, `disc_speed_level4` 3, `mb_radiance_cycle` .15, Radiance close 1.5 / fade 1.2 / flash 2.1 / lead .3 / order together / shimmer 1 at .3 s, when all; Umbra close 1.5 / disc opacity 1 / flash 1 for .02 / gap 0 / together / smoke .18, no spread.

**User request:** `radiance open time` / `umbra open time`. Umbra: the smoke rings replaced by one ring-shaped MB-style bloom (transparent → black → transparent), "most of the same shaping settings, just black and with a different overall opacity", with a growth setting where − shrinks, 0 stays in place as it fades, + grows; which settings need their own values can be refined later. Umbra MB ring: instead of the purple ring, pulse like its ending (not sinking until the real ending) across the whole window, matching seamlessly with the actual ending; adjustable Umbra MB ring size. Umbra disc larger than the shared level-4 size ("huge floor black hole around enemy's and ally's feet"); Radiance's size is liked as is. Radiance: hide the disc's glyph; the MB floor glyph does its old breathing, NO rotation, adjustable size and opacity. Deferred by the user: Radiance three-disc stack, Umbra glyph copies, level-to-level ring transitions (new levels' rings currently just appear).

**Changes:** at frame start a level-4 link may get a view of its state with `sc_open = created + open time` (and `sc_close ≥` that); MB timing and the stored state are untouched. Radiance `glyph breath` runs the frame with `mb glyph rest breath` and `after fall`; its glyph rotation is 0, radius × `glyph size`, offset follows the ground ring wave (`glyph buzz`), opacity replaces `mb overall` and, when set, is the breath itself (idle ÷ (mb idle × breath gain)). Radiance trace drawn with zero outline unless `disc lines on`. Umbra `after bloom`: per-ring smoke suppressed; one black disc from `M.umbra_flashed` (last ring's flash end) for `bloom time`: radius = SC ring radius × size × (1 + growth × (1−(1−t)^mb ease)), alpha = bloom opacity × .05 s attack × (1−t)^mb fade, stops from `mb bloom` center/middle/position/edge, height ground ring / property disc / MB ring. Umbra MB ring `pulse`: before the ending, color → white and alpha → `M.umbra_pulse` × strength (× mb effects): the ending's soft strong/half/strong (or hard) rhythm extended backwards from `mb_close − mb ending`, so the handover is at a pulse boundary with the same pattern; the real ending code then takes over (and sinks). `umbra mb size` scales its radius; `umbra disc size` replaces the level-4 size for Umbra's fill and lines. `umbra mb strength` (named to avoid clashing with `umbra mb pulse`). Older tests pin `umbra after smoke` / `radiance disc lines on` where they check 5.1/5.2 behavior.

**Host verification (not FFXI):** full suite PASS; new `test_level4_more.lua` PASS (open time phases for Umbra/Radiance, state untouched; bloom absent before the flash-out, black, MB bloom stops, shrinks/stays/grows, own opacity, height choice, no smoke glows in bloom mode, smoke and off modes; Umbra MB pulse equals the real ending curve at seven points inside the ending, ~0 at the handover, repeats across the window, white vs classic purple, no sinking before the ending, sinks in it, size ×2; Umbra disc ×8 while Radiance unchanged; Radiance trace hidden/on; glyph rotation 0 with level-4 spin 3, breathes at rest, size ×1.5, own opacity 1 reaches ~full at the peak, buzz moves it more than without; commands; presets). Host probes with Cioara-like Umbra values: opening ends at 2 s with open time 2, rings flash out together ~3.5 s, black bloom shrinks 1.59 → 1.02 while fading, disc ×4 solid black, MB ring pulses then sinks in the last 2 s. **Live pending:** all of it.

## TargetSC 0.15.3 unified Test5.3 — `preview umbra` (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only quick patch. Author: A.

**User request:** "one quick patch with tsc preview umbra, a darkness skillchain closing is opened into the full umbra animation" (to test Test5.2's Umbra look ASAP).

**Change:** `preview umbra` (any case) → Darkness level 3 link created 5 s before the preview (SC window closes at 2.0 s), Umbra level 4 closed link at 1.2 s, preview ends at Umbra's MB deadline (11.2 s). The four-link demo previously on `umbra` remains on `preview demo` / `preview full`.

**Host verification (not FFXI):** full suite PASS; `test_level4_looks.lua` adds: Darkness window closing within 3 s, Umbra level 4 closed created at 1.2 s, preview ends after Umbra's MB deadline, `demo` still the sequence. **Live pending:** the Umbra look via this preview.

## TargetSC 0.15.2 unified Test5.2 — Radiance/Umbra ring looks (Batch A of the level-4 pass) (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only. Author: A.

**User direction (discussion, recorded):** Radiance: the rings stay as at the beginning of their opening (white, buzzing, rotating with the level-4 disc speed) instead of turning gold; at 3 s they fade one at a time, **lower before upper**, innermost to outermost, each glow giving its own brief flash and going out before its ring; a shimmer on the glows: a bright patch **traveling around each ring from the far side (top on screen) to the near side (bottom) and back, staggered** so each concentric ring differs; the MB ring may adopt it while keeping its rotation and color shifting; no end-glow swell for now; close-out stretched to **3 s**. Umbra: all assets may override the overall opacity (wants TOTAL black); rings with a **black core and white glow** from the opening; after the hold each ring **flashes white and immediately disappears, outermost to innermost, upper before lower**, leaving only the glow, which becomes **a barely noticeable black, like smoke, dissipating in place**. "Include options to test variations and fine tune." Confirmed answers: gold glow existed but was faint (≈ overall opacity × .32); Umbra rings looked white at the opening because every link starts white and shifts at window open (not the glow). Middle point .095 → use .95 for near the edge. Batch B (next): Radiance three-disc stack (white / Fusion↔Fragmentation crossfade with **its own timing setting** / white, lowest disc opacity + overall height), Radiance single large white glyph (still, buzzing, breathing, own opacity/size), Umbra glyph copies spinning just under the disc through the opening. Batch C (DLL): glyph without circle, filled glyph, glyph line glow, tracing, Umbra lines tilting up and sinking into the disc (clipped at its plane).

**Changes:** `radiance …` / `umbra …` command namespaces (table-driven; numbers, `same`, choices, on/off; two-word settings). Level-4 links only (Radiance/Umbra, not openers). Opacity overrides replace `opacity` in the frame; disc opacity replaces `discs opacity × opacity` for the fill. Looks: Radiance `open` forces the opening color mix (white); Umbra `black` forces black cores; Umbra `white` glow tints both glow bands white. Close sequences draw the rings past the terminal fade until `level4_end`; per-ring schedule `M.level4_ring` (order index from set/direction): Radiance step = (close−lead−fade)/(rings−1), glow ×(1+flash) then out by `lead`, core fades over `fade`; Umbra hold `close time`, then per ring `gap`: white core near full alpha for `flash time`, then core gone and glow → black over the first quarter of `smoke`, alpha × `smoke opacity` falling to 0, radius spreading by `smoke spread`. Shimmer `M.level4_shimmer`: four-stop gradient on the glow bands (bright | base | dim | base) rotated to angle = view + offset + π·(½−½cos(2π(t/period + stagger·index))); view angle = bearing from you to the target (approximate camera direction; 0 on yourself), passed through the resonance context; MB ring index 8. `band` gained a `lit` argument; `ring` an `extra` table (glow/core scales, spread, lit). Defaults on; killala/historical fixture classic.

**Host verification (not FFXI):** full suite PASS (Test5.1 test isolates the MB shimmer); new `test_level4_looks.lua` PASS: open stays white vs classic shifting; order indices for lower/upper/together and inner/outer; glow waits, flashes >1.5×, out before its ring, ring then fades; last ring still drawn in mb-only, all closed after 3 s; shimmer absent before the window with `when close`, present with `all`; far side → near side (view+π) → back over one period; staggered per ring; angle offset; glow band rotation equals the patch angle with a bright/dim four-stop gradient; MB ring joins (index 8) and `shimmer mb off`; Radiance opacity override; Umbra disc opacity 1 = alpha 255 black (default remains capped); Umbra black core + white glow, black through the hold, outer upper ring flashes white first, next after one gap, vanished ring leaves black smoke, smoke opacity scales; Umbra classic white before the window; commands incl. two-word, `same`, invalid choice/range; presets. A host timeline probe showed the full Radiance sequence ending 3 s after opening and Umbra's flash-out + smoke (smoke default lowered to .5 after the probe showed ~28% black at 1). **Live pending:** everything; especially whether the shimmer's "far side" lines up with the camera (tune with `radiance shimmer angle`), and the smoke's visibility.

## TargetSC 0.15.1 unified Test5.1 — Radiance MB ring; level-4 disc controls (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (native 0.10.0 unchanged; its middle stop is used by the new disc option). Author: A.

**User request:** the Radiance MB ring "exactly like one of the middle rings of the light skillchain, but in the location and size of the radiance mb ring, full glow strength, shifting fast" (their SC glows are at .9/.6; for this ring around the maximum, 3); options for the Radiance and Umbra "property disc" opacity (inner/outer, with a middle point), size and height. Direction for level 4 generally: it already has an in-game animation, so level-4 effects should just introduce the skillchain — subtle effects on what's already there. Ideas to come back to: Umbra's bloom drawn **inward**; Umbra's property disc as an opaque "black hole" with a thin white glowing ring; something different and special for both level-4 MB rings (not decided).

**Changes:** `mb radiance light|classic` (default light; killala classic): on a Radiance link the MB ring is white with the lit side and the disc's rotation (Test4.7 match path), plus the Light middle strand's inner glow, which cycles Light's four elements (index 2, same mixing) every `mb radiance cycle` (.4 s) at `mb radiance glow` strength (3): the ring() glow uses the inner color × gain, and the SC-style glow band keeps the SC ring's glow-to-core proportion (.32·glow·electric·gain / (brightness·.95·(.72+.28·electric)), level-3 electric) relative to the MB core alpha. MB timing (breath, intro, bursts, ending) unchanged. Level-4 disc (terminal path, Radiance and Umbra): `discs level4 inner|middle|outer|position|size|height`; -1 = same as `discs` (middle -1 = none); size applies to fill and trace; height lifts both. Level 1–3 discs unaffected.

**Host verification (not FFXI):** full suite PASS; new `test_radiance_level4.lua` (white core; two glows; glow color travels through several colors in 1.2 s, far less with cycle 8; strength 3 > 1; ring glow = core × .24 × glow × 3; MB ring rotation equals the disc's when the level-4 disc turns; classic has one plain glow; Umbra unchanged; level-4 disc defaults untouched; overrides on Radiance and Umbra: inner/outer/mid/position, 1.5× size for fill and lines, +.1 height for both; level 3 unaffected; commands, `same`, ranges, presets) PASS. **Live pending:** the look on a real Radiance (needs `discs speed level4` > 0 to see it turn; Cioara has 1); disc options on Radiance/Umbra.

## TargetSC 0.15.0 unified Test5.0 — target handoff fades; preview switch (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (native 0.10.0 unchanged). Author: A. Test4.9 was pushed at the start of this batch (the repo was attached to the session with the user's permission).

**User feedback on Test4.9:** "we got something real good here"; the overlap interactions noted in Test4.9 don't look bad in game ("they kinda work"); keep an eye out. Supplied Cioara bloom values (center 0, middle 1 at .9, core 1, flash 1, ease 1.5, fade .9, size 1.1→1.21, time 4, to ring, lines delay .15 / size 1.06).

**User request:** kill rule recorded for later: a kill only counts if the MB or WS itself drove the enemy to 0 HP; special SC-window and MB kill animations are postponed. Now: detarget/untarget and ordinary death keep the animation running exactly as normal on the old enemy and dim **from the first moment** (no hold), 1 s default, extendable to 3 s. Switching targets: quick fade out then fade in, but **only when the new enemy has resonance**; otherwise the old enemy uses the detarget duration. `preview off` should use the detarget animation. A preview for switching: on self, or apply the preview resonance to two enemies switched between.

**Changes:** `detarget time <0-3>` (1), `switch out <0-1>` (.25), `switch in <0-1>` (.35). Implemented in `TargetSC.lua`'s render loop as a sequential hand-off (the DLL draws one target per frame): the frame is sent at a level by scaling every color's alpha (rings, tails, disc colors, outlines, hubs); the old target is redrawn by its index while its id still matches. Retargeting a fading enemy brightens it back from its current level over the remaining `switch in` share (a fading preview comes back too); a carrier target picked during a slow fade hurries it (`switch out` × level); the new target's fade-in starts when the old fade ends. `preview off` → detarget fade; a real state arriving for that target drops the fading preview. `preview switch [preview]` (default `mb`): the first two targets picked (enemies, or yourself) carry the preview; others stay plain. Cutscene/zone/logout/off/despawn/recycled index cut immediately. `preset killala` → 0/0/0 (instant). `test_addon.lua` death and self-preview checks updated to the new fade (previously instant cuts).

**Host verification (not FFXI):** full suite PASS; new `test_handoff.lua` measures levels against an undimmed twin of the same preview: untarget 1.0 → .5 at .5 s → .1 at .9 s → gone after 1 s on the old enemy; retarget brightens from its fading level to full; switch to a plain enemy uses the full detarget time; switch preview A→B: A out over .25, then B in over .35 (half at .175 s); B→plain C: full detarget time; back to A during that: B hurried, A in; a third enemy never carries; recycled index and cutscene cut; preview off dims; commands, ranges, presets. **Live pending:** whether the DLL keeps drawing on a just-dead enemy during the fade (dead mobs stay a few seconds; if it stops, the fade will cut there); feel of the timings; `preview switch` with two enemies.

**Next (user's order):** Radiance MB ring = like a level-3 Light middle SC ring with the colored glows, but strong (around the maximum, 3) and shifting fast, only on the MB ring. Later: Radiance disc/glyph/ring colors (gold ring with white glow and white ring with gold glow, reversing as they flicker like the xivcrossbar active-slot skillchain flicker; "buzzing with power"), a cleaner Radiance fade from opening to end (level 4 has no real "opening" window), the same review for Umbra/Darkness, possibly reusing the bloom around the property ring when a new skillchain opens, and the postponed kill animations.

## TargetSC 0.14.9 unified Test4.9 — MB burst bloom; preview mb light/dark (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. **Includes a new native DLL (0.10.0).** Author: A.

**User request:** loves the latest MB animation; asked whether the breathing glyph has its own disc (answer: not yet; item 4 of the open list). Chose option 1, the burst bloom: command options for starting at MB-ring or property-disc height; growth `<start> [end]`; opacity at three points (center, edge and somewhere between); copies of the glyph lines growing outward as an option; anything else that helps finesse it and read as a magic burst. Also requested two previews: `preview mb light` = a level 3 Light link opens from a nearly closed Fusion just after a Fire MB; after the new window opens, a Light MB, then a Wind MB right after the ending animation begins. `preview mb dark` = Darkness level 3 opens; two quick MBs, Ice and then, as that MB animation ends, Darkness; towards the end of the window Umbra (level 4) opens; after its animation the MB elements are hit by Ice, Earth, then Darkness exactly as the ending begins. Purpose: test overlaps and get ideas about where to move animations.

**Changes:** native 0.10.0: `native.disc` optional args 15–16 = middle radial stop (alpha multiplier, radius fraction .05–.95; the stop's RGB is the straight center→rim blend), drawn as a center fan plus a middle→rim annulus only when given; disc limit 8 → 16 with the bounded vertex storage updated (42,240); omitted args keep 0.9.0 output. Lua accepts 0.10.0 (still 0.9–0.5); the middle stop is sent only to 0.10.0, and the disc budget is 16 there, 8 otherwise. Bloom (all `mb bloom …`, default on, killala off): one per confirmed burst on its own clock (overlaps each finish), drawn after every other disc so it is the first to drop at the cap; radius = MB ring radius × (start + (end−start)·(1−(1−t)^ease)); opacity = `mb overall` × `mb effects` × .05 s attack × (1−t)^fade, multiplied at the center/middle/edge stops; color starts white-hot (`flash`) and settles into the element over the first 30% of its life; the center blends toward white (`core`, via the 0.9.0 hub color); height from ring (MB ring height), disc (just above the property fill) or glyph (current large-glyph height), optionally travelling `to` another plane along the growth. Optional glyph-line copies (`lines 1–4`) start at the large glyph's size, one every `lines delay`, grow to `lines size`, turn with the glyph and share the color/fade. With an ending style, blooms go out over the last .25 s before the MB deadline. A burst entry is kept while its bloom still draws (`max_duration` 4 → 6 s for expired tails). Previews `mb light` / `mb dark` (plain `preview mb` unchanged). Historical fixture pins `mb_bloom=false`.

**Host verification (not FFXI):** 0.10.0 `-Werror` build; `test_property.cpp` adds `radial_mid` (ends, half blend, alpha multiplier, clamping) PASS; full suite PASS; new `test_burst_bloom.lua` (ring height, growth formula, fade, three stops and hub, white-hot start, no copies by default, disc→ring rise and `same`, two staggered copies larger than the ring turning with the glyph, two overlapping blooms, 16 vs 8 disc budget, a 3.5 s bloom keeps its burst, out at the deadline, off/killala, every command and range, presets, both preview sequences against the request, bloom drawn on an Umbra MB) PASS; new `test_native_bloom.lua` (addon sends middle .35 at .5 with a hub to 0.10.0; 0.9.0 never gets more than 14 args) PASS. A host timeline probe of both previews was used for the overlap notes below.

**Overlap notes from the probe (for discussion, nothing changed):** (1) during the ending the large glyph pulses wherever it is: at the floor normally, but at its risen height when a burst landed within ~2.6 s, while the MB ring sinks to the floor, so they separate (open decision #1); (2) a burst exactly as the ending begins is masked by the ending pulses on the glyph and ring, so the bloom is its only visible signal; (3) a re-strike after the risen glyph has mostly faded restarts its rise from the floor (a small dip, e.g. .22 → .18 in the dark preview at 14.4 s) because the carried height uses the return energy; (4) the Fire burst's risen glyph keeps fading through Light's first ~1.8 s, overlapping Light's window-opening flash; (5) default bloom end size reaches about 1.3× the SC ring radius; (6) Dark blooms start white-hot with a whitish core (`flash`/`core`), which may read oddly for Darkness.

**Live pending:** bloom look and defaults; `from disc to ring`; three-point opacity (try `opacity 1 .2 .6` for an edge-bright shockwave); `lines 2`; both previews. Close all clients before replacing the DLL.

## TargetSC 0.14.8 unified Test4.8 — large glyph fades at its risen height; hidden at rest (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (native 0.9.0 unchanged). Author: A.

**User request:** instead of the large breathing glyph falling back after a burst (`mb hold` .6 s / `mb return` 2 s only time the fall), it should stay at its risen height and fade away over that same period. At the floor it should show only the brief flash when a new MB window opens and otherwise be fully faded, so there are no conflicts; a burst during that time takes over. The ending interaction is still to be decided.

**Changes:** `mb glyph after fade|fall` (default fade): the clapper glyph's height stays at the peak (rise ramp still applies) while its opacity follows the same return energy as before, fading out instead of landing; a re-strike returns it to full at that height. `mb glyph rest hidden|breath` (default hidden): no floor breathing; the window-opening flash, bursts and (interim) the ending pulses still light it. Classic MB style unaffected. Test3's glyph test pinned to fall/breath. `preset killala` → fall/breath.

**Host verification (not FFXI):** full suite PASS; new `test_glyph_fade.lua` (opening flash visible then hidden at four later times; breath option still breathes; after a burst the height is constant at the risen peak while visible and well above the floor, opacity falls (168→84 alpha over 1.5 s in a host probe), gone after the return with no fall; fall option still falls; re-strike brightens at the same height; ending pulses still show; commands; presets) PASS. **Open:** ending interaction for the glyph (currently pulses at the floor while the MB ring sinks onto it). **Live pending:** feel of fade vs fall; empty floor during the window.

## TargetSC 0.14.7 unified Test4.7 — Light glows wait for the window; Light MB ring matches the lowest ring (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (native 0.9.0 unchanged). Author: A.

**User request:** first asked for Light's pre-window rings to look like `rings light classic`; after learning that every link's rings are white before the window in both modes (the classic difference being the gold glow and no lit side), revised before delivery: stay in the white look, with the colored inner glows at strength 0 until the window opens, then at the `rings light glow` setting. Also, for level-3 Light only, the MB ring should basically match the lowermost skillchain ring's appearance, including rotation. A classic-crossfade version was built and tested first, then replaced in the same batch (not shipped).

**Changes:** `rings light opening off|on` (default off): the inner glows' strength follows `rings light glow` × the opening transition (0 before the window, full .15 s after it opens, the same .3 s ring opening transition). `rings light mb match|white` (default match): the level-3 Light MB ring is white with the same lit side (`rings shade`) and the same rotation as the lowest ground ring (disc spin under `rings spin disc`; still under classic), keeping its MB breathing, burst flash, intro and ending. Darkness, level 2 and other levels unchanged. Test4.6's test pinned to `opening on`. `preset killala` → on/white.

**Host verification (not FFXI):** full suite PASS; new `test_light_opening.lua` (no colored glows before the window, present after; `on` shows them from the start; identical to `on` after the transition; strength rises through the opening; MB ring rotation equals the lowest ring's, white with a bright/dim lit side like it, `white` option plain and still; MB ring still breathes; Darkness and Fusion MB rings unchanged; commands; presets) PASS. **Live pending:** the wait→open moment on a Light link; MB ring look against the lowest ring.

## TargetSC 0.14.6 unified Test4.6 — level 3 Light: white strands, element-colored inner glows (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (native 0.9.0 unchanged). Author: A.

**User feedback on Test4.5:** too colorful for Light. Chose: rings white with the colors living on the property disc (Cioara uses `discs lightdark elements`); the four inner rings' **glows** carry the element colors in game order top to bottom (one of them the Light element, white), slowly changing over time; the Light MB window keeps a white breathing ring. **Darkness keeps the Test4.5 elements look** (user likes it). Supplied Cioara's current settings (incl. `frames full`, `disc_inner 0`, `disc_size 1.03`, `mb_breath_gain 1`, `mb_breath_min 0.7`, `mb_glyph_rise 0`, `mb_lightdark_cycle 3`, `ring_lightdark_spin -2`, `intensity 0.1`).

**Changes:** `rings light white|elements|classic` (Light only; default white). White: all six strands white; the four inner rings (top to bottom: sky middle, sky lower, ground upper, ground middle) get glow bands in Fire/Wind/Lightning/Light that shift down one ring every `rings light cycle` seconds (default 4) with smooth hand-offs; the outer two keep white glows; `rings light glow <0-3>` scales both glow layers on the inner rings; MB ring white with its normal breathing. `rings lightdark` now governs Darkness (and Light only when `rings light elements`). Test4.5's test pinned to `rings light elements`. `preset killala` → classic.

**Host verification (not FFXI):** full suite PASS; new `test_light_white.lua` (six white strands; inner glow colors at four step boundaries in order, outer glows white; exactly one inner glow is the Light element; glow strength; white MB ring; Darkness frames identical whatever the Light mode, still four-color middle; commands; killala) PASS. **Live pending:** `preview level3` look, cycle speed, glow strength.

## TargetSC 0.14.5 unified Test4.5 — level 3 Light/Darkness rings (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (native 0.9.0 unchanged). Author: A.

**Brainstorm recorded (2026-11-17), not yet built:** (1) the whole MB apparatus fades over the window after its introduction except when lit by a burst or the ending ("energy passing from anchor to resonance" liked; open question whether the MB ring keeps strengthening while the glyph fades); (2) the breathing glyph stops spinning while risen at MB ring height during a burst and resumes without a jump (alternative: fades out and grows back in like the MB ring); (3) special animations when an MB or skillchain kills the target, instead of cutting out (needs research on death/event timing; dead mobs persist a few seconds); (4) a quick fade on target switch (sequential fade without native change; true crossfade needs a DLL); (5) a burst "bloom" disc in the element color expanding from MB-ring or property-disc height, center-opaque/edge-transparent. Ease ranking given: fade < L3 rings < glyph hold < target switch < kill animations. User chose the level 3 rings first.

**Request implemented:** level 3 Light and Darkness links: top and bottom strands white (Light) or black (Darkness); the middle strand blends around the circle through the four element colors; the MB ring cycles through those four colors, twice as fast as level 2's two-color cycle.

**Changes:** `rings lightdark classic|elements` (default elements); options `rings lightdark spin <-2-2>` (middle strand turn rate relative to the others; negative counter-turns), `rings lightdark tint gold|white` (Light's level 3 glow band; default white since gold read close to Earth), `rings lightdark cycle <0.25-6>` (MB ring four-color cycle speed as a multiple of level 2's; default 2). Uses the existing native ring gradient; the middle strand follows `rings blend`. Strand heights unchanged (0/.035/.07). Openers, level 2 and level 4 unchanged. `preset killala` → classic/1/gold/2.

**Host verification (not FFXI):** full suite PASS; new `test_lightdark_rings.lua` (Light and Darkness on ground and sky: outer strands white/black, middle four element colors blended in game order and turning with the rest; spin −1 counter-turns; white tint with gold option; MB ring shows all four Light elements over four hand-offs; classic restores three single-tone strands; Fusion L2 and Radiance/Umbra L4 identical either way; commands; presets) PASS. **Live pending:** `preview level3`, `preview Darkness 3`, middle strand spin values, tint, MB cycle speed.

## TargetSC 0.14.4 unified Test4.4 — link disc controls and Light/Darkness elements look (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only over Test4.0+ (native 0.9.0 unchanged). Author: A.

**User feedback/requests:** `frames full` "looks so good". Asked about the breathing glyph height (`mb glyph height`, default 1.1 = just above the MB ring), instant rise (`mb glyph rise 0`) and matching the sigil lift (`mb lift` ≈ .15 level / .17 just above with current heights; a ring-relative sigil lift was offered). Described the bell: sky ring = mouth, ground ring = closed end, MB ring = resonance within, floor glyph = anchor holding it to the ground, property disc = elemental resonance tied to both SC and MB. MB overhaul ideas for later: glyph invisible at rest except glow while settling; on a burst the glyph gets its own disc fill that subtly expands and fades (and possibly line copies growing out of it like emanating power). Requested now: link disc fade/size, `discs size lines`, one setting for all links, and the Light/Darkness four-element disc look as an option.

**Changes:** `discs fade <inner> <outer>` (link fill center/edge multipliers), `discs size <0.2-2>` (link fill only), `discs size lines <0.2-2>` (link glyph lines = upper sigil and its burst glow), all levels including level 4 terminal discs; opener keeps its own `opener discs` controls (shared code path now picks opener vs link values). MB ring/large glyph sizing unchanged. `discs lightdark classic|elements` (default classic): Light/Darkness discs (links and openers; level 4 terminal unchanged) show a white/black hub (native 0.9.0 hub color) blending out to Fire/Wind/Lightning/Light or Earth/Ice/Water/Dark at the rim; hub follows burst/intro tinting. Classic MB style splits fill and lines only when a custom value is set. `preset killala` → 1/1/1/1/classic.

**Host verification (not FFXI):** full suite PASS (opener disc tests unchanged after the shared refactor); new `test_link_discs.lua` (both MB styles: defaults byte-identical, fill size/fade with lines unchanged, lines size, terminal fill size, opener and link settings fully independent, Light/Darkness hub and four rim colors with blending, no hub elsewhere or in classic, opener Light gets it; commands; killala) PASS. **Live pending:** `preview level3` (Light), `preview Darkness`, `preview opener Light` with `discs lightdark elements`; link fade/size feel.

## TargetSC 0.14.3 unified Test4.3 — optional world frame cadence (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (native 0.9.0 unchanged). Author: A.

**User decisions:** the animated white→color shift (stage 2's second half) and the cycling opener disc (stage 4) are no longer needed: the stacked opener discs already appear to shift colors as they rotate under each other. Stage 3 stays on hold (and conflicts with the recorded design principle). Asked whether the world-animation smoothing affects performance and wanted it optional so nothing working changes.

**Change:** `//tsc frames classic|even|full` (stored outside the visual presets; default classic = previous `now+1/30`). `even` advances a fixed 1/30 s grid with a 2 ms jitter tolerance so a 60 fps client updates exactly every other frame; same CPU as classic. `full` rebuilds every game frame (roughly double the Lua work at 60 fps).

**Host verification (not FFXI):** full suite PASS; `test_addon.lua` measures commits over 2 s at 60 fps: full ≥119, even exactly every other frame (one 1/30 s gap value), classic ~30 Hz; unknown mode rejected. **Live pending:** compare classic vs even (and full) on Cioara and while multiboxing.

## Design principle stated by the user (2026-11-17)

**Live feedback on Test4.1/4.2:** "the opener now animates so beautifully … the timing for those comet trails just right"; no settings changed. Settled on `opener discs outline 0`.

**Principle (user's words, summarized):** each layer means one thing. The **glyphs and MB ring** represent only an MB opportunity. The **skillchain rings** represent the resonance of skillchain properties, and those properties are represented by the **property disc colors**. So the opener (no MB possible) shows an incomplete skillchain with an open window resonating its properties' colors, with no glyphs. Future changes should keep each layer to its meaning; e.g. putting a glyph on the white awakening disc (stage 3, on hold) would conflict with it.

**Performance note given:** a layer at 0 opacity is skipped in Lua before reaching the native renderer (and native also skips zero-alpha lines), so `outline 0` costs the same as removal. Rough budget: disc fill 64 triangles, glyph lines ~175, full ring 128, opener arc 64; a busy three-property opener is ~2–3k triangles. Per-client cost is mainly Lua frame building at 30 Hz. **Possible later smoothing:** the world renderer's 30 Hz animation update uses `now+1/30` (the same drift pattern fixed in the HUD in Test3.1), which can alternate 2- and 3-frame steps at 60 fps.

## TargetSC 0.14.2 unified Test4.2 — opener discs outline (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only over Test4.0/4.1 (native 0.9.0 unchanged). Author: A.

**Request:** add `//tsc opener discs outline`; keep moving the glyph to the white disc (stage 3) on hold.

**Change:** `opener discs outline <0-1>|same` sets the glyph line opacity of opener property discs only; default `same` (stored as −1) follows `discs outline` exactly, so nothing changes until set. Links unaffected. `preset killala` → same.

**Host verification (not FFXI):** full suite + new `test_opener_outline.lua` (both MB styles: default identical to before, 1 raises and .1 lowers opener line alpha, link lines unchanged; command range, `same` reset, size unaffected, killala) PASS. **Live pending:** opener glyph line strength over the new section arcs.

## TargetSC 0.14.1 unified Test4.1 — opener spin slowdown and minimum (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only over Test4.0 (native 0.9.0 unchanged). Author: A.

**User feedback:** Test4.0 sections look good. Asked how the opener spin is animated and wanted it not to slow so much. Explained: constant `discs speed opener × discs speed` through the wait, then `(1−t)^discs slowdown` across the window to a full stop (cube: 42% a quarter in, 12.5% halfway, <2% at three-quarters). Also asked about glyph-line alpha on opener discs: `discs outline` (all stages; no opener-only control yet). User may keep the glyph lines on opener discs, so stage 3 (moving the glyph to the awakening disc) is on hold pending their decision.

**Change:** opener-only `opener spin slowdown <0-4>` (default 1; 0 = never slows) and `opener spin minimum <0-4>` (default .5, in `discs speed` units, capped at the opener's own speed): after the window opens the speed eases from full to the minimum along (1−t)^slowdown, integrated analytically. Applies to everything using the opener rotation (section arcs, rings, opener property discs). Links unchanged. `preset killala` → 3 / 0 (identical to before).

**Host verification (not FFXI):** full suite + new `test_opener_spin.lua` (legacy 3/0 matches an independent copy of the old formula at eight times; full speed in the wait, halfway = minimum + half, reaches minimum at close; far faster than before late in the window; slowdown 0 constant; minimum capped; continuous at open/close; links identical; commands; presets) PASS. **Live pending:** feel of slowdown 1 / minimum .5; try slowdown 0.5 or 0.

## TargetSC 0.14.0 unified Test4.0 — opener sections (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. **Includes a new native DLL (0.9.0).** Author: A.

**Design agreed with the user (2026-11-17):** the opener's properties share the circle as equal sections with gaps of 90° (one property), 60° (two) or 30° (three). Inside a section there is one arc per element, at the same radius and stacked by height like level-2 strands (`opener spacing`). Single element: one arc. Two elements: two arcs, each leading in its own color and trailing into the other; game order with the first-listed element on top (Fusion: Light above Fire). Light/Darkness: four arcs (one per element) with white or black heads trailing into Fire/Wind/Lightning/Light or Earth/Ice/Water/Dark; the dark glow stays. Arcs keep the bright-leading-end fade. Staggering nested groups was discussed and superseded by sections. Arc shortening near the window end was **not** wanted; the user clarified they meant the existing white-to-color shift (rings start white with a .3 s pulse and turn to color over two-thirds of the wait), which stage 2 will tie to the awakening disc.

**Remaining stages (agreed, not yet built):** (2) arc fade grows as the white disc fades, and the white→color shift follows the white disc; (3) property discs lose glyph lines during the opener and the awakening disc shows the glyph, spinning with the rings; (4) one opener disc cross-fading between each property's look (single: solid; two-element: its blend; Light/Darkness: white/black center to a rim of four element colors via the new hub color).

**Changes (stage 1):** native `native.arc` (start/span, lead→tail color and alpha along the shaped fade), optional disc hub color (stage 4 groundwork), ring limit 32→64 with storage check updated. Lua `opener layout sections|rings` (default sections), `opener spacing <0-0.2>` (default .035); context now carries element lookups and the DLL level; DLLs older than 0.9.0 fall back to the previous gapped rings. `preset killala` → rings.

**Host verification (not FFXI):** 0.9.0 `-Werror` build; property tests incl. arc_color/arc_shape (lead end, tail rgb at tip, fade alpha, trail flip, length holds lead) PASS; full suite PASS (Test3.8's fade test pinned to the rings layout); new `test_opener_sections.lua` (gaps 90/60/30 and equal sections for 1–3 properties, 1/2/4 arcs, two-element lead/tail swap with Light-led arc on top, stack spacing, Light white heads with all four element tails, Darkness black heads, fade/glow follow and black glow, sky arcs, rings/killala/0.8.0 fallbacks, links unaffected, worst case Light+Darkness+Fusion = 32 strokes ≤ 64, commands) PASS. **Live pending:** whole look on 1/2/3-property openers (`preview opener Liquefaction,Fusion,Light`), stacking height, colors after the white shift. Close all clients before replacing the DLL.

## TargetSC 0.13.9 unified Test3.9 — previews on yourself (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only over Test3.8 (native 0.8.0 unchanged). Author: A.

**Notes:** Test3.8's zip was built but not sent in the first reply; delivered on request. User asked to allow previews to draw on self as target.

**Change:** previews draw on your own character when you target yourself or have nothing targeted, or with `//tsc preview self [scenario]` (`me` also accepted). A self preview keeps drawing on you if you target something else meanwhile; it ends with `preview off` or when it completes. The native renderer already resolves any entity by index; only the Lua enemy-only gate applied to previews. Live resonance still only ever selects living enemies (unchanged `selected_mob`).

**Host verification (not FFXI):** full suite PASS; `test_addon.lua` adds self-preview checks (no target → self; persists while targeting an enemy; enemy target → enemy; `preview self` forces self; self-targeted → self; nothing drawn on yourself after preview off). **Live pending:** placement/scale on your own model (player model size), self preview while moving.

## TargetSC 0.13.8 unified Test3.8 — opener arc fade (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. **Includes a new native DLL (0.8.0).** Author: A.

**User feedback:** Test3.7 looking good; has settings that may become new defaults (to be supplied). Approved the proposed opener arc gradient design and commands.

**Changes:** native `lua_ring` takes optional fade (0–1), length (.1–1), curve (.5–3) and bright-end direction (±1), args 13–16; on gapped (open) arcs each of the 33 points per arc scales its alpha from 1 at the bright end to 1−fade at the tip over the far `length` fraction, shaped by `curve`. Lua sends them only for gapped opener ground/sky rings with fade > 0; "lead" = +1 because openers rotate toward increasing angle, so the end facing the spin stays bright. The opener glow band uses fade × `opener_fade_glow`. Commands: `opener fade <0-1>` (default .6), `opener fade length <0.1-1>` (1), `opener fade curve <0.5-3>` (1), `opener fade lead|trail` (lead), `opener fade glow <0-1>` (1). Lua accepts DLL 0.8.0/0.7.0/0.6.0/0.5.0 by level; older DLLs never receive fade args and draw even arcs. `preset killala` → fade 0. Also tidied a stray comment that an earlier edit had copied into the killala table (no value change).

**Host verification (not FFXI):** 0.8.0 `-Werror` DLL build; property tests incl. arc_fade (off, lead/trail ends, tip = 1−fade, length holds the bright 60%, monotone, curve ordering) PASS; full suite PASS; `test_addon` asserts a 0.5.0 DLL never receives fade args; new `test_opener_fade.lua` (cores and glows faded, all options flow, glow 0 leaves glow even, fade 0 / no gap / killala / links send nothing new, command parsing and ranges, presets) PASS. **Live pending:** default .6 lead look while spinning; length .4–.6 and curve 2; trail for comparison; glow follow. Close all clients before replacing the DLL.

## TargetSC 0.13.7 unified Test3.7 — awakening fade until (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only over Test3.5/3.6 (native 0.7.0 unchanged). Author: A.

**Request:** `//tsc awakening fade until default|window|…|1-9`: default = current; window = as the window opens; (fading until the end of the skillchain window); 1–9 = that many seconds after the window opens. The request named "until window" twice with two meanings; implemented as `open` (alias `window`) for the opening and `close` for the end of the window.

**Changes:** the grow stays over the first third of the wait; the fade now runs from there to the chosen end: `default` (two-thirds of the wait, bit-identical to before), `open` (exactly at the real window opening), `close` (the opener's own window end, stored on the opening glyph and refreshed while the opener is current), or `N` seconds after opening, **capped at the window end** because the whole opener display clears after it. If a link lands while the disc is still showing, it fades out continuously over 0.3 s; because the link's large MB glyph takes over the pooled shape, the lingering disc is drawn as its own fill disc (same radius/size, center/edge fade). The default can never overlap a link, so it is unchanged. `preset killala` → default.

**Host verification (not FFXI):** full suite + new `test_awakening_until.lua` (default matches the previous formula at seven times and is gone at two-thirds; open/close/1/5/9 end exactly on time, 9 capped at window end; grow identical in every mode; no jump when a link lands, fading through .3 s and gone at .3 s; command parsing incl. `window` alias and rejects 0/10/2.5/text; fade numbers unaffected; killala) PASS. **Live pending:** compare `open` vs `close` vs a few seconds; check the hand-off when a link lands during a lingering fade.

## TargetSC 0.13.6 unified Test3.6 — opener property-disc fade and size (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only over Test3.5 (native 0.7.0 unchanged). Author: A.

**Questions answered:** `awakening opacity` (0.3) is multiplied by global `opacity` (0.27), so ≈8% at the disc center; 1 caps at ≈27% unless global opacity rises. Awakening timing: the pre-window is each ability's delay (3 s for most weapon skills); the disc grows over the first third, fades over the middle third and is gone at two-thirds (≈1 s before the window on a 3 s opener). Proposed (not built, awaiting choice): `awakening fade until window` (default; fade ends exactly at the real window opening whatever the delay) plus `awakening fade until <seconds>` for a fixed time.

**Request implemented:** opener-only controls for the property-disc **fill**, glyph lines unchanged: `//tsc opener discs fade <inner 0-1> <outer 0-1>` (both required; multipliers of current fill opacity; 1 1 = unchanged) and `//tsc opener discs size <0.2-2>` (1 = current). Clapper path resizes the separate fill disc only; the classic path splits fill and glyph lines only when a custom value is set. Defaults send exactly the previous discs (no radial fields). Links and later stages untouched. `preset killala` → 1/1/1.

**Host verification (not FFXI):** full suite + new `test_opener_discs.lua` (both MB styles: defaults untouched, fill fade/size per opener property, glyph line discs keep size and carry no radial, link discs unchanged, command parsing/range, killala) PASS. **Live pending:** try `opener discs fade 0.2 1` (edge-bright), `fade 1 0` (center-bright), `size 1.2–1.5`.

## TargetSC 0.13.5 unified Test3.5 — awakening disc fade and size (2026-11-17)

**Branch:** `development/targetsc-mb-rise-gradient`. **Includes a new native DLL (0.7.0).** Author: A.

**Discussion (2026-11-17, questions before changes):** user asked about radial opacity on single-element discs, center/edge opacity on glyph outlines, and a fading end on opener arcs; all three need native support. Then described the opener as it stands (awakening white disc grows over the first third of the pre-window and fades over the middle third at awakening_opacity × opacity ≈ 8%, unchanged by Test3; property discs fade in over the first fifth at opener speed; opener rings muted, two gapped arcs, black glow, drawn at 78% before the window and 95% after — an instant step). Answered: breath opacity = `mb idle` .1 × `mb breath gain` 3 × breath (.35–1) × `mb overall` .66 ≈ 7–20%; a confirmed MB holds .6 s and lands over 2 s (~2.6 s); pausing the upper sigil during MB would desync the rings since Test3.2 (choose: rings pause too, or sigil pauses then eases back into step); radial/arc fades can be animated per frame from Lua at no native cost. Proposed series (later): large glyph grows with the awakening disc and spins with the arcs; plain opener discs (fill-only, edge-bright, separate inner/outer controls); opener arc fade with bright leading end and matching glow band; darker opener glow before the window opens; sigil pause during MB. Smoothing suggestions: ease the 78%→95% opener-ring step, crossfade the 0.16 s white link strike, fade out extra opener property discs at the first link.

**Request implemented now (only):** `//tsc awakening fade <inner 0-1> [outer 0-1]` — center and edge multipliers of the current awakening opacity, outer defaulting to 0; `//tsc awakening size <scale>` with 1 = current size.

**Changes:** native `lua_disc` takes optional inner/outer fill-alpha multipliers (args 12/13; default 1 keeps 0.6.0 output), applied to hub and rim vertices on both fill paths. Awakening disc carries `inner`/`outer` (defaults 1/0 = center at current opacity, transparent edge); `awakening_size` scales its radius throughout the grow/fade. Lua accepts DLL 0.7.0, 0.6.0 or 0.5.0; older DLLs never receive the radial args and draw an even fill at the average opacity. `preset killala` restores 1/1/1. No other visuals changed.

**Host verification (not FFXI):** mingw `-Werror` 0.7.0 DLL build; property test (scale_alpha) PASS; all prior simulations PASS; `test_addon` asserts a 0.5.0 DLL never receives radial args; new `test_awakening_fade.lua` (defaults 1/0, killala 1/1 with identical base opacity, size at four moments, radial only on the awakening disc, fallback alpha, command parsing incl. optional outer and range errors, opacity/toggle unaffected, presets) PASS. **Live pending:** default fade look; try `awakening fade 1 0.3`, `awakening size 0.8/1.3`. Close all clients before replacing the DLL.

## TargetSC 0.13.4 unified Test3.4 — smoother MB burst glows (2026-11-16)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (native 0.6.0 unchanged). Author: A.

**User feedback:** loves Test3.3; firm feels better for both rings and discs. Supplied current `settings.xml`: Cioara overrides `disc_blend`/`ring_blend` firm, `disc_speed` .12, `disc_speed_level4` 1, `mb_glyph_rise` .3, `mb_glyph_tint` .6, `opener_gap` 60, `ring_shade` .6. Reports that the elemental glows on the two glyphs during a confirmed MB look chunky; asks for the ring lit-side treatment and a spin faster/slower than their glyphs; approved all three proposed parts.

**Cause:** each burst glow was one even-brightness band 10–12 px wide with a 9 Hz decaying flicker, with no visible rotation.

**Changes:** `mb glow shade` (.5) gives both burst glows a lit side using the current `rings blend` mode (gradient or firm; split keeps them even). `mb glow spin` (turns/sec, −2..2, default .5) is added on top of each glyph's own angle (large glyph's slow reverse spin; trace's disc rotation), using a continuous clock so re-strikes do not jump. `mb glow flicker` (1 original, 0 steady) scales the 9 Hz ripple; `mb glow width` (.2–2, default 1) multiplies thickness. Flicker/width defaults keep the previous look. `preset killala` → shade 0, spin 0.

**Host verification (not FFXI):** full suite plus new `test_mb_glow.lua` (lit side in gradient/firm, split/shade 0 even, exact added spin for ±/0 on both glyphs, flicker 0 monotone vs ripple at 1, width multipliers, commands, killala/default) PASS. **Live pending:** compare glow smoothness with shade/spin, try flicker 0–.5 and width .6–.8.

## TargetSC 0.13.3 unified Test3.3 — firm blend option (2026-11-16)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (native 0.6.0 unchanged). Author: A.

**User question/request:** current stage speeds were listed (global .1 × opener 4 / L1 2 / L2 3 / L3 4 / L4 0 turns/sec; minimum .5 → .05; per-stage max 4, raise `discs speed` to go further). User asked whether gradients could hold each side's own color longer with the fade concentrated where the colors meet ("harder"/"sharper" transition, narrower falloff); chose to feel out the Lua-only four-stop approach first.

**Change:** `rings blend firm` and `discs blend firm` send A,A,B,B four stops with the native gradient, so each color holds pure for about a quarter turn and the fade occupies the two quarters where they meet. With shading, firm rings carry a lit half: A+ | A | B- | B (single-color rings: bright half/dim half). Strand order and openers unchanged. On a 0.5.0 DLL firm falls back to plain halves. A continuous native hardness slider remains a possible later DLL batch.

**Host verification (not FFXI):** full suite + `test_ring_blend` firm checks (four stops, A,A,B,B, opposite strands preserved, firm disc, lit side, openers split, commands) PASS. **Live pending:** compare `rings blend gradient` vs `firm` and `discs blend gradient` vs `firm`.

## TargetSC 0.13.2 unified Test3.2 — rings turn with the disc, lit side, MB ring settles (2026-11-16)

**Branch:** `development/targetsc-mb-rise-gradient`. Lua-only (native 0.6.0 DLL unchanged from Test3.1). Author: A.

**User feedback/requests:** opener gap 60 is enough (no change). L2 gradient rings no longer seemed to spin with the upper glyph. Explanation given: the rotation itself was unchanged, but the smooth gradient removed the hard color edges that made the spin visible, and since Test8 the disc eased to its minimum speed while rings slowed to zero, so they drifted apart. Requests: rings rotate at each stage's set speed, easing toward the minimum so they match the disc/glyph; give levels 1, 3 and 4 rings rotation plus a slightly brighter/dimmer side; same visible link for L2 gradient rings; an option for the glow to spin twice as fast; the closing three pulses are the MB ring and large breathing glyph (confirmed) — lower the MB ring toward the large glyph during the end of the MB window.

**Changes:** `ring_spin='disc'` — all non-opener SC rings use the property disc's rotation (`discs speed levelN`, easing to `discs minimum` through MB; with display `sc` both fall back to the original slow-to-stop). Level 4 default speed is 0, so its rings stay still unless `discs speed level4` is raised. `ring_shade=.25` — ground/sky rings and glows get a brighter side and an opposite dimmer side via the native alpha gradient (single color: bright/dim; two colors: A+ | mid | B- | mid, preserving each strand's order). `ring_glow_spin` multiplies glow rotation (default 1). `mb_ending_drop=1` — during the ending interval the MB ring smoothly settles from its height to the large glyph's resting plane (same radius), reaching it at the real deadline. Openers are untouched. `preset killala` restores `classic`/0/1/0. New commands: `rings spin disc|classic`, `rings shade <0-1>`, `rings glow spin <0-4>`, `mb ending drop <0-1>`.

**Host verification (not FFXI):** all prior simulations and C++ tests PASS; `test_ring_blend` pinned to shade 0 for its structural checks; new `test_ring_spin.lua` (L1/L2/L3 rings share the disc angle through the window and keep turning near the deadline, classic restore, lit side for 1- and 2-color rings, shade 0, openers unchanged, glow ×2, MB ring lowering and drop 0, commands, killala/default) PASS. **Live pending:** spin visibility and step with the glyph at each level; lit-side strength; glow ×2 comparison; MB ring settling during soft/hard endings.

## TargetSC 0.13.1 unified Test3.1 — HUD freeze fix and gradient SC rings (2026-11-16)

**Branch:** `development/targetsc-mb-rise-gradient`. **Commits:** `ccf7b49` HUD freeze fix, `4b64ea0` gradient rings, plus this record. Author: A.

**User feedback on Test3 (live):** likes the changes; the opening HUD animation is much smoother, but the countdown pauses as it begins counting down, apparently in response to a new skillchain or MB, when it should keep counting and animating. Likes the blended discs; requests blended SC rings (ground and sky), noting level-2 strands are oriented in opposite color directions; openers keep two-part rings because of their gaps.

**Cause of pause (Test3 regression):** each every-frame render during the smooth period advanced the 30 Hz grid by 1/30 s, so after ~2 s at 60 fps the next scheduled frame was seconds in the future and the HUD stopped drawing until real time caught up. Every new opener/link on any target re-armed smoothing. **Fix:** the grid advances only on due ticks and is never scheduled more than 1/30 s ahead. The strengthened `test_hud_cadence.lua` reproduces the freeze on the Test3 code (6 frames in 2.5 s) and passes after the fix, including after another target's skillchain.

**Gradient rings:** native ring call takes an optional 12th `blend` argument; each closed-ring vertex takes the blended color at its own angle, in the same order and direction as the split sectors it replaces, so the two level-2 strands keep their opposite orientation and ground/sky strands match. Glow bands follow. Opener ground/sky rings are always split (even with `opener gap 0`). Level 3/4 rings are single-color strands and look unchanged. `//tsc rings blend gradient|split` (default gradient); `preset killala` restores split. The 0.5.0 DLL receives the same four-step fallback as discs. Disc rims now sample the gradient at exact vertex angles (half-slice correction).

**Host verification (not FFXI):** DLL `-Werror` build, property/stroke tests, Lua 5.1 parse, all prior simulations, `test_glyph_rise`, `test_hud_cadence`, new `test_ring_blend` PASS; the addon mock asserts a 0.5.0 DLL never receives either gradient flag. **Live pending:** HUD never pauses through openers, links and MBs (including other characters' SCs); L2 ring gradients from ground and sky views; opener rings unchanged; DLL replacement needs all clients closed.

## TargetSC 0.13.0 unified Test3 — MB glyph rise, gradient discs, smooth SC opening (2026-11-16)

**Branch:** `development/targetsc-mb-rise-gradient`, based on the newly promoted `master` (`9476226` = known-good Test2 `9c9106f`). **Commits:** `3394f9d` native 0.6.0 gradient, `232366f` MB glyph/intro/blend/killala, `9a5f32b` HUD cadence + positions, `76c0309` version/CI, plus this record. Author: A.

**User requests (2026-11-16):** (1) the lower, larger glyph should rise to the MB ring height or slightly above, stay white, and fall back together with the upper (property-trace) glyph unless interrupted by another MB; (2) perhaps a dimmer glyph for the opening (new MB) window; (3) test against Killala presets, list all presets, keep Cioara's settings if different; (4) gradient dual-element discs instead of split halves; (5) smoother SC first-step opening (white bar sweep feels low-framerate); (6) a default-position preset for SC elements from Cioara's settings; (7) push the snapshot to main as the trusted version.

**Findings.** The supplied `TargetSC-snapshot-2026-11-16.zip` is byte-identical to `9c9106f` for every source/doc/asset; it adds CI-generated icons, `BUILD_MANIFEST.json` and personal `data/`. Cioara's saved `data/settings.xml` (global profile) equals the Killala defaults in every visual key, so no separate TargetSC preset was needed; `killala` covers both. Cioara's HUD (`skillchains-settings.xml`, `<cioara>`) overrides bar 1490,60; MB custom 1489,54 width 445, icon/text off; learning 1050,2100; display both. Cause of (5): the HUD throttle used `next=now+1/30`, so a 60 fps client alternated 2- and 3-frame gaps; the 1 s smoothstep sweep over a 310 px bar then jumped unevenly (~15/23 px).

**Changes.** Clapper glyph burst height = rest + (MB-ring − rest) × `mb_glyph_height` (1.1) × the same return energy as the trace lift, with a `mb_glyph_rise` (.15 s) ramp that carries the previous burst's height on a re-strike. Glyph color mixes toward the element only by `mb_glyph_tint` (0), and its shimmer follows. Intro flash is scaled per layer by `mb_intro_glyph` (.5) / `mb_intro_disc` (1). Native 0.6.0 accepts an optional 11th `blend` argument; gradient rims smoothstep between sector colors with an averaged hub (Gouraud shading); Lua accepts 0.5.0 or 0.6.0 and approximates with A|mix|B|mix sectors on 0.5.0. HUD renders every frame for max(2.2 s, delay+.6 s) after an opener/link, otherwise on a fixed 1/30 grid; `//tsc sc smooth off` restores 30 Hz. `//tsc sc positions default|cioara`. New settings merge into saved data; nothing is reset.

**Host verification (this environment, not CI, not FFXI):** mingw i686 `-Werror` DLL build and portable property tests (incl. new gradient math) PASS; Lua 5.1 parse of all files PASS; all 17 existing simulations PASS (three were pinned to the Killala/pre-Test3 values via `historical_defaults.lua` and `R.killala`, preserving their original assertions); new `test_glyph_rise.lua` (peak above ring, white, synced landing with trace, no dip on re-strike, tint/height fallbacks, dimmer intro, gradient flag, ARGB fallback, commands, killala/default presets) and `test_hud_cadence.lua` (every-frame sweep and transition at 60 fps, even 30 Hz afterwards, smooth off, position presets) PASS; `test_addon.lua` now asserts a 0.5.0 DLL never receives the gradient flag. Package `TargetSC-Unified-0.13.0-Test3.zip` builds and validates. GitHub Actions should rerun on push.

**LIVE FFXI pending:** `//tsc preview mb` with default, then `//tsc preset killala` for comparison; check glyph reaches ~ring height and lands with the trace; two quick bursts; intro brightness; Fusion/Distortion/Fragmentation gradient after DLL replacement (and fallback look before); SC opener sweep smoothness at your frame rate; `//tsc sc positions cioara` on Cioara and `default` elsewhere; multibox CPU cost of every-frame sweeps. **Install:** close all clients before replacing the DLL; preserve `TargetSC/data/`.

## Promoted to master — 2026-11-16

The TargetSC unified Test2 build (`9c9106f`, ~~tag `targetsc-0.12.1-test2-known-good`~~ **Correction (2026-11-16):** the tag push was refused by this session's connection; the marker is branch `known-good/targetsc-0.12.1-test2`) was compared against the user's 2026-11-16 installed snapshot: every source, doc and asset file is byte-identical (the snapshot additionally contains CI-generated `images/mb_flash`, `images/terminal`, `BUILD_MANIFEST.json` and personal `data/`). At A's request it is now `master`, the trusted known-good version. Master's earlier docs-only history is preserved at the end of this file.

## TargetSC unified Test2 — AoE and learning HUD (2026-11-11)

**Automated verification passed:** [GitHub Actions run 43067931891](https://github.com/rerorriM-Mirrorer/Skillchains/actions/runs/43067931891), from commit `9b200fc`. Native x86 DLL build, portable renderer geometry, HUD artwork generation, Lua 5.1 syntax, existing HUD/bell regressions, actual combined-loader simulation, new multi-target Uriel/missed-hit/Myrr/confirmed-SC tests, helper-only presentation tests, one-folder ZIP integrity and publication all **PASS**. All of these are compilation or host simulation, **not live FFXI testing**. The unified Test1 ZIP and branch remain available for rollback. Full live SC/MB timing and GripRumble parity are outstanding.

User observations: on **Cioara's client**, GripRumble's long *SC-window*
vibration fires for Valaineral's Uriel Blade, but a second successfully hit
enemy may have no TargetSC rings after target switching. Myrr's Shining Strike
has also sometimes lacked rings while Cioara is observing. This is stronger
evidence than a generic damage-vibration cue.

**Source finding:** The embedded Skillchains combat handler used the first
target *and its first subaction* only. Both Uriel Blade (including monster
abilities 2273/3202) and Shining Strike (WS 160, Impaction) already exist in
skills.lua; no new arbitrary skillchain properties were added. Test2 now
iterates each target and action, accepts only qualifying landed actions,
prefers confirmed SC additional effects over opener reports, and shares
consumable action buffs across AoE targets rather than re-consuming per target.
It still uses the original SC and provisional MB timing rules.

**Display request:** `//tsc sc mode learn` and `//tsc sc display off` hide
the SC and MB HUD ribbons while retaining the helper/learning box for open
continuation windows. `display both` restores the ribbons. `//tsc sc trace on|off`
temporarily records per-target combat classification for investigation.
No visual presets or character settings are reset.

**Host tests:** New integration simulation covers Valaineral-style multi-target
Uriel Blade (first target missed, two subsequent valid), Myrr-style external
actor Shining Strike, Shining Strike misses, SC effect precedence, and
renderer resubscription. New UI simulation tests helper visibility with both
ribbons disabled, reenabled, expired, and compact. Automated CI results to be
recorded after successful build.

**FFXI pending:** Reproduce Uriel on different target IDs, watch Myrr's actual
Shining Strike packet from Cioara, compare open window haptic vs bell,
test helper-only during SC and MB periods, and verify no false resonances on
missed attacks. The exact GripRumble code is not in this repository; its
independent target tracker cannot prove identical observations by the two addons.

## TargetSC unified Test1 — green host verification (2026-11-10)

**Verified commit:** [`a941b82`](https://github.com/rerorriM-Mirrorer/Skillchains/commit/a941b82976b214f2466e61398da59c41a4c4346b). **GitHub Actions:** [run 42964264172](https://github.com/rerorriM-Mirrorer/Skillchains/actions/runs/42964264172) completed successfully.

- Lua 5.1 syntax validation of embedded and baseline files: **PASS**.
- x86 native renderer rebuild and portable geometry tests: **PASS**.
- HUD art generation and validation: **PASS**.
- Existing Skillchains HUD/demo and TargetSC animation regression simulations: **PASS**.
- New local publisher/receiver bridge test with states, burst, resync, zone and unload: **PASS**.
- New single-process, actual-entry/runtime loader simulation: **PASS**.
- Missing or incompatible native module with independent HUD stub: **PASS**.
- One-folder TargetSC ZIP creation, artifact publication, manifest, required modules, no shipped personal settings and PNG integrity: **PASS**.
- **Unverified:** Actual FFXI/Windower rendering, real combat timestamps, imported character settings on disk, graphics compatibility, multibox performance, install-and-restart behavior. The standalone two-addon transport regression remains historical; it is not a valid loader test for this merged build.
- **Delivery:** GitHub Actions artifact `TargetSC-Unified-0.12.0-Test1` at run 42964264172. Requires unloading standalone Skillchains and preserving both prior data folders. Native DLL replacement requires clients closed.

**2026-11-10 integration CI correction:** The original `test_transport.lua` deliberately loads two isolated Windower addon environments and is no longer an appropriate Test1 merged-load test. Keep it in history for standalone pair regression; the unified workflow runs the direct event test `test_local_bus.lua` instead. `test_missing.lua` now stubs only the embedded SC engine so it can continue testing the actual TargetSC error path without requiring a real Windower action listener. Native build, asset generation, and Lua parsing already passed before this correction. Live FFXI still untested.

**Unified-loader smoke test:** A new host simulation now loads the real `TargetSC.lua` and embedded `sc_runtime.lua` in a single Windower-like Lua environment, stubbing only native drawing and game/HUD APIs. It verifies one command dispatcher and action listener, direct SC/MB state propagation, unchanged deadlines after resync, independent renderer on/off, zone cleanup and zero inter-addon command dispatch. This remains host simulation, not actual FFXI testing.

## TargetSC 0.12.0 unified Test1 — in-process merger (2026-11-10)

- **Branch:** `development/targetsc-unified-test1`, based on the preserved
  `development/targetsc-white-breath` Test11.1 build (`6bfbc7b`).
- **Scope:** Embed the exact Skillchains Animation8.8 runtime as
  `TargetSC/sc_runtime.lua` with only initialization, settings-path,
  command-routing and in-process transport adaptations. Bundle its HUD,
  learning modules, and artwork in the single installable TargetSC directory.
- **Behavior:** TargetSC is the sole Windower addon. Existing `//tsc` bell
  commands continue; legacy HUD commands use `//tsc sc <command>`. Preserves
  source deadlines, rendering code, visual defaults, native API 0.5.0 and
  per-target bridge-v1 frame semantics. No standalone Skillchains is required.
- **Configuration:** TargetSC `data/settings.xml` is unchanged. The embedded
  HUD loads `data/skillchains-settings.xml`, importing a previous
  `../Skillchains/data/settings.xml` only when destination is absent.
  Source files and personal settings are never overwritten.
- **Verification:** Require Lua 5.1 parse checks, direct callback+actual
  bridge state/burst/reset tests, existing native/renderer/HUD suites, source
  regression, ZIP manifest/assets/licensing checks and x86 compilation.
  Record CI run outcome separately from live FFXI.
- **LIVE TEST PENDING:** Install with standalone Skillchains unloaded; confirm
  real weaponskill opener/extension, burst, SC/MB bar, learning panel,
  target change, job change, death, zone, logout/login, reload, multibox
  and settings persistence. Compare with a separate known-good client.
- **Rollback:** Restore the two original addon folders/data backups and load
  Skillchains and TargetSC from the known-good paired package. Do not replace
  the old DLL while clients are running.

## TargetSC 0.11.1 Test11.1 — white breathing glyph (2026-10-22)

Branch `development/targetsc-white-breath`, based on Test11 `0ba8176`. A reports the large breathing glyph gets lost during demo level-two Gravitation. Diagnosis: Test10 extended the requested MB ring color cycling to the glyph too; its dark-purple/earth palette combined with roughly 7–20% breathing opacity and overlaid property fill makes it hard to see. A asks to revert only the large glyph's ordinary color. Restore white between confirmed bursts at all levels; preserve MB ring palette cycling, elemental MB overlays, bloom/return, rotation, opacity and all Killala defaults. No new setting or user-data change.

Host checks: existing Lua 5.1 bloom/descent, clapper and addon simulations; direct four-level-two-property frame checks confirm white idle outlines, continued MB ring cycling and full elemental strike/white return. Cumulative Lua patch includes WORKFLOW/TESTING/README inside TargetSC and needs only a reload. Package guards protect native 0.5.0/HUD bytes. Live appearance needs in-game confirmation; previous testing history follows.

## TargetSC 0.11.0 Test11 — layered bloom and descent (2026-10-22)

Branch `development/targetsc-bloom-descent`, based on Test10.1 `b4e29af`. A requests the complete effective global + Killala profile from settings(20261022-164147).xml as hardcoded visual defaults, and only two behavior changes: immediate full expansion/lift of the breathing glyph returning alongside the small trace, and signed SC descent shaping. Snapshot display is both, MB overall .66, opacity .27, MB expansion 0, rise .01, hold .6, return 2 and duration .9. Preserve even zero expansion; do not force an expansion override or reset any user's saved data. No personal XML shipped. Existing earlier snapshots/requests below remain historical.

Large clapper glyph overlays the same property-response energy on its continuously running breath, rotation and base palette. Initial geometry reaches full configured rise/expand (subject to mb effects); hold is max(mb hold,.375×mb duration), followed by mb return. No fade-out/recovery replaces the underlying breath. Subsequent MBs re-strike the full peak; property switches retain the existing response timeline and white announcements. Classic keeps its earlier trajectory. Steady MB ring, property motion, flash/ending priority and source clocks are preserved.

Signed sky descent -4..4 remaps normalized post-hold presentation time; positive fast/slow, negative slow/fast, zero exact old formula. Existing hold and source endpoints, short windows and terminal behavior stay unchanged; radius still follows height through the bell profile. No invented continuation time.

Host verification includes dedicated Test11 tests for adopted values, peak geometry, shared quintic return, uninterrupted breath/rotation, repeated hits, property transitions, master/effects/burst suppression, floor independence, signed curve ordering/monotonicity/bounds, old-formula parity at 0, hold/endpoints/short windows and saved-command validation. Historical tests now use a pinned Test10.1 default fixture rather than silently assuming today's defaults; new addon tests and Test11 exercise current defaults. Run all Lua 5.1/native/transport/source-regression and package guard checks. Cumulative patch includes README/WORKFLOW/TESTING under TargetSC; DLL/native and Skillchains runtime stay byte-identical. Live FFXI appearance still needs acceptance.

## TargetSC 0.10.1 Test10.1 — steady MB ring (2026-10-22)

Branch `development/targetsc-steady-mb-ring`, based on Test10 `4ff91e2`. A reports the clapper pass feels more coherent, and requests a vertically stationary MB ring even on property changes, leaving the property disc's motion unchanged. Ring height now uses nominal property/floor anchors, independent of all vibration, transition blending, SC layouts and trace lift. A common .006 property-plane offset avoids a terminal-level height step. No new controls, settings reset or opacity-default change; the proposed .6/.66 master remains tuning under consideration.

Host checks: extended clapper test sweeps 18,546 frames across MB/both display and three SC layouts, including fresh-window strikes, sustained hum, four property transitions, late confirmed bursts and terminal Umbra. Assert steady MB-ring height while property disc continues moving. Existing clapper response, demo, addon lifecycle, motion, transport and Lua 5.1 checks remain required; package guards preserve HUD/native source and DLL. Native API remains 0.5.0. Cumulative Test10.1 Lua patch: merge TargetSC/ into addons, preserve data/, reload TargetSC. Live check: preview mb, watch fixed-height MB ring against moving property disc; verify breathing, flashes and endings still animate. No direct FFXI rendering test performed.

## TargetSC 0.10.0 Test10 — clapper response and MB demo (2026-10-22)

Development branch `development/targetsc-clapper-burst`, based on latest Skillchains Animation8.8 `010c93be`, incorporating TargetSC Test9 `4894b49f`. Author: A. Saved personal settings/data remain untouched. User requested expressive defaults with restraint controls, low MB clapper placement, synchronized nonzero breathing, slow reverse glyph rotation, immediate elemental strike/lift and a shared mathematical return; then requested the original four-link demo with one appropriate MB per window.

Install the cumulative Test10 Lua patch by merging its TargetSC/ folder into Windower/addons and `//lua reload TargetSC`; preserve data/. Native 0.5.0 is unchanged; no DLL replacement/restart. Complete paired install preserves Skillchains Animation8.8 runtime, assets, bridge and combat semantics. Source deadlines are unchanged. New settings merge into saved settings; resetting a visual preset is unnecessary.

New `//tsc preview mb` runs the same 0/9/17/24/30s sequence, inserting valid Wind/Earth/Water/Dark MBs at 12.6/23.8/29.8/38.8s. Original no-burst demo remains available. All events are local visual fixtures; no game actions or bridge publication. Late Earth/Water hits exercise transition interactions.

Host verification: Lua 5.1 parse/load and simulated addon command/native-sink tests; clapper geometry, shared breathing/cycling, independent reverse spin, immediate master-capped strikes, quintic simultaneous return, restraint controls, overlapping release continuity, selected-ending clipping and 4011 demo frames within 32 bands/8 discs. Historical Test5–9 fixtures explicitly select classic style/zero extra ground lift so their old assertions remain meaningful. Existing motion/transport/lifecycle and source-combat regression checks remain required. Package checks protect all Skillchains runtime and native source/DLL bytes, CRCs, SHA256 manifests, license/docs placement and exclusion of personal data. Native rendering and visual legibility still need live FFXI acceptance.

Live checklist: select enemy; run preview mb at preferred saved tuning; inspect both late-link transitions and Umbra trace return. Try mb lift .04, mb shimmer .25, mb breath gain 2 to restrain; compare mb style classic / ground lift 0; restore clapper / .04. Check display sc, mb, both and mb overall 0. Observe an actual confirmed burst, a natural MB ending and multiple clients. Radius/position are relative to saved floor geometry; unusual saved heights may intentionally invert the default ordering. Full command/default guide is at the top of README.

## Current development — Animation8.8 independent MB HUD and white intro (2026-10-21)

**Passing host checkpoint:** Commit `10d22a5` passed [GitHub Actions run 39587410187](https://github.com/rerorriM-Mirrorer/Skillchains/actions/runs/39587410187) on 2026-10-21. All Lua 5.1 files parse; simulated UI tests cover independent MB drag and Ctrl snapping, position persistence despite SC moves, separate MB font/icon/scale/width, visibility combinations, white alpha silhouettes on first and replacement windows, flash disable and fade to property color, MB-only lifetime and continued numeric clock through terminal Umbra/Radiance. Actual command-handler tests cover saved values and validation. Full unchanged TargetSC Test8 0.8.0 Lua/native/transport simulations, generated 14 MB white icon alpha-mask checks and package manifests passed. Artifacts: **Skillchains-only `12340791482`** (recommended), compatibility paired `12340611542`, unchanged TargetSC patch `12340976379`. Earlier development CI failures were test harness assumptions about MB's old attached position and terminal coloring, display-tenth rounding, and an omitted stub method; all were corrected before the green run. **No live FFXI visual acceptance yet.**

**Repo/branch:** `rerorriM-Mirrorer/Skillchains`, `development/skillchains-mb-independent-white-intro`, based on user-reviewed Animation8.7 `fa8b8b4`. TargetSC Test8 0.8.0 Lua, native 0.5.0 DLL and bridge remain unchanged.

**User feedback:** The SC ghost tip looks good, and the new MB ribbon looks good but overlapping texts reveal that it must be **fully independently draggable** with saved position/scale and separate caption/icon sizing/visibility. User wants an MB introduction/replacement flash to white as a transient transition, akin to TargetSC's MB state changes; white flash can be refined when TSC animations are finalized. **SC Level 4 black/white terminal animations must not touch MB**; MB timer must remain independently visible/readable and truthful throughout the terminal effect.

**Implementation:** Add independent `mb.x/y/width/scale/fontsize/iconsize/text/icon` values that safely merge with legacy MB gap/height/position and seed x/y relative to old SC once if missing. A draggable MB handle appears alongside SC and Learning in edit mode, with Ctrl-to-grid and viewport rescue; moving SC or resizing the SC bar doesn't alter MB. MB `position above|below` is explicit one-time alignment; free-drag sets custom. MB can show only fill, fill+text, fill+icon, or all; font/icon scaling independent from main SC. New MB flashes white via `1-smooth(age/flash_duration)` at the new/replaced MB window's source `created` timestamp; separate white-alpha silhouettes are generated from the 14 original property icons at build time. Flash only affects existing visible MB window and its own glow/fill/icon, not game packets or combat timers. MB no longer receives SC `terminal_color` / `terminal_mult`, neither from MB bars nor captions/icons; compact panel keeps MB status readable.

**Commands:** `//sc mb pos <x> <y>`, `mb center`, `mb position above|below`, `mb width <40..1600>`, `mb scale <.5..2.5>`, `mb height <1..6>`, `mb fontsize <6..24>`, `mb iconsize <6..32>`, `mb text on|off`, `mb icon on|off`, `mb gap <0..32>`, `mb flash on|off`, `mb flash duration <.05..1>`. `//sc edit on|off` reveals/hides both drag handles. User's SC fade period 0.24, optional L1 glow, saved SC positions, full 40s demo and earlier FX remain intact.

**Checks:** Lua 5.1 parse and command-simulation controls/validation; actual HUD mock tests of independent drag and grid, MB width/scale/fonts/icons, first/replacement pure-white bar and icon, normal palette after white transition, authentic MB-only tail, compact and learn terminal SC isolation; generated PNG alpha masks, complete TargetSC Test8/native/transport regressions and solo/pair package verification. **No direct in-game FFXI verification yet**; record final passing GitHub Actions run and artifact when available.

**In-game verification request:** Back up `Skillchains/data/`, install only new Skillchains folder, reload. `//sc display both`, `//sc demo`; MB transitions at 9s,17s,24s,30s should brighten white then settle, while SC tip/refills/Level4 remain unchanged. During Umbra confirm MB ribbon/color/icon/timer never inherit black SC fade. `//sc edit on`: MB has own draggable handle, Ctrl grid, saved coordinate; check narrow 960×540 client rescue and scale separate from SC. `//sc mb icon off`/`text off` independently, `mb fontsize`/`iconsize` produce expected relative sizes. Confirm TargetSC sync and later actual combat WS/MB behavior.

---

## Current development — Skillchains Animation8.7 Ghost tip / MB ribbon (2026-10-21)

**Verified host checkpoint:** Commit `9107495` passed GitHub Actions [run 39583635949](https://github.com/rerorriM-Mirrorer/Skillchains/actions/runs/39583635949): Lua 5.1 compilation, real HUD-renderer and command-handler simulations (tip, independent MB-only ribbon, above/below, controls, help colors), demo parity, *all latest TargetSC 0.8.0 Test8* tests/transport/native build, package/PNG/manifest validation. Published a **Skillchains-only** install artifact `12339441036`, paired compatibility artifact `12339486032`, and unchanged TargetSC Test8 Lua patch artifact `12338651447`. Earlier CI failures were test-fixture duplication from a source-string replacement, an inherited missing Pillow dependency, and a doubly escaped PNG signature check; each was corrected before this passing checkpoint. **These tests are host simulations and static checks, not direct FFXI visual verification.**

**Repo/branch:** `rerorriM-Mirrorer/Skillchains`, `development/skillchains-ribbon-endpoint-test1`, based on newest TargetSC Test8 `fa295295`. This branch contains the latest TSC 0.8 Lua/native 0.5 baseline but has **not modified any TargetSC runtime or bridge files**. Starting Skillchains Animation8.6 code from `3d96aea`; new version `2.20.08.25-resonance.7-animation.8.7`.

**User request and source basis:** Follow settled sequence: first small moving SC fill-end flare from supplied `ghost_flare.png` 64x16; then thin independent fill-only Magic Burst ribbon close to SC; then tune MB placement/text; redesign `//sc help` per WORKFLOW/BattleStations color standards. Latest TSC Test8 independently sustains property-disc lifetime through MB and gives MB its own slow breathing and closing signals. Use TSC for *visual vocabulary*, not reuse its world geometry or create dependencies. User likes Killala's 0.24s pulse, Level 1 glow, and terminal black/white finishes; preserve XML.

**Runtime implementation:** Tip samples exact user PNG with a white 1px core at the true SC fill endpoint, lightly blended toward last element color (notably dual elements), and subtly varying length/opacity. Active SC countdown only; hidden in white pre-continuation charge, terminal fades, when SC expires or display is off. MB is a separate 2px gradient ribbon of original MB fractional countdown with faint underlying glow but **no track/frame**; 2s slow brightness breathing and soft small final 0.6s triple pulse inspired by TSC Test8, without changing source deadlines or requiring TSC to be loaded. Default ribbon immediately below bar, anchored independently of SC label height; configurable above/below, gap, height, text. Preserve old SC bar, fill shimmer, tip and MB positions as one draggable parent bar; retain all settings and not silently change `display sc` to `both`.

**Commands:** `//sc tip on|off`, `//sc tip length <8..40>`, `//sc tip opacity <0..1>`; `//sc mb position above|below`, `//sc mb gap <0..32>`, `//sc mb height <1..6>`, `//sc mb text on|off`. Bare/invalid `//sc` now show chat-only color-coded help; `//sc status`, `//sc restart`, `//sc unload` are explicit. TargetSC commands unchanged.

**Developer checks:** Run Lua5.1 parse, full `tools/test_learning_ui.lua` and `tools/test_visual_commands.lua` (including tip/MB-only, no background/SC timer borrowing and help colors), `tools/test_skillchains_demo.lua`, TargetSC Test8 `test_mb_finish` and all other TargetSC native/packet compatibility tests. Package Skillchains-only folder with user-supplied `images/resonance/ghost_flare.png`, README/WORKFLOW/TESTING docs inside folder. CI dependency now installs `python3-pil` because upstream Test8 workflow failed its own icon-generation check without Pillow. **No direct FFXI rendering test performed.**

**In-game test request:** Back up `Skillchains/data/` and update only Skillchains folder. `//lua reload Skillchains`, `//sc display both`, `//sc demo`: verify SC ghost at endpoint on dark Gravitation/Darkness countdowns, but not during charge or on terminal Umbra; verify MB ribbon independently shrinking during SC prep and remaining for MB-only time; check `//sc mb position above` / `below` and small gap changes without moving the bar anchor. `//sc help` check colors and readability. Ensure `//sc targetsc`, `//tsc status` show sync; TSC Test8 ring/Magic Burst visuals should remain unchanged.

---

## TargetSC 0.8.0 Test8 — MB finish and sustained property glyph (2026-10-21)

Branch `development/targetsc-mb-final-pass`, based on Test7 `649752f6`.
A's final animation pass for now; all controls remain available for later tuning.
User's 09:14:40 Killala snapshot has speed .1, opener 4, L1 1, L2 3, L3 4,
L4 0 and slowdown 1. Preserve all saved stage speeds, opacity, sky curve/cutoff,
MB duration/ending length and other settings. Do not ship or rewrite personal XML.

Lua-only cumulative patch over working Test5–7: merge TargetSC/ into
Windower/addons, preserve data/, then `//lua reload TargetSC`. Lua reports
0.8.0-test8; native remains 0.5.0. No DLL replacement or FFXI restart.
Skillchains Animation8.6 runtime, bridge and assets are unchanged.

With display both or mb AND an actual MB window, the small property floor disc
holds its configured fill/trace alpha instead of following the SC countdown.
During the final mb_ending interval, it fades smoothly to zero at mb_close,
keeping its normal property colors and continuous rotation. The opener still
uses SC-only lifetime because no MB window exists yet. Display sc preserves
Test7's disc lifetime and slowdown-to-stop; off remains hidden.

`//tsc discs minimum 0.5` adds a minimum property-disc speed before the existing
speed multiplier. At speed .1 this is .05 turns/sec, one turn per 20 seconds.
The existing slowdown exponent blends initial stage speed toward this minimum
through the continuation countdown, then holds it through MB. Minimum is capped
at the stage's initial speed; stage 0 stays stationary. No angle discontinuity
at opening, continuation deadline or MB deadline. Rings retain their original
SC rotation; hum and all gameplay clocks remain untouched. Set minimum 0 for
the previous slowdown-to-stop comparison. Resettable new minimum is .5.

`//tsc mb opacity 0.39` now means starting opacity, growing toward full strength
across the source's existing MB window. `//tsc mb overall 1` is a separate master
for the middle ring, large MB glyph and confirmed-MB flash contributions. At
start .39 and master .5, middle alpha grows .195 -> .5. Closing white peaks are
also bounded by the master. The shared property's ordinary baseline continues
using discs opacity/outline * global opacity; MB master 0 removes MB overlays,
not that shared SC foundation. Existing mb effects remains animated strength.

`//tsc mb ending style soft|hard|both|off` selects synchronized white endings:
soft = three smooth strong/half/strong pulses; hard = three rectangular full/zero
flashes; both = soft then hard inside the SAME total mb_ending interval. Default
soft; no longer successively diminishing pulses. Both middle and large glyph
use full selected pulse strength * mb_effects * mb_overall, independent of idle
breathing alpha. The small property disc fades smoothly underneath these pulses.
`//tsc mb ending 0.9` is useful to inspect both styles without rushing six pulses;
existing saved .3/.6 values remain respected. Ending off disables closing white
signals, retaining the original confirmed-burst visual-tail comparison. Other
selected endings finish dark at the original deadline, even after a late MB;
no released glyph resurrects after the closing flashes. Explicit cleanup/reset
and pooled glyph ownership remain unchanged.

`//tsc sky hold 0.5` keeps the unfolded bell at nominal full span through the
.15s color transition plus .5s, then uses a smooth compressed descent to meet at
the original continuation deadline. Strike vibration still modulates actual
positions. 0 restores Test7's immediate linear descent. Range 0–2s; short windows
cap the hold to leave at least .1s for descent. Source timer and opacity/spin
progress are never paused. Existing cutoff/curve/expansion remain respected.
New hold default .5; existing saved values are otherwise untouched.

Host verification: all runtime/test Lua parses under Lua 5.1; all TargetSC tests,
actual addon-handler and both-load-order transport simulations, eight-element
burst previews, Skillchains HUD/demo tests and baseline combat-clock regression.
New test_mb_finish covers .5/1/4 slowdown curves, minimum-speed continuity and
stationary stages, SC-only compatibility, steady alpha/final fade, master-zero
and half-opacity responses, synchronized soft/hard/both pulses, late-hit dark
closure, bell hold/zero-hold/short-window deadlines, and saved command validation.
Geometry sweeps remain bounded at 32 bands/8 discs. Package checks enforce no
Skillchains/native changes and verify ZIP CRCs/manifests. These are host tests;
Test8's appearance still awaits live FFXI evaluation.

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


## Current Development Status — Animation8.6 terminal purity (2026-10-21)

**Repository/branch:** `rerorriM-Mirrorer/Skillchains`, `development/skillchains-terminal-purity`, based on live-feedback Animation8.5 (`1c870a6`). User confirms Umbra's black fade looks wonderful and 0.24s countdown pulse is preferred, and intends to keep the optional Level 1 glow. Needs timer-free terminal results, completely white Radiance including stroke and icon, and wants the dark underlying bar removed once terminal white refill reaches full length.

**Clarification from source:** Prior to Animation8.5 Skillchains' HUD continuation bar would be hidden on `closed=true` even during the 3-second charge. TargetSC independently renders closed skillchains with `pre` phase until `sc_open`, then `terminal` fading phase (`fade_duration=.8`) and may retain MB-only rings; Skillchains bar visibility does not determine TSC ring visibility. Animation8.5 already repaired Skillchains' terminal bar, and this iteration refines its display.

**Animation8.6:** The terminal result label shows `Umbra`/`Radiance` **without any SC countdown** from the instant the terminal result is registered, both for real closed combat frames and `//sc demo`/individual previews. During the brief end fade, the MB caption says `Magic Burst` with no numeric timer, then resumes its original time-based countdown after the effect; deadlines are not changed. Pure Radiance white drops the black text stroke (SC caption, MB caption, compact text) and uses a true white-alpha icon texture. Umbra uses the same silhouette tinted black. Monochrome assets are generated reproducibly from the source icons' alpha masks, bundled in the installable package, and used only for terminal effects. The pooled dark SC track is hidden when a terminal charge reaches full width (~1s), but never destroyed; it is visible again for any normal continuation bar. This is not applied to nonterminal skillchains, which need the dark track for decay.

**In-game test:** Back up existing `Skillchains/data/`; install Skillchains-only package; `//lua reload Skillchains`, `//sc glow levels 1234` (only if desired), keep `//sc anim fade period 0.24`, then `//sc demo`; `//sc anim preview umbra` and `//sc anim preview radiance` should show no terminal SC timer, true black/white glyphs and no dark stroke. Observe dark track disappearing from fully charged terminal bar, returning on later normal chains. With `//sc display both`, confirm numeric MB label is absent during terminal fade but returns when the fade is complete, at original MB deadline. Confirm `//sc targetsc` and `//tsc status` unchanged.

**Tests:** Source checkpoint `9b4d748` passed GitHub Actions [run 39552488664](https://github.com/rerorriM-Mirrorer/Skillchains/actions/runs/39552488664): Lua 5.1 parse, reproducible white-alpha icon artwork generation and check, actual HUD renderer simulations of timer-free monochrome text, true icon silhouettes, stroke suppression, terminal SC track hide/reuse, restored MB timer and color, standalone 40s demo, TargetSC bridge and native compatibility, complete package validation. GitHub published **Skillchains-only** artifact `12324486160` and paired compatibility artifact `12324481147`. All checks are host-side static/simulated—not direct in-game visual testing. Earlier first implementation packaging/tests had corrections before this final green checkpoint. **Live FFXI rendering still needs user acceptance.**

---

## Current Development Status — Animation8.5 terminal and pulse timing (2026-10-21)

**Repository/branch:** `rerorriM-Mirrorer/Skillchains`, `development/skillchains-pulse-terminal-fx`, based on `6a0d623` (Animation8.4, user says dramatically improved). Skillchains version `2.20.08.25-resonance.7-animation.8.5`. TargetSC Test3 0.3.0 native DLL/Lua/bridge unchanged.

**Latest feedback:** User restored `glow level2 .7` and `glow level3 1`, likes synchronized visual demos, but L2 white pre-window halo looked absent. User wants a configurable SC fill pulse near TargetSC floor ring vibration, and whimsical all-elements Umbra-black / light-side Radiance-white terminal fade. Asks whether L1 glow exists: yes, L1 already has muted property-color halo but is excluded by global mask 234.

**Code changes:** `//sc anim fade period <0.08..5 seconds>` changes sin² waveform cycle (default legacy ≈0.417s, recommended near TSC hum 0.24s); period anchored to current SC created clock. TargetSC ground hum uses `hum_period=.12` half-period plus per-level `hum_gain=.35` and countdown `hum_slowdown=1`. Matching 0.24s is approximate only: no live phase lock or changed TargetSC settings. A separate `pre2=.85` raises early white halo visibility; existing pre3 remains legacy. Real closed L4 receives a visible SC bar during the source's real 3-second preparation, then 0.8s terminal overlay whose SC/MB bar fills and backgrounds, text, icons and perimeter glow take black for Umbra, white for Radiance/Lux, fade and return MB to normal. No mutation of combat state or source clocks. `//sc anim preview umbra|radiance|lux` offers local visual test.

**Protection:** No TargetSC, `targetsc_bridge.lua`, skillchain ability parser, UI assets, HUD layout or user data modifications; keep complete cumulative source history below. No real auto-launch of dual demonstrations is added.

**Testing:** Final runtime checkpoint `08e9223` passed GitHub Actions [run 39549157835](https://github.com/rerorriM-Mirrorer/Skillchains/actions/runs/39549157835): Lua 5.1 compile; command-handler period/on/off and `pre2`; real renderer simulation of first-frame L2 alpha, different pulse cycles, black Umbra/white Radiance SC and MB backgrounds/captions/icons, fade end and separate MB continuation; existing 40s demo/TargetSC command-handler transport, x86 native build and curated archive manifest. Artifacts published: solo `12322358235`, paired `12322188464`. First full run `39549074933` passed its runtime checks but failed packaging because an extra guard included updated `TargetSC/TESTING.md` (documentation); corrected guard continues to enforce unchanged TargetSC Lua/native files, and the rerun passed. All tests are host-side static/simulated. **In-game visual performance and final appearance have not yet been verified.**

**Install and live checks:** Install only the Skillchains artifact, preserve `Skillchains/data/` and existing TargetSC Test3. `//lua reload Skillchains`; `//sc glow levels 234`; `//sc glow pre2 0.85`; `//sc anim fade on`; `//sc anim fade period 0.24`; `//sc demo`. Compare L2 white-charge glow at 17–20s, L3 charge at 24–27s, Umbra black fade from 33s, MB color recovery afterward. Run `//sc anim preview radiance` for white version; `//sc anim preview umbra` for black. `//sc targetsc`/`//tsc status` must still sync. No FFXI testing done by assistant.

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



## Current Development Status — Animation8.4 glow-tier progression (2026-10-20)

**Repository/branch:** `rerorriM-Mirrorer/Skillchains`, `development/skillchains-glow-tier-shift`; starting baseline `c6b05a7` (Animation8.3 standalone Umbra HUD demo with user feedback that the synchronized demo looks great). TargetSC companion Test3 `0.3.0`, native DLL, its preview, and working `lua c` bridge remain unchanged.

**Request:** Promote L3's white shimmer/border to L2 and L4's strong electric flicker/border to L3. Keep L4 terminal presentation unchanged. Make the promoted halos visible immediately on new chain registration, during the 3-second white refill/hold before the countdown. Do not change skillchain clocks, HUD fill pulse, TSC, saved user locations or per-character settings.

**Implementation:** Source FX code maps L2 to former L3 white halo/pulse (11-rad/s, stronger 34 rail/cap profile, `pre3` white-window energy), L3 to former L4 gold halo/electric envelope (23/28-rad/s, `pre4` pre-window energy), while L4 uses the same previous gold flicker. L2/L3 solid perimeter colors follow the corresponding styles while the white-fill transition stays otherwise intact. New global defaults enable 2,3,4 and suggest `level2=.70`, `level3=1`. **Existing saved level masks are not rewritten.** Previously selected `34` disables L2 until the user runs `//sc glow levels 234`; old customized `level2`/`level3` brightness values are respected.

**Verification:** Source checkpoint `7f70079` passed GitHub Actions [run 39547124075](https://github.com/rerorriM-Mirrorer/Skillchains/actions/runs/39547124075): Lua 5.1 parsing, L2/L3 first-frame pre-window colors/opacity and flicker at user-restored intensity 2/glow 2, L4 unchanged, legacy masks, actual-handler TargetSC transport, standalone 40s demo, native build and complete/solo manifest packaging. Artifacts: Skillchains-only `12321744158`, paired `12321564515`. Initial run `39547000455` failed a test assertion because intensity-1 glow alpha quantized two flicker samples to the same integer; the sampled intensity was raised to Killala's in-game value and an explicit t=0 pre-window check was added. No runtime code change was necessary after that failed test. **All checks are static/simulated, not FFXI rendering. New in-game acceptance remains pending.**

**Suggested in-game checks:** Back up `Skillchains/data/`; merge the new **Skillchains-only** addon files; `//lua reload Skillchains`, `//sc glow levels 234`, `//sc demo`. Observe Fusion L2 white shimmer beginning at 17 s, Darkness L3 gold electricity beginning at 24 s, unchanged Umbra L4 at 30 s. Compare `//sc anim preview level2`, `//sc anim preview level3`, `//sc anim preview level4`, and check `//sc targetsc`/`//tsc status`. Keep `//sc anim fade on` for the independently pulsing countdown fill if desired. No TargetSC changes in this batch.

---

## Current Development Status — Skillchains HUD demo (2026-10-20)

**Repository/branch:** `rerorriM-Mirrorer/Skillchains`, `development/skillchains-umbra-hud-demo`. Based on committed/pushed and CI-passing Animation8.2 `db8e919`; earlier paired Animation8.1+TargetSC Test3 synchronization was user-confirmed in game. **Skillchains** `resonance.7-animation.8.3`; **TargetSC** `0.3.0-test3` / native `0.3.0` unchanged.

**Present work:** Standalone `//sc demo` for the same five-step progression and absolute-derived clocks as TargetSC's Test3 Umbra visual demo, but running entirely in the Skillchains HUD. It temporarily takes over HUD presentation without modifying real combat or publishing bridge events. Demo ends automatically or via `//sc demo off`.

**Checks:** GitHub Actions run [39543735004](https://github.com/rerorriM-Mirrorer/Skillchains/actions/runs/39543735004) **PASSED** for source `9025f611` (Lua 5.1 parse, exact TargetSC demo timeline parity, real Skillchains command/HUD simulation with no fake bridge events or saved-setting writes, TargetSC Test3 handshake/native compilation, package manifests). It published a Skillchains-only install artifact `12320293616` and compatible paired artifact `12320597395`. These are **static/simulated checks**, not an in-game demo test; visual behavior and FPS remain to be verified by the user.

**Next test:** Backup and preserve Skillchains/data; install the Skillchains-only folder; `//lua reload Skillchains`; `//sc status` expected 8.3. For an independent MB tail run `//sc display both`, then `//sc demo` and observe milestones, L4 charge through 33 s and MB expiry at 40 s; `//sc demo off` cancels. Restore `//sc display sc` if desired. Verify `//sc targetsc` and `//tsc status` still connected and that live WS actions render normally afterward. No real weaponskills are executed by the demo.

---

## Skillchains Animation8.3 — standalone Umbra HUD demo (2026-10-20; LIVE PENDING)

**Command:** `//sc demo` or `//sc demo start` begins a local **40-second visual demonstration** using Skillchains' regular HUD renderer; `//sc demo status` reports progress and `//sc demo off` restores live display. The existing `//sc anim preview opener|level1|level2|level3|level4|off` commands still work independently. Starting the full demo cancels the single-scene HUD preview; starting a single-scene preview cancels the full demo.

| Demo elapsed | Weaponskill | HUD result |
| --- | --- | --- |
| 0 s | Fast Blade | Scission opener |
| 9 s | Gust Slash | Detonation L1 |
| 17 s | Nightmare Scythe | Gravitation L2 |
| 24 s | Rudra's Storm | Darkness L3 |
| 30 s | Entropy (Anguta + qualifying Aeonic Aftermath) | Umbra L4 |

**Same timing source math as TargetSC Test3:** every next weaponskill occurs one second before its predecessor's `created + 3 + 8 - step` continuation deadline. Individual wait times remain three seconds. Umbra's terminal charge is visible from 30–33 s, after which no further SC continuation is presented; the independent MB timer expires at 40 s. No confirmed Magic Burst or game action is invented. With `//sc display both`, the MB tail is visible; `display sc` keeps the user's existing visibility choice and may appear blank after the terminal charge.

**Isolation:** No fake action packets, no changes to `resonating`, no TargetSC `_event` sends or bridge calls, no configuration saves and no changes to source SC/MB deadlines. Real packet observation and TargetSC synchronization continue in the background; while the demo runs, its synthetic frames temporarily replace live HUD frames only. Both return to live display after `off` or expiry. Zone/logout cancel the demo.

**Install:** Solo Skillchains package contains `Skillchains/` with all required runtime Lua/images plus README.md, WORKFLOW.md and cumulative TESTING.md; no DLL and no TargetSC folder. Back up `Skillchains/` and preserve `Skillchains/data/`, merge the included folder into `Windower/addons/`, `//lua reload Skillchains`. Existing TargetSC Test3 is untouched, and `//sc targetsc`/`//tsc status` must retain subscribed/synced. User can run `//sc demo` even when TargetSC is not loaded.

**Verification:** GitHub Actions' Lua 5.1 parser, new standalone timeline/parity tests against TargetSC's reference sequence, real Skillchains command/render smoke tests, existing FX/learning regression, and TargetSC transport/native/build/package checks. All are static/simulated; **no live FFXI demo visual/fps or timing check yet**.

---

## Current Development Status — Animation8.2 glow configuration (2026-10-20)

**Repository:** `rerorriM-Mirrorer/Skillchains`; branch `development/skillchains-glow-config-schema-fix`. Source checkpoint: `721242f` paired Animation8.1 + TargetSC Test3, confirmed in-game by user to synchronize. **Runtime:** Skillchains `2.20.08.25-resonance.7-animation.8.2`; TargetSC `0.3.0-test3` / native `0.3.0`, unchanged.

**Cause:** Windower's `config.load` saves defaults when XML is missing, then reads newly written `<levels>34</levels>` back as number 34. The addon defined string default `'34'`, so even deleting settings.xml caused repeated string/number merge warnings. Animation8.1 prevented the `:find()` runtime exception but did not correct the loader's default type.

**Remedy:** Remove `levels` from typed defaults, keep reading legacy numeric and string masks, and save newly chosen masks as alphabetic `level_mask` (`L3,L4`, `L1,L2,L3,L4`, or `off`). The priority is new mask, old levels, then default L3/L4. No XML deletion, lost settings, visual changes or TargetSC bridge/native changes required.

**Verification:** Lua 5.1 parsing, legacy/new mask command and rendering simulations, TargetSC actual-handler bridge protocol and source deadlines, cross-compiled native build and two-addon package CI. Consult the associated GitHub Actions result before claiming pass. The **new build has not yet been verified in FFXI**.

**Next test:** On Killala/Franklet/Lionstag, keep settings.xml, update Skillchains source only and reload. Confirm `//sc status` Animation8.2 and no type-mismatch warning. Set `//sc glow levels 34`, reload once more, and verify warnings remain absent; verify `//sc targetsc` subscribed=true and `//tsc status` synced=true.

---

## Animation8.2 — correction to previous XML advice (2026-10-20; LIVE PENDING)

~~Deleting or hand-editing the saved glow mask fixes the startup warning.~~ This did not address the root cause: an ambiguous numeric-looking **default**, reproduced even with no XML present. Windower/Lua `addons/libs/config.lua` writes a fresh settings file and parses `34` numerically. Keeping old saved `levels` keys as untyped legacy values prevents the merge warning; new `level_mask` values are textual. No effect on prior TargetSC Test3 transport correction. Old records and in-game observations preserved below.

---

## TargetSC Test3 + Skillchains Animation8.1 paired repair (2026-10-20; LIVE SYNC PENDING)

**Branch:** `development/targetsc-test3-animation8.1-paired`, based on published Test3 `c18f262`.
**Paired versions:** Skillchains `2.20.08.25-resonance.7-animation.8.1` and TargetSC `0.3.0-test3` / native `0.3.0`.
**Why:** The separate Animation8.1 branch still had legacy `lua i TargetSC` commands; installing it over Test3's Skillchains bridge reverted Test3's crucial `lua c` addon-command transport correction, so TargetSC could not subscribe to real Skillchains updates. The numeric `glow.levels` loader warnings in the user's submitted XML are unrelated to bridge transport.

**Minimal integration:** Use the exact Animation8.1 `Skillchains.lua` and `resonance_fx.lua` blobs plus the added numeric-mask simulation from the Animation8.1 branch. Preserve Test3's already fixed `targetsc_bridge.lua` (`lua c TargetSC`) and its newer TargetSC driver, native DLL, geometry and previews without alteration. The package guard now compares all protected Skillchains HUD sources/images against the known Animation8.1 commit `d13f9c2` and checks the publisher is the same bridge with only `lua i` → `lua c` transport corrections.

**User data:** User supplied Cioara Skillchains `settings(20261021-002422).xml` for optional shared visuals. Preserve the original `data/settings.xml` in every client; don't put character-specific settings into published Git or overwrite differing viewport coordinates. The XML includes `<levels>34</levels>`; the renderer now tolerates this numeric value but config.load may still emit type-merge warnings at startup. Separate schema cleanup remains pending. Optional shared-profile export is delivered privately to the user, outside the tracked testing package.

**Available checks:** Lua 5.1 parse, simulated HUD numeric glow masks, actual-handler transport simulation (load orders/reload/unsubscribe/snapshot), TargetSC preview/state regressions, native cross-build and deterministic DLL checks, snapshot baseline, curated two-folder package and manifest. GitHub Actions outcome to be verified. These are static/simulated, not gameplay.

**In-game verification:** Close all FFXI clients before replacing TargetSC's DLL; back up both addon folders and preserve `data/`. Install both folders together. Load Skillchains then TargetSC. Run `//sc status` (Animation8.1), `//tsc status` (0.3.0-test3, source Skillchains v1, synced=true), `//sc targetsc` (subscribed=true, send failures=0). Retry `//tsc sync` if needed. Check `//lua reload Skillchains` while TargetSC stays loaded, and verify it reconnects without resetting absolute deadlines. Compare real opener/extension and `//tsc preview opener Fragmentation`; synthetic `//sc anim preview` deliberately does NOT drive TargetSC. Record exact statuses if it fails.

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

**Start here.** Cumulative development and testing record; not a claim of live validation.

## TargetSC 0.3.0 Test3 paired delivery (2026-10-19)

Branch `development/targetsc-resonance-test3`, Test2 base `5d23e29`, bridge fix
`aaf233f`. Full current install/test guide is in TargetSC/TESTING.md. Both folders
must be installed: TargetSC Lua/native API are now 0.3.0, and Skillchains' two
publisher commands now use `lua c`. This is the only change to its production
runtime; Animation8 HUD, assets, resolver and source deadlines are byte-identical
and guarded by the package builder.

Test3 adds world-space matched strikes, a separate slowing ground hum, no opener
fall, full opener colors, the requested concentric/stacked L1–L4 hierarchy,
faithful procedural circle/cross/star/central-square glyphs, independent fill/
outline and awakening controls, spin-to-stop discs, in-place expiration, snapshot
baseline presets and a no-burst four-link Umbra demo. Its five hits occur at
0/9/17/24/30 seconds. The independent MB reminder halo is deliberately retained.

Latest Lionstag snapshot `settings(20261019-131605).xml` supplies resettable
numeric defaults. Amplitude .3 now uses world units rather than model-height
fraction. No user settings/log bytes enter the package. Test2 preview feedback
is preserved separately from Test3's live-pending motion/renderer/connection.
Automated host checks cover Lua, native compilation/portable geometry, actual
handler transport, source deadline regression, original HUD and full packaging.
No Test3 FFXI/D3D execution or GitHub Actions success is claimed by local checks.

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

## Repository documentation history merged from master (2026-10-13 to 2026-10-16)

Preserved verbatim from `master` when the known-good TargetSC unified Test2 (`9c9106f`) was promoted to `master` on 2026-11-16.



### Agent entry-point adoption — 2026-10-16

- Added [`AGENTS.md`](AGENTS.md) to direct repository-aware coding agents to read the current `WORKFLOW.md` and `TESTING.md` before making changes.
- **Commit:** [`739d971`](https://github.com/rerorriM-Mirrorer/Skillchains/commit/739d971b72f7f18069e976f5e2064b5426663cc9).
- **Scope:** Documentation only; no addon code changed, testing ZIP generated, or in-game test performed.
- **Continuity:** Earlier testing and development records below remain intact.

### Package layout convention — 2026-10-16

- **Repository:** Keep `WORKFLOW.md` and `TESTING.md` at the repository root.
- **Testing ZIPs:** Include both inside the installable addon folder alongside the README and code. For patch/test-only bundles without an addon folder, place both next to the delivered files. No redundant outer ZIP-root copies.
- **Reference commit:** [`9ba8f76`](https://github.com/rerorriM-Mirrorer/Skillchains/commit/9ba8f76bf7f1394f6c3f6130d933661abb8cde7b).
- **Verification:** Documentation only; no game code changed and no in-game tests performed for this instruction update.
- **History:** Previous ZIP-root conventions remain below as historical records, with dated corrections where they were stated as current instructions.

Read this first when preparing or evaluating a development/testing batch. This cumulative, project-specific record belongs at the repository ~~and testing-package~~ root alongside `WORKFLOW.md`. **Correction (2026-10-16):** In testing packages, put both guides alongside the addon or patch/test files, not at the outer ZIP root.

### Current testing batch — documentation adoption (2026-10-13)

- **Project:** Skillchains (`rerorriM-Mirrorer/Skillchains`).
- **Batch:** Documentation-only adoption; no addon testing package or executable changes.
- **Starting default-branch commit:** `c703f9fb7a5d561c4c361ede52c090fc9abf38c8` (`master`).
- **Documents:** Added root `WORKFLOW.md` and `TESTING.md`.
- **Reference:** [NPCMirror consolidated workflow](https://github.com/rerorriM-Mirrorer/ffxi-NPCmirror/blob/main/WORKFLOW.md).
- **Verification:** Check root filenames and links; compare migration against its starting commit and confirm only Markdown documentation changed.
- **In-game testing:** Not performed for this documentation-only change; existing addon behavior has not been revalidated.

- **Recorded migration commit:** [`cde196b`](https://github.com/rerorriM-Mirrorer/Skillchains/commit/cde196b0ea604101403dbd6fb24480d02a468c5d).
- **Verified result:** Git comparison against the recorded starting commit lists Markdown changes only; `WORKFLOW.md` and `TESTING.md` exist at the repository root. No Lua source paths changed.

### Tests for the next functional batch

List the requested change, actions to perform, expected outcomes, previously working behavior to retest, and results actually observed. For UI positioning tests, record the character, resolution, visibility state and actual observed behavior when relevant.

### Previous tests and checks

No historical test results were reconstructed or verified during this documentation migration. Preserve previous testing materials and bring forward only accurately attributed results when reviewed.

### Cumulative changelog

- **2026-10-13 — Navigation refinement:** Corrected the heading levels for the Testing Packages and Shared Development Conventions sections in `WORKFLOW.md` ([`37d3841`](https://github.com/rerorriM-Mirrorer/Skillchains/commit/37d3841344b09f73a098beeb84a035d99cb489ac)). Documentation only; no addon code changed.

- **2026-10-13:** Adopted the shared two-document development convention without changing executable addon behavior.

### Delivered packages and documents

| Date | Batch | Item | Type | Commit/reference | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-10-13 | Documentation adoption | WORKFLOW.md; TESTING.md | Repository documents | [`cde196b`](https://github.com/rerorriM-Mirrorer/Skillchains/commit/cde196b0ea604101403dbd6fb24480d02a468c5d) | No testing package or Lua changes |

### User-provided materials, observations, and requests

- **2026-10-13 — Shared conventions:** Combine Agathos, Design, and Workflow into one `WORKFLOW.md` with linked table of contents; retain `TESTING.md` as the project-specific historical record; both documents belong in each active repository and testing-package root.
- Add earlier requests, tests, screenshots, files, and observations only when their provenance is verified; record date, batch, and reference.

### Corrections and retention

Correct errors with ~~strikethrough~~, an explanation, and the replacement. Remove historical testing information only by mutual agreement.
