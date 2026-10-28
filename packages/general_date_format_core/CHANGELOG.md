# Changelog

## 2.0.0 — 2026-10-28

- Fix strict and loose parsing of digit-ending Chinese month names next to
  fixed-width numeric fields; test all supported years, digit modes, and
  cross-calendar reuse on VM and JavaScript.


- Add Chinese date formatting and strict/loose parsing with pinned CLDR 48
  regular/leap month names across all bundled locales. Numeric months remain
  chronological ordinals; reject unsupported era and quarter patterns.
- Add translated Chinese Material localizations, picker integration, and
  all-locale leap-month round-trip coverage.


- Verify Hebrew locale tables, all-locale round trips, minimum Dart support,
  and JavaScript parsing across three historical/DST timezone fixtures.

- Add JavaScript format/parse regressions for odd microseconds in ancient and
  future Hebrew/Persian dates, consuming the chronology precision correction.

- Require `general_datetime_core ^2.0.0`, including the Hebrew calendar APIs
  and new public `CalendarId` case.

- Support HebrewDateTime with CLDR 48 month and AM era names for all locales.
- Format Adar II by year type; validate parsed leap-month names and stable
  numeric month slots against the input year. Preserve microseconds, digit
  policy, ordinal/weekday/era validation, and rolling Hebrew year windows.
- Add locale round trips and leap-name regressions, including numeric name
  boundaries. Quarter patterns explicitly remain unsupported for Hebrew.
- Preserve Persian/Hijri output in 850,228 before/after comparison records.
  Add five formatter coexistence regressions; the complete core suite has
  75 tests and the timezone/Node selection has 64 tests per zone.

- Remove the unused deprecated locale initialization hook. Locale data continues
  to load lazily; Flutter adapters reference the core directly.
- Export locale resolution helpers through the public core library so Material
  adapters do not import core implementation files.
- Validate strict/loose era labels against the resolved year's sign, preserving
  ambiguous labels and signed-year round trips, including year zero.
- Resolve two-digit years across chronology bounds and negative centuries;
  compare wall-field window endpoints and keep repeated-year range failures
  within the documented FormatException/nullable parsing contracts.
- Reject local DST normalization that changes minutes, seconds, or fractional
  seconds during strict/loose parsing; preserve permissive parsing and the
  date-only one-hour midnight exception.
- Remove Gregorian formatting/parsing from GeneralDateFormat; applications use
  intl.DateFormat directly and choose their own locale initialization.
- Bundle Persian/Hijri neutral locale metadata and remove intl and clock from
  the Dart core. The Flutter adapter also has no direct intl dependency.
- Add a per-formatter native `now` callback for two-digit year parsing.
- Default pre-operation dateSymbols to Persian; reject native DateTime selectors
  with UnsupportedError, including nullable parsing APIs.

## 1.0.0 — release preparation

- Extract the corrected pure Dart implementation from the Flutter package.
- Preserve exact microseconds in six-digit fraction formatting/parsing, including
  localized digits, and reject excess nonzero precision in strict/loose parsing.
- Generate Persian and Umm al-Qura names from checksum-locked CLDR 48 sources,
  preserving documented locale and shared-pattern compatibility policies.
