part of 'general_date_format.dart';

/// This is a private class internal to DateFormat which is used for formatting
/// particular fields in a template. e.g. if the format is hh:mm:ss then the
/// fields would be 'hh', ':', 'mm', ':', and 'ss'. Each type of field knows
/// how to format that portion of a date.
abstract class _DateFormatField {
  /// The format string that defines us, e.g. 'hh'
  final String pattern;

  /// The DateFormat that we are part of.
  GeneralDateFormat parent;

  /// Trimmed version of [pattern].
  final String _trimmedPattern;

  _DateFormatField(this.pattern, this.parent)
      : _trimmedPattern = pattern.trim();

  /// Does this field potentially represent part of a Date, i.e. is not
  /// time-specific.
  bool get forDate => true;

  /// Return the width of [pattern]. Different widths represent different
  /// formatting options. See the comment for DateFormat for details.
  int get width => pattern.length;

  String fullPattern() => pattern;

  @override
  String toString() => pattern;

  /// Format date according to our specification and return the result.
  String format(GeneralDateTimeInterface date) => pattern;

  /// Abstract method for subclasses to implementing parsing for their format.
  void parse(StringStack input, DateBuilder dateFields);

  /// Abstract method for subclasses to implementing 'loose' parsing for
  /// their format, accepting input case-insensitively, and allowing some
  /// delimiters to be skipped.
  void parseLoose(StringStack input, DateBuilder dateFields);

  /// Parse a literal field. We just look for the exact input.
  void parseLiteral(StringStack input) {
    var found = input.read(width);
    if (found != pattern) {
      throwFormatException(input);
    }
  }

  /// Parse a literal field. We accept either an exact match, or an arbitrary
  /// amount of whitespace.
  ///
  /// Any whitespace which occurs before or after the literal field is trimmed
  /// from the input stack. Any leading or trailing whitespace in the literal
  /// field's format specification is also trimmed before matching is
  /// attempted. Therefore, leading and trailing whitespace is optional, and
  /// arbitrary additional whitespace may be added before/after the literal.
  void parseLiteralLoose(StringStack input) {
    _trimWhitespace(input);
    var found = input.peek(_trimmedPattern.length);
    if (found == _trimmedPattern) {
      input.pop(_trimmedPattern.length);
    }
    _trimWhitespace(input);
  }

  void _trimWhitespace(StringStack input) {
    while (!input.atEnd && input.peek().trim().isEmpty) {
      input.pop();
    }
  }

  /// Throw a format exception with an error message indicating the position.
  Never throwFormatException(StringStack stack) =>
      throw FormatException('Trying to read $this from $stack');
}

/// Represents a literal field - a sequence of characters that doesn't
/// change according to the date's data. As such, the implementation
/// is extremely simple.
class _DateFormatLiteralField extends _DateFormatField {
  _DateFormatLiteralField(super.pattern, super.parent);

  @override
  void parse(StringStack input, DateBuilder dateFields) => parseLiteral(input);

  @override
  void parseLoose(StringStack input, DateBuilder dateFields) =>
      parseLiteralLoose(input);
}

/// Represents a literal field with quoted characters in it. This is
/// only slightly more complex than a _DateFormatLiteralField.
class _DateFormatQuotedField extends _DateFormatField {
  final String _fullPattern;

  @override
  String fullPattern() => _fullPattern;

  _DateFormatQuotedField(String pattern, GeneralDateFormat parent)
      : _fullPattern = pattern,
        super(_patchQuotes(pattern), parent);

  @override
  void parse(StringStack input, DateBuilder dateFields) => parseLiteral(input);

  @override
  void parseLoose(StringStack input, DateBuilder dateFields) =>
      parseLiteralLoose(input);

  static final _twoEscapedQuotes = RegExp(r"''");

  static String _patchQuotes(String pattern) {
    if (pattern == "''") {
      return "'";
    } else {
      return pattern
          .substring(1, pattern.length - 1)
          .replaceAll(_twoEscapedQuotes, "'");
    }
  }
}

/// A field that parses 'loosely', meaning that we'll accept input that is
/// missing delimiters, has upper/lower case mixed up, and might not strictly
/// conform to the pattern, e.g. the pattern calls for Sep we might accept
/// sep, september, sEPTember. Doesn't affect numeric fields.
class _LoosePatternField extends _DateFormatPatternField {
  _LoosePatternField(super.pattern, super.parent);

