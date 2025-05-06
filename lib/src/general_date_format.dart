import 'package:general_date_format/src/common/date_time_patterns.dart';
import 'package:general_date_format/src/common/symbol_list.dart';
import 'package:general_datetime/general_datetime.dart';
import 'package:meta/meta.dart';

import 'date_builder.dart';
import 'date_symbols.dart';
import 'general_date_format_internal.dart';
import 'helpers.dart';
import 'string_stack.dart';

part 'date_format_field.dart';

/// feedback on appropriateness.
/// GeneralDateFormat is for formatting and parsing dates in a locale-sensitive manner.
/// It allows the user to choose from a set of standard date time formats as
/// well as specify a customized pattern under certain locales. Date elements
/// that vary across locales include month name, week name, field order, etc.
/// Formatting dates in the default 'en_US' format.
///
/// ```dart
/// print(GeneralDateFormat.yMMMd().format(JalaliDateTime.now()));
/// ```
///
/// This library uses the ICU/JDK date/time pattern specification both for
/// complete format specifications and also the abbreviated 'skeleton' form
/// which can also adapt to different locales and is preferred where available.
///
/// Skeletons: These can be specified either as the ICU constant name or as the
/// skeleton to which it resolves. The supported set of skeletons is as follows.
/// For each skeleton there is a named constructor that can be used to create
/// it.  It's also possible to pass the skeleton as a string, but the
/// constructor is preferred.
///
///      ICU Name                   Skeleton
///      --------                   --------
///      DAY                          d
///      ABBR_WEEKDAY                 E
///      WEEKDAY                      EEEE
///      ABBR_STANDALONE_MONTH        LLL
///      STANDALONE_MONTH             LLLL
///      NUM_MONTH                    M
///      NUM_MONTH_DAY                Md
///      NUM_MONTH_WEEKDAY_DAY        MEd
///      ABBR_MONTH                   MMM
///      ABBR_MONTH_DAY               MMMd
///      ABBR_MONTH_WEEKDAY_DAY       MMMEd
///      MONTH                        MMMM
///      MONTH_DAY                    MMMMd
///      MONTH_WEEKDAY_DAY            MMMMEEEEd
///      ABBR_QUARTER                 QQQ
///      QUARTER                      QQQQ
///      YEAR                         y
///      YEAR_NUM_MONTH               yM
///      YEAR_NUM_MONTH_DAY           yMd
///      YEAR_NUM_MONTH_WEEKDAY_DAY   yMEd
///      YEAR_ABBR_MONTH              yMMM
///      YEAR_ABBR_MONTH_DAY          yMMMd
///      YEAR_ABBR_MONTH_WEEKDAY_DAY  yMMMEd
///      YEAR_MONTH                   yMMMM
///      YEAR_MONTH_DAY               yMMMMd
///      YEAR_MONTH_WEEKDAY_DAY       yMMMMEEEEd
///      YEAR_ABBR_QUARTER            yQQQ
///      YEAR_QUARTER                 yQQQQ
///      HOUR24                       H
///      HOUR24_MINUTE                Hm
///      HOUR24_MINUTE_SECOND         Hms
///      HOUR                         j
///      HOUR_MINUTE                  jm
///      HOUR_MINUTE_SECOND           jms
///      HOUR_MINUTE_GENERIC_TZ       jmv   (not yet implemented)
///      HOUR_MINUTE_TZ               jmz   (not yet implemented)
///      HOUR_GENERIC_TZ              jv    (not yet implemented)
///      HOUR_TZ                      jz    (not yet implemented)
///      MINUTE                       m
///      MINUTE_SECOND                ms
///      SECOND                       s
//
// TODO(https://github.com/dart-lang/intl/issues/74): Update table above.
///
/// Examples Using the US Locale:
///
///      Pattern                           Result
///      ----------------                  -------
///      GeneralDateFormat.yMd()                 -> 7/10/1996
///      GeneralDateFormat('yMd')                -> 7/10/1996
///      GeneralDateFormat.yMMMMd('en_US')       -> July 10, 1996
///      GeneralDateFormat.jm()                  -> 5:08 PM
///      GeneralDateFormat.yMd().add_jm()        -> 7/10/1996 5:08 PM
///      GeneralDateFormat.Hm()                  -> 17:08 // force 24 hour time
///
/// Explicit Pattern Syntax: Formats can also be specified with a pattern
/// string.  This can be used for formats that don't have a skeleton available,
/// but these will not adapt to different locales. For example, in an explicit
/// pattern the letters 'H' and 'h' are available for 24 hour and 12 hour time
/// formats respectively. But there isn't a way in an explicit pattern to get
/// the behaviour of the 'j' skeleton, which prints 24 hour or 12 hour time
/// according to the conventions of the locale, and also includes am/pm markers
/// where appropriate. So it is preferable to use the skeletons.
///
/// The following characters are available in explicit patterns:
///
///     Symbol   Meaning                Presentation       Example
///     ------   -------                ------------       -------
///     G        era designator         (Text)             AD
///     y        year                   (Number)           1996
///     M        month in year          (Text & Number)    July & 07
///     L        standalone month       (Text & Number)    July & 07
///     d        day in month           (Number)           10
///     c        standalone day         (Number)           10
///     h        hour in am/pm (1~12)   (Number)           12
///     H        hour in day (0~23)     (Number)           0
///     m        minute in hour         (Number)           30
///     s        second in minute       (Number)           55
///     S        fractional second      (Number)           978
///     E        day of week            (Text)             Tuesday
///     D        day in year            (Number)           189
///     a        am/pm marker           (Text)             PM
///     k        hour in day (1~24)     (Number)           24
///     K        hour in am/pm (0~11)   (Number)           0
///     Q        quarter                (Text)             Q3
///     '        escape for text        (Delimiter)        'Date='
///     ''       single quote           (Literal)          'o''clock'
///
//  TODO(https://github.com/dart-lang/intl/issues/74): Merge tables.
//
/// The following characters are reserved and currently are unimplemented:
///
///     Symbol   Meaning                Presentation       Example
///     ------   -------                ------------       -------
///     z        time zone              (Text)             Pacific Standard Time
///     Z        time zone (RFC 822)    (Number)           -0800
///     v        time zone (generic)    (Text)             Pacific Time
///
/// The count of pattern letters determine the format.
///
/// **Text**:
/// * 5 pattern letters--use narrow form for standalone. Otherwise not used.
/// * 4 or more pattern letters--use full form,
/// * 3 pattern letters--use short or abbreviated form if one exists
/// * less than 3--use numeric form if one exists
///
/// **Number**: the minimum number of digits. Shorter numbers are zero-padded to
/// this amount (e.g. if 'm' produces '6', 'mm' produces '06'). Year is handled
/// specially; that is, if the count of 'y' is 2, the Year will be truncated to
/// 2 digits. (e.g., if 'yyyy' produces '1997', 'yy' produces '97'.) Unlike
/// other fields, fractional seconds are padded on the right with zero.
///
/// **(Text & Number)**: 3 or over, use text, otherwise use number.
///
/// Any characters not in the pattern will be treated as quoted text. For
/// instance, characters like ':', '.', ' ', '#' and '@' will appear in the
/// resulting text even though they are not enclosed in single quotes. In our
/// current pattern usage, not all letters have meanings. But those unused
/// letters are strongly discouraged to be used as quoted text without quotes,
/// because we may use other letters as pattern characters in the future.
///
/// Examples Using the US Locale:
///
///     Format Pattern                    Result
///     --------------                    -------
///     "EEE, MMM d, ''yy"                Wed, Jul 10, '96
///     'h:mm a'                          12:08 PM
///     'yyyyy.MMMM.dd GGG hh:mm aaa'     01996.July.10 AD 12:08 PM
//
// TODO(https://github.com/dart-lang/intl/issues/74): Merge tables.
//
//      NOT YET IMPLEMENTED
//      -------------------
//      'yyyy.MM.dd G 'at' HH:mm:ss vvvv' 1996.07.10 AD at 15:08:56 Pacific Time
//      'hh 'o''clock' a, zzzz'           12 o'clock PM, Pacific Daylight Time
//      'K:mm a, vvv'                     0:00 PM, PT
///
/// When parsing a date string using the abbreviated year pattern ('yy'),
/// GeneralDateFormat must interpret the abbreviated year relative to some
/// century. It does this by adjusting dates to be within 80 years before and 20
/// years after the time the parse function is called. For example, using a
/// pattern of 'MM/dd/yy' and a GeneralDateFormat instance created on Jan 1, 1997,
/// the string '01/11/12' would be interpreted as Jan 11, 2012 while the string
/// '05/04/64' would be interpreted as May 4, 1964. During parsing, only
/// strings consisting of exactly two digits will be parsed into the default
/// century. Any other numeric string, such as a one digit string, a three or
/// more digit string will be interpreted as its face value. Tests that parse
/// two-digit years can control the current date with package:clock.
///
/// If the year pattern does not have exactly two 'y' characters, the year is
/// interpreted literally, regardless of the number of digits. So using the
/// pattern 'MM/dd/yyyy', '01/11/12' parses to Jan 11, 12 A.D.

