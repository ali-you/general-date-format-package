@Tags(['critical'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

import 'support/calendar_fixture.dart';

void main() {
  group('Calendar boundaries', () {
    final gregorianLeapDays = <int, bool>{
      1900: false,
      1999: false,
      2000: true,
      2023: false,
      2024: true,
      2100: false,
      2400: true,
    };
    for (final entry in gregorianLeapDays.entries) {
      test('Gregorian February 29 in ${entry.key}', () {
        final format = GeneralDateFormat('yyyy-MM-dd');
        final input = '${entry.key}-02-29';
        if (entry.value) {
          expectCalendarFields(format.parseStrict(input, DateTime(2000), true),
              DateTime(entry.key, 2, 29),
              utc: true);
        } else {
          expect(() => format.parseStrict(input, DateTime(2000), true),
              throwsFormatException);
          expect(format.tryParseStrict(input, DateTime(2000), true), isNull);
        }
      });
    }

    test('Persian long and short months have independent golden boundaries',
        () {
      final format = GeneralDateFormat('yyyy-MM-dd');
      final selector = PersianDateTime(1402);
      for (final input in [
        '1402-01-31',
        '1402-06-31',
        '1402-07-30',
        '1402-12-29'
      ]) {
        expect(format.format(format.parseStrict(input, selector, true)), input);
      }
      for (final input in ['1402-01-32', '1402-07-31', '1402-12-31']) {
        expect(format.tryParseStrict(input, selector, true), isNull,
            reason: input);
      }
    });

    for (final calendar in CalendarFixture.values) {
      group(calendar.name, () {
        for (var month = 1; month <= 12; month++) {
          test('month $month accepts its last day and rejects the next', () {
            // Calendar arithmetic belongs to the dependency; the formatter
            // must validate against whichever calendar implementation is used.
            final length = calendar.monthLength(calendar.baseYear, month);
            final last = calendar.date(
                calendar.baseYear, month, length, 23, 59, 59, 999);
            for (final locale in ['en', 'fa', 'ar']) {
              final format =
                  GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSS', locale);
              expectCalendarFields(
                  format.parseStrict(
                      format.format(last), calendar.selector, true),
                  last,
                  utc: true,
                  reason: '$locale month $month');
            }
            final format = GeneralDateFormat('yyyy-M-d');
            final overflow = '${calendar.baseYear}-$month-${length + 1}';
            expect(format.tryParseStrict(overflow, calendar.selector, true),
                isNull);
            expectCalendarFields(
                format.parse(overflow, calendar.selector, true),
                calendar.date(calendar.baseYear, month + 1, 1),
                utc: true);
          });
        }

        for (final year in [calendar.baseYear - 1, calendar.baseYear]) {
          test('ordinal day spans every month in year $year', () {
            final format = GeneralDateFormat('yyyy-DDD');
            var ordinal = 0;
            for (var month = 1; month <= 12; month++) {
              final length = calendar.monthLength(year, month);
              for (var day = 1; day <= length; day++) {
                ordinal++;
                final text = '$year-${ordinal.toString().padLeft(3, '0')}';
                final expected = calendar.date(year, month, day);
                expect(format.format(expected), text,
                    reason: '${calendar.name} $year/$month/$day');
                expectCalendarFields(
                    format.parseStrict(text, calendar.selector, true), expected,
                    utc: true, reason: text);
              }
            }
            expect(ordinal, calendar.yearLength(year));
            expect(format.tryParseStrict('$year-000', calendar.selector, true),
                isNull);
            expect(
                format.tryParseStrict(
                    '$year-${ordinal + 1}', calendar.selector, true),
                isNull);
            expectCalendarFields(
                format.parse('$year-${ordinal + 1}', calendar.selector, true),
                calendar.date(year + 1),
                utc: true);
          });
        }

        test('all 24 hours round-trip through H, k, h and K', () {
          for (final pattern in ['HH', 'kk', 'hh a', 'KK a']) {
            final format = GeneralDateFormat('yyyy-MM-dd $pattern:mm:ss');
            for (var hour = 0; hour < 24; hour++) {
              final date = calendar.date(calendar.baseYear, 1, 1, hour, 59, 59);
              expectCalendarFields(
                  format.parseStrict(
                      format.format(date), calendar.selector, true),
                  date,
                  utc: true,
                  reason: '$pattern hour $hour');
            }
          }
        });

        test('every quarter maps to its first month and day when parsed', () {
          for (var month = 1; month <= 12; month++) {
            for (final token in ['Q', 'QQ', 'QQQ', 'QQQQ']) {
              final format = GeneralDateFormat('yyyy $token');
              final date = calendar.date(calendar.baseYear, month, 15);
              final firstMonth = ((month - 1) ~/ 3) * 3 + 1;
              expectCalendarFields(
                  format.parseStrict(
                      format.format(date), calendar.selector, true),
                  calendar.date(calendar.baseYear, firstMonth),
                  utc: true,
                  reason: '${calendar.name} $token month $month');
            }
          }
        });

        test('subsecond zeros, padding and truncation', () {
          for (final width in [1, 2, 3, 6, 9]) {
            final format =
                GeneralDateFormat('yyyy-MM-dd HH:mm:ss.${'S' * width}');
            for (final millisecond in [0, 1, 9, 10, 99, 100, 500, 999]) {
              final date = calendar.date(
                  calendar.baseYear, 1, 1, 0, 0, 0, millisecond, 321);
              final fraction = millisecond.toString().padLeft(3, '0') +
                  '0' * (width > 3 ? width - 3 : 0);
              final text = '${calendar.baseYear}-01-01 00:00:00.$fraction';
              expect(format.format(date), text);
              expectCalendarFields(
                  format.parseStrict(text, calendar.selector, true), date,
                  utc: true);
            }
          }
          final format = GeneralDateFormat('yyyy-MM-dd ss.SSSSSS');
          for (final entry
              in {'0': 0, '01': 10, '123456': 123, '999999': 999}.entries) {
            final parsed = format.parseStrict(
                '${calendar.baseYear}-01-01 00.${entry.key}',
                calendar.selector,
                true);
            expect(parsed.millisecond, entry.value);
            expect(parsed.microsecond, 0);
          }
        });
      });
    }

    test('Gregorian year zero and BC/AD transition retain their eras', () {
      final format = GeneralDateFormat('yyyy-MM-dd G');
      for (final entry in {
        0: '0001-01-01 BC',
        -1: '0002-01-01 BC',
        1: '0001-01-01 AD',
        -43: '0044-01-01 BC'
      }.entries) {
        final expected = DateTime(entry.key);
        expect(format.format(expected), entry.value);
        expectCalendarFields(
            format.parseStrict(entry.value, DateTime(2000), true), expected,
            utc: true);
      }
    });

    test('English weekdays use Sunday-based symbols for a complete week', () {
      final full = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday'
      ];
      final short = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      final narrow = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
      for (var index = 0; index < 7; index++) {
        final date = DateTime(2024, 1, 7 + index);
        for (final entry in {
          'EEEE': full,
          'cccc': full,
          'EEE': short,
          'ccc': short,
          'EEEEE': narrow,
          'ccccc': narrow
        }.entries) {
          expect(GeneralDateFormat(entry.key).format(date), entry.value[index]);
          final format = GeneralDateFormat('yyyy-MM-dd ${entry.key}');
          expectCalendarFields(
              format.parseStrict(format.format(date), DateTime(2000), true),
              date,
              utc: true);
        }
      }
    });
  });
}
