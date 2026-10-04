# Locale data sources

Gregorian symbols use the resolved `intl` package's generated locale tables.
Persian and Hijri share those tables' weekday names, quarters, AM/PM markers,
time/date-time formats, first weekday, weekend range, and first-week cutoff.
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

Other Persian month/era names and calendar-specific date patterns retain the
legacy table in `jalali_symbol_data_local.dart`; they have not been certified as
an independently generated CLDR dataset. Its copied neutral fields are ignored
at runtime. A complete migration of those calendar names and the separate
skeleton-pattern table remains a locale maintenance task (checklist issue 22).

Hijri month and era names use `generate_hijri_symbols.py` with the same pinned
CLDR release. See `THIRD_PARTY_NOTICES.md` for the Unicode data license.
