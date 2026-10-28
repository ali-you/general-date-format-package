# General Date Format Core

Pure Dart localized formatting and strict/loose parsing for Persian, Hebrew, Chinese,
and Umm al-Qura dates. Its only runtime dependency is our `general_datetime_core`.
Locale data is bundled; there is no `intl`, `clock` or Flutter dependency.

For Gregorian dates, add `intl` to your application and use `intl.DateFormat`
directly. You choose its locale data initialization and digit policy. Native
`DateTime` format/parse selectors (including `tryParse` APIs) throw
`UnsupportedError` with migration guidance. Before its first operation, a
formatter's `dateSymbols` exposes Persian names.

To control the rolling two-digit year window without a clock package, assign
`format.now = () => DateTime.utc(2025, 6, 15)`. Each parse reads this callback at
most once and only for ambiguous two-digit years.

The prepared Flutter `general_date_format` 3.0.0 package re-exports this 2.0.0 core and
adds its existing Material localization delegates. Both imports expose the
same `GeneralDateFormat` type and consume the same calendar date classes.

Formatting, parsing, helpers, and symbol data live only in this core package.
The Flutter wrapper's `lib/src` contains Material localization adapters that
reference the core directly. Locale data loads lazily, so no initialization
hook is needed.

The public core library also exports `resolveLocale` and `verifiedLocale` for
adapters that need the formatter's bundled-data locale fallback policy.

Chinese formatting includes localized CLDR 48 regular/leap month names and
strict parsing. Numeric month fields are chronological ordinals (1–12/13);
`y` is the Gregorian year containing lunar New Year. Named patterns show the
traditional month identity. Era and quarter patterns reject Chinese dates.
Install `ChineseCalendarMaterialLocalizations.delegate` with
`ChineseCalendarDelegate` for translated Material pickers.

## Installation and development

The prepared release uses version 2.0.0 of both cores. After publication, add
them to a Dart application:

```yaml
dependencies:
  general_datetime_core: ^2.0.0
  general_date_format_core: ^2.0.0
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

Publication of the prepared 2.0.0 cores is a separate step. Development
and CI select the local chronology core with `tool/resolve_calendar_pair.py`.
From the formatter repository root, run:

```console
python tool/resolve_calendar_pair.py --chronology ../general_date --formatter .
```

Then resolve this core's dependencies and run the checks above. Verify compatible
hosted dependencies without development overrides before releasing consumers.

When migrating from 1.x, use application-owned `intl.DateFormat` for Gregorian
dates, remove calls to the removed locale initialization hook, and use the
formatter's `now` callback for deterministic two-digit-year parsing. The new
chronology `CalendarId.hebrew` case requires exhaustive-switch updates.
See [release migration](../../docs/release-migration.md).

## Hebrew calendar

```dart
final date = HebrewDateTime.utc(5784, 7, 10);
final format = GeneralDateFormat('d MMMM yyyy G', 'he');
final text = format.format(date);
final parsed = format.parseStrict(text, HebrewDateTime(5785), true);
```

All bundled locales include Hebrew month and era names from CLDR 48. The input
type selects the calendar. Numeric fields retain stable month slots 1–13:
Adar I=6 (leap years only), Adar/Adar II=7, Elul=13. Parsing validates names
against the input year, independently of the selector's leap status. Public
month symbol arrays contain the thirteen base slots; `format` selects the
Adar II spelling for leap years. Quarter `Q` patterns are unsupported for Hebrew.
See the [Hebrew guide](../../docs/hebrew-formatting.md) for full details.

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

Persian, Hebrew, and Umm al-Qura names use generated CLDR 48 inputs with a checksum lock,
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
