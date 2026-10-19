# Skillchains — Resonance HUD Animation8.1 test build

A standalone FFXI Windower 4 addon based on Ivaar's original Skillchains, updated by posimagi.
This test branch adds a restrained, FFXI-inspired visual layer without modifying EnemyBar2 or XIVCrossbar.

**Start with [TESTING.md](TESTING.md).** Initial addon load and basic commands were user-confirmed; the newest combat/rendering changes remain live-untested. This is not a public release.

## Animation8.1 — Lionstag saved-mask crash fix

Lionstag reported repeated `resonance_fx.lua:278` errors while loading the
Animation8 HUD. Windower can read a saved glow-level mask such as `34` as a
number, while the renderer expected a string and called `:find` on it.
The renderer now converts this setting to text at the lookup, preserving the
same enabled levels and every existing visual/timing setting. Numeric `34`
and `1234` masks have dedicated simulated regression cases. This correction
still needs live confirmation on Lionstag; it is not a new visual pass.

Preserve `Skillchains/data/`, replace only the Skillchains files from the
Animation8.1 testing package, then `//lua reload Skillchains`. No TargetSC
DLL or Lua update is needed.

## Animation8 — real capsule perimeter and stronger electric border

New `development/skillchains-resonance-animation9` **test** branch
fixes the high-tier background problem: previously the "border" was
a whole opaque white/gold rectangle **under** the semi-transparent
track. Now only its top/bottom/rounded ends draw, leaving a genuine
dark, translucent interior at every level. Three tintable glow
sprites — `capsule_halo_l.png`, `capsule_halo_rail.png`, and
`capsule_halo_r.png` — sample exactly the same source outline.
They meet end-to-end, with no overlapping cap blobs and a dark
interior. `tools/generate_capsule_halo.py` reproduces the art.

The opener retains the animation you liked. Successful chains
retain the white refill, three-second hold and 0.30s white→property
overlap at the actual start of decay. Level 1's border develops its
result color while the bar stays white; L2's perimeter favors
property color to protect its gradient; L3 has a slower, pale
11-rad/s shimmer; L4 restores fast 23/28-rad/s gold electricity,
including throughout the white pre-window. Empty learning groups
draw no box or placeholder.

**Current recommended base and controls:**

```text
//sc glow reset                 -- resets ONLY glow, not positions
//sc glow rail34 0.75           -- user-confirmed attractive L4 reference
//sc glow cap34 0.85
//sc glow pre3 0.38             -- level 3 activity during white hold
//sc glow pre4 0.85             -- level 4 stays electric during white hold
//sc glow pre4 0                -- compare no prewindow flicker
//sc glow l4 gold               -- whitegold and white remain optional
//sc glow levels 1234           -- optionally include lower levels
//sc glow preset balanced      -- equal cap and rail strength
//sc glow preset capforward
//sc track                      -- shows active RGB and alpha
//sc track alpha 155            -- default; 0=fully transparent
//sc track rgb 6 8 17           -- dark neutral-blue default
//sc track reset                -- resets ONLY track, not positions
//sc anim preview opener
//sc anim preview level4
```

New defaults: glow levels 34; rail12=.30 cap12=.35;
rail34=.75 cap34=.85; level1=1 level2=.65 level3=.70 level4=1;
pre12=.18 pre3=.38 pre4=.85; glow scale=1; L4=gold;
track RGB(6,8,17), alpha155. All glow numeric multipliers remain
unbounded nonnegative; alpha itself saturates at 255. Existing
per-character settings are retained: use `//sc glow reset` and
`//sc track reset` to try the new defaults without moving anything.
TargetSC native/bridge is unchanged. Keep your `Skillchains/data/`
folder when updating; run `//lua reload Skillchains`.
The new renderer has **only passed synthetic/static tests**, not
FFXI live tests. See TESTING.md for detailed test cases.

## Animation7 — continuous glow caps and tunable electricity (2026-10-19)

