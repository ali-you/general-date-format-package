import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  test('odd microseconds survive formatting beyond exact JS epoch integers',
      () {
    for (final native in [
      DateTime.utc(1600, 3, 20, 12, 34, 56, 123, 1),
      DateTime.utc(2300, 3, 20, 12, 34, 56, 123, 457),
      DateTime.utc(6000, 3, 20, 12, 34, 56, 999, 999),
    ]) {
      final calendars = [
        HebrewDateTime.fromDateTime(native),
        if (PersianDateTime.isSupportedDateTime(native))
          PersianDateTime.fromDateTime(native)
      ];
      for (final date in calendars) {
        for (final locale in ['en', 'fa', 'ar', 'he']) {
          final format =
              GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', locale);
          final input = format.format(date);
          final parsed = format.parseStrict(input, date, true);
          expect(parsed, native);
          expect(parsed.microsecond, native.microsecond);
          expect(CalendarDateUtils.toGregorian(parsed), native);
        }
      }
    }
  });
  for (final selector in <DateTime>[
    PersianDateTime.utc(1403, 1, 1),
    HijriDateTime.utc(1445, 9, 10)
  ]) {
    test(
        'microseconds round trip for ${selector.runtimeType} and native digits',
        () {
      final date = CalendarDateUtils.copyWith(selector,
          millisecond: 123, microsecond: 456);
      for (final locale in ['en', 'fa']) {
        final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', locale);
        expect(
            format
                .parseStrict(format.format(date), selector, true)
                .microsecondsSinceEpoch,
            date.microsecondsSinceEpoch);
      }
      expect(GeneralDateFormat('SSSS').format(date), '1234');
      expect(GeneralDateFormat('SSSSSSSSS').format(date), '123456000');
      final format = GeneralDateFormat('yyyy-MM-dd ss.SSSSSSS');
      final prefix =
          '${selector.year}-${selector.month.toString().padLeft(2, '0')}-${selector.day.toString().padLeft(2, '0')} 00.';
      expect(() => format.parseStrict('${prefix}1234567', selector, true),
          throwsFormatException);
      expect(format.parseStrict('${prefix}1234560', selector, true).microsecond,
          456);
      expect(format.parse('${prefix}1234567', selector, true).microsecond, 456);
      expect(
          () => GeneralDateFormat('yyyy-MM-dd SSSSSS SSSSSS').parseStrict(
              '${prefix.split(' ').first} 123456 123457', selector, true),
          throwsFormatException);
    });
  }
}
