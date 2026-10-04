import 'package:intl/date_symbol_data_local.dart' as intl_data;
import '../date_symbols.dart';
import '../common/symbol_list.dart';
import 'calendar_locale_policy.dart';
import 'persian_calendar_data.dart';

/// CLDR 48 calendar names; compatibility date patterns and digits are explicit.
final Map<String, DateSymbols> persianDateSymbolMap = Map.unmodifiable({
  for (final locale in symbolList) locale: _symbols(locale),
});

DateSymbols _symbols(String locale) {
  final data = intl_data.dateTimeSymbolMap()[locale]!.serializeToMap();
  data['ZERODIGIT'] = calendarZeroDigits[locale];
  data['DATEFORMATS'] = persianDateFormats[locale]!;
  data.addAll(persianCalendarData[locale]!);
  return DateSymbols.deserializeFromMap(data);
}
