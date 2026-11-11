import '../common/symbol_list.dart';
import '../date_symbols.dart';
import 'calendar_neutral_data.dart';
import 'calendar_locale_policy.dart';
import 'chinese_calendar_data.dart';

/// CLDR 48 traditional Chinese month names. Numeric patterns use ordinal
/// months for compatibility with the chronology constructor/storage contract.
final Map<String, DateSymbols> chineseDateSymbolMap = Map.unmodifiable({
  for (final locale in symbolList) locale: _symbols(locale),
});
DateSymbols _symbols(String locale) {
  final data = Map<String, dynamic>.from(calendarNeutralData[locale]!);
  data['ZERODIGIT'] = calendarZeroDigits[locale];
  data['NAME'] = locale;
  data.addAll(chineseCalendarData[locale]!);
  return DateSymbols.deserializeFromMap(data);
}

/// Regular identities 1..12 followed by the twelve possible leap identities.
List<String> chineseMonthNames(String locale, String field) => [
      ...chineseCalendarData[locale]![field]!,
      ...chineseCalendarData[locale]!['LEAP_$field']!,
    ];
