# Testing

Run from the package directory after `flutter pub get`:

```sh
flutter test
flutter test --tags critical
flutter test --coverage
flutter analyze
dart format --output=none --set-exit-if-changed lib test example/lib example/test
```

Run the example's widget test separately:

```sh
cd example
flutter test
```

The package has 488 tests, including 216 tagged `critical`: 131 formatting and
regression tests, 319 boundary/contract/locale/state tests, and 38 Material
localization integration tests. The example has three widget tests.

| Suite | Coverage |
| --- | --- |
| `calendar_boundaries_test.dart` | Gregorian leap centuries, Persian long/short months, every month's last valid day, every ordinal day in two years per calendar, all 24 hours, all quarters, fractional precision, BC/AD, weekdays |
| `parsing_contract_test.dart` | Malformed and oversized input, invalid dates/times, throwing and nullable APIs, permissive/strict/loose differences, compact fields, selector defaults, century cutoffs, quoting, missing textual fields, unsupported patterns |
| `formatter_state_test.dart` | Alternating calendars, failure recovery, unregistered calendars, native-digit toggles and defaults, pattern mutation, UTC/local instants, midnight DST jumps and nonexistent wall times |
| `locale_round_trip_test.dart` | All 120 locales across twelve months and three calendars, named patterns, aliases, an independent `intl` Gregorian oracle, loose names/whitespace, deterministic generated dates |
| `calendar_material_localizations_test.dart` | Calendar delegate formatting, strict compact input, Flutter translations and plural rules, consistent native/ASCII numeric labels, supported locales, RTL calendar/input widgets, disabled year labels, extended Persian dates |

The generated matrix uses seed `0x5eed`: 100 dates for each calendar, locale
(`en`, `fa`, `ar`), and UTC/local combination. Each of its 1,800 samples is
checked with four patterns, including compact, textual, and ordinal dates.
Failure messages include the seed, sample index, pattern, and input.

CI runs the complete package and example suites with `TZ` set to `UTC`,
`Asia/Tehran`, and `America/New_York` on Linux. The DST tests compare with native
`DateTime` and exercise historical Tehran midnight changes and New York's
spring gap. Local Windows runs use the operating system's configured timezone;
they do not prove that every CI timezone has passed.

## Local calendar integration

The same suite works with the hosted `general_datetime` dependency and the local
project. To test the local project, create an uncommitted
`pubspec_overrides.yaml`:

```yaml
dependency_overrides:
  general_datetime:
    path: D:/StudioProjects/general_date
```

Run `flutter pub get` and `flutter test`. Remove the override, resolve again,
and rerun the suite to verify the hosted package. Avoid committing the override.

## Scope and limitations

Tests validate formatting and parsing against the selected calendar dependency.
Persian/Hijri arithmetic and conversion algorithms belong to `general_datetime`;
month lengths can differ between its hosted and local implementations. Fixed
Gregorian and Persian month fixtures supplement the integration checks.

Some translated abbreviated/narrow month names are shared by multiple months.
Locale tests require those ambiguous names to retain their spelling and date
fields, while requiring unique names and numeric dates to retain the exact month.
Millisecond round trips deliberately expect discarded microseconds, matching the
documented fractional-second contract.

Measured line coverage on the installed Flutter SDK is 94.3% (1,044 of 1,107
instrumented package lines); this does not measure branch coverage or the
calendar dependency. Recalculate it after changes using `flutter test --coverage`.
