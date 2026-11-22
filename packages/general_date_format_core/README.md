# General Date Format Core

![General Date Format Core banner](https://raw.githubusercontent.com/ali-you/general-date-format-package/v4.2.0/docs/general_date_format_core-banner.png)

Format and parse Persian (Jalali), Hebrew, Chinese, Amanta, and Umm al-Qura
(Hijri) dates in pure Dart. Locale data is bundled, and
[`general_datetime_core`](https://pub.dev/packages/general_datetime_core) supplies the calendar date types.

[API reference](https://pub.dev/documentation/general_date_format_core/latest/) ·
[Changelog](https://pub.dev/packages/general_date_format_core/changelog)

## Installation and quick start

The Amanta release uses formatter core 3.2.0 with chronology core 3.1.0. Add
them to a Dart application:

```yaml
dependencies:
  general_datetime_core: ^3.1.0
  general_date_format_core: ^3.2.0
```

Run `dart pub get`, then format a date and parse it back in UTC.

```dart
import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';

void main() {
  final date = PersianDateTime.utc(1403, 1, 1);
  final format = GeneralDateFormat('yyyy/MM/dd', 'fa');
  final text = format.format(date);
  final parsed = format.parseStrict(text, date, true);

  print(text); // ۱۴۰۳/۰۱/۰۱
  print(CalendarDateUtils.toGregorian(parsed).toIso8601String()); // 2024-03-20T00:00:00.000Z
}
```

## Locale data and Flutter integration

For Gregorian dates, add `intl` to your application and use `intl.DateFormat`
directly. You choose its locale data initialization and digit policy. Native
`DateTime` format/parse selectors (including `tryParse` APIs) throw
`UnsupportedError` with migration guidance. Before its first operation, a
formatter's `dateSymbols` exposes Persian names.

To control the rolling two-digit year window without a clock package, assign
`format.now = () => DateTime.utc(2025, 6, 15)`. Each parse reads this callback at
most once and only for ambiguous two-digit years.

For Flutter Material picker localizations, use
[`general_date_format`](https://pub.dev/packages/general_date_format). It re-exports both formatter
classes and uses the same calendar date types. Locale data loads lazily on
first use.

The public core library also exports `resolveLocale` and `verifiedLocale` for
adapters that need the formatter's bundled-data locale fallback policy.

## Chinese calendar

Chinese dates use related Gregorian years 1901-2099 and ordinal numeric months.
CLDR 48 names distinguish the twelve traditional months and their leap variants
in every bundled locale. Parsing resolves named identities against the parsed
year, including when the name precedes the year. Chinese era and quarter
patterns are unsupported; `y` is the related year, not a cyclic year.
See the [Chinese guide](https://github.com/ali-you/general-date-format-package/blob/main/docs/chinese-formatting.md).

## Amanta calendar

`AmantaDateFormat` formats traditional Amanta dates in English or Hindi and
parses compact civil dates. Use it with `AmantaDate` from the chronology
core. See the [Amanta calendar guide](https://github.com/ali-you/general-date-package/blob/v5.1.0/docs/amanta-calendar.md)
for leap months and repeated tithis.

```dart
final date = AmantaDate.fromGregorian(2023, 7, 22);
final format = AmantaDateFormat('en');
print(format.formatTraditional(date)); // Adhika Shravana 2080, tithi 4 (second)
final roundTrip = format.parseCompact(format.formatCompact(date));
```

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
See the [Hebrew guide](https://github.com/ali-you/general-date-format-package/blob/main/docs/hebrew-formatting.md) for full details.

## Formatting and parsing behavior

The date object's type selects the calendar. The locale controls language,
patterns, and digits. See the [pattern reference](https://pub.dev/packages/general_date_format#pattern-reference)
and [parsing contracts](https://pub.dev/packages/general_date_format#parsing-contracts) for
pattern fields and strict, loose, and permissive parsing. Named timezone patterns `z`, `Z`, and `v` remain
unsupported. Use `SSSSSS` to round-trip microseconds, including native digits.
One-to-three `S` characters retain the historical minimum three-digit output;
widths four and five truncate output, while widths beyond six pad zeros.
Strict/loose parsing rejects nonzero digits beyond microsecond precision.
Use the [chronology serialization guide](https://github.com/ali-you/general-date-package/blob/main/docs/serialization.md)
to choose a storage representation for instants and civil dates.

## Development

The [CLI example](https://github.com/ali-you/general-date-format-package/blob/main/packages/general_date_format_core/example/cli.dart)
demonstrates formatting and parsing in a Dart application. Run these commands
from the package directory in a repository checkout.

```powershell
dart pub get
dart analyze
dart test
dart run example/cli.dart
dart compile exe example/cli.dart -o .dart_tool/calendar_cli.exe
```

Development and CI select the local chronology core with `tool/resolve_calendar_pair.py`.
From the formatter repository root, run:

```console
python tool/resolve_calendar_pair.py --chronology ../general_date --formatter .
```

Then resolve this core's dependencies and run the checks above. Verify compatible
hosted dependencies without development overrides before releasing consumers.

Persian, Hebrew, and Umm al-Qura names use generated CLDR 48 inputs with a checksum lock,
attribution, and documented compatibility exceptions in the parent `tool`
directory. Shared skeleton patterns remain a compatibility policy because the
skeleton API selects a pattern before the date object's calendar is known.

The parent Flutter suites verify this same formatter and its Material
integration. Dart tests additionally verify a Flutter-free resolved dependency
graph, UTC calendar round trips, native digits, script fallback, and strict
parser rejection. Locale generators remain in the parent `tool` directory and
write the canonical tables in this package.

## Migration

When migrating from 1.x, use application-owned `intl.DateFormat` for Gregorian
dates, remove calls to the removed locale initialization hook, and use the
formatter's `now` callback for deterministic two-digit-year parsing. The new
chronology `CalendarId.hebrew` case requires exhaustive-switch updates.
See [release migration](https://github.com/ali-you/general-date-format-package/blob/main/docs/release-migration.md).

## License

BSD 3-Clause; see [LICENSE](LICENSE). Unicode data carries the notice in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
