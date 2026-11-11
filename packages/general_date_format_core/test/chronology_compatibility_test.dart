import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  test('all supported chronologies preserve formatter reuse and exact instants',
      () {
    final native = DateTime.utc(2024, 3, 20, 12, 34, 56, 123, 457);
    final chinese = ChineseDateTime.fromDateTime(native);
    final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', 'en');

    final text = format.format(chinese);
    for (final parse in [
      format.parse,
      format.parseStrict,
      format.parseLoose,
      format.tryParse,
      format.tryParseStrict,
      format.tryParseLoose,
    ]) {
      expect(parse(text, chinese, true), chinese);
      for (final date in [
        chinese,
        PersianDateTime.fromDateTime(native),
        HijriDateTime.fromDateTime(native),
        HebrewDateTime.fromDateTime(native),
      ]) {
        final text = format.format(date);
        final parsed = format.parseStrict(text, date, true);
        expect(parsed.runtimeType, date.runtimeType);
        expect(parsed.toUtc().microsecondsSinceEpoch,
            native.microsecondsSinceEpoch);
      }
    }
  });
}
