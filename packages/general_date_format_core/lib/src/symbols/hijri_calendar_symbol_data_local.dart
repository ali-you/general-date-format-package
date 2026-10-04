import '../common/symbol_list.dart';
import '../date_symbols.dart';
import 'gregorian_symbol_data_local.dart';
import 'hijri_calendar_data.dart';

/// Localized Umm al-Qura months and eras with locale-specific weekday,
/// time and digit data from intl. Calendar names come from Unicode CLDR 48.
final Map<String, DateSymbols> hijriDateSymbolMap = {
  for (final locale in symbolList) locale: _symbols(locale),
};

DateSymbols _symbols(String locale) {
  final data = gregorianSymbols(locale).serializeToMap();
  data['NAME'] = locale;
  data.addAll(hijriCalendarData[locale]!);
  return DateSymbols.deserializeFromMap(data);
}
