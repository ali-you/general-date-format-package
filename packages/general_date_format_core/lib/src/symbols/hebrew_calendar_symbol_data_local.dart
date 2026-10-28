import '../common/symbol_list.dart';
import '../date_symbols.dart';
import 'calendar_neutral_data.dart';
import 'calendar_locale_policy.dart';
import 'hebrew_calendar_data.dart';

/// Stable Hebrew month slots and AM eras from CLDR 48. Weekday, time,
/// digit and week-rule metadata use the same neutral tables as other calendars.
final Map<String, DateSymbols> hebrewDateSymbolMap = Map.unmodifiable({
  for (final locale in symbolList) locale: _symbols(locale),
});

DateSymbols _symbols(String locale) {
  final data = Map<String, dynamic>.from(calendarNeutralData[locale]!);
  data['ZERODIGIT'] = calendarZeroDigits[locale];
  data['NAME'] = locale;
  data.addAll(hebrewCalendarData[locale]!);
  return DateSymbols.deserializeFromMap(data);
}

/// Parsing cannot choose a year type before the year token has been read.
/// Keep the thirteen stable slots, followed by the leap-year name for slot 7.
/// This internal fourteenth entry is a spelling variant, never a month number.
List<String> hebrewMonthNames(String locale, String field) => [
      ...hebrewCalendarData[locale]![field]!,
      ...hebrewCalendarData[locale]!['LEAP_$field']!,
    ];
