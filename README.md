# Skillchains — Resonance UI testing build resonance.6

A standalone FFXI Windower 4 addon based on Ivaar's original Skillchains, updated by posimagi.
This test branch adds a restrained, FFXI-inspired visual layer without modifying EnemyBar2 or XIVCrossbar.

**Start with [TESTING.md](TESTING.md).** Initial addon load and basic commands were user-confirmed; the newest combat/rendering changes remain live-untested. This is not a public release.

## What it does

- Tracks individual targets' skillchain resonance and Magic Burst opportunities using action packets.
- Displays fading, element-colored gradient bars with subtle 1-pixel rounded ends
  and darker translucent tracks. The first weapon skill opens a **muted** waiting
  phase; the skillchain bar brightens when a following skill may land, then
  diminishes smoothly toward expiry (~30 updates/second). A new skillchain step
  still resets the bar immediately, with no cross-step tween.
- Tracks a separate Magic Burst window only after a successful skillchain. A completed/closed chain can continue showing its MB timer.
- Shows **all compatible character-learned** weapon skills, Scholar Immanence spells, Blue Magic, or applicable pet abilities, grouped by **resulting** skillchain and sorted by level. TP, recast, and other immediate execution prerequisites are **not** checked.
- Keeps its own draggable learning panel separate from the resonance bars.
  The list is bottom-anchored so additional compatible actions extend **upward**.
  Learn mode shows **ability names first**, colored by the predicted result
  using the resonance bar's elemental palette. The action's own skillchain
  property PNG icons form a **fixed right-aligned column**. Higher-level
  results appear first; the FFXI prediction logic still selects one expected
  result per action. There is no redundant level or result heading.
  The Learn background is transparent; only a small edit handle is opaque.
- Displays the target's **currently resonating skillchain properties** just below
  the SC bar in smaller EnemyBar2-style Arial bold italic text with a dark stroke.
  The first WS shows all its properties (for example, Liquefaction, Detonation);
  a completed skillchain shows its result (for example, Fusion). Long
  property lists wrap. The label follows the SC bar, not the learning panel,
  and is hidden with the SC bar or in Minimal mode. It can independently
  display full names, 3-letter labels, or nothing; the text stays white with
  a black outline until skillchain-level colors are deliberately selected.
  Small skillchain-property icons now precede the SC property names and
  the MB caption. Radiance/Umbra temporarily reuse Light/Darkness artwork.
  The SC name caption includes a live `x.xs` expiration countdown. When the
  separate MB bar is enabled, it reads `Magic Burst: x.xs`. Minimal remains
  completely bars-only.
- Does not auto-detect magic jobs, simulate skillchains, or use Japanese terminology.

The color stops are **provisional** approximations, not colors sampled from FFXI effects.
Level 3/4 Light/Dark burst opportunities use a single recognizable Light/Dark family color;
lower levels retain their specific burst element colors.

## Install (test branch)