class GeneralDateFormat {
  /// Creates a new GeneralDateFormat, using the format specified by [newPattern].
  ///
  /// For forms that match one of our predefined skeletons, we look up the
  /// corresponding pattern in [locale] (or in the default locale if none is
  /// specified) and use the resulting full format string. This is the preferred
  /// usage, but if [newPattern] does not match one of the skeletons, then it is
  /// used as a format directly, but will not be adapted to suit the locale.
  ///
  /// For example, in an en_US locale, specifying the skeleton
  ///
  /// ```dart
  /// GeneralDateFormat.yMEd();
  /// ```
  ///
  /// or the explicit
  ///
  /// ```dart
  /// GeneralDateFormat('EEE, M/d/y');
  /// ```
  ///
  /// would produce the same result, a date of the form 'Wed, 6/27/2012'.
  ///
  /// The first version would produce a different format string if used in
  /// another locale, but the second format would always be the same.
  ///
  /// If [locale] does not exist in our set of supported locales then an
  /// [ArgumentError] is thrown.
  GeneralDateFormat([String? newPattern, String? locale])
      : _locale = verifiedLocale(locale, localeExists, null)! {
    addPattern(newPattern);
  }

  /// Return a string representing [date] formatted according to our locale
  /// and internal format.
  String format(GeneralDateTimeInterface date) {
    initializeDateSymbols(date);
    var result = StringBuffer();
    for (var field in _formatFields) {
      result.write(field.format(date));
    }
    return result.toString();
  }

