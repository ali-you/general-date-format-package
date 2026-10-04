@Tags(['critical'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

import 'support/calendar_fixture.dart';

/// No fields should be read before an unregistered calendar is rejected.
class _UnregisteredCalendar implements DateTime, GeneralDateTimeInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError(
      'Unexpected calendar field access: ${invocation.memberName}');
}

void main() {
  group('Formatter state isolation', () {
    test(
        'unregistered calendars fail explicitly without altering the formatter',
        () {
      final format = GeneralDateFormat('yyyy-MM-dd');
      final unsupported = _UnregisteredCalendar();
      expect(() => format.format(unsupported), throwsUnsupportedError);
      expect(() => format.parseStrict('2024-01-01', unsupported),
          throwsUnsupportedError);
      expect(() => format.tryParseStrict('2024-01-01', unsupported),
          throwsUnsupportedError);
      expect(format.format(DateTime(2024, 1, 1)), '2024-01-01');
    });
    for (final locale in ['fa', 'ar']) {
      test(
          '$locale native digits remain parseable when ASCII output is selected',
          () {
        final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSS', locale);
        for (final calendar in CalendarFixture.values) {
          final expected =
              calendar.date(calendar.baseYear, 9, 15, 13, 5, 6, 789);
          format.useNativeDigits = true;
          final native = format.format(expected);
          expect(native, isNot(matches(RegExp(r'[0-9]'))));
          format.useNativeDigits = false;
          final ascii = format.format(expected);
          expect(ascii, matches(RegExp(r'^\d{4}-09-15 13:05:06\.789$')));
          for (final input in [native, ascii]) {
            expectCalendarFields(
                format.parseStrict(input, calendar.selector, true), expected,
                utc: true, reason: '$locale ${calendar.name} $input');
          }
          format.useNativeDigits = true;
          expect(format.format(expected), native);
        }
      });

      test(
          '$locale native digit default is isolated from initialized instances',
          () {
        final originalDefault =
            GeneralDateFormat.shouldUseNativeDigitsByDefaultFor(locale);
        try {
          GeneralDateFormat.useNativeDigitsByDefaultFor(locale, true);
          final existing = GeneralDateFormat('yyyy', locale);
          final native = existing.format(DateTime(2024));
          GeneralDateFormat.useNativeDigitsByDefaultFor(locale, false);
          final ascii = GeneralDateFormat('yyyy', locale);
          expect(ascii.format(DateTime(2024)), '2024');
          expect(existing.format(DateTime(2024)), native);
          GeneralDateFormat.useNativeDigitsByDefaultFor(locale, true);
          expect(ascii.format(DateTime(2024)), '2024');
        } finally {
          GeneralDateFormat.useNativeDigitsByDefaultFor(
              locale, originalDefault);
        }
      });
    }

    test('one formatter cycles between calendars using independent golden text',
        () {
      final format = GeneralDateFormat('MMMM G yyyy-MM-dd');
      final expected = [
        'September AD 2024-09-01',
        'Azar AP 1403-09-01',
        'Ramadan AH 1446-09-01',
      ];
      for (var cycle = 0; cycle < 20; cycle++) {
        for (var index = 0; index < CalendarFixture.values.length; index++) {
          final calendar = CalendarFixture.values[index];
          final date = calendar.date(calendar.baseYear, 9, 1);
          expect(format.format(date), expected[index]);
          expectCalendarFields(
              format.parseStrict(expected[index], calendar.selector, true),
              date,
              utc: true);
        }
      }
    });

    test(
        'addPattern refreshes parsed fields and dateOnly after caches are warm',
        () {
      final format = GeneralDateFormat('yyyy-MM-dd');
      expect(format.dateOnly, true);
      expect(format.format(DateTime(2024, 2, 29)), '2024-02-29');
      expect(format.parseStrict('2024-02-29', DateTime(2000), true).day, 29);
      expect(identical(format.addPattern('HH:mm', ' @ '), format), true);
      expect(format.dateOnly, false);
      final date = DateTime(2024, 2, 29, 23, 59);
      expect(format.format(date), '2024-02-29 @ 23:59');
      expectCalendarFields(
          format.parseStrict('2024-02-29 @ 23:59', DateTime(2000), true), date,
          utc: true);
      expect(format.tryParseStrict('2024-02-29', DateTime(2000)), isNull);
      expect(
          format.tryParseStrict('2024-02-29 @ 24:00', DateTime(2000)), isNull);
    });
  });

  group('Local time and DST', () {
    test('date-only parsing tolerates a midnight DST jump', () {
      // Tehran moved its clocks at midnight on this historical date.
      final reference = DateTime(2021, 3, 22);
      final format = GeneralDateFormat('yyyy-MM-dd');
      final local = format.parseStrict('2021-03-22', DateTime(2000));
      expect(local.millisecondsSinceEpoch, reference.millisecondsSinceEpoch);
      expectCalendarFields(local, reference, utc: false);
      expectCalendarFields(
          format.parseStrict('2021-03-22', DateTime(2000), true),
          DateTime.utc(2021, 3, 22),
          utc: true);
    });
    // CI runs these under UTC, Asia/Tehran and America/New_York. Native
    // DateTime is the independent oracle for wall-time/instant behavior.
    for (final parts in [
      [2024, 3, 10, 1, 59], // Before New York's spring gap.
      [2024, 3, 10, 3, 0], // After the gap.
      [2024, 11, 3, 0, 59], // Before the autumn repeated hour.
      [2024, 11, 3, 2, 0], // After it.
      [2024, 12, 31, 23, 59],
      [2025, 1, 1, 0, 0],
    ]) {
      test('native local/UTC instant for $parts', () {
        final expected =
            DateTime(parts[0], parts[1], parts[2], parts[3], parts[4]);
        final format = GeneralDateFormat('yyyy-MM-dd HH:mm');
        final text = format.format(expected);
        final local = format.parseStrict(text, DateTime(2000));
        final utc = format.parseStrict(text, DateTime(2000), true);
        expectCalendarFields(local, expected, utc: false);
        expectCalendarFields(utc, expected, utc: true);
        expect(local.millisecondsSinceEpoch, expected.millisecondsSinceEpoch);
        expect(
            utc.millisecondsSinceEpoch,
            DateTime.utc(parts[0], parts[1], parts[2], parts[3], parts[4])
                .millisecondsSinceEpoch);
        expect(local.timeZoneOffset, expected.timeZoneOffset);
      });
    }

    test('strict local parsing rejects DST wall times that normalize', () {
      final format = GeneralDateFormat('yyyy-MM-dd HH:mm');
      const input = '2024-03-10 02:30';
      final reference = DateTime(2024, 3, 10, 2, 30);
      if (reference.hour != 2 || reference.minute != 30) {
        expect(format.tryParseStrict(input, DateTime(2000)), isNull);
        expect(format.parse(input, DateTime(2000)).millisecondsSinceEpoch,
            reference.millisecondsSinceEpoch);
      } else {
        expectCalendarFields(
            format.parseStrict(input, DateTime(2000)), reference,
            utc: false);
      }
      expectCalendarFields(format.parseStrict(input, DateTime(2000), true),
          DateTime.utc(2024, 3, 10, 2, 30),
          utc: true);
    });
  });
}