1. Back up `addons/Skillchains/data` (if present), and keep a copy of your old addon folder.
2. Download the [**Skillchains-resonance.6-test**](https://github.com/rerorriM-Mirrorer/Skillchains/actions/workflows/package-testing.yml) from the latest successful GitHub Actions run (Artifacts section), not GitHub's automatic source-code archive.
3. Open it and copy the installable `Skillchains/` folder into
   `Windower/addons/`, merging with your existing `Skillchains/` folder if updating.
   It contains `Skillchains.lua`, `skills.lua`, `resonance_ui.lua`,
   `learning_ui.lua`, 14 PNGs under `images/skillchain/`, and `README.md`.
4. Keep your existing `Windower/addons/Skillchains/data/settings.xml` untouched.
5. At the console, `lua reload Skillchains` (or `lua load Skillchains` on first install).
6. Type `//sc help`, then use `//sc edit` to position the bar and learning panel.

The curated testing ZIP contains exactly one `Skillchains/` directory.
Its `README.md`, `WORKFLOW.md`, and `TESTING.md` sit **inside that
installable folder** alongside the four Lua files and property icons, following
NPCMirror's current packaging convention.
A source copy also remains at the GitHub repository root.
`WORKFLOW.md` is the consolidated NPCMirror guide: it includes AGATHOS,
DESIGN, and WORKFLOW principles; there are no separate retired documents.
GitHub's automatic branch ZIP wraps the entire repository in an extra
source-directory name and is **not** the recommended installation package.

## Commands

| Command | Purpose |
| --- | --- |
| `//sc` or `//sc status` | Current version and settings |
| `//sc help` | Compact command guide |
| `//sc display sc` | Skillchain resonance only (**default**) |
| `//sc display mb` | Magic Burst only |
| `//sc display both` | Two independent windows |
| `//sc mode learn` | Transparent, color-coded ability names and right-aligned own-property icons; higher-level resulting chains first (**default**) |
| `//sc mode compact` | Short standalone timer summary; bar captions retain property names and live timers |
| `//sc mode minimal` | Bars only |
| `//sc names full` | Full property names below SC bar (**default**) |
| `//sc names short` | Three-letter properties separated by ` / ` |
| `//sc names off` | Hide attached property caption in Learn/Compact too |
| `//sc names offset 0 -11` | Position captions relative to their bars: X, Y pixels. Default is `0 -11`; omit values to report. |
| `//sc edit` or `//sc edit on/off` | Drag the bar and learning panel; automatically recovers off-screen positions |
| `//sc center` | Center both UI objects within the current client's viewport |
| `//sc pos 200 450` | Set a precise bar position (clamped to the current viewport) |
| `//sc scale edit` | Toggle the draggable horizontal scale handle (also enters edit mode) |
| `//sc scale 0.8` | Uniform thickness/spacing/text scale (0.5–2.5); omitting number reports |
| `//sc width 310` | Set pixel width to match EnemyBar2's primary target HP bar |
| `//sc default` | Reset UI positions, scale, display choice, and mode |
| `//sc save` / `//sc save all` | Persist character settings / apply to all |
| `//sc weapon`, `//sc spell`, `//sc pet` | Original per-main-job suggestion filters |
| `//sc aeonic` | Preserve original Aeonic fallback toggle |

`//sc burst`, `//sc step`, `//sc timer`, `//sc props`, and `//sc color`
previously controlled the long text window. They now advise using `mode` and `display`.

## Arrangement

Resonance bars begin near Franklet's primary target HP bar in the shared screenshot,
but **do not dynamically follow EnemyBar2** yet. Drag the bar via `//sc edit`,
and use `//sc width` to match that client's actual HP bar. Scale does not shorten
the bar's configured width. The learning panel can be placed above or elsewhere. The property label sits
**below** the SC bar, so leave a little extra vertical space beneath the target
HP bar, especially at Franklet's small resolution. If both bars are displayed,
the MB bar is pushed below the property label so the two do not overlap.
Different-resolution clients have independent settings. If a position saved
on a larger client is outside Lionstag's smaller screen, `//sc edit` now
automatically brings its drag handle into view; `//sc center` is an explicit
recovery command and `//sc pos x y` offers direct adjustment.

The UI creates only its own objects, and disappears outside a tracked target's
active window. It does not need EnemyBar2 to run.

For a little overlap between the property names and the bottom of the resonance
bar, try `//sc names offset 0 -11` (now the default). This is saved per character and follows the
bar when moved or scaled; `//sc default` resets the offset to `0 -11`. The first
number is horizontal adjustment and the second vertical adjustment. If Magic
Burst is displayed too, a positive Y offset reserves extra clearance.

## Credits and provenance

Original addon copyright © 2017 Ivaar, under its BSD-style source notice.
Skill data refresh and newer skill additions from posimagi/Skillchains.
Resonance UI testing changes authored by A (Awake) with user-directed design.
Existing upstream notices in the Lua source files remain intact.
The 14 colored skillchain PNGs are copies of the user fork's
[XIVCrossbar default icon pack](https://github.com/rerorriM-Mirrorer/xivcrossbar/tree/master/images/icons/iconpacks/default/skillchain)
and are supplied locally to keep Skillchains independent of XIVCrossbar.
Check artwork provenance and redistribution terms before a public release.

The original addon displays Magic Burst **elements**, not an inventory-filtered
list of usable burst spells. This build does not add burst spell suggestions;
`//sc spell` continues to cover compatible skillchain-forming spells on
eligible jobs.

## Changelog (cumulative)

### 2026-10-18 — canonical package documentation alignment
- Place WORKFLOW.md and TESTING.md inside the packaged Skillchains folder
  according to NPCMirror's current workflow, preserving source copies at
  the repository root. Add AGENTS.md to the source repository.

### 2026-10-18 — resonance.6 test: ability-first Learn mode
- Show only ability names in Learn mode, with colors derived from the
  predicted result's resonance palette and the action's own property icons
  in a fixed, right-aligned column. Existing game-result prediction and
  high-level-first ordering remain unchanged; no speculative outcomes.
- Use transparent Learn rows with Arial bold italic text and black stroke,
  retaining the bottom-anchored, upward-growing design. Keep an independently
  draggable small guide visible only in edit mode.
- Add local copies of XIVCrossbar's 14 PNG skillchain icons, used both in the
  Learn rows and next to SC/MB bar captions. The addon needs no XIVCrossbar
  runtime dependency. Radiance and Umbra reuse Light and Darkness icons.
- Pool and reuse text/image objects, clipping long learning lists to the
  viewport with a `+N more` marker when necessary. Preserve Compact and
  Minimal modes, all bar timers, widths, scale and saved positions.
- Add Lua 5.1 parsing, simulated Windower layout checks, and ZIP icon
  manifest/signature verification. Actual FFXI gameplay still needs testing.


### 2026-10-13 — resonance.5 test: upward learning list and bar timers
- Move the SC BAR edit drag handle farther above the bar so it no longer
  covers the gradient during appearance review. Preserve dragging.
- Set the default property-name offset to `0 -11` per user in-game preference;
  `//sc default` restores that value without changing saved custom offsets
  unless a reset is explicitly requested.
- Attach live `x.xs` countdowns to property names on the SC bar and a separate
  `Magic Burst: x.xs` caption to the MB bar. Minimal still shows only bars.
- Remove the redundant step/availability headings from Learn mode; show
  `Light: Savage Blade`-style groups sorted by resulting level, with all
  learned compatible actions retained.
- Save the learning panel's bottom edge when dragged, so new rows expand
  upward. Cache measured text height for smoother multibox rendering.
- Leave the dark learning-panel background and more transparent bar tracks
  unchanged pending visual review. New behavior requires live verification.
- Add automated Lua 5.1 syntax checking before publishing the testing ZIP;
  fix an inherited parser-incompatible string-literal method call. Source
  compiles, but the new UI behavior has not yet been tested in FFXI.

### 2026-10-13 — v0.1.2 property-caption offset (resonance.4)
- Add `//sc names offset <x> <y>` for independent, persistent property-label
  positioning relative to the SC bar; e.g. `0 -4` overlaps the bar slightly.
- Preserve whitespace between caption and MB bar for positive downward offsets;
  include offset reset in `//sc default`.
- Add command help and testing instructions. New behavior not yet tested in game.

### 2026-10-13 — README installation-folder convention
- Keep the source README at the repository root and place its package copy
  **inside Skillchains/**, so it remains with the addon after installation.
- Keep consolidated WORKFLOW.md and cumulative TESTING.md at the ZIP root.
- Updated the reusable package builder and synced canonical NPCMirror workflow.
- Packaging/documentation only; no Lua changes.

### 2026-10-13 — v0.1.2 testing-package correction
- Adopt canonical NPCMirror `WORKFLOW.md` (Agathos, Design and Workflow combined)
  at repository and package root, with `TESTING.md` beside it.
- Retire separate `AGATHOS.md` and `DESIGN.md` from the test branch.
- Provide a curated ZIP with one `Skillchains/` runtime directory;
  no addon behavior changes in this packaging correction.

### 2026-10-13 — v0.1.2 test: labels, smooth expiry and edit recovery
- New `//sc names full|short|off` label choice, with abbreviations for
  level 1–4 properties. Full names remain default, in white Arial bold
  italic with black stroke; Minimal stays bars-only.
- The learning panel no longer repeats the target's current property names.
- Countdown redraws at ~30 Hz from absolute expiry times and leaves active
  primitives visible between frames. Learning text is cached to reduce
  the cost of additional redraws.
- Add dark translucent tracks with subtle 1px rounded endcaps using native
  primitives, without requiring new image files.
- Repair off-screen `//sc edit` handles across different client resolutions;
  add `//sc center` and `//sc pos x y` for recovery.
- **Live tests pending** for motion, layout, clipping, label abbreviations
  and rounding on Lionstag and other clients.

### 2026-10-13 — v0.1.1 test: attached property caption
- Display current weapon-skill/skillchain properties directly under the SC bar,
  independent of the learning panel; match EnemyBar2's smaller Arial bold
  italic and stroked type. Wrap long captions and reserve clearance for the MB bar.
- No new command or job-based detection. Minimal remains bars-only.
- Source-reviewed; in-game rendering **not yet tested**.

### 2026-10-13 — v0.1 test (initial combat behavior not yet live-tested)
- Refresh ability data from posimagi.
- Add independent skillchain continuation and post-chain Magic Burst timers.
- Add editable gradient bars, stand-alone learning panel, grouping by resulting chain.
- Add `display sc|mb|both`, `mode learn|compact|minimal`, `edit`, `scale`,
  draggable scale edit, width, default, help, status.
- Preserve manual selection: **no magic-job/subjob detection**.
- Retain original action-packet detection and legacy useful suggestion filters.
