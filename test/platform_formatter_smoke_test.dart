import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  test('portable pair formats native digits and retains six fractional digits',
      () {
    final date = PersianDateTime.utc(1403, 1, 1, 12, 34, 56, 123, 456);
    final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', 'fa');
    final text = format.format(date);
    expect(text, '۱۴۰۳-۰۱-۰۱ ۱۲:۳۴:۵۶.۱۲۳۴۵۶');
    expect(format.parseStrict(text, date, true).microsecondsSinceEpoch,
        DateTime.utc(2024, 3, 20, 12, 34, 56, 123, 456).microsecondsSinceEpoch);
    expect(GeneralDateFormat('EEEE', 'sr_Latn_RS').format(date), 'sreda');
    final hebrew = HebrewDateTime.utc(5784, 7, 10, 12, 34, 56, 123, 456);
    final hebrewText = format.format(hebrew);
    expect(hebrewText, '۵۷۸۴-۰۷-۱۰ ۱۲:۳۴:۵۶.۱۲۳۴۵۶');
    expect(format.parseStrict(hebrewText, hebrew, true), hebrew);
    expect(
        GeneralDateFormat('d MMMM y', 'he').format(hebrew), '10 אדר ב׳ 5784');
    for (final year in [1600, 2300, 6000]) {
      final native = DateTime.utc(year, 3, 20, 12, 34, 56, 123, 1);
      for (final date in [
        HebrewDateTime.fromDateTime(native),
        if (PersianDateTime.isSupportedDateTime(native))
          PersianDateTime.fromDateTime(native),
      ]) {
        final input = format.format(date);
        final parsed = format.parseStrict(input, date, true);
        expect(parsed.microsecond, 1);
        expect(parsed, native);
        expect(CalendarDateUtils.toGregorian(parsed), native);
      }
    }
  });
}
