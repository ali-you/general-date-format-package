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

The package has 493 tests, including 221 tagged `critical`: 131 formatting and
regression tests, 319 boundary/contract/locale/state tests, and 38 Material
localization integration tests, plus five corrected-core dependency-contract
tests. The example has three widget tests.

| Suite | Coverage |
| --- | --- |
| `dependency_contract_test.dart` | Independent Umm al-Qura conversion anchor, the reported negative-day regression, strict UTC parsing, symmetric native equality/hash keys, finite supported bounds |
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

The suite requires corrected `general_datetime` 3.x. Hosted 2.1.0 is deliberately
excluded. To use the neighboring local project, copy the tracked templates:

```powershell
Copy-Item pubspec_overrides.yaml.example pubspec_overrides.yaml
Copy-Item example/pubspec_overrides.yaml.example example/pubspec_overrides.yaml
flutter pub get
Push-Location example
flutter pub get
Pop-Location
```

The overrides are ignored and use relative paths. Run `flutter test` from the
package directory. Once general_datetime 3.0.0 is published, remove the
overrides, resolve again, and rerun the suite to verify the hosted 3.x package.
The dependency-contract tests prevent a field-only formatter round trip from
masking an incorrect chronology or native-instant contract.

## Scope and limitations

Tests validate formatting and parsing against the selected calendar dependency.
Persian/Hijri arithmetic and conversion algorithms belong to `general_datetime`;
the published 3.x release and its matching source must use the same chronology.
Fixed Gregorian and Persian month fixtures and the independent Umm al-Qura
anchor supplement the integration checks.

Some translated abbreviated/narrow month names are shared by multiple months.
Locale tests require those ambiguous names to retain their spelling and date
fields, while requiring unique names and numeric dates to retain the exact month.
Millisecond round trips deliberately expect discarded microseconds, matching the
documented fractional-second contract.

Measured line coverage on the installed Flutter SDK is 94.3% (1,044 of 1,107
instrumented package lines); this does not measure branch coverage or the
calendar dependency. Recalculate it after changes using `flutter test --coverage`.
