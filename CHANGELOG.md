# Changelog

## Unreleased

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
  the Dart core.
- Remove the Flutter wrapper's direct intl dependency, imports and formatter
  bridge. Forward Material translations and number/time conventions through
  Flutter's public localization interface; retain calendar parsing and digits.
- Add a per-formatter native `now` callback for two-digit year parsing.
- Default pre-operation dateSymbols to Persian; reject native DateTime selectors
  with UnsupportedError, including nullable parsing APIs.

## [2.0.0] — release preparation
- Preserve microseconds with six fractional-second digits and native digits.
  Strict/loose parsing rejects nonzero precision beyond six digits; ordinary
  parsing truncates it. Legacy one-to-three-digit output remains millisecond
  based, and wider patterns pad exact zeros after microseconds.
- Generate Persian and Umm al-Qura locale names from checksum-locked CLDR 48
  inputs. Retain shared skeleton patterns and documented compatibility overrides,
  preserve attribution, and add deterministic generation checks.
- Add pinned peer-repository CI, Flutter adapter compatibility coverage, and a
  reproducible native release performance baseline. Published-dependency and
  device/browser matrix execution remain release verification steps.
- Extract formatting, parsing, locale resolution, and symbol data into pure Dart
  `general_date_format_core` 1.0.0, depending on `general_datetime_core` 1.0.0.
  Keep existing public formatter imports and Material localization delegates in
  the Flutter wrapper, with shared formatter/date type identities. Locale
  generators now write the canonical tables in the Dart core package.
- Make the example sample one injectable native clock per screen, deriving
  Gregorian, Persian, and Hijri displays from the same instant. Freeze widget
  fixtures and verify midnight/rebuild consistency and exact picker selections.
- Correct Afrikaans Persian month/era names using generated Unicode CLDR 48
  data. Reconcile all Persian weekday, quarter, time, and week metadata with
  intl's shared locale tables; document generation and source conventions.
  Persian abbreviated weekdays and quarter spellings now match intl.
- Breaking: DateSymbols fields and collections are immutable. Callers can read
  shared symbols or transform detached serializeToMap snapshots for their own
  UI, but cannot customize formatting by mutating global locale data.
- Preserve supported locale scripts during fallback in formatting, parsing and
  Material date/number adapters. Normalize language/script/region components,
  retain regional patterns, and map Chinese scripts to compatible regional data.
- Add script/region regressions and construct advertised script locales with
  Locale.fromSubtags in Material integration tests.
- Validate conflicting/repeated date and time fields in strict and loose parsing,
  preserving ambiguous names and per-token hour ranges/two-digit-year semantics.
- Respect h/K versus H/k hour cycles with AM/PM; validate mixed 24-hour markers
  without shifting the hour.
- Correct numeric c/cc to unpadded locale-relative weekdays 1–7 and validate
  weekday consistency. Update former day-of-month expectations and documentation.
- Breaking: require general_datetime ^3.0.0, excluding the defective published
  2.1.0 chronology and instant contracts. Publish general_datetime first.
- Remove the old Hijri UTC workaround and use the corrected core directly.
- Add dependency-contract regressions for Umm al-Qura conversion, UTC parsing,
  native equality, and supported range APIs.
- Added Persian and Hijri Material localization delegates using calendar-aware
  date formats, translated Flutter labels, native digits and strict input parsing.
- Demonstrate both localized calendar pickers in the example and test their
  integration with calendar delegates and date input fields.
- Preserve signed Persian years when formatting and parsing extended dates.
- Added 319 comprehensive tests, including critical boundary/parser cases,
  all-locale round trips, seeded date generation, and timezone CI coverage.
- Keep native-digit input parseable with ASCII output; require textual fields in
  loose parsing and allow flexible whitespace inside localized names.
- Fixed Gregorian symbol selection and removed shared calendar state.
- Replaced copied Persian data with Unicode CLDR 48 Hijri month and era names.
- Implemented local, UTC, strict and loose parsing for all three supported calendars.
- Fixed day-of-year handling, compact numeric fields, hour ranges, two-digit years,
  fractional-second parsing and pattern-cache invalidation.
- Reject malformed quoted patterns and unsupported time-zone patterns explicitly.
- Reuse locale pattern data and preserve ASCII/native digit parsing.
- Added calendar/parsing regression coverage, analysis and formatting CI checks.
- Replaced the counter example and corrected API documentation.
- Added intl and clock dependencies and aligned Flutter support with 3.32 or newer.

## [1.0.1]
- Updated `general_datetime` dependency to `^2.1.0`
- Improved internal date symbol processing and helper utilities
- Refined pattern parsing logic in `StringStack`
- Synchronized Android build configurations for the example project

## [1.0.0]
- Initial stable release
- Added support for a wide range of locales
- Internal optimizations for pattern parsing and string handling
- Updated example project with latest Android configurations
- Documentation improvements and added `LICENSE`

## [0.1.3]
- Updated `README.md` and documentation

## [0.1.2]
- Some optimizations applied
- Updated `README.md` and documentation

## [0.1.1]
- Full implementation of format functions for `JalaliDateTime`
- Updated `README.md` and documentation

## [0.0.1]
- Initial release with support for all platforms
