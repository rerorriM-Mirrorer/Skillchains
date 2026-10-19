#!/usr/bin/env python3
"""Generate soft, mirrored ghost-glow endcaps for the Skillchains border.

PNG pixels are neutral white with alpha only, so the game can tint the same
texture to pale-gold, white-gold, white, or any existing property. The left
image follows a half-capsule; the right is an exact pixel mirror.
Rebuild: python3 tools/generate_glow_caps.py
Verify:  python3 tools/generate_glow_caps.py --check
Author: A.
"""
from pathlib import Path
import math
import struct
import sys
import zlib

SIZE = 64
OUT = Path(__file__).resolve().parent.parent / 'images' / 'resonance'


def clamp(t):
    return max(0.0, min(1.0, t))


def smooth(t):
    t = clamp(t)
    return t*t*(3.0-2.0*t)


def alpha_at(x, y):
    xx = (x + 0.5) / SIZE
    yy = (y + 0.5) / SIZE
    dy = abs(yy - 0.5)
    center_x, radius_x, radius_y = 0.52, 0.43, 0.17
    if xx < center_x:
        theta = min(1.0, dy / radius_y)
        arc_x = center_x - radius_x * math.sqrt(max(0., 1.-theta*theta))
        core = math.exp(-((xx-arc_x)/0.054)**2) if dy <= radius_y else 0.
        halo = math.exp(-((xx-arc_x)/0.135)**2) if dy <= radius_y else 0.
        # Round smoothly onto the upper/lower rail near their start.
        if dy > radius_y:
            core = math.exp(-((xx-center_x)/0.075)**2
                            -((dy-radius_y)/0.070)**2)
            halo = math.exp(-((xx-center_x)/0.18)**2
                            -((dy-radius_y)/0.14)**2)
    else:
        taper = smooth((1.0-xx)/0.40)
        core = math.exp(-((dy-radius_y)/0.052)**2) * taper
        halo = math.exp(-((dy-radius_y)/0.135)**2) * taper
    return math.floor(clamp((163*core+66*halo)/255)*255+0.5)


def chunk(tag, data):
    return (struct.pack('>I',len(data))+tag+data+
            struct.pack('>I', zlib.crc32(tag+data)&0xffffffff))


def encode_png(rows):
    pixels = b''.join(b'\\x00'+b''.join(bytes((255,255,255,a))
                    for a in row) for row in rows)
    return (b'\\x89PNG\\r\\n\\x1a\\n' +
            chunk(b'IHDR',struct.pack('>IIBBBBB',SIZE,SIZE,8,6,0,0,0)) +
            chunk(b'IDAT',zlib.compress(pixels,0)) +
            chunk(b'IEND',b''))


def files():
    left=[[alpha_at(x,y) for x in range(SIZE)] for y in range(SIZE)]
    return {'ghost_glow_cap_l.png':encode_png(left),
            'ghost_glow_cap_r.png':encode_png([row[::-1] for row in left])}


def main():
    check='--check' in sys.argv[1:]
    if not check:
        OUT.mkdir(parents=True,exist_ok=True)
    for name,data in files().items():
        path=OUT/name
        if check:
            assert path.read_bytes()==data, name+' differs from generator'
        else:
            path.write_bytes(data)
        print(('verified' if check else 'generated')+': '+name)


if __name__=='__main__':
    main()
