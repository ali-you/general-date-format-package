// Flutter 3.32 uses the SDK design libraries.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'calendar_material_localizations.dart';

/// English and Hindi Material strings with Indian National Calendar dates.
///
/// Install before Flutter's global Material delegate and pair with
/// SakaCalendarDelegate from package:general_datetime/delegates.dart.
abstract final class SakaCalendarMaterialLocalizations {
  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      SakaCalendarMaterialLocalizationsDelegate();

  static Future<MaterialLocalizations> load(Locale locale,
      {bool useNativeDigits = true}) {
    if (!_supportsSaka(locale)) {
      throw ArgumentError.value(locale, 'locale', 'Expected English or Hindi');
    }
    return loadCalendarMaterialLocalizations(locale, MaterialCalendar.saka,
        useNativeDigits: useNativeDigits);
  }
}

/// Controls Saka date formatting and Material's numeric labels together.
class SakaCalendarMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const SakaCalendarMaterialLocalizationsDelegate(
      {this.useNativeDigits = true});

  final bool useNativeDigits;

  @override
  bool isSupported(Locale locale) => _supportsSaka(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SakaCalendarMaterialLocalizations.load(locale,
          useNativeDigits: useNativeDigits);

  @override
  bool shouldReload(SakaCalendarMaterialLocalizationsDelegate old) =>
      old.useNativeDigits != useNativeDigits;
}

bool _supportsSaka(Locale locale) =>
    (locale.languageCode == 'en' || locale.languageCode == 'hi') &&
    isCalendarMaterialLocaleSupported(locale);
