# General Date Format

Localized formatting and parsing for Persian (Jalali) and Hijri (Umm al-Qura)
dates, plus translated Flutter Material date-picker localizations. The date
object selects the calendar; the locale selects language, date order, and digits.

[![pub.dev](https://img.shields.io/pub/v/general_date_format.svg)](https://pub.dev/packages/general_date_format)
[![Formatter CI](https://github.com/ali-you/general-date-format-package/actions/workflows/flutter.yml/badge.svg)](https://github.com/ali-you/general-date-format-package/actions/workflows/flutter.yml)

Gregorian formatting/parsing belongs to the consuming application through
`intl.DateFormat`. Calendar conversion and arithmetic belong to
`general_datetime` / `general_datetime_core`.

## Contents

- [Packages and installation](#packages-and-installation)
- [Quick start](#quick-start)
- [Skeletons and explicit patterns](#skeletons-and-explicit-patterns)
- [Pattern reference](#pattern-reference)
- [Parsing contracts](#parsing-contracts)
- [Fractional seconds](#fractional-seconds)
- [Locales, digits, and symbols](#locales-digits-and-symbols)
- [Flutter Material integration](#flutter-material-integration)
- [Conversion, field editing, and storage](#conversion-field-editing-and-storage)
- [Limits and error behavior](#limits-and-error-behavior)
- [Examples and testing](#examples-and-testing)
- [Locale maintenance and release checks](#locale-maintenance-and-release-checks)

## Packages and installation

| Package | Use | Runtime dependencies |
| --- | --- | --- |
| `general_date_format` | Formatter re-export and Flutter Material localization adapters | Formatting core, Flutter/localizations, datetime wrapper |
| [`general_date_format_core`](packages/general_date_format_core/README.md) | Formatting/parsing for Dart servers and CLIs | `general_datetime_core` only |
| `general_datetime` / `general_datetime_core` | Calendar chronology, conversion, civil dates, and JSON storage | Flutter for the wrapper only |

The Flutter wrapper and pure Dart formatter expose the exact same
`GeneralDateFormat` class. Bundled locale data requires no formatter
initialization call, network fetch, `intl` locale registration, or `clock`
package. The Flutter adapter uses the public `MaterialLocalizations` interface
and has no direct `intl` dependency or imports. Flutter's
`flutter_localizations` still depends on `intl` transitively.

The checked-in manifests target `general_date_format` **2.0.0**,
`general_datetime` **3.0.0**, and both Dart cores **1.0.0**. Flutter wrappers
require Dart `>=3.4.0 <4.0.0` and Flutter `>=3.32.0`; the cores need only Dart
`>=3.4.0 <4.0.0`.

When matching releases are available from your package source:

```yaml
dependencies:
  general_date_format: ^2.0.0
  general_datetime: ^3.0.0
```

## Quick start

```dart
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  final native = DateTime.utc(2024, 3, 20, 13, 5);
  final persian = PersianDateTime.fromDateTime(native);
  final hijri = HijriDateTime.fromDateTime(native);

  print(GeneralDateFormat('yyyy/MM/dd', 'fa').format(persian));
  // ۱۴۰۳/۰۱/۰۱
  print(GeneralDateFormat('yyyy-MM-dd MMMM G', 'en').format(hijri));
  // 1445-09-10 Ramadan AH

  final format = GeneralDateFormat('yyyy/MM/dd', 'fa');
  final parsed = format.parseStrict('۱۴۰۳/۰۱/۰۱', PersianDateTime(1400), true);
  print(parsed.isUtc); // true
  print(CalendarDateUtils.toGregorian(parsed).toIso8601String());
  // 2024-03-20T00:00:00.000Z
}
```

`format` accepts `DateTime` statically, but the value must be a
`PersianDateTime` or `HijriDateTime` at runtime. A native Gregorian value throws
`UnsupportedError`; it is not automatically converted. One formatter can be
used for both supported calendars, selecting the corresponding symbols for
each operation.

For Gregorian output, add `intl` as a direct application dependency:

```dart
import 'package:intl/intl.dart' as intl;

final text = intl.DateFormat('yyyy-MM-dd', 'en').format(DateTime.utc(2024, 3, 20));
// 2024-03-20
```

For other Gregorian locales, the application must initialize `intl` data or
use Flutter's localization delegates. This calendar formatter does not perform
that initialization for general Gregorian application formatting.

## Skeletons and explicit patterns

Use a named skeleton for locale-specific order and time conventions:

```dart
final label = GeneralDateFormat.yMMMMEEEEd('fa').add_Hm();
final text = label.format(PersianDateTime(1403, 1, 1, 13, 5));
```

Useful skeletons include:

| Purpose | Constructors |
| --- | --- |
| Numeric dates | `yMd`, `yM`, `Md`, `MEd`, `yMEd` |
| Abbreviated month names | `yMMMd`, `yMMMEd`, `MMM`, `MMMd`, `MMMEd` |
| Full month names | `yMMMMd`, `yMMMMEEEEd`, `MMMM`, `MMMMd`, `MMMMEEEEd` |
| Standalone month/weekday | `LLL`, `LLLL`, `E`, `EEEE`, `EEEEE` |
| Quarter/year | `QQQ`, `QQQQ`, `yQQQ`, `yQQQQ`, `y` |
| Explicit 24-hour time | `H`, `Hm`, `Hms` |
| Locale-preferred hour cycle | `j`, `jm`, `jms` |
| Smaller fields | `d`, `M`, `m`, `ms`, `s` |

For example, `GeneralDateFormat.yMd('en_US')` and
`GeneralDateFormat('yMd', 'en_US')` select the same bundled pattern.
An input matching a known skeleton resolves to its locale pattern; other
inputs are treated as explicit patterns.

Use explicit patterns when field order must stay fixed:

```dart
final fixed = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', 'en');
final compact = GeneralDateFormat('yyyyMMddHHmmss', 'en');
final quoted = GeneralDateFormat("yyyy-MM-dd 'at' HH:mm 'o''clock'", 'en');
```

Adjacent numeric fields are bounded by their pattern widths. Quoted literals
use single quotes; double a quote inside a literal to emit one quote.
Quote alphabetic literal text so it is not interpreted as a field.

`add_Hm()`, other `add_*` methods, and `addPattern(pattern, separator)` append
to the existing pattern and return the same formatter. The default separator
is a space. `pattern` is a read-only, nullable getter, and `locale` is the
resolved locale. With no pattern supplied, first use resolves the locale's
`yMMMMd` plus `jms` patterns.

Skeleton date/time patterns are a shared compatibility policy chosen before a
calendar date is supplied. They are not a complete implementation of CLDR's
calendar-specific pattern selection. Month and era names are calendar-specific.

## Pattern reference

| Field | Meaning and supported forms |
| --- | --- |
| `y` | Calendar year; numeric widths pad, `yy` formats the last two digits |
| `M` | Month: `M`/`MM` numeric, `MMM` abbreviated, `MMMM` full, `MMMMM` narrow |
| `L` | Same widths as `M`, using standalone month names |
| `d` | Day of month; `dd` pads to two digits |
| `D` | Ordinal day within the selected calendar year |
| `E` | Weekday names: `E`/`EEE` abbreviated, `EEEE` full, `EEEEE` narrow |
| `c` | Locale-relative weekday: `c` and `cc` emit one number 1–7; `ccc`/`cccc`/`ccccc` use standalone names |
| `G` | Calendar era label; `GGGG` uses the full era name |
| `Q` | Quarter: `Q`/`QQ` numeric, `QQQ` abbreviated, `QQQQ` full |
| `H` | Hour 0–23 |
| `h` | Hour 1–12, resolved with AM/PM |
| `K` | Hour 0–11, resolved with AM/PM |
| `k` | Hour 1–24; 24 represents midnight on that date |
| `m`, `s` | Minute and second, 0–59 |
| `S` | Fractional seconds; see the precision rules below |
| `a` | Locale AM/PM marker |
| `'text'`, `''` | Literal text and escaped single quote |

For `c`, numbering follows the locale's week start. A Monday instant emits
`2` in `en_US` and `1` in `en_GB`; `cc` remains unpadded. This differs from
Dart's fixed Monday=1 `DateTime.weekday` convention.

`j` is a skeleton request for a locale-preferred hour cycle, not an explicit
hour field. Timezone fields `z`, `Z`, `v` and the `jmv`, `jmz`, `jv`, `jz`
skeletons are unsupported. Other ICU field families, such as week-of-year,
are not implemented by this pattern engine.

## Parsing contracts

The selector chooses the result calendar, not the parsed fields or timezone.
The returned value is statically `DateTime` and has the matching calendar
runtime type. The optional third positional `utc` argument defaults to `false`,
even if the selector itself is UTC.

```dart
final format = GeneralDateFormat('yyyy/MM/dd', 'fa');
final selector = PersianDateTime(1400);
final local = format.parseStrict('۱۴۰۳/۰۱/۰۱', selector);
final utc = format.parseStrict('۱۴۰۳/۰۱/۰۱', selector, true);
final invalid = format.tryParseStrict('۱۴۰۳/۱۳/۰۱', selector); // null
```

Use a `HijriDateTime` selector for Umm al-Qura. For Gregorian parsing, use
`intl.DateFormat` directly.

| API | Date/field validation | Text behavior | Failure |
| --- | --- | --- | --- |
| `parse(text, selector, [utc])` | Permits constructor normalization and permissive field precedence | Can leave trailing text | `FormatException` |
| `parseStrict(text, selector, [utc])` | Validates ranges, repeated fields, and date constraints | Entire input must match; trailing whitespace is rejected | `FormatException` |
| `parseLoose(text, selector, [utc])` | Strict date/field constraints | Also accepts case differences and flexible whitespace/delimiters for recognized names | `FormatException` |
| `parseUtc(text, selector)` / `parseUTC(...)` | Same permissive rules as `parse` | Constructs UTC | `FormatException` |
| `tryParse`, `tryParseStrict`, `tryParseLoose`, `tryParseUtc` | Same contract as their throwing counterpart | Same counterpart's text rules | `null` for `FormatException` |

Use `parseStrict(..., true)` for strict UTC input; `parseUtc` is not strict.
Loose parsing does not translate arbitrary month names or allow arbitrary
trailing text. Nullable methods do not swallow `UnsupportedError` for an
unsupported calendar or timezone pattern.

### Defaults and date constraints

Omitted date fields start from Gregorian 1970-01-01 expressed in the selected
calendar, not from the selector's fields or today's date. Omitted clock fields
start at zero. A supplied quarter provides its first month and day 1 only when
those fields are absent.

Strict/loose parsing checks weekday, locale weekday numbers, quarter, ordinal
day, and month/day agreement with the resulting date. Each repeated field is
validated: a later valid occurrence cannot hide an earlier invalid one.
Consistent repetitions are accepted. A weekday constrains the resulting date;
it does not search for another date when year/month/day are missing.

Abbreviated/narrow labels can be ambiguous. For example, a weekday initial can
match several days. Strict parsing accepts a compatible candidate; numeric or
unique full names are preferable when an exact round trip is required.

### Hour cycles and AM/PM

`h` and `K` use AM/PM to resolve the hour. `H` and `k` already specify a 24-hour
value; a day-period marker does not shift it. Strict/loose parsing rejects a
contradictory marker: `HH:mm a` accepts `13:00 PM` and rejects `01:00 PM`.

### Two-digit years and eras

With `yy` and exactly two unsigned input digits, the result is selected from
the rolling century window ending 20 calendar years after the reference date
(and starting approximately 80 years before). Other widths, signed years, or
inputs with other than two digits use literal years.

Control the reference instant per formatter for deterministic parsing:

```dart
final format = GeneralDateFormat('yy-MM-dd', 'en')
  ..now = () => DateTime.utc(2025, 6, 15);
```

The callback defaults to native `DateTime.now`, is sampled at most once per
parse, and is used only for ambiguous two-digit years. The window uses the
selected calendar and requested UTC/local mode; range bounds still apply.

Persian signed years, including zero, are supported. `G` recognizes era labels
and validates repeated era tokens, but does not convert a positive numeric year
into a negative year. Use signed year input when representing negative years.

## Fractional seconds

The formatter retains microseconds through six digits, with the existing
minimum three-digit output for `S`, `SS`, and `SSS`:

| Pattern | Output for fraction `.123456` |
| --- | --- |
| `S`, `SS`, `SSS` | `123` |
| `SSSS` | `1234` |
| `SSSSS` | `12345` |
| `SSSSSS` | `123456` |
| `SSSSSSSSS` | `123456000` |

Widths four/five truncate lower precision; widths beyond six append exact
zeros. Parsing short fractions right-pads to six digits: `1` means 100000
microseconds, and `01` means 10000. Strict/loose parsing accepts excess trailing
zeros but rejects nonzero precision beyond six digits. Permissive `parse`
truncates excess precision. Native-digit translation applies to the entire
fraction. Three-digit display round trips deliberately lose microseconds;
use `SSSSSS` when exact fractional display/parsing is required.

## Locales, digits, and symbols

The default locale is `en_US`. Bundled data covers 120 locale keys:

```dart
final locales = GeneralDateFormat.allLocalesWithSymbols();
final format = GeneralDateFormat.yMd('sr-Latn-RS');
print(format.locale); // sr_Latn
```

`localeExists(key)` checks an exact bundled key. The constructor also resolves
aliases/fallbacks: it accepts hyphens or underscores, normalizes language/script/
region casing, tries exact data, language plus script, compatible regional data,
and then language, including legacy language-code aliases.

Examples:

| Request | Resolved data |
| --- | --- |
| `sr-Latn-RS` | `sr_Latn` |
| `en-Latn-GB` | `en_GB` |
| `zh-Hant-HK`, `zh-Hant-MO` | `zh_HK`, with `zh_TW` backup |
| Other `zh-Hant` requests | `zh_TW`, with `zh_HK` backup |
| `zh-Hans` | `zh_CN`, unless an exact supported key already matched |
| `C` | `en_ISO` |

An exact supported key takes precedence. Unknown languages with no supported
fallback throw `ArgumentError`. Variants/extensions can match exact keys but
otherwise are ignored; Unicode extensions do not select a calendar or numbering
system. This is a bundled-data fallback policy, not full CLDR locale matching.

### Native and ASCII digits

Native digits are enabled by default when locale data supplies them. To format
ASCII for one instance:

```dart
final format = GeneralDateFormat('yyyy-MM-dd', 'fa')..useNativeDigits = false;
print(format.format(PersianDateTime(1403, 1, 1))); // 1403-01-01
final parsed = format.parseStrict('۱۴۰۳-۰۱-۰۱', PersianDateTime(1400), true);
// Parsing still accepts the selected locale's native digits and ASCII.
```

`usesNativeDigits` and `usesAsciiDigits` report the effective output policy.
`GeneralDateFormat.useNativeDigitsByDefaultFor(resolvedLocale, value)` controls
the default; set it before creating/using formatters. An instance's explicit
`useNativeDigits` setting takes precedence. Parsing accepts ASCII and the
selected locale's digit set independently of the output preference.

### Symbol data and state

`dateSymbols` returns immutable fields, lists, and maps for the most recently
selected calendar, with Persian symbols exposed before the first operation.
`serializeToMap()` returns a detached snapshot, including nested collections,
for building your own labels. Editing it does not customize the formatter.
Calendar selection changes during successful dispatch; applications should not
treat `dateSymbols` as a separate calendar registry.

Week metadata indices in the symbols use Monday=0, distinct from
`DateTime.weekday`. Calendar month/era names are generated from pinned CLDR;
weekday, AM/PM, quarter, and shared time metadata are bundled separately.

## Flutter Material integration

The wrapper exports these APIs through `general_date_format.dart` and
`localizations.dart`:

| Calendar | Material localization | Datetime arithmetic delegate |
| --- | --- | --- |
| Persian | `PersianCalendarMaterialLocalizations.delegate` | `PersianCalendarDelegate` |
| Umm al-Qura | `HijriCalendarMaterialLocalizations.delegate` | `HijriCalendarDelegate` |

Supported picker locales are the intersection of the formatter's resolved data
and Flutter's global Material translations. The adapters provide translated
labels/plural rules, date formatting, strict compact parsing, locale week
starts, and consistent date/day/year/time digits.

Add `flutter_localizations: {sdk: flutter}` as a direct dependency when importing
Flutter's global delegates in your application. Install the calendar's Material
delegate before Flutter's global Material delegate.

### Complete Persian application

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';
import 'package:general_datetime/delegates.dart';

void main() => runApp(MaterialApp(
  locale: const Locale('fa'),
  supportedLocales: const [Locale('en'), Locale('fa'), Locale('ar')],
  localizationsDelegates: const [
    PersianCalendarMaterialLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: Scaffold(
    body: CalendarDatePicker(
      initialDate: PersianDateTime(1403, 1, 1),
      firstDate: PersianDateTime(1400),
      lastDate: PersianDateTime(1410, 12, 29),
      calendarDelegate: const PersianCalendarDelegate(),
      onDateChanged: (DateTime selected) {
        debugPrint(CalendarDate.fromDateTime(selected).toString());
      },
    ),
  ),
));
```

For Hijri, replace the date values and both calendar delegates. For ASCII
numeric labels, use `const PersianCalendarMaterialLocalizationsDelegate(
useNativeDigits: false)` or its Hijri equivalent. `shouldReload` reacts to a
changed digit preference. `PersianCalendarMaterialLocalizations.load(locale,
useNativeDigits: ...)` and its Hijri equivalent are available for explicit loads.

These adapters use locale-specific compact patterns. The datetime package's
`Default...` localizations instead provide English-only legacy `dd/mm/yyyy`
input. Arithmetic delegates forward formatting/parsing to the current Material
localization; choosing the arithmetic delegate alone does not choose its labels.

### Multiple calendars and dialog scopes

Keep global delegates at application level and override Material localizations
for each calendar dialog. The following function assumes a mounted context
below that application:

```dart
Future<DateTime?> pickHijri(BuildContext context) {
  return showDatePicker(
    context: context,
    initialDate: HijriDateTime(1445, 9, 10),
    firstDate: HijriDateTime(1440),
    lastDate: HijriDateTime(1460, 12, 29),
    calendarDelegate: const HijriCalendarDelegate(),
    builder: (context, child) => Localizations.override(
      context: context,
      delegates: const [HijriCalendarMaterialLocalizations.delegate],
      child: child!,
    ),
  );
}
```

Flutter uses one Material localization per scope; competing delegates in one
scope do not provide simultaneous calendars. Both arithmetic delegates reject
native Gregorian and other-calendar arguments, including comparison operands,
range endpoints, and non-null parser results, with `ArgumentError`. Convert
instants explicitly before opening a picker. Invalid compact text returns
`null`; a non-null wrong-calendar result indicates incompatible configuration.

For a standalone Flutter `YearPicker`, supply a matching `currentDate`, such
as `HijriDateTime.now()`. Its native default is Gregorian. `CalendarDatePicker`
already obtains its default clock from the arithmetic delegate.

Represent scripts with `Locale.fromSubtags(languageCode: 'sr', scriptCode:
'Latn', countryCode: 'RS')`. `Locale('sr', 'Latn')` incorrectly puts the script
in the country field. Date data resolves using the locale policy above;
Flutter selects translated labels and number/time conventions from the requested
locale. The adapter applies the calendar's digit preference to numeric output.

## Conversion, field editing, and storage

Formatting does not convert calendars. Convert the instant explicitly:

```dart
DateTime value = PersianDateTime.utc(1403, 1, 1, 12, 34, 56, 789, 123);
final changed = CalendarDateUtils.copyWith(value, day: 2);
final midnight = CalendarDateUtils.dateOnly(value);
final native = CalendarDateUtils.toGregorian(value);
final hijri = HijriDateTime.fromDateTime(native);
```

These helpers preserve the selected calendar and UTC/local mode for field
operations. Dart's `DateTime.copyWith` extension and Flutter's Gregorian
`DateUtils` can reconstruct Gregorian dates from custom fields; use the safe
helpers or convert to native Gregorian before calling external utilities.

Display strings do not store a calendar ID, an IANA zone, or an authoritative
instant. For persistence, use the chronology core's `CalendarInstant` for
native Gregorian UTC timestamps with metadata, and `CalendarDateRecord` /
`CalendarDate` for all-day values. Calendar-specific `toIso8601String()` output
still contains Persian/Hijri fields and must not be sent as a generic timestamp.
The [datetime README](../general_date/README.md#json-storage) documents the
version-1 JSON schema, validation, and domain distinctions.

## Limits and error behavior

| Condition | Behavior |
| --- | --- |
| Native Gregorian or unregistered calendar passed to formatter/parse selector | `UnsupportedError`, including through nullable APIs |
| Unknown locale without fallback | Constructor throws `ArgumentError` |
| Timezone fields/skeletons | `UnsupportedError` when the pattern is used |
| Unclosed quoted literal | `FormatException` when the pattern is used |
| Malformed text, strict constraint failure, or date outside chronology bounds | `FormatException`; nullable parse counterparts return `null` |

The formatter inherits Persian/Umm al-Qura supported bounds and calculation
policies from the resolved chronology core. It supports UTC and host-local
construction, with native DST rules. Strict/loose parsing rejects DST changes
to the requested clock, except date-only midnight normalization to exactly
01:00 on the same date. Permissive parsing retains native normalization.
It does not parse or retain named zones,
resolve IANA offsets, or infer an instant's intended display timezone. A local
wall-time string can be ambiguous during a DST fold; use explicit zone policies
in the separate scheduling layer for that domain.

The pattern API resembles `intl.DateFormat`, but differs in supported runtime
calendars, six-digit fractional precision, and its calendar-selector parse
argument. It is not a drop-in replacement for arbitrary Gregorian/ICU APIs.

## Examples and testing

The [example](example/README.md) demonstrates explicit patterns, skeletons,
strict UTC parsing, three display calendars, English/Persian/Arabic selection,
and Persian/Hijri pickers. Gregorian presentation uses application-owned `intl`.
Run `flutter run` from `example` after its local setup.

Its screen captures one native clock reading and derives both calendar values
from that same instant. Locale changes and picker rebuilds retain the snapshot.
Tests inject `MyApp(now: () => DateTime.utc(2024, 3, 20, 12, 34))`.

After resolving dependencies, run from the repository root:

```sh
flutter analyze
flutter test
flutter test --tags critical
flutter test --coverage
dart format --output=none --set-exit-if-changed lib test example/lib example/test
```

Run `flutter test` from `example` separately. From
`packages/general_date_format_core`, copy its override template, then run
`dart pub get`, `dart analyze`, `dart test`, and `dart test --tags critical`.
Its CLI example runs with `dart run example/cli.dart` and supports native
`dart compile exe`.

Local verification on **2026-10-05**, using Flutter 3.47.5 / Dart 3.13.4:

| Suite | Passed |
| --- | ---: |
| Flutter formatting/Material integration | 499 |
| Tagged critical Flutter tests (included above) | 182 |
| Standalone core | 12 |
| Example widgets | 5 |

Analysis and format checks passed. The suites cover all locales, calendar
boundaries, invalid/conflicting/repeated parser fields, hour cycles, state,
symbol immutability, fallback/scripts, digits, and picker integration. Four
standalone critical regressions use seed `0xC0DE` for 2,400 display/parse/JSON
checks and 540 fraction-width checks across both calendars, UTC/local mode,
and `en`/`fa`/`ar`. A compiled native probe passed 48 exact precision/storage
checks, including negative epoch fractions.

Historical Tehran timezone assertions also passed with:

```sh
flutter test --dart-define=CALENDAR_TEST_TZ=Asia/Tehran test/timezone_environment_test.dart
```

CI is configured for minimum/current SDKs and UTC/Tehran/New York Linux jobs,
with JavaScript/Wasm smoke jobs. Windows runs use the OS timezone. Browser and
device runtime tests, minimum SDK execution, the full process-timezone matrix,
and hosted dependencies were not certified by that local run. Coverage
percentages were not recalculated; `flutter test --coverage` creates a new report.

## Locale maintenance and release checks

Persian/Umm al-Qura month and era names are generated from pinned CLDR 48.0.0
inputs with verified hashes. Shared neutral metadata and legacy date-order,
native-digit, skeleton, and `en_ISO` compatibility policies are explicit.
Canonical tables live only in `packages/general_date_format_core/lib/src`.
The [maintainer guide](tool/README.md) explains provenance, regeneration,
compatibility changes, and native/web release measurements.

Check generated data without rewriting tracked output:

```sh
python tool/generate_calendar_data.py --check
python tool/generate_persian_af_symbols.py --check
```

Downloads are cached under `.dart_tool/cldr-48`; modified inputs are rejected
against `tool/cldr_sources.lock.json`. On Windows, the unified generator accepts
`--dart <absolute-dart.exe>` if Dart is available only as a batch wrapper.

The source integration workflow pins its chronology peer by SHA in
`.github/calendar_pair.json`. Update that pin when adopting a new peer revision.
Release order is `general_datetime_core`, then `general_date_format_core` and
`general_datetime`, then `general_date_format`. Resolve/test the matching hosted
versions without local overrides before releasing wrappers. Local path success
does not certify hosted resolution.

## License

See [CHANGELOG.md](CHANGELOG.md) for release changes. Code uses the BSD 3-Clause
[LICENSE](LICENSE). Unicode data carries the notice in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
