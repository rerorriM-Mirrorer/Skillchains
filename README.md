# Skillchains — Resonance UI testing build v0.1

A standalone FFXI Windower 4 addon based on Ivaar's original Skillchains, updated by posimagi.
This test branch adds a restrained, FFXI-inspired visual layer without modifying EnemyBar2 or XIVCrossbar.

**Start with [TESTING.md](TESTING.md).** This is untested in-game and is not a public release.

## What it does

- Tracks individual targets' skillchain resonance and Magic Burst opportunities using action packets.
- Displays fading, element-colored gradient bars. The first weapon skill opens a **muted** waiting phase; the skillchain bar brightens when a following skill may land, then diminishes toward expiry.
- Tracks a separate Magic Burst window only after a successful skillchain. A completed/closed chain can continue showing its MB timer.
- Shows **all compatible character-learned** weapon skills, Scholar Immanence spells, Blue Magic, or applicable pet abilities, grouped by **resulting** skillchain and sorted by level. TP, recast, and other immediate execution prerequisites are **not** checked.
- Keeps its own draggable learning panel separate from the resonance bars.
- Does not auto-detect magic jobs, simulate skillchains, or use Japanese terminology.

The color stops are **provisional** approximations, not colors sampled from FFXI effects.
Level 3/4 Light/Dark burst opportunities use a single recognizable Light/Dark family color;
lower levels retain their specific burst element colors.

## Install (test branch)

1. Back up `addons/Skillchains/data` (if present), and keep a copy of your old addon folder.
2. Download the **resonance-ui-v0.1-test** branch ZIP (not the repository's default `master` ZIP).
3. Place `Skillchains.lua`, `skills.lua`, and `resonance_ui.lua` together in `Windower/addons/Skillchains/`.
4. Do **not** overwrite your `data/settings.xml` with a test configuration.
5. At the console, `lua reload Skillchains` (or `lua load Skillchains` on first install).
6. Type `//sc help`, then use `//sc edit` before combat to position the two UI components.

The root documents `AGATHOS.md`, `DESIGN.md`, `WORKFLOW.md`, and `TESTING.md`
accompany the development repository/testing ZIP; they are not needed at runtime.

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
| `//sc edit` or `//sc edit on/off` | Drag resonance handle and learning panel; a static setup sample appears |
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
the bar's configured width. The learning panel can be placed above or elsewhere.
Different-resolution clients have independent settings.

The UI creates only its own objects, and disappears outside a tracked target's
active window. It does not need EnemyBar2 to run.

## Credits and provenance

Original addon copyright © 2017 Ivaar, under its BSD-style source notice.
Skill data refresh and newer skill additions from posimagi/Skillchains.
Resonance UI testing changes authored by A (Awake) with user-directed design.
Existing upstream notices in the Lua source files remain intact.

## Changelog (cumulative)

### 2026-10-13 — v0.1 test (not yet live-tested)
- Refresh ability data from posimagi.
- Add independent skillchain continuation and post-chain Magic Burst timers.
- Add editable gradient bars, stand-alone learning panel, grouping by resulting chain.
- Add `display sc|mb|both`, `mode learn|compact|minimal`, `edit`, `scale`,
  draggable scale edit, width, default, help, status.
- Preserve manual selection: **no magic-job/subjob detection**.
- Retain original action-packet detection and legacy useful suggestion filters.