The personal development branch `development/skillchains-resonance-animation8`
simplifies the resonating bars while preserving the source-clock HUD
and TargetSC compatibility. A successful chain gets one clean,
left-to-right white refill with the former fill/dark track underneath.
White **stays** through most of the three-second pre-window; over
the 0.30s window centered on countdown start, the entire bar
smoothly becomes its skillchain property color and the glow border
reawakens. There are no vertical edge or center flare sprites.
The opener retains the user-approved white expansion -> dim
opener color -> bright active behavior.

The level-3/4 electric border now consists of two soft ghost-glow
rails and **two matching rounded, mirrored endcap PNGs**
(`ghost_glow_cap_l.png` and `ghost_glow_cap_r.png`). Level four
defaults to a pale white-gold shimmer. Levels 1/2 can enable
the same system independently without changing global glow levels.

Try the following while viewing `//sc anim preview level4`:

```text
//sc glow
//sc glow levels 34
//sc glow levels 1234
//sc glow rail12 0.30
//sc glow cap12 0.35
//sc glow rail34 0.60
//sc glow cap34 0.75
//sc glow level1 0.5
//sc glow level2 1
//sc glow level3 1
//sc glow level4 1
//sc glow scale 1
//sc glow preset balanced
//sc glow preset capforward
//sc glow l4 whitegold
//sc glow l4 gold
//sc glow l4 white
//sc transition 0.30
//sc transition style energized
//sc transition style uniform
```

Defaults: levels `34`; rail strengths 0.30 (1/2), 0.60 (3/4);
cap strengths 0.35 (1/2), 0.75 (3/4); level multipliers 1,
global scale 1, transition 0.30s energized, L4 white-gold.
`capforward` makes caps 1.25× as bright as their rails;
`balanced` matches them. Every numeric change reports its
default, and nonnegative finite values have no artificial
maximum (actual alpha saturates at 255). The existing
`//sc anim glow` and `//sc anim intensity` remain independent
global multipliers. `//sc anim flare` still saves its old value
but retired flare sprites no longer draw.

Existing character settings are not overwritten; `//sc default`
restores new defaults. `//sc anim preview opener|level1|level2|
level3|level4` is local-only and never sends fake TargetSC
events. Full deployment copies the Skillchains Lua files and
the **new three runtime texture PNGs**; preserve `data/`.
No TargetSC native/DLL or bridge changes. See TESTING.md
for live verification; **only static/synthetic checks are claimed**.

## Animation6 testing — rounded light leaks

The `development/skillchains-resonance-animation7` branch updates
only the Skillchains HUD. Its two new tintable mirrored PNGs
(`images/resonance/edge_flare_left.png`, `edge_flare_right.png`)
replace the vertical fill-end sprites. Their rounded feet track the
fill's bottom while the plume extends upward. Confirmed skillchains
keep the existing bar/track visible beneath a white sweep that grows
from the far left, and center pulses use the midpoint color of the **currently
displayed fill**, including its property transition. Frame-to-frame FX hide/show cycles are removed and
hidden opener gradient primitives are skipped to investigate the
reported hitch.

Existing `//sc anim preview opener|level1|level2|level3|level4`
and `//sc anim intensity|flare|glow <0-2>` controls remain.
Saved settings are retained; TargetSC native/bridge behavior is
unchanged. To verify or regenerate the authored PNGs from source,
run `python3 tools/generate_edge_flares.py --check` or omit
`--check` to regenerate. **Only synthetic tests so far**;
please report in-game clipping, continuity and frame pacing.

## Animation4 unified pre-window preview

The `development/skillchains-resonance-animation5` branch tests
the common three-beat white expansion → white fade → colored
pre-decay flare transition for all chain levels. Level-2/3 traveling
flares removed; level-4 flicker preserved. Edge flares and glow
rails are inset horizontally to fit rounded bar ends. User-preferred
initial intensity/flare/glow settings are 2/2/2; saved settings
remain untouched. TargetSC 0.1.0 is unchanged. See TESTING.md.

## Current Skillchains Animation3 test — 2026-10-19

