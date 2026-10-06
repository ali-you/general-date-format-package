import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

void expectFields(DateTime actual, DateTime expected) {
  expect([
    actual.year,
    actual.month,
    actual.day,
    actual.hour,
    actual.minute,
    actual.second,
    actual.millisecond
  ], [
    expected.year,
    expected.month,
    expected.day,
    expected.hour,
    expected.minute,
    expected.second,
    expected.millisecond
  ]);
}

void main() {
  final calendars = <String, DateTime>{
    'Persian': PersianDateTime(1403, 1, 1, 13, 5, 6, 789),
    'Hijri': HijriDateTime(1446, 9, 1, 13, 5, 6, 789),
  };

  test('Persian symbols are available before formatting', () {
    expect(GeneralDateFormat('MMMM').dateSymbols.MONTHS.first, 'Farvardin');
  });

  test('Formatters can alternate calendars without changing each other', () {
    final first = GeneralDateFormat('MMMM G');
    final second = GeneralDateFormat('MMMM', 'fa');
    expect(first.format(HijriDateTime(1446, 9, 1)), 'Ramadan AH');
    expect(second.format(PersianDateTime(1403, 1, 1)), 'فروردین');
    expect(first.dateSymbols.MONTHS[8], 'Ramadan');
    expect(first.format(PersianDateTime(1403, 1, 1)), 'Farvardin AP');
    expect(first.format(HijriDateTime(1446, 9, 1)), 'Ramadan AH');
  });

  test('Hijri names and eras use CLDR English, Arabic and Persian', () {
    final date = HijriDateTime(1446, 9, 1);
    expect(GeneralDateFormat('MMMM G', 'en').format(date), 'Ramadan AH');
    expect(GeneralDateFormat('MMMM G', 'ar').format(date), 'رمضان هـ');
    expect(GeneralDateFormat('MMMM', 'fa').format(date), 'رمضان');
    expect(GeneralDateFormat('LLLL', 'ar').format(date), 'رمضان');
  });

  test('Every advertised locale formats both calendars', () {
    for (final locale in GeneralDateFormat.allLocalesWithSymbols()) {
      for (final date in calendars.values) {
        final format = GeneralDateFormat.yMMMMEEEEd(locale).add_Hms();
        expect(format.format(date), isNotEmpty,
            reason: '$locale ${date.runtimeType}');
      }
    }
  });

  for (final entry in calendars.entries) {
    group(entry.key, () {
      final date = entry.value;
      test('Local and UTC parse preserve calendar type and fields', () {
        final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSS');
        final text = format.format(date);
        final local = format.parseStrict(text, date);
        final utc = format.parseStrict(text, date, true);
        expect(local.runtimeType, date.runtimeType);
        expect(utc.runtimeType, date.runtimeType);
        expect(local.isUtc, isFalse);
        expect(utc.isUtc, isTrue);
        expectFields(local, date);
        expectFields(utc, date);
        expectFields(format.parseUtc(text, date), date);
        expect(format.parseUTC(text, date).isUtc, isTrue);
        expect(format.tryParseUtc(text, date)!.isUtc, isTrue);
        expectFields(format.tryParse(text, date)!, date);
      });

      test('Time-only parsing has a valid calendar default date', () {
        final parsed =
            GeneralDateFormat('HH:mm').parseStrict('13:05', date, true);
        expect(parsed.runtimeType, date.runtimeType);
        expect(parsed.isUtc, isTrue);
        expect([parsed.hour, parsed.minute], [13, 5]);
      });

      test('Parsing needs no earlier format call and uses supplied calendar',
          () {
        final input = '${date.year}-${date.month}-${date.day}';
        final parsed = GeneralDateFormat('yyyy-M-d').parse(input, date);
        expect(parsed.runtimeType, date.runtimeType);
        expect([parsed.year, parsed.month, parsed.day],
            [date.year, date.month, date.day]);
      });

      test('Compact numeric fields round-trip in English and native digits',
          () {
        for (final locale in ['en', 'fa', 'ar']) {
          final format = GeneralDateFormat('yyyyMMddHHmmssSSS', locale);
          expectFields(
              format.parseStrict(format.format(date), date, true), date);
        }
      });

      test('Localized month and narrow weekday parsing round-trip', () {
        for (final locale in ['en', 'fa', 'ar']) {
          final format = GeneralDateFormat('yyyy MMMM dd EEEEE', locale);
          final parsed = format.parseStrict(format.format(date), date, true);
          expect([parsed.year, parsed.month, parsed.day],
              [date.year, date.month, date.day]);
        }
      });

      test('Day of year is calendar-specific and validates the result', () {
        final format = GeneralDateFormat('yyyy D');
        final text = format.format(date);
        final parsed = format.parseStrict(text, date, true);
        expect([parsed.year, parsed.month, parsed.day],
            [date.year, date.month, date.day]);
        expect(format.tryParseStrict('${date.year} 0', date, true), isNull);
        expect(format.tryParseStrict('${date.year} 367', date, true), isNull);
      });

      test('Strict dates reject overflow while ordinary parse normalizes', () {
        final format = GeneralDateFormat('yyyy-MM-dd');
        expect(format.tryParseStrict('${date.year}-02-32', date), isNull);
        expect(format.parse('${date.year}-02-32', date).month, 3);
        expect(format.tryParseStrict('${date.year}-13-01', date), isNull);
        expect(format.tryParseStrict('${date.year}-00-01', date), isNull);
        expect(
            format.tryParseStrict('${date.year}-01-01 trailing', date), isNull);
        expect(format.tryParse('bad input', date), isNull);
        expect(format.tryParseUtc('bad input', date), isNull);
      });

      test('Loose month parsing handles case and whitespace', () {
        final format = GeneralDateFormat('yyyy MMMM d');
        final text = format.format(date).toUpperCase().replaceAll(' ', '   ');
        final parsed = format.parseLoose(text, date, true);
        expect([parsed.year, parsed.month, parsed.day],
            [date.year, date.month, date.day]);
        expect(format.tryParseLoose('invalid', date), isNull);
      });
    });
  }

  test('Strict time parsing respects each hour symbol range', () {
    final selector = PersianDateTime(1403);
    for (final pattern in ['h', 'K', 'k', 'H']) {
      final format = GeneralDateFormat('yyyy-MM-dd $pattern:mm a');
      for (final hour in [0, 1, 11, 12, 13, 23]) {
        final date = PersianDateTime(1403, 3, 1, hour, 5);
        // AM/PM applies only to 12-hour patterns.
        final actualFormat = pattern == 'H' || pattern == 'k'
            ? GeneralDateFormat('yyyy-MM-dd $pattern:mm')
            : format;
        expect(
            actualFormat
                .parseStrict(actualFormat.format(date), selector, true)
                .hour,
            hour);
      }
    }
    expect(GeneralDateFormat('h a').tryParseStrict('0 AM', selector), isNull);
    expect(GeneralDateFormat('h a').tryParseStrict('13 PM', selector), isNull);
    expect(GeneralDateFormat('K a').tryParseStrict('12 AM', selector), isNull);
    expect(GeneralDateFormat('k').tryParseStrict('0', selector), isNull);
    expect(GeneralDateFormat('H').tryParseStrict('24', selector), isNull);
    expect(GeneralDateFormat('HH:mm:ss').tryParseStrict('12:60:00', selector),
        isNull);
  });

  test('Century window uses the selected calendar and injected native time',
      () {
    final instant = DateTime.utc(2025, 6, 15, 12);
    for (final selector in [PersianDateTime(1400), HijriDateTime(1440)]) {
      final current = selector is PersianDateTime
          ? PersianDateTime.fromDateTime(instant)
          : HijriDateTime.fromDateTime(instant);
      final format = GeneralDateFormat('yy-MM-dd')..now = () => instant;
      final parsed = format.parseUtc(
          '${(current.year % 100).toString().padLeft(2, '0')}-01-01', selector);
      expect(parsed.year, current.year);
    }
  });

  test('Fractional parsing preserves emitted millisecond precision', () {
    final date = PersianDateTime(1403, 1, 1, 1, 2, 3, 789, 123);
    for (final pattern in ['S', 'SSS', 'SSSSSS']) {
      final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.$pattern');
      expect(
          format.parseStrict(format.format(date), date, true).millisecond, 789);
    }
    expect(GeneralDateFormat('ss.S').parseUtc('03.5', date).millisecond, 500);
  });

  test('Format mutation invalidates date-only cache', () {
    final format = GeneralDateFormat.yMd();
    expect(format.dateOnly, isTrue);
    format.add_Hms();
    expect(format.dateOnly, isFalse);
    expect(format.tryParseStrict('3/1/2025 99:00:00', PersianDateTime(1403)),
        isNull);
  });

  test('Malformed quotes and unsupported time zones fail explicitly', () {
    expect(
        () =>
            GeneralDateFormat("yyyy 'unfinished").format(PersianDateTime(1403)),
        throwsFormatException);
    expect(GeneralDateFormat("'Zone:' yyyy").format(PersianDateTime(1403)),
        'Zone: 1403');
    for (final pattern in ['z', 'Z', 'v', 'HH:mm z']) {
      expect(() => GeneralDateFormat(pattern).format(PersianDateTime(1403)),
          throwsUnsupportedError);
    }
    // A long literal/field pattern must not recurse until the stack overflows.
    expect(
        GeneralDateFormat(List.filled(10000, 'y ').join())
            .format(PersianDateTime(1403))
            .length,
        50000);
  });

  test('Native digits and ASCII digits can be parsed by the same locale', () {
    final format = GeneralDateFormat('yyyy-MM-dd', 'fa');
    expect(format.parseUtc('1403-01-01', PersianDateTime(1400)).year, 1403);
    expect(format.parseUtc('۱۴۰۳-۰۱-۰۱', PersianDateTime(1400)).year, 1403);
    expect(format.parseUtc('14۰۳-۰1-۰۱', PersianDateTime(1400)).year, 1403);
    format.useNativeDigits = false;
    expect(format.format(PersianDateTime(1403, 1, 1)), '1403-01-01');
    expect(
        GeneralDateFormat('yyyy-MM-dd', 'ar')
            .format(PersianDateTime(1403, 3, 1)),
        '١٤٠٣-٠٣-٠١');
  });

  test('Quarter formats parse in the Persian calendar', () {
    final selector = PersianDateTime(1403);
    for (final pattern in ['Q', 'QQ', 'QQQ', 'QQQQ']) {
      final format = GeneralDateFormat('yyyy $pattern');
      final parsed =
          format.parseUtc(format.format(PersianDateTime(1403, 7, 1)), selector);
      expect([parsed.year, parsed.month, parsed.day], [1403, 7, 1]);
    }
  });

  test('Signed Persian years retain their sign in numeric and compact patterns',
      () {
    for (final locale in ['en', 'fa', 'ar']) {
      for (final pattern in ['yyyy-MM-dd', 'yyyyMMdd', 'yy-MM-dd']) {
        final date = PersianDateTime(-61, 2, 31);
        final format = GeneralDateFormat(pattern, locale);
        final text = format.format(date);
        expect(text, startsWith('-'));
        expectFields(
            format.parseStrict(text, PersianDateTime(1400), true), date);
      }
    }
  });
}
