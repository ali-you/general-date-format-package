# General Date Format

Localized formatting and parsing for Gregorian `DateTime`, `PersianDateTime`
(Jalali), and `HijriDateTime`, with an API similar to `intl.DateFormat`.

Requires Flutter 3.32 or newer. Add the packages to your app:

```yaml
dependencies:
  general_date_format: ^2.0.0
  general_datetime: ^3.0.0
```

These versions are being prepared in the source repositories. Until they are
published, use both local checkouts as described below. The formatter requires
the corrected datetime core; general_datetime 2.1.0 is no longer supported.

## Formatting

### Dart servers and command-line applications

Use [`general_date_format_core`](packages/general_date_format_core/README.md)
and `general_datetime_core` for formatting and chronology without Flutter.
Their version 1.0.0 releases are prepared locally; the linked README provides
path dependencies, overrides, and standalone Dart test/CLI commands.

This Flutter package retains its existing public formatter and localization
imports. It re-exports the Dart core's exact `GeneralDateFormat` type and adds
the Material adapters. Date classes are likewise shared through
`general_datetime_core`, preserving runtime calendar selection across imports.

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

Persian weekday names, quarters, AM/PM markers, time formats and week metadata
use the same `intl` locale source as Gregorian and Hijri. Afrikaans Persian
month and era names are generated from pinned Unicode CLDR 48. For provenance,
regeneration commands, and the `en_MY`/`en_ISO` conventions, see
[Locale data sources](tool/README.md). Existing Persian abbreviated weekday and
quarter spellings may change to match the shared locale data.

`dateSymbols` exposes immutable fields, lists, and maps for the formatter's most
recently selected calendar (Gregorian before its first format/parse call).
Assignments to symbol fields are no longer supported. To adapt labels for your
own UI, use `dateSymbols.serializeToMap()`: it returns a detached snapshot,
including nested collections. Editing that snapshot does not customize the
formatter or affect other instances.

Use named skeleton constructors for locale-aware ordering:

```dart
final format = GeneralDateFormat.yMMMMEEEEd('fa').add_Hm();
final text = format.format(PersianDateTime(1403, 1, 1, 13, 5));
```

Explicit patterns such as `yyyy-MM-dd HH:mm:ss` retain their field order.
Supported fields include `y`, `M`, `L`, `d`, `D`, `E`, `c`, `G`, `Q`, `H`, `h`,
`K`, `k`, `m`, `s`, `S`, and `a`. Quote literal text with single quotes; double
quotes inside the literal to emit a single quote: `'o''clock'`.

### Editing calendar dates before formatting

For values held in a `DateTime` variable (including picker callbacks), use the
core package's `CalendarDateUtils.copyWith(date, day: 2)` or
`CalendarDateUtils.dateOnly(date)`. They retain the Persian/Hijri calendar and
UTC/local mode. Import `package:general_datetime/general_datetime.dart` for
these helpers.

Dart's `.copyWith` extension on a `DateTime`-typed variable and Flutter's
`DateUtils` helpers reconstruct Gregorian dates from custom calendar fields.
Use `CalendarDateUtils.toGregorian(date)` before calling external Gregorian
helpers, then explicitly convert back to the desired calendar if needed.

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

Strict and loose parsing validate every supplied field, including repeated
fields. Weekday names/numbers, quarters, and ordinal days (`D`) must agree with
the resulting calendar date and any explicit month/day. Matching repetitions
are accepted; invalid earlier values cannot be hidden by later values.
Ambiguous names (such as the English weekday initial `T`) match any of their
possible days. A weekday constrains the date; it does not search for another
date when year/month/day are omitted. A quarter supplies its first month and
day 1 only when those fields are missing. Ordinary `parse` retains permissive
date-field precedence and overflow normalization.

`h` (1–12) and `K` (0–11) use AM/PM to resolve the hour. `H` (0–23) and
`k` (1–24, with 24 meaning midnight) already specify a 24-hour value: an AM/PM
marker does not shift it, and strict/loose parsing rejects a contradictory
marker. For example, `HH:mm a` accepts `13:00 PM` and rejects `01:00 PM`.

