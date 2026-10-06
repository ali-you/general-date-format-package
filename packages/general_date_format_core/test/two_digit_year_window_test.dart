import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  for (final utc in [false, true]) {
    DateTime hijri(int year) =>
        utc ? HijriDateTime.utc(year) : HijriDateTime(year);
    DateTime persian(int year) =>
        utc ? PersianDateTime.utc(year) : PersianDateTime(year);

    test('Hijri provisional year beyond bounds resolves in the window utc=$utc',
        () {
      final format = GeneralDateFormat('yy-MM-dd')
        ..now = () => (hijri(1580) as HijriDateTime).toDateTime();
      final selector = hijri(1445);
      for (final parse in [
        format.parse,
        format.parseStrict,
        format.parseLoose
      ]) {
        expect(parse('99-01-01', selector, utc), hijri(1599));
      }
    });

    test('window endpoint can lie beyond either calendar bound utc=$utc', () {
      final hijriFormat = GeneralDateFormat('yy-MM-dd')
        ..now = () => (hijri(1590) as HijriDateTime).toDateTime();
      expect(hijriFormat.tryParseStrict('90-01-01', hijri(1445), utc),
          hijri(1590));
      final persianFormat = GeneralDateFormat('yy-MM-dd')
        ..now = () => (persian(3160) as PersianDateTime).toDateTime();
      expect(persianFormat.parseStrict('77-01-01', persian(1403), utc),
          persian(3177));
      expect(
          persianFormat.tryParseStrict('80-01-01', persian(1403), utc), isNull);
    });

    test('negative Persian centuries stay within the actual window utc=$utc',
        () {
      final format = GeneralDateFormat('yy-MM-dd')
        ..now = () => (persian(-40) as PersianDateTime).toDateTime();
      expect(format.parseStrict('50-01-01', persian(1403), utc), persian(-50));
      expect(format.tryParseStrict('99-01-01', persian(1403), utc), isNull);
      expect(format.tryParseLoose('99-01-01', persian(1403), utc), isNull);
      expect(() => format.parse('99-01-01', persian(1403), utc),
          throwsFormatException);
      format.now = () => (persian(-20) as PersianDateTime).toDateTime();
      expect(format.parseStrict('99-01-01', persian(1403), utc), persian(-1));
    });

    for (final pattern in ['yy yyyy-MM-dd', 'yyyy yy-MM-dd']) {
      test('repeated years retain nullable contracts $pattern utc=$utc', () {
        var calls = 0;
        final format = GeneralDateFormat(pattern)
          ..now = () {
            calls++;
            return (hijri(1580) as HijriDateTime).toDateTime();
          };
        final input =
            pattern.startsWith('yy ') ? '99 1599-01-01' : '1599 99-01-01';
        expect(format.tryParseStrict(input, hijri(1445), utc), hijri(1599));
        expect(calls, 1);
        final conflict =
            pattern.startsWith('yy ') ? '99 1598-01-01' : '1598 99-01-01';
        expect(format.tryParseStrict(conflict, hijri(1445), utc), isNull);
        expect(format.tryParseLoose(conflict, hijri(1445), utc), isNull);
        expect(() => format.parseStrict(conflict, hijri(1445), utc),
            throwsFormatException);
      });
    }
  }

  test('century cutoff compares all clock fields including microseconds', () {
    final format = GeneralDateFormat('yy-MM-dd HH:mm:ss.SSSSSS')
      ..now = () =>
          HijriDateTime.utc(1580, 1, 1, 12, 30, 45, 123, 456).toDateTime();
    final selector = HijriDateTime.utc(1445);
    expect(format.parseStrict('00-01-01 12:30:45.123456', selector, true),
        HijriDateTime.utc(1600, 1, 1, 12, 30, 45, 123, 456));
    expect(format.parseStrict('00-01-01 12:30:45.123457', selector, true),
        HijriDateTime.utc(1500, 1, 1, 12, 30, 45, 123, 457));
  });

  test('ordinal and overflow dates are compared after calendar normalization',
      () {
    final selector = PersianDateTime.utc(1403);
    final ordinal = GeneralDateFormat('yy D')
      ..now = () => PersianDateTime.utc(1404, 3, 25).toDateTime();
    expect(ordinal.parseStrict('24 200', selector, true),
        PersianDateTime.utc(1324, 1, 200));
    final overflow = GeneralDateFormat('yy-MM-dd')..now = ordinal.now;
    expect(overflow.parse('24-02-99', selector, true),
        PersianDateTime.utc(1324, 2, 99));
  });

  test('unsupported clock reference does not leak range errors for repetitions',
      () {
    final format = GeneralDateFormat('yy yyyy-MM-dd')
      ..now = () => DateTime.utc(2500);
    expect(
        format.tryParseStrict('45 1445-01-01', HijriDateTime.utc(1445), true),
        isNull);
    expect(
        () =>
            format.parseStrict('45 1445-01-01', HijriDateTime.utc(1445), true),
        throwsFormatException);
  });
}
