import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  group("Format Tests", () {
    test('Test Year', () {
      JalaliDateTime jalaliNow = JalaliDateTime.now();
      String res = GeneralDateFormat("yyyy/MMMM/dd HH:mm EEEE", "fa").format(jalaliNow);
      print(jalaliNow);
      print(res);
    });
  },);
}
