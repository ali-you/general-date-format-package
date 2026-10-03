# general_date_format project analysis

## Fix status

The findings below record the original review. The subsequent implementation
fixes calendar-specific symbols, Gregorian handling, Hijri names/eras, local
and UTC parsing, day-of-year validation, compact patterns, hour ranges,
two-digit years, pattern cache invalidation and invalid quoted patterns.
It also replaces the counter example, corrects documentation, and adds CI
analysis/formatting checks. Persian and Hijri Material localization delegates
now integrate calendar formatting, strict input parsing and Flutter translations
with the companion package's calendar delegates. Time-zone patterns fail explicitly and remain
unsupported; fractional precision remains milliseconds for intl compatibility.

Validation after the fixes and comprehensive test expansion: 488 package tests
passed with the hosted dependency and 488 with the local general_date override.
216 tests are tagged critical. Measured package line coverage is 94.3%.
Static analysis reported no issues. Three widget tests cover the example's
three calendars, locale switching, and Persian/Hijri picker dialogs.
The original suite contributed 95 tests; 36 calendar/parsing regression tests,
319 comprehensive tests and 38 Material localization tests were added.
All 120 locales are exercised for each
of the three calendars. See TESTING.md for the suite and timezone CI details.

Hijri data is generated from pinned CLDR 48.0.0 with a reproducible Python
generator and Unicode license notice. The normal dependency still uses hosted
general_datetime; the local override is confined to the ignored audit setup.
The formatter includes a compatibility fallback for the hosted 2.1.0 Hijri UTC
constructor's lost UTC flag. No companion-package source was changed.

## Original review

Reviewed on 2026-10-03. Scope: `D:/StudioProjects/general_date_format` and its integration with `D:/StudioProjects/general_date`.

## Assessment

The package is a useful foundation for localized Persian date formatting with an `intl.DateFormat`-style API. Its named constructors, skeleton expansion, explicit patterns, quoted literals, and native-digit options work for the covered Persian cases. It is not yet reliable as a general formatter/parser for Gregorian, Persian, and Hijri calendars. The most serious gaps are incorrect Hijri symbol data, state-dependent Gregorian behavior, and incomplete parsing.

No implementation, existing tests, or normal dependency manifests were changed during this review. This report is the only new file outside ignored audit directories.

## How the projects fit together

- `general_datetime` owns calendar construction, conversion, arithmetic, time zones, and calendar fields. The local package exports `PersianDateTime` and `HijriDateTime`, both extending `DateTime` and implementing `GeneralDateTimeInterface`.
- `general_date_format` owns string formatting and intended parsing. `GeneralDateFormat.format(DateTime)` reads the object's calendar fields directly; it does not convert the input into a requested calendar.
- `lib/src/general_date_format.dart` exposes the formatters, locale resolution, skeletons, and parsing methods. Its private field classes live in `date_format_field.dart`; `DateBuilder` constructs parsed dates.
- Localized symbols are selected globally in `general_date_format_internal.dart`. Two symbol tables and a common pattern table advertise 120 locales.
- The normal dependency is hosted `general_datetime: ^2.1.0`. The existing package configuration resolves the Pub cache copy, not `D:/StudioProjects/general_date`. Both currently use the version number 2.1.0 despite their different implementations.
- The local project's Material calendar delegates use ambient `MaterialLocalizations`. This formatter package provides no working localization delegate or automatic date-picker integration; `loadDateIntlDataIfNotLoaded()` is an unused no-op. A future integration belongs in calendar-specific Material localizations.

## Verified findings

### P1: Hijri names and eras are Persian

Source: `lib/src/symbols/hijri_symbol_data_local.dart:6`.

The entire Hijri table equals the Persian table after replacing the map variable name. Runtime comparison confirms equality for all 120 locales.

For `HijriDateTime(1446, 9, 1)`, formatting `yyyy-MM-dd MMMM G` in English produces `1446-09-01 Azar S.Y.`. Month 9 should identify Ramadan, and the era data must correspond to the Hijri calendar. Arabic formatting also produces the Persian month name.

Action: replace Hijri month, abbreviated month, narrow month, standalone month, and era data with calendar-appropriate localized data. Validate translations independently; successful formatting alone does not establish correctness.

