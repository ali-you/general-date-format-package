import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  test('Chinese rejection preserves supported calendar round trips', () {
    final native = DateTime.utc(2024, 3, 20, 12, 34, 56, 123, 457);
    final chinese = ChineseDateTime.fromDateTime(native);
    final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', 'en');

    final unsupportedOperations = <Object? Function()>[
      () => format.format(chinese),
      () => format.parse('2024-01-01', chinese),
      () => format.parseStrict('2024-01-01', chinese),
      () => format.parseLoose('2024-01-01', chinese),
      () => format.tryParse('2024-01-01', chinese),
      () => format.tryParseStrict('2024-01-01', chinese),
      () => format.tryParseLoose('2024-01-01', chinese),
      () => format.tryParseUtc('2024-01-01', chinese),
    ];
    for (final operation in unsupportedOperations) {
      expect(operation, throwsUnsupportedError);
      for (final date in [
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
