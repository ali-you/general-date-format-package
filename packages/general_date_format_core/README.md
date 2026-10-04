# General Date Format Core

Pure Dart localized formatting and strict/loose parsing for Gregorian,
Persian, and Umm al-Qura dates. Depends on `general_datetime_core`, `intl`, and
`clock`; no Flutter SDK or Material localization library is required.

The Flutter `general_date_format` package re-exports this implementation and
adds its existing Material localization delegates. Both imports expose the
same `GeneralDateFormat` type and consume the same calendar date classes.

## Local use before publication

Keep the `general_date` and `general_date_format` repositories beside each other.
For a Dart application beside those checkouts:

```yaml
dependencies:
  general_datetime_core:
    path: ../general_date/packages/general_datetime_core
  general_date_format_core:
    path: ../general_date_format/packages/general_date_format_core
dependency_overrides:
  general_datetime_core:
    path: ../general_date/packages/general_datetime_core
```

The application override selects the unpublished chronology dependency of the
formatting package; an override inside a dependency is not inherited.

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
Copy-Item pubspec_overrides.yaml.example pubspec_overrides.yaml
dart pub get
dart analyze
dart test
dart run example/cli.dart
dart compile exe example/cli.dart -o .dart_tool/calendar_cli.exe
```

Version 1.0.0 is prepared locally and has not been published. Publish
`general_datetime_core` first, then this package. Remove local overrides and
verify hosted dependencies before publishing the Flutter wrappers.

## Preserved behavior

The date object's runtime type selects the calendar; locale selects language,
patterns, and digits. Strict/loose parser validation, ambiguous names, hour-cycle
rules, locale script fallback, immutable symbols, and generated data are
unchanged by extraction. Named timezone patterns `z`, `Z`, and `v` remain
unsupported. Fractional output/parsing retains millisecond precision; use the
chronology core's instant serialization to preserve microseconds in storage.

The parent Flutter suites verify this same formatter and its Material
integration. Dart tests additionally verify a Flutter-free resolved dependency
graph, UTC calendar round trips, native digits, script fallback, and strict
parser rejection. Locale generators remain in the parent `tool` directory and
write the canonical tables in this package.

BSD 3-Clause; see [LICENSE](LICENSE). Unicode data carries the notice in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