Numeric `c` and `cc` both emit a single locale-relative weekday number, 1–7,
using the selected calendar's locale week start. For Gregorian Monday,
`en_US` emits `2` and `en_GB` emits `1`. Parsing validates both the range and
agreement with the date. Use `ccc`, `cccc`, or `ccccc` for abbreviated, full,
or narrow standalone weekday names.

Fixed-width compact patterns such as `yyyyMMddHHmmss` are supported. Two-digit
`yy` years select the century in the interval from 80 years before to 20 years
after the current date, using the result's calendar. Other year widths and
inputs with other than two digits are literal years. Tests can control this
window with `package:clock`.

Missing date fields default to the Gregorian epoch date represented in the
selected calendar, except for the quarter defaults described above.
Fractional seconds retain millisecond precision: `S`, `SS`,
and `SSS` emit three digits; longer widths append zeros, like `intl`. Parsing
short fractions pads on the right and longer fractions truncates to milliseconds.

## Locales and digits

The default locale is `en_US`. Supported locale codes are available from
`GeneralDateFormat.allLocalesWithSymbols()`. Locale names accept hyphens or
underscores and normalize language/script/region casing. Resolution checks the
exact locale, then language plus script, compatible regional data, and finally
the language, including legacy language-code aliases at each step. For example,
`sr-Latn-RS` uses `sr_Latn`, and `en-Latn-GB` retains `en_GB` patterns.

The bundled Chinese tables use region keys: `zh-Hant-HK` and `zh-Hant-MO` prefer
`zh_HK`; other `zh-Hant` requests prefer `zh_TW`. Either Traditional table can
back up the other. `zh-Hans` uses `zh_CN`, including when the supplied region
would otherwise select Traditional Chinese. An exact supported key takes
precedence. Unsupported scripts ultimately use the language's available data;
the resolver does not generate translations or implement full CLDR matching.
Variants and extensions are tried as exact keys, then ignored for fallback;
Unicode extensions do not select a different calendar or numbering system.
`C` remains an alias for `en_ISO`. Unknown languages without supported fallback
throw `ArgumentError`.

The package includes 120 locales, and Hijri month and
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
- Flutter date pickers need matching Material localizations and the calendar
  delegates from `general_datetime`; see the integration below.

The [example](example/lib/main.dart) demonstrates formatting and strict UTC
parsing for all three calendars, with English, Persian and Arabic selection,
plus Persian and Hijri date pickers.

The example samples one native clock when its screen is created and derives
all three displayed calendars from that instant. Locale changes and picker
rebuilds retain the snapshot. Tests inject a fixed clock with
`MyApp(now: () => DateTime.utc(2024, 3, 20, 12, 34))`; the default app uses local
`DateTime.now`. Recreating the screen samples the clock again.

## Material calendar localization delegates

`PersianCalendarMaterialLocalizations.delegate` and
`HijriCalendarMaterialLocalizations.delegate` provide calendar-aware date
formatting and strict parsing, translated Material labels, localized numbers,
weekday names and locale-specific first-day-of-week conventions. They support
locales available in both this package and Flutter's Material translations.
Import them from `general_date_format.dart` or `localizations.dart`.

The delegates use the same locale resolution policy for date and number data,
while Flutter selects translated labels from the requested locale. Represent
scripts with `Locale.fromSubtags`, for example
`Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn', countryCode: 'RS')`.
`Locale('sr', 'Latn')` places the script in the country field and is incorrect.

For an app using one calendar, place its delegate **before** Flutter's global
delegates:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/delegates.dart';
import 'package:general_datetime/general_datetime.dart';

