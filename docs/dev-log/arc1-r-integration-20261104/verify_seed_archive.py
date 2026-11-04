#!/usr/bin/env python3
"""Verify retained audit-source bytes against the historical candidate map."""
import hashlib
import json
import sys
import zipfile
from pathlib import PurePosixPath


def safe_path(name):
    p = PurePosixPath(name)
    return bool(name) and str(p) == name and not p.is_absolute() and all(part not in ('.', '..') for part in p.parts) and '\\' not in name


def verify(archive, candidate, pinned_hash):
    expected_candidate = hashlib.sha256(candidate).hexdigest()
    if expected_candidate != pinned_hash:
        raise ValueError('candidate does not match externally pinned hash')
    audit = json.loads(candidate)['manifest_preflight']['verified']['historical_seed_audit']['scanned_paths']
    expected = {}
    for row in audit:
        path, digest = row['path'], row['sha256']
        if not safe_path(path) or path in expected or len(digest) != 64 or any(c not in '0123456789abcdef' for c in digest):
            raise ValueError('invalid candidate path or hash')
        expected[path] = digest
    with zipfile.ZipFile(archive) as z:
        names = z.namelist()
        if len(names) != len(set(names)) or 'MANIFEST.json' not in names:
            raise ValueError('duplicate or missing archive member')
        manifest = json.loads(z.read('MANIFEST.json'))
        if manifest['candidate_sha256'] != expected_candidate or manifest['expected'] != len(expected):
            raise ValueError('candidate identity or denominator mismatch')
        files, missing = {}, {}
        for row in manifest['files']:
            path, digest = row['path'], row['sha256']
            if not safe_path(path) or path in files or expected.get(path) != digest:
                raise ValueError('invalid recovered path')
            member = 'historical-source/' + path
            info = z.getinfo(member)
            file_type = (info.external_attr >> 16) & 0o170000
            if info.is_dir() or file_type not in (0, 0o100000):
                raise ValueError('non-regular payload')
            if hashlib.sha256(z.read(member)).hexdigest() != digest:
                raise ValueError('payload hash mismatch')
            files[path] = digest
        for row in manifest['missing']:
            path, digest = row['path'], row['expected_sha256']
            if not safe_path(path) or path in missing or path in files or expected.get(path) != digest:
                raise ValueError('invalid missing path')
            missing[path] = digest
        if set(files) | set(missing) != set(expected) or manifest['recovered'] != len(files):
            raise ValueError('incomplete or inconsistent classification')
        if set(names) != {'MANIFEST.json'} | {'historical-source/' + p for p in files}:
            raise ValueError('unlisted archive members')
    print(f'ARCHIVE_VERIFIED {len(files)}/{len(expected)}; {len(missing)} gaps')


if __name__ == '__main__':
    if len(sys.argv) != 4:
        sys.exit('usage: verify_seed_archive.py ARCHIVE CANDIDATE_JSON PINNED_SHA256')
    try:
        with open(sys.argv[2], 'rb') as f:
            verify(sys.argv[1], f.read(), sys.argv[3])
    except (ValueError, KeyError, OSError, zipfile.BadZipFile) as exc:
        sys.exit(f'ARCHIVE_INVALID: {exc}')
