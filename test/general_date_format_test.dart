import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  group(
    "Date (Year, Month, Day) Format Constructors Testing",
    () {
      test('Month and Day Constructors', () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11);
        String M = GeneralDateFormat.M().format(jalaliNow);
        String d = GeneralDateFormat.d().format(jalaliNow);
        String MMM = GeneralDateFormat.MMM().format(jalaliNow);
        String MMMM = GeneralDateFormat.MMMM().format(jalaliNow);
        String y = GeneralDateFormat.y().format(jalaliNow);
        expect(d, "11");
        expect(M, "2");
        expect(MMM, "Ord");
        expect(MMMM, "Ordibehesht");
        expect(y, "1400");
      });
      test('Month and Day Constructors With "fa" Locale', () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11);
        String M = GeneralDateFormat.M("fa").format(jalaliNow);
        String d = GeneralDateFormat.d("fa").format(jalaliNow);
        String MMM = GeneralDateFormat.MMM("fa").format(jalaliNow);
        String MMMM = GeneralDateFormat.MMMM("fa").format(jalaliNow);
        String y = GeneralDateFormat.y("fa").format(jalaliNow);
        expect(d, "۱۱");
        expect(M, "۲");
        expect(MMM, "ارد");
        expect(MMMM, "اردیبهشت");
        expect(y, "۱۴۰۰");
      });
    },
  );






















  group(
    "Format Testing",
    () {
      test('Test Year', () {
        JalaliDateTime jalaliNow = JalaliDateTime.now();
        String res = GeneralDateFormat("yyyy/MMMM/dd HH:mm EEEE", "fa")
            .format(jalaliNow);
        print(jalaliNow);
        print(res);
      });
      test('Test Conversion', () {
        JalaliDateTime jalaliNow = JalaliDateTime.fromDateTime(DateTime(1970));
        String res = GeneralDateFormat("yyyy/MMMM/dd HH:mm EEEE", "fa")
            .format(jalaliNow);
        print(jalaliNow);
        print(res);
      });
      test('Test Type Generics', () {
        GeneralDateTimeInterface generalDateTimeInterface =
            JalaliDateTime.fromDateTime(DateTime(1970));

        print(generalDateTimeInterface is HijriDateTime);
      });
    },
  );

  group("Challenging Format Tests", () {
    // Test conversion at Jalali year boundary (Nowruz)
    test('Nowruz Boundary Conversion', () {
      final gregorianNowruz = DateTime(2023, 3, 21);
      final jalali = JalaliDateTime.fromDateTime(gregorianNowruz);

      expect(jalali.year, 1402);
      expect(jalali.month, 1);
      expect(jalali.day, 1);

      final formatted =
          GeneralDateFormat("yyyy-MM-dd EEEE", "fa").format(jalali);
      expect(formatted, "۱۴۰۲-۰۱-۰۱ سه\u200cشنبه");
    });

    // Test last day of Esfand in leap year
    test('Leap Year Handling', () {
      final leapDate = JalaliDateTime(1403, 12, 30); // Esfand 1403 has 30 days
      final formatted = GeneralDateFormat("yyyy/MM/dd", "fa").format(leapDate);
      expect(formatted, "۱۴۰۳/۱۲/۳۰");
    });

    // Test formatting all date components
    test('Component Exhaustion', () {
      final date = JalaliDateTime(1402, 7, 15, 14, 45, 30, 500);
      final formatted = GeneralDateFormat(
              "yyyy/yy MMMM/MMM MM/M dd/d hh/h HH/H mm/m ss/s SSS/SS S a EEEE/EEE EE E",
              "en_ISO")
          .format(date);

      expect(formatted,
          "1402/02 Mehr/Meh 07/7 15/15 02/2 14/14 45/45 30/30 500/500 500/500 PM Saturday/Sat Sat Sat");
    });

    // Test invalid date handling
    test('Invalid Date Protection', () {
      expect(() => JalaliDateTime(1399, 13, 1), throwsA(isA<Exception>()));
      expect(() => JalaliDateTime(1400, 12, 30), throwsA(isA<Exception>()));
      expect(() => JalaliDateTime.fromDateTime(DateTime(1899, 1, 1)),
          throwsA(isA<Exception>()));
    });

    // Test calendar type detection
    test('Calendar Type Safety', () {
      final jalaliDate = JalaliDateTime.now();
      final hijriDate = HijriDateTime.now();

      expect(jalaliDate is HijriDateTime, isFalse);
      expect(hijriDate is HijriDateTime, isTrue);
      expect(() => GeneralDateFormat("yyyy", "fa").format(hijriDate),
          throwsA(isA<Exception>()));
    });

    // Test localized month names
    test('Localization Validation', () {
      final date = JalaliDateTime(1402, 1, 1);
      final persian = GeneralDateFormat("MMMM", "fa").format(date);
      final english = GeneralDateFormat("MMMM", "en_ISO").format(date);
      final spanish = GeneralDateFormat("MMMM", "es").format(date);

      expect(persian, "فروردین");
      expect(english, "Farvardin");
      expect(spanish, "Farvardín");
    });

    // Test daylight saving transition
    test('Daylight Saving Transition', () {
      final beforeDst = DateTime(2023, 9, 21, 23, 30); // Iran DST ends
      final afterDst = DateTime(2023, 9, 22, 0, 30);

      final jBefore = JalaliDateTime.fromDateTime(beforeDst);
      final jAfter = JalaliDateTime.fromDateTime(afterDst);

      expect(jBefore.hour, 23);
      expect(jAfter.hour, 0);
    });
  });

  group("Formatting Stress Tests", () {
    // Test full RTL formatting with Persian numerals
    test('Persian RTL Complexity', () {
      final date = JalaliDateTime(1402, 7, 15, 14, 45, 30, 500);
      final formatted =
          GeneralDateFormat("yyyy/MMMM/dd EEEE - HH:mm:ss.SSS a", "fa")
              .format(date);

      expect(formatted, "۱۴۰۲/مهر/۱۵ شنبه - ۱۴:۴۵:۳۰.۵۰۰ بعدازظهر");
    });

    // Test midnight/noon edge cases
    test('Time Extremes', () {
      final midnight = JalaliDateTime(1402, 1, 1, 0, 0);
      final noon = JalaliDateTime(1402, 1, 1, 12, 0);

      expect(
          GeneralDateFormat("h:mm a", "en_ISO").format(midnight), "12:00 AM");
      expect(GeneralDateFormat("HH:mm", "fa").format(noon), "۱۲:۰۰");
    });

    // Test month name localization collisions
    test('Localization Ambiguity', () {
      final date = JalaliDateTime(1402, 1, 1);
      expect(GeneralDateFormat("MMM", "es").format(date), "Far");
      expect(GeneralDateFormat("MMMM", "en_ISO").format(date), "Farvardin");
      expect(GeneralDateFormat("M", "fa").format(date), "۱");
    });

    // Test numeric formatting edge cases
    test('Numeric Padding', () {
      final date = JalaliDateTime(5, 3, 7, 3, 9);
      expect(GeneralDateFormat("yy/MM/dd hh:mm", "en_ISO").format(date),
          "05/03/07 03:09");
      expect(GeneralDateFormat("y/M/d H:m", "fa").format(date), "۵/۳/۷ ۳:۹");
    });

    // Test escape characters
    test('Format Literals', () {
      final date = JalaliDateTime(1402, 1, 1);
      expect(
          GeneralDateFormat("'Year:' yyyy 'at' HH:mm", "en_ISO").format(date),
          "Year: 1402 at 00:00");
      expect(GeneralDateFormat("'yyyy'", "fa").format(date), "yyyy");
    });

    // Test combined specifiers
    test('Specifier Combinations', () {
      final date = JalaliDateTime(1402, 12, 30, 23, 59);
      final format = "ddMMyyyyHHmmss";
      expect(GeneralDateFormat(format, "en_ISO").format(date), "301402235959");
    });

    // Test leap year formatting
    test('Leap Year Display', () {
      final leapDate = JalaliDateTime(1403, 12, 30);
      final nonLeapDate = JalaliDateTime(1402, 12, 29);

      expect(GeneralDateFormat("dd/MM", "fa").format(leapDate), "۳۰/۱۲");
      expect(GeneralDateFormat("dd/MM", "en_ISO").format(nonLeapDate), "29/12");
    });

    // Test weekday localization
    test('Weekday Variations', () {
      final date = JalaliDateTime(1402, 1, 1); // Saturday
      expect(GeneralDateFormat("EEEE", "fa").format(date), "شنبه");
      expect(GeneralDateFormat("EEE", "en_ISO").format(date), "Sat");
      expect(GeneralDateFormat("E", "es").format(date), "S");
    });

    // Test microsecond precision
    test('Fractional Seconds', () {
      final date = JalaliDateTime(1, 1, 1, 1, 1, 1, 1, 123456);
      expect(GeneralDateFormat("SSSSSS", "en_ISO").format(date), "123456");
      expect(GeneralDateFormat("SSS", "fa").format(date), "۱۲۳");
    });

    // Test timezone offsets
    test('Timezone Display', () {
      final date = JalaliDateTime.fromDateTime(
        DateTime.utc(2023, 3, 21, 19, 30),
      );
      expect(
          GeneralDateFormat("HH:mm Z", "en_ISO").format(date), "00:00 +04:30");
    });
  });
}
