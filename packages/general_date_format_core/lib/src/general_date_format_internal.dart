import 'package:general_datetime_core/general_datetime_core.dart';

import 'date_symbols.dart';
import 'symbols/hijri_calendar_symbol_data_local.dart';
import 'symbols/persian_calendar_symbol_data_local.dart';

enum CalendarType { persian, hijri }

CalendarType calendarType(DateTime date) {
  if (date is PersianDateTime) return CalendarType.persian;
  if (date is HijriDateTime) return CalendarType.hijri;
  if (date is GeneralDateTimeInterface) {
    throw UnsupportedError('Calendar ${date.runtimeType} is not supported.');
  }
  throw UnsupportedError(
      'Gregorian dates are not supported by GeneralDateFormat. '
      'Use intl.DateFormat directly and choose its locale initialization in your application.');
}

DateSymbols symbolsFor(CalendarType calendar, String locale) =>
    switch (calendar) {
      CalendarType.persian => persianDateSymbolMap[locale]!,
      CalendarType.hijri => hijriDateSymbolMap[locale]!,
    };

int calendarDayOfYear(DateTime date) {
  calendarType(date);
  return (date as GeneralDateTimeInterface).dayOfYear;
}
