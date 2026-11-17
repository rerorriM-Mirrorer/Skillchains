# TargetSC TESTING.md — start here

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

## TargetSC 0.9.0 Test9 — terminal stars and synchronized MB introductions (2026-10-21)

Branch `development/targetsc-terminal-intro`, based on latest paired Skillchains
Animation8.7 branch `1dfae131` (which retains TargetSC Test8 `fa295295`).
A confirmed enjoying Test8 live, then requested contrasting terminal traces and
brief synchronized white flashes introducing each new MB window/property change.
Latest supplied tuning reference: settings(20261021-100005).xml. Preserve user
settings; no preset reset, no personal XML modification or inclusion.

Install TargetSC-0.9.0-Test9-Terminal-Intro-Lua-Patch.zip by merging TargetSC/
into Windower/addons, preserving data/, then `//lua reload TargetSC`. Lua 0.9.0-test9;
native remains 0.5.0. No DLL replacement or FFXI restart. The patch contains no
Skillchains folder. Latest Animation8.7 runtime/artwork/source bridge stays
byte-identical to 1dfae131; all combat clocks and interpretation stay untouched.

Umbra now has a white-gold (#fff2cc) copy of the same approved traced star over
its black fill. Radiance has the same star in black over white. Both fill and
trace use radius .92 * model radius, just below the resting breathing glyph's
.96 radius. Fill remains at the existing floor-property height; trace is emitted
AFTER its fill, .006 world units higher, using the native outline-only path.
Normal discs opacity/outline and global opacity remain respected. The standard
fill-only / outline-only styles remain available. Existing level-four spin 0
remains stationary; saved per-level speed overrides still work. Other levels'
star, radius, colors and position are unchanged outside MB introductions/hits.

Every real new MB window flashes the larger glyph, regular property fill/trace
and middle ring white together. Default: two flashes over .24 seconds, with a
brief full-strength plateau, quick fade and gap for each. The shared waveform
is based on the source state's created timestamp, not an accumulated animation
timer. At full mb_effects, all three peaks equal mb_overall; the property introduction
reaches that peak instead of being limited by idle/global alpha. Lower effects
values blend a weaker introduction over each layer's ordinary baseline.
The master and effects settings can suppress the introduction. Normal baseline
property opacity is preserved when the MB master is 0. Existing mb_floor/mb_ring
controls continue to describe CONFIRMED burst responses, not fresh-window intro.

`//tsc mb intro 0.24` controls the total intro duration (0–.6); 0 disables.
`//tsc mb intro flashes 1|2` selects one or two flashes (default 2).
Live skillchain switches restart this short white announcement before revealing
the new palette. Authoritative reload/sync snapshots do not replay it, even if
their source window is fresh. An opener alone never invents an MB introduction.
Closing signals take priority over an intro if a very short window overlaps.
The stationary breathing glyph's normal opacity/cycle does NOT gain a ramp.
Test8 sustained floor lifetime, minimum spin, bell hold and synchronized endings
remain intact. This is a targeted follow-up, not a visual preset reset.

Host checks: Lua 5.1 parsing; all TargetSC simulations including the new
terminal_intro test; actual addon-handler validation, source receiver/load-order
transport, source combat-clock baseline comparison, eight MB elements, geometry
sweeps, current Animation8.7 HUD/command/demo simulations. New tests check both
terminal contrast palettes, equal fill/trace radius, smaller-than-breathing size,
height/draw order, style choices, white peaks across five properties and both MB
display modes, effect/master gating, live switch/pool reuse, no snapshot replay,
local demo timing, source deadline preservation and command bounds/integer count.
Package guards/CRC/SHA manifests verify current HUD/native preservation. Native
DLL SHA remains bc841580e5110739759d3427e6f6975cd7c305363c480620120fc469d0e618f6.
These are host checks; Test9 appearance still awaits live FFXI evaluation.

The latest Animation8.7 tools/test_learning_ui.lua contained an unterminated
assertion with a duplicated ~530-line test body inserted inside it. Repaired
only this test harness by retaining each distinct scenario once and correctly
joining the new ghostflare/ribbon assertions. Its full simulation now passes;
no HUD runtime change was needed. Also corrected its package PNG signature
check to compare actual PNG bytes rather than a double-escaped text literal.
Prior testing history below is preserved.

## Companion Skillchains Animation8.8 (2026-10-21)

Skillchains provides a *presentation-only* white introduction for new/replaced MB windows, and MB HUD gains independent position, scale, typography and icon settings. Unlike the prior shared terminal implementation, real Umbra/Radiance SC black/white fade does not modify MB. TargetSC Test8 rings, property-disc phases, MB visual endings, Lua/native DLL and unchanged bridge still drive their own views from the same real packet source clocks. No TargetSC code or data is modified by this batch. Confirm continued subscription status and compare the new Skillchains MB flash to the existing TargetSC animations in-game.

---

## Companion Skillchains Animation8.7 (2026-10-21)

This Skillchains-only visual pass uses TSC Test8's independent MB lifetime/slow breathing as a design reference. SC moving endpoint, fill-only MB ribbon, above/below MB spacing and BattleStations-style help do not alter TargetSC 0.8.0 Test8 Lua, native DLL 0.5, bridge v1 or source deadlines. There is no new coupling or TSC dependency. Install **Skillchains-only** folder, preserve both addons' `data/` and verify subscription. TSC Test8 itself still requires its own live visual acceptance.

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
