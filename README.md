# Skillchains — Resonance UI testing build v0.1

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
- Displays the target's **currently resonating skillchain properties** just below
  the SC bar in smaller EnemyBar2-style Arial bold italic text with a dark stroke.
  The first WS shows all its properties (for example, Liquefaction, Detonation);
  a completed skillchain shows its result (for example, Fusion). Long
  property lists wrap. The label follows the SC bar, not the learning panel,
  and is hidden with the SC bar or in Minimal mode. It can independently
  display full names, 3-letter labels, or nothing; the text stays white with
  a black outline until skillchain-level colors are deliberately selected.
- Does not auto-detect magic jobs, simulate skillchains, or use Japanese terminology.

The color stops are **provisional** approximations, not colors sampled from FFXI effects.
Level 3/4 Light/Dark burst opportunities use a single recognizable Light/Dark family color;
lower levels retain their specific burst element colors.

## Install (test branch)

1. Back up `addons/Skillchains/data` (if present), and keep a copy of your old addon folder.
2. Download the **curated testing ZIP**, not GitHub's automatic source-code archive.
3. Open it and copy the single inner `Skillchains/` folder's three Lua files
   (`Skillchains.lua`, `skills.lua`, `resonance_ui.lua`) into
   `Windower/addons/Skillchains/`.
4. Keep your existing `Windower/addons/Skillchains/data/settings.xml` untouched.
5. At the console, `lua reload Skillchains` (or `lua load Skillchains` on first install).
6. Type `//sc help`, then use `//sc edit` to position the bar and learning panel.

The curated testing ZIP contains `README.md`, `WORKFLOW.md`, and `TESTING.md`
**at the archive root**, with exactly one `Skillchains/` addon directory.
`WORKFLOW.md` is the consolidated NPCMirror guide: it includes AGATHOS,
DESIGN and WORKFLOW principles; no separate `AGATHOS.md` or `DESIGN.md`.
The documentation is not required to run the addon. GitHub's automatic
branch ZIP wraps the entire repository in an extra source-directory name
and is **not** the recommended installation package.

## Commands

| Command | Purpose |
| --- | --- |
| `//sc` or `//sc status` | Current version and settings |
| `//sc help` | Compact command guide |
| `//sc display sc` | Skillchain resonance only (**default**) |
| `//sc display mb` | Magic Burst only |
| `//sc display both` | Two independent windows |
| `//sc mode learn` | Full grouped compatible action list (**default**) |
| `//sc mode compact` | Property text and timers, no action list |
| `//sc mode minimal` | Bars only |
| `//sc names full` | Full property names below SC bar (**default**) |
| `//sc names short` | Three-letter properties separated by ` / ` |
| `//sc names off` | Hide attached property caption in Learn/Compact too |
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

## Credits and provenance

Original addon copyright © 2017 Ivaar, under its BSD-style source notice.
Skill data refresh and newer skill additions from posimagi/Skillchains.
Resonance UI testing changes authored by A (Awake) with user-directed design.
Existing upstream notices in the Lua source files remain intact.

## Changelog (cumulative)

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
