"""Record release web artifact bytes; this is not a formatter-only size budget."""

import argparse
import gzip
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("build", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--sdk", required=True)
    args = parser.parse_args()
    build = args.build.resolve()
    main_js = build / "main.dart.js"
    if not main_js.is_file():
        parser.error("Expected a release JavaScript build with main.dart.js")
    files = sorted(path for path in build.rglob("*") if path.is_file())
    report = {
        "artifact": "calendar_demo release JavaScript web build",
        "sdk": args.sdk,
        "scope": "Complete demo, Flutter renderer, fonts and assets; not formatter-only",
        "file_count": len(files),
        "total_bytes": sum(path.stat().st_size for path in files),
        "main_js_bytes": main_js.stat().st_size,
        "main_js_gzip_bytes": len(gzip.compress(main_js.read_bytes(), mtime=0)),
        "largest_files": [
            {"path": path.relative_to(build).as_posix(), "bytes": path.stat().st_size}
            for path in sorted(files, key=lambda path: path.stat().st_size, reverse=True)[:10]
        ],
        "notes": "Gzip is an offline size estimate. Timings, device memory and actual HTTP transfer are not measured.",
    }
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
