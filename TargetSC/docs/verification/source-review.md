# Test1 source review

Reviewed against the user's 2026-10-18 TargetSC request. No live FFXI test.

- Correct personal baseline e095657 and current AGENTS/WORKFLOW/TESTING read
  directly from GitHub before edits. New isolated branch preserves that branch
  and master. Existing observations/history retained in root TESTING.md.
- Skillchains action/timer formulas and existing UI modules are unchanged.
  Additions are optional publication, lifecycle commands, resolved-tier metadata
  and a confirmed-burst observer in the existing action callback. No injections.
- No combat packet parsing/listening exists in TargetSC. Its only simulated
  deadlines belong to explicit preview mode. Live state uses source timestamps.
- Transport uses local lua-i messages at transitions/snapshots/lifecycle only.
  TargetSC's native begin/ring/commit calls never use console or IPC. Sequence
  gap recovery requests a snapshot and remains throttled while awaiting it.
- Colors follow source element associations with explicitly requested high-tier
  artistic palettes. Confirmed unknown-element nonspell bursts are skipped and
  counted; reliable source/resource support can extend this later.
- Lua identity/index/health gate and cutscene/zone/reset logic clear visual
  state. Native display following reads positions each scene; real movement,
  despawn races and model-height calibration remain unverified.
- Native snapshots are lock-protected, bounded to 24 bands, with a 250ms stale
  frame watchdog. Correct projected depth is supplied and depth writes disabled.
  Complete stateblock restore includes shaders/textures/stream 0. Failed capture
  skips drawing; configuration/restore failures increment status counters.
- SceneHook header is unchanged and byte-identical to both references. Normal
  stop drains/unregisters; DLL detach unconditionally unregisters without waiting.
  Device discovery and wrapped-device COM handling derive from TargetRing.
- Module compiled with all requested warnings treated as errors. PE32/i386,
  one Lua export, no MinGW runtime DLL imports. This is compilation/inspection,
  not a Windows loader, Windower, D3D, SceneHook or native runtime smoke test.
- Height uses clamped model-size/scale estimates rather than exact animated
  mesh bounds; this limitation and controls are explicit in README/TESTING.
- Source/licensing/build instructions, actual test output and exact commit/hash
  metadata accompany a complete two-folder package. Settings/user data excluded.