The `development/skillchains-resonance-animation4` testing branch
contains **Skillchains-only** changes. TargetSC's native DLL,
target-bound rings, synchronization events and Magic Burst detection
are unchanged. Use the paired `Skillchains-TargetSC-Animation3-test`
artifact, which contains both full installable addon folders and
cumulative `WORKFLOW.md` / `TESTING.md` inside each.

- **Learn icon column:** measured from actual bold-italic labels, with
  stroke/italic width allowance and a minimum 8px safety gap.
  Overlong names truncate ahead of the icons, even on small clients;
  current compact icon size is retained.
- **Opener:** rounded white expanding bar; caption and learning
  labels/icons fade in within the **first** beat. One leading white
  flare only. Underlying bar remains dark and translucent until
  revealed. SC continuation countdown remains source-clocked.
- **Confirmed chain:** raised side/end flares whose feet sit at the
  bottom of the fill; level 1 has no extra traveling flare; levels
  2/3 get one follow-up during the entire pre-window. Level 4
  keeps its provisional pulsing. Dim→bright fade is continuous.
- **Readability:** empty track keeps its original dark translucent
  alpha, even with optional `//sc anim fade on`; level 3/4
  halos now follow *both border rails* rather than washing out
  the bar's empty interior.
- **Independent icon adjustments:** `//sc names offset 5 -9`
  moves the entire caption as before. New
  `//sc icons offset 0 2` moves its property icons alone
  another two UI pixels down. `//sc icons offset` without
  coordinates reports the saved offset. Normal default SC
  icon baseline is already three scaled pixels lower.
- Newly initialized options favor the user-tested combination
  `intensity 1`, `flare 2`, `glow 1`, `fade off` and
  name offset (5,-9). Existing saved character settings are
  **not reset**. `//sc default` intentionally resets all options
  to the updated defaults.

**Live FFXI testing pending.** Earlier Animation2 visuals were
user-tested, but this refinement has passed Lua 5.1 and synthetic
regression tests only. The existing TargetSC DLL is compatible:
with it already installed you can update **Skillchains** files
and `//lua reload Skillchains` without closing FFXI. Always
close FFXI before replacing the DLL itself.

## Development update — Grid1 (2026-10-18)

