#!/usr/bin/env python3
"""Curate a complete two-addon test ZIP. Run from a clean, committed checkout."""
from pathlib import Path
import hashlib
import json
import shutil
import struct
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parent.parent
DIST = ROOT / 'dist'
STAGE = DIST / 'targetsc-package'
NAME = 'Skillchains-Animation8.4-Glow-Tier-Shift-Paired-Full'
HUD_BASELINE = 'd13f9c20eff5ad927e92b3d9dd781904cf49dec7'
SC_FILES = ('TESTING.md', 'WORKFLOW.md', 'README.md', 'AGENTS.md', 'Skillchains.lua',
            'targetsc_bridge.lua', 'skillchains_demo.lua', 'skills.lua', 'resonance_ui.lua', 'learning_ui.lua', 'resonance_fx.lua')
BASELINE = 'e095657a2e7ecc5a49d05e96c1b78523a4860af5'


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args], text=True).strip()


def verify_dll(path):
    data = path.read_bytes()
    assert data[:2] == b'MZ', 'Not a Windows module'
    pe = struct.unpack_from('<I', data, 0x3c)[0]
    assert data[pe:pe+4] == b'PE\0\0'
    assert struct.unpack_from('<H', data, pe+4)[0] == 0x14c, 'Must be i386'
    assert struct.unpack_from('<H', data, pe+24)[0] == 0x10b, 'Must be PE32'
    assert struct.unpack_from('<H', data, pe+22)[0] & 0x2000, 'Must be a DLL'
    assert b'luaopen__TargetSC\0' in data, 'Lua module export missing'
    return hashlib.sha256(data).hexdigest()


