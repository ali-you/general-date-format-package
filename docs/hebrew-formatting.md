# Hebrew formatting and parsing

The formatter core and Flutter wrapper accept `HebrewDateTime`, alongside
Persian and Umm al-Qura dates. The input type selects the calendar; the locale
selects language, shared skeleton patterns, weekdays, week rules, and digits.
All 120 bundled locales have Hebrew month and era data from pinned CLDR 48.

The coordinated releases are published on pub.dev: formatter core 2.0.0,
formatter wrapper 3.0.0, chronology core 2.0.0, and chronology wrapper 4.0.0.
All 509 formatter wrapper tests passed against these hosted dependencies
without development overrides. Published library files and archive checksums
were independently verified against the validated release source.

```dart
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

final date = HebrewDateTime.utc(5784, 7, 10, 12, 34, 56, 123, 456);
print(GeneralDateFormat('d MMMM y G', 'en').format(date));
// 10 Adar II 5784 AM
print(GeneralDateFormat('d MMMM y', 'he').format(date));
// 10 אדר ב׳ 5784

final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', 'fa');
final input = format.format(date); // ۵۷۸۴-۰۷-۱۰ ۱۲:۳۴:۵۶.۱۲۳۴۵۶
final parsed = format.parseStrict(input, HebrewDateTime(5785), true);
print(parsed == date); // true
```

Pure Dart applications import the corresponding `general_date_format_core`
and `general_datetime_core` libraries. Gregorian formatting remains in the
consumer application's `intl.DateFormat`.

## Month identity and parsing

Numeric `M`/`L` fields preserve the chronology's stable slots: Tishri=1,
Adar I=6 (leap years only), Adar/Adar II=7, Nisan=8, and Elul=13.
Common years omit slot 6. Use `HebrewDateTime.monthsOfYear(year)` to iterate;
`date.monthOrdinal` reports chronological position in that year.

Textual `MMM`/`MMMM` and `LLL`/`LLLL` select the localized Adar II spelling
for slot 7 in leap years. Strict parsing validates names against the input year,
including when the month name precedes the year. The selector supplies the
calendar type, not the parsed year's leap status. Adar I and an explicit Adar II
name are rejected in a common year. The ordinary Adar name also accepts slot 7
in leap years as an alias. Locale spellings shared by common/leap variants cannot
distinguish year types by themselves.

Narrow names can be ambiguous. Supply a numeric month or another month field
to disambiguate them in strict parsing, as with the other calendars. Names ending
in numerals use digit boundaries so a leap spelling such as Korean Adar 2 does
not consume the first digit of an ordinary Adar day such as 29.

`dateSymbols` remains immutable and calendar-specific. Its month arrays contain
thirteen base slots, with ordinary Adar in slot 7. They do not choose a year type;
use `format` to obtain a leap-year label. The internal Adar II spelling variant
is never a numeric month 14.

The core supports AM 1–9999 and midnight-based civil dates. Strict parsing rejects
invalid dates; permissive parsing retains the chronology's overflow rules and
still rejects an absent explicit leap month. Weekday, day-of-year, era, clock,
fractional-second, repeated-field, and two-digit-year validation apply to Hebrew
dates. `now` defines the rolling year window in the Hebrew calendar. Use
`SSSSSS` for microseconds and pass `true` to parse in UTC.

Quarter `Q` patterns and quarter skeletons raise `UnsupportedError` for Hebrew
values and selectors: the package does not define quarters for its 12/13-month
years. Quoted literal `Q` is unaffected. Existing Persian/Hijri quarter behavior
is preserved. Hebrew letters as numeric years (gematria), sunset boundaries,
holidays, named timezone patterns, and observance rules are outside these APIs.

## Material pickers

Use the chronology's arithmetic delegate with the formatter's translated
localizations, scoped to a Hebrew picker:

```dart
import 'package:flutter/material.dart';
import 'package:general_datetime/delegates.dart';

Future<DateTime?> pickHebrew(BuildContext context) => showDatePicker(
  context: context,
  initialDate: HebrewDateTime(5784, 7, 10),
  firstDate: HebrewDateTime(5783),
  lastDate: HebrewDateTime(5785, 13, 29),
  currentDate: HebrewDateTime.now(),
  calendarDelegate: const HebrewCalendarDelegate(),
  builder: (context, child) => Localizations.override(
    context: context,
    locale: const Locale('he'),
    delegates: const [HebrewCalendarMaterialLocalizations.delegate],
    child: child!,
  ),
);
```

The enclosing application needs Flutter's global localization delegates and the
requested supported locale for its other Material/Widgets/Cupertino strings.
`HebrewCalendarMaterialLocalizationsDelegate(useNativeDigits: false)` selects
ASCII dates and numeric Material labels. `load(locale, useNativeDigits: ...)`
is also available. These adapters use locale-specific compact date order; English
input is `M/d/y`. Locale support requires both formatter data and Flutter Material
translations. Invalid compact input returns null; wrong-calendar values throw
`ArgumentError`.

For range pickers, use `const HebrewCalendarDelegate().rangePickerDelegate`
and `calendarDateRangePickerBuilder(rangeDelegate)`. The localized adapter works
with the same endpoint handling as the chronology package. The example now
includes a Hebrew card, date picker, and Hebrew-language locale option.

## Checkout setup and verification

The prepared releases are formatter core 2.0.0 / wrapper 3.0.0 and chronology
core 2.0.0 / wrapper 4.0.0. Consumer constraints now require these minimums.
Use the updated local source pair until the matching versions are published.
See [release migration](release-migration.md). From the formatter root:

```console
python tool/resolve_calendar_pair.py --chronology ../general_date --formatter .
flutter pub get
```

The helper configures root, example, and pure Dart core overrides. CI checks out
the recorded chronology revision and uses this same helper. Overrides are ignored
by Git and are development-only. For release verification, resolve compatible
hosted packages without these overrides.

Core tests round-trip every valid month in representative leap/common years
across all bundled locales, test name order, narrow ambiguity, numeric boundaries,
precision, calendar reuse, invalid dates, eras/ordinals/weekdays, and short-year
windows. Coexistence tests verify that Hebrew formatter state cannot change
Persian/Hijri names, quarters, digit parsing or year windows. Material tests
cover translated strings and digits, Hebrew-script month
navigation, compact input, and range selection. The Hebrew core suite also runs
under Node in CI; browser jobs include the Material suite.

Source hashes are in `tool/cldr_sources.lock.json`. Regenerate or verify Hebrew
tables with `python tool/generate_calendar_data.py --calendar hebrew --check`
(omit `--check` to regenerate approved inputs). Source and license attribution
are in the packages' third-party notices.