MaterialApp(
  locale: const Locale('fa'),
  supportedLocales: const [Locale('en'), Locale('fa'), Locale('ar')],
  localizationsDelegates: const [
    PersianCalendarMaterialLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: Scaffold(body: CalendarDatePicker(
    initialDate: PersianDateTime(1403, 1, 1),
    firstDate: PersianDateTime(1400),
    lastDate: PersianDateTime(1410, 12, 29),
    calendarDelegate: const PersianCalendarDelegate(),
    onDateChanged: (date) {},
  )),
);
```

Add `flutter_localizations: {sdk: flutter}` to your app's dependencies when
importing Flutter's global delegates directly. Supply `PersianDateTime` or
`HijriDateTime` values to the corresponding picker. Gregorian instants can be
converted with the calendar's `fromDateTime` factory before opening the picker.

The core calendar delegates enforce matching runtime types for all date inputs,
comparisons, ranges, and non-null parser results. Incompatible values throw
`ArgumentError`; invalid text still parses to null. Use the corresponding calendar
localization delegate below, and explicitly convert Gregorian/other-calendar
instants with `fromDateTime` before passing them to the arithmetic delegate.

For an app that opens several calendar types, keep global delegates in the app
and override Material localizations for each dialog:

```dart
final selected = await showDatePicker(
  context: context,
  initialDate: HijriDateTime(1446, 9, 1),
  firstDate: HijriDateTime(1440),
  lastDate: HijriDateTime(1450, 12, 29),
  calendarDelegate: const HijriCalendarDelegate(),
  builder: (context, child) => Localizations.override(
    context: context,
    locale: const Locale('ar'),
    delegates: const [HijriCalendarMaterialLocalizations.delegate],
    child: child!,
  ),
);
```

Only the first delegate for `MaterialLocalizations` is loaded in a localization
scope; install one calendar delegate per picker. For ASCII dates and numeric
labels, use `const PersianCalendarMaterialLocalizationsDelegate(useNativeDigits:
false)` or the corresponding Hijri delegate. These delegates use locale-specific
compact date patterns, rather than the fixed English `dd/mm/yyyy` pattern of
`general_datetime`'s `Default...` localizations. Invalid compact input returns
`null`; parsed values use local time and retain the selected calendar type.

## Developing with a local calendar package

Keep the two checkouts beside each other as `general_date` and
`general_date_format`. Copy the tracked override templates for the package and
example before resolving dependencies (PowerShell):

```powershell
Copy-Item pubspec_overrides.yaml.example pubspec_overrides.yaml
Copy-Item example/pubspec_overrides.yaml.example example/pubspec_overrides.yaml
flutter pub get
Push-Location example
flutter pub get
Pop-Location
```

The ignored overrides resolve both Flutter packages and both extracted Dart
cores through relative paths. Dependency manifests retain publishable hosted
version constraints. Run `flutter analyze` and `flutter test` against this pair.
For core development, also copy the template inside
`packages/general_date_format_core` and run its `dart pub get`, `dart analyze`,
and `dart test` there. An external application must provide all needed overrides
itself; dependency overrides are not inherited from these packages.

Publish `general_datetime_core` 1.0.0 first. Then publish
`general_date_format_core` 1.0.0 and `general_datetime` 3.0.0, both of which depend
on it. Publish `general_date_format` 2.0.0 after verifying those hosted releases
without local overrides. Until publication, resolution requires the documented
overrides and must not fall back to the defective general_datetime 2.1.0.

See [TESTING.md](TESTING.md) for the comprehensive suites, the fast
`flutter test --tags critical` command, coverage, and timezone CI matrix.

To regenerate Hijri data, run `python tool/generate_hijri_symbols.py`. It uses
pinned CLDR 48.0.0 data and caches downloaded source files in `.dart_tool/cldr-48`.

## License

BSD 3-Clause; see [LICENSE](LICENSE). Unicode data carries the notice in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Fractional seconds and calendar data maintenance

Fraction fields retain microseconds through six digits. Existing S/SS/SSS
output remains at least three digits; widths 4–6 truncate to the requested
fractional precision, and larger widths append exact zeros. Native digit
translation applies to the entire fraction. Strict/loose parsing rejects
nonzero precision beyond six digits and accepts exact trailing zeros; ordinary
parsing truncates excess precision. Use `CalendarInstant` for storage rather
than a display pattern.

Persian and Hijri month/era names are now generated from pinned CLDR 48 with
verified input hashes. Some Persian abbreviations/era spellings change;
compatibility date order, digit defaults and en_ISO exceptions remain explicit.
See [locale generation and measurements](tool/README.md) for reproduction,
provenance, the retained shared-skeleton policy and release benchmark results.

Flutter compatibility coverage exercises calendar date parsing/formatting,
translated labels and number/time formatting against minimum/current SDK jobs.
The integration workflow pins its chronology peer by SHA in
`.github/calendar_pair.json`; update that pin when adopting a new peer revision.