  /// Given user input, attempt to parse the [inputString] into the anticipated
  /// format, treating it as being in the local timezone.
  ///
  /// If [inputString] does not match our format, throws a [FormatException].
  /// This will accept dates whose values are not strictly valid, or strings
  /// with additional characters (including whitespace) after a valid date. For
  /// stricter parsing, use [parseStrict].
  /// TODO: implement this
  // DateTime parse(String inputString, [bool utc = false]) =>
  //     _parse(inputString, utc: utc, strict: false);

  /// Given user input, attempt to parse the [inputString] into the anticipated
  /// format, treating it as being in the local timezone.
  ///
  /// If [inputString] does not match our format, returns `null`.
  /// This will accept dates whose values are not strictly valid, or strings
  /// with additional characters (including whitespace) after a valid date. For
  /// stricter parsing, use [tryParseStrict].
  /// TODO: implement this
  // DateTime? tryParse(String inputString, [bool utc = false]) {
  //   try {
  //     return parse(inputString, utc);
  //   } on FormatException {
  //     return null;
  //   }
  // }

  /// Given user input, attempt to parse the [inputString] 'loosely' into the
  /// anticipated format, accepting some variations from the strict format.
  ///
  /// If [inputString] is accepted by [parseStrict], just return the result. If
  /// not, attempt to parse it, but accepting either upper or lower case,
  /// allowing delimiters to be missing and replaced or supplemented with
  /// whitespace, and allowing arbitrary amounts of whitespace wherever
  /// whitespace is permitted. Note that this does not allow trailing
  /// characters, the way [parse] does.  It also does not allow alternative
  /// names for months or weekdays other than those the format knows about. The
  /// restrictions are quite arbitrary and it's not known how well they'll work
  /// for locales that aren't English-like.
  ///
  /// If [inputString] does not parse, this throws a [FormatException].
  ///
  /// For example, this will accept
  ///
  ///       GeneralDateFormat.yMMMd('en_US').parseLoose('SEp   3 2014');
  ///       GeneralDateFormat.yMd('en_US').parseLoose('09    03/2014');
  ///       GeneralDateFormat.yMd('en_US').parseLoose('09 / 03 / 2014');
  ///
  /// It will NOT accept
  ///
  ///       // 'Sept' is not a valid month name.
  ///       GeneralDateFormat.yMMMd('en_US').parseLoose('Sept 3, 2014');
  /// TODO: implement this
  // DateTime parseLoose(String inputString, [bool utc = false]) {
  //   try {
  //     return _parse(inputString, utc: utc, strict: true);
  //   } on FormatException {
  //     return _parseLoose(inputString.toLowerCase(), utc);
  //   }
  // }

  /// Given user input, attempt to parse the [inputString] 'loosely' into the
  /// anticipated format, accepting some variations from the strict format.
  ///
  /// If [inputString] is accepted by [tryParseStrict], just return the result. If
  /// not, attempt to parse it, but accepting either upper or lower case,
  /// allowing delimiters to be missing and replaced or supplemented with
  /// whitespace, and allowing arbitrary amounts of whitespace wherever
  /// whitespace is permitted. Note that this does not allow trailing
  /// characters, the way [tryParse] does.  It also does not allow alternative
  /// names for months or weekdays other than those the format knows about. The
  /// restrictions are quite arbitrary and it's not known how well they'll work
  /// for locales that aren't English-like.
  ///
  /// If [inputString] does not parse, this returns `null`.
  ///
  /// For example, this will accept
  ///
  ///       GeneralDateFormat.yMMMd('en_US').tryParseLoose('SEp   3 2014');
  ///       GeneralDateFormat.yMd('en_US').tryParseLoose('09    03/2014');
  ///       GeneralDateFormat.yMd('en_US').tryParseLoose('09 / 03 / 2014');
  ///
  /// It will NOT accept
  ///
  ///       // 'Sept' is not a valid month name.
  ///       GeneralDateFormat.yMMMd('en_US').tryParseLoose('Sept 3, 2014');
  /// TODO: implement this
  // DateTime? tryParseLoose(String inputString, [bool utc = false]) {
  //   try {
  //     return parseLoose(inputString, utc);
  //   } on FormatException {
  //     return null;
  //   }
  // }

