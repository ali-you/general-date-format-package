import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  final persian = PersianDateTime.utc(1403, 9, 29, 12, 34, 56, 123, 456);
  final hijri = HijriDateTime.utc(1446, 9, 29, 12, 34, 56, 123, 456);
  final hebrew = HebrewDateTime.utc(5784, 7, 29, 12, 34, 56, 123, 456);

  test('Hebrew month and digit caches do not leak into existing calendars', () {
    for (final locale in GeneralDateFormat.allLocalesWithSymbols()) {
      for (final nativeDigits in [true, false]) {
        for (final monthPattern in ['MMMM', 'LLLL', 'MMMMM', 'LLLLL']) {
          final pattern = 'yyyy-MM-dd $monthPattern G EEEE HH:mm:ss.SSSSSS';
          final reused = GeneralDateFormat(pattern, locale)
            ..useNativeDigits = nativeDigits;
          for (final date in [persian, hebrew, hijri, hebrew, persian, hijri]) {
            final fresh = GeneralDateFormat(pattern, locale)
              ..useNativeDigits = nativeDigits;
            final text = fresh.format(date);
            expect(reused.format(date), text,
                reason: '$locale $nativeDigits $pattern ${date.runtimeType}');
            final parsed = reused.parseStrict(text, date, true);
            expect(parsed.runtimeType, date.runtimeType);
            expect(parsed, date);
          }
        }
      }
    }
  });

  test('failed Hebrew leap-month parsing leaves Persian and Hijri usable', () {
    final format = GeneralDateFormat('yyyy MMMM dd', 'en');
    for (final date in [persian, hijri]) {
      expect(format.tryParseStrict('5785 Adar II 01', hebrew, true), isNull);
      final text = GeneralDateFormat('yyyy MMMM dd', 'en').format(date);
      expect(format.format(date), text);
      expect(format.parseStrict(text, date, true),
          CalendarDateUtils.dateOnly(date));
      expect(format.parseLoose(text.toUpperCase(), date, true),
          CalendarDateUtils.dateOnly(date));
    }
  });

  test('Hebrew month 13 never enables month 13 in Persian or Hijri', () {
    final format = GeneralDateFormat('yyyy-MM-dd', 'en');
    expect(format.parseStrict('5784-13-29', hebrew, true),
        HebrewDateTime.utc(5784, 13, 29));
    for (final date in [persian, hijri]) {
      expect(format.tryParseStrict('${date.year}-13-01', date, true), isNull);
      expect(
          format.parse('${date.year}-13-01', date, true),
          CalendarDateUtils.copyWith(CalendarDateUtils.dateOnly(date),
              year: date.year + 1, month: 1, day: 1));
    }
  });

  test('Hebrew quarter rejection leaves both existing quarter parsers usable',
      () {
    for (final pattern in ['yyyy Q', 'yyyy QQQ', 'yyyy QQQQ']) {
      final reused = GeneralDateFormat(pattern, 'en');
      for (final date in [persian, hijri]) {
        expect(() => reused.format(hebrew), throwsUnsupportedError);
        expect(() => reused.parseStrict('5784 1', hebrew, true),
            throwsUnsupportedError);
        final fresh = GeneralDateFormat(pattern, 'en');
        final text = fresh.format(date);
        expect(reused.format(date), text);
        expect(reused.parseStrict(text, date, true),
            fresh.parseStrict(text, date, true));
        expect(
            reused.parseStrict(text, date, true).runtimeType, date.runtimeType);
      }
    }
  });

  test('two-digit year windows remain calendar-specific after Hebrew reuse',
      () {
    final reused = GeneralDateFormat('yy MMMM dd', 'en')
      ..now = () => DateTime.utc(2025, 3, 20);
    for (final date in [hebrew, persian, hebrew, hijri, persian]) {
      final fresh = GeneralDateFormat('yy MMMM dd', 'en')
        ..now = () => DateTime.utc(2025, 3, 20);
      final text = fresh.format(date);
      expect(reused.format(date), text);
      expect(reused.parseStrict(text, date, true),
          CalendarDateUtils.dateOnly(date));
    }
  });
}
