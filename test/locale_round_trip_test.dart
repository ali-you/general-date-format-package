import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:intl/date_symbol_data_local.dart' as intl_data;

import 'support/calendar_fixture.dart';

void main() {
  setUpAll(intl_data.initializeDateFormatting);

  group('Locale data and named patterns', () {
    for (final locale in GeneralDateFormat.allLocalesWithSymbols()) {
      test('$locale: twelve months in both calendars', () {
        for (final calendar in CalendarFixture.values) {
          for (var month = 1; month <= 12; month++) {
            final expected =
                calendar.date(calendar.baseYear, month, 15, 13, 5, 6, 789);
            final full = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSS', locale);
            expectCalendarFields(
                full.parseStrict(
                    full.format(expected), calendar.selector, true),
                expected,
                utc: true,
                reason: '$locale ${calendar.name} month $month');
            for (final format in [
              GeneralDateFormat.yMd(locale),
              GeneralDateFormat.yMMMd(locale),
              GeneralDateFormat.yMMMMd(locale),
              GeneralDateFormat('yyyy LLLL dd', locale),
            ]) {
              final dateOnly = calendar.date(calendar.baseYear, month, 15);
              final text = format.format(dateOnly);
              final parsed = format.parseStrict(text, calendar.selector, true);
              final pattern = format.pattern!;
              final symbols = format.dateSymbols;
              final names = pattern.contains('LLLL')
                  ? symbols.STANDALONEMONTHS
                  : pattern.contains('MMMM')
                      ? symbols.MONTHS
                      : pattern.contains('MMM')
                          ? symbols.SHORTMONTHS
                          : null;
              // Some locale data has duplicate month abbreviations. Such
              // text must preserve its spelling, but cannot select one month.
              final ambiguous = names != null &&
                  names.where((name) => name == names[month - 1]).length > 1;
              if (ambiguous) {
                expect(names[parsed.month - 1], names[month - 1]);
                expect(format.format(parsed), text);
              }
              expectCalendarFields(
                  parsed,
                  ambiguous
                      ? calendar.date(calendar.baseYear, parsed.month, 15)
                      : dateOnly,
                  utc: true,
                  reason: '$locale ${calendar.name} ${format.pattern} $text');
            }
          }
        }
      });
    }

    test('locale aliases and regional fallback resolve consistently', () {
      for (final entry in {
        'en-us': 'en_US',
        'en-GB': 'en_GB',
        'fa_IR': 'fa',
        'ar-IR': 'ar',
        'C': 'en_ISO',
        'iw': 'he',
      }.entries) {
        final format = GeneralDateFormat.yMMMMd(entry.key);
        final canonical = GeneralDateFormat.yMMMMd(entry.value);
        for (final calendar in CalendarFixture.values) {
          expect(format.format(calendar.selector),
              canonical.format(calendar.selector),
              reason: '${entry.key} ${calendar.name}');
        }
      }
      expect(GeneralDateFormat.yMd().locale, 'en_US');
      for (final invalid in ['', 'not_a_locale', 'zz_ZZ']) {
        expect(() => GeneralDateFormat.yMd(invalid), throwsArgumentError);
      }
    });

    test('loose parsing accepts abbreviated and full names in either pattern',
        () {
      for (final calendar in CalendarFixture.values) {
        for (final month in [1, 6, 9, 12]) {
          final expected = calendar.date(calendar.baseYear, month, 15);
          for (final inputPattern in [
            'yyyy MMM dd',
            'yyyy MMMM dd',
            'yyyy LLL dd',
            'yyyy LLLL dd'
          ]) {
            final text = GeneralDateFormat(inputPattern)
                .format(expected)
                .toUpperCase()
                .replaceAll(' ', '\t  ');
            for (final parsePattern in [
              'yyyy MMM dd',
              'yyyy MMMM dd',
              'yyyy LLL dd',
              'yyyy LLLL dd'
            ]) {
              final format = GeneralDateFormat(parsePattern);
              expectCalendarFields(
                  format.parseLoose(text, calendar.selector, true), expected,
                  utc: true, reason: '${calendar.name} $parsePattern $text');
            }
          }
        }
      }
    });
  });

  group('Deterministic round trips', () {
    for (final calendar in CalendarFixture.values) {
      for (final locale in ['en', 'fa', 'ar']) {
        for (final utc in [false, true]) {
          test(
              '${calendar.name} $locale ${utc ? 'UTC' : 'local'}: seed 0x5eed, 100 dates',
              () {
            final random = Random(0x5eed);
            final formats = [
              GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSS', locale),
              GeneralDateFormat('yyyyMMddHHmmssSSS', locale),
              GeneralDateFormat('dd MMMM yyyy hh:mm:ss.SSS a', locale),
              GeneralDateFormat('yyyy DDD HH:mm:ss.SSS', locale),
            ];
            for (var sample = 0; sample < 100; sample++) {
              final year = calendar.baseYear - 4 + random.nextInt(9);
              final month = 1 + random.nextInt(12);
              final expected = calendar.date(
                  year,
                  month,
                  1 + random.nextInt(calendar.monthLength(year, month)),
                  random.nextInt(24),
                  random.nextInt(60),
                  random.nextInt(60),
                  random.nextInt(1000));
              for (final format in formats) {
                final text = format.format(expected);
                expectCalendarFields(
                    format.parseStrict(text, calendar.selector, utc), expected,
                    utc: utc,
                    reason:
                        'seed=0x5eed sample=$sample ${format.pattern} $text');
              }
            }
          });
        }
      }
    }
  });
}
