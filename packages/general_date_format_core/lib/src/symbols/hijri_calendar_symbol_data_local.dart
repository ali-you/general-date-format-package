import '../common/symbol_list.dart';
import '../date_symbols.dart';
import 'calendar_neutral_data.dart';
import 'calendar_locale_policy.dart';
import 'hijri_calendar_data.dart';

/// Localized Umm al-Qura months and eras with locale-specific weekday,
/// time and digit data from bundled tables. Calendar names use Unicode CLDR 48.
final Map<String, DateSymbols> hijriDateSymbolMap = Map.unmodifiable({
  for (final locale in symbolList) locale: _symbols(locale),
});

DateSymbols _symbols(String locale) {
  final data = Map<String, dynamic>.from(calendarNeutralData[locale]!);
  data['ZERODIGIT'] = calendarZeroDigits[locale];
  data['NAME'] = locale;
  data.addAll(hijriCalendarData[locale]!);
  return DateSymbols.deserializeFromMap(data);
}
