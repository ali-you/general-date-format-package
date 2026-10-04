import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_date_format/src/helpers.dart';
import 'package:general_datetime/general_datetime.dart';
import 'package:intl/intl.dart' as intl;

import 'support/calendar_fixture.dart';

void main() {
  test('normalizes each locale component and retains legacy defaults', () {
    for (final entry in <String?, String>{
      null: 'en_US',
      'C': 'en_ISO',
      'EN-iso': 'en_ISO',
      'SR-lATN-rs': 'sr_Latn_RS',
      'ZH_hANT-hk': 'zh_Hant_HK',
      'EN-us': 'en_US',
      'ES-latn-419': 'es_Latn_419',
      'en-US-u-NU-arab': 'en_US_u_nu_arab',
    }.entries) {
      expect(canonicalizedLocale(entry.key), entry.value);
    }
  });

  test('exact data wins, then script, then region, then language', () {
    String? resolve(Set<String> supported) =>
        resolveLocale('SR-latn-rs', supported.contains);
    expect(resolve({'sr_Latn_RS', 'sr_Latn', 'sr_RS', 'sr'}), 'sr_Latn_RS');
    expect(resolve({'sr_Latn', 'sr_RS', 'sr'}), 'sr_Latn');
    expect(resolve({'sr_RS', 'sr'}), 'sr_RS');
    expect(resolve({'sr'}), 'sr');
    expect(resolve({}), isNull);
    expect(resolve({'fallback'}), 'fallback');
  });

  test('language aliases retain script and region before lossy fallback', () {
    expect(resolveLocale('iw-Latn-IL', {'he_Latn_IL', 'iw'}.contains),
        'he_Latn_IL');
    expect(resolveLocale('he-IL', {'iw_IL', 'he'}.contains), 'iw_IL');
    expect(resolveLocale('in-ID', {'id_ID'}.contains), 'id_ID');
    expect(resolveLocale('tl-PH', {'fil'}.contains), 'fil');
    expect(resolveLocale('no-NO', {'nb'}.contains), 'nb');
  });

  final cases = <String, String>{
    'sr_Latn': 'sr_Latn',
    'sr_Latn_RS': 'sr_Latn',
    'SR-lATN-rs': 'sr_Latn',
    'sr-Cyrl-RS': 'sr',
    'zh-Hant': 'zh_TW',
    'zh-Hant-HK': 'zh_HK',
    'zh-Hant-TW': 'zh_TW',
    'zh-Hant-MO': 'zh_HK',
    'zh-Hant-CN': 'zh_TW',
    'zh-Hans': 'zh_CN',
    'zh-Hans-TW': 'zh_CN',
    'zh_HK': 'zh_HK',
    'zh_TW': 'zh_TW',
    'en-Latn-GB': 'en_GB',
    'es-Latn-419': 'es_419',
    'fa-IR': 'fa',
    'sr-Latn-RS-u-nu-latn': 'sr_Latn',
    'en-US-posix': 'en_US',
  };
  test('date and number data use the same locale candidate policy', () {
    for (final entry in cases.entries) {
      expect(GeneralDateFormat('y', entry.key).locale, entry.value,
          reason: entry.key);
      expect(
          resolveLocale(entry.key, intl.NumberFormat.localeExists), entry.value,
          reason: entry.key);
    }
    expect(GeneralDateFormat('y').locale, 'en_US');
    expect(GeneralDateFormat('y', 'C').locale, 'en_ISO');
    expect(resolveLocale('zz-Latn-ZZ', GeneralDateFormat.localeExists), isNull);
    expect(() => GeneralDateFormat('y', 'zz-Latn-ZZ'), throwsArgumentError);
  });

  for (final calendar in CalendarFixture.values) {
    final instant = DateTime.utc(2024, 1, 15);
    final monday = switch (calendar) {
      CalendarFixture.gregorian => instant,
      CalendarFixture.persian => PersianDateTime.fromDateTime(instant),
      CalendarFixture.hijri => HijriDateTime.fromDateTime(instant),
    };
    test('${calendar.name} preserves requested script in weekday names', () {
      for (final locale in ['sr_Latn_RS', 'sr-Latn-RS', 'SR_latn_rs']) {
        expect(GeneralDateFormat('EEEE', locale).format(monday), 'ponedeljak');
      }
      expect(
          GeneralDateFormat('EEEE', 'sr-Cyrl-RS').format(monday), 'понедељак');
      for (final locale in ['zh-Hant', 'zh-Hant-HK', 'zh_Hant_TW']) {
        expect(GeneralDateFormat('EEE', locale).format(monday), '週一');
      }
      expect(GeneralDateFormat('EEE', 'zh-Hans-TW').format(monday), '周一');
    });

    test('${calendar.name} parses names from the requested script', () {
      for (final entry in cases.entries) {
        final expected = GeneralDateFormat('y MMMM d EEEE', entry.value)
          ..useNativeDigits = false;
        final actual = GeneralDateFormat('y MMMM d EEEE', entry.key)
          ..useNativeDigits = false;
        final text = expected.format(monday);
        expect(actual.format(monday), text, reason: entry.key);
        expectCalendarFields(actual.parseStrict(text, monday, true), monday,
            utc: true, reason: entry.key);
        expectCalendarFields(actual.parseLoose(text, monday, true), monday,
            utc: true, reason: entry.key);
      }
    });

    test('${calendar.name} skeletons retain compatible regional patterns', () {
      for (final entry in cases.entries) {
        for (final skeleton in ['yMd', 'yMMMMEEEEd', 'jm', 'c']) {
          expect(GeneralDateFormat(skeleton, entry.key).format(monday),
              GeneralDateFormat(skeleton, entry.value).format(monday),
              reason: '${entry.key} $skeleton');
        }
      }
    });
  }
}
