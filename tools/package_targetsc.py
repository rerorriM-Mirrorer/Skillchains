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
NAME = 'Skillchains-Animation8.8-Independent-MB-TargetSC-Test8-Paired-Full'
PATCH_BASE = '700bef129e9932dde996127813f6853e1227af7b'
SC_CURRENT = '3d96aeac0b63dc5e1fbd61ca8bf576bb3758cada'
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
    # The HUD renderer, command help and new glyph are intentionally updated.
    # Combat interpretation, native bridge, source clocks, existing artwork and
    # all TargetSC Test8 source/native files stay exactly at their baseline.
    assert not git('diff',SC_CURRENT,'--',
        'skills.lua','learning_ui.lua','resonance_fx.lua',
        'targetsc_bridge.lua','skillchains_demo.lua',
        'images/skillchain','images/terminal',
        'images/resonance/capsule_halo_l.png',
        'images/resonance/capsule_halo_rail.png',
        'images/resonance/capsule_halo_r.png'), 'Protected Skillchains runtime or artwork changed'
    runtime=set(git('diff','--name-only',SC_CURRENT,'--',
        'Skillchains.lua','resonance_ui.lua').splitlines())
    assert runtime=={'Skillchains.lua','resonance_ui.lua'}, 'Unexpected HUD implementation changes'
    assert (ROOT/'images/resonance/ghost_flare.png').is_file(), 'SC endpoint texture missing'
    assert not git('diff','fa2952959c736a1f7cf605a0caa6dc83045c4146',
        '--','TargetSC/src','TargetSC/libs','TargetSC/TargetSC.lua',
        'TargetSC/resonance.lua','TargetSC/resonance_motion.lua',
        'TargetSC/resonance_burst.lua','TargetSC/resonance_controls.lua',
        'TargetSC/resonance_preview.lua','TargetSC/tests'), 'Latest TargetSC Test8 runtime changed'
    assert not git('diff',PATCH_BASE,'--','TargetSC/libs','TargetSC/src'), 'Native API 0.5.0 renderer changed'
    original_bridge = subprocess.check_output(['git','-C',str(ROOT),'show',HUD_BASELINE+':targetsc_bridge.lua'])
    assert (ROOT/'targetsc_bridge.lua').read_bytes() == original_bridge.replace(b'lua i TargetSC',b'lua c TargetSC'), 'Unexpected bridge change'
    dll_hash = verify_dll(ROOT / 'TargetSC/libs/_TargetSC.dll')
    info = {'batch': 'Skillchains Animation8.8 independent draggable MB HUD, true-white introductions and SC terminal isolation / TargetSC Test8 unchanged', 'author': 'A.',
            'repository': 'rerorriM-Mirrorer/Skillchains', 'branch': branch,
            'source_commit': commit, 'skillchains_baseline': BASELINE,
            'hud_reference_commit': SC_CURRENT,
            'targetsc_test8_in_game_tested': False,
            'skillchains_preview_user_confirmed': True,
            'targetsc_test1_render_user_confirmed': True,
            'targetsc_test2_previews_user_confirmed': True,
            'targetsc_test3_in_game_tested': False,
            'bridge_fix_commit': 'aaf233f',
            'native_api': '0.5.0', 'bridge_protocol': 1, 'scenehook_abi': 2,
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
    # The terminal glyphs are exact white-alpha silhouettes of existing
    # source icons. Black and white variants use texture tinting at runtime.
    terminal_art = [ROOT / 'images/terminal/light.png',
                    ROOT / 'images/terminal/darkness.png']
    for file in terminal_art:
        assert file.is_file(), 'Generate terminal icons with tools/generate_terminal_icons.py'
        dest = STAGE / 'Skillchains/images/terminal' / file.name
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(file, dest)
    # Build-time-only pure-white MB glyph silhouettes are shipped under
    # Skillchains, never replacing the original full-color property icons.
    mb_white=sorted((ROOT/'images/mb_flash').glob('*.png'))
    assert len(mb_white)==len(icons)==14, 'Run tools/generate_mb_flash_icons.py first'
    for file in mb_white:
        assert file.name in {i.name for i in icons}
        dest=STAGE/'Skillchains/images/mb_flash'/file.name
        dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(file,dest)
    ghostflare=ROOT/'images/resonance/ghost_flare.png'
    assert ghostflare.read_bytes().startswith(bytes.fromhex('89504e470d0a1a0a'))
    dest=STAGE/'Skillchains/images/resonance/ghost_flare.png'
    dest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(ghostflare,dest)
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
        for file in terminal_art:
            assert z.read('Skillchains/images/terminal/' + file.name).startswith(bytes.fromhex('89504e470d0a1a0a'))
        assert z.read('Skillchains/images/resonance/ghost_flare.png').startswith(bytes.fromhex('89504e470d0a1a0a'))
        for file in mb_white:
            assert z.read('Skillchains/images/mb_flash/'+file.name).startswith(bytes.fromhex('89504e470d0a1a0a'))
        for folder in ('Skillchains', 'TargetSC'):
            checks = json.loads(z.read(folder + '/SHA256SUMS.json'))
            for name, expected in checks.items():
                assert hashlib.sha256(z.read(folder + '/' + name)).hexdigest() == expected
    # A minimal TargetSC patch preserves the user's independently updated HUD.
    patch_paths=set(git('diff','--name-only',PATCH_BASE,'--','TargetSC').splitlines())
    assert not any(name.endswith('.dll')for name in patch_paths), 'Lua-only patch must not include DLL'
    patch_paths.update({'TargetSC/README.md','TargetSC/WORKFLOW.md','TargetSC/TESTING.md'})
    patch = DIST / 'TargetSC-0.8.0-Test8-MB-Finish-Lua-Patch.zip'
    patch_checks={}
    with zipfile.ZipFile(patch,'w',zipfile.ZIP_DEFLATED) as z:
        for name in sorted(patch_paths):
            data=(ROOT/name).read_bytes();z.writestr(name,data)
            patch_checks[name]=hashlib.sha256(data).hexdigest()
        z.writestr('TargetSC/BUILD_INFO_TEST8.json',json.dumps(info,indent=2)+'\n')
        z.writestr('TargetSC/SHA256SUMS_TEST8.json',json.dumps(patch_checks,indent=2)+'\n')
    with zipfile.ZipFile(patch) as z:
        assert z.testzip() is None
        assert all(name.startswith('TargetSC/')and '/data/'not in name for name in z.namelist())
        for name,sha in patch_checks.items():assert hashlib.sha256(z.read(name)).hexdigest()==sha
    print('TargetSC patch:',patch)
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
