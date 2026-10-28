import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  final selector = ChineseDateTime.utc(2024);
  test('numeric year and day fields bound digit-leading Chinese month names',
      () {
    for (final locale in GeneralDateFormat.allLocalesWithSymbols()) {
      for (final field in ['MMM', 'MMMM', 'MMMMM', 'LLL', 'LLLL', 'LLLLL']) {
        for (final month in [1, 2, 6, 7, 11, 12, 13]) {
          final date = ChineseDateTime.utc(2025, month, 12);
          for (final pattern in ['yyyy${field}dd', 'yyyy dd$field']) {
            final format = GeneralDateFormat(pattern, locale);
            final text = format.format(date);
            expect(format.parseStrict(text, selector, true), date,
                reason: '$locale $pattern $text');
          }
        }
      }
    }
  });

  test('quoted numeric literals disambiguate month-name prefixes', () {
    for (final field in ['MMM', 'MMMMM', 'LLL', 'LLLLL']) {
      for (final digit in ['0', '1', '9']) {
        final format = GeneralDateFormat("yyyy $field'$digit' dd", 'en');
        for (final month in [1, 2, 6, 7, 10, 11, 12, 13]) {
          final date = ChineseDateTime.utc(2025, month, 12);
          final text = format.format(date);
          expect(format.parseStrict(text, selector, true), date,
              reason: '${format.pattern} $text');
          expect(format.parseLoose(text.toUpperCase(), selector, true), date);
        }
      }
    }
  });

  test('loose fallback preserves narrow Chinese names and leap markers', () {
    for (final locale in GeneralDateFormat.allLocalesWithSymbols()) {
      for (final field in ['MMMMM', 'LLLLL']) {
        final format = GeneralDateFormat('yyyy $field dd', locale);
        for (final year in [2024, 2025, 2033]) {
          for (final month in ChineseDateTime.monthsOfYear(year)) {
            final date = ChineseDateTime.utc(year, month, 12);
            final input =
                format.format(date).toUpperCase().replaceAll(' ', '   ');
            expect(format.parseLoose(input, selector, true), date,
                reason: '$locale $field $input');
          }
        }
      }
    }
  });

  test(
      'loose narrow patterns retain full and abbreviated name fallback across calendars',
      () {
    for (final date in [
      ChineseDateTime.utc(2025, 7, 12),
      PersianDateTime.utc(1403, 1, 12),
      HijriDateTime.utc(1445, 9, 12),
      HebrewDateTime.utc(5784, 6, 12)
    ]) {
      for (final prefix in ['M', 'L']) {
        final narrow = GeneralDateFormat('yyyy ${prefix * 5} dd', 'en');
        for (final width in [3, 4]) {
          final full = GeneralDateFormat('yyyy ${prefix * width} dd', 'en');
          final input = full.format(date).toUpperCase().replaceAll(' ', '   ');
          expect(narrow.parseLoose(input, date, true), date,
              reason: '${date.runtimeType} $input');
        }
      }
    }
  });
}
