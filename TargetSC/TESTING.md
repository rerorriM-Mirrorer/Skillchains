# TargetSC TESTING.md — start here

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
- No TargetSC live observations or user test logs have yet been received.

Preserve this cumulative record. Corrections use strikethrough, reason and
replacement rather than deleting history.
