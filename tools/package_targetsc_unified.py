#!/usr/bin/env python3
"""Package the first single-folder TargetSC integration, without user data."""
from pathlib import Path
import hashlib
import json
import zipfile
import subprocess

ROOT=Path(__file__).resolve().parent.parent
SRC=ROOT/'TargetSC'
DIST=ROOT/'dist'
NAME='TargetSC-Unified-0.12.0-Test1.zip'
MODULES={'TargetSC.lua','sc_runtime.lua','targetsc_local.lua','targetsc_bridge.lua',
         'skills.lua','resonance_ui.lua','resonance_fx.lua','learning_ui.lua',
         'skillchains_demo.lua','resonance.lua','resonance_motion.lua',
         'resonance_burst.lua','resonance_controls.lua','resonance_preview.lua',
         'WORKFLOW.md','TESTING.md','AGENTS.md','README.md','INTEGRATION.md',
         'THIRD_PARTY_NOTICES.md','libs/_TargetSC.dll'}
for name in MODULES:
    assert (SRC/name).is_file(),f'missing required file: {name}'

# White-alphas are generated reproducibly by the existing Skillchains build
# tooling; put them inside TargetSC, never under a second addon folder.
extra=[]
for folder in ('terminal','mb_flash'):
    images=sorted((ROOT/'images'/folder).glob('*.png'))
    assert images,f'no generated icons in images/{folder}; run generators first'
    extra.extend((f'TargetSC/images/{folder}/{p.name}',p) for p in images)

files=[]
for p in sorted(SRC.rglob('*')):
    if not p.is_file():
        continue
    rel=p.relative_to(SRC)
    if any(part in ('data','tests','__pycache__','.git','verification') for part in rel.parts):
        continue
    if p.name=='.gitignore':
        continue
    files.append((f'TargetSC/{rel.as_posix()}',p))
files.extend(extra)
names=[n for n,_ in files]
assert len(names)==len(set(names)),'duplicate package name'
assert not any(n.startswith('Skillchains/') or '/data/' in n or n.endswith('settings.xml') for n in names)
assert all(n.startswith('TargetSC/') for n in names)
assert len([n for n in names if n.endswith('.png')])>=35, 'missing HUD artwork'

manifest={'version':'0.12.0-unified-test1','kind':'single-addon-private-test',
          'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
          'files':{n:hashlib.sha256(p.read_bytes()).hexdigest() for n,p in files}}
DIST.mkdir(exist_ok=True)
out=DIST/NAME
with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for n,p in files:z.write(p,n)
    z.writestr('TargetSC/BUILD_MANIFEST.json',json.dumps(manifest,indent=2)+'\n')
with zipfile.ZipFile(out) as z:
    assert z.testzip() is None
    assert all(n.startswith('TargetSC/') for n in z.namelist())
    for n in z.namelist():
        if n.endswith('.png'):
            assert z.read(n).startswith(b'\x89PNG\r\n\x1a\n'),n
print(f'PASS {out} ({len(files)} files, SHA256={hashlib.sha256(out.read_bytes()).hexdigest()})')
