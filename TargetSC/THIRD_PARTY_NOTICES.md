# TargetSC third-party notices

Authoring identity for new TargetSC work: **A.**, 2026.

## TargetRing / SceneHook — Broguypal

Source: https://github.com/Broguypal/Addons/tree/main/TargetRing
Inspected source repository commit: `e45fdf791598738267b717dd76192b49b4ba4e28`.
TargetSC's native device discovery, readable-memory checks, scene hookup,
projection and display-position approach include adapted TargetRing code.
Copyright (c) 2026 Broguypal. BSD 3-Clause; full license retained in
`licenses/TargetRing-BSD-3-Clause.txt` and `src/SceneHook/LICENSE`.

`src/SceneHook/SceneHook.h` is retained **byte for byte**. ABI: 2.
SHA-256: `159f1f062874cb61e45f7dfcbd871813172cf31a16ea1a6f5e649b1c2ad9ce24`.
The header also exactly matches the inspected TargetLines version. Its sibling
`SceneHook.md` is retained. Preserve these notices in source and binary packages.

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
