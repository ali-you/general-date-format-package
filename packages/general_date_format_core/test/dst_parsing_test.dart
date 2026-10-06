import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  const zone = String.fromEnvironment('CALENDAR_TEST_TZ');
  if (zone.isNotEmpty) {
    test('requested timezone activates its DST regression fixture', () {
      switch (zone) {
        case 'Australia/Lord_Howe':
          final gap = DateTime(2024, 10, 6, 2, 15, 12, 123, 456);
          expect((gap.hour, gap.minute, gap.second), (2, 45, 12));
          break;
        case 'Africa/Monrovia':
          final gap = DateTime(1972, 1, 7, 0, 15, 12, 123, 456);
          expect((gap.hour, gap.minute, gap.second), (0, 59, 42));
          break;
        case 'Asia/Tehran':
          expect(DateTime(2021, 3, 22).hour, 1);
          break;
        default:
          fail('Unsupported requested timezone: $zone');
      }
    });
  }
  for (final hijri in [false, true]) {
    DateTime inCalendar(DateTime value) => hijri
        ? HijriDateTime.fromDateTime(value)
        : PersianDateTime.fromDateTime(value);
    final calendar = hijri ? 'Hijri' : 'Persian';

    for (final fields in [
      [2024, 10, 6, 2, 15, 12], // Lord Howe's half-hour gap.
      [1972, 1, 7, 0, 15, 12], // Monrovia's 44-minute, 30-second gap.
      [2024, 10, 6, 1, 59, 59], // Before Lord Howe's gap.
      [2024, 10, 6, 2, 30, 0], // After Lord Howe's gap.
      [1972, 1, 7, 0, 44, 30], // After Monrovia's gap.
    ]) {
      test('$calendar local clock validation for $fields', () {
        final requested = DateTime.utc(fields[0], fields[1], fields[2],
            fields[3], fields[4], fields[5], 123, 456);
        final native = DateTime(fields[0], fields[1], fields[2], fields[3],
            fields[4], fields[5], 123, 456);
        final selector = inCalendar(requested);
        final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', 'en');
        final input = format.format(selector);
        final normalized = (
              native.year,
              native.month,
              native.day,
              native.hour,
              native.minute,
              native.second,
              native.millisecond,
              native.microsecond
            ) !=
            (
              requested.year,
              requested.month,
              requested.day,
              requested.hour,
              requested.minute,
              requested.second,
              requested.millisecond,
              requested.microsecond
            );

        if (normalized) {
          expect(
              () => format.parseStrict(input, selector), throwsFormatException);
          expect(
              () => format.parseLoose(input, selector), throwsFormatException);
          expect(format.tryParseStrict(input, selector), isNull);
          expect(format.tryParseLoose(input, selector), isNull);
        } else {
          expect(format.parseStrict(input, selector).microsecondsSinceEpoch,
              native.microsecondsSinceEpoch);
          expect(format.parseLoose(input, selector).microsecondsSinceEpoch,
              native.microsecondsSinceEpoch);
        }
        // Permissive parsing retains native normalization; UTC has no DST gap.
        expect(format.parse(input, selector).microsecondsSinceEpoch,
            native.microsecondsSinceEpoch);
        expect(format.parseStrict(input, selector, true).microsecondsSinceEpoch,
            requested.microsecondsSinceEpoch);
        expect(format.parseLoose(input, selector, true).microsecondsSinceEpoch,
            requested.microsecondsSinceEpoch);
      });
    }

    test('$calendar date-only parsing retains the one-hour midnight exception',
        () {
      final selector = inCalendar(DateTime.utc(2021, 3, 22));
      final native = DateTime(2021, 3, 22); // Historical Tehran midnight gap.
      final format = GeneralDateFormat('yyyy-MM-dd', 'en');
      final input = format.format(selector);
      expect(format.parseStrict(input, selector).microsecondsSinceEpoch,
          native.microsecondsSinceEpoch);
      expect(format.parseLoose(input, selector).microsecondsSinceEpoch,
          native.microsecondsSinceEpoch);
    });
    test('$calendar date-only parsing rejects a minute/second midnight shift',
        () {
      final selector = inCalendar(DateTime.utc(1972, 1, 7));
      final native = DateTime(1972, 1, 7); // Monrovia: 00:44:30.
      final format = GeneralDateFormat('yyyy-MM-dd', 'en');
      final input = format.format(selector);
      if (native.minute != 0 || native.second != 0) {
        expect(format.tryParseStrict(input, selector), isNull);
        expect(format.tryParseLoose(input, selector), isNull);
      } else {
        expect(format.parseStrict(input, selector).microsecondsSinceEpoch,
            native.microsecondsSinceEpoch);
      }
      expect(format.parse(input, selector).microsecondsSinceEpoch,
          native.microsecondsSinceEpoch);
    });
  }
}