### P1: Gregorian behavior depends on previous formatting

Source: `lib/src/general_date_format_internal.dart:31` and `lib/src/general_date_format.dart:794`.

Initialization handles only Persian and Hijri objects. Formatting a native `DateTime(2025, 3, 1)` before other formatting throws an initialization/null-check error. After formatting a Persian date, the same native date formatted with `yyyy-MM-dd MMMM` produces `2025-03-01 Khordad`.

Action: select symbols explicitly by calendar and locale, implement Gregorian symbols or delegate Gregorian formatting to `intl`, and remove reliance on whichever symbol map was initialized last. If a calendar is unsupported, reject it clearly before returning misleading output.

### P1: Parsing crashes, constructs the wrong calendar, and ignores UTC

Source: `lib/src/date_builder.dart:139` and `lib/src/general_date_format.dart:493`.

- `parse('1403-01-01', PersianDateTime(...))` throws a null-check error. `DateBuilder.asDate()` assigns its cached result only when `utc && _hasCentury`; normal local parsing therefore returns `_date!` while it is null.
- `tryParse` also throws this error because it catches only `FormatException`.
- `parseUtc` creates a local `PersianDateTime`, so the returned object's `isUtc` is false.
- Parsing a Hijri input with a Hijri type argument still returns `PersianDateTime`. `_typeSelector()` returns Persian instances in both branches, and the main builder bypasses it entirely.
- Parsing before any formatting has occurred can fail on valid input because `_parse()` never initializes the required symbols. Its field-level catch converts the initialization error into a misleading `FormatException`.
- Two-digit years also fail to populate `_date` when their century is ambiguous; year estimation uses Persian current dates regardless of the requested calendar.

Action: finish calendar-aware date construction for local and UTC modes, initialize parsing context before reading fields, and preserve documented parse/tryParse error behavior. Use calendar-specific defaults and century estimation.

### P1: Day-of-year is hard-coded to Persian

Source: `lib/src/date_format_field.dart:622` and `lib/src/date_builder.dart:99`.

Formatting `D` for `HijriDateTime` throws a type-cast error. Both date classes already provide `dayOfYear` through `GeneralDateTimeInterface`.

Strict parsing checks the supplied type-selector object's day-of-year rather than the constructed result. Parsing `1403 100` with pattern `yyyy D` and a type-selector date on day 1 rejects valid input, even though the constructed date is `1403-04-07`.

Action: calculate and validate day-of-year using the selected calendar and the parsed result. Native Gregorian dates need an appropriate implementation too.

### P2: Additional parsing and pattern edge cases

Source: `lib/src/date_format_field.dart:298`, `lib/src/general_date_format.dart:511`, and `lib/src/general_date_format.dart:933`.

- Compact `yyyyMMdd` parsing consumes the entire numeric input as a year, then fails reading the month. Numeric fields read all consecutive digits without accounting for adjacent fields.
- A `k` hour round-trip formats `13:05`, then parses it as `12:05`; the parser subtracts one from every hour. This behavior is also present in the cached `intl` implementation inspected during review, so address it deliberately when defining compatibility.
- An unmatched quote in `yyyy 'unfinished` silently truncates output to `1403 `.
- Reading `dateOnly`, then appending a time pattern, leaves the cached property true. `addPattern()` clears parsed fields but does not invalidate `_dateOnly`.

Action: define supported pattern semantics and cover adjacent numeric fields, invalid patterns, round-trips, and formatter mutation.

### P2: Documentation and example do not match the API

Source: `README.md:65`, `lib/src/general_date_format.dart:239`, and `example/lib/main.dart`.

The README uses `JalaliDateTime`, which the current dependency does not export, and calls `GeneralDateFormat.format(...)` as a static method even though it is an instance method. It also omits the date package import. The class documentation says the default locale comes from `Intl.systemLocale`, but the helper actually fixes it to `en_US`.

The example is the generated Flutter counter app and demonstrates no package functionality. Its pubspec contains an unrelated `ambient_light` dependency and lacks `publish_to: none` despite using a path dependency.

Correct basic usage:

```dart
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

final date = PersianDateTime(1403, 1, 1);
final formatted = GeneralDateFormat('yyyy/MM/dd', 'fa').format(date);
// ۱۴۰۳/۰۱/۰۱
```

