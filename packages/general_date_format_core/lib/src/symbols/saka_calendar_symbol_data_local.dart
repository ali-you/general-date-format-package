import '../common/symbol_list.dart';
import '../date_symbols.dart';
import 'calendar_locale_policy.dart';
import 'calendar_neutral_data.dart';
import 'saka_calendar_data.dart';

/// CLDR 48 Saka month and era names. Locales outside Hindi use English names.
final Map<String, DateSymbols> sakaDateSymbolMap = Map.unmodifiable({
  for (final locale in symbolList) locale: _symbols(locale),
});

DateSymbols _symbols(String locale) {
  final data = Map<String, dynamic>.from(calendarNeutralData[locale]!);
  // Hindi uses Devanagari when the caller requests native digits.
  data['ZERODIGIT'] = locale == 'hi' ? '०' : calendarZeroDigits[locale];
  data.addAll(sakaCalendarData[locale] ?? sakaCalendarData['en']!);
  return DateSymbols.deserializeFromMap(data);
}
