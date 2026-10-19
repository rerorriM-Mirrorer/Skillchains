# Shared resonance plan — reconciled 2026-10-19 (A.)

## Current reference and scope

Skillchains Animation8 at **e3a8b632e29eeebdbd4455da470810a9574a7ddd**,
`development/skillchains-resonance-animation9`, version
`2.20.08.25-resonance.7-animation.8`, is the user-accepted preview reference.
The opener, genuinely transparent interior, narrow perimeter, seamless capsule
halo, slow L3 shimmer and strong pre-window L4 gold flicker are working well.
Gameplay remains the next calibration source; preview approval is not a claim
of fully accepted live timing. L2 gradient contrast and subtle preparing-white
flicker are observations to retain, **not HUD edits in this TargetSC batch**.

The earlier plan below predates Animation8. Its 0.2s center-out HUD opener,
brightness-only high-tier plan and proposed composite MB underbar must not
replace the successful current HUD. Retain them as historical design notes.

## One authoritative timeline, separate presentations

| Source phase | Preserved Animation8 HUD | TargetSC 0.2.0 test |
| --- | --- | --- |
| Opener impact/charge | White grow/reveal into primary property | White expanding ground disc and falling/concentric ground rings; property glyph reveal |
| Opener sc_open | Begin true countdown | Spawn sky, quick rise and damped flutter, then converge toward ground/center |
| Confirmed successful chain | White refill during charge | White consolidation/recharge; sky restores from previous separation |
| Result sc_open boundary | 0.30s white-to-result transition | Same boundary-centered 0.30s ring color change; no timer shift |
| L3/L4 charge and decay | Restrained slow white / strong fast gold perimeter | Related slow/fast ring modulation, stronger visible cores and minimal surrounding light |
| Continuation expiry | SC expires; independent MB remains | Rings meet/flash/fade; MB-only visual persists when eligible |
| Confirmed burst | Existing HUD behavior unchanged | Existing central shimmer/ripple unchanged for this iteration |

TargetSC computes phases from source-created/sc_open/sc_close/mb_close.
Pre-window visual thirds scale with the actual source delay; they do not add
another 3-second combat wait. Explicit local previews use chosen synthetic
source states and never publish through the bridge or alter gameplay.

## Experimental choices

Default test: scale 2, grounded layout, discrete alternate positions held .15s,
amplitude .28 model heights × intensity 2, exponential damping .85/sec. Sine
and legacy motion remain comparison modes; symmetric/center layouts remain
experimental. The sky's envelope converges continuously; **flutter offsets
jump without interpolation**. L3 slows the alternation and L4 speeds it up.

A narrow 2px screen core with independent opacity/brightness/glow improves
visibility. The 1px floor is configurable upward and independent of model scale.
Projection retains world perspective, correct depth and clipped/occluded arcs.
Property discs are bounded procedural circle/star glyphs, not exact icon art.
Further elemental assets can replace/enrich them once movement is accepted.

Keep protocol v1 and all Skillchains runtime code/assets unchanged. Discs and
pixel strokes require TargetSC native API 0.2.0 but **do not** change SceneHook
ABI 2 or require other addons to be rebuilt. Preserve identity checks, scene
state restoration, unload handoff and native stale-frame watchdog.

Next acceptance gate: user tests individual phases on real models, compares
motion/layout presets and adjusts width/brightness before extending MBs or
adding target-specific dimensions. No fake native runtime testing is claimed.

---

## Historical Grid1 proposal (preserved)

# Shared resonance presentation — coordinated Skillchains + TargetSC plan

Status: design proposal, not implemented by the Grid1 change. Author: A.
Source of truth: `Skillchains.lua`, with TargetSC receiving optional transition
events through `targetsc_bridge.lua`. Keep both addons usable independently.
This plan follows the user-approved "struck bell" model and the composite bar
direction. Gameplay acceptance remains required before promotion to master.

## One event / two presentations

| Confirmed source event | Skillchains HUD | TargetSC world overlay |
| --- | --- | --- |
| Weapon-skill opener | 0.2s center-out strike ripple into existing SC fill | Initial central strike, opening target-bound strands |
| Successful skillchain | Brief reinforced glow; border adopts a persistent level-based brightness | Existing collapsed/reopened rings reinforce in result palette |
| New MB opportunity | Semi-transparent white MB underbar behind SC fill; independent expiry | Existing faint central MB halo |
| Confirmed Magic Burst | A brief element-colored shimmer travels through MB underbar | Existing spell-element ripple from same `burst` event |
| Continuation expiration | SC fill expires; MB underbar remains if its deadline is later | SC strands converge; MB halo remains when eligible |
| MB expiration / target loss | Fade/purge relevant visuals without extra timer | Existing renderer clears at same absolute deadline |