  /// Parse from a list of possibilities, but case-insensitively.
  /// Assumes that input is lower case.
  @override
  int parseEnumeratedString(StringStack input, List<String> possibilities) {
    var lowercasePossibilities =
        possibilities.map((x) => x.toLowerCase()).toList();
    try {
      return super.parseEnumeratedString(input, lowercasePossibilities);
    } on FormatException {
      return -1;
    }
  }

  /// Parse a month name, case-insensitively, and set it in [dateFields].
  /// Assumes that [input] is lower case.
  @override
  void parseMonth(StringStack input, DateBuilder dateFields) {
    if (width <= 2) {
      handleNumericField(input, dateFields.setMonth);
      return;
    }
    var possibilities = [symbols.MONTHS, symbols.SHORTMONTHS];
    for (var monthNames in possibilities) {
      var month = parseEnumeratedString(input, monthNames);
      if (month != -1) {
        dateFields.month = month + 1;
        return;
      }
    }
    throwFormatException(input);
  }

  /// Parse a standalone day name, case-insensitively.
  /// Assumes that input is lower case. Doesn't do anything
  @override
  void parseStandaloneDay(StringStack input) {
    // This is ignored, but we still have to skip over it the correct amount.
    if (width <= 2) {
      handleNumericField(input, (x) => x);
      return;
    }
    var possibilities = [
      symbols.STANDALONEWEEKDAYS,
      symbols.STANDALONESHORTWEEKDAYS
    ];
    for (var dayNames in possibilities) {
      var day = parseEnumeratedString(input, dayNames);
      if (day != -1) {
        return;
      }
    }
  }

  /// Parse a standalone month name, case-insensitively, and set it in
  /// [dateFields]. Assumes that input is lower case.
  @override
  void parseStandaloneMonth(StringStack input, DateBuilder dateFields) {
    if (width <= 2) {
      handleNumericField(input, dateFields.setMonth);
      return;
    }
    var possibilities = [
      symbols.STANDALONEMONTHS,
      symbols.STANDALONESHORTMONTHS
    ];
    for (var monthNames in possibilities) {
      var month = parseEnumeratedString(input, monthNames);
      if (month != -1) {
        dateFields.month = month + 1;
        return;
      }
    }
    throwFormatException(input);
  }

  /// Parse a day of the week name, case-insensitively.
  /// Assumes that input is lower case. Doesn't do anything
  @override
  void parseDayOfWeek(StringStack input) {
    // This is IGNORED, but we still have to skip over it the correct amount.
    if (width <= 2) {
      handleNumericField(input, (x) => x);
      return;
    }
    var possibilities = [symbols.WEEKDAYS, symbols.SHORTWEEKDAYS];
    for (var dayNames in possibilities) {
      var day = parseEnumeratedString(input, dayNames);
      if (day != -1) {
        return;
      }
    }
  }
}

/*
 * Represents a field in the pattern that formats some aspect of the
 * date. Consists primarily of a switch on the particular pattern characters
 * to determine what to do.
 */
class _DateFormatPatternField extends _DateFormatField {
  _DateFormatPatternField(super.pattern, super.parent);

  /// Format date according to our specification and return the result.
  @override
  String format(GeneralDateTimeInterface date) => formatField(date);

  /// Parse the date according to our specification and put the result
  /// into the correct place in dateFields.
  @override
  void parse(StringStack input, DateBuilder dateFields) =>
      parseField(input, dateFields);

  /// Parse the date according to our specification and put the result
  /// into the correct place in dateFields. Allow looser parsing, accepting
  /// case-insensitive input and skipped delimiters.
  @override
  void parseLoose(StringStack input, DateBuilder dateFields) =>
      _LoosePatternField(pattern, parent).parse(input, dateFields);

  bool? _forDate;

  /// Is this field involved in computing the date portion, as opposed to the
  /// time.
  ///
  /// The [pattern] will contain one or more of a particular format character,
  /// e.g. 'yyyy' for a four-digit year. This hard-codes all the pattern
  /// characters that pertain to dates. The remaining characters, 'ahHkKms' are
  /// all time-related. See e.g. [formatField]
  @override
  bool get forDate => _forDate ??= 'cdDEGLMQvyZz'.contains(pattern[0]);

