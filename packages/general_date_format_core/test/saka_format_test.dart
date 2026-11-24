import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  test('round trips Saka month names, era, and native Hindi digits', () {
    final date = SakaDateTime.utc(1948, 1, 1);
    final english = GeneralDateFormat('d MMMM y G', 'en');
    final hindi = GeneralDateFormat('d MMMM y G', 'hi');
    expect(english.format(date), '1 Chaitra 1948 Śaka');
    expect(hindi.format(date), '१ चैत्र १९४८ शक');
    expect(english.parseStrict(english.format(date), date, true), date);
    expect(hindi.parseStrict(hindi.format(date), date, true), date);
    hindi.useNativeDigits = false;
    expect(hindi.format(date), '1 चैत्र 1948 शक');
    expect(hindi.parseStrict(hindi.format(date), date, true), date);
  });

  test('strict parsing validates Chaitra and loose parsing normalizes it', () {
    final format = GeneralDateFormat('yyyy-MM-dd', 'en');
    final selector = SakaDateTime.utc(1948);
    expect(format.parseStrict('1946-01-31', selector, true),
        SakaDateTime.utc(1946, 1, 31));
    expect(() => format.parseStrict('1948-01-31', selector, true),
        throwsFormatException);
    expect(
        format.parse('1948-01-31', selector, true), SakaDateTime.utc(1948, 2));
    expect(format.format(PersianDateTime.utc(1405, 1, 2)), '1405-01-02');
    expect(format.format(selector), '1948-01-01');
  });

  test('narrow numeric month names reserve adjacent fixed-width fields', () {
    for (final locale in ['en', 'hi']) {
      for (final monthField in ['MMMMM', 'LLLLL']) {
        for (final pattern in [
          'yyyy${monthField}dd',
          '${monthField}ddyyyy',
          'dd${monthField}yyyy',
          '${monthField}ccyyyy-MM-dd',
          "yyyy $monthField'0'dd",
        ]) {
          final format = GeneralDateFormat(pattern, locale);
          for (final year in [1, 1948, 9920]) {
            for (final month in [1, 2, 10, 11, 12]) {
              for (final day in [1, 10, 21]) {
                final date = SakaDateTime.utc(year, month, day);
                final text = format.format(date);
                final reason = '$locale $pattern $text';
                expect(format.parseStrict(text, date, true), date,
                    reason: reason);
                expect(format.parseLoose(text, date, true), date,
                    reason: reason);
              }
            }
          }
        }
      }
    }
  });

  test('ambiguous variable-width fields need a separator by a narrow month',
      () {
    final date = SakaDateTime.utc(1948, 1, 1);
    for (final pattern in [
      'yMMMMMdd',
      'MMMMMddyyy',
      'yyyyMMMMMd',
      "MMMMM'0'yyy",
    ]) {
      final format = GeneralDateFormat(pattern, 'en');
      final text = format.format(date);
      expect(format.tryParseStrict(text, date, true), isNull, reason: pattern);
      expect(format.tryParseLoose(text, date, true), isNull, reason: pattern);
    }
    final separated = GeneralDateFormat('y-MMMMM-d', 'en');
    expect(separated.parseStrict('1948-1-1', date, true), date);
  });
}
