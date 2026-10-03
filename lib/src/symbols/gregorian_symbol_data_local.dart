import 'package:intl/date_symbol_data_local.dart' as intl_data;

import '../date_symbols.dart';
import 'jalali_symbol_data_local.dart';

final _intlSymbols = intl_data.dateTimeSymbolMap();
final _gregorianSymbols = <String, DateSymbols>{};

DateSymbols gregorianSymbols(String locale) =>
    _gregorianSymbols.putIfAbsent(locale, () {
      final symbols = _intlSymbols[locale];
      if (symbols == null) throw ArgumentError('Invalid locale "$locale"');
      final result = DateSymbols.deserializeFromMap(symbols.serializeToMap());
      // Preserve this package's native-digit defaults for every calendar.
      result.ZERODIGIT = persianDateSymbolMap[locale]!.ZERODIGIT;
      return result;
    });