  /// TODO: implement this
  // DateTime _parseLoose(String inputString, bool utc) {
  //   var dateFields = DateBuilder(locale, dateTimeConstructor);
  //   if (utc) dateFields.utc = true;
  //   var stack = StringStack(inputString);
  //   for (var field in _formatFields) {
  //     field.parseLoose(stack, dateFields);
  //   }
  //   if (!stack.atEnd) {
  //     throw FormatException(
  //         'Characters remaining after date parsing in $inputString');
  //   }
  //   dateFields.verify(inputString);
  //   return dateFields.asDate();
  // }

  /// Given user input, attempt to parse the [inputString] into the anticipated
  /// format, treating it as being in the local timezone.
  ///
  /// If [inputString] does not match our format, throws a [FormatException].
  /// This will reject dates whose values are not strictly valid, even if the
  /// DateTime constructor will accept them. It will also reject strings with
  /// additional characters (including whitespace) after a valid date. For
  /// looser parsing, use [parse].
  /// TODO: implement this
  // DateTime parseStrict(String inputString, [bool utc = false]) =>
  //     _parse(inputString, utc: utc, strict: true);

  /// Given user input, attempt to parse the [inputString] into the anticipated
  /// format, treating it as being in the local timezone.
  ///
  /// If [inputString] does not match our format, returns `null`.
  /// This will reject dates whose values are not strictly valid, even if the
  /// DateTime constructor will accept them. It will also reject strings with
  /// additional characters (including whitespace) after a valid date. For
  /// looser parsing, use [tryParse].
  /// TODO: implement this
  // DateTime? tryParseStrict(String inputString, [bool utc = false]) {
  //   try {
  //     return parseStrict(inputString, utc);
  //   } on FormatException {
  //     return null;
  //   }
  // }

  /// TODO: implement this
  // DateTime _parse(String inputString, {bool utc = false, bool strict = false}) {
  //   // TODO(alanknight): The Closure code refers to special parsing of numeric
  //   // values with no delimiters, which we currently don't do. Should we?
  //   var dateFields = DateBuilder(locale, dateTimeConstructor);
  //   if (utc) dateFields.utc = true;
  //   dateFields.dateOnly = dateOnly;
  //   var stack = StringStack(inputString);
  //   for (var field in _formatFields) {
  //     field.parse(stack, dateFields);
  //   }
  //   if (strict && !stack.atEnd) {
  //     throw FormatException(
  //         'Characters remaining after date parsing in $inputString');
  //   }
  //   if (strict) dateFields.verify(inputString);
  //   return dateFields.asDate();
  // }

  /// Does our format only date fields, and no time fields.
  ///
  /// For example, 'yyyy-MM-dd' would be true, but 'dd hh:mm' would be false.
  bool get dateOnly => _dateOnly ??= _checkDateOnly;
  bool? _dateOnly;

  bool get _checkDateOnly => _formatFields.every((each) => each.forDate);

  /// Given user input, attempt to parse the [inputString] into the anticipated
  /// format, treating it as being in UTC.
  /// If [inputString] does not match our format, throws a [FormatException].
  ///
  /// The canonical Dart style name
  /// is [parseUtc], but [parseUTC] is retained
  /// for backward-compatibility.
  /// TODO: implement this
  // DateTime parseUTC(String inputString) => parse(inputString, true);

  /// Given user input, attempt to parse the [inputString] into the anticipated
  /// format, treating it as being in UTC.
  /// If [inputString] does not match our format, throws a [FormatException].
  ///
  /// The canonical Dart style name
  /// is [parseUtc], but [parseUTC] is retained
  /// for backward-compatibility.
  /// TODO: implement this
  // DateTime parseUtc(String inputString) => parse(inputString, true);

  /// Given user input, attempt to parse the [inputString] into the anticipated
  /// format, treating it as being in UTC.
  /// If [inputString] does not match our format, returns `null`.
  /// TODO: implement this
  // DateTime? tryParseUtc(String inputString) {
  //   try {
  //     return parseUtc(inputString);
  //   } on FormatException {
  //     return null;
  //   }
  // }

  /// Return the locale code in which we operate, e.g. 'en_US' or 'pt'.
  String get locale => _locale;

  /// Returns a list of all locales for which we have date formatting
  /// information.
  static List<String> allLocalesWithSymbols() => symbolList;

