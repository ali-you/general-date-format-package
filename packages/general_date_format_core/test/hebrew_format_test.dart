import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  final selector = HebrewDateTime.utc(5784);

  test('English and Hebrew names distinguish both Adars and the AM era', () {
    final format = GeneralDateFormat('d MMMM y G', 'en');
    expect(format.format(HebrewDateTime.utc(5784, 6)), '1 Adar I 5784 AM');
    expect(format.format(HebrewDateTime.utc(5784, 7)), '1 Adar II 5784 AM');
    expect(format.format(HebrewDateTime.utc(5785, 7)), '1 Adar 5785 AM');
    expect(format.format(HebrewDateTime.utc(5785, 13)), '1 Elul 5785 AM');
    final hebrew = GeneralDateFormat('d MMMM y', 'he');
    expect(hebrew.format(HebrewDateTime.utc(5784, 6)), '1 אדר א׳ 5784');
    expect(hebrew.format(HebrewDateTime.utc(5784, 7)), '1 אדר ב׳ 5784');
    expect(hebrew.format(HebrewDateTime.utc(5785, 7)), '1 אדר 5785');
  });

  test('month names preceding the year validate against the input year', () {
    final format = GeneralDateFormat('d MMMM yyyy', 'en');
    expect(format.parseStrict('1 Adar II 5784', HebrewDateTime(5785), true),
        HebrewDateTime.utc(5784, 7));
    expect(format.parseStrict('1 Adar 5785', selector, true),
        HebrewDateTime.utc(5785, 7));
    for (final input in ['1 Adar I 5785', '1 Adar II 5785']) {
      expect(format.tryParseStrict(input, selector), isNull);
      expect(format.tryParseLoose(input.toLowerCase(), selector), isNull);
      expect(format.tryParse(input, selector), isNull);
    }
    expect(format.parseLoose('1 aDaR   ii 5784', selector, true),
        HebrewDateTime.utc(5784, 7));
  });

  test('all locales round trip actual month slots and leap names', () {
    for (final locale in GeneralDateFormat.allLocalesWithSymbols()) {
      for (final field in ['MMMM', 'MMM', 'LLLL', 'LLL', 'MM', 'LL']) {
        final format =
            GeneralDateFormat('yyyy $field dd HH:mm:ss.SSSSSS', locale);
        for (final year in [5784, 5785]) {
          for (final month in HebrewDateTime.monthsOfYear(year)) {
            final date = HebrewDateTime.utc(year, month,
                HebrewDateTime.daysInMonth(year, month), 12, 34, 56, 123, 456);
            final input = format.format(date);
            final actual = format.parseStrict(input, selector, true);
            expect(actual, date, reason: '$locale $field $input');
            expect(actual.microsecondsSinceEpoch, date.microsecondsSinceEpoch);
            expect(actual, isA<HebrewDateTime>());
            expect(format.parseLoose(input, selector, true), date,
                reason: 'loose $locale $field $input');
          }
        }
      }
    }
  });

  test('narrow names preserve all candidates until numeric fields disambiguate',
      () {
    for (final locale in ['en', 'he', 'ar', 'fa']) {
      for (final field in ['MMMMM', 'LLLLL']) {
        final format = GeneralDateFormat('yyyy MM $field dd', locale);
        for (final year in [5784, 5785]) {
          for (final month in HebrewDateTime.monthsOfYear(year)) {
            final date = HebrewDateTime.utc(year, month, 1);
            expect(
                format.parseStrict(format.format(date), selector, true), date,
                reason: '$locale $field $year $month');
          }
        }
      }
    }
  });

  test('strict numeric dates reject absent slots and invalid month lengths',
      () {
    final format = GeneralDateFormat('yyyy-MM-dd', 'en');
    for (final input in [
      '5785-06-01',
      '5784-14-01',
      '5784-00-01',
      '5785-07-30',
      '0000-01-01',
      '10000-01-01',
      '5784-07-01junk'
    ]) {
      expect(format.tryParseStrict(input, selector), isNull, reason: input);
    }
    expect(format.parseStrict('5784-13-29', selector, true),
        HebrewDateTime.utc(5784, 13, 29));
    expect(format.parse('5785-05-31', selector, true),
        HebrewDateTime.utc(5785, 7));
    expect(format.parseStrict('0001-01-01', selector, true),
        HebrewDateTime.utc(1));
    expect(format.parseStrict('9999-13-29', selector, true),
        HebrewDateTime.utc(9999, 13, 29));
  });

  test('ordinal, weekday and era tokens validate redundant fields', () {
    final date = HebrewDateTime.utc(5784, 7, 10);
    final format = GeneralDateFormat('yyyy-MM-dd D EEEE G', 'en');
    expect(format.parseStrict(format.format(date), selector, true), date);
    final ordinal = GeneralDateFormat('yyyy D', 'en');
    expect(ordinal.parseStrict('5784 ${date.dayOfYear}', selector, true), date);
    expect(ordinal.tryParseStrict('5785 356', selector, true), isNull);
    expect(
        GeneralDateFormat('yyyy D MMMM', 'en')
            .tryParseStrict('5785 157 Adar II', selector, true),
        isNull);
    for (final name in ['Adar I', 'Adar II']) {
      expect(
          GeneralDateFormat('yyyy D MMMM', 'en')
              .tryParse('5785 157 $name', selector, true),
          isNull);
    }
    expect(
        GeneralDateFormat('yyyy-MM-dd EEEE', 'en')
            .tryParseStrict('5784-07-10 Thursday', selector),
        isNull);
  });

  test('native digits and formatter reuse preserve calendar and UTC mode', () {
    final native = DateTime.utc(2024, 3, 20, 12, 34, 56, 123, 456);
    for (final locale in ['fa', 'ar', 'he', 'en']) {
      final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', locale);
      for (final date in [
        HebrewDateTime.fromDateTime(native),
        PersianDateTime.fromDateTime(native),
        HijriDateTime.fromDateTime(native),
        HebrewDateTime.fromDateTime(native),
        HebrewDateTime.fromDateTime(native.toLocal())
      ]) {
        final input = format.format(date);
        expect(format.parseStrict(input, date, date.isUtc), date);
      }
      format.useNativeDigits = false;
      final date = HebrewDateTime.fromDateTime(native);
      expect(format.format(date), '5784-07-10 12:34:56.123456');
    }
  });

  test('two digit years use a Hebrew century window and leap-name constraints',
      () {
    var calls = 0;
    final format = GeneralDateFormat('d MMMM yy', 'en')
      ..now = () {
        calls++;
        return HebrewDateTime.utc(5785, 1, 1).toDateTime();
      };
    expect(format.parseStrict('1 Adar II 84', selector, true),
        HebrewDateTime.utc(5784, 7));
    expect(calls, 1);
    expect(format.tryParseStrict('1 Adar II 85', selector, true), isNull);
    expect(format.parseStrict('1 Nisan 85', selector, true),
        HebrewDateTime.utc(5785, 8));
  });

  test('quarter fields fail explicitly for Hebrew and retain other calendars',
      () {
    for (final pattern in ['Q', 'QQQ', 'QQQQ', 'yQQQ', 'yQQQQ']) {
      final format = GeneralDateFormat(pattern, 'en');
      expect(() => format.format(HebrewDateTime.utc(5784, 13)),
          throwsUnsupportedError);
      expect(() => format.parse('1', selector), throwsUnsupportedError);
      expect(() => format.parseStrict('1', selector), throwsUnsupportedError);
      expect(format.format(PersianDateTime.utc(1403, 10)), isNotEmpty);
    }
    final literal = GeneralDateFormat("'Q' yyyy-MM-dd", 'en');
    expect(literal.format(selector), 'Q 5784-01-01');
    expect(literal.parseStrict('Q 5784-01-01', selector, true), selector);
  });
}
