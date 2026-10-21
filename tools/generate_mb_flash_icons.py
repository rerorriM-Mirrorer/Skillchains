#!/usr/bin/env python3
"""Build pure-white MB window-introduction glyphs from all original property PNGs.

At runtime no Python or Pillow is needed. Preserve each source icon's exact
alpha mask; a white tint on a colored source image cannot remove its colors.
"""
from pathlib import Path
import argparse
from PIL import Image

ROOT=Path(__file__).resolve().parent.parent
SOURCE=ROOT/'images/skillchain'
OUTPUT=ROOT/'images/mb_flash'

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--check',action='store_true')
    args=parser.parse_args()
    icons=sorted(SOURCE.glob('*.png'))
    assert len(icons)==14, 'Expected all 14 chain property glyphs'
    if not args.check: OUTPUT.mkdir(parents=True,exist_ok=True)
    for source in icons:
        original=Image.open(source).convert('RGBA')
        alpha=original.getchannel('A')
        lo,hi=alpha.getextrema()
        assert lo<hi, 'Missing transparent glyph pixels: '+source.name
        white=Image.new('RGBA',original.size,(255,255,255,0))
        white.putalpha(alpha)
        target=OUTPUT/source.name
        if args.check:
            assert target.is_file(), 'Missing MB white glyph: '+source.name
            produced=Image.open(target).convert('RGBA')
            assert produced.size==white.size and list(produced.getdata())==list(white.getdata()), (
                'MB glyph alpha mismatch: '+source.name)
        else: white.save(target,format='PNG',optimize=False)
    print(('Verified' if args.check else 'Generated'),len(icons),
        'white-alpha MB property glyphs')

if __name__=='__main__':
    main()
