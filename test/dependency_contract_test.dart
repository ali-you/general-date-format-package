@Tags(['critical'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  group('Corrected general_datetime dependency contract', () {
    test('Gregorian conversion uses the verified Umm al-Qura boundary', () {
      final native = DateTime.utc(2024, 12, 2, 12, 34, 56, 789, 321);
      final hijri = HijriDateTime.fromDateTime(native);

      expect((hijri.year, hijri.month, hijri.day), (1446, 6, 1));
      expect(hijri.isUtc, isTrue);
      expect(hijri.toDateTime(), native);
      expect(hijri.microsecond, 321);
      expect(GeneralDateFormat('yyyy-MM-dd MMMM', 'en').format(hijri),
          '1446-06-01 Jumada II');
    });

    test('Gregorian conversion produces valid fields for the reported date',
        () {
      final native = DateTime.utc(2026, 10, 3);
      final hijri = HijriDateTime.fromDateTime(native);

      expect(HijriDateTime.isValidDate(hijri.year, hijri.month, hijri.day),
          isTrue);
      expect(hijri.toDateTime(), native);
    });

    test('Hijri UTC parsing retains its exact native instant', () {
      final expected = HijriDateTime.utc(1446, 9, 1, 12, 34, 56, 789);
      final parsed = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSS')
          .parseStrict('1446-09-01 12:34:56.789', HijriDateTime(1440), true);

      expect(expected.isUtc, isTrue);
      expect(parsed, isA<HijriDateTime>());
      expect(parsed.isUtc, isTrue);
      expect(parsed, expected);
      expect(parsed.microsecondsSinceEpoch,
          DateTime.utc(2025, 3, 1, 12, 34, 56, 789).microsecondsSinceEpoch);
    });

    test('custom/native equality and hash keys are symmetric', () {
      final native = DateTime.utc(2024, 3, 20, 12, 34, 56, 789, 321);
      final dates = <DateTime>[
        PersianDateTime.fromDateTime(native),
        HijriDateTime.fromDateTime(native),
      ];

      for (final date in dates) {
        expect(date == native, isTrue);
        expect(native == date, isTrue);
        expect(date.hashCode, native.hashCode);
        expect(<DateTime, String>{date: 'event'}[native], 'event');
        expect(<DateTime, String>{native: 'event'}[date], 'event');
      }
    });

    test('finite chronology bounds reject unsupported Hijri dates', () {
      expect(HijriDateTime.minimumYear, 1300);
      expect(HijriDateTime.maximumYear, 1600);
      expect(() => HijriDateTime.utc(1299), throwsRangeError);
      expect(() => HijriDateTime.utc(1601), throwsRangeError);
    });
  });
}
