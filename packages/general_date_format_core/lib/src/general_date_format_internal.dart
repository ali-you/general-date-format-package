import 'package:general_datetime_core/general_datetime_core.dart';

import 'date_symbols.dart';
import 'symbols/gregorian_symbol_data_local.dart';
import 'symbols/hijri_calendar_symbol_data_local.dart';
import 'symbols/persian_calendar_symbol_data_local.dart';

enum CalendarType { gregorian, persian, hijri }

CalendarType calendarType(DateTime date) {
  if (date is PersianDateTime) return CalendarType.persian;
  if (date is HijriDateTime) return CalendarType.hijri;
  if (date is GeneralDateTimeInterface) {
    throw UnsupportedError('Calendar ${date.runtimeType} is not supported.');
  }
  return CalendarType.gregorian;
}

DateSymbols symbolsFor(CalendarType calendar, String locale) =>
    switch (calendar) {
      CalendarType.gregorian => gregorianSymbols(locale),
      CalendarType.persian => persianDateSymbolMap[locale]!,
      CalendarType.hijri => hijriDateSymbolMap[locale]!,
    };

int calendarDayOfYear(DateTime date) {
  if (date is GeneralDateTimeInterface) {
    return (date as GeneralDateTimeInterface).dayOfYear;
  }
  // UTC field arithmetic avoids DST affecting the day count.
  return DateTime.utc(date.year, date.month, date.day)
          .difference(DateTime.utc(date.year))
          .inDays +
      1;
}
