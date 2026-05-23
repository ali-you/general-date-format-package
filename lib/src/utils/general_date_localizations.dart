import 'package:general_date_format/src/common/date_time_patterns.dart';
import 'package:general_date_format/src/general_date_format_internal.dart';
import 'package:general_date_format/src/symbols/jalali_symbol_data_local.dart';

import '../date_symbols.dart';

bool _dateGeneralDataInitialized = false;

/// Loads i18n data for dates if it hasn't been loaded yet.
///
/// Only the first invocation of this function loads the data. Subsequent
/// invocations have no effect.
void loadDateIntlDataIfNotLoaded() {
  if (!_dateGeneralDataInitialized) {
    initializeDateSymbols(calendar);
    dateTimeSymbols = dateTimePatternMap;

    persianDateSymbolMap.forEach((String locale, DateSymbols symbols) {
      // Perform initialization.
      assert(persianDateSymbolMap.containsKey(locale));
      date_symbol_data_custom.initializeDateFormattingCustom(
        locale: locale,
        symbols: symbols,
        patterns: dateTimePatternMap[locale],
      );
    });
    _dateGeneralDataInitialized = true;
  }
}
