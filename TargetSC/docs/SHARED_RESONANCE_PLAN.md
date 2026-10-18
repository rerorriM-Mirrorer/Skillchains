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