The experimental `development/targetsc-resonance-grid` branch includes the
existing optional TargetSC companion and independently snapped HUD anchors.
The Skillchains version is `resonance.6-targetsc.1-grid.1`. **This is not
the known-good release.** Use the complete *Skillchains-TargetSC-Grid1-test*
testing artifact from [GitHub Actions](https://github.com/rerorriM-Mirrorer/Skillchains/actions/workflows/targetsc-grid-testing.yml)
for this branch; it contains both installable addons and their cumulative
README/WORKFLOW/TESTING documents.

Enter `//sc edit`, then drag either the SC bar or learning-panel handle.
Normal dragging stays free. Hold **left or right Ctrl** to snap that
widget's independent parent anchor to a shared (0,0)-origin UI-pixel grid.
Default spacing is 10 pixels; `//sc grid 16` changes it and
`//sc grid` reports the value. Changes are stored in existing character
configuration; `//sc default` resets the grid to 10. Scale-drag is unchanged.
No new mouse input interception, TargetSC renderer change, or game-state
change is included in Grid1.

Future synchronized "struck bell" animation and a composite SC/MB HUD
underbar are designed—but **not implemented**—in
[TargetSC/docs/SHARED_RESONANCE_PLAN.md](TargetSC/docs/SHARED_RESONANCE_PLAN.md).

## Skillchains Animation2 — live feedback refinements (2026-10-19)

**Development branch:** `development/skillchains-resonance-animation3`;
version `resonance.7-animation.2`. This is a **new testing build**, not
an in-game-validated release. The existing TargetSC 0.1.0 DLL, its Lua
renderer, world-space rings and bridge protocol are unchanged.

- Learning icons were oversized even after shrinking the requested sprite
  dimensions because Windower `images` texture `fit=true` can keep the
  original PNG's size. The new build uses **`fit=false`** and smaller
  0.78×font-size icons with space between them. The fixed property column
  still follows the longest current ability name. SC caption icons also
  use `fit=false`.
- Windower text and stroke have **separate alpha channels**. Both now fade
  together on the SC caption and Learn suggestions; previously the dark
  outlines remained visible while the letters were transparent.
- The opener now has **only one expanding white bar and soft leading flare**
  in its first beat. The actual SC track, dark border and fill stay hidden
  behind it. The white bar fades over the second beat as the dim, **primary
  weapon-skill property only** appears. If that primary property has multiple
  elements, it retains its own gradient. Names, timers and learning actions
  fade in throughout the **second** beat, not the third. At the *real*
  continuation-window opening, that same fill brightens as its already-
  corrected countdown begins.
- Successful chains keep the brief white impact/expansion and frame
  brightening, but the property fill **blends over approximately 0.55s**
  from the previous resonance to the new result instead of switching
  instantly. Level 1 makes one soft flare traverse the full three-second
  pre-window; level 2 makes two (about 1.5s each); level 3 makes three
  (about 1s each). Travel ends when the continuation window opens.
  Level 4 keeps an explicitly **provisional** three-pulse / flicker
  treatment, deferred until available in actual gameplay.
- The soft flare and halo sprites are the original procedural
  `ghost_flare.png` / `ghost_glow.png` from our EnemyBar2 work,
  now included locally under `Skillchains/images/resonance/`. No
  EnemyBar2 runtime dependency. Solid rectangular light glows were
  replaced by tapered alpha-gradient textures; the solid white
  opener bar remains intentionally rectangular.
- New persisted tuning: `//sc anim flare 0-2` and
  `//sc anim glow 0-2`. Existing `//sc anim intensity 0-2`,
  `//sc anim fade on|off`, `//sc anim preview opener|level1|level2|
  level3|level4` and Ctrl+drag remain.

Use the paired `Skillchains-TargetSC-Animation2-test` artifact
from [the branch's testing workflow](https://github.com/rerorriM-Mirrorer/Skillchains/actions/workflows/targetsc-grid-testing.yml).
It contains both complete addon folders, `WORKFLOW.md`, `TESTING.md`,
and all PNG assets. **Do not replace a DLL while FFXI is running.** If
TargetSC 0.1.0 is already installed, replace only the Skillchains files
while preserving character `data/`, then `//lua reload Skillchains`.
Live screenshot and timing approval for this new batch are pending.

## Skillchains Animation1 test — latest development (2026-10-18)

Branch: `development/skillchains-resonance-animation2`; source based on the
previous Grid1/TargetSC companion branch. **Neither master nor TargetSC's
runtime/DLL is modified.** This is an experimental Skillchains-only animation
pass; the World/TargetSC rings and discs requested for a separate TargetSC
conversation are **not implemented here**. Magic Burst shimmer/underbar changes
and level-four-specific tuning are also deferred.

Install: use the paired `Skillchains-TargetSC-Animation1-test` GitHub Actions
artifact, containing complete `Skillchains/` and `TargetSC/` folders. If
you already have TargetSC 0.1.0 installed, you may replace **only**
Skillchains Lua/asset files and then `//lua reload Skillchains`; keep
`Skillchains/data/`. Close every FFXI client **before** you replace the
TargetSC DLL; it is binary-identical in this batch. Do not install
GitHub's generic repository source ZIP.

### Animation controls

| Command | Effect |
| --- | --- |
| `//sc anim` | Report animation state, intensity and countdown-opacity wave |
| `//sc anim on/off` | Enable/disable transient glow, flares and entrance effects |
| `//sc anim intensity 1.5` | Scale visibility 0–2 (default 1.0) |
| `//sc anim fade on/off` | Optional soft oscillating countdown-opacity fade; off by default |
| `//sc anim preview opener` | HUD-only preview of opening triple-beat white→property strike |
| `//sc anim preview level1/level2/level3/level4` | HUD-only chained-result sample; no actual spell/weapon skill |
| `//sc anim preview off` | End the local preview |

The opener stages occupy the **actual pre-window delay** (typically about 3s)
rather than inventing time. A left-to-right white sweep and leading flare,
fading white wash and white pulse, followed by a property-colored pulse and
fading labels reveal the underlying SC fill. Its **displayed timer now
holds at full value until the real continuation window opens**. Server
deadlines and TargetSC events are unchanged.

On a confirmed skillchain, an initial white expansion/shimmer brightens the
border. A level-1 border adopts the resulting property shade; level-2 is
white; level-3 receives a persistent faint white halo; level-4 has a
provisional gold outline and stronger flicker (tuning deferred until live
level-four gameplay). Left/right colored flares and moving flares follow the
actual shortening bar. Animation effects use a fixed primitive pool and do
not create a new sprite every rendered frame.

Learning-mode property icons now match the ability text size, with more
space between multiple icons. Every row shares an icon **starting column**
placed after the longest currently available ability name; screen clamping
prevents off-edge positioning. The SC bar caption icon is smaller and lowered
toward its label's baseline, respecting the saved bar anchor and name offset.

**Not tested in FFXI yet.** Previous Grid1 free drag/Ctrl drag, scaling,
modes, TargetSC bridge and native renderer remain in place; their previous
live-test requests remain applicable.

## Optional TargetSC companion (targetsc.1)

On the isolated `targetsc-companion-v0.1` branch, Skillchains can publish its
existing state to TargetSC's 3D ring renderer. Install the full Skillchains
folder with `targetsc_bridge.lua`; no DLL belongs in Skillchains. Existing bars,
learning suggestions, configuration and timing formulas are retained.

Load Skillchains, then TargetSC. `//sc targetsc` reports bridge status;
`//tsc sync` requests a fresh snapshot. Unloading TargetSC unsubscribes it.
See [TargetSC/README.md](TargetSC/README.md) for installation and previews.

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
| `//sc edit` or `//sc edit on/off` | Drag bar and learning panel freely; hold either Ctrl to snap their independent anchors |
| `//sc grid [pixels]` | Show/set shared screen-origin Ctrl+drag grid; default 10, range 1–200 |\n| `//sc center` | Center both UI objects within the current client's viewport |
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
Resonance UI testing changes authored by A (A) with user-directed design.
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

### 2026-10-19 — Animation8.1: prevent numeric saved glow-mask render errors
- Treat a saved numeric glow-level mask as text before matching enabled levels; simulate numeric `34`/`1234` settings and preserve Animation8 rendering.

### 2026-10-19 — Animation8: dark true-perimeter SC bar and seamless capsule halo
- Removed the old full-height white/gold frame behind translucent track; separated 1px upper/lower rails plus corner ends. The bar interiors are now truly dark, regardless of chain level.
- New shared-contour 3-part capsule halo with L4's pre-window electrical activity, L3 slower shimmer, property-tinted borders, and preserved successful-chain/opening white animations.
- Save track alpha/RGB and pre-window level strengths separately; independent reset commands preserve position. Hide empty learning panels. TargetSC unchanged; FFXI testing pending.

### 2026-10-18 — Grid1: Ctrl+drag positioning
- Introduce a shared UI-pixel grid anchored to screen (0,0) with floor
  snapping for either Ctrl key. Bar and learning panel retain independent
  saved anchors; internal primitives are never individually snapped.
- Preserve free drag, edit handles, existing viewport recovery, scale,
  bar width, property icons, TargetSC publisher events and all existing
  animation/timing behavior. Default spacing is 10 pixels, adjustable via
  `//sc grid [pixels]`. Keyboard observer does not consume inputs.
- Add synthetic dual-Ctrl, non-drag keypress, boundary, scale and multi-size
  tests. **No FFXI/Windows live verification yet.**
- Document the separate, future unified resonance animation plan alongside
  TargetSC; that work is not part of Grid1.


### 2026-10-18 — targetsc.1 optional state publisher (A.)
- Publish authoritative SC/MB deadlines and resolved property/tier metadata
  on state transitions; keep combat/UI behavior and per-client ownership.
- Observe confirmed Magic Burst messages for the companion, without resetting
  timers or independently interpreting combat in TargetSC.
- Retain the resonance.6 baseline; all new live integration tests are pending.

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
