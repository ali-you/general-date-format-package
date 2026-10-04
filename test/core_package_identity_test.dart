import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart' as flutter_api;
import 'package:general_date_format_core/general_date_format_core.dart' as core;
import 'package:general_datetime_core/general_datetime_core.dart';

void main() {
  test(
      'Flutter formatter uses the same type and accepts pure Dart calendar dates',
      () {
    expect(flutter_api.GeneralDateFormat, core.GeneralDateFormat);
    final date = PersianDateTime.utc(1403, 1, 1);
    expect(
        flutter_api.GeneralDateFormat('yyyy-MM-dd').format(date), '1403-01-01');
  });
}