  /// Parse a field representing part of a date pattern. Note that we do not
  /// return a value, but rather build up the result in [builder].
  void parseField(StringStack input, DateBuilder builder) {
    try {
      switch (pattern[0]) {
        case 'a':
          parseAmPm(input, builder);
          break;
        case 'c':
          parseStandaloneDay(input);
          break;
        case 'd':
          handleNumericField(input, builder.setDay);
          break; // day
        // Day of year. Setting month=January with any day of the year works
        case 'D':
          handleNumericField(input, builder.setDayOfYear);
          break; // dayofyear
        case 'E':
          parseDayOfWeek(input);
          break;
        case 'G':
          parseEra(input);
          break; // era
        case 'h':
          parse1To12Hours(input, builder);
          break;
        case 'H':
          handleNumericField(input, builder.setHour);
          break; // hour 0-23
        case 'K':
          handleNumericField(input, builder.setHour);
          break; //hour 0-11
        case 'k':
          handleNumericField(input, builder.setHour, -1);
          break; //hr 1-24
        case 'L':
          parseStandaloneMonth(input, builder);
          break;
        case 'M':
          parseMonth(input, builder);
          break;
        case 'm':
          handleNumericField(input, builder.setMinute);
          break; // minutes
        case 'Q':
          break; // quarter
        case 'S':
          handleNumericField(input, builder.setFractionalSecond);
          break;
        case 's':
          handleNumericField(input, builder.setSecond);
          break;
        case 'v':
          break; // time zone id
        case 'y':
          parseYear(input, builder);
          break;
        case 'z':
          break; // time zone
        case 'Z':
          break; // time zone RFC
        default:
          return;
      }
    } catch (e) {
      throwFormatException(input);
    }
  }

  /// Formatting logic if we are of type FIELD
  String formatField(GeneralDateTimeInterface date) {
    switch (pattern[0]) {
      case 'a':
        return formatAmPm(date);
      case 'c':
        return formatStandaloneDay(date);
      case 'd':
        return formatDayOfMonth(date);
      case 'D':
        return formatDayOfYear(date);
      case 'E':
        return formatDayOfWeek(date);
      case 'G':
        return formatEra(date);
      case 'h':
        return format1To12Hours(date);
      case 'H':
        return format0To23Hours(date);
      case 'K':
        return format0To11Hours(date);
      case 'k':
        return format24Hours(date);
      case 'L':
        return formatStandaloneMonth(date);
      case 'M':
        return formatMonth(date);
      case 'm':
        return formatMinutes(date);
      case 'Q':
        return formatQuarter(date);
      case 'S':
        return formatFractionalSeconds(date);
      case 's':
        return formatSeconds(date);
      case 'y':
        return formatYear(date);
      default:
        return '';
    }
  }

  /// Return the symbols for our current locale.
  DateSymbols get symbols => parent.dateSymbols;

  String formatEra(GeneralDateTimeInterface date) {
    var era = date.year > 0 ? 1 : 0;
    return width >= 4 ? symbols.ERANAMES[era] : symbols.ERAS[era];
  }

  String formatYear(GeneralDateTimeInterface date) {
    var year = date.year;
    if (year < 0) year = -year;
    return width == 2 ? padTo(2, year % 100) : padTo(width, year);
  }

  /// We are given [inputStack] as an stack from which we want to read a date. We
  /// can't dynamically build up a date, so the caller has a list of the
  /// constructor arguments and a position at which to set it
  /// (year,month,day,hour,minute,second,fractionalSecond) and gives us a setter
  /// for it.
  ///
  /// Then after all parsing is done we construct a date from the
  /// arguments.
  ///
  /// This method handles reading any of the numeric fields. The [offset]
  /// argument allows us to compensate for zero-based versus one-based values.
  void handleNumericField(
    StringStack inputStack,
    void Function(int) setter, [
    int offset = 0,
  ]) {
    var result = _nextInteger(
      inputStack,
      parent.digitMatcher,
      parent.localeZeroCodeUnit,
    );
    setter(result + offset);
  }

