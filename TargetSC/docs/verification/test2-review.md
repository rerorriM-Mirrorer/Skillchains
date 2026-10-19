# TargetSC Test2 delivery review — A., 2026-10-19

- Correct baseline/branch e3a8b63 identified; current root and TargetSC agent,
  workflow and cumulative testing guidance read from GitHub before changes.
- All production Skillchains Lua, v1 bridge and image assets match Animation8
  byte-for-byte. HUD L2 contrast/preparing-white observations are retained only.
- All live phase boundaries derive from source created/sc_open/sc_close/
  mb_close. Pre-window stages normalize to actual delay; success uses the
  same 0.30s boundary-centered color transition as the current HUD.
- Discrete vibration toggles held offsets by source-relative sample index.
  Exponential damping and remaining separation control its envelope. Sine and
  original legacy motion remain available; ground/center layouts are explicit.
- New property discs are bounded procedural geometry with spinning star/circle
  styling. Their appearance is an approximation, not exact resource icon art.
  No image generation, native texture loader or extra runtime library is used.
- Native screen strokes preserve centerline z/rhw, clip invalid points, limit
  joins and retain scene depth testing/no depth writes/full stateblock restore.
  32 ring bands/8 discs/one draw call; reusable bounded vertex storage.
- Native identity/display tracking, stale-frame watchdog and unconditional
  DLL-detach SceneHook unregister remain. SceneHook ABI/header unchanged.
- Native API 0.2.0 is intentionally distinct from bridge v1/SceneHook v2.
  Missing/old DLL gives explicit diagnostics; install complete TargetSC together.
- New openers clear predecessor/burst geometry; successful chains recharge
  without changing deadlines. Snapshot state retains phase and source age.
- MB style/origin redesign deferred. Existing confirmed-element queue and
  independent MB expiry are preserved; no countdown reset on a burst.
- Lua, lifecycle, bridge, HUD, PNG, native CPU stroke math and x86 build/PE
  checks passed locally. No new D3D execution/native loader/FFXI test is claimed.
- Package builder rejects modified Animation8 runtime/assets and dirty
  checkouts, and validates full manifests, SHA/CRC, 14 icons and 3 halo textures.
- User Test1 rendering and Animation8 preview approval are recorded separately
  from Test2's remaining live tests, not promoted to full gameplay acceptance.