  /// The named constructors for this class are all conveniences for creating
  /// instances using one of the known 'skeleton' formats, and having code
  /// completion support for discovering those formats.
  /// So,
  ///
  /// ```dart
  /// GeneralDateFormat.yMd('en_US')
  /// ```
  ///
  /// is equivalent to
  ///
  /// ```dart
  /// GeneralDateFormat('yMd', 'en_US')
  /// ```
  ///
  /// To create a compound format you can use these constructors in combination
  /// with the 'add_*' methods below. e.g.
  ///
  /// ```dart
  /// GeneralDateFormat.yMd().add_Hms();
  /// ```
  ///
  /// If the optional [locale] is omitted, the format will be created using the
  /// default locale in [Intl.systemLocale].
  GeneralDateFormat.d([locale]) : this('d', locale);

  GeneralDateFormat.E([locale]) : this('E', locale);

  GeneralDateFormat.EEEE([locale]) : this('EEEE', locale);

  GeneralDateFormat.EEEEE([locale]) : this('EEEEE', locale);

  GeneralDateFormat.LLL([locale]) : this('LLL', locale);

  GeneralDateFormat.LLLL([locale]) : this('LLLL', locale);

  GeneralDateFormat.M([locale]) : this('M', locale);

  GeneralDateFormat.Md([locale]) : this('Md', locale);

  GeneralDateFormat.MEd([locale]) : this('MEd', locale);

  GeneralDateFormat.MMM([locale]) : this('MMM', locale);

  GeneralDateFormat.MMMd([locale]) : this('MMMd', locale);

  GeneralDateFormat.MMMEd([locale]) : this('MMMEd', locale);

  GeneralDateFormat.MMMM([locale]) : this('MMMM', locale);

  GeneralDateFormat.MMMMd([locale]) : this('MMMMd', locale);

  GeneralDateFormat.MMMMEEEEd([locale]) : this('MMMMEEEEd', locale);

  GeneralDateFormat.QQQ([locale]) : this('QQQ', locale);

  GeneralDateFormat.QQQQ([locale]) : this('QQQQ', locale);

  GeneralDateFormat.y([locale]) : this('y', locale);

  GeneralDateFormat.yM([locale]) : this('yM', locale);

  GeneralDateFormat.yMd([locale]) : this('yMd', locale);

  GeneralDateFormat.yMEd([locale]) : this('yMEd', locale);

  GeneralDateFormat.yMMM([locale]) : this('yMMM', locale);

  GeneralDateFormat.yMMMd([locale]) : this('yMMMd', locale);

  GeneralDateFormat.yMMMEd([locale]) : this('yMMMEd', locale);

  GeneralDateFormat.yMMMM([locale]) : this('yMMMM', locale);

  GeneralDateFormat.yMMMMd([locale]) : this('yMMMMd', locale);

  GeneralDateFormat.yMMMMEEEEd([locale]) : this('yMMMMEEEEd', locale);

  GeneralDateFormat.yQQQ([locale]) : this('yQQQ', locale);

  GeneralDateFormat.yQQQQ([locale]) : this('yQQQQ', locale);

  GeneralDateFormat.H([locale]) : this('H', locale);

  GeneralDateFormat.Hm([locale]) : this('Hm', locale);

  GeneralDateFormat.Hms([locale]) : this('Hms', locale);

  GeneralDateFormat.j([locale]) : this('j', locale);

  GeneralDateFormat.jm([locale]) : this('jm', locale);

  GeneralDateFormat.jms([locale]) : this('jms', locale);

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  GeneralDateFormat.jmv([locale]) : this('jmv', locale);

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  GeneralDateFormat.jmz([locale]) : this('jmz', locale);

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  GeneralDateFormat.jv([locale]) : this('jv', locale);

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  GeneralDateFormat.jz([locale]) : this('jz', locale);

  GeneralDateFormat.m([locale]) : this('m', locale);

  GeneralDateFormat.ms([locale]) : this('ms', locale);

  GeneralDateFormat.s([locale]) : this('s', locale);

  /// The 'add_*' methods append a particular skeleton to the format, or set
  /// it as the only format if none was previously set. These are primarily
  /// useful for creating compound formats. For example
  ///
  /// ```dart
  /// GeneralDateFormat.yMd().add_Hms();
  /// ```
  ///
  /// would create a date format that prints both the date and the time.
  GeneralDateFormat add_d() => addPattern('d');

  GeneralDateFormat add_E() => addPattern('E');

  GeneralDateFormat add_EEEE() => addPattern('EEEE');

  GeneralDateFormat add_LLL() => addPattern('LLL');

  GeneralDateFormat add_LLLL() => addPattern('LLLL');

  GeneralDateFormat add_M() => addPattern('M');

  GeneralDateFormat add_Md() => addPattern('Md');

  GeneralDateFormat add_MEd() => addPattern('MEd');

  GeneralDateFormat add_MMM() => addPattern('MMM');

  GeneralDateFormat add_MMMd() => addPattern('MMMd');

  GeneralDateFormat add_MMMEd() => addPattern('MMMEd');

  GeneralDateFormat add_MMMM() => addPattern('MMMM');

  GeneralDateFormat add_MMMMd() => addPattern('MMMMd');

