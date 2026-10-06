"""Resolve the unpublished Flutter chronology wrapper from a local checkout.

Both core packages are published and resolve through their pubspecs.
Remove this helper when general_datetime 3.0.0 is available on pub.dev.
"""
import argparse
import os
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--chronology', type=Path, required=True)
parser.add_argument('--formatter', type=Path, required=True)
args = parser.parse_args()
chronology, formatter = args.chronology.resolve(), args.formatter.resolve()
for root in [chronology, formatter]:
    if not (root / 'pubspec.yaml').is_file():
        raise SystemExit(f'Missing repository: {root}')

for directory in [formatter, formatter / 'example']:
    if not (directory / 'pubspec.yaml').is_file():
        continue
    # Relative paths support neighboring checkouts and CI's nested checkout.
    path = Path(os.path.relpath(chronology, directory)).as_posix()
    path = path.replace("'", "''")
    content = f"dependency_overrides:\n  general_datetime:\n    path: '{path}'\n"
    (directory / 'pubspec_overrides.yaml').write_text(content, encoding='utf-8')

print(f'Chronology wrapper: {chronology}\nFormatter: {formatter}')
