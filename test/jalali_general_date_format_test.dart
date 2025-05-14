import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  group(
    "Date (Year, Month, Day, Week, Quarter) Format Constructors Testing",
    () {
      JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11);
      test('Month and Day Constructors', () {
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
      JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11, 2, 2, 2, 2, 2);
      test('Time Constructors', () {
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
      JalaliDateTime jalaliNow = JalaliDateTime(1400, 2, 11, 2, 2, 2, 2, 2);
      test('Composition Month, Day, Weekday Constructors', () {
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
      test('GeneralDateFormat formats all date/time components correctly', () {
        final date = JalaliDateTime(1402, 2, 2, 14, 4, 5, 60, 7);
        final p =
            "yyyy yy MMMM MMM MM M dd d c hh h HH H mm m ss s SSS SS S a EEEEE EEEE EEE EE E";
        final formatted = GeneralDateFormat(p).format(date);
        // Breakdown of expected outputs:
        final values = {
          'yyyy': '1402', // Full year
          'yy': '02', // Last two digits of year
          'MMMM': 'Ordibehesht', // Full month name
          'MMM': 'Ord', // Abbreviated month name
          'MM': '02', // Two-digit month
          'M': '2', // One-digit month
          'dd': '02', // Two-digit day
          'd': '2', // One-digit day
          'c': '2', // Standalone day - may be same as 'd'
          'hh': '02', // Two-digit 12-hour format (14 => 2 PM)
          'h': '2', // One-digit 12-hour format
          'HH': '14', // Two-digit 24-hour format
          'H': '14', // One-digit 24-hour format
          'mm': '04', // Two-digit minute
          'm': '4', // One-digit minute
          'ss': '05', // Two-digit second
          's': '5', // One-digit second
          'SSS': '060', // Milliseconds (3-digit)
          'SS': '060', // Milliseconds (2+ digit fallback)
          'S': '060', // Milliseconds (1+ digit fallback)
          'a': 'PM', // AM/PM marker
          'EEEEE': 'S',
          'EEEE': 'Saturday', // Full weekday name
          'EEE': 'Sat', // Abbreviated weekday name
          'EE': 'Sat', // Double-abbreviated fallback
          'E': 'Sat', // Shortest day format
        };
        final expected = values.entries.map((e) => e.value).join(' ');
        expect(formatted, expected);
      });

      test('GeneralDateFormat handles all ICU-like symbols correctly', () {
        final date = JalaliDateTime(1402, 4, 10, 23);
        final p = "G GGGG yyyy y MM M dd d c h H k K EEEE E D a Q QQ QQQ QQQQ";
        final formatted = GeneralDateFormat(p).format(date);
        final values = {
          'G': 'S.Y.',
          'GGGG': 'Solar Year',
          'yyyy': '1402',
          'y': '1402',
          'MM': '04',
          'M': '4',
          'dd': '10',
          'd': '10',
          'c': '10',
          'h': '11',
          'H': '23',
          'k': '23',
          'K': '11',
          'EEEE': 'Saturday',
          'E': 'Sat',
          'D': '103',
          'a': 'PM',
          'Q': '2',
          'QQ': '02',
          'QQQ': 'Q2',
          'QQQQ': '2nd quarter',
        };
        final expected = values.entries.map((e) => e.value).join(' ');
        expect(formatted, expected);
      });

      test('Full DateTime With Delimiter', () {
        final date = JalaliDateTime(1402, 2, 11, 23, 12, 45);
        String res = GeneralDateFormat("yyyy/MM/dd HH:mm:ss EEEE").format(date);
        expect(res, "1402/02/11 23:12:45 Monday");
      });
    },
  );

  group(
    "Full Customize Pattern Testing (fa locale)",
    () {
      test('GeneralDateFormat formats all date/time components correctly in fa',
          () {
        final date = JalaliDateTime(1402, 2, 2, 14, 4, 5, 60, 7);
        final p =
            "yyyy yy MMMM MMM MM M dd d c hh h HH H mm m ss s SSS SS S a EEEEE EEEE EEE EE E";
        final formatted = GeneralDateFormat(p, 'fa').format(date);

        final values = {
          'yyyy': '۱۴۰۲',
          'yy': '۰۲',
          'MMMM': 'اردیبهشت',
          'MMM': 'ارد',
          'MM': '۰۲',
          'M': '۲',
          'dd': '۰۲',
          'd': '۲',
          'c': '۲',
          'hh': '۰۲',
          'h': '۲',
          'HH': '۱۴',
          'H': '۱۴',
          'mm': '۰۴',
          'm': '۴',
          'ss': '۰۵',
          's': '۵',
          'SSS': '۰۶۰',
          'SS': '۰۶۰',
          'S': '۰۶۰',
          'a': 'ب.ظ.',
          'EEEEE': 'ش',
          'EEEE': 'شنبه',
          'EEE': 'شنب',
          'EE': 'شنب',
          'E': 'شنب',
        };
        final expected = values.entries.map((e) => e.value).join(' ');
        expect(formatted, expected);
      });

      test('GeneralDateFormat handles all ICU-like symbols correctly in fa',
          () {
        final date = JalaliDateTime(1402, 4, 10, 23);
        final p =
            "G GGGG yyyy y MM M dd d c h H k K EEEE EEEEE D a Q QQ QQQ QQQQ";
        final formatted = GeneralDateFormat(p, 'fa').format(date);

        final values = {
          'G': 'خ.',
          'GGGG': 'خورشیدی',
          'yyyy': '۱۴۰۲',
          'y': '۱۴۰۲',
          'MM': '۰۴',
          'M': '۴',
          'dd': '۱۰',
          'd': '۱۰',
          'c': '۱۰',
          'h': '۱۱',
          'H': '۲۳',
          'k': '۲۳',
          'K': '۱۱',
          'EEEE': 'شنبه',
          'EEEEE': 'ش',
          'D': '۱۰۳',
          'a': 'ب.ظ.',
          'Q': '۲',
          'QQ': '۰۲',
          'QQQ': 'س‌م۲',
          'QQQQ': 'سه‌ماهه دوم',
        };
        final expected = values.entries.map((e) => e.value).join(' ');
        expect(formatted, expected);
      });

      test('Full DateTime With Delimiter in fa', () {
        final date = JalaliDateTime(1402, 2, 11, 23, 12, 45);
        String res =
            GeneralDateFormat("yyyy/MM/dd HH:mm:ss EEEE", 'fa').format(date);
        expect(res, "۱۴۰۲/۰۲/۱۱ ۲۳:۱۲:۴۵ دوشنبه");
      });
    },
  );

  group("Formatting Stress Tests", () {
    // Test full RTL formatting with Persian numerals
    test('Persian RTL Complexity', () {
      final date = JalaliDateTime(1402, 7, 15, 14, 45, 30, 500);
      final formatted =
          GeneralDateFormat("yyyy/MMMM/dd EEEE - HH:mm:ss.SSS a", "fa")
              .format(date);

      expect(formatted, "۱۴۰۲/مهر/۱۵ شنبه - ۱۴:۴۵:۳۰.۵۰۰ ب.ظ.");
    });

    // Test midnight/noon edge cases
    test('Time Extremes', () {
      final midnight = JalaliDateTime(1402, 1, 1, 0, 0);
      expect(GeneralDateFormat("h:mm a").format(midnight), "12:00 AM");
    });

    // Test numeric formatting edge cases
    test('Numeric Padding', () {
      final date = JalaliDateTime(5, 3, 7, 3, 9);
      expect(
          GeneralDateFormat("yy/MM/dd hh:mm").format(date), "05/03/07 03:09");
      expect(GeneralDateFormat("y/M/d H:m", "fa").format(date), "۵/۳/۷ ۳:۹");
    });

    // Test escape characters
    test('Format Literals', () {
      final date = JalaliDateTime(1402, 1, 1);
      expect(GeneralDateFormat("'Year:' yyyy 'at' HH:mm").format(date),
          "Year: 1402 at 00:00");
    });

    // Test microsecond precision
    test('Fractional Seconds', () {
      final date = JalaliDateTime(1, 1, 1, 1, 1, 1, 1, 123456);
      expect(GeneralDateFormat("SSSSSS", "en_ISO").format(date), "124000");
      expect(GeneralDateFormat("SSS", "fa").format(date), "۱۲۴");
    });
  });

  group(
    "Functions Testing (add_X)",
    () {
      final date = JalaliDateTime(1402, 2, 11, 23, 59, 30, 789, 123);

      test('add_d formats day in month', () {
        expect(GeneralDateFormat("M").add_d().format(date), '2 11');
      });

      test('add_E formats abbreviated weekday', () {
        expect(GeneralDateFormat().add_E().format(date), 'Mon');
      });

      test('add_EEEE formats full weekday', () {
        expect(GeneralDateFormat().add_EEEE().format(date), 'Monday');
      });

      test('add_LLL formats standalone abbreviated month', () {
        expect(GeneralDateFormat("y").add_LLL().format(date), '1402 Ord');
      });

      test('add_LLLL formats standalone full month', () {
        expect(GeneralDateFormat().add_LLLL().add_d().format(date),
            'Ordibehesht 11');
      });

      test('add_M formats numeric month', () {
        expect(GeneralDateFormat().add_M().format(date), '2');
      });

      test('add_Md formats month/day', () {
        expect(GeneralDateFormat().add_Md().format(date), '2/11');
      });

      test('add_MEd formats abbreviated weekday and month/day', () {
        expect(GeneralDateFormat().add_MEd().format(date), 'Mon, 2/11');
      });

      test('add_MMM formats abbreviated month name', () {
        expect(GeneralDateFormat().add_MMM().format(date), 'Ord');
      });

      test('add_MMMd formats abbreviated month name and day', () {
        expect(GeneralDateFormat().add_MMMd().format(date), 'Ord 11');
      });

      test('add_MMMEd formats abbreviated weekday + month + day', () {
        expect(GeneralDateFormat().add_MMMEd().format(date), 'Mon, Ord 11');
      });

      test('add_MMMM formats full month name', () {
        expect(GeneralDateFormat().add_MMMM().format(date), 'Ordibehesht');
      });

      test('add_MMMMd formats full month + day', () {
        expect(GeneralDateFormat().add_MMMMd().format(date), 'Ordibehesht 11');
      });

      test('add_MMMMEEEEd formats full weekday + full month + day', () {
        expect(GeneralDateFormat().add_MMMMEEEEd().format(date),
            'Monday, Ordibehesht 11');
      });

      test('add_QQQ formats short quarter', () {
        expect(GeneralDateFormat().add_QQQ().format(date), 'Q1');
      });

      test('add_QQQQ formats full quarter', () {
        expect(GeneralDateFormat().add_QQQQ().format(date), '1st quarter');
      });

      test('add_y formats year', () {
        expect(GeneralDateFormat().add_y().format(date), '1402');
      });

      test('add_yM formats year and month', () {
        expect(GeneralDateFormat().add_yM().format(date), '2/1402');
      });

      test('add_yMd formats full numeric date', () {
        expect(GeneralDateFormat().add_yMd().format(date), '2/11/1402');
      });

      test('add_yMEd formats weekday + year/month/day', () {
        expect(GeneralDateFormat().add_yMEd().format(date), 'Mon, 2/11/1402');
      });

      test('add_yMMM formats year and abbreviated month', () {
        expect(GeneralDateFormat().add_yMMM().format(date), 'Ord 1402');
      });

      test('add_yMMMd formats abbreviated month + day + year', () {
        expect(GeneralDateFormat().add_yMMMd().format(date), 'Ord 11, 1402');
      });

      test('add_yMMMEd formats weekday + month + day + year', () {
        expect(
            GeneralDateFormat().add_yMMMEd().format(date), 'Mon, Ord 11, 1402');
      });

      test('add_yMMMM formats full month + year', () {
        expect(
            GeneralDateFormat().add_yMMMM().format(date), 'Ordibehesht 1402');
      });

      test('add_yMMMMd formats full month + day + year', () {
        expect(GeneralDateFormat().add_yMMMMd().format(date),
            'Ordibehesht 11, 1402');
      });

      test('add_yMMMMEEEEd formats weekday + full month + day + year', () {
        expect(GeneralDateFormat().add_yMMMMEEEEd().format(date),
            'Monday, Ordibehesht 11, 1402');
      });

      test('add_yQQQ formats year + short quarter', () {
        expect(GeneralDateFormat().add_yQQQ().format(date), 'Q1 1402');
      });

      test('add_yQQQQ formats year + full quarter', () {
        expect(
            GeneralDateFormat().add_yQQQQ().format(date), '1st quarter 1402');
      });

      test('add_H formats 24-hour time', () {
        expect(GeneralDateFormat().add_H().format(date), '23');
      });

      test('add_Hm formats hour + minute', () {
        expect(GeneralDateFormat().add_Hm().format(date), '23:59');
      });

      test('add_Hms formats hour + minute + second', () {
        expect(GeneralDateFormat().add_Hms().format(date), '23:59:30');
      });

      test('add_j formats localized hour (12 or 24)', () {
        expect(
            GeneralDateFormat().add_j().format(date), '11 PM'); // 23 => 11 PM
      });

      test('add_jm formats localized hour:minute', () {
        expect(GeneralDateFormat().add_jm().format(date), '11:59 PM');
      });

      test('add_jms formats localized hour:minute:second', () {
        expect(GeneralDateFormat().add_jms().format(date), '11:59:30 PM');
      });

      test('add_m formats minute', () {
        expect(GeneralDateFormat().add_m().format(date), '59');
      });

      test('add_ms formats minute:second', () {
        expect(GeneralDateFormat().add_ms().format(date), '59:30');
      });

      test('add_s formats second', () {
        expect(GeneralDateFormat().add_s().format(date), '30');
      });
    },
  );

  group(
    "Functions Testing (add_X) - fa locale",
        () {
      final date = JalaliDateTime(1402, 2, 11, 23, 59, 30, 789, 123);
      final locale = 'fa';

      test('add_d formats day in month', () {
        expect(GeneralDateFormat("M", locale).add_d().format(date), '۲ ۱۱');
      });

      test('add_E formats abbreviated weekday', () {
        expect(GeneralDateFormat(null, locale).add_E().format(date), 'دوش');
      });

      test('add_EEEE formats full weekday', () {
        expect(GeneralDateFormat(null, locale).add_EEEE().format(date), 'دوشنبه');
      });

      test('add_LLL formats standalone abbreviated month', () {
        expect(GeneralDateFormat("y", locale).add_LLL().format(date), '۱۴۰۲ ارد');
      });

      test('add_LLLL formats standalone full month', () {
        expect(
          GeneralDateFormat(null, locale).add_LLLL().add_d().format(date),
          'اردیبهشت ۱۱',
        );
      });

      test('add_M formats numeric month', () {
        expect(GeneralDateFormat(null, locale).add_M().format(date), '۲');
      });

      test('add_Md formats month/day', () {
        expect(GeneralDateFormat(null, locale).add_Md().format(date), '۲/۱۱');
      });

      test('add_MEd formats weekday and month/day', () {
        expect(GeneralDateFormat(null, locale).add_MEd().format(date), 'دوش ۲/۱۱');
      });

      test('add_MMM formats abbreviated month', () {
        expect(GeneralDateFormat(null, locale).add_MMM().format(date), 'ارد');
      });

      test('add_MMMd formats abbreviated month and day', () {
        expect(GeneralDateFormat(null, locale).add_MMMd().format(date), '۱۱ ارد');
      });

      test('add_MMMEd formats abbreviated weekday + month + day', () {
        expect(GeneralDateFormat(null, locale).add_MMMEd().format(date), 'دوش ۱۱ ارد');
      });

      test('add_MMMM formats full month name', () {
        expect(GeneralDateFormat(null, locale).add_MMMM().format(date), 'اردیبهشت');
      });

      test('add_MMMMd formats full month + day', () {
        expect(GeneralDateFormat(null, locale).add_MMMMd().format(date), '۱۱ اردیبهشت');
      });

      test('add_MMMMEEEEd formats full weekday + full month + day', () {
        expect(GeneralDateFormat(null, locale).add_MMMMEEEEd().format(date), 'دوشنبه ۱۱ اردیبهشت');
      });

      test('add_QQQ formats short quarter', () {
        expect(GeneralDateFormat(null, locale).add_QQQ().format(date), 'س‌م۱');
      });

      test('add_QQQQ formats full quarter', () {
        expect(GeneralDateFormat(null, locale).add_QQQQ().format(date), 'سه‌ماهه اول');
      });

      test('add_y formats year', () {
        expect(GeneralDateFormat(null, locale).add_y().format(date), '۱۴۰۲');
      });

      test('add_yM formats year and month', () {
        expect(GeneralDateFormat(null, locale).add_yM().format(date), '۱۴۰۲/۲');
      });

      test('add_yMd formats full numeric date', () {
        expect(GeneralDateFormat(null, locale).add_yMd().format(date), '۱۴۰۲/۲/۱۱');
      });

      test('add_yMEd formats weekday + full numeric date', () {
        expect(GeneralDateFormat(null, locale).add_yMEd().format(date), 'دوش ۱۴۰۲/۲/۱۱');
      });

      test('add_yMMM formats year and abbreviated month', () {
        expect(GeneralDateFormat(null, locale).add_yMMM().format(date), 'ارد ۱۴۰۲');
      });

      test('add_yMMMd formats abbreviated month + day + year', () {
        expect(GeneralDateFormat(null, locale).add_yMMMd().format(date), '۱۱ ارد ۱۴۰۲');
      });

      test('add_yMMMEd formats weekday + month + day + year', () {
        expect(GeneralDateFormat(null, locale).add_yMMMEd().format(date), 'دوش ۱۱ ارد ۱۴۰۲');
      });

      test('add_yMMMM formats full month + year', () {
        expect(GeneralDateFormat(null, locale).add_yMMMM().format(date), 'اردیبهشت ۱۴۰۲');
      });

      test('add_yMMMMd formats full month + day + year', () {
        expect(GeneralDateFormat(null, locale).add_yMMMMd().format(date), '۱۱ اردیبهشت ۱۴۰۲');
      });

      test('add_yMMMMEEEEd formats weekday + full month + day + year', () {
        expect(GeneralDateFormat(null, locale).add_yMMMMEEEEd().format(date), 'دوشنبه ۱۱ اردیبهشت ۱۴۰۲');
      });

      test('add_yQQQ formats year + short quarter', () {
        expect(GeneralDateFormat(null, locale).add_yQQQ().format(date), 'سه‌ماهه اول ۱۴۰۲');
      });

      test('add_yQQQQ formats year + full quarter', () {
        expect(GeneralDateFormat(null, locale).add_yQQQQ().format(date), 'سه‌ماهه اول ۱۴۰۲');
      });

      test('add_H formats 24-hour', () {
        expect(GeneralDateFormat(null, locale).add_H().format(date), '۲۳');
      });

      test('add_Hm formats hour + minute', () {
        expect(GeneralDateFormat(null, locale).add_Hm().format(date), '۲۳:۵۹');
      });

      test('add_Hms formats hour + minute + second', () {
        expect(GeneralDateFormat(null, locale).add_Hms().format(date), '۲۳:۵۹:۳۰');
      });

      test('add_j formats localized hour', () {
        expect(GeneralDateFormat(null, locale).add_j().format(date), '۲۳');
      });

      test('add_jm formats localized hour:minute', () {
        expect(GeneralDateFormat(null, locale).add_jm().format(date), '۲۳:۵۹');
      });

      test('add_jms formats localized hour:minute:second', () {
        expect(GeneralDateFormat(null, locale).add_jms().format(date), '۲۳:۵۹:۳۰');
      });

      test('add_m formats minute', () {
        expect(GeneralDateFormat(null, locale).add_m().format(date), '۵۹');
      });

      test('add_ms formats minute:second', () {
        expect(GeneralDateFormat(null, locale).add_ms().format(date), '۵۹:۳۰');
      });

      test('add_s formats second', () {
        expect(GeneralDateFormat(null, locale).add_s().format(date), '۳۰');
      });
    },
  );

}
