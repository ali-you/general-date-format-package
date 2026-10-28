import 'package:flutter/material.dart';

import 'calendar_material_localizations.dart';

/// Translated Material strings with localized Hebrew calendar dates.
/// Install before Flutter's global Material delegate and pair with
/// HebrewCalendarDelegate from package:general_datetime/delegates.dart.
abstract final class HebrewCalendarMaterialLocalizations {
  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      HebrewCalendarMaterialLocalizationsDelegate();

  static Future<MaterialLocalizations> load(Locale locale,
          {bool useNativeDigits = true}) =>
      loadCalendarMaterialLocalizations(locale, MaterialCalendar.hebrew,
          useNativeDigits: useNativeDigits);
}

/// Controls Hebrew calendar formatting and Material's numeric labels together.
class HebrewCalendarMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const HebrewCalendarMaterialLocalizationsDelegate(
      {this.useNativeDigits = true});

  final bool useNativeDigits;

  @override
  bool isSupported(Locale locale) => isCalendarMaterialLocaleSupported(locale);
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      HebrewCalendarMaterialLocalizations.load(locale,
          useNativeDigits: useNativeDigits);
  @override
  bool shouldReload(HebrewCalendarMaterialLocalizationsDelegate old) =>
      old.useNativeDigits != useNativeDigits;
}
