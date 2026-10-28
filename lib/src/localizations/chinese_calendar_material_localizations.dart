import 'package:flutter/material.dart';

import 'calendar_material_localizations.dart';

/// Translated Material strings with localized Chinese calendar dates.
/// Install before Flutter's global Material delegate and pair with
/// ChineseCalendarDelegate from package:general_datetime/delegates.dart.
abstract final class ChineseCalendarMaterialLocalizations {
  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      ChineseCalendarMaterialLocalizationsDelegate();

  static Future<MaterialLocalizations> load(Locale locale,
          {bool useNativeDigits = true}) =>
      loadCalendarMaterialLocalizations(locale, MaterialCalendar.chinese,
          useNativeDigits: useNativeDigits);
}

/// Controls Chinese calendar formatting and Material's numeric labels together.
class ChineseCalendarMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const ChineseCalendarMaterialLocalizationsDelegate(
      {this.useNativeDigits = true});

  final bool useNativeDigits;

  @override
  bool isSupported(Locale locale) => isCalendarMaterialLocaleSupported(locale);
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      ChineseCalendarMaterialLocalizations.load(locale,
          useNativeDigits: useNativeDigits);
  @override
  bool shouldReload(ChineseCalendarMaterialLocalizationsDelegate old) =>
      old.useNativeDigits != useNativeDigits;
}
