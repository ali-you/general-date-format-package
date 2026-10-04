import 'package:clock/clock.dart';
import 'package:general_datetime_core/general_datetime_core.dart';

import 'general_date_format_internal.dart';

/// Calendar-aware construction and validation of parsed date fields.
class DateBuilder {
  late int year, month, day;
  int dayOfYear = 0, hour = 0, minute = 0, second = 0, fractionalSecond = 0;
  int microsecond = 0;
  bool pm = false, utc = false, dateOnly = false;
  bool _hasAmbiguousCentury = false;
  bool hasDayOfYear = false;
  int? _hourMaximum;
  int? era;
  DateTime? _date;
  DateTime? _centuryWindowEnd;
  int? _resolvedYear;
  final DateTime generalDateTime;
  final bool strict;
  bool _hasMonth = false, _hasDay = false;
  int? _quarter;
  final _months = <Set<int>>[];
  final _days = <int>[];
  final _quarters = <int>[];
  final _ordinals = <int>[];
  final _weekdays = <Set<int>>[];
  final _localWeekdays = <({int value, int firstDay})>[];
  final _years = <({int value, bool ambiguous})>[];
  final _hours = <({int value, int minimum, int maximum})>[];
  final _timeInputs = <String, List<int>>{};
  final _eras = <int>[];
  final _periods = <int>[];

