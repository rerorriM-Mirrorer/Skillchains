# TargetSC third-party notices

Authoring identity for new TargetSC work: **A.**, 2026.

## TargetRing / SceneHook — Broguypal

Source: https://github.com/Broguypal/Addons/tree/main/TargetRing
Originally inspected TargetRing at `e45fdf791598738267b717dd76192b49b4ba4e28`.
Native device discovery safety was updated from TargetRing 3.0.4 commit
`982980f5009c06fdba070d0114a1869688e4764c` (2026-11-11).
SceneHook v2.1 was updated from TargetRing 3.0.3 commit
`d45806bf1edb270db86cd1343e87cafa2a064c9d` (2026-10-30).
TargetSC's native device discovery, readable-memory checks, scene hookup,
projection and display-position approach include adapted TargetRing code.
Copyright (c) 2026 Broguypal. BSD 3-Clause; full license retained in
`licenses/TargetRing-BSD-3-Clause.txt` and `src/SceneHook/LICENSE`.

`src/SceneHook/SceneHook.h` is retained **byte for byte** from upstream v2.1. ABI: 2.
SHA-256: `159f1f062874cb61e45f7dfcbd871813172cf31a16ea1a6f5e649b1c2ad9ce24`.
The SHA-256 above identifies the original v2.0 import, not the updated header.
The current v2.1 header is retained byte-for-byte from upstream; Git blob SHA-1:
`6937e1f8ef6a7c11fbebc8ae51eda2f0bc6de925`.
Its sibling `SceneHook.md` is also copied from upstream (blob
`42b9325d1e4c1dad757712b2b4001c12ab4bbbf0`).
Preserve these notices and both upstream licenses in source and binary packages.

## TargetLines — MogSafe

Source: https://github.com/MogSafe/TargetLines/tree/develop
Inspected commit: `548b0e28753a1f3479319dffb4b095ac4d5a8ec0`.
Copyright (c) 2026 MogSafe. MIT license retained in
`licenses/TargetLines-MIT.txt`. Technical design reference for Lua-to-native
state submission, layered halos/rings, short outward ripples and safe lifecycle
handling. Its supplied native binary is **not** included or renamed.

## Skillchains

Companion integration remains in the separately distributed Skillchains
folder. The original Ivaar license/header and prior fork credits are preserved.
Windower resource definitions provide spell-element and confirmed MB-message
associations; no resource dataset is redistributed inside TargetSC.
