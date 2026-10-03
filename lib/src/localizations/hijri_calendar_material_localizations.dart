import 'package:flutter/material.dart';

import 'calendar_material_localizations.dart';

/// Loads translated Material strings with Hijri calendar date formatting.
///
/// Install [delegate] before Flutter's global Material delegate, either in
/// MaterialApp or in a picker-specific Localizations.override. Pair it with
/// HijriCalendarDelegate from package:general_datetime/delegates.dart.
abstract final class HijriCalendarMaterialLocalizations {
  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      HijriCalendarMaterialLocalizationsDelegate();

  static Future<MaterialLocalizations> load(Locale locale,
          {bool useNativeDigits = true}) =>
      loadCalendarMaterialLocalizations(locale, MaterialCalendar.hijri,
          useNativeDigits: useNativeDigits);
}

/// Material localization delegate for a Hijri calendar picker.
class HijriCalendarMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const HijriCalendarMaterialLocalizationsDelegate(
      {this.useNativeDigits = true});

  /// Controls both calendar dates and Material's numeric day/year/time labels.
  final bool useNativeDigits;

  @override
  bool isSupported(Locale locale) => isCalendarMaterialLocaleSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      HijriCalendarMaterialLocalizations.load(locale,
          useNativeDigits: useNativeDigits);

  @override
  bool shouldReload(HijriCalendarMaterialLocalizationsDelegate old) =>
      old.useNativeDigits != useNativeDigits;
}
