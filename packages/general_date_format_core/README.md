# General Date Format Core

Pure Dart localized formatting and strict/loose parsing for Persian and
Umm al-Qura dates. Its only runtime dependency is our `general_datetime_core`.
Locale data is bundled; there is no `intl`, `clock` or Flutter dependency.

For Gregorian dates, add `intl` to your application and use `intl.DateFormat`
directly. You choose its locale data initialization and digit policy. Native
`DateTime` format/parse selectors (including `tryParse` APIs) throw
`UnsupportedError` with migration guidance. Before its first operation, a
formatter's `dateSymbols` exposes Persian names.

To control the rolling two-digit year window without a clock package, assign
`format.now = () => DateTime.utc(2025, 6, 15)`. Each parse reads this callback at
most once and only for ambiguous two-digit years.

The Flutter `general_date_format` 3.0.0 package re-exports this 1.0.0 core and
adds its existing Material localization delegates. Both imports expose the
same `GeneralDateFormat` type and consume the same calendar date classes.

Formatting, parsing, helpers, and symbol data live only in this core package.
The Flutter wrapper's `lib/src` contains Material localization adapters that
reference the core directly. Locale data loads lazily, so no initialization
hook is needed.

The public core library also exports `resolveLocale` and `verifiedLocale` for
adapters that need the formatter's bundled-data locale fallback policy.

## Installation and development

Both core packages are published on pub.dev. Add them to a Dart application:

```yaml
dependencies:
  general_datetime_core: ^1.0.0
  general_date_format_core: ^1.0.0
```

```dart
import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';

final date = PersianDateTime.utc(1403, 1, 1);
final format = GeneralDateFormat('yyyy/MM/dd', 'fa');
print(format.format(date)); // ۱۴۰۳/۰۱/۰۱
final parsed = format.parseStrict('۱۴۰۳/۰۱/۰۱', date, true);
```

From this package directory (PowerShell):

```powershell
dart pub get
dart analyze
dart test
dart run example/cli.dart
dart compile exe example/cli.dart -o .dart_tool/calendar_cli.exe
```

Version 1.0.0 is published. Development and CI resolve the hosted chronology
core without overrides. Verify hosted dependencies before publishing the
Flutter wrappers.

## Preserved behavior

The date object's runtime type selects the calendar; locale selects language,
patterns, and digits. Strict/loose parser validation, ambiguous names, hour-cycle
rules, locale script fallback, immutable symbols, and generated data are
unchanged by extraction. Named timezone patterns `z`, `Z`, and `v` remain
unsupported. Use `SSSSSS` to round-trip microseconds, including native digits.
One-to-three `S` characters retain the historical minimum three-digit output;
widths four and five truncate output, while widths beyond six pad zeros.
Strict/loose parsing rejects nonzero digits beyond microsecond precision.
Chronology instant serialization remains the appropriate storage contract.

Persian and Umm al-Qura names use generated CLDR 48 inputs with a checksum lock,
attribution, and documented compatibility exceptions in the parent `tool`
directory. Shared skeleton patterns remain a compatibility policy because the
skeleton API selects a pattern before the date object's calendar is known.

The parent Flutter suites verify this same formatter and its Material
integration. Dart tests additionally verify a Flutter-free resolved dependency
graph, UTC calendar round trips, native digits, script fallback, and strict
parser rejection. Locale generators remain in the parent `tool` directory and
write the canonical tables in this package.

BSD 3-Clause; see [LICENSE](LICENSE). Unicode data carries the notice in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
