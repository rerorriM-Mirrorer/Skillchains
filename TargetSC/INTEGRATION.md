# TargetSC unified Test2 — installation and validation

This development build is **not a public release**. Test2 additionally fixes secondary AoE/Trust weapon-skill target tracking and allows `//tsc sc display off` with `//tsc sc mode learn` to retain only the helper and world rings. Use `//tsc sc trace on|off` for target-specific action diagnostics. The original Test1 package remains the fallback.

 It merges the existing
Skillchains combat engine, HUD bars and learning display into one Windower 4
addon. No combat timing or visualization formulas were changed.

## Installation

1. Back up `Windower/addons/Skillchains/data/` and
   `Windower/addons/TargetSC/data/`, and retain the previous complete
   working paired build for rollback.
2. Close **every** FFXI client if replacing `_TargetSC.dll`.
3. Install the zip's `TargetSC/` folder under `Windower/addons/`.
   Do **not** merge source files into the old Skillchains folder.
4. Unload or disable standalone Skillchains from auto-load/profile scripts.
   If it is already loaded, use `//lua unload Skillchains`.
5. Run `//lua load TargetSC` (or reload if already loaded).
6. Run `//tsc status`, `//tsc sc status`, `//tsc sc help`,
   `//tsc preview demo`, then test a real weaponskill chain.

## Settings and commands

Original TargetSC settings remain at `TargetSC/data/settings.xml`. On first
load only, if `TargetSC/data/skillchains-settings.xml` does **not** exist
and `Skillchains/data/settings.xml` is still present, an untouched copy is
imported into the new file. Existing character-specific entries are preserved.
The source file is never modified. Keep both files backed up.

All existing TargetSC bell commands remain `//tsc ...`. Original Skillchains
HUD/learning commands are now `//tsc sc ...`: for example,
`//tsc sc edit on`, `//tsc sc mb text off`, `//tsc sc mode learn`,
and `//tsc sc demo`. The old `//sc` alias is not yet supported by the merged
addon. Source and bell demos are separate previews; compare real combat
rather than assuming the two independent demos start at the same frame.

Disable **3D only** with `//tsc off`: the embedded Skillchains engine and HUD
continue running; `//tsc on` resubscribes the renderer to a full snapshot.
The native renderer is optional for HUD operation.

## Technical layout

- `TargetSC.lua`: Windower entry point; native scene rendering and visual
  controls. Loads `sc_runtime.lua` once.
- `sc_runtime.lua`: Skillchains Animation8.8 action listener, SC/MB clocks,
  UI/learning rendering, and command handler (preserved logic).
- `targetsc_bridge.lua` and `targetsc_local.lua`: old event producer with
  same-process callback transport; no separate Windower addon/IPC.
- `resonance.lua` and `resonance_motion.lua`: unchanged visual state model
  and drawing geometry, driven by Skillchains source timestamps.
- `images/` and `libs/_TargetSC.dll`: retained HUD art and x86 native module.

This first implementation retains bridge-v1 serialization **inside** the
process to limit change scope. A future pass can replace it with structured
in-memory messages once live parity has been demonstrated. Neither stage
should add independent combat timers.

## Critical live checklist

- Verify real opener, L1/L2/L3/L4 transitions, a confirmed elemental MB,
  a late MB near its source close, and expiry of both independent windows.
- Verify world/HUD mode toggles and independent previews on same client.
- Verify target switch, entity recycle/death, moving/floating/huge enemies.
- Verify zone/logout/reload with no ghost rings or stale bars.
- Verify solo and multibox memory/FPS; TargetRing/TargetLines coexistence.
- Verify the old Skillchains XML profile imported without changing the source;
  reload and job switch to confirm persistence.
- Check the error path when `_TargetSC.dll` is absent, and confirm HUD still works.
- Confirm only **one** action listener is active (unload standalone Skillchains).

## Rollback

Close clients for DLL replacement, restore your original backed-up folders,
and load the previous known-good Skillchains + TargetSC pair. Integration
never writes to the old Skillchains folder. Preserve both data files.
