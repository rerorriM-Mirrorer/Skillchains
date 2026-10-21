# Building and verifying TargetSC 0.5.0 / Test5

Native API 0.5.0 interprets the optional eleventh `ring` argument as the size of
EACH of two opposite gaps. With gap=12 the 64 segments span open arcs 6–174
and 186–354 degrees (66 points total, independent end caps). Closed circles
remain on the original periodic path. Vertex storage remains 18,048 vertices,
one draw call, SceneHook ABI 2. New Lua requires native 0.5.0.

Previous API/build notes are retained below as history:

# Building and verifying TargetSC 0.4.0 / Test4

Native API 0.4.0 adds an optional eleventh `ring` argument, gap degrees (0–60).
New Lua requires this DLL; older Lua callers can still omit the argument.
Open rings use 65 points/64 segments with exact endpoints and unjoined caps.
Closed rings and glyph rims retain the original periodic path. Vertex storage
remains bounded at 18,048 vertices, one draw call; SceneHook ABI 2 is unchanged.
Native status retains `glyph=traced`. See TESTING.md for installation/comparisons.

The following historical 0.3.0 API remains otherwise unchanged:

# Building and verifying TargetSC 0.3.0 / Test3

Author: A. The DLL is PE32/i386. Host compilation, Lua simulations and portable
CPU geometry tests do not demonstrate Windows loading, D3D or FFXI rendering.
SceneHook ABI/header 2, native display tracking and scene lifecycle are preserved.

## x86 build

```sh
i686-w64-mingw32-g++ -std=c++17 -O2 -Wall -Wextra -Wpedantic -Werror \
  -shared -static -static-libgcc -static-libstdc++ -Wl,--no-insert-timestamp \
  -o TargetSC/libs/_TargetSC.dll TargetSC/src/TargetSC.cpp \
  TargetSC/src/exports.def -ld3d8
i686-w64-mingw32-strip --strip-unneeded TargetSC/libs/_TargetSC.dll
i686-w64-mingw32-objdump -p TargetSC/libs/_TargetSC.dll
```

The development host uses the installed GCC 13.2 `-win32` executable variant.
Expected: sole `luaopen__TargetSC` export, i386/PE32, only KERNEL32.dll and
msvcrt.dll imports; LuaCore.dll exports resolve dynamically. No texture loader,
D3DX or extra runtime DLL. Close every client before replacing the DLL.
CMake remains available; its Visual Studio route has not been verified.

## Native API 0.3.0

```lua
native.version() -- '0.3.0'
native.start()
native.begin(entity_index, entity_id)
native.ring(radius, height, world_width, argb, minimum_pixels,
            sector_count, argb2, argb3, argb4, rotation_radians)
native.disc(radius, height, rotation_radians, fill_argb, glyph_mode,
            outline_argb, sector_count, argb2, argb3, argb4)
native.commit()
native.clear()
native.status()
native.stop()
```

`sector_count` is 1–4; unused colors may repeat the first. Each sector uses the
same circle centerline, joints, rotation and depth. It changes color exactly at
its boundary, without blending separate arc endpoints. Disc sectors and glyph
rotate together. Glyph mode: 0 plain fill, 1 fill plus glyph lines, 2 glyph lines
only. Fill and outline ARGB are independent; no hidden solid glyph background.
The glyph contains circle rim, full border-reaching cross, pointed star and
central square from normalized procedural line geometry.

Ring pixel widening retains projected centerline z/rhw and bounded joins.
Scene depth test/no depth writes and full stateblock restore remain. Maximum
work: 32 ring bands, 8 discs, 18,240 vertices (~356 KiB), one triangle-list draw
call, no per-frame heap allocation in native rendering. Source coordinates are
resolved each scene frame; Lua identity/health gates and 250ms stale-frame
watchdog are retained. Other SceneHook ABI 2 addons need no rebuild solely for
TargetSC's own API update. Test2 Lua/DLL intentionally fail the Test3 version
guard: install the complete matching folder.

## Reproduce host verification

```sh
for f in Skillchains.lua skills.lua resonance_ui.lua resonance_fx.lua learning_ui.lua targetsc_bridge.lua TargetSC/*.lua TargetSC/tests/*.lua; do luac5.1 -p "$f"; done
lua5.1 tools/test_learning_ui.lua
lua5.1 tools/test_visual_commands.lua
lua5.1 TargetSC/tests/test_motion.lua
lua5.1 TargetSC/tests/test_transport.lua
lua5.1 TargetSC/tests/test_resonance.lua
lua5.1 TargetSC/tests/test_addon.lua
lua5.1 TargetSC/tests/test_missing.lua
lua5.1 TargetSC/tests/test_missing.lua mismatch
git show e095657a2e7ecc5a49d05e96c1b78523a4860af5:Skillchains.lua > /tmp/sc-baseline.lua
lua5.1 TargetSC/tests/test_skillchains_regression.lua /tmp/sc-baseline.lua
g++ -std=c++17 -Wall -Wextra -Wpedantic -Werror -o /tmp/tsc-stroke TargetSC/tests/test_stroke.cpp
/tmp/tsc-stroke
g++ -std=c++17 -Wall -Wextra -Wpedantic -Werror -o /tmp/tsc-property TargetSC/tests/test_property.cpp
/tmp/tsc-property
python3 tools/generate_capsule_halo.py --check
python3 tools/test_capsule_halo.py
python3 tools/package_targetsc.py
```

