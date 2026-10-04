import 'dart:convert';
import 'dart:io';

import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  test('resolved CLI dependency graph contains no Flutter integration', () {
    final config = jsonDecode(
      File('.dart_tool/package_config.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final names = (config['packages'] as List)
        .map((entry) => (entry as Map)['name'])
        .toSet();
    expect(names,
        containsAll(['general_date_format_core', 'general_datetime_core']));
    for (final name in [
      'flutter',
      'flutter_localizations',
      'flutter_test',
      'general_datetime',
      'general_date_format',
      'intl',
      'clock',
    ]) {
      expect(names, isNot(contains(name)));
    }
  });

  test('Gregorian operations fail with migration guidance and preserve state',
      () {
    final date = HijriDateTime.utc(1445, 9, 10);
    final format = GeneralDateFormat('yyyy-MM-dd');
    final text = format.format(date);
    final symbols = format.dateSymbols;
    final native = DateTime.utc(2024, 3, 20);
    final operations = <Object? Function()>[
      () => format.format(native),
      () => format.parse(text, native),
      () => format.parseStrict(text, native),
      () => format.parseLoose(text, native),
      () => format.parseUtc(text, native),
      () => format.parseUTC(text, native),
      () => format.tryParse(text, native),
      () => format.tryParseStrict(text, native),
      () => format.tryParseLoose(text, native),
      () => format.tryParseUtc(text, native),
    ];
    for (final operation in operations) {
      expect(
          operation,
          throwsA(isA<UnsupportedError>().having((error) => error.message,
              'migration', contains('intl.DateFormat'))));
      expect(identical(format.dateSymbols, symbols), isTrue);
      expect(format.format(date), text);
    }
  });

  test('native time callback is per formatter and read only for short years',
      () {
    var calls = 0;
    final format = GeneralDateFormat('yy-MM-dd')
      ..now = () {
        calls++;
        return PersianDateTime.utc(1404, 3, 25).toDateTime();
      };
    final other = GeneralDateFormat('yy-MM-dd')
      ..now = () => PersianDateTime.utc(1504, 3, 25).toDateTime();
    final selector = PersianDateTime.utc(1400);
    expect(format.format(selector), '00-01-01');
    expect(format.parseUtc('1403-01-01', selector).year, 1403);
    expect(calls, 0);
    expect(format.parseUtc('04-01-01', selector).year, 1404);
    expect(calls, 1);
    expect(other.parseUtc('04-01-01', selector).year, 1504);
    expect(calls, 1);
  });

  test('Persian and Hijri format and parse independent UTC fixtures', () {
    final instant = DateTime.utc(2024, 3, 20, 13, 5);
    final format = GeneralDateFormat('yyyy-MM-dd HH:mm', 'en_US');
    for (final fixture in [
      (PersianDateTime.utc(1403, 1, 1, 13, 5), '1403-01-01 13:05'),
      (HijriDateTime.utc(1445, 9, 10, 13, 5), '1445-09-10 13:05'),
    ]) {
      expect(format.format(fixture.$1), fixture.$2);
      final parsed = format.parseStrict(fixture.$2, fixture.$1, true);
      expect(parsed.runtimeType, fixture.$1.runtimeType);
      expect(parsed.isUtc, isTrue);
      expect(CalendarDateUtils.toGregorian(parsed), instant);
    }
  });

  test('localized digits and script fallback work in Dart alone', () {
    final date = PersianDateTime.utc(1403, 1, 1);
    final format = GeneralDateFormat('yyyy/MM/dd', 'fa');
    expect(format.format(date), '۱۴۰۳/۰۱/۰۱');
    expect(format.parseStrict('۱۴۰۳/۰۱/۰۱', date, true), date);
    expect(GeneralDateFormat('EEEE', 'sr-Latn-RS').format(date), 'sreda');
  });

  test('strict parser retains conflicting-field and hour-cycle guards', () {
    for (final date in <DateTime>[
      PersianDateTime.utc(1403, 1, 1),
      HijriDateTime.utc(1445, 9, 10),
    ]) {
      expect(
        () => GeneralDateFormat('HH:mm a').parseStrict('01:00 PM', date, true),
        throwsFormatException,
      );
      expect(
        GeneralDateFormat('HH:mm a').parseStrict('13:00 PM', date, true).hour,
        13,
      );
      expect(
        () => GeneralDateFormat('HH HH').parseStrict('25 01', date, true),
        throwsFormatException,
      );
    }
  });
}
