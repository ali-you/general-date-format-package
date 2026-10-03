import 'package:flutter/material.dart';

import 'calendar_material_localizations.dart';

/// Loads translated Material strings with Persian calendar date formatting.
///
/// Install [delegate] before Flutter's global Material delegate, either in
/// MaterialApp or in a picker-specific Localizations.override. Pair it with
/// PersianCalendarDelegate from package:general_datetime/delegates.dart.
abstract final class PersianCalendarMaterialLocalizations {
  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      PersianCalendarMaterialLocalizationsDelegate();

  static Future<MaterialLocalizations> load(Locale locale,
          {bool useNativeDigits = true}) =>
      loadCalendarMaterialLocalizations(locale, MaterialCalendar.persian,
          useNativeDigits: useNativeDigits);
}

/// Material localization delegate for a Persian calendar picker.
class PersianCalendarMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const PersianCalendarMaterialLocalizationsDelegate(
      {this.useNativeDigits = true});

  /// Controls both calendar dates and Material's numeric day/year/time labels.
  final bool useNativeDigits;

  @override
  bool isSupported(Locale locale) => isCalendarMaterialLocaleSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      PersianCalendarMaterialLocalizations.load(locale,
          useNativeDigits: useNativeDigits);

  @override
  bool shouldReload(PersianCalendarMaterialLocalizationsDelegate old) =>
      old.useNativeDigits != useNativeDigits;
}
