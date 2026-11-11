import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  final selector = ChineseDateTime.utc(2024);
  test('every supported year round trips named identity before the year token',
      () {
    for (final locale in ['en', 'zh', 'zh_TW']) {
      for (final field in ['MMM', 'MMMM', 'LLLL']) {
        final format = GeneralDateFormat('dd $field yyyy', locale);
        for (var year = 1901; year <= 2099; year++) {
          for (final month in ChineseDateTime.monthsOfYear(year)) {
            final date = ChineseDateTime.utc(
                year, month, ChineseDateTime.daysInMonth(year, month));
            final parsed =
                format.parseStrict(format.format(date), selector, true);
            expect(parsed, date, reason: '$locale $field $date');
            expect((parsed as ChineseDateTime).monthCode, date.monthCode);
          }
        }
      }
    }
  });

  test(
      'digit-ending month names leave adjacent fixed-width day and time tokens intact',
      () {
    for (final locale in ['en', 'fa', 'ko', 'zh']) {
      for (final field in ['MMM', 'MMMM', 'MMMMM', 'LLLLL']) {
        for (final month in [1, 2, 6, 7, 11, 12, 13]) {
          final date = ChineseDateTime.utc(2025, month, 12, 14, 5);
          for (final suffix in ['dd', 'ddHHmm']) {
            final format = GeneralDateFormat('yyyy $field$suffix', locale);
            final expected =
                suffix == 'dd' ? ChineseDateTime.utc(2025, month, 12) : date;
            final text = format.format(date);
            expect(format.parseStrict(text, selector, true), expected,
                reason: '$locale $field$suffix $text');
            expect(format.parseLoose(text, selector, true), expected);
          }
        }
      }
    }
  });

  test('strict redundant tokens reject regular/leap conflicts in every order',
      () {
    final date = ChineseDateTime.utc(2025, 7, 10);
    for (final pattern in [
      'yyyy MM MMMM dd',
      'MMMM dd yyyy MM',
      'MM dd yyyy MMMM',
      'MMMM yyyy dd MMMM',
      'yyyy D MMMM MM dd EEEE'
    ]) {
      final format = GeneralDateFormat(pattern, 'en');
      final input = format.format(date);
      expect(format.parseStrict(input, selector, true), date);
      expect(
          format.tryParseStrict(
              input.replaceFirst('Sixth Monthbis', 'Sixth Month'),
              selector,
              true),
          isNull,
          reason: '$pattern $input');
    }
    for (final pattern in ['yyyy D MMMM', 'yyyy MMMM D']) {
      final format = GeneralDateFormat(pattern, 'en');
      final input = format.format(date);
      expect(format.parseStrict(input, selector, true), date);
      expect(
          format.tryParseStrict(
              input.replaceFirst('Sixth Monthbis', 'Seventh Month'),
              selector,
              true),
          isNull);
    }
    final ordinal = GeneralDateFormat('yyyy D', 'en');
    for (final input in ['2024 0', '2024 355', '2025 385']) {
      expect(ordinal.tryParseStrict(input, selector, true), isNull);
    }
  });

  test(
      'all locale digit modes preserve leap identity after failed calendar reuse',
      () {
    final leap = ChineseDateTime.utc(2025, 7, 29, 23, 59, 58, 123, 987);
    for (final locale in GeneralDateFormat.allLocalesWithSymbols()) {
      for (final native in [false, true]) {
        final format =
            GeneralDateFormat('yyyy MM MMMM dd HH:mm:ss.SSSSSS', locale)
              ..useNativeDigits = native;
        for (final date in [
          leap,
          PersianDateTime.utc(1403, 1, 1),
          HebrewDateTime.utc(5784, 6, 1),
          HijriDateTime.utc(1445),
          leap
        ]) {
          final text = format.format(date);
          expect(format.tryParseStrict('invalid input', date, true), isNull);
          expect(format.parseStrict(text, date, true), date,
              reason: '$locale nativeDigits=$native ${date.runtimeType}');
        }
      }
    }
  });

  test(
      'two-digit related years resolve a leap identity and sample one clock reading',
      () {
    for (final pattern in ['dd MMMM yy', 'yy MM MMMM dd']) {
      var reads = 0;
      final format = GeneralDateFormat(pattern, 'en')
        ..now = () {
          reads++;
          return DateTime.utc(2025, 8);
        };
      final leap = ChineseDateTime.utc(2025, 7, 10);
      expect(format.parseStrict(format.format(leap), selector, true), leap);
      expect(reads, 1);
    }
    final format = GeneralDateFormat('yy-MM-dd', 'en')
      ..now = () => DateTime.utc(2025, 8);
    expect(format.parseStrict('25-07-10', selector, true),
        ChineseDateTime.utc(2025, 7, 10));
    expect(format.tryParseStrict('-25-07-10', selector, true), isNull);
    expect(
        GeneralDateFormat('yyyy-MM-dd', 'en')
            .tryParseStrict('25-07-10', selector, true),
        isNull);
  });

  test(
      'compact numeric fractions truncate explicitly and never consume the following field',
      () {
    for (var width = 1; width <= 9; width++) {
      final retained = width < 3
          ? 3
          : width > 6
              ? 6
              : width;
      final factor = [1000000, 100000, 10000, 1000, 100, 10, 1][retained];
      for (final locale in ['en', 'fa', 'ar']) {
        final format =
            GeneralDateFormat("yyyyMMddHHmmss${'S' * width}mm", locale);
        final date = ChineseDateTime.utc(2025, 7, 29, 23, 59, 58, 123, 987);
        final expected = date.subtract(Duration(microseconds: 123987 % factor));
        expect(
            format.parseStrict(format.format(date), selector, true), expected);
      }
    }
  });
}
