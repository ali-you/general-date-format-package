"""Run a compiled benchmark repeatedly; record release size and process runtime."""
import argparse
import json
from pathlib import Path
import statistics
import subprocess
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('executable', type=Path)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
runs = []
for _ in range(5):
    start = time.perf_counter()
    result = subprocess.run([str(args.executable.resolve())], check=True, capture_output=True, text=True, encoding='utf-8')
    run = json.loads(result.stdout)
    run['processSeconds'] = time.perf_counter() - start
    runs.append(run)
report = {'executableBytes': args.executable.stat().st_size,
          'medianProcessSeconds': statistics.median(run['processSeconds'] for run in runs),
          'notes': 'Current AOT baseline; not an old/new comparison. Repeat on the same host/toolchain. RSS is process-wide.',
          'runs': runs}
args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(f'Recorded {args.output}; AOT executable: {report["executableBytes"]} bytes')
