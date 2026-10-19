#!/usr/bin/env python3
"""Check the actual PNG contours, their mirror, and a dark, seamless rail."""
import struct
import zlib
from pathlib import Path

ROOT=Path(__file__).resolve().parent.parent / "images" / "resonance"


def load(path):
    buf=path.read_bytes()
    assert buf[:8]==b"\x89PNG\r\n\x1a\n"
    off=8
    pixels=b""
    w=h=None
    while off<len(buf):
        size=struct.unpack_from(">I",buf,off)[0]
        tag=buf[off+4:off+8]
        data=buf[off+8:off+8+size]
        if tag==b"IHDR":
            w,h,bitdepth,ctype,_,_,_=struct.unpack(">IIBBBBB",data)
            assert (w,h,bitdepth,ctype)==(64,64,8,6)
        if tag==b"IDAT":
            pixels+=zlib.decompress(data)
        off+=12+size
    stride=4*w+1
    rows=[]
    for y in range(h):
        row=pixels[y*stride:(y+1)*stride]
        assert row[0]==0
        rows.append([row[1+x*4+3] for x in range(w)])
        assert all(row[1+x*4:1+x*4+3]==b"\xff\xff\xff"
                   for x in range(w))
    return rows


left=load(ROOT/"capsule_halo_l.png")
center=load(ROOT/"capsule_halo_rail.png")
right=load(ROOT/"capsule_halo_r.png")
assert right==[row[::-1] for row in left], "Caps must be exact mirrors"
assert all(len(set(row))==1 for row in center), "Rail must stretch without horizontal artifacts"
assert all(left[y][-1]==center[y][0] and right[y][0]==center[y][-1]
           for y in range(64)), "Cap/rail seam must have exactly matched alpha"
assert center[32][0]<12, "Interior must remain nearly clear rather than bleaching dark track"
assert max(center[14][0],center[49][0])>85, "Top/bottom must contain light"
assert left[32][15]>left[32][63], "Only the rounded outside edge carries central cap glow"
print("PASS capsule PNGs: pixel-exact mirror, no halo seams, dark interior, two narrow rails")
