#!/usr/bin/env python3
"""Deterministic tintable RGBA light-leak flares. Author: A.

Right-hand asset has its bright rounded base at the RIGHT edge of the
sprite; left-hand asset is its pixel-for-pixel mirror. The bottom row
of both sprites is the fill's bottom edge, so there is no flare below
the bar. To regenerate: python3 tools/generate_edge_flares.py
To verify: python3 tools/generate_edge_flares.py --check
"""
from pathlib import Path
import math
import struct
import sys
import zlib

W, H = 64, 96
OUT = Path(__file__).resolve().parent.parent / 'images' / 'resonance'


def clamp(x):
    return max(0., min(1., x))


def smooth(x):
    x = clamp(x)
    return x * x * (3 - 2 * x)


def alpha_at(x, y):
    px, py = x + .5, y + .5
    dy = py - 86
    base = 0.
    if abs(dy) <= 10:
        outer = 53 + math.sqrt(max(0., 100 - dy * dy))
        inside = smooth((outer - px) / 2.4) * smooth((px - 9) / 34)
        rim = math.exp(-((outer - px - 1.3) / 3.2) ** 2)
        base = inside * (62 + 145 * smooth((px - 24) / 30))
        base += 57 * rim * smooth((px - 25) / 28)
    t = clamp((77 - py) / 77)
    center = 56.5 - 9 * t + 1.2 * math.sin(t * math.pi * 2.4) * t
    width = 7.2 * (1 - t) + 1.4
    fade_top = smooth(py / 15)
    plume = (148 * (1 - t) ** 1.15 * fade_top
             * math.exp(-((px - center) / width) ** 2)) if py < 77 else 0
    strand_x = 58 - 16 * t + 1.4 * math.sin(t * 10)
    strand = (56 * (1 - t) ** 1.7 * fade_top
              * math.exp(-((px - strand_x) / 2.5) ** 2)) if py < 77 else 0
    halo = (42 * math.exp(-((px - 53) / 15) ** 2 -
                          ((py - 74) / 22) ** 2)) if py < 77 else 0
    return round(clamp((base + plume + strand + halo) / 255) * 255)


def chunk(tag, data):
    return (struct.pack('>I', len(data)) + tag + data +
            struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff))


def png(rows):
    image_data = b''.join(
        b'\x00' + b''.join(bytes((255, 255, 255, a)) for a in row)
        for row in rows)
    return (b'\x89PNG\r\n\x1a\n' +
            chunk(b'IHDR', struct.pack('>IIBBBBB', W, H, 8, 6, 0, 0, 0)) +
            chunk(b'IDAT', zlib.compress(image_data, 9)) +
            chunk(b'IEND', b'')


def assets():
    right = [[alpha_at(x, y) for x in range(W)] for y in range(H)]
    return {'edge_flare_right.png': png(right),
            'edge_flare_left.png': png([row[::-1] for row in right])}


def main():
    check = '--check' in sys.argv[1:]
    if not check:
        OUT.mkdir(parents=True, exist_ok=True)
    for name, data in assets().items():
        path = OUT / name
        if check:
            assert path.read_bytes() == data, f'{name} differs from generator'
        else:
            path.write_bytes(data)
        print(('verified' if check else 'generated') + ': ' + name)


if __name__ == '__main__':
    main()
