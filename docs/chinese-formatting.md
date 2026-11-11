# Chinese formatting and Material pickers

Formatter core 3.1.0 and Flutter wrapper 4.1.0 support `ChineseDateTime` from
chronology core 3.x / wrapper 5.x. Locale selects language and digits; the date
object selects the calendar. No locale initialization is required by the core.

```dart
final date = ChineseDateTime.utc(2025, 7, 1);
final format = GeneralDateFormat('d MMMM yyyy', 'en');
assert(format.format(date) == '1 Sixth Monthbis 2025');
assert(format.parseStrict(format.format(date), date, true) == date);
assert(GeneralDateFormat('yyyy MMMM d', 'zh').format(date) == '2025 闰六月 1');
```

The year is the Gregorian year containing lunar New Year. Numeric `M`, `MM`,
`L` and `LL` are chronological ordinal months, including month 13 in leap years.
Named patterns use the twelve traditional month names and CLDR 48 leap markers
in all 120 bundled locale identifiers. `dateSymbols.MONTHS` lists regular month
names; format a date to obtain the year-specific ordinal month's name.

Strict parsing resolves names after reading the year, rejects nonexistent leap
months, and validates redundant numeric/named month fields. Loose parsing also
recognizes narrow names and flexible whitespace. Use `SSSSSS` for microseconds.
Era (`G`), quarter (`Q`), and cyclic-year semantics are outside this API. Era
and quarter patterns throw `UnsupportedError` for Chinese dates.

```dart
MaterialApp(
  locale: const Locale('zh'),
  supportedLocales: const [Locale('zh')],
  localizationsDelegates: const [
    ChineseCalendarMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  // Use ChineseDateTime values and ChineseCalendarDelegate in pickers.
);
```

Import the adapters from `package:general_date_format/general_date_format.dart`
or `package:general_date_format/localizations.dart`. The configurable delegate
and `load` method accept `useNativeDigits`. Install the calendar delegate before
Flutter's global Material delegate. Input uses locale date order and ordinal
numeric months, so repeated traditional month names cannot lose leap identity.

`general_calendar` uses the same delegate/localizations for month/year views,
selection, ranges and combined time input. For Flutter `showDateRangePicker`,
use `ChineseCalendarDelegate().rangePickerDelegate` together with
`calendarDateRangePickerBuilder` from `general_datetime/delegates.dart`.

Chronology remains bounded to lunar years 1901-2099 (Gregorian 1901-02-19 through
2100-02-08), following pinned .NET data. It differs from HKO on 30 days and Node
ICU 77.1 on 417 days. Formatting does not change that chronology or compute solar
terms, observance times, geographical timezones or astronomical alternatives.

Generated Chinese symbols use checksum-locked Unicode CLDR 48.0.0 inputs.
Run `python tool/generate_calendar_data.py --calendar chinese --check` to verify
them. Runtime dependencies remain free of `intl` and Flutter in the Dart core;
Unicode attribution is retained in both packages' third-party notices.

For exhaustive formatter-to-Gregorian validation, run from the core directory:

```console
dart tool/validate_chinese_oracle.dart <path-to-chinese_dotnet_months.json>
```

The fixture comes from the chronology repository's `test/fixtures` directory.
This checks all 72,674 days against independently exported .NET anchors and
literal CLDR English month names, rather than only round-tripping formatter output.
