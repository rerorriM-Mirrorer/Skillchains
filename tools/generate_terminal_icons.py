#!/usr/bin/env python3
"""Build deterministic monochrome terminal glyphs from the existing skillchain icons.

The original colored images remain untouched. Generated white-alpha masks can
be tinted to pure white for Radiance or pure black for Umbra in Windower.
This is build-time artwork; Pillow is NOT needed in the installed addon.
"""
from pathlib import Path
import argparse

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / 'images/skillchain'
OUTPUT = ROOT / 'images/terminal'
ICONS = ('light.png', 'darkness.png')


def render(name):
    original = Image.open(SOURCE / name).convert('RGBA')
    alpha = original.getchannel('A')
    low, high = alpha.getextrema()
    assert low < high, f'Icon {name} must contain transparent shape pixels'
    mask = Image.new('RGBA', original.size, (255, 255, 255, 0))
    mask.putalpha(alpha)
    return mask


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    if not args.check:
        OUTPUT.mkdir(parents=True, exist_ok=True)
    for name in ICONS:
        expected = render(name)
        output = OUTPUT / name
        if args.check:
            assert output.is_file(), f'Missing generated terminal glyph: {output}'
            actual = Image.open(output).convert('RGBA')
            assert actual.size == expected.size and list(actual.getdata()) == list(expected.getdata()), (
                f'Terminal glyph differs from exact original alpha silhouette: {output}'
            )
        else:
            expected.save(output, format='PNG', optimize=False)
        print(('verified' if args.check else 'generated') + ': ' + str(output.relative_to(ROOT)))


if __name__ == '__main__':
    main()
