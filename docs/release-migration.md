# Hebrew release versions and migration

The prepared source release uses this compatible package set:

| Package | Version | Dependencies in the package manifests |
| --- | --- | --- |
| `general_datetime_core` | **2.0.0** | No runtime dependencies |
| `general_datetime` | **4.0.0** | Chronology core `^2.0.0` |
| `general_date_format_core` | **2.0.0** | Chronology core `^2.0.0` |
| `general_date_format` | **3.0.0** | Formatter core `^2.0.0`, chronology wrapper `^4.0.0` |

Flutter consumers use formatter `^3.0.0` and chronology `^4.0.0`; Dart-only
consumers use both cores at `^2.0.0`. Dart remains `>=3.4.0 <4.0.0`, with
Flutter `>=3.32.0` for wrappers. The example's dependency constraints match.
These versions are prepared in source and have not been published by this work.

## Upgrade from formatter core 1.x / wrapper 2.x

- Use application-owned `intl.DateFormat` for native Gregorian `DateTime`
  formatting/parsing. `GeneralDateFormat` accepts Persian, Hijri or Hebrew
  objects/selectors; native Gregorian and unregistered calendars throw
  `UnsupportedError`, including nullable parsing methods.
- Remove the old locale initialization hook. Bundled calendar locale data loads
  lazily and needs no registration call. Exported `resolveLocale` and
  `verifiedLocale` retain the formatter's locale fallback policy.
- Use `format.now = () => nativeDateTime` for deterministic two-digit-year
  parsing. The callback is read at most once per parse when a year is ambiguous.
- Handle `CalendarId.hebrew` in exhaustive switches and code iterating calendar
  enum values. Existing enum indices and Persian/Hijri JSON remain unchanged;
  old chronology core 1.x decoders cannot read the new Hebrew identifier.
- Observe strict/loose era and rolling-year validation and DST normalization
  rules. Ordinary parsing remains permissive, and nullable counterparts return
  null for `FormatException`, not for unsupported calendar features.

The formatter core no longer depends on `intl` or `clock`; Flutter's
`flutter_localizations` still depends on `intl` transitively. Applications using
`intl` directly must declare and initialize it themselves. Public Flutter imports
continue to re-export the exact same formatter/date classes as the cores;
removed `src` forwarding imports are not a supported boundary.

## Hebrew support

Core 2.0.0 formats and parses Hebrew with CLDR 48 month/AM era names in all
120 locale identifiers. Numeric months retain stable slots 1–13. Adar I=6 is
leap-only, while slot 7 formats as Adar or Adar II for the date's year. Parsing
validates the input year even when a month token comes first. Use actual-month
lists for iteration and six `S` characters for exact microseconds.

Formatter wrapper 3.0.0 adds `HebrewCalendarMaterialLocalizations.delegate` and
the configurable delegate/load variants, with localized digits, input and range
pickers. Pair it with chronology 4.0.0's `HebrewCalendarDelegate`. Hebrew quarter
patterns remain unsupported. See [Hebrew formatting](hebrew-formatting.md).

Five new coexistence tests exercise all locales and preserve Persian/Hijri names,
digits, quarters, month validation and rolling year windows after Hebrew reuse.
Before/after comparisons matched 850,228 existing-calendar records. One optimized
Persian/Hijri-only Dart JavaScript sample grew by 32,231 bytes (7,277 gzip bytes);
this is not a Flutter application size measurement or a CPU/memory benchmark.

## Development and publication

Until hosted releases are available, configure the local source pair:

```console
python tool/resolve_calendar_pair.py --chronology ../general_date --formatter .
flutter pub get
```

The helper preserves edited dependency overrides; it does not silently discard
other local packages. See the [maintainer guide](../tool/README.md).

Resolve the core and example separately before their commands. Publish chronology
core 2.0.0 first, then chronology wrapper 4.0.0 / formatter core 2.0.0, then this
wrapper 3.0.0. Test each consumer against hosted dependencies without development
overrides before publication, and inspect `pub publish --dry-run` archives.
After committing chronology release metadata, refresh `.github/calendar_pair.json`
to that real commit; its current pin records the Hebrew implementation source.

On 2026-10-12, 75 formatter core tests, 509 wrapper tests and 6 example tests
passed; Node selections passed 64 cases in each tested timezone. Chrome JS/Wasm
integration tests and the Android example build passed. Analysis and generation
checks passed. Minimum SDK, hosted resolution, iOS and physical-device execution
remain release checks. No publishing, tags or release uploads were performed.
