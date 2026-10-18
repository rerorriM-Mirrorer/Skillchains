# Building and verifying TargetSC 0.1.0

The supplied module is a newly compiled Windows PE32/i386 DLL, not a renamed
reference binary. It has **not** been run inside FFXI/Windower.

## MinGW-w64 x86 (recommended / verified cross-compile route)

From this repository's root using GCC 13.2 MinGW-w64 i686:

```sh
i686-w64-mingw32-g++ -std=c++17 -O2 -Wall -Wextra -Wpedantic -Werror \
  -shared -static -static-libgcc -static-libstdc++ \
  -o TargetSC/libs/_TargetSC.dll TargetSC/src/TargetSC.cpp \
  TargetSC/src/exports.def -ld3d8
i686-w64-mingw32-strip --strip-unneeded TargetSC/libs/_TargetSC.dll
i686-w64-mingw32-objdump -p TargetSC/libs/_TargetSC.dll
```

The development host used the compiler's `-win32` executable variant. MinGW32
under MSYS2 can use `g++`/`strip` within its 32-bit shell. Link statically to
avoid a runtime dependency on separately installed MinGW DLLs. This module
resolves Lua 5.1 exports from LuaCore.dll at runtime; no Lua SDK/import library
is required. Direct3D8 headers/import libraries come with MinGW-w64.

Expected module export: exactly **luaopen__TargetSC**. Expected machine:
**IMAGE_FILE_MACHINE_I386**, optional header PE32. The supplied build imports
only **KERNEL32.dll** and **msvcrt.dll**. Never ship a 64-bit build.

## CMake / Visual Studio alternative (source provided; not compiled here)

With a 32-bit Windows toolchain and Direct3D8 SDK headers/libraries available:

```text
cmake -S TargetSC/src -B TargetSC/build -A Win32
cmake --build TargetSC/build --config Release
```

Depending on generator, the DLL may be under `TargetSC/libs/Release/`; copy it
to `TargetSC/libs/_TargetSC.dll`. CMake checks pointer width. The GCC discovery
wrappers have a standard COM-call fallback for MSVC; that route is **unverified**.

## Reproduce checks and package

From repository root (Lua 5.1 and Python 3):

```sh
luac5.1 -p Skillchains.lua targetsc_bridge.lua skills.lua resonance_ui.lua learning_ui.lua
luac5.1 -p TargetSC/TargetSC.lua TargetSC/resonance.lua
lua5.1 tools/test_learning_ui.lua
lua5.1 TargetSC/tests/test_resonance.lua
lua5.1 TargetSC/tests/test_addon.lua
lua5.1 TargetSC/tests/test_missing.lua
git show e095657a2e7ecc5a49d05e96c1b78523a4860af5:Skillchains.lua > /tmp/skillchains-baseline.lua
lua5.1 TargetSC/tests/test_skillchains_regression.lua /tmp/skillchains-baseline.lua
python3 tools/package_targetsc.py
```

Package verification checks the DLL header, full file manifest/CRC, required
native/source/license files, all 14 PNGs and exclusion of user data. The two
installable folders each carry README, WORKFLOW, TESTING and generated build
information. The ZIP's file order starts with each TESTING.md.

Reference source commits and the exact SceneHook header SHA-256 are in
`THIRD_PARTY_NOTICES.md`. Regenerating the binary changes its hash if compiler,
linker or PE metadata changes; package BUILD_INFO records the delivered bytes.

## Native runtime checks still required

Lua C API binding, COM device discovery with the user's D3D wrapper, depth-buffer
behavior, SceneHook coexistence/owner handoff, device reset, animated/floating
model anchoring and 4–6-client FPS have not been validated on this Linux host.
No emulated native invocation or screenshot is claimed as an in-game test.
