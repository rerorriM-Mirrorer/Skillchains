# TargetSC Test3 request and delivery review — A, 2026-10-19

Baseline: Test2 5d23e29 from the GitHub development branch. Current root/nested
AGENTS, WORKFLOW and TESTING were read directly from GitHub before edits.
Bridge fix commit aaf233f; paired Lua/native feature commit 0d40912. Package
BUILD_INFO.json records the exact final committed source and native hash.

- Fixed all subscription, ready, event and unsubscribe dispatch to lua c. The
  new simulation loads both actual addon handlers, distinguishes invocation
  from command dispatch, and exercises load order, reload, snapshots and stop.
  This verifies the documented host model, not Windower itself.
- Skillchains.lua, resolver/data, HUD modules, FX and all images are unchanged
  from Animation8 e3a8b63. The package builder restricts publisher differences
  to the two exact command-token corrections. No source deadline is changed.
- Preserved source-created phase timing and target identity gating. Shared
  world-space strike amplitude/damping controls appearance/opening; opener
  fall removed. Sky loses strike wobble while descending; ground keeps a
  separately controlled settled hum with declining frequency and level gain.
- Snapshot numeric defaults and explicit reset/discs-on/discs-off presets are
  implemented. The changed world-space meaning of amplitude is documented;
  no claim is made that old height-dependent displacement remains identical.
- Full palettes survive on opening properties. Opener alternatives are inner
  concentric rings; result hierarchy is one / two vertical / three vertical /
  four concentric rings. A level is independent of the link/weapon-skill count.
- Native geometry extends joined circles with color sectors; fill and glyph
  outlines rotate together. Glyph has a circle rim, full rim-reaching cross,
  pointed star and central square, plus a transparent outline-only option.
  It is a procedural interpretation, not an exact resource texture copy.
- Property layers appear with the one expanding white awakening disc; primary
  overlaps the unfilled ground glyph, alternatives are smaller and above it.
  Later small pulses are removed. Awakening is independently switchable from
  persistent discs. Opacity controls distinguish colored fill from white lines.
- Disc angle is the integral of slowing velocity: no reversal or angle jump.
  Starting speeds remain .5/1/2/4 turns/sec, L4 stationary. Ground hum and spin
  reach zero speed at the actual continuation deadline; settled hum amplitude
  stays independent. Natural expiry freezes/fades existing ring positions.
- Closed chains have a visual terminal fade without an invented continuation.
  The independent MB reminder halo and confirmed-burst effect queue remain.
  No burst redesign or clock mutation. Full demo injects no burst events.
- Five-hit cooperative Umbra demo lands at 0/9/17/24/30s, each extension one
  second before the previous deadline. Existing skills, aeonic_prop and
  check_props validate the actual property progression. Anguta with qualifying
  Aeonic Aftermath is an explicit condition, not an assumed all-job sequence.
- Native scene/device discovery, depth test/no depth writes, complete state
  restoration, SceneHook header/ABI, stale-frame watchdog and Lua identity gates
  are unchanged. Native storage remains bounded: 32 bands, 8 discs, 18,240
  vertices, one DrawPrimitiveUP submission. No new texture/D3DX dependency.
- Lua 5.1 parse, original HUD/asset checks, source deadline regression, actual
  addon lifecycle and command/native-argument simulation, motion sweeps,
  portable stroke/property math, strict x86 compilation and binary inspection
  passed locally. Records are test3-lua-tests/native-build/native-inspection.
- GitHub Actions is configured for Test3 but was not run for these local commits.
  Automatic approval review blocked publishing to the GitHub remote. No push or
  remote CI success is claimed. All unaffected local deliverables are completed.
- FFXI/native loading, actual visual feel, model/floating anchoring, live sync,
  clipping, SceneHook owner handoff, device reset and multibox frame pacing
  remain user tests. Test2 preview approval is not Test3 live acceptance.
