class DateSymbols {
  String NAME;
  List<String>

      /// The short name of the era, e.g. 'BC' or 'AD'
      ERAS,

      /// The long name of the era, e.g. 'Before Christ' or 'Anno Domino'
      ERANAMES,

      /// Very short names of months, e.g. 'J'.
      NARROWMONTHS,

      /// Very short names of months as they would be written on their own,
      /// e.g. 'J'.
      STANDALONENARROWMONTHS,

      /// Full names of months, e.g. 'January'.
      MONTHS,

      /// Full names of months as they would be written on their own,
      /// e.g. 'January'.
      ///
      /// These are frequently the same as MONTHS, but for example might start
      /// with upper case where the names in MONTHS might not.
      STANDALONEMONTHS,

      /// Short names of months, e.g. 'Jan'.
      SHORTMONTHS,

      /// Short names of months as they would be written on their own,
      /// e.g. 'Jan'.
      STANDALONESHORTMONTHS,

      /// The days of the week, starting with Sunday.
      WEEKDAYS,

      /// The days of the week as they would be written on their own, starting
      /// with Sunday.
      /// Frequently the same as WEEKDAYS, but for example might
      /// start with upper case where the names in WEEKDAYS might not.
      STANDALONEWEEKDAYS,

      /// Short names for days of the week, starting with Sunday, e.g. 'Sun'.
      SHORTWEEKDAYS,

      /// Short names for days of the week as they would be written on their
      /// own, starting with Sunday, e.g. 'Sun'.
      STANDALONESHORTWEEKDAYS,

      /// Very short names for days of the week, starting with Sunday, e.g. 'S'.
      NARROWWEEKDAYS,

      /// Very short names for days of the week as they would be written on
      /// their own, starting with Sunday, e.g. 'S'.
      STANDALONENARROWWEEKDAYS,

      /// Names of the quarters of the year in a short form, e.g. 'Q1'.
      SHORTQUARTERS,

      /// Long names of the quartesr of the year, e.g. '1st Quarter'.
      QUARTERS,

      /// A list of length 2 with localized text for 'AM' and 'PM'.
      AMPMS,

      /// The supported date formats for this locale.
      DATEFORMATS,

      /// The supported time formats for this locale.
      TIMEFORMATS,

      /// The ways date and time formats can be combined for this locale.
      DATETIMEFORMATS;
  Map<String, String>? AVAILABLEFORMATS;

  /// The first day of the week, in ISO 8601 style, where the first day of the
  /// week, i.e. index 0, is Monday.
  int FIRSTDAYOFWEEK;

  /// Which days are weekend days, integers where 0=Monday.
  ///
  /// For example, [5, 6] to mean Saturday and Sunday are weekend days.
  List<int> WEEKENDRANGE;
  int FIRSTWEEKCUTOFFDAY;

  String? ZERODIGIT;

  DateSymbols(
      {required this.NAME,
      required this.ERAS,
      required this.ERANAMES,
      required this.NARROWMONTHS,
      required this.STANDALONENARROWMONTHS,
      required this.MONTHS,
      required this.STANDALONEMONTHS,
      required this.SHORTMONTHS,
      required this.STANDALONESHORTMONTHS,
      required this.WEEKDAYS,
      required this.STANDALONEWEEKDAYS,
      required this.SHORTWEEKDAYS,
      required this.STANDALONESHORTWEEKDAYS,
      required this.NARROWWEEKDAYS,
      required this.STANDALONENARROWWEEKDAYS,
      required this.SHORTQUARTERS,
      required this.QUARTERS,
      required this.AMPMS,
      this.ZERODIGIT,
      required this.DATEFORMATS,
      required this.TIMEFORMATS,
      this.AVAILABLEFORMATS,
      required this.FIRSTDAYOFWEEK,
      required this.WEEKENDRANGE,
      required this.FIRSTWEEKCUTOFFDAY,
      required this.DATETIMEFORMATS});