Package only a clean committed checkout. The builder enforces Animation8 HUD/
combat/asset identity, permits exactly the two command-dispatch publisher fixes,
and validates PE32, manifests, hashes, PNGs, archive structure and CRC. It records
the exact source commit and native DLL hash. `docs/verification/test3-*` contains
local records. GitHub Actions is configured but a local pass is not an Actions
run, and a local package is not proof of publishing. Gameplay/SceneHook handoff/
device reset and multibox frame pacing remain live tests.

---

## Historical Test2 build instructions (superseded)

# Building and verifying TargetSC 0.2.0 / Test2

Author: A. The new DLL is PE32/i386. Compilation, binary inspection and portable
stroke-math tests do **not** demonstrate native loading or live FFXI rendering.
SceneHook ABI 2 is unchanged and byte-identical to the Test1 references.

## MinGW-w64 x86 (verified cross-compile route)

From the repository root using GCC 13.2 MinGW-w64 i686:

```sh
i686-w64-mingw32-g++ -std=c++17 -O2 -Wall -Wextra -Wpedantic -Werror \
  -shared -static -static-libgcc -static-libstdc++ -Wl,--no-insert-timestamp \
  -o TargetSC/libs/_TargetSC.dll TargetSC/src/TargetSC.cpp \
  TargetSC/src/exports.def -ld3d8
i686-w64-mingw32-strip --strip-unneeded TargetSC/libs/_TargetSC.dll
i686-w64-mingw32-objdump -p TargetSC/libs/_TargetSC.dll
```

Linker image-base selection and strip timestamps can vary by output path/time;
BUILD_INFO records the delivered binary hash rather than promising identical
bytes across rebuild locations.

The development host uses the `-win32` executable variant. Expected sole export:
`luaopen__TargetSC`; expected machine I386/PE32; imports only KERNEL32.dll and
msvcrt.dll. The runtime resolves LuaCore.dll exports dynamically. No Lua SDK,
D3DX, texture loader or third-party runtime DLL is needed. Never install an
x64 build. Close every FFXI client before replacing the native DLL.

CMake source is included (Visual Studio route unverified, as in Test1):

```text
cmake -S TargetSC/src -B TargetSC/build -A Win32
cmake --build TargetSC/build --config Release
```

A multi-configuration generator may emit `libs/Release/_TargetSC.dll`; its
install location must be `TargetSC/libs/_TargetSC.dll`.

## Native API 0.2.0

```lua
native.version()                         -- "0.2.0"
native.start()
native.begin(entity_index, entity_id)     -- clears inactive complete snapshot
native.disc(radius, height, radians, argb, glyph_0_or_1)
native.ring(radius, height, world_width, argb, minimum_viewport_pixels)
native.commit()                          -- atomic lock-protected publication
native.clear()
native.status()
native.stop()                            -- drains/unregisters callback
```

Frames are capped at 32 ring bands (including glows) and 8 discs. There is one
triangle-list submission, no per-frame heap allocation and about 0.35 MiB of
module-owned reusable vertex capacity. The native thread resolves the display
position every scene frame; Lua identity/health gating and the 250ms stale
frame watchdog remain unchanged. Disc fill, projected white border and rotating
four-point star are geometry; exact game property icon art is not reproduced.

Stroke centers are projected with current view/projection/viewport state. A
bounded miter offsets each projected centerline point by at least half the
configured pixel width. Both sides keep its projected depth and reciprocal w.
Near-plane/hidden/degenerate parts are culled; rings are not drawn through
walls. D3D8 state-block restore includes textures/shaders/stream 0. Depth writes
stay disabled. Glyph rotation is in the horizontal world plane.

Old Lua rejects native API 0.2.0; new Lua rejects the old DLL with useful status.
Update the complete TargetSC folder together. Other SceneHook ABI 2 addons do
not require recompilation merely because TargetSC's own API version changed.

## Reproduce automated checks

From the repository root:

```sh
luac5.1 -p TargetSC/*.lua TargetSC/tests/*.lua
lua5.1 TargetSC/tests/test_motion.lua
lua5.1 TargetSC/tests/test_resonance.lua
lua5.1 TargetSC/tests/test_addon.lua
lua5.1 TargetSC/tests/test_missing.lua
lua5.1 TargetSC/tests/test_missing.lua mismatch
g++ -std=c++17 -Wall -Wextra -Wpedantic -Werror -o /tmp/tsc-stroke TargetSC/tests/test_stroke.cpp
/tmp/tsc-stroke
lua5.1 tools/test_learning_ui.lua
lua5.1 tools/test_visual_commands.lua
python3 tools/generate_capsule_halo.py --check
python3 tools/test_capsule_halo.py
git show e095657a2e7ecc5a49d05e96c1b78523a4860af5:Skillchains.lua > /tmp/sc-baseline.lua
lua5.1 TargetSC/tests/test_skillchains_regression.lua /tmp/sc-baseline.lua
python3 tools/package_targetsc.py
```

The new motion sweep covers 8 properties × 3 motions × 3 layouts × 1051 frames.
The stroke test executes 2304 projected ellipse/width combinations, checks
bounded joins, subpixel widening and degenerate points. These are portable CPU
math tests, **not native-DLL invocation, D3D execution or live game tests**.

The package builder checks that Skillchains runtime/bridge/assets are identical
to e3a8b63, curates the two complete addon folders, validates PNGs, PE32 DLL,
archive CRC and SHA manifests, and records the exact delivered commit and DLL
hash in BUILD_INFO.json. Only committed files are packaged; user data excluded.

Records are in `docs/verification/test2-*`; original Test1 records are preserved.
