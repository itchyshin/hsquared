#!/usr/bin/env python3
"""Negative controls for the retained-source archive verifier."""
import hashlib
import io
import json
import unittest
import warnings
import zipfile

from verify_seed_archive import verify


class VerifyArchive(unittest.TestCase):
    def setUp(self):
        self.content = b'original bytes'
        self.sha = hashlib.sha256(self.content).hexdigest()
        self.candidate = json.dumps({'manifest_preflight': {'verified': {
            'historical_seed_audit': {'scanned_paths': [
                {'path': 'src/file.R', 'sha256': self.sha}
            ]}}}}).encode()
        self.pin = hashlib.sha256(self.candidate).hexdigest()
        self.manifest = {
            'candidate_sha256': self.pin, 'expected': 1, 'recovered': 1,
            'files': [{'path': 'src/file.R', 'sha256': self.sha}], 'missing': []
        }

    def archive(self, content=None, duplicate=False, link=False):
        output = io.BytesIO()
        with warnings.catch_warnings():
            warnings.simplefilter('ignore', UserWarning)
            with zipfile.ZipFile(output, 'w') as z:
                info = zipfile.ZipInfo('historical-source/src/file.R')
                if link:
                    info.create_system = 3
                    info.external_attr = 0o120777 << 16
                z.writestr(info, self.content if content is None else content)
                z.writestr('MANIFEST.json', json.dumps(self.manifest))
                if duplicate:
                    z.writestr('MANIFEST.json', '{}')
        output.seek(0)
        return output

    def test_valid_archive(self):
        verify(self.archive(), self.candidate, self.pin)

    def test_rejects_changed_bytes(self):
        with self.assertRaises(ValueError):
            verify(self.archive(content=b'changed'), self.candidate, self.pin)

    def test_rejects_wrong_candidate_pin(self):
        with self.assertRaises(ValueError):
            verify(self.archive(), self.candidate, '0' * 64)

    def test_rejects_duplicate_member(self):
        with self.assertRaises(ValueError):
            verify(self.archive(duplicate=True), self.candidate, self.pin)

    def test_rejects_symlink(self):
        with self.assertRaises(ValueError):
            verify(self.archive(link=True), self.candidate, self.pin)

    def test_rejects_missing_member(self):
        output = io.BytesIO()
        with zipfile.ZipFile(output, 'w') as z:
            z.writestr('MANIFEST.json', json.dumps(self.manifest))
        output.seek(0)
        with self.assertRaises(KeyError):
            verify(output, self.candidate, self.pin)

    def test_rejects_duplicate_candidate_paths(self):
        parsed = json.loads(self.candidate)
        rows = parsed['manifest_preflight']['verified']['historical_seed_audit']['scanned_paths']
        rows.append(rows[0])
        altered = json.dumps(parsed).encode()
        with self.assertRaises(ValueError):
            verify(self.archive(), altered, hashlib.sha256(altered).hexdigest())

    def test_rejects_traversal(self):
        self.manifest['files'][0]['path'] = '../file.R'
        with self.assertRaises(ValueError):
            verify(self.archive(), self.candidate, self.pin)


if __name__ == '__main__':
    unittest.main()