  /// Read as much content as [digitMatcher] matches from the current position,
  /// and parse the result as an integer, advancing the index.
  ///
  /// The regular expression [digitMatcher] is used to find the substring which
  /// matches an integer.
  /// The codeUnit of the local zero [zeroDigit] is used to anchor the parsing
  /// into digits.
  int _nextInteger(StringStack inputStack, RegExp digitMatcher, int zeroDigit) {
    var string = digitMatcher.stringMatch(inputStack.peekAll());
    if (string == null || string.isEmpty) {
      return throwFormatException(inputStack);
    }
    inputStack.pop(string.length);
    if (zeroDigit != '0'.codeUnitAt(0)) {
      var codeUnits = string.codeUnits;
      string = String.fromCharCodes(List.generate(
        codeUnits.length,
        (index) => codeUnits[index] - zeroDigit + '0'.codeUnitAt(0),
        growable: false,
      ));
    }
    return int.parse(string);
  }

  /// We are given [input] as a stack from which we want to read a date. We
  /// can't dynamically build up a date, so the caller has a list of the
  /// constructor arguments and a position at which to set it
  /// (year,month,day,hour,minute,second,fractionalSecond) and gives us a setter
  /// for it.
  ///
  /// Then after all parsing is done we construct a date from the
  /// arguments. This method handles reading any of string fields from an
  /// enumerated set.
  int parseEnumeratedString(StringStack input, List<String> possibilities) {
    var results = [
      for (var i = 0; i < possibilities.length; i++)
        if (input.peek(possibilities[i].length) == possibilities[i]) i
    ];
    if (results.isEmpty) throwFormatException(input);
    var longestResult = results.first;
    for (var result in results.skip(1)) {
      if (possibilities[result].length >= possibilities[longestResult].length) {
        longestResult = result;
      }
    }
    input.pop(possibilities[longestResult].length);
    return longestResult;
  }

  void parseYear(StringStack input, DateBuilder builder) {
    handleNumericField(input, builder.setYear);
    builder.hasAmbiguousCentury = width == 2;
  }

  String formatMonth(GeneralDateTimeInterface date) {
    switch (width) {
      case 5:
        return symbols.NARROWMONTHS[date.month - 1];
      case 4:
        return symbols.MONTHS[date.month - 1];
      case 3:
        return symbols.SHORTMONTHS[date.month - 1];
      default:
        return padTo(width, date.month);
    }
  }

  void parseMonth(StringStack input, DateBuilder dateFields) {
    List<String> possibilities;
    switch (width) {
      case 5:
        possibilities = symbols.NARROWMONTHS;
        break;
      case 4:
        possibilities = symbols.MONTHS;
        break;
      case 3:
        possibilities = symbols.SHORTMONTHS;
        break;
      default:
        return handleNumericField(input, dateFields.setMonth);
    }
    dateFields.month = parseEnumeratedString(input, possibilities) + 1;
  }

  String format24Hours(GeneralDateTimeInterface date) {
    var hour = date.hour == 0 ? 24 : date.hour;
    return padTo(width, hour);
  }

  String formatFractionalSeconds(GeneralDateTimeInterface date) {
    // Always print at least 3 digits. If the width is greater, append 0s
    var basic = padTo(3, date.millisecond);
    if (width - 3 > 0) {
      var extra = padTo(width - 3, 0);
      return basic + extra;
    } else {
      return basic;
    }
  }

  String formatAmPm(GeneralDateTimeInterface date) {
    var hours = date.hour;
    var index = (hours >= 12) && (hours < 24) ? 1 : 0;
    var ampm = symbols.AMPMS;
    return ampm[index];
  }

  void parseAmPm(StringStack input, DateBuilder dateFields) {
    var ampm = parseEnumeratedString(input, symbols.AMPMS);
    if (ampm == 1) dateFields.pm = true;
  }

  String format1To12Hours(GeneralDateTimeInterface date) {
    var hours = date.hour;
    if (date.hour > 12) hours = hours - 12;
    if (hours == 0) hours = 12;
    return padTo(width, hours);
  }

  void parse1To12Hours(StringStack input, DateBuilder dateFields) {
    handleNumericField(input, dateFields.setHour);
    if (dateFields.hour == 12) dateFields.hour = 0;
  }

