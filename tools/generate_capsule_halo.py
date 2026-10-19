#!/usr/bin/env python3
"""Generate a true three-part rounded-rectangle BORDER halo, not glow blobs.

All three textures sample the same distance function in scaled design-space.
The center rail contains TWO thin continuous edge strips with an almost
transparent interior. Left/right caps terminate those strips by following
the exact one-pixel-rounded primitive frame used in resonance_ui.lua.
Textures carry white RGB + variable alpha for Windower tinting.

The PNG encoding deliberately uses zlib level 0 for fully deterministic bytes.
Author: A.
"""
import math
import struct
import sys
import zlib
from pathlib import Path

N = 64
FRAME_HEIGHT = 7.0  # scale 1: 5px bar + 2px frame
CORNER = 1.0        # current crisp Windower frame rounds corners by 1px
PADDING = 3.0       # bloom reach beyond the frame in UI design pixels
SPAN = 10.0         # straight rails join at x=10px from bar edge
OUT = Path(__file__).resolve().parent.parent / "images" / "resonance"


def halo(distance):
    # Narrow luminous rim, faint exterior bloom, DARK center (no bar wash).
    return max(0, min(255, int(
        190.0 * math.exp(-(distance / 1.25) ** 2) +
        25.0 * math.exp(-(distance / 2.50) ** 2) + 0.5)))


def sample(x, y, cap):
    """Distance from the border contour, with tangential cap/rail join."""
    r, h = CORNER, FRAME_HEIGHT
    if cap and x < r:
        if y < r:
            distance = abs(math.hypot(x - r, y - r) - r)
        elif y > h - r:
            distance = abs(math.hypot(x - r, y - (h - r)) - r)
        else:
            distance = abs(x)
    else:
        distance = min(abs(y), abs(y - h))
    return halo(distance)


def pixels(cap=False, mirrored=False):
    rows = []
    span = SPAN + PADDING if cap else 1.0
    height = FRAME_HEIGHT + 2 * PADDING
    for iy in range(N):
        y = (iy + 0.5) / N * height - PADDING
        row = []
        for ix in range(N):
            u = (N - 1 - ix) if mirrored else ix
            x = (u + 0.5) / N * span - (PADDING if cap else 0)
            row.append(sample(x, y, cap))
        rows.append(row)
    return rows


def chunk(tag, data):
    return (struct.pack(">I", len(data)) + tag + data +
            struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff))


def encode(rows):
    raw = b"".join(b"\x00" + b"".join(bytes((255, 255, 255, a))
                 for a in row) for row in rows)
    return (b"\x89PNG\r\n\x1a\n" +
            chunk(b"IHDR", struct.pack(">IIBBBBB", N, N, 8, 6, 0, 0, 0)) +
            chunk(b"IDAT", zlib.compress(raw, 0)) +
            chunk(b"IEND", b""))


def files():
    return {
        "capsule_halo_l.png": encode(pixels(cap=True)),
        "capsule_halo_rail.png": encode(pixels()),
        "capsule_halo_r.png": encode(pixels(cap=True, mirrored=True))
    }


def main():
    check = "--check" in sys.argv[1:]
    if not check:
        OUT.mkdir(parents=True, exist_ok=True)
    for name, data in files().items():
        path = OUT / name
        if check:
            assert path.read_bytes() == data, name + " differs from generator"
        else:
            path.write_bytes(data)
        print(("verified" if check else "generated") + ": " + name)


if __name__ == "__main__":
    main()
