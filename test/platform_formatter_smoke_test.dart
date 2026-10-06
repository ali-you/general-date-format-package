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
  });
}
