import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime/general_datetime.dart';

import 'material_localizations_proxy.dart';

enum MaterialCalendar {
  persian,
  hijri;

  DateTime get selector =>
      this == persian ? PersianDateTime(1400) : HijriDateTime(1440);

  bool contains(DateTime date) =>
      this == persian ? date is PersianDateTime : date is HijriDateTime;
}

bool isCalendarMaterialLocaleSupported(Locale locale) =>
    GlobalMaterialLocalizations.delegate.isSupported(locale) &&
    resolveLocale(locale.toString(), GeneralDateFormat.localeExists) != null;

Future<MaterialLocalizations> loadCalendarMaterialLocalizations(
    Locale locale, MaterialCalendar calendar,
    {required bool useNativeDigits}) async {
  if (!isCalendarMaterialLocaleSupported(locale)) {
    throw ArgumentError.value(locale, 'locale',
        'Material translations and calendar symbols must both support the locale');
  }
  final translations = await GlobalMaterialLocalizations.delegate.load(locale);
  final dateLocale =
      verifiedLocale(locale.toString(), GeneralDateFormat.localeExists);
  return _CalendarMaterialLocalizations(
      translations, dateLocale, calendar, useNativeDigits);
}

/// Uses Flutter's public localization interface for translations and numbers,
/// and the bundled formatter for calendar dates. No formatter bridge is needed.
class _CalendarMaterialLocalizations extends MaterialLocalizationsProxy {
  _CalendarMaterialLocalizations(
      super.translations, String locale, this.calendar, bool nativeDigits) {
    for (final skeleton in [
      'y',
      'yMd',
      'yMMMd',
      'MMMEd',
      'yMMMMEEEEd',
      'yMMMM',
      'MMMd'
    ]) {
      _formats[skeleton] = GeneralDateFormat(skeleton, locale)
        ..useNativeDigits = nativeDigits;
    }
    final yearFormat = _formats['y']!;
    _yearTemplate = yearFormat.format(calendar.selector);
    _targetZero = (nativeDigits ? yearFormat.dateSymbols.ZERODIGIT ?? '0' : '0')
        .codeUnitAt(0);
    _sourceZero = translations.formatDecimal(0).codeUnitAt(0);
    _referenceYear = _yearDigits(calendar.selector.year);
  }

  final MaterialCalendar calendar;
  final _formats = <String, GeneralDateFormat>{};
  late final int _sourceZero;
  late final int _targetZero;
  late final String _yearTemplate;
  late final String _referenceYear;

  String _yearDigits(int year) => _translateDigits('$year', 48, _targetZero);

  @override
  String localizeDigits(String value) =>
      _translateDigits(value, _sourceZero, _targetZero);

  String _format(String skeleton, DateTime date) {
    if (!calendar.contains(date)) {
      throw ArgumentError.value(date, 'date',
          'Use a ${calendar.name} date with this calendar localization');
    }
    return _formats[skeleton]!.format(date);
  }

  @override
  String formatYear(DateTime date) =>
      // YearPicker renders native DateTimes, including disabled boundary years.
      // Preserve locale year suffixes without constructing invalid calendar dates.
      _yearTemplate.replaceFirst(_referenceYear, _yearDigits(date.year));

  @override
  String formatCompactDate(DateTime date) => _format('yMd', date);

  @override
  String formatShortDate(DateTime date) => _format('yMMMd', date);

  @override
  String formatMediumDate(DateTime date) => _format('MMMEd', date);

  @override
  String formatFullDate(DateTime date) => _format('yMMMMEEEEd', date);

  @override
  String formatMonthYear(DateTime date) => _format('yMMMM', date);

  @override
  String formatShortMonthDay(DateTime date) => _format('MMMd', date);

  @override
  DateTime? parseCompactDate(String? inputString) {
    if (inputString == null) return null;
    try {
      return _formats['yMd']!.parseStrict(inputString, calendar.selector);
    } on FormatException {
      return null;
    }
  }

  @override
  List<String> get narrowWeekdays => _formats['y']!.dateSymbols.NARROWWEEKDAYS;

  @override
  int get firstDayOfWeekIndex =>
      (_formats['y']!.dateSymbols.FIRSTDAYOFWEEK + 1) % 7;
}

String _translateDigits(String value, int sourceZero, int targetZero) {
  if (sourceZero == targetZero) return value;
  return String.fromCharCodes(value.codeUnits.map((code) =>
      code >= sourceZero && code <= sourceZero + 9
          ? code - sourceZero + targetZero
          : code));
}
