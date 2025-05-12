import 'package:general_datetime/general_datetime.dart';
import 'date_symbols.dart';
import 'jalali/jalali_symbol_data_local.dart';

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
GeneralDateTimeInterface? lastCalendar;

/// Initialize the symbols dictionary. This should be passed a function that
/// creates and returns the symbol data. We take a function so that if
/// initializing the data is an expensive operation it need only be done once,
/// no matter how many times this method is called.
void initializeDateSymbols(GeneralDateTimeInterface calendar) {
  if (lastCalendar == null ||
      lastCalendar != calendar ||
      _dateTimeSymbols == null) {
    if (calendar is JalaliDateTime) dateTimeSymbols = jalaliSymbolMap();

    /// TODO: implement for Hijri calendar
    // if (calendar is HijriDateTime) dateTimeSymbols = jalaliSymbolMap();
  }
}
