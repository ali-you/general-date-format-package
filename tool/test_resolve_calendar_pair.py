import hashlib
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).with_name('resolve_calendar_pair.py')


class PairResolutionTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        root = Path(self.temporary.name)
        self.chronology = root / 'chronology'
        self.formatter = root / 'formatter'
        for path in [self.chronology, self.chronology / 'packages/general_datetime_core',
                     self.formatter, self.formatter / 'packages/general_date_format_core',
                     self.formatter / 'example']:
            path.mkdir(parents=True, exist_ok=True)
            (path / 'pubspec.yaml').write_text('name: fixture\n', encoding='utf-8')

    def run_helper(self, *extra):
        return subprocess.run([sys.executable, str(SCRIPT),
            '--chronology', str(self.chronology), '--formatter', str(self.formatter), *extra],
            capture_output=True, text=True)

    def test_generated_paths_and_idempotence(self):
        self.assertEqual(self.run_helper().returncode, 0)
        path = self.formatter / 'pubspec_overrides.yaml'
        content = path.read_text(encoding='utf-8')
        self.assertIn("path: '../chronology'", content)
        first, body = content.split('\n', 1)
        self.assertTrue(first.endswith(hashlib.sha256(body.encode()).hexdigest()))
        self.assertEqual(self.run_helper().returncode, 0)
        self.assertEqual(path.read_text(encoding='utf-8'), content)

    def test_rejecting_an_edited_file_does_not_partially_write_other_files(self):
        path = self.formatter / 'example/pubspec_overrides.yaml'
        original = 'dependency_overrides:\n  user_package:\n    path: ../custom\n'
        path.write_text(original, encoding='utf-8')
        result = self.run_helper()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Preserving edited overrides', result.stderr)
        self.assertEqual(path.read_text(encoding='utf-8'), original)
        self.assertFalse((self.formatter / 'pubspec_overrides.yaml').exists())

    def test_edits_to_generated_output_are_preserved(self):
        self.assertEqual(self.run_helper().returncode, 0)
        path = self.formatter / 'pubspec_overrides.yaml'
        content = path.read_text(encoding='utf-8') + '  user_package: any\n'
        path.write_text(content, encoding='utf-8')
        self.assertNotEqual(self.run_helper().returncode, 0)
        self.assertEqual(path.read_text(encoding='utf-8'), content)

    def test_explicit_replacement(self):
        path = self.formatter / 'pubspec_overrides.yaml'
        path.write_text('dependency_overrides:\n  user_package: any\n', encoding='utf-8')
        self.assertEqual(self.run_helper('--replace-overrides').returncode, 0)
        self.assertNotIn('user_package', path.read_text(encoding='utf-8'))

    def test_unchanged_legacy_output_is_upgraded(self):
        self.assertEqual(self.run_helper().returncode, 0)
        path = self.formatter / 'pubspec_overrides.yaml'
        body = path.read_text(encoding='utf-8').split('\n', 1)[1]
        path.write_text(body, encoding='utf-8')
        self.assertEqual(self.run_helper().returncode, 0)
        self.assertTrue(path.read_text(encoding='utf-8').startswith('# Generated'))


if __name__ == '__main__':
    unittest.main()
