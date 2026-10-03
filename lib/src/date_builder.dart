import 'package:clock/clock.dart';
import 'package:general_datetime/general_datetime.dart';

import 'general_date_format_internal.dart';

/// Calendar-aware construction and validation of parsed date fields.
class DateBuilder {
  late int year, month, day;
  int dayOfYear = 0, hour = 0, minute = 0, second = 0, fractionalSecond = 0;
  bool pm = false, utc = false, dateOnly = false;
  bool _hasAmbiguousCentury = false;
  bool hasDayOfYear = false;
  int? hourMinimum, hourMaximum;
  int? _inputHour;
  int? era;
  DateTime? _date;
  int? _resolvedYear;
  final DateTime generalDateTime;

  DateBuilder(this.generalDateTime) {
    calendarType(generalDateTime);
    final epoch = _inCalendar(DateTime.utc(1970));
    year = epoch.year;
    month = epoch.month;
    day = epoch.day;
  }

  DateTime _inCalendar(DateTime date) {
    if (generalDateTime is PersianDateTime) {
      return PersianDateTime.fromDateTime(date);
    }
    if (generalDateTime is HijriDateTime) {
      final converted = HijriDateTime.fromDateTime(date);
      return _construct(
          converted.year,
          converted.month,
          converted.day,
          converted.hour,
          converted.minute,
          converted.second,
          converted.millisecond);
    }
    return date;
  }

  void setYear(int x) => year = x;
  set hasAmbiguousCentury(bool value) => _hasAmbiguousCentury = value;
  void setMonth(int x) => month = x;
  void setDay(int x) => day = x;
  void setDayOfYear(int x) {
    dayOfYear = x;
    hasDayOfYear = true;
  }

  void setHour(int x) => hour = x;
  void setMinute(int x) => minute = x;
  void setSecond(int x) => second = x;
  void setFractionalSecond(int x) => fractionalSecond = x;

  /// Retain the original value so strict parsing checks the token's range.
  void setPatternHour(int value, int minimum, int maximum) {
    _inputHour = value;
    hourMinimum = minimum;
    hourMaximum = maximum;
    hour = value;
  }

  int get dayOrDayOfYear => hasDayOfYear ? dayOfYear : day;
  int get hour24 => pm ? hour + 12 : hour;

  void verify(String input) {
    _verify(month, 1, 12, 'month', input);
    if (_inputHour != null) {
      _verify(_inputHour!, hourMinimum!, hourMaximum!, 'hour', input);
    }
    _verify(hour24, 0, 23, 'hour', input);
    _verify(minute, 0, 59, 'minute', input);
    _verify(second, 0, 59, 'second', input);
    _verify(fractionalSecond, 0, 999, 'fractional second', input);
    final date = asDate();
    final minimumHour = dateOnly && date.hour == 1 ? 0 : date.hour;
    _verify(hour24, minimumHour, date.hour, 'hour', input);
    if (hasDayOfYear) {
      final actual = calendarDayOfYear(date);
      _verify(dayOfYear, actual, actual, 'dayOfYear', input);
    } else {
      _verify(day, date.day, date.day, 'day', input);
      _verify(month, date.month, date.month, 'month', input);
    }
    _verify(_estimatedYear, date.year, date.year, 'year', input);
  }

  void _verify(
      int value, int minimum, int maximum, String field, String input) {
    if (value < minimum || value > maximum) {
      throw FormatException(
          'Invalid $field: $value (expected $minimum..$maximum)', input);
    }
  }

  DateTime asDate() {
    if (_date != null) return _date!;
    try {
      _date = _construct(_estimatedYear, hasDayOfYear ? 1 : month,
          dayOrDayOfYear, hour24, minute, second, fractionalSecond);
    } on ArgumentError catch (error) {
      throw FormatException('Date outside the calendar range: $error');
    }
    return _date!;
  }

  int get _estimatedYear => _resolvedYear ??= _estimateYear();

  int _estimateYear() {
    if (era == 0 && generalDateTime is! GeneralDateTimeInterface) {
      return 1 - year;
    }
    if (!_hasAmbiguousCentury || year < 0 || year >= 100) return year;
    final now = _inCalendar(utc ? clock.now().toUtc() : clock.now().toLocal());
    final upper = _construct(now.year + 20, now.month, now.day, now.hour,
        now.minute, now.second, now.millisecond);
    var candidate = (upper.year ~/ 100) * 100 + year;
    // Compare calendar fields, without relying on DateTime subclass internals.
    final candidateDate = _construct(candidate, hasDayOfYear ? 1 : month,
        dayOrDayOfYear, hour24, minute, second, fractionalSecond);
    final inputFields = [
      candidateDate.year,
      candidateDate.month,
      candidateDate.day,
      candidateDate.hour,
      candidateDate.minute,
      candidateDate.second,
      candidateDate.millisecond
    ];
    final upperFields = [
      upper.year,
      upper.month,
      upper.day,
      upper.hour,
      upper.minute,
      upper.second,
      upper.millisecond
    ];
    for (var i = 0; i < inputFields.length; i++) {
      if (inputFields[i] == upperFields[i]) continue;
      if (inputFields[i] > upperFields[i]) candidate -= 100;
      break;
    }
    return candidate;
  }

  DateTime _construct(int year, int month, int day, int hour, int minute,
      int second, int millisecond) {
    if (generalDateTime is PersianDateTime) {
      return utc
          ? PersianDateTime.utc(
              year, month, day, hour, minute, second, millisecond)
          : PersianDateTime(
              year, month, day, hour, minute, second, millisecond);
    }
    if (generalDateTime is HijriDateTime) {
      final result = utc
          ? HijriDateTime.utc(
              year, month, day, hour, minute, second, millisecond)
          : HijriDateTime(year, month, day, hour, minute, second, millisecond);
      if (!utc || result.isUtc) return result;
      // Hosted general_datetime 2.1.0 loses UTC during Hijri normalization.
      // Its ISO parser preserves it; use already-normalized calendar fields.
      String two(int value) => '$value'.padLeft(2, '0');
      return HijriDateTime.parse('${result.year.toString().padLeft(4, '0')}-'
          '${two(result.month)}-${two(result.day)}T${two(result.hour)}:'
          '${two(result.minute)}:${two(result.second)}.'
          '${result.millisecond.toString().padLeft(3, '0')}Z');
    }
    return utc
        ? DateTime.utc(year, month, day, hour, minute, second, millisecond)
        : DateTime(year, month, day, hour, minute, second, millisecond);
  }
}