### P2: Tests and CI miss the failing functionality

Source: `test/persian_date_format_test.dart` and `.github/workflows/flutter.yml:27`.

The 95 tests exercise Persian formatting, mainly default English and Persian locales. They contain no formatter parsing tests or Hijri/Gregorian formatting tests. CI runs `flutter test` but does not run analysis or enforce formatting.

Action: add meaningful regression tests for the findings above. Test calendar/locale combinations, fresh initialization, alternating calendars, local/UTC parsing, invalid inputs, leap boundaries, and format/parse round-trips. Include integration coverage against the intended `general_datetime` version.

## Other limitations and maintenance observations

- Arbitrary `GeneralDateTimeInterface` implementations are not automatically supported: the API requires `DateTime`, and symbol selection recognizes only two concrete date classes. A calendar adapter/provider registry would make the stated extensibility concrete.
- Time-zone fields `z`, `Z`, and `v` emit empty strings. Related constructors already say they are unimplemented. Either explicitly document unsupported fields or implement them; do not imply full `intl` feature parity.
- Six fractional digits produce `789000` for milliseconds 789 and microseconds 123. This is millisecond precision with padding, also matching the inspected cached `intl` code. It does not preserve the local date package's microsecond precision, despite a test comment referring to it.
- `lastCalendar` is never assigned, so symbol initialization and cache invalidation happen on every supported-calendar formatting call. Merely assigning a date object would still make this cache depend on date equality rather than calendar identity.
- `dateTimePatternMap` is a getter that creates the outer map repeatedly; `addPattern()` can access it twice. Reuse immutable data, and cache by calendar/locale where appropriate. No performance benchmark was conducted.
- The package declares Flutter `>=1.17.0`; the local companion package declares `>=3.32.0`. Align documented support and the intended dependency release before publishing changes that require the local code.
- A substantial amount of formatter code resembles the inspected cached `intl` implementation. Track the upstream version and retained modifications to make future maintenance and compatibility decisions explicit.

## Validation results

Environment: Windows, Dart 3.13.4, Flutter 3.47.5. The process used a +03:30 local offset.

| Check | Result |
| --- | --- |
| Existing suite with hosted `general_datetime` 2.1.0 | 95 passed |
| Existing suite with local `D:/StudioProjects/general_date` override | 95 passed |
| Runtime probes against both dependencies | Identical outputs; confirmed failures above |
| Locale/symbol/pattern key consistency | 120 locales, no missing entries |
| Long date plus time formatting for 120 locales × 2 calendars | 240 calls succeeded; translation accuracy not validated |
| Explicit ASCII digit option in Persian locale | Worked |
| Static analysis | 0 error diagnostics, 1 warning, 158 informational lints |

The analysis warning concerns the publishable example's path dependency. Informational diagnostics are identifier-naming lints, many arising from `intl`-style API names.

The original `.dart_tool/package_config.json` is stale relative to the installed SDK and points to missing `meta` and `test_api` cache versions. The initial normal test attempt could not compile. Dependencies were resolved offline in isolated ignored audit folders, allowing both suites to run without modifying the normal pubspecs, lockfiles, or package configuration.

Audit materials remain under `.dart_tool/project_audit`: the probe source, isolated manifests, analyzer output, and test/probe output for hosted and local dependencies. These are ignored by Git. The companion package was read and used as a dependency; its own complete test suite was not run in this review.

## Recommended implementation order

1. Define explicit calendar selection and obtain symbols by calendar plus locale; repair Hijri data and Gregorian handling.
2. Finish parsing with correct calendar construction, UTC/local behavior, day-of-year validation, and predictable errors.
3. Add regression tests for those fixes, then update CI to run analysis with intentional treatment of compatibility naming lints.
4. Replace the README snippet and counter example with executable Persian, Hijri, and Gregorian examples; document unsupported features.
5. Optimize immutable data lookup and introduce calendar adapters if additional calendars are a real requirement.

Treat calendar construction and conversion as responsibilities of `general_datetime`; keep localized string formatting and parsing in `general_date_format`. This preserves a clear boundary and avoids duplicating calendar algorithms.
