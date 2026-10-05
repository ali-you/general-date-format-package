# Locale data sources

Canonical symbol and pattern tables live in
`packages/general_date_format_core/lib/src`. The generators below write there;
the Flutter wrapper forwards to those same libraries. Both distributed cores
retain their data-license notices.

Gregorian formatting belongs to the application and uses `intl.DateFormat`.
Persian and Hijri bundle weekday names, quarters, AM/PM markers, time/date-time
formats, first weekday, weekend range, and first-week cutoff in
`calendar_neutral_data.dart`. These calendar-independent fields are a pinned
intl 0.20.3 / CLDR 48 snapshot, with Gregorian months and eras excluded.
Those fields depend on language and territory, not the calendar's month names.
The package retains its existing native-digit defaults and calendar date patterns.

`en_ISO` retains intl's explicit ISO Monday convention. `en_MY` also starts on
Monday in intl and Unicode CLDR 48. Flutter's Material English fallback starts
on Sunday; this difference is deliberate rather than copying the fallback into
the calendar data. Tests verify each source's convention with its index system.

The Afrikaans Persian month and era correction is generated from Unicode CLDR
48, tag `48.0.0`, `cldr-cal-persian-full/main/af/ca-persian.json`:

```sh
python tool/generate_persian_af_symbols.py
python tool/generate_persian_af_symbols.py --check
```

The script caches the pinned input in `.dart_tool/cldr-48/persian-af.json`, writes
the source URL and SHA-256 digest into the output, and supports a non-writing
regeneration check. The generated names are `Farvardin` through `Esfand`, with
the CLDR era `AP`. They describe Persian months, not Gregorian months.

All Persian month/era names now use the unified pinned CLDR generator described below.
Calendar-independent skeleton patterns and digit/date-order compatibility policies
are tracked explicitly rather than maintained as anonymous legacy Dart tables.

Hijri month and era names use `generate_hijri_symbols.py` with the same pinned
CLDR release. See `THIRD_PARTY_NOTICES.md` for the Unicode data license.

## Reproducible calendar names and compatibility patterns

Run the unified generator from the formatter repository:

```sh
python tool/generate_calendar_data.py --check
python tool/generate_hijri_symbols.py --check
python tool/generate_persian_af_symbols.py --check
```

On Windows, pass `--dart <absolute-dart.exe>` to the first two commands if Dart
is available only through a batch wrapper. Generation uses the Dart formatter
for deterministic source layout. Checks may populate ignored source caches but
never rewrite tracked outputs or source locks. Every pinned CLDR input is
verified against `cldr_sources.lock.json`; a modified cache is rejected.
`--refresh-lock` is an explicit maintainer operation requiring review of pinned
input hashes, not a normal CI step. License notices are never overwritten.

All Persian/Hijri month and era names now come from CLDR 48. Shared neutral
metadata comes from the bundled snapshot in `calendar_neutral_symbols.json`.
`calendar_neutral_sources.json` records the original source and snapshot SHA-256
hashes. The unified generator verifies the snapshot hash and locale coverage
before regenerating the Dart table, including during `--check`. To deliberately
refresh it, prepare a reviewed snapshot outside these packages, preserving its
source attribution, and update the data and source/hash manifest together.
The one-time intl exporter has been removed; package tools use the checked-in
snapshot without importing intl. `locale_compatibility.json`
is the explicit policy for existing date ordering, digit defaults, shared
skeletons and en_ISO short-label/era exceptions. `export_locale_policy.dart`
was the one-time migration snapshot; do not rerun it on migrated data.
`locale_migration_report.json` records retained pattern differences against
Persian CLDR. The existing skeleton API chooses its pattern before knowing
which runtime calendar will be formatted; calendar-independent compatibility
patterns remain deliberate exceptions, not a full CLDR calendar matcher.

CLDR changes English Persian abbreviations such as `Ord` to `Ordibehesht`,
Persian abbreviations such as `ارد` to `اردیبهشت`, and default era names to
`AP`/`ه‍.ش.`/`هجری شمسی` as applicable. en_ISO retains its explicit compatibility
short labels and era wording. Native-digit defaults and date order are retained.

## Release measurements

From `packages/general_date_format_core`:

```sh
dart compile exe benchmark/release.dart -o .dart_tool/calendar_benchmark
python ../../tool/measure_release.py .dart_tool/calendar_benchmark --output ../../tool/performance_baseline.json
```

Use an `.exe` suffix on Windows. The five-process report includes AOT executable
size, first-format time, warm format/strict-parse cost and process RSS. It records
the current implementation, not an old/new comparison or a universal device
budget. Repeat on the same host, fixture and SDK before evaluating changes.
The current Windows/Dart 3.13.4 AOT executable is 6,718,464 bytes. Source-table size
is not a release size estimate. Browser/app artifacts are measured independently.

For the separate demo's release JavaScript build:

```sh
python tool/measure_web_release.py ../general_date/apps/calendar_demo/build/web --output tool/performance_web_baseline.json --sdk "<Flutter and Dart versions>"
```

The recorded Flutter 3.47.5/Dart 3.13.4 build contains 43,740,857 bytes across
all packaged files. `main.dart.js` is 3,452,264 bytes (837,855 with offline gzip).
The total includes renderer alternatives, fonts, assets and symbol files; it is
neither a single page's download size nor a formatter-only budget. Browser
startup timing and memory require separate measurements.
