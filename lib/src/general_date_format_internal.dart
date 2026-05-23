import 'package:general_date_format/src/symbols/hijri_symbol_data_local.dart';
import 'package:general_datetime/general_datetime.dart';
import 'date_symbols.dart';
import 'symbols/jalali_symbol_data_local.dart';

Map<String, DateSymbols>? _dateTimeSymbols;

Map<String, DateSymbols> get dateTimeSymbols =>
    _dateTimeSymbols ?? (throw Exception("Symbols is not initialized"));

/// Set the dateTimeSymbols and invalidate cache.
set dateTimeSymbols(Map<String, DateSymbols> symbols) {
  _dateTimeSymbols = symbols;
  cachedDateSymbols = null;
  lastDateSymbolLocale = null;
}

/// Cache the last used symbols to reduce repeated lookups.
DateSymbols? cachedDateSymbols;

/// Which locale was last used for symbol lookup.
String? lastDateSymbolLocale;

/// Which calendar type was last used.
DateTime? lastCalendar;

/// Initialize the symbols dictionary. This should be passed a function that
/// creates and returns the symbol data. We take a function so that if
/// initializing the data is an expensive operation it need only be done once,
/// no matter how many times this method is called.
void initializeDateSymbols(DateTime calendar) {
  if (lastCalendar == null ||
      lastCalendar != calendar ||
      _dateTimeSymbols == null) {
    if (calendar is PersianDateTime) dateTimeSymbols = persianDateSymbolMap;
    if (calendar is HijriDateTime) dateTimeSymbols = hijriDateSymbolMap;
  }
}

Map<String, Map<String, String>>? _dateTimePatterns;

Map<String, Map<String, String>> get dateTimePatterns =>
    _dateTimePatterns ?? (throw Exception("Patterns is not initialized"));

/// Set the dateTimePatterns and invalidate cache.
set dateTimePatterns(Map<String, Map<String, String>> patterns) {
  _dateTimePatterns = patterns;
}
