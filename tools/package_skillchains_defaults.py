#!/usr/bin/env python3
"""Build a verified Skillchains-only Cioara-defaults testing package.

No TargetSC runtime, DLL, character settings, or generated caches are copied.
README/WORKFLOW/TESTING remain alongside the addon inside Skillchains/.
"""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parent.parent
DIST = ROOT / "dist"
STAGE = DIST / "skillchains-cioara-package"
NAME = "Skillchains-Cioara-Defaults-Animation8.8"
BASE = "6bfbc7b1cee6bc49bb5f139f75b993a7bb8ead0f"

FILES = (
    "AGENTS.md", "README.md", "WORKFLOW.md", "TESTING.md",
    "Skillchains.lua", "skills.lua", "resonance_ui.lua",
    "resonance_fx.lua", "learning_ui.lua", "targetsc_bridge.lua",
    "skillchains_demo.lua",
)
HALOS = (
    "images/resonance/capsule_halo_l.png",
    "images/resonance/capsule_halo_rail.png",
    "images/resonance/capsule_halo_r.png",
    "images/resonance/ghost_flare.png",
)
TERMINAL = ("images/terminal/light.png", "images/terminal/darkness.png")
PNG = bytes.fromhex("89504e470d0a1a0a")


def git(*args):
    return subprocess.check_output(
        ["git", "-C", str(ROOT), *args], text=True
    ).strip()


def main():
    branch = git("branch", "--show-current")
    commit = git("rev-parse", "HEAD")
    # The independent TargetSC Test11.1 package has strict, intentionally
    # separate protection for a Skillchains-unchanged paired release.
    assert not git("diff", "--name-only", BASE, "--", "TargetSC"), (
        "TargetSC files changed; this package is Skillchains-only"
    )
    for relative in (
        "skills.lua", "resonance_ui.lua", "learning_ui.lua",
        "targetsc_bridge.lua", "skillchains_demo.lua", "images",
    ):
        assert not git("diff", "--name-only", BASE, "--", relative), (
            "Unexpected unrelated Skillchains runtime/art change: " + relative
        )

    icons = tuple(sorted((ROOT / "images/skillchain").glob("*.png")))
    flashes = tuple(sorted((ROOT / "images/mb_flash").glob("*.png")))
    assert len(icons) == len(flashes) == 14, (
        "Generate all 14 MB flash silhouettes before packaging"
    )
    assert {p.name for p in icons} == {p.name for p in flashes}
    paths = list(FILES) + list(HALOS) + list(TERMINAL)
    paths += [str(p.relative_to(ROOT)) for p in icons]
    paths += [str(p.relative_to(ROOT)) for p in flashes]
    assert len(set(paths)) == len(paths), "Duplicate package path"
    assert not any("/data/" in p or p.endswith("settings.xml") for p in paths)

    if STAGE.exists():
        shutil.rmtree(STAGE)
    addon = STAGE / "Skillchains"
    for relative in paths:
        source = ROOT / relative
        assert source.is_file(), "Missing runtime file: " + relative
        destination = addon / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
        if source.suffix.lower() == ".png":
            assert source.read_bytes().startswith(PNG), "Invalid PNG: " + relative

    info = {
        "batch": NAME,
        "repository": "rerorriM-Mirrorer/Skillchains",
        "branch": branch,
        "commit": commit,
        "source_profile": "effective global + Cioara, settings(20261105-105912).xml",
        "in_game_tested": False,
        "scope": "Skillchains-only; no TargetSC files or character settings",
    }
    (addon / "BUILD_INFO.json").write_text(
        json.dumps(info, indent=2) + "\n", encoding="utf-8"
    )
    checks = {
        str(p.relative_to(addon)): hashlib.sha256(p.read_bytes()).hexdigest()
        for p in sorted(addon.rglob("*")) if p.is_file()
    }
    (addon / "SHA256SUMS.json").write_text(
        json.dumps(checks, indent=2) + "\n", encoding="utf-8"
    )
    archive = DIST / (NAME + ".zip")
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as z:
        for p in sorted(addon.rglob("*")):
            if p.is_file():
                z.write(p, str(p.relative_to(STAGE)))
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None, "ZIP CRC failure"
        names = z.namelist()
        assert len(names) == len(set(names))
        assert set(n.split("/")[0] for n in names) == {"Skillchains"}
        assert not any("/data/" in n or "settings.xml" in n
                       or "/.git/" in n or n.endswith(".dll") for n in names)
        for filename in ("AGENTS.md", "README.md", "WORKFLOW.md", "TESTING.md",
                         "Skillchains.lua", "resonance_fx.lua",
                         "BUILD_INFO.json", "SHA256SUMS.json"):
            assert "Skillchains/" + filename in names
        assert b"## AGATHOS" in z.read("Skillchains/WORKFLOW.md")
        for filename, sha in checks.items():
            assert hashlib.sha256(
                z.read("Skillchains/" + filename)
            ).hexdigest() == sha, filename
        assert all(z.read("Skillchains/" + p).startswith(PNG)
                   for p in HALOS + TERMINAL)
        assert len([n for n in names if n.startswith(
            "Skillchains/images/skillchain/")]) == 14
        assert len([n for n in names if n.startswith(
            "Skillchains/images/mb_flash/")]) == 14
    print(f"PASS verified Skillchains-only package: {archive}")
    print(f"  branch={branch}, commit={commit}, files={len(checks)}")
    print("  No TargetSC binaries/files, no user settings, valid SHA256 and ZIP CRC")


if __name__ == "__main__":
    main()
