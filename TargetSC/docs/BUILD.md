# Building and verifying TargetSC 0.15.0 / unified Test7.25

Native API 0.15.0: `native.disc` takes optional args 19-23, a glyph shimmer:
world angle (radians; outside +-1e6 = none), half-width (radians, 0..pi), far
alpha multiplier (0..1), gain (0..1), count (1..4). A shimmered disc draws its
rim as 64 strokes and each glyph line as `kShimmerPieces` (8) strokes; every
stroke end takes `targetsc::shimmer_color(outline, shimmer_weight(angle))`
(cosine bell; far side alpha x far; the patch toward white and opaque by
gain). At most `kMaxShimmerDiscs` (4) discs per frame shimmer, later ones draw
plain. Args 17/18 must be sent (Lua: clip or 1e9, sliced 0/1). Bounded storage
47,760 vertices (`static_assert`). Note: `far` is a Windows macro, so the C++
parameter is `rest`. Build command unchanged (below); built 2026-11-23 with
Ubuntu's `g++-mingw-w64-i686` 13.2.0 (13-win32), sha256
`8296e3ce24bbb972d181b69b7026901f56f04febf9af3aa55b083349f6d3ce23`; PE32, sole
`luaopen__TargetSC` export, KERNEL32.dll + msvcrt.dll imports (Verified with
objdump). Close every client before replacing the DLL.

# Building and verifying TargetSC 0.14.0 / unified Test7.24

Native API 0.14.0: `native.disc` takes an optional 18th argument, sliced
center (1 = on). With a gradient (blend 1) fill, each of the 64 fan slices'
center corner takes that slice's own gradient color (`targetsc::sliced_center`
= `gradient_at` at the slice middle) instead of one shared averaged center, so
a clear sector stays clear to the center and lit sectors fade center -> rim
with `inner`/`outer`. Pass arg 17 outside +-1e6 (Lua sends 1e9) for no clip.
Everything else unchanged. Build command unchanged (below); built 2026-11-23
with Ubuntu's `g++-mingw-w64-i686` 13.2.0 (13-win32), sha256
`9f86cfb8fe4ecffc570060536b349a4a414d2e27f021cc9ee2fc25073fca0eb9`; PE32, sole
`luaopen__TargetSC` export, KERNEL32.dll + msvcrt.dll imports (Verified with
objdump). Close every client before replacing the DLL.

# Building and verifying TargetSC 0.13.0 / unified Test7.20

Native API 0.13.0: the property glyph is 20 lines (the 4 short cap lines that
ran along the circle at the cross-arm ends are removed; 3D glyph stagger keys
unchanged via `kGlyph3KeyDistance`). `native.disc` takes an optional 17th
argument, a clip angle in radians (east 0, north pi/2): only the glyph lines and
the rim on that side of the disc center are drawn (SC kill halves). Bounded
storage 43,920 vertices (`static_assert`). Build command unchanged (below);
built 2026-11-22 with Ubuntu's `g++-mingw-w64-i686` 13.2.0 (13-win32), sha256
`b3ceb95b6a905dbda1a33f3148a29decf4a6267ad176a059ad41076c1235d2f9`. Not byte-identical to builds from the earlier host (different
GCC packaging); PE32, sole `luaopen__TargetSC` export, KERNEL32.dll + msvcrt.dll
imports (Verified with objdump). Close every client before replacing the DLL.

# Building and verifying TargetSC 0.12.0 / unified Test6.1

Native API 0.12.0 adds `native.shift(east,north)` (a sideways offset stamped
on every ring/arc/disc/glyph added after it in the frame; `begin` resets it)
and `native.line(x1,y1,z1,x2,y2,z2,color,pixels)` (up to 8 straight lines,
target-relative, z up). Bounded storage 44,400 vertices; earlier calls
unchanged. Build command unchanged (below).

# Building and verifying TargetSC 0.11.0 / unified Test5.7

Native API 0.11.0 adds `native.glyph(radius,height,rotation,color,tilt,stand,
lift,sink,pull,stagger,order,clip,circle)`: up to 4 property glyphs per frame
drawn in 3D (geometry in `PropertyGeometry.h` glyph3_*). Bounded storage
44,352 vertices; one draw call; all earlier calls unchanged. Build command
unchanged (below).

# Building and verifying TargetSC 0.10.0 / unified Test4.9

Native API 0.10.0: `native.disc` takes optional args 15 (middle radial stop:
alpha multiplier 0–1, or −1 for none) and 16 (its position, .05–.95 of the
radius). Its RGB is the straight blend of the unscaled center (hub or average)
and rim colors there; with it the fill is a center fan plus a middle→rim
annulus. Disc limit 16 (was 8); bounded storage 42,240 vertices, one draw
call; SceneHook ABI unchanged. Omitted args draw exactly as 0.9.0. Build
command unchanged (below).

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