Do not imply the skillchain and burst windows are identical or mutually exclusive:
their clocks overlap and can differ. A burst does not consume or restart the
source's countdown. One combined HUD **object** may contain two independent
fills. The MB underbar must be allowed to remain visible after an SC fill ends.
A closed chain has no valid continuing SC fill but may keep an MB tail.
An opener has no MB underbar.

## Cross-addon synchronization contract

`targetsc_bridge.lua` already sends: target ID, revision, created timestamp,
`sc_open`, `sc_close`, `mb_close`, result level, properties, and confirmed
`burst` element. Treat this as the authoritative time/identity contract. Extend
the local HUD render state to carry the **same** revision and created timestamp,
plus a small bounded burst event queue or latest burst event with per-target
sequence, timestamp and element. The optional TargetSC companion continues
consuming the same bridge events. No second combat parser, duplicated skillchain
resolver, cross-client IPC, packet injection, or per-frame bridge messages.

Animation phase is calculated from the source event's absolute timestamp and
shared deadlines, not from addon load time or packet receipt time. For a
reloaded addon or snapshot, restore the *remaining* bar/ring state but do NOT
replay the strike or shimmer. Target switching likewise must not invent a
fresh impact. Multiple actual bursts during one window may each trigger a
separate brief shimmer. If the element cannot be resolved from the actual
action, display a neutral confirmation or skip tint; never guess from the SC
property. Do not reset an MB clock on a successful burst.

## Visual rules

- Keep a single shared screen-space bar anchor and a separate learning-list
  anchor. The new Ctrl+drag feature is strictly a layout change; target rings
  remain model-space and cannot meaningfully "snap" to a HUD grid.
- First hit: one restrained center-out pulse (~.2s). No continuous attention-
  seeking pulse once stable.
- Successful level 1/2 chain: brighter persistent border, with proportional
  brightness. Level 3: further brightness. Radiance/Umbra: reserve a special
  treatment until the user has genuine live access to level 4.
- MB: rear underbar uses pale translucent white, ideally peeking just below
  the front bar as in EnemyBar2. Its distinct clock drives remaining length.
  Actual confirmed burst briefly tints it with spell's element and sends a
  short outward ripple. Avoid a permanently colored MB underbar after burst.
- Preserve the selected result's full gradient family, existing property
  icon captions and Learn list. Default has no additional MB text timer; a
  user option can re-enable it if live testing exposes ambiguity.
- Minimal/quiet UI hides labels without hiding the timer and its event cues.
  When TargetSC becomes trustworthy in-game, support HUD, world, and hybrid
  presence without forcing TargetSC as a dependency.

## Implementation sequence / acceptance gates

1. **Grid1 (current change):** independent screen-origin Ctrl+drag snapping
   for bar and learning panel; preserve all previous behavior, packaging and
   TargetSC publisher unchanged. Simulated tests first; user live acceptance
   before merging to known-good branches.
2. **Shared events:** expose HUD event phase from Skillchains' already tracked
   revision/created and burst observations, without changing timer math.
   Add simulated per-target, reload, target-switch and packet-order cases.
3. **Composite bar:** merge visual SC and MB bars *only* in the display layer.
   Validate the two deadlines and MB-only tail with TargetSC using scripted
   identical state timelines; expose an opt-in display mode initially.
4. **Success/strike animations:** implement small deterministic HUD pulses and
   persistent level border states, synchronized with TargetSC transitions.
   Compare opener, chain, burst, closed chain, expiry and target-switch clips
   at 30/60 FPS; cap primitives and CPU/GPU work for 4–6 clients.
5. **Live tuning:** verify actual FFXI timing, native SceneHook rendering,
   element identification, resync, idle cleanup, model height and multi-client
   performance. Refine intensity/opacity/duration only from observations.
   Defer Radiance/Umbra-specific glow tuning until real level-4 gameplay.

All newly built work remains on testing branches until explicit live approval.
Do not declare user-accepted gameplay solely from Lua and Windows cross-builds.
