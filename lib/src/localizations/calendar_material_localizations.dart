import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:general_datetime/general_datetime.dart';
import 'package:intl/date_symbols.dart' as intl_symbols;
import 'package:intl/intl.dart' as intl;

import '../general_date_format.dart';
import '../helpers.dart';

enum MaterialCalendar {
  persian,
  hijri;

  DateTime get selector => yearDate(this == persian ? 1400 : 1440);

  DateTime yearDate(int year) =>
      this == persian ? PersianDateTime(year) : HijriDateTime(year);

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
  // Flutter initializes its intl locale data through its public delegate.
  // Keep its generated translations, plural rules and time conventions.
  await GlobalMaterialLocalizations.delegate.load(locale);
  final dateLocale =
      verifiedLocale(locale.toString(), GeneralDateFormat.localeExists);
  final numberLocale =
      verifiedLocale(locale.toString(), intl.NumberFormat.localeExists);
  final symbols = GeneralDateFormat('y', dateLocale)..format(calendar.selector);
  final zero = useNativeDigits ? symbols.dateSymbols.ZERODIGIT ?? '0' : '0';

  intl.DateFormat format(String skeleton) =>
      _CalendarDateFormat(skeleton, dateLocale, calendar, useNativeDigits);

  return getMaterialTranslation(
    locale,
    format('y'),
    format('yMd'),
    format('yMMMd'),
    format('MMMEd'),
    format('yMMMMEEEEd'),
    format('yMMMM'),
    format('MMMd'),
    _CalendarNumberFormat.decimal(numberLocale, zero),
    _CalendarNumberFormat.twoDigits(numberLocale, zero),
  )!;
}

/// Bridges Flutter's intl-typed date format inputs to GeneralDateFormat.
/// The adapter is private: picker clients consume MaterialLocalizations.
class _CalendarDateFormat extends intl.DateFormat {
  // Both parameters initialize the calendar formatter as well as intl.
  // ignore: use_super_parameters
  _CalendarDateFormat(
      String skeleton, String locale, this.calendar, bool nativeDigits)
      : _formatter = GeneralDateFormat(skeleton, locale)
          ..useNativeDigits = nativeDigits,
        _yearOnly = skeleton == 'y',
        super(skeleton, locale) {
    _formatter.format(calendar.selector);
    _symbols = intl_symbols.DateSymbols.deserializeFromMap(
        _formatter.dateSymbols.serializeToMap());
    if (_yearOnly) {
      _yearTemplate = _formatter.format(calendar.selector);
      _referenceYear = _yearDigits(calendar.selector.year);
    }
  }

  final MaterialCalendar calendar;
  final GeneralDateFormat _formatter;
  final bool _yearOnly;
  late final intl_symbols.DateSymbols _symbols;
  late final String _yearTemplate;
  late final String _referenceYear;

  String _yearDigits(int year) => _translateDigits(
      '$year',
      48,
      (_formatter.useNativeDigits ? _symbols.ZERODIGIT ?? '0' : '0')
          .codeUnitAt(0));

  @override
  intl_symbols.DateSymbols get dateSymbols => _symbols;

  @override
  String format(DateTime date) {
    // CalendarDelegate.formatYear intentionally constructs a native DateTime.
    // YearPicker also renders disabled labels outside a calendar's bounds.
    // Retain locale year suffixes without constructing those invalid dates.
    if (_yearOnly) {
      return _yearTemplate.replaceFirst(_referenceYear, _yearDigits(date.year));
    }
    if (!calendar.contains(date)) {
      throw ArgumentError.value(date, 'date',
          'Use a ${calendar.name} date with this calendar localization');
    }
    return _formatter.format(date);
  }

  @override
  DateTime parse(String inputString, [bool utc = false]) =>
      _formatter.parse(inputString, calendar.selector, utc);

  @override
  DateTime parseStrict(String inputString, [bool utc = false]) =>
      _formatter.parseStrict(inputString, calendar.selector, utc);

  @override
  DateTime parseLoose(String inputString, [bool utc = false]) =>
      _formatter.parseLoose(inputString, calendar.selector, utc);
}

/// Keep day grid, date fields, semantics and time picker digits consistent.
class _CalendarNumberFormat implements intl.NumberFormat {
  _CalendarNumberFormat.decimal(String locale, this._zero)
      : _formatter = intl.NumberFormat.decimalPattern(locale);
  _CalendarNumberFormat.twoDigits(String locale, this._zero)
      : _formatter = intl.NumberFormat('00', locale);

  final intl.NumberFormat _formatter;
  final String _zero;

  @override
  String format(dynamic number) {
    final result = _formatter.format(number);
    final sourceZero = _formatter.symbols.ZERO_DIGIT.codeUnitAt(0);
    final targetZero = _zero.codeUnitAt(0);
    return _translateDigits(result, sourceZero, targetZero);
  }

  // Flutter's GlobalMaterialLocalizations accepts NumberFormat but only calls
  // format. NumberFormat has factory-only public constructors, so this private
  // formatting adapter uses composition. Other operations fail explicitly.
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Calendar number adapter only supports format.');
}

String _translateDigits(String value, int sourceZero, int targetZero) {
  if (sourceZero == targetZero) return value;
  return String.fromCharCodes(value.codeUnits.map((code) =>
      code >= sourceZero && code <= sourceZero + 9
          ? code - sourceZero + targetZero
          : code));
}
