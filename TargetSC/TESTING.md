# TargetSC TESTING.md — start here

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
