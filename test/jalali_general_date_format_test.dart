import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  group(
    "Date (Year, Month, Day, Week, Quarter) Format Constructors Testing",
    () {
      test('Month and Day Constructors', () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11);
        String M = GeneralDateFormat.M().format(jalaliNow);
        String d = GeneralDateFormat.d().format(jalaliNow);
        String MMM = GeneralDateFormat.MMM().format(jalaliNow);
        String MMMM = GeneralDateFormat.MMMM().format(jalaliNow);
        String y = GeneralDateFormat.y().format(jalaliNow);
        String E = GeneralDateFormat.E().format(jalaliNow);
        String EEEE = GeneralDateFormat.EEEE().format(jalaliNow);
        String EEEEE = GeneralDateFormat.EEEEE().format(jalaliNow);
        String LLL = GeneralDateFormat.LLL().format(jalaliNow);
        String LLLL = GeneralDateFormat.LLLL().format(jalaliNow);
        String QQQ = GeneralDateFormat.QQQ().format(jalaliNow);
        String QQQQ = GeneralDateFormat.QQQQ().format(jalaliNow);
        expect(d, "11");
        expect(M, "2");
        expect(MMM, "Ord");
        expect(MMMM, "Ordibehesht");
        expect(LLL, "Ord");
        expect(LLLL, "Ordibehesht");
        expect(y, "1400");
        expect(E, "Sat");
        expect(EEEE, "Saturday");
        expect(EEEEE, "S");
        expect(QQQ, "Q1");
        expect(QQQQ, "1st quarter");
      });
      test('Month and Day Constructors With "fa" Locale', () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11);
        String M = GeneralDateFormat.M("fa").format(jalaliNow);
        String d = GeneralDateFormat.d("fa").format(jalaliNow);
        String MMM = GeneralDateFormat.MMM("fa").format(jalaliNow);
        String MMMM = GeneralDateFormat.MMMM("fa").format(jalaliNow);
        String y = GeneralDateFormat.y("fa").format(jalaliNow);
        String E = GeneralDateFormat.E("fa").format(jalaliNow);
        String EEEE = GeneralDateFormat.EEEE("fa").format(jalaliNow);
        String EEEEE = GeneralDateFormat.EEEEE("fa").format(jalaliNow);
        String LLL = GeneralDateFormat.LLL("fa").format(jalaliNow);
        String LLLL = GeneralDateFormat.LLLL("fa").format(jalaliNow);
        String QQQ = GeneralDateFormat.QQQ("fa").format(jalaliNow);
        String QQQQ = GeneralDateFormat.QQQQ("fa").format(jalaliNow);
        expect(d, "۱۱");
        expect(M, "۲");
        expect(MMM, "ارد");
        expect(MMMM, "اردیبهشت");
        expect(LLL, "ارد");
        expect(LLLL, "اردیبهشت");
        expect(y, "۱۴۰۰");
        expect(E, "شنب");
        expect(EEEE, "شنبه");
        expect(EEEEE, "ش");
        expect(QQQ, "س‌م۱");
        expect(QQQQ, "سه‌ماهه اول");
      });
    },
  );

  group(
    "Time Format Constructors Testing",
    () {
      test('Time Constructors', () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11, 2, 2, 2, 2, 2);
        String H = GeneralDateFormat.H().format(jalaliNow);
        String j = GeneralDateFormat.j().format(jalaliNow);
        String m = GeneralDateFormat.m().format(jalaliNow);
        String s = GeneralDateFormat.s().format(jalaliNow);
        expect(H, "02");
        expect(j, "2 AM");
        expect(m, "2");
        expect(s, "2");
      });
      test('Time Constructors With "fa" Locale', () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11, 2, 2, 2, 2, 2);
        String H = GeneralDateFormat.H("fa").format(jalaliNow);
        String j = GeneralDateFormat.j("fa").format(jalaliNow);
        String m = GeneralDateFormat.m("fa").format(jalaliNow);
        String s = GeneralDateFormat.s("fa").format(jalaliNow);
        expect(H, "۲");
        expect(j, "۲");
        expect(m, "۲");
        expect(s, "۲");
      });
    },
  );

  group(
    "Composition Format Constructors Testing",
    () {
      test('Composition Month, Day, Weekday Constructors', () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11, 2, 2, 2, 2, 2);
        String Md = GeneralDateFormat.Md().format(jalaliNow);
        String MEd = GeneralDateFormat.MEd().format(jalaliNow);
        String MMMd = GeneralDateFormat.MMMd().format(jalaliNow);
        String MMMEd = GeneralDateFormat.MMMEd().format(jalaliNow);
        String MMMMd = GeneralDateFormat.MMMMd().format(jalaliNow);
        String MMMMEEEEd = GeneralDateFormat.MMMMEEEEd().format(jalaliNow);
        expect(Md, "2/11");
        expect(MEd, "Sat, 2/11");
        expect(MMMd, "Ord 11");
        expect(MMMEd, "Sat, Ord 11");
        expect(MMMMd, "Ordibehesht 11");
        expect(MMMMEEEEd, "Saturday, Ordibehesht 11");
      });
      test('Composition Month, Day, Weekday Constructors With "fa" Locale', () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11, 2, 2, 2, 2, 2);
        String Md = GeneralDateFormat.Md("fa").format(jalaliNow);
        String MEd = GeneralDateFormat.MEd("fa").format(jalaliNow);
        String MMMd = GeneralDateFormat.MMMd("fa").format(jalaliNow);
        String MMMEd = GeneralDateFormat.MMMEd("fa").format(jalaliNow);
        String MMMMd = GeneralDateFormat.MMMMd("fa").format(jalaliNow);
        String MMMMEEEEd = GeneralDateFormat.MMMMEEEEd("fa").format(jalaliNow);
        expect(Md, "۲/۱۱");
        expect(MEd, "شنب ۲/۱۱");
        expect(MMMd, "۱۱ ارد");
        expect(MMMEd, "شنب ۱۱ ارد");
        expect(MMMMd, "۱۱ اردیبهشت");
        expect(MMMMEEEEd, "شنبه ۱۱ اردیبهشت");
      });
      test('Composition Year, Month, Day, Weekday, Quarter Constructors', () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11, 2, 2, 2, 2, 2);
        String yM = GeneralDateFormat.yM().format(jalaliNow);
        String yMd = GeneralDateFormat.yMd().format(jalaliNow);
        String yMEd = GeneralDateFormat.yMEd().format(jalaliNow);
        String yMMM = GeneralDateFormat.yMMM().format(jalaliNow);
        String yMMMd = GeneralDateFormat.yMMMd().format(jalaliNow);
        String yMMMEd = GeneralDateFormat.yMMMEd().format(jalaliNow);
        String yMMMM = GeneralDateFormat.yMMMM().format(jalaliNow);
        String yMMMMd = GeneralDateFormat.yMMMMd().format(jalaliNow);
        String yMMMMEEEEd = GeneralDateFormat.yMMMMEEEEd().format(jalaliNow);
        String yQQQ = GeneralDateFormat.yQQQ().format(jalaliNow);
        String yQQQQ = GeneralDateFormat.yQQQQ().format(jalaliNow);
        expect(yM, "2/1400");
        expect(yMd, "2/11/1400");
        expect(yMEd, "Sat, 2/11/1400");
        expect(yMMM, "Ord 1400");
        expect(yMMMd, "Ord 11, 1400");
        expect(yMMMEd, "Sat, Ord 11, 1400");
        expect(yMMMM, "Ordibehesht 1400");
        expect(yMMMMd, "Ordibehesht 11, 1400");
        expect(yMMMMEEEEd, "Saturday, Ordibehesht 11, 1400");
        expect(yQQQ, "Q1 1400");
        expect(yQQQQ, "1st quarter 1400");
      });
      test(
          'Composition Year, Month, Day, Weekday, Quarter Constructors With "fa" Locale',
          () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11, 2, 2, 2, 2, 2);
        String yM = GeneralDateFormat.yM("fa").format(jalaliNow);
        String yMd = GeneralDateFormat.yMd("fa").format(jalaliNow);
        String yMEd = GeneralDateFormat.yMEd("fa").format(jalaliNow);
        String yMMM = GeneralDateFormat.yMMM("fa").format(jalaliNow);
        String yMMMd = GeneralDateFormat.yMMMd("fa").format(jalaliNow);
        String yMMMEd = GeneralDateFormat.yMMMEd("fa").format(jalaliNow);
        String yMMMM = GeneralDateFormat.yMMMM("fa").format(jalaliNow);
        String yMMMMd = GeneralDateFormat.yMMMMd("fa").format(jalaliNow);
        String yMMMMEEEEd =
            GeneralDateFormat.yMMMMEEEEd("fa").format(jalaliNow);
        String yQQQ = GeneralDateFormat.yQQQ("fa").format(jalaliNow);
        String yQQQQ = GeneralDateFormat.yQQQQ("fa").format(jalaliNow);
        expect(yM, "۱۴۰۰/۲");
        expect(yMd, "۱۴۰۰/۲/۱۱");
        expect(yMEd, "شنب ۱۴۰۰/۲/۱۱");
        expect(yMMM, "ارد ۱۴۰۰");
        expect(yMMMd, "۱۱ ارد ۱۴۰۰");
        expect(yMMMEd, "شنب ۱۱ ارد ۱۴۰۰");
        expect(yMMMM, "اردیبهشت ۱۴۰۰");
        expect(yMMMMd, "۱۱ اردیبهشت ۱۴۰۰");
        expect(yMMMMEEEEd, "شنبه ۱۱ اردیبهشت ۱۴۰۰");
        expect(yQQQ, "سه‌ماهه اول ۱۴۰۰");
        expect(yQQQQ, "سه‌ماهه اول ۱۴۰۰");
      });
      test('Time Constructors', () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11, 2, 2, 2, 2, 2);
        String Hm = GeneralDateFormat.Hm().format(jalaliNow);
        String Hms = GeneralDateFormat.Hms().format(jalaliNow);
        String jm = GeneralDateFormat.jm().format(jalaliNow);
        String jms = GeneralDateFormat.jms().format(jalaliNow);
        String ms = GeneralDateFormat.ms().format(jalaliNow);
        expect(Hm, "02:02");
        expect(Hms, "02:02:02");
        expect(jm, "2:02 AM");
        expect(jms, "2:02:02 AM");
        expect(ms, "02:02");
      });
      test('Time Constructors With "fa" Locale', () {
        JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11, 2, 2, 2, 2, 2);
        String Hm = GeneralDateFormat.Hm("fa").format(jalaliNow);
        String Hms = GeneralDateFormat.Hms("fa").format(jalaliNow);
        String jm = GeneralDateFormat.jm("fa").format(jalaliNow);
        String jms = GeneralDateFormat.jms("fa").format(jalaliNow);
        String ms = GeneralDateFormat.ms("fa").format(jalaliNow);
        expect(Hm, "۲:۰۲");
        expect(Hms, "۲:۰۲:۰۲");
        expect(jm, "۲:۰۲");
        expect(jms, "۲:۰۲:۰۲");
        expect(ms, "۲:۰۲");
      });
    },
  );

  group(
    "Full Customize Pattern Testing",
    () {

      // Test formatting all date components
      test('GeneralDateFormat formats all date/time components correctly', () {
        final date = JalaliDateTime(1402, 2, 2, 14, 4, 5, 6);
        final formatPattern =
            "yyyy yy MMMM MMM MM M dd d hh h HH H mm m ss s SSS SS S a EEEE EEE EE E";
        final formatted = GeneralDateFormat(formatPattern).format(date);

        // Breakdown of expected outputs:
        final expectedValues = {
          'yyyy': '1402',        // Full year
          'yy': '02',            // Last two digits of year
          'MMMM': 'Ordibehesht',        // Full month name
          'MMM': 'Ord',          // Abbreviated month name
          'MM': '02',            // Two-digit month
          'M': '2',              // One-digit month
          'dd': '02',            // Two-digit day
          'd': '2',             // One-digit day
          'hh': '02',            // Two-digit 12-hour format (14 => 2 PM)
          'h': '2',              // One-digit 12-hour format
          'HH': '14',            // Two-digit 24-hour format
          'H': '14',             // One-digit 24-hour format
          'mm': '04',            // Two-digit minute
          'm': '4',             // One-digit minute
          'ss': '05',            // Two-digit second
          's': '5',             // One-digit second
          'SSS': '500',          // Milliseconds (3-digit)
          'SS': '500',           // Milliseconds (2+ digit fallback)
          'S': '500',            // Milliseconds (1+ digit fallback)
          'a': 'PM',             // AM/PM marker
          'EEEE': 'Saturday',    // Full weekday name
          'EEE': 'Sat',          // Abbreviated weekday name
          'EE': 'Sat',           // Double-abbreviated fallback
          'E': 'Sat',            // Shortest day format
        };

        // Compose the expected output using the same pattern structure
        final expectedFormatted = expectedValues.entries
            .map((e) => e.value)
            .join(' ');

        // Assert formatted output matches expected values
        expect(formatted, expectedFormatted);
      });






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