  factory DateSymbols.deserializeFromMap(Map<dynamic, dynamic> map) {
    List<String> getStringList(String name) => List<String>.from(map[name]);

    return DateSymbols(
      NAME: map['NAME'],
      ERAS: getStringList('ERAS'),
      ERANAMES: getStringList('ERANAMES'),
      NARROWMONTHS: getStringList('NARROWMONTHS'),
      STANDALONENARROWMONTHS: getStringList('STANDALONENARROWMONTHS'),
      MONTHS: getStringList('MONTHS'),
      STANDALONEMONTHS: getStringList('STANDALONEMONTHS'),
      SHORTMONTHS: getStringList('SHORTMONTHS'),
      STANDALONESHORTMONTHS: getStringList('STANDALONESHORTMONTHS'),
      WEEKDAYS: getStringList('WEEKDAYS'),
      STANDALONEWEEKDAYS: getStringList('STANDALONEWEEKDAYS'),
      SHORTWEEKDAYS: getStringList('SHORTWEEKDAYS'),
      STANDALONESHORTWEEKDAYS: getStringList('STANDALONESHORTWEEKDAYS'),
      NARROWWEEKDAYS: getStringList('NARROWWEEKDAYS'),
      STANDALONENARROWWEEKDAYS: getStringList('STANDALONENARROWWEEKDAYS'),
      SHORTQUARTERS: getStringList('SHORTQUARTERS'),
      QUARTERS: getStringList('QUARTERS'),
      AMPMS: getStringList('AMPMS'),
      ZERODIGIT: map['ZERODIGIT'],
      DATEFORMATS: getStringList('DATEFORMATS'),
      TIMEFORMATS: getStringList('TIMEFORMATS'),
      AVAILABLEFORMATS: Map<String, String>.from(map['AVAILABLEFORMATS'] ?? {}),
      FIRSTDAYOFWEEK: map['FIRSTDAYOFWEEK'],
      WEEKENDRANGE: List<int>.from(map['WEEKENDRANGE']),
      FIRSTWEEKCUTOFFDAY: map['FIRSTWEEKCUTOFFDAY'],
      DATETIMEFORMATS: getStringList('DATETIMEFORMATS'),
    );
  }

  Map<String, dynamic> serializeToMap() {
    var basicMap = _serializeToMap();
    if (ZERODIGIT != null && ZERODIGIT != '') {
      basicMap['ZERODIGIT'] = ZERODIGIT;
    }
    return basicMap;
  }

  Map<String, dynamic> _serializeToMap() => {
        'NAME': NAME,
        'ERAS': ERAS,
        'ERANAMES': ERANAMES,
        'NARROWMONTHS': NARROWMONTHS,
        'STANDALONENARROWMONTHS': STANDALONENARROWMONTHS,
        'MONTHS': MONTHS,
        'STANDALONEMONTHS': STANDALONEMONTHS,
        'SHORTMONTHS': SHORTMONTHS,
        'STANDALONESHORTMONTHS': STANDALONESHORTMONTHS,
        'WEEKDAYS': WEEKDAYS,
        'STANDALONEWEEKDAYS': STANDALONEWEEKDAYS,
        'SHORTWEEKDAYS': SHORTWEEKDAYS,
        'STANDALONESHORTWEEKDAYS': STANDALONESHORTWEEKDAYS,
        'NARROWWEEKDAYS': NARROWWEEKDAYS,
        'STANDALONENARROWWEEKDAYS': STANDALONENARROWWEEKDAYS,
        'SHORTQUARTERS': SHORTQUARTERS,
        'QUARTERS': QUARTERS,
        'AMPMS': AMPMS,
        'DATEFORMATS': DATEFORMATS,
        'TIMEFORMATS': TIMEFORMATS,
        'AVAILABLEFORMATS': AVAILABLEFORMATS,
        'FIRSTDAYOFWEEK': FIRSTDAYOFWEEK,
        'WEEKENDRANGE': WEEKENDRANGE,
        'FIRSTWEEKCUTOFFDAY': FIRSTWEEKCUTOFFDAY,
        'DATETIMEFORMATS': DATETIMEFORMATS,
      };

  @override
  String toString() => NAME;
}