  GeneralDateFormat add_MMMMEEEEd() => addPattern('MMMMEEEEd');

  GeneralDateFormat add_QQQ() => addPattern('QQQ');

  GeneralDateFormat add_QQQQ() => addPattern('QQQQ');

  GeneralDateFormat add_y() => addPattern('y');

  GeneralDateFormat add_yM() => addPattern('yM');

  GeneralDateFormat add_yMd() => addPattern('yMd');

  GeneralDateFormat add_yMEd() => addPattern('yMEd');

  GeneralDateFormat add_yMMM() => addPattern('yMMM');

  GeneralDateFormat add_yMMMd() => addPattern('yMMMd');

  GeneralDateFormat add_yMMMEd() => addPattern('yMMMEd');

  GeneralDateFormat add_yMMMM() => addPattern('yMMMM');

  GeneralDateFormat add_yMMMMd() => addPattern('yMMMMd');

  GeneralDateFormat add_yMMMMEEEEd() => addPattern('yMMMMEEEEd');

  GeneralDateFormat add_yQQQ() => addPattern('yQQQ');

  GeneralDateFormat add_yQQQQ() => addPattern('yQQQQ');

  GeneralDateFormat add_H() => addPattern('H');

  GeneralDateFormat add_Hm() => addPattern('Hm');

  GeneralDateFormat add_Hms() => addPattern('Hms');

  GeneralDateFormat add_j() => addPattern('j');

  GeneralDateFormat add_jm() => addPattern('jm');

  GeneralDateFormat add_jms() => addPattern('jms');

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  GeneralDateFormat add_jmv() => addPattern('jmv');

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  GeneralDateFormat add_jmz() => addPattern('jmz');

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  GeneralDateFormat add_jv() => addPattern('jv');

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  GeneralDateFormat add_jz() => addPattern('jz');

  GeneralDateFormat add_m() => addPattern('m');

  GeneralDateFormat add_ms() => addPattern('ms');

  GeneralDateFormat add_s() => addPattern('s');

  /// For each of the skeleton formats we also allow the use of the
  /// corresponding ICU constant names.
  static const String ABBR_MONTH = 'MMM';
  static const String DAY = 'd';
  static const String ABBR_WEEKDAY = 'E';
  static const String WEEKDAY = 'EEEE';
  static const String ABBR_STANDALONE_MONTH = 'LLL';
  static const String STANDALONE_MONTH = 'LLLL';
  static const String NUM_MONTH = 'M';
  static const String NUM_MONTH_DAY = 'Md';
  static const String NUM_MONTH_WEEKDAY_DAY = 'MEd';
  static const String ABBR_MONTH_DAY = 'MMMd';
  static const String ABBR_MONTH_WEEKDAY_DAY = 'MMMEd';
  static const String MONTH = 'MMMM';
  static const String MONTH_DAY = 'MMMMd';
  static const String MONTH_WEEKDAY_DAY = 'MMMMEEEEd';
  static const String ABBR_QUARTER = 'QQQ';
  static const String QUARTER = 'QQQQ';
  static const String YEAR = 'y';
  static const String YEAR_NUM_MONTH = 'yM';
  static const String YEAR_NUM_MONTH_DAY = 'yMd';
  static const String YEAR_NUM_MONTH_WEEKDAY_DAY = 'yMEd';
  static const String YEAR_ABBR_MONTH = 'yMMM';
  static const String YEAR_ABBR_MONTH_DAY = 'yMMMd';
  static const String YEAR_ABBR_MONTH_WEEKDAY_DAY = 'yMMMEd';
  static const String YEAR_MONTH = 'yMMMM';
  static const String YEAR_MONTH_DAY = 'yMMMMd';
  static const String YEAR_MONTH_WEEKDAY_DAY = 'yMMMMEEEEd';
  static const String YEAR_ABBR_QUARTER = 'yQQQ';
  static const String YEAR_QUARTER = 'yQQQQ';
  static const String HOUR24 = 'H';
  static const String HOUR24_MINUTE = 'Hm';
  static const String HOUR24_MINUTE_SECOND = 'Hms';
  static const String HOUR = 'j';
  static const String HOUR_MINUTE = 'jm';
  static const String HOUR_MINUTE_SECOND = 'jms';

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  static const String HOUR_MINUTE_GENERIC_TZ = 'jmv';

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  static const String HOUR_MINUTE_TZ = 'jmz';

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  static const String HOUR_GENERIC_TZ = 'jv';

  /// NOT YET IMPLEMENTED.
  // TODO(https://github.com/dart-lang/intl/issues/74)
  static const String HOUR_TZ = 'jz';
  static const String MINUTE = 'm';
  static const String MINUTE_SECOND = 'ms';
  static const String SECOND = 's';

  /// The locale in which we operate, e.g. 'en_US', or 'pt'.
  String _locale;

  /// The full template string. This may have been specified directly, or
  /// it may have been derived from a skeleton and the locale information
  /// on how to interpret that skeleton.
  String? _pattern;