  DateBuilder(this.generalDateTime, {this.strict = false}) {
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
      return HijriDateTime.fromDateTime(date);
    }
    return date;
  }

  void setYear(int x, {bool ambiguous = false}) {
    year = x;
    _hasAmbiguousCentury = ambiguous;
    _years.add((value: x, ambiguous: ambiguous));
  }

  void setMonth(int x, {Set<int>? candidates}) {
    month = x;
    _hasMonth = true;
    _months.add(candidates ?? {x});
    if (strict) {
      final common = _months.reduce((a, b) => a.intersection(b));
      if (common.isNotEmpty && !common.contains(x)) month = common.last;
    }
  }

  void setDay(int x) {
    day = x;
    _hasDay = true;
    _days.add(x);
  }

  void setQuarter(int x) {
    _quarter = x;
    _quarters.add(x);
    if (!strict) {
      month = (x - 1) * 3 + 1;
      day = 1;
    }
  }

  void setWeekday(Set<int> candidates) => _weekdays.add(candidates);

  void setLocalWeekday(int value, int firstDay) =>
      _localWeekdays.add((value: value, firstDay: firstDay));

  void setDayOfYear(int x) {
    dayOfYear = x;
    hasDayOfYear = true;
    _ordinals.add(x);
  }

  void setMinute(int x) {
    minute = x;
    _recordTime('minute', x);
  }

  void setSecond(int x) {
    second = x;
    _recordTime('second', x);
  }

  void setFractionalSecond(int x) {
    setFractionalMicroseconds(x * 1000);
  }

  void setFractionalMicroseconds(int x) {
    fractionalSecond = x ~/ 1000;
    microsecond = x % 1000;
    _recordTime('fractional second', x);
  }

  void _recordTime(String field, int value) =>
      (_timeInputs[field] ??= []).add(value);

  void setEra(int x) {
    era = x;
    _eras.add(x);
  }

  void setDayPeriod(int x) {
    pm = x == 1;
    _periods.add(x);
  }

  /// Retain every token's range and cycle before normalizing h=12 or k=24.
  void setPatternHour(int value, int minimum, int maximum) {
    _hourMaximum = maximum;
    hour = _normalizeHour(value, minimum, maximum);
    _hours.add((value: value, minimum: minimum, maximum: maximum));
  }

  int _normalizeHour(int value, int minimum, int maximum) =>
      value == maximum && minimum == 1 ? 0 : value;

  // h/K use 12-hour ranges; H/k already express a complete 24-hour value.
  int _applyDayPeriod(int value, int maximum) =>
      pm && maximum <= 12 ? value + 12 : value;

  int get _constructionMonth {
    if (hasDayOfYear) return 1;
    if (!strict || _quarter == null) return month;
    final start = (_quarter! - 1) * 3 + 1;
    if (!_hasMonth) return start;
    // A quarter can disambiguate a name such as Gregorian "M" (March/May).
    final common = _months.reduce((a, b) => a.intersection(b));
    final compatible =
        common.where((value) => value >= start && value < start + 3);
    if (compatible.isEmpty || compatible.contains(month)) return month;
    return compatible.last;
  }

  int get dayOrDayOfYear => hasDayOfYear
      ? dayOfYear
      : strict && !_hasDay && _quarter != null
          ? 1
          : day;
  int get hour24 => _applyDayPeriod(hour, _hourMaximum ?? 12);

  void verify(String input) {
    _verify(month, 1, 12, 'month', input);
    for (final token in _hours) {
      _verify(token.value, token.minimum, token.maximum, 'hour', input);
      final normalized =
          _normalizeHour(token.value, token.minimum, token.maximum);
      final actual = _applyDayPeriod(normalized, token.maximum);
      _verify(actual, hour24, hour24, 'repeated hour', input);
    }
    for (final entry in _timeInputs.entries) {
      final maximum = entry.key == 'fractional second' ? 999999 : 59;
      final expected = switch (entry.key) {
        'minute' => minute,
        'second' => second,
        _ => fractionalSecond * 1000 + microsecond,
      };
      for (final value in entry.value) {
        _verify(value, 0, maximum, entry.key, input);
        _verify(value, expected, expected, 'repeated ${entry.key}', input);
      }
    }
    for (final value in _eras) {
      _verify(value, era!, era!, 'repeated era', input);
    }
    for (final value in _periods) {
      _verify(value, pm ? 1 : 0, pm ? 1 : 0, 'repeated day period', input);
      if (_hours.any((token) => token.maximum > 12)) {
        final expected = hour24 >= 12 ? 1 : 0;
        _verify(
            value, expected, expected, 'day period for 24-hour time', input);
      }
    }
    _verify(hour24, 0, 23, 'hour', input);
    _verify(minute, 0, 59, 'minute', input);
    _verify(second, 0, 59, 'second', input);
    _verify(fractionalSecond, 0, 999, 'fractional second', input);
    final date = asDate();
    for (final candidates in _months) {
      if (!candidates.contains(date.month)) {
        throw FormatException('Month does not match the parsed date', input);
      }
    }
    for (final value in _days) {
      _verify(value, date.day, date.day, 'day', input);
    }
    for (final value in _quarters) {
      final actual = (date.month - 1) ~/ 3 + 1;
      _verify(value, actual, actual, 'quarter', input);
    }
    for (final value in _ordinals) {
      final actual = calendarDayOfYear(date);
      _verify(value, actual, actual, 'dayOfYear', input);
    }
    for (final candidates in _weekdays) {
      if (!candidates.contains(date.weekday)) {
        throw FormatException('Weekday does not match the parsed date', input);
      }
    }
    for (final token in _localWeekdays) {
      _verify(token.value, 1, 7, 'local weekday', input);
      final expected = (date.weekday - 1 - token.firstDay) % 7 + 1;
      _verify(token.value, expected, expected, 'local weekday', input);
    }
    final minimumHour = dateOnly && date.hour == 1 ? 0 : date.hour;
    _verify(hour24, minimumHour, date.hour, 'hour', input);
    if (hasDayOfYear) {
      final actual = calendarDayOfYear(date);
      _verify(dayOfYear, actual, actual, 'dayOfYear', input);
    } else {
      _verify(dayOrDayOfYear, date.day, date.day, 'day', input);
      _verify(_constructionMonth, date.month, date.month, 'month', input);
    }
    _verify(_estimatedYear, date.year, date.year, 'year', input);
    for (final token in _years) {
      final resolved = _estimateYear(token.value, token.ambiguous);
      _verify(resolved, date.year, date.year, 'repeated year', input);
    }
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
      _date = _construct(_estimatedYear, _constructionMonth, dayOrDayOfYear,
          hour24, minute, second, fractionalSecond, microsecond);
    } on ArgumentError catch (error) {
      throw FormatException('Date outside the calendar range: $error');
    }
    return _date!;
  }

  int get _estimatedYear => _resolvedYear ??= _estimateYear();

  int _estimateYear([int? inputYear, bool? ambiguous]) {
    final year = inputYear ?? this.year;
    if (era == 0 && generalDateTime is! GeneralDateTimeInterface) {
      return 1 - year;
    }
    if (!(ambiguous ?? _hasAmbiguousCentury) || year < 0 || year >= 100) {
      return year;
    }
    // All occurrences use one clock reading, including a century boundary.
    final upper = _centuryWindowEnd ??= _makeCenturyWindowEnd();
    var candidate = (upper.year ~/ 100) * 100 + year;
    // Compare calendar fields, without relying on DateTime subclass internals.
    final candidateDate = _construct(candidate, _constructionMonth,
        dayOrDayOfYear, hour24, minute, second, fractionalSecond, microsecond);
    final inputFields = [
      candidateDate.year,
      candidateDate.month,
      candidateDate.day,
      candidateDate.hour,
      candidateDate.minute,
      candidateDate.second,
      candidateDate.millisecond,
      candidateDate.microsecond
    ];
    final upperFields = [
      upper.year,
      upper.month,
      upper.day,
      upper.hour,
      upper.minute,
      upper.second,
      upper.millisecond,
      upper.microsecond
    ];
    for (var i = 0; i < inputFields.length; i++) {
      if (inputFields[i] == upperFields[i]) continue;
      if (inputFields[i] > upperFields[i]) candidate -= 100;
      break;
    }
    return candidate;
  }

  DateTime _makeCenturyWindowEnd() {
    final now = _inCalendar(utc ? clock.now().toUtc() : clock.now().toLocal());
    return _construct(now.year + 20, now.month, now.day, now.hour, now.minute,
        now.second, now.millisecond, now.microsecond);
  }

  DateTime _construct(int year, int month, int day, int hour, int minute,
      int second, int millisecond,
      [int microsecond = 0]) {
    if (generalDateTime is PersianDateTime) {
      return utc
          ? PersianDateTime.utc(
              year, month, day, hour, minute, second, millisecond, microsecond)
          : PersianDateTime(
              year, month, day, hour, minute, second, millisecond, microsecond);
    }
    if (generalDateTime is HijriDateTime) {
      return utc
          ? HijriDateTime.utc(
              year, month, day, hour, minute, second, millisecond, microsecond)
          : HijriDateTime(
              year, month, day, hour, minute, second, millisecond, microsecond);
    }
    return utc
        ? DateTime.utc(
            year, month, day, hour, minute, second, millisecond, microsecond)
        : DateTime(
            year, month, day, hour, minute, second, millisecond, microsecond);
  }
}