/// We hard-code the locale data for en_US here so that there's at least one
/// locale always available.
final DateSymbols en_USSymbols = DateSymbols(
    NAME: 'en_US',
    ERAS: const ['BC', 'AD'],
    ERANAMES: const ['Before Christ', 'Anno Domini'],
    NARROWMONTHS: const [
      'J',
      'F',
      'M',
      'A',
      'M',
      'J',
      'J',
      'A',
      'S',
      'O',
      'N',
      'D'
    ],
    STANDALONENARROWMONTHS: const [
      'J',
      'F',
      'M',
      'A',
      'M',
      'J',
      'J',
      'A',
      'S',
      'O',
      'N',
      'D'
    ],
    MONTHS: const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ],
    STANDALONEMONTHS: const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ],
    SHORTMONTHS: const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ],
    STANDALONESHORTMONTHS: const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ],
    WEEKDAYS: const [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ],
    STANDALONEWEEKDAYS: const [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ],
    SHORTWEEKDAYS: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    STANDALONESHORTWEEKDAYS: const [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat'
    ],
    NARROWWEEKDAYS: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
    STANDALONENARROWWEEKDAYS: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
    SHORTQUARTERS: const ['Q1', 'Q2', 'Q3', 'Q4'],
    QUARTERS: const [
      '1st quarter',
      '2nd quarter',
      '3rd quarter',
      '4th quarter'
    ],
    AMPMS: const ['AM', 'PM'],
    DATEFORMATS: const ['EEEE, MMMM d, y', 'MMMM d, y', 'MMM d, y', 'M/d/yy'],
    TIMEFORMATS: const ['h:mm:ss a zzzz', 'h:mm:ss a z', 'h:mm:ss a', 'h:mm a'],
    FIRSTDAYOFWEEK: 6,
    WEEKENDRANGE: const [5, 6],
    FIRSTWEEKCUTOFFDAY: 5,
    DATETIMEFORMATS: const [
      '{1}, {0}',
      '{1}, {0}',
      '{1}, {0}',
      '{1}, {0}',
    ]);

const Map<String, String> en_USPatterns = {
  'd': 'd', // DAY
  'E': 'ccc', // ABBR_WEEKDAY
  'EEEE': 'cccc', // WEEKDAY
  'LLL': 'LLL', // ABBR_STANDALONE_MONTH
  'LLLL': 'LLLL', // STANDALONE_MONTH
  'M': 'L', // NUM_MONTH
  'Md': 'M/d', // NUM_MONTH_DAY
  'MEd': 'EEE, M/d', // NUM_MONTH_WEEKDAY_DAY
  'MMM': 'LLL', // ABBR_MONTH
  'MMMd': 'MMM d', // ABBR_MONTH_DAY
  'MMMEd': 'EEE, MMM d', // ABBR_MONTH_WEEKDAY_DAY
  'MMMM': 'LLLL', // MONTH
  'MMMMd': 'MMMM d', // MONTH_DAY
  'MMMMEEEEd': 'EEEE, MMMM d', // MONTH_WEEKDAY_DAY
  'QQQ': 'QQQ', // ABBR_QUARTER
  'QQQQ': 'QQQQ', // QUARTER
  'y': 'y', // YEAR
  'yM': 'M/y', // YEAR_NUM_MONTH
  'yMd': 'M/d/y', // YEAR_NUM_MONTH_DAY
  'yMEd': 'EEE, M/d/y', // YEAR_NUM_MONTH_WEEKDAY_DAY
  'yMMM': 'MMM y', // YEAR_ABBR_MONTH
  'yMMMd': 'MMM d, y', // YEAR_ABBR_MONTH_DAY
  'yMMMEd': 'EEE, MMM d, y', // YEAR_ABBR_MONTH_WEEKDAY_DAY
  'yMMMM': 'MMMM y', // YEAR_MONTH
  'yMMMMd': 'MMMM d, y', // YEAR_MONTH_DAY
  'yMMMMEEEEd': 'EEEE, MMMM d, y', // YEAR_MONTH_WEEKDAY_DAY
  'yQQQ': 'QQQ y', // YEAR_ABBR_QUARTER
  'yQQQQ': 'QQQQ y', // YEAR_QUARTER
  'H': 'HH', // HOUR24
  'Hm': 'HH:mm', // HOUR24_MINUTE
  'Hms': 'HH:mm:ss', // HOUR24_MINUTE_SECOND
  'j': 'h a', // HOUR
  'jm': 'h:mm a', // HOUR_MINUTE
  'jms': 'h:mm:ss a', // HOUR_MINUTE_SECOND
  'jmv': 'h:mm a v', // HOUR_MINUTE_GENERIC_TZ
  'jmz': 'h:mm a z', // HOUR_MINUTETZ
  'jz': 'h a z', // HOURGENERIC_TZ
  'm': 'm', // MINUTE
  'ms': 'mm:ss', // MINUTE_SECOND
  's': 's', // SECOND
  'v': 'v', // ABBR_GENERIC_TZ
  'z': 'z', // ABBR_SPECIFIC_TZ
  'zzzz': 'zzzz', // SPECIFIC_TZ
  'ZZZZ': 'ZZZZ' // ABBR_UTC_TZ
};
