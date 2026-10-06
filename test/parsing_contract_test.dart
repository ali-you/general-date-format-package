@Tags(['critical'])
library;

import 'package:general_datetime/general_datetime.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';

import 'support/calendar_fixture.dart';

void main() {
  group('Parser contracts', () {
    test('Calendar construction failures become FormatException or null', () {
      final format = GeneralDateFormat('yyyy-MM-dd');
      final selector = PersianDateTime(1400);
      // A year outside the Persian chronology range.
      const input = '275761-01-01';
      expect(() => format.parse(input, selector, true), throwsFormatException);
      expect(() => format.parseStrict(input, selector, true),
          throwsFormatException);
      expect(format.tryParse(input, selector, true), isNull);
      expect(format.tryParseStrict(input, selector, true), isNull);
      expect(format.tryParseLoose(input, selector, true), isNull);
      expect(format.tryParseUtc(input, selector), isNull);
    });
    for (final calendar in CalendarFixture.values) {
      group(calendar.name, () {
        final year = calendar.baseYear;
        final invalidDates = <String, String>{
          'empty': '',
          'missing year': '-01-01',
          'missing month': '$year--01',
          'missing day': '$year-01-',
          'wrong separator': '$year/01/01',
          'day zero': '$year-01-00',
          'month zero': '$year-00-01',
          'month thirteen': '$year-13-01',
          'negative month': '$year--1-01',
          'negative day': '$year-01--1',
          'non numeric': '$year-one-01',
          'signed month': '$year-+1-01',
          'embedded whitespace': '$year-0 1-01',
          'leading whitespace': ' $year-01-01',
          'trailing whitespace': '$year-01-01 ',
          'trailing text': '$year-01-01tail',
          'trailing nul': '$year-01-01\u0000',
          'oversized integer': '${'9' * 80}-01-01',
        };
        for (final entry in invalidDates.entries) {
          test('strict rejects ${entry.key}', () {
            final format = GeneralDateFormat('yyyy-MM-dd');
            for (final utc in [false, true]) {
              expect(
                  () => format.parseStrict(entry.value, calendar.selector, utc),
                  throwsFormatException);
              expect(format.tryParseStrict(entry.value, calendar.selector, utc),
                  isNull);
            }
          });
        }

        final invalidTimes = <String, String>{
          'H:mm:ss': '24:00:00',
          'k:mm:ss': '25:00:00',
          'h:mm:ss a': '13:00:00 AM',
          'K:mm:ss a': '12:00:00 PM',
          'HH:mm:ss': '23:60:00',
          'HH:m:ss': '23:59:60',
          'HH:mm:s': '23:59:-1',
        };
        for (final entry in invalidTimes.entries) {
          test('strict rejects ${entry.value} for ${entry.key}', () {
            final format = GeneralDateFormat('yyyy-MM-dd ${entry.key}');
            final input = '$year-01-01 ${entry.value}';
            expect(() => format.parseStrict(input, calendar.selector, true),
                throwsFormatException);
            expect(
                format.tryParseStrict(input, calendar.selector, true), isNull);
            expect(
                format.tryParseLoose(input, calendar.selector, true), isNull);
          });
        }

        test(
            'all throwing and nullable APIs agree on valid and malformed input',
            () {
          final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSS');
          final expected = calendar.date(year, 2, 15, 12, 34, 56, 789);
          final text = '$year-02-15 12:34:56.789';
          for (final utc in [false, true]) {
            for (final parse in [
              format.parse,
              format.parseStrict,
              format.parseLoose
            ]) {
              expectCalendarFields(
                  parse(text, calendar.selector, utc), expected,
                  utc: utc);
              expect(() => parse('unparseable', calendar.selector, utc),
                  throwsFormatException);
            }
            for (final parse in [
              format.tryParse,
              format.tryParseStrict,
              format.tryParseLoose
            ]) {
              expectCalendarFields(
                  parse(text, calendar.selector, utc)!, expected,
                  utc: utc);
              expect(parse('unparseable', calendar.selector, utc), isNull);
            }
          }
          for (final parse in [format.parseUtc, format.parseUTC]) {
            expectCalendarFields(parse(text, calendar.selector), expected,
                utc: true);
            expect(() => parse('unparseable', calendar.selector),
                throwsFormatException);
          }
          expectCalendarFields(
              format.tryParseUtc(text, calendar.selector)!, expected,
              utc: true);
          expect(format.tryParseUtc('unparseable', calendar.selector), isNull);
        });

        test('ordinary parse permits trailing text, loose and strict reject it',
            () {
          final format = GeneralDateFormat('yyyy-MM-dd');
          final expected = calendar.date(year, 1, 1);
          for (final suffix in [' garbage', '\nextra', '\u0000']) {
            final input = '$year-01-01$suffix';
            expectCalendarFields(
                format.parse(input, calendar.selector, true), expected,
                utc: true);
            expect(
                format.tryParseStrict(input, calendar.selector, true), isNull);
            expect(
                format.tryParseLoose(input, calendar.selector, true), isNull);
          }
        });

        test('compact input rejects absent fields and invalid components', () {
          final format = GeneralDateFormat('yyyyMMddHHmmssSSS');
          for (final input in [
            '$year',
            '${year}01',
            '${year}0101',
            '${year}1301000000000',
            '${year}0101240000000',
            '${year}0101126000000'
          ]) {
            expect(
                format.tryParseStrict(input, calendar.selector, true), isNull,
                reason: input);
          }
        });

        test('selector supplies a calendar, never the missing time fields', () {
          final selector = calendar.date(year + 1, 9, 19, 23, 59, 59, 999);
          final parsed = GeneralDateFormat('yyyy-MM-dd')
              .parseStrict('$year-02-15', selector, true);
          expectCalendarFields(parsed, calendar.date(year, 2, 15), utc: true);
        });

        test('failed parsing does not poison subsequent calendar selection',
            () {
          final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSS', 'fa');
          expect(format.tryParseStrict('bad', calendar.selector), isNull);
          for (final next in CalendarFixture.values.reversed) {
            final expected = next.date(next.baseYear, 9, 1, 23, 59, 59, 999);
            expectCalendarFields(
                format.parseStrict(
                    format.format(expected), next.selector, true),
                expected,
                utc: true);
          }
        });
      });
    }

    test('two-digit century boundary includes seconds and milliseconds', () {
      final format = GeneralDateFormat('yy-MM-dd HH:mm:ss.SSS')
        ..now = () =>
            PersianDateTime.utc(1404, 3, 25, 12, 30, 45, 500).toDateTime();
      for (final entry in {
        '24-03-25 12:30:45.499': 1424,
        '24-03-25 12:30:45.500': 1424,
        '24-03-25 12:30:45.501': 1324,
        '24-03-25 12:30:46.000': 1324,
      }.entries) {
        expect(format.parseStrict(entry.key, PersianDateTime(1400), true).year,
            entry.value,
            reason: entry.key);
      }
      for (final pattern in ['y', 'yyy', 'yyyy']) {
        expect(
            GeneralDateFormat('$pattern-MM-dd')
                .parseStrict('45-01-01', PersianDateTime(1400), true)
                .year,
            45);
      }
    });

    for (final entry in {
      "yyyy-MM-dd 'at' HH:mm": '1403-02-29 at 13:05',
      "yyyy-MM-dd 'o''clock' HH:mm": "1403-02-29 o'clock 13:05",
      "yyyy-MM-dd '' HH:mm": "1403-02-29 ' 13:05",
      "yyyy-MM-dd 'z Z v' HH:mm": '1403-02-29 z Z v 13:05',
    }.entries) {
      test('literal quoting ${entry.key}', () {
        final format = GeneralDateFormat(entry.key);
        final expected = PersianDateTime(1403, 2, 29, 13, 5);
        expect(format.format(expected), entry.value);
        expectCalendarFields(
            format.parseStrict(entry.value, PersianDateTime(1400), true),
            expected,
            utc: true);
      });
    }

    for (final pattern in [
      'G yyyy-MM-dd',
      'EEEE yyyy-MM-dd',
      'cccc yyyy-MM-dd',
      'a hh yyyy-MM-dd'
    ]) {
      test('loose parsing requires the textual field in $pattern', () {
        final input = pattern.startsWith('a') ? '01 1403-01-01' : '1403-01-01';
        final format = GeneralDateFormat(pattern);
        expect(() => format.parseLoose(input, PersianDateTime(1400), true),
            throwsFormatException);
        expect(
            format.tryParseLoose(input, PersianDateTime(1400), true), isNull);
        final expected =
            PersianDateTime(1403, 1, 1, pattern.startsWith('a') ? 1 : 0);
        final valid =
            format.format(expected).toUpperCase().replaceAll(' ', '\t  ');
        expectCalendarFields(
            format.parseLoose(valid, PersianDateTime(1400), true), expected,
            utc: true);
      });
    }

    test('invalid quarters fail through throwing and nullable APIs', () {
      for (final input in ['0', '5', '-1', 'Q0', 'Q5', 'unknown']) {
        final format =
            GeneralDateFormat('yyyy ${input.startsWith('Q') ? 'QQQ' : 'Q'}');
        expect(
            () =>
                format.parseStrict('1403 $input', PersianDateTime(1400), true),
            throwsFormatException);
        expect(
            format.tryParseStrict('1403 $input', PersianDateTime(1400), true),
            isNull);
      }
    });

    test('bad pattern errors propagate through nullable APIs', () {
      for (final pattern in ['z', 'Z', 'v', 'jmv', 'jmz', 'jv', 'jz']) {
        final format = GeneralDateFormat(pattern);
        expect(
            () => format.format(PersianDateTime(1403)), throwsUnsupportedError);
        expect(() => format.tryParseStrict('anything', PersianDateTime(1400)),
            throwsUnsupportedError);
      }
      final unclosed = GeneralDateFormat("yyyy 'unterminated");
      expect(
          () => unclosed.format(PersianDateTime(1403)), throwsFormatException);
      expect(unclosed.tryParseStrict('2024', PersianDateTime(1400)), isNull);
    });
  });
}