def main():
    assert not git('status', '--porcelain', '--untracked-files=normal'), 'Commit work before packaging'
    commit, branch = git('rev-parse', 'HEAD'), git('branch', '--show-current')
    # Unchanged Animation8.1 HUD/combat/assets are protected, except mask-loading Lua.
    # The publisher must still retain Test3's corrected lua c transport.
    guarded = ('skills.lua','resonance_ui.lua',
               'learning_ui.lua','images')
    assert not git('diff',HUD_BASELINE,'--',*guarded), 'HUD/assets changed'
    changed=set(git('diff','--name-only',HUD_BASELINE,'--','Skillchains.lua','resonance_fx.lua').splitlines())
    assert changed=={'Skillchains.lua','resonance_fx.lua'}, 'Unexpected source baseline differences'
    # The new demo module is mandatory; TargetSC is never the HUD's runtime source.
    demo=(ROOT/'skillchains_demo.lua').read_text()
    assert 'require(\'resonance_preview\')' not in demo
    assert 'targetsc:state(' not in demo and 'windower.send_command' not in demo
    assert not git('diff','721242f15f1c02c542af290208662f0ed4f21417','--',
        'TargetSC/TargetSC.lua','TargetSC/resonance.lua',
        'TargetSC/resonance_controls.lua','TargetSC/resonance_motion.lua',
        'TargetSC/resonance_preview.lua','TargetSC/libs','TargetSC/src'), 'TargetSC runtime changed'
    original_bridge = subprocess.check_output(['git','-C',str(ROOT),'show',HUD_BASELINE+':targetsc_bridge.lua'])
    assert (ROOT/'targetsc_bridge.lua').read_bytes() == original_bridge.replace(b'lua i TargetSC',b'lua c TargetSC'), 'Unexpected bridge change'
    dll_hash = verify_dll(ROOT / 'TargetSC/libs/_TargetSC.dll')
    info = {'batch': 'Skillchains Animation8.4 L2 shimmer L3 electric L4 preserved / TargetSC Test3 untouched', 'author': 'A.',
            'repository': 'rerorriM-Mirrorer/Skillchains', 'branch': branch,
            'source_commit': commit, 'skillchains_baseline': BASELINE,
            'hud_reference_commit': HUD_BASELINE,
            'skillchains_preview_user_confirmed': True,
            'targetsc_test1_render_user_confirmed': True,
            'targetsc_test2_previews_user_confirmed': True,
            'targetsc_test3_in_game_tested': False,
            'bridge_fix_commit': 'aaf233f',
            'native_api': '0.3.0', 'bridge_protocol': 1, 'scenehook_abi': 2,
            'native_source_sha256': hashlib.sha256((ROOT/'TargetSC/src/TargetSC.cpp').read_bytes()).hexdigest(),
            'native_dll_sha256': dll_hash, 'native_machine': 'PE32/i386',
            'compilation': 'MinGW-w64 GCC 13.2 x86, warnings treated as errors',
            'in_game_tested': False}
    if STAGE.exists():
        shutil.rmtree(STAGE)
    for file in SC_FILES:
        dest = STAGE / 'Skillchains' / file
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / file, dest)
    icons = list((ROOT / 'images/skillchain').glob('*.png'))
    assert len(icons) == 14
    for file in icons:
        dest = STAGE / 'Skillchains/images/skillchain' / file.name
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(file, dest)
    # All three textures sample the same capsule-outline halo function.
    # No loose cap blob/flare textures enter the installable addon.
    fx_art = [ROOT / 'images/resonance/capsule_halo_l.png',
              ROOT / 'images/resonance/capsule_halo_rail.png',
              ROOT / 'images/resonance/capsule_halo_r.png']
    for file in fx_art:
        assert file.is_file()
        dest = STAGE / 'Skillchains/images/resonance' / file.name
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(file, dest)
    # Track exactly the committed deliverable. Never copy caches, user data,
    # scratch binaries or arbitrary untracked files into the archive.
    for relative in git('ls-files', 'TargetSC').splitlines():
        if relative.endswith('.gitignore'):
            continue
        assert '/data/' not in relative and '/build/' not in relative
        dest = STAGE / relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / relative, dest)
    for folder in ('TargetSC', 'Skillchains'):
        (STAGE / folder / 'BUILD_INFO.json').write_text(json.dumps(info, indent=2) + '\n')
        files = sorted(p for p in (STAGE / folder).rglob('*') if p.is_file())
        manifest = {str(p.relative_to(STAGE / folder)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
        (STAGE / folder / 'SHA256SUMS.json').write_text(json.dumps(manifest, indent=2) + '\n')
    archive = DIST / (NAME + '.zip')
    files = sorted((p for p in STAGE.rglob('*') if p.is_file()),
                   key=lambda p: (p.parts[-2] if p.name == 'TESTING.md' else 'zz', str(p)))
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as z:
        for p in files:
            z.write(p, str(p.relative_to(STAGE)))
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        names = z.namelist()
        assert set(n.split('/')[0] for n in names) == {'Skillchains', 'TargetSC'}
        for folder in ('Skillchains', 'TargetSC'):
            for doc in ('TESTING.md', 'WORKFLOW.md', 'README.md', 'BUILD_INFO.json'):
                assert folder + '/' + doc in names
            workflow = z.read(folder + '/WORKFLOW.md')
            assert all(s in workflow for s in (b'## AGATHOS', b'## DESIGN', b'## WORKFLOW'))
        assert 'TargetSC/src/SceneHook/SceneHook.h' in names
        assert 'TargetSC/licenses/TargetRing-BSD-3-Clause.txt' in names
        assert 'TargetSC/licenses/TargetLines-MIT.txt' in names
        assert not any('/data/' in n or n.endswith('settings.xml') or '/.git/' in n for n in names)
        for file in icons:
            assert z.read('Skillchains/images/skillchain/' + file.name).startswith(b'\x89PNG\r\n\x1a\n')
        for file in fx_art:
            assert z.read('Skillchains/images/resonance/' + file.name).startswith(bytes.fromhex('89504e470d0a1a0a'))
        for folder in ('Skillchains', 'TargetSC'):
            checks = json.loads(z.read(folder + '/SHA256SUMS.json'))
            for name, expected in checks.items():
                assert hashlib.sha256(z.read(folder + '/' + name)).hexdigest() == expected
    # Offer a Skillchains-only installable artifact: no DLL or TargetSC files.
    solo = DIST / 'skillchains-demo-package'
    if solo.exists():
        shutil.rmtree(solo)
    shutil.copytree(STAGE / 'Skillchains', solo / 'Skillchains')
    assert (solo / 'Skillchains/skillchains_demo.lua').is_file()
    assert set(p.name for p in solo.iterdir()) == {'Skillchains'}
    assert not any('TargetSC' in str(p.relative_to(solo))
                   for p in solo.rglob('*') if p.is_file())
    print('Skillchains-only installation staged:', solo)
    print(json.dumps({'archive': str(archive), 'commit': commit, 'branch': branch,
                      'files': len(files), 'dll_sha256': dll_hash, 'crc_manifest_checks': 'PASS'}, indent=2))


if __name__ == '__main__':
    main()