  String format0To11Hours(GeneralDateTimeInterface date) =>
      padTo(width, date.hour % 12);

  String format0To23Hours(GeneralDateTimeInterface date) =>
      padTo(width, date.hour);

  String formatStandaloneDay(GeneralDateTimeInterface date) {
    switch (width) {
      case 5:
        return symbols.STANDALONENARROWWEEKDAYS[date.weekday % 7];
      case 4:
        return symbols.STANDALONEWEEKDAYS[date.weekday % 7];
      case 3:
        return symbols.STANDALONESHORTWEEKDAYS[date.weekday % 7];
      default:
        return padTo(1, date.day);
    }
  }

  void parseStandaloneDay(StringStack input) {
    // This is ignored, but we still have to skip over it the correct amount.
    List<String> possibilities;
    switch (width) {
      case 5:
        possibilities = symbols.STANDALONENARROWWEEKDAYS;
        break;
      case 4:
        possibilities = symbols.STANDALONEWEEKDAYS;
        break;
      case 3:
        possibilities = symbols.STANDALONESHORTWEEKDAYS;
        break;
      default:
        return handleNumericField(input, (x) => x);
    }
    parseEnumeratedString(input, possibilities);
  }

  String formatStandaloneMonth(GeneralDateTimeInterface date) {
    switch (width) {
      case 5:
        return symbols.STANDALONENARROWMONTHS[date.month - 1];
      case 4:
        return symbols.STANDALONEMONTHS[date.month - 1];
      case 3:
        return symbols.STANDALONESHORTMONTHS[date.month - 1];
      default:
        return padTo(width, date.month);
    }
  }

  void parseStandaloneMonth(StringStack input, DateBuilder dateFields) {
    List<String> possibilities;
    switch (width) {
      case 5:
        possibilities = symbols.STANDALONENARROWMONTHS;
        break;
      case 4:
        possibilities = symbols.STANDALONEMONTHS;
        break;
      case 3:
        possibilities = symbols.STANDALONESHORTMONTHS;
        break;
      default:
        return handleNumericField(input, dateFields.setMonth);
    }
    dateFields.month = parseEnumeratedString(input, possibilities) + 1;
  }

  String formatQuarter(GeneralDateTimeInterface date) {
    var quarter = ((date.month - 1) / 3).truncate();
    switch (width) {
      case 4:
        return symbols.QUARTERS[quarter];
      case 3:
        return symbols.SHORTQUARTERS[quarter];
      default:
        return padTo(width, quarter + 1);
    }
  }

  String formatDayOfMonth(GeneralDateTimeInterface date) {
    return padTo(width, date.day);
  }

  String formatDayOfYear(GeneralDateTimeInterface date) =>
      padTo(width, date.dayOfYear);

  /// See also http://www.unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table
  String formatDayOfWeek(GeneralDateTimeInterface date) {
    // Note that Dart's weekday returns 1 for Monday and 7 for Sunday.
    return switch (width) {
      /// "Abbreviated" - `Tue` for en-US
      <= 3 => symbols.SHORTWEEKDAYS,

      /// "Wide" - `Tuesday` for en-US
      == 4 => symbols.WEEKDAYS,

      /// "Narrow" - `T` for en-US
      == 5 => symbols.NARROWWEEKDAYS,
      >= 6 =>
        throw UnsupportedError('"Short" weekdays are currently not supported.'),
      int() => throw AssertionError('unreachable'),
    }[(date.weekday) % 7];
  }

  void parseDayOfWeek(StringStack input) {
    var possibilities = width >= 4 ? symbols.WEEKDAYS : symbols.SHORTWEEKDAYS;
    parseEnumeratedString(input, possibilities);
  }

  void parseEra(StringStack input) {
    var possibilities = width >= 4 ? symbols.ERANAMES : symbols.ERAS;
    parseEnumeratedString(input, possibilities);
  }

  String formatMinutes(GeneralDateTimeInterface date) =>
      padTo(width, date.minute);

  String formatSeconds(GeneralDateTimeInterface date) =>
      padTo(width, date.second);

  /// Return a string representation of the object padded to the left with
  /// zeros. Primarily useful for numbers.
  String padTo(int width, Object toBePrinted) =>
      parent._localizeDigits('$toBePrinted'.padLeft(width, '0'));
}
