import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

import 'support/calendar_fixture.dart';

void main() {
  for (final calendar in CalendarFixture.values) {
    final year = calendar.baseYear;
    final selector = calendar.selector;
    final prefix = '$year-01-15';

    void rejects(String pattern, String input, {String locale = 'en'}) {
      final format = GeneralDateFormat(pattern, locale)
        ..now = () => DateTime.utc(2025, 6, 15);
      for (final utc in [false, true]) {
        expect(() => format.parseStrict(input, selector, utc),
            throwsFormatException,
            reason: '$pattern / $input');
        expect(format.tryParseStrict(input, selector, utc), isNull);
        expect(
            format.tryParseLoose(input.toLowerCase(), selector, utc), isNull);
      }
    }

    void roundTrip(String pattern, DateTime expected, {String locale = 'en'}) {
      final format = GeneralDateFormat(pattern, locale)
        ..now = () => DateTime.utc(2025, 6, 15);
      final input = format.format(expected);
      for (final utc in [false, true]) {
        expectCalendarFields(format.parseStrict(input, selector, utc), expected,
            utc: utc, reason: '$pattern / $input');
        expectCalendarFields(
            format.parseLoose(input.toUpperCase(), selector, utc), expected,
            utc: utc, reason: '$pattern / $input');
      }
    }

    group('${calendar.name} strict parser constraints', () {
      test('issue 6: inconsistent date constraints in either order fail', () {
        final date = calendar.date(year, 1, 15);
        final name = GeneralDateFormat('EEEE', 'en').format(date);
        final wrong = name == 'Sunday' ? 'Monday' : 'Sunday';
        rejects('yyyy-MM-dd EEEE', '$prefix $wrong');
        rejects('EEEE yyyy-MM-dd', '$wrong $prefix');
        rejects('yyyy-MM-dd Q', '$prefix 4');
        rejects('Q yyyy-MM-dd', '4 $prefix');
        rejects('yyyy-MM-dd D', '$prefix 100');
        rejects('D yyyy-MM-dd', '100 $prefix');
        rejects('yyyy-MM-dd D', '$year-01-99 100');
        rejects('yyyy-MM-dd D', '$year-13-15 100');
      });

      test('issue 6: matching redundant constraints preserve the date', () {
        final date = calendar.date(year, 2, 15);
        for (final pattern in [
          'yyyy-MM-dd Q D EEEE',
          'EEEE D Q yyyy-MM-dd',
          'yyyy-MM-dd QQQQ D cccc',
          'yyyy D MM',
          'yyyy D dd',
        ]) {
          roundTrip(pattern, date);
        }
      });

      test('issue 6: quarter supplies only missing month/day defaults', () {
        for (final quarter in [1, 2, 3, 4]) {
          final month = (quarter - 1) * 3 + 1;
          final expected = calendar.date(year, month, 1);
          roundTrip('yyyy Q', expected);
          for (final pattern in ['yyyy Q MM', 'MM Q yyyy']) {
            roundTrip(pattern, calendar.date(year, month + 1, 1));
          }
          roundTrip('yyyy Q dd', calendar.date(year, month, 15));
        }
      });

      test('issue 6: narrow weekday ambiguity matches the actual date', () {
        for (var day = 1; day <= 7; day++) {
          final date = calendar.date(year, 1, day);
          for (final pattern in ['yyyy-MM-dd EEEEE', 'yyyy-MM-dd ccccc']) {
            roundTrip(pattern, date);
          }
        }
        final date = calendar.date(year, 1, 15);
        final correct = GeneralDateFormat('EEEEE', 'en').format(date);
        final wrong = correct == 'M' ? 'W' : 'M';
        rejects('yyyy-MM-dd EEEEE', '$prefix $wrong');
      });

      test('issue 6: ordinal bounds follow the selected calendar year', () {
        final length = calendar.yearLength(year);
        rejects('yyyy D', '$year 0');
        rejects('yyyy D', '$year ${length + 1}');
        roundTrip(
            'yyyy D', calendar.date(year, 12, calendar.monthLength(year, 12)));
      });

      test('issue 6: ordinary parsing keeps permissive date precedence', () {
        final format = GeneralDateFormat('yyyy-MM-dd Q', 'en');
        final date = format.parse('$prefix 4', selector, true);
        expect([date.month, date.day], [10, 1]);
        expect(
            GeneralDateFormat('yyyy-MM-dd D', 'en')
                .parse('$year-01-99 100', selector, true),
            isNotNull);
      });

      test('issue 7: invalid and inconsistent earlier fields fail', () {
        for (final entry in {
          'yyyy yyyy-MM-dd': '999999 $prefix',
          'yyyy-MM MM-dd': '$year-99 01-15',
          'yyyy-MM-dd dd': '$year-01-99 15',
          'yyyy-MM-dd HH HH': '$prefix 25 01',
          'yyyy-MM-dd hh hh a': '$prefix 00 01 AM',
          'yyyy-MM-dd hh hh a ': '$prefix 13 01 AM ',
          'yyyy-MM-dd KK KK a': '$prefix 12 01 AM',
          'yyyy-MM-dd kk kk': '$prefix 00 01',
          'yyyy-MM-dd kk kk ': '$prefix 25 01 ',
          'yyyy-MM-dd HH:mm mm': '$prefix 01:99 02',
          'yyyy-MM-dd HH:mm:ss ss': '$prefix 01:02:99 03',
          'yyyy-MM-dd HH HH:mm': '$prefix 02 01:00',
          'yyyy-MM-dd HH:mm mm:ss': '$prefix 01:03 02:00',
          'yyyy-MM-dd HH:mm:ss ss ': '$prefix 01:02:04 03 ',
          'yyyy-MM-dd HH:mm:ss.SSS SSS': '$prefix 01:02:03.100 200',
          'yyyy-MM-dd Q Q': '$prefix 4 1',
          'yyyy-MM-dd D D': '$prefix 100 15',
          'yyyy-MM-dd hh a a': '$prefix 01 AM PM',
          'yyyy-MM-dd hh a a ': '$prefix 01 PM AM ',
        }.entries) {
          rejects(entry.key, entry.value);
        }
        final correct =
            GeneralDateFormat('EEEE', 'en').format(calendar.date(year, 1, 15));
        final wrong = correct == 'Sunday' ? 'Monday' : 'Sunday';
        rejects('yyyy-MM-dd EEEE EEEE', '$prefix $wrong $correct');
        rejects('yyyy-MM-dd EEEE EEEE', '$prefix $correct $wrong');
      });

      test('issue 7: consistent repetitions and aliases round-trip', () {
        final date = calendar.date(year, 2, 15, 13, 2, 3, 456);
        roundTrip('yyyy yyyy-MM-dd MM dd HH HH:mm mm:ss ss.SSS SSS', date);
        roundTrip('G G yyyy-MM-dd MMMM LLLL HH:mm:ss.SSS', date);
        roundTrip('yyyy-MM-dd Q QQQ D D EEEE cccc HH:mm:ss.SSS', date);
        roundTrip('yyyy-MM-dd hh hh:mm:ss.SSS a a', date);
      });

      test('issue 7: repeated two-digit years retain century semantics', () {
        final date = calendar.date(year, 2, 15);
        roundTrip('yy yyyy-MM-dd', date);
        roundTrip('yyyy yy-MM-dd', date);
        final shortYear = '${year % 100}'.padLeft(2, '0');
        rejects('yy yyyy-MM-dd', '$shortYear ${year + 1}-02-15');
        rejects('yyyy yy-MM-dd', '$year ${year % 100 + 1}-02-15');
      });

      test('issue 7: ambiguous month names retain all compatible months', () {
        for (var month = 1; month <= 12; month++) {
          final date = calendar.date(year, month, 15);
          roundTrip('yyyy-MM-dd MMMMM', date);
          roundTrip('MMMMM yyyy-MM-dd', date);
          roundTrip('yyyy-MM-dd LLLLL', date);
          for (final pattern in ['yyyy Q MMMMM dd', 'MMMMM yyyy dd Q']) {
            final format = GeneralDateFormat(pattern, 'en');
            final text = format.format(date);
            final parsed = format.parseStrict(text, selector, true);
            // Some narrow names remain ambiguous even within a quarter.
            expect(format.format(parsed), text);
            expect((parsed.month - 1) ~/ 3, (month - 1) ~/ 3);
            expect(parsed.day, 15);
          }
        }
      });

      test('issue 8: all hour cycles round-trip with day periods', () {
        for (final cycle in ['HH', 'kk', 'hh', 'KK']) {
          for (final hour in [0, 1, 11, 12, 13, 23]) {
            final date = calendar.date(year, 1, 15, hour, 2, 3);
            for (final pattern in [
              'yyyy-MM-dd $cycle:mm:ss a',
              'a yyyy-MM-dd $cycle:mm:ss',
              'yyyy-MM-dd $cycle $cycle:mm:ss a a',
            ]) {
              roundTrip(pattern, date);
            }
          }
        }
      });

      test('issue 8: contradictory 24-hour day periods fail', () {
        for (final cycle in ['HH', 'kk']) {
          for (final text in ['01 PM', '11 PM', '12 AM', '13 AM', '23 AM']) {
            rejects('yyyy-MM-dd $cycle a', '$prefix $text');
            final parts = text.split(' ');
            rejects(
                'a yyyy-MM-dd $cycle', '${parts.last} $prefix ${parts.first}');
          }
        }
        rejects('yyyy-MM-dd HH a', '$prefix 00 PM');
        rejects('yyyy-MM-dd kk a', '$prefix 24 PM');
        rejects('yyyy-MM-dd HH a', '$prefix 24 AM');
        rejects('yyyy-MM-dd kk a', '$prefix 00 AM');
      });

      test('issue 8: mixed hour cycles must describe the same hour', () {
        for (final hour in [0, 12, 13, 23]) {
          final date = calendar.date(year, 1, 15, hour, 2);
          roundTrip('yyyy-MM-dd HH hh KK kk:mm a', date);
          roundTrip('yyyy-MM-dd hh KK kk HH:mm a', date);
        }
        rejects('yyyy-MM-dd HH hh a', '$prefix 14 01 PM');
        rejects('yyyy-MM-dd hh HH a', '$prefix 01 14 PM');
      });

      test('issue 9: numeric weekdays validate range and date consistency', () {
        final date = calendar.date(year, 1, 15);
        final format = GeneralDateFormat('c', 'en')..format(date);
        final first = format.dateSymbols.FIRSTDAYOFWEEK;
        final actual = (date.weekday - 1 - first) % 7 + 1;
        final wrong = actual % 7 + 1;
        for (final pattern in ['c', 'cc']) {
          for (final value in [0, 8, 99, wrong]) {
            rejects('yyyy-MM-dd $pattern', '$prefix $value');
            rejects('$pattern yyyy-MM-dd', '$value $prefix');
          }
          rejects('yyyy-MM-dd $pattern $pattern', '$prefix $wrong $actual');
          rejects('yyyy-MM-dd $pattern $pattern', '$prefix $actual $wrong');
          roundTrip('yyyy-MM-dd $pattern $pattern EEEE', date);
        }
      });

      test('issue 9: locale-relative numbers and native digits round-trip', () {
        for (final locale in ['en_US', 'en_GB', 'fa', 'ar']) {
          final weekdayFormat = GeneralDateFormat('c cc', locale);
          for (var day = 15; day <= 21; day++) {
            final date = calendar.date(year, 1, day);
            weekdayFormat.format(date);
            final first = weekdayFormat.dateSymbols.FIRSTDAYOFWEEK;
            final expected = (date.weekday - 1 - first) % 7 + 1;
            weekdayFormat.useNativeDigits = false;
            expect(weekdayFormat.format(date), '$expected $expected');
            roundTrip('yyyy-MM-dd c cc EEEE', date, locale: locale);
            roundTrip('c cc yyyy-MM-dd', date, locale: locale);
          }
        }
      });
    });
  }

  test('issue 9: known locale week starts on the same Monday instant', () {
    final monday = DateTime.utc(2024, 1, 15);
    for (final date in [
      PersianDateTime.fromDateTime(monday),
      HijriDateTime.fromDateTime(monday),
    ]) {
      expect(GeneralDateFormat('c cc', 'en_US').format(date), '2 2');
      expect(GeneralDateFormat('c cc', 'en_GB').format(date), '1 1');
      expect(GeneralDateFormat('c cc', 'fa').format(date), '۳ ۳');
    }
  });

  test('issue 7: year occurrences sample moving native time once', () {
    var calls = 0;
    final format = GeneralDateFormat('yy yy-MM-dd HH:mm:ss.SSS', 'en')
      ..now = () =>
          PersianDateTime.utc(1404, 3, 25, 12, 0, 0, calls++).toDateTime();
    final parsed = format.parseStrict(
        '24 24-03-25 12:00:00.001', PersianDateTime(1400), true);
    expect(parsed, PersianDateTime.utc(1324, 3, 25, 12, 0, 0, 1));
    expect(calls, 1);
  });
}
