# TESTING.md — Skillchains Resonance UI

**Start here.** Cumulative development and testing record; not a claim of live validation.

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
