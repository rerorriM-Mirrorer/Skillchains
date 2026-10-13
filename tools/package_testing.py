#!/usr/bin/env python3
"""Build a clean Skillchains testing package (stdlib only).

The archive root contains WORKFLOW.md, TESTING.md, and exactly one
installable Skillchains/ directory with README.md and runtime Lua files.
Never package character settings.
"""
from pathlib import Path
import argparse
import shutil
import zipfile

ROOT = Path(__file__).resolve().parent.parent
ROOT_DOCS = ("WORKFLOW.md", "TESTING.md")
ADDON_DOCS = ("README.md",)
LUA = ("Skillchains.lua", "skills.lua", "resonance_ui.lua")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--name", default="Skillchains-resonance.5-test")
    args = parser.parse_args()
    dist = ROOT / "dist"
    staging = dist / "package_content"
    if staging.exists():
        shutil.rmtree(staging)
    (staging / "Skillchains").mkdir(parents=True)
    for filename in ROOT_DOCS:
        shutil.copy2(ROOT / filename, staging / filename)
    for filename in ADDON_DOCS:
        shutil.copy2(ROOT / filename, staging / "Skillchains" / filename)
    for filename in LUA:
        shutil.copy2(ROOT / filename, staging / "Skillchains" / filename)

    archive = dist / (args.name + ".zip")
    manifest = [*ROOT_DOCS, *(f"Skillchains/{name}" for name in (*ADDON_DOCS, *LUA))]
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
        assert b"## AGATHOS" in zf.read("WORKFLOW.md")
        assert b"## DESIGN" in zf.read("WORKFLOW.md")
        assert b"## WORKFLOW" in zf.read("WORKFLOW.md")
        assert not any(x.endswith("settings.xml") for x in zf.namelist())

    print(f"Created and verified: {archive.relative_to(ROOT)}")
    for name in manifest:
        print("  " + name)


if __name__ == "__main__":
    main()