  /// We parse the format string into individual [_DateFormatField] objects
  /// that are used to do the actual formatting and parsing. Do not use
  /// this variable directly, use the getter [_formatFields].
  List<_DateFormatField>? _formatFieldsPrivate;

  /// Getter for [_formatFieldsPrivate] that lazily initializes it.
  List<_DateFormatField> get _formatFields {
    if (_formatFieldsPrivate == null) {
      if (_pattern == null) _useDefaultPattern();
      _formatFieldsPrivate = parsePattern(_pattern!);
    }
    return _formatFieldsPrivate!;
  }

  /// We are being asked to do formatting without having set any pattern.
  /// Use a default.
  void _useDefaultPattern() {
    add_yMMMMd();
    add_jms();
  }

  /// A series of regular expressions used to parse a format string into its
  /// component fields.
  static final List<RegExp> _matchers = [
    // Quoted String - anything between single quotes, with escaping
    //   of single quotes by doubling them.
    // e.g. in the pattern 'hh 'o''clock'' will match 'o''clock'
    RegExp('^\'(?:[^\']|\'\')*\''),
    // Fields - any sequence of 1 or more of the same field characters.
    // e.g. in 'hh:mm:ss' will match hh, mm, and ss. But in 'hms' would
    // match each letter individually.
    RegExp('^(?:G+|y+|M+|k+|S+|E+|a+|h+|K+|H+|c+|L+|Q+|d+|D+|m+|s+|v+|z+|Z+)'),
    // Everything else - A sequence that is not quotes or field characters.
    // e.g. in 'hh:mm:ss' will match the colons.
    RegExp('^[^\'GyMkSEahKHcLQdDmsvzZ]+')
  ];

  /// Set our pattern, appending it to any existing patterns. Also adds a single
  /// space to separate the two.
  void _appendPattern(String inputPattern, [String separator = ' ']) {
    _pattern =
        _pattern == null ? inputPattern : '$_pattern$separator$inputPattern';
  }

  /// Add [inputPattern] to this instance as a pattern.
  ///
  /// If there was a previous pattern, then this appends to it, separating the
  /// two by [separator].  [inputPattern] is first looked up in our list of
  /// known skeletons.  If it's found there, then use the corresponding pattern
  /// for this locale.  If it's not, then treat [inputPattern] as an explicit
  /// pattern.
  GeneralDateFormat addPattern(String? inputPattern, [String separator = ' ']) {
    // TODO(alanknight): This is an expensive operation. Caching recently used
    // formats, or possibly introducing an entire 'locale' object that would
    // cache patterns for that locale could be a good optimization.
    // If we have already parsed the format fields, reset them.
    _formatFieldsPrivate = null;
    if (inputPattern == null) return this;
    if (!_availableSkeletons.containsKey(inputPattern)) {
      _appendPattern(inputPattern, separator);
    } else {
      _appendPattern(_availableSkeletons[inputPattern], separator);
    }
    return this;
  }

  /// Return the pattern that we use to format dates.
  String? get pattern => _pattern;

  /// Return the skeletons for our current locale.
  Map<dynamic, dynamic> get _availableSkeletons =>
      dateTimePatternMap[locale] ??
      (throw Exception("Date Patten not founded"));

  /// Return the [DateSymbols] information for the locale.
  ///
  /// This can be useful to find lists like the names of weekdays or months in a
  /// locale, but the structure of this data may change, and it's generally
  /// better to go through the [format] and [parse] APIs.
  ///
  /// If the locale isn't present, or is uninitialized, throws.
  DateSymbols get dateSymbols {
    if (_locale != lastDateSymbolLocale) {
      lastDateSymbolLocale = _locale;
      cachedDateSymbols = dateTimeSymbols[_locale];
    }
    return cachedDateSymbols!;
  }

  static final Map<String, bool> _useNativeDigitsByDefault = {};

  /// Should a new GeneralDateFormat for [locale] have useNativeDigits true.
  ///
  /// For example, for locale 'ar' when this setting is true, GeneralDateFormat will
  /// format using Eastern Arabic digits, e.g. '\u0660, \u0661, \u0662'. If it
  /// is false, a new GeneralDateFormat will format using ASCII digits.
  static bool shouldUseNativeDigitsByDefaultFor(String locale) =>
      _useNativeDigitsByDefault[locale] ?? true;

  /// Indicate if a new GeneralDateFormat for [locale] should have useNativeDigits
  /// true.
  ///
  /// For example, for locale 'ar' when this setting is true, GeneralDateFormat will
  /// format using Eastern Arabic digits, e.g. '\u0660, \u0661, \u0662'. If it
  /// is false, a new GeneralDateFormat will format using ASCII digits.
  ///
  /// If not indicated, the default value is true, so native digits will be
  /// used.
  static void useNativeDigitsByDefaultFor(String locale, bool value) {
    _useNativeDigitsByDefault[locale] = value;
  }

