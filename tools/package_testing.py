#!/usr/bin/env python3
"""Build a clean Skillchains testing package (stdlib only).

The archive root contains exactly one installable Skillchains/ directory.
README.md, WORKFLOW.md, TESTING.md and runtime files all live inside it.
Never package character settings.
"""
from pathlib import Path
import argparse
import shutil
import zipfile

ROOT = Path(__file__).resolve().parent.parent
ROOT_DOCS = ("WORKFLOW.md", "TESTING.md")
ADDON_DOCS = ("README.md",)
LUA = ("Skillchains.lua", "skills.lua", "resonance_ui.lua", "learning_ui.lua")
ICON_SOURCE = ROOT / "images" / "skillchain"
ICONS = tuple(sorted(path.name for path in ICON_SOURCE.glob("*.png")))
assert len(ICONS) == 14, "Expected 14 property PNG icons"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--name", default="Skillchains-resonance.6-test")
    args = parser.parse_args()
    dist = ROOT / "dist"
    staging = dist / "package_content"
    if staging.exists():
        shutil.rmtree(staging)
    (staging / "Skillchains").mkdir(parents=True)
    for filename in ROOT_DOCS:
        shutil.copy2(ROOT / filename, staging / "Skillchains" / filename)
    for filename in ADDON_DOCS:
        shutil.copy2(ROOT / filename, staging / "Skillchains" / filename)
    for filename in LUA:
        shutil.copy2(ROOT / filename, staging / "Skillchains" / filename)
    (staging / "Skillchains" / "images" / "skillchain").mkdir(parents=True)
    for filename in ICONS:
        shutil.copy2(ICON_SOURCE / filename,
                     staging / "Skillchains" / "images" / "skillchain" / filename)

    archive = dist / (args.name + ".zip")
    manifest = [*(f"Skillchains/{name}" for name in (*ROOT_DOCS, *ADDON_DOCS, *LUA)),
                *(f"Skillchains/images/skillchain/{name}" for name in ICONS)]
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as zf:
        for name in manifest:
            zf.write(staging / name, arcname=name)

    with zipfile.ZipFile(archive) as zf:
        assert sorted(zf.namelist()) == sorted(manifest)
        assert zf.testzip() is None, "CRC failure"
        for filename in (*ADDON_DOCS, *LUA):
            assert zf.read("Skillchains/" + filename).strip(), filename
        assert "README.md" not in zf.namelist()
        assert "Skillchains/README.md" in zf.namelist()
        for name in ICONS:
            data = zf.read("Skillchains/images/skillchain/" + name)
            assert data.startswith(bytes((137, 80, 78, 71, 13, 10, 26, 10))), name
        assert b"## AGATHOS" in zf.read("Skillchains/WORKFLOW.md")
        assert b"## DESIGN" in zf.read("Skillchains/WORKFLOW.md")
        assert b"## WORKFLOW" in zf.read("Skillchains/WORKFLOW.md")
        assert "WORKFLOW.md" not in zf.namelist()
        assert "TESTING.md" not in zf.namelist()
        assert not any(x.endswith("settings.xml") for x in zf.namelist())

    print(f"Created and verified: {archive.relative_to(ROOT)}")
    for name in manifest:
        print("  " + name)


if __name__ == "__main__":
    main()
