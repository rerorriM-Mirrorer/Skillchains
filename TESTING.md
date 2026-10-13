# TESTING.md — Skillchains Resonance UI

**Start here.** Cumulative development and testing record; not a claim of live validation.

## Current testing batch — 2026-10-13 / v0.1.2 (property-caption offset and small-client recovery)

**Branch:** `resonance-ui-v0.1-test`; master remains at its previous live baseline.
**Status:** User previously confirmed the addon loads and basic commands work in FFXI. The new property-label, redraw, rounding, and off-screen-edit changes have not yet been tested live.
**Delivery:** Download the artifact named `Skillchains-v0.1.2-test` from the
latest successful [GitHub Actions packaging run](https://github.com/rerorriM-Mirrorer/Skillchains/actions/workflows/package-testing.yml),
rather than using GitHub's auto-generated repository source ZIP.
The packaging workflow verifies the archive layout and CRC checks. Archive
root: `WORKFLOW.md`, `TESTING.md`, and one `Skillchains/` folder containing
`README.md`, `Skillchains.lua`, `skills.lua`, and `resonance_ui.lua`.
Install only that `Skillchains/` folder, preserving existing `data/`.
**Conventions:** `WORKFLOW.md` is the consolidated canonical document from
NPCMirror, containing AGATHOS, DESIGN and WORKFLOW. The retired
`AGATHOS.md` and `DESIGN.md` documents are intentionally absent.
**Runtime:** No `settings.xml`, launcher scripts, or EnemyBar2 modifications
are included.
**Precaution:** Back up your current Skillchains folder and its `data` before replacing files.

### Current targeted test: property-caption offset (resonance.4)

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

### Packaging verification (documentation-only correction)

- Confirm the published GitHub Actions artifact ZIP has **one** `Skillchains/`
  directory containing `README.md` and the three Lua files. Only the two
  development documents `WORKFLOW.md` and `TESTING.md` stay at the ZIP root.
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

| Date | Batch | Work | Reference | Status |
| --- | --- | --- | --- | --- |
| 2026-10-13 | v0.1.2 offset | Add bar-relative property-label offset in `//sc names offset <x> <y>` | `15ec5e4`, `39323f9`, `ea1c5e8` | Committed / live untested |
| 2026-10-13 | v0.1.2 README location | Place README inside installable folder, keep WORKFLOW/TESTING at ZIP root and sync NPCMirror guide | Canonical NPCMirror `WORKFLOW.md`; package builder updated | Documentation/package-only change |
| 2026-10-13 | v0.1.2 packaging | Adopt consolidated NPCMirror workflow, retire duplicate docs; CI produces one-addon-directory artifact | `5831d2b`, `2da4ec1`, `d97ee94`, `d64e819`, `df535cc` | GitHub Actions run 38449553310 succeeded, artifact 11838873673; no Lua behavior changes |
| 2026-10-13 | v0.1.2 | Smooth rendering, short labels, rounded dark tracks and off-screen edit recovery | `f989b8a`, `d6b13f0`, `32dca6d`, `6ae3365`, `a9f3ca3` | Committed / live untested |
| 2026-10-13 | v0.1.1 | Add attached property label and MB clearance in `resonance_ui.lua` | `9544346` | Committed / live untested |
| 2026-10-13 | v0.1 | posimagi skill database refresh | `25513fb` | Committed / live untested |
| 2026-10-13 | v0.1 | first standalone gradient renderer and independent timers | `a1ad1d3`, `b3238f3` | Committed / live untested |
| 2026-10-13 | v0.1 | manual display, Light/Dark simplification, scale handle, schema correction, and load-time guard | `d0056c6`, `d021e08`, `71902d3`, `0308a9e`, `5522303`, `9f62963` | Committed / live untested |

## User-provided materials, observations, and requests

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

Preserve this record; corrections use strike-through with the reason and replacement,
rather than silently deleting prior entries.