  bool? _useNativeDigits;

  /// Should we use native digits for printing DateTime, or ASCII.
  ///
  /// The default for this can be set using [useNativeDigitsByDefaultFor].
  bool get useNativeDigits => _useNativeDigits == null
      ? _useNativeDigits = shouldUseNativeDigitsByDefaultFor(locale)
      : _useNativeDigits!;

  /// Should we use native digits for printing DateTime, or ASCII.
  set useNativeDigits(bool native) {
    _useNativeDigits = native;
    // Invalidate any cached information that would depend on this setting.
    _digitMatcher = null;
    _localeZeroCodeUnit = null;
    _localeZero = null;
  }

  /// Caches digit matchers that we have already calculated for particular
  /// digits.
  ///
  /// Keys are the zero digits, and the values are matchers for digits in that
  /// locale.
  static final Map<String, RegExp> _digitMatchers = {};

  RegExp? _digitMatcher;

  /// A regular expression which matches against digits for this locale.
  RegExp get digitMatcher {
    if (_digitMatcher != null) return _digitMatcher!;
    _digitMatcher = _digitMatchers.putIfAbsent(localeZero, _initDigitMatcher);
    return _digitMatcher!;
  }

  int? _localeZeroCodeUnit;

  /// For performance, keep the code unit of the zero digit available.
  int get localeZeroCodeUnit => _localeZeroCodeUnit == null
      ? _localeZeroCodeUnit = localeZero.codeUnitAt(0)
      : _localeZeroCodeUnit!;

  String? _localeZero;

  /// For performance, keep the zero digit available.
  String get localeZero => _localeZero == null
      ? _localeZero = useNativeDigits ? dateSymbols.ZERODIGIT ?? '0' : '0'
      : _localeZero!;

  // Does this use non-ASCII digits, e.g. Eastern Arabic.
  bool get usesNativeDigits =>
      useNativeDigits && _localeZeroCodeUnit != '0'.codeUnitAt(0);

  /// Does this use ASCII digits
  bool get usesAsciiDigits => !usesNativeDigits;

  /// Given a numeric string in ASCII digits, return a copy updated for our
  /// locale digits.
  String _localizeDigits(String numberString) {
    if (usesAsciiDigits) return numberString;
    var newDigits = List<int>.filled(numberString.length, 0);
    var oldDigits = numberString.codeUnits;
    for (var i = 0; i < numberString.length; i++) {
      newDigits[i] = oldDigits[i] + localeZeroCodeUnit - '0'.codeUnitAt(0);
    }
    return String.fromCharCodes(newDigits);
  }

  /// A regular expression that matches for digits in a particular
  /// locale, defined by the digit for zero in that locale.
  RegExp _initDigitMatcher() {
    if (usesAsciiDigits) return RegExp(r'^\d+');
    var localeDigits = Iterable.generate(10, (i) => i)
        .map((i) => localeZeroCodeUnit + i)
        .toList();
    var localeDigitsString = String.fromCharCodes(localeDigits);
    return RegExp('^[$localeDigitsString]+');
  }

  /// Return true if the locale exists, or if it is null. The null case
  /// is interpreted to mean that we use the default locale.
  static bool localeExists(String? localeName) {
    if (localeName == null) return false;
    return symbolList.contains(localeName);
  }

  static List<_DateFormatField Function(String, GeneralDateFormat)>
      get _fieldConstructors => [
            (pattern, parent) => _DateFormatQuotedField(pattern, parent),
            (pattern, parent) => _DateFormatPatternField(pattern, parent),
            (pattern, parent) => _DateFormatLiteralField(pattern, parent)
          ];

  /// Parse the template pattern and return a list of field objects.
  @visibleForTesting
  @Deprecated('clients should not depend on this internal method')
  // ignore: library_private_types_in_public_api
  List<_DateFormatField> parsePattern(String pattern) {
    return _parsePatternHelper(pattern).reversed.toList();
  }

  /// Recursive helper for parsing the template pattern.
  List<_DateFormatField> _parsePatternHelper(String pattern) {
    if (pattern.isEmpty) return [];

    var matched = _match(pattern);
    if (matched == null) return [];

    var parsed =
        _parsePatternHelper(pattern.substring(matched.fullPattern().length));
    parsed.add(matched);
    return parsed;
  }

  /// Find elements in a string that are patterns for specific fields.
  _DateFormatField? _match(String pattern) {
    for (var i = 0; i < _matchers.length; i++) {
      var regex = _matchers[i];
      var match = regex.firstMatch(pattern);
      if (match != null) {
        return _fieldConstructors[i](match.group(0)!, this);
      }
    }
    return null;
  }
}

/// Defines a function type for creating DateTime instances.
typedef _DateTimeConstructor = DateTime Function(int year, int month, int day,
    int hour24, int minute, int second, int fractionalSecond, bool utc);
