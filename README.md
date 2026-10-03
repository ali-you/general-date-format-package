# General Date Format

Localized formatting and parsing for Gregorian `DateTime`, `PersianDateTime`
(Jalali), and `HijriDateTime`, with an API similar to `intl.DateFormat`.

Requires Flutter 3.32 or newer. Add the packages to your app:

```yaml
dependencies:
  general_date_format: ^1.0.1
  general_datetime: ^2.1.0
```

## Formatting

```dart
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

final persian = PersianDateTime(1403, 1, 1, 13, 5);
final hijri = HijriDateTime(1446, 9, 1);
final gregorian = DateTime(2025, 3, 1);

print(GeneralDateFormat('yyyy/MM/dd', 'fa').format(persian));
// ۱۴۰۳/۰۱/۰۱
print(GeneralDateFormat('MMMM G', 'en').format(hijri));
// Ramadan AH
print(GeneralDateFormat('yyyy-MM-dd MMMM', 'en').format(gregorian));
// 2025-03-01 March
```

The **date object's type chooses the calendar**. The locale chooses language,
field order and digits. Formatting does not convert calendars. Use
`PersianDateTime.fromDateTime` or `HijriDateTime.fromDateTime` for conversion.
Calendar calculations, supported year ranges and normalization are provided by
`general_datetime` and depend on the version you install.

Use named skeleton constructors for locale-aware ordering:

```dart
final format = GeneralDateFormat.yMMMMEEEEd('fa').add_Hm();
final text = format.format(PersianDateTime(1403, 1, 1, 13, 5));
```

Explicit patterns such as `yyyy-MM-dd HH:mm:ss` retain their field order.
Supported fields include `y`, `M`, `L`, `d`, `D`, `E`, `c`, `G`, `Q`, `H`, `h`,
`K`, `k`, `m`, `s`, `S`, and `a`. Quote literal text with single quotes; double
quotes inside the literal to emit a single quote: `'o''clock'`.

## Parsing

Pass a date instance to select the result's calendar. Its fields do not set
parsed values. `parse` permits overflow and trailing text; `parseStrict`
rejects invalid fields and trailing text. The default result uses local time.

```dart
final format = GeneralDateFormat('yyyy/MM/dd', 'fa');
final selector = PersianDateTime(1400);
final local = format.parseStrict('۱۴۰۳/۰۱/۰۱', selector);
final utc = format.parseStrict('۱۴۰۳/۰۱/۰۱', selector, true);
final alsoUtc = format.parseUtc('۱۴۰۳/۰۱/۰۱', selector);
final invalid = format.tryParseStrict('۱۴۰۳/۱۳/۰۱', selector); // null
```

Use `DateTime(2000)` for Gregorian parsing or `HijriDateTime(1440)` for Hijri
parsing. `parseLoose` also accepts case differences in names and flexible
whitespace. `tryParse`, `tryParseStrict`, `tryParseLoose`, and `tryParseUtc`
return `null` on invalid input.

Fixed-width compact patterns such as `yyyyMMddHHmmss` are supported. Two-digit
`yy` years select the century in the interval from 80 years before to 20 years
after the current date, using the result's calendar. Other year widths and
inputs with other than two digits are literal years. Tests can control this
window with `package:clock`.

Missing date fields default to the Gregorian epoch date represented in the
selected calendar. Fractional seconds retain millisecond precision: `S`, `SS`,
and `SSS` emit three digits; longer widths append zeros, like `intl`. Parsing
short fractions pads on the right and longer fractions truncates to milliseconds.

## Locales and digits

The default locale is `en_US`. Supported locale codes are available from
`GeneralDateFormat.allLocalesWithSymbols()`; region aliases fall back to their
language when necessary. The package includes 120 locales, and Hijri month and
era names are generated from Unicode CLDR 48. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Native digits are enabled by default where locale data supplies them. Parsing
accepts either ASCII or native digits for the selected locale. To format ASCII:

```dart
final format = GeneralDateFormat('yyyy-MM-dd', 'fa')..useNativeDigits = false;
```

## Limits and Flutter integration

- Supported calendars are Gregorian, Persian, and Hijri. Implementing
  `GeneralDateTimeInterface` alone does not register additional calendars.
- Time-zone patterns `z`, `Z`, `v` and their skeleton constructors throw
  `UnsupportedError`; UTC/local date construction is supported.
- Unclosed quoted patterns throw `FormatException`.
- This package formats strings; Flutter date-picker integration needs matching
  `MaterialLocalizations` and calendar delegates from `general_datetime`.

The [example](example/lib/main.dart) demonstrates formatting and strict UTC
parsing for all three calendars, with English, Persian and Arabic selection.

## Developing with a local calendar package

For development only, create an uncommitted `pubspec_overrides.yaml`:

```yaml
dependency_overrides:
  general_datetime:
    path: D:/StudioProjects/general_date
```

Run `flutter pub get`, `flutter analyze`, and `flutter test`. Remove the override
and resolve again to verify the hosted dependency before a release.

To regenerate Hijri data, run `python tool/generate_hijri_symbols.py`. It uses
pinned CLDR 48.0.0 data and caches downloaded source files in `.dart_tool/cldr-48`.

## License

BSD 3-Clause; see [LICENSE](LICENSE). Unicode data carries the notice in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
