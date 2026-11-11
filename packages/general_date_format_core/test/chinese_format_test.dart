import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  final selector = ChineseDateTime.utc(2024);
  test('CLDR names distinguish regular and leap months before parsing the year',
      () {
    final format = GeneralDateFormat('d MMMM yyyy', 'en');
    final leap = ChineseDateTime.utc(2025, 7);
    expect(format.format(leap), '1 Sixth Monthbis 2025');
    expect(format.format(ChineseDateTime.utc(2025, 6)), '1 Sixth Month 2025');
    expect(format.parseStrict('1 Sixth Monthbis 2025', selector, true), leap);
    expect(format.parseStrict('1 Seventh Month 2025', selector, true),
        ChineseDateTime.utc(2025, 8));
    expect(format.tryParseStrict('1 Sixth Monthbis 2024', selector), isNull);
    expect(format.tryParseLoose('1 sixth monthbis 2024', selector), isNull);
    expect(format.parseLoose('1 sixth monthbis 2025', selector, true), leap);
    final zh = GeneralDateFormat('yyyy MMMM d', 'zh');
    expect(zh.format(leap), '2025 闰六月 1');
    expect(zh.parseStrict(zh.format(leap), selector, true), leap);
  });

  test(
      'every locale round trips ordinal and named months in both year structures',
      () {
    for (final locale in GeneralDateFormat.allLocalesWithSymbols()) {
      for (final field in ['MMM', 'MMMM', 'MMMMM', 'LLL', 'LLLL', 'LLLLL']) {
        final format = GeneralDateFormat('yyyy MM $field dd', locale);
        for (final year in [2024, 2025, 2033]) {
          for (final month in ChineseDateTime.monthsOfYear(year)) {
            final date = ChineseDateTime.utc(
                year, month, ChineseDateTime.daysInMonth(year, month));
            expect(
                format.parseStrict(format.format(date), selector, true), date,
                reason: '$locale $field $year $month');
          }
        }
      }
    }
  });

  test(
      'ordinal numeric fields, strict conflicts, year bounds and unsupported patterns',
      () {
    final numeric = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', 'en');
    final date = ChineseDateTime.utc(2025, 7, 1, 12, 34, 56, 123, 456);
    expect(numeric.parseStrict(numeric.format(date), selector, true), date);
    final mixed = GeneralDateFormat('yyyy MM MMMM dd', 'en');
    expect(mixed.tryParseStrict('2025 06 Sixth Monthbis 01', selector), isNull);
    expect(mixed.parseStrict('2025 07 Sixth Monthbis 01', selector, true),
        ChineseDateTime.utc(2025, 7));
    final format = GeneralDateFormat('yyyy-MM-dd', 'en');
    for (final input in [
      '1900-01-01',
      '2100-01-01',
      '2024-13-01',
      '2025-07-30'
    ]) {
      expect(format.tryParseStrict(input, selector), isNull);
    }
    for (final pattern in ['y Q', 'y G']) {
      expect(() => GeneralDateFormat(pattern, 'en').format(date),
          throwsUnsupportedError);
      expect(
          () =>
              GeneralDateFormat(pattern, 'en').parseStrict('2025 1', selector),
          throwsUnsupportedError);
    }
  });

  test(
      'reusing a formatter across calendars resets month symbols and parsing state',
      () {
    final format = GeneralDateFormat('yyyy MM MMMM dd', 'fa');
    for (final date in [
      ChineseDateTime.utc(2025, 7),
      PersianDateTime.utc(1403),
      HebrewDateTime.utc(5784, 6),
      HijriDateTime.utc(1445),
      ChineseDateTime.utc(2025, 8)
    ]) {
      expect(format.parseStrict(format.format(date), date, true), date);
    }
    final ordinal = GeneralDateFormat('yyyy D', 'en');
    final last = ChineseDateTime.utc(2025, 13, 29);
    expect(ordinal.parseStrict(ordinal.format(last), selector, true), last);
  });
}
