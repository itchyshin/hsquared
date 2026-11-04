#!/usr/bin/env python3
"""Reproduce Arc 1 seed-guard checks without model fitting.

The input repository must contain the pinned Julia trial commit. The evidence
ZIP must contain the seven original outer33 files at their recorded paths.
The JSON result is written only if its output path does not already exist.
"""
import argparse
import ast
import hashlib
import json
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

TRIAL = '927b8f11bba481e6d5adb6e65e6a1469b5dcd0ed'
LANE = 'LOOP/lanes/arc1-gaussian-reliability-20261002/evidence/g2-development-nine-cell-admission-v17'
FILES = {
    'candidate': 'candidate.json', 'source_lock': 'source-lock.tsv',
    'review': 'independent-review-receipt-v17.json',
    'owner_approval': 'owner-approval-v17-outer33.json',
    'preflight': 'totoro-current-state-preflight-v17.json',
    'receipt': 'retained-attempt-outer33-v17-ingest.json',
    'result': '0033.result.json',
}
POSITIVE = '''from pathlib import Path
import sys,tempfile
root=Path.cwd();sys.path.insert(0,str(root/'test'));sys.path.insert(0,str(root/'tools'))
from test_arc1_manifest_amendment import FaRankDevelopmentAmendmentTests
import arc1_manifest
with tempfile.TemporaryDirectory(prefix='arc1-positive-') as temp:
    fixture=FaRankDevelopmentAmendmentTests()._outer33_fixture(Path(temp))
    result=arc1_manifest._documented_consumed_seed_exceptions(Path(temp),fixture['audit'])
    assert len(result)==1 and result[0]['key']==['fa_rank','development',80,'null',33,0,'data']
    print('POSITIVE_CONTROL_PASS')
'''
AUDIT = '''from pathlib import Path
import json,sys
sys.path.insert(0,'tools');import arc1_manifest as m
root=Path.cwd();audit=m.historical_seed_audit(root);seed=m._OUTER33_CONSUMPTION['seed']
try:m.validate(root);result='PASS'
except ValueError as e:result='REFUSED: '+str(e)
print(json.dumps({'scanned_paths':len(audit['scanned_paths']),'occurrences':m._seed_context_occurrences(root,audit,seed),'documented_exceptions':len(audit['documented_allocated_seed_consumptions']),'validate':result},indent=2))
'''


def run(clone, *args):
    command = [sys.executable, '-B', '-I', *args]
    result = subprocess.run(command, cwd=clone, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True, check=False)
    return {'command': command, 'exit_code': result.returncode, 'output': result.stdout}


def run_replay(repo, outer_zip, output):
    if output.exists():
        raise FileExistsError('output already exists')
    with tempfile.TemporaryDirectory(prefix='arc1-guard-replay-') as tmp:
        clone = Path(tmp) / 'repo'
        subprocess.run(['git', 'clone', '--quiet', '--no-checkout', str(repo), str(clone)], check=True)
        subprocess.run(['git', 'checkout', '--quiet', '--detach', TRIAL], cwd=clone, check=True)
        head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=clone, text=True).strip()
        if head != TRIAL:
            raise ValueError('incorrect Julia trial commit')
        parsed = ast.parse((clone / 'tools/arc1_manifest.py').read_text())
        pin = next(ast.literal_eval(n.value) for n in parsed.body if isinstance(n, ast.Assign)
                   and any(isinstance(x, ast.Name) and x.id == '_OUTER33_CONSUMPTION' for x in n.targets))
        hashes = {}
        with zipfile.ZipFile(outer_zip) as z:
            if len(z.namelist()) != len(set(z.namelist())):
                raise ValueError('duplicate evidence archive members')
            for key, name in FILES.items():
                member = LANE + '/' + name
                info = z.getinfo(member)
                kind = (info.external_attr >> 16) & 0o170000
                if info.is_dir() or kind not in (0, 0o100000):
                    raise ValueError('non-regular evidence member')
                data = z.read(info)
                digest = hashlib.sha256(data).hexdigest()
                if digest != pin[key + '_sha256']:
                    raise ValueError('pinned evidence mismatch: ' + name)
                target = clone / LANE / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(data)
                hashes[name] = digest
        receipt = {
            'source_commit': head,
            'scope': 'No fits: disposable clone, seven pinned files, manifest and guard checks only.',
            'seven_copied_file_sha256': hashes,
            'suite': run(clone, '-m', 'unittest', 'discover', '-s', 'test', '-p',
                         'test_arc1_manifest_amendment.py', '-v'),
            'positive_control': run(clone, '-c', POSITIVE),
            'audit_diagnostic': run(clone, '-c', AUDIT),
        }
    with output.open('x', encoding='utf-8') as f:
        json.dump(receipt, f, indent=2)
        f.write('\n')
    print('RECEIPT_WRITTEN', output)
    print('suite exit', receipt['suite']['exit_code'], 'positive exit',
          receipt['positive_control']['exit_code'], 'audit exit', receipt['audit_diagnostic']['exit_code'])
    print('Receipt creation is not a claim that the guard suite passed.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--outer33-archive', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    try:
        run_replay(args.repo.resolve(), args.outer33_archive.resolve(), args.output.resolve())
    except (OSError, ValueError, KeyError, StopIteration, zipfile.BadZipFile, subprocess.CalledProcessError) as exc:
        sys.exit('REPLAY_FAILED: ' + str(exc))
