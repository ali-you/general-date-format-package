// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:general_datetime/general_datetime.dart';

/// A class for holding onto the data for a date so that it can be built
/// up incrementally.
class DateBuilder {
  // Default the date values to the EPOCH so that there's a valid date
  // in case the format doesn't set them.
  int year = 1970,
      month = 1,
      day = 1,
      dayOfYear = 0,
      hour = 0,
      minute = 0,
      second = 0,
      fractionalSecond = 0;
  bool pm = false;
  bool utc = false;

  /// Whether the century portion of [year] is ambiguous.
  ///
  /// Ignored if `year < 0` or `year >= 100`.
  bool _hasAmbiguousCentury = false;

  bool get _hasCentury => !_hasAmbiguousCentury || year < 0 || year >= 100;

  /// The locale, kept for logging purposes when there's an error.
  final String _locale;

  /// The date result produced from [asDate].
  ///
  /// Kept as a field to cache the result and to reduce the possibility of error
  /// after we've verified.
  GeneralDateTimeInterface? _date;

  /// The number of times we've retried, for error reporting.
  int _retried = 0;

  /// Is this constructing a pure date.
  ///
  /// This is important because some locales change times at midnight,
  /// e.g. Brazil. So if we try to create a DateTime representing a date at
  /// midnight on the day of transition it will jump forward or back 1 hour.  If
  /// it jumps forward that's mostly harmless if we only care about the
  /// date. But if it jumps backwards that will change the date, which is
  /// bad. Compensate by adjusting the time portion forward. But only do that
  /// when we're explicitly trying to construct a date, which we can tell from
  /// the format.

  // We do set it, the analyzer just can't tell.
  bool dateOnly = false;

  // /// The function we will call to create a DateTime from its component pieces.
  // ///
  // /// This is normally only modified in tests that want to introduce errors.
  // final _DateTimeConstructor _dateTimeConstructor;

  GeneralDateTimeInterface generalDateTime;

  DateBuilder(this._locale, this.generalDateTime);

  // Functions that exist just to be closurized so we can pass them to a general
  // method.
  void setYear(int x) {
    year = x;
  }

  /// Sets whether [year] should be treated as ambiguous because it lacks a
  /// century.
  set hasAmbiguousCentury(bool isAmbiguous) =>
      _hasAmbiguousCentury = isAmbiguous;

  void setMonth(int x) {
    month = x;
  }

  void setDay(int x) {
    day = x;
  }

  void setDayOfYear(int x) {
    dayOfYear = x;
  }

  /// If [dayOfYear] has been set, return it, otherwise return [day], indicating
  /// the day of the month.
  int get dayOrDayOfYear => dayOfYear == 0 ? day : dayOfYear;

  void setHour(int x) {
    hour = x;
  }

  void setMinute(int x) {
    minute = x;
  }

  void setSecond(int x) {
    second = x;
  }

  void setFractionalSecond(int x) {
    fractionalSecond = x;
  }

  int get hour24 => pm ? hour + 12 : hour;

  /// Verify that we correspond to a valid date. This will reject out of
  /// range values, even if the DateTime constructor would accept them. An
  /// invalid message will result in throwing a [FormatException].
  void verify(String s) {
    _verify(month, 1, 12, 'month', s);
    _verify(hour24, 0, 23, 'hour', s);
    _verify(minute, 0, 59, 'minute', s);
    _verify(second, 0, 59, 'second', s);
    _verify(fractionalSecond, 0, 999, 'fractional second', s);
    // Verifying the day is tricky, because it depends on the month. Create
    // our resulting date and then verify that our values agree with it
    // as an additional verification. And since we're doing that, also
    // check the year, which we otherwise can't verify, and the hours,
    // which will catch cases like '14:00:00 PM'.
    var date = asDate();
    // On rare occasions, possibly related to DST boundaries, a parsed date will
    // come out as 1:00am. We compensate for the case of going backwards in
    // _correctForErrors, but we may not be able to compensate for a midnight
    // that doesn't exist. So tolerate an hour value of zero or one in these
    // cases.
    var minimumDate = dateOnly && date.hour == 1 ? 0 : date.hour;
    _verify(hour24, minimumDate, date.hour, 'hour', s, date);
    if (dayOfYear > 0) {
      // We have an ordinal date, compute the corresponding date for the result
      // and compare to that.
      // var leapYear = date_computation.isLeapYear(date);
      var leapYear = generalDateTime.isLeapYear;
      var correspondingDay = generalDateTime.dayOfYear;
      _verify(
          dayOfYear, correspondingDay, correspondingDay, 'dayOfYear', s, date);
    } else {
      // We have the day of the month, compare directly.
      _verify(day, date.day, date.day, 'day', s, date);
    }
    _verify(_estimatedYear, date.year, date.year, 'year', s, date);
  }

  void _verify(int value, int min, int max, String desc, String originalInput,
      [GeneralDateTimeInterface? parsed]) {
    if (value < min || value > max) {
      var parsedDescription = parsed == null ? '' : ' Date parsed as $parsed.';
      var errorDescription =
          'Error parsing $originalInput, invalid $desc value: $value'
          ' in $_locale'
          ' with time zone offset ${parsed?.timeZoneOffset ?? 'unknown'}.'
          ' Expected value between $min and $max.$parsedDescription.';
      if (_retried > 0) {
        errorDescription += ' Failed after $_retried retries.';
      }
      throw FormatException(errorDescription);
    }
  }

  /// Offsets a [DateTime] by a specified number of years.
  ///
  /// All other fields of the [DateTime] normally will remain unaffected.  An
  /// exception is if the resulting [DateTime] otherwise would represent an
  /// invalid date (e.g. February 29 of a non-leap year).
  GeneralDateTimeInterface _offsetYear(
      GeneralDateTimeInterface dateTime, int offsetYears) {
    int newYear = dateTime.year + offsetYears;

    return switch (dateTime) {
      JalaliDateTime _ => JalaliDateTime(
          newYear,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
          dateTime.millisecond,
          dateTime.microsecond),
      HijriDateTime _ => HijriDateTime(
          newYear,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
          dateTime.millisecond,
          dateTime.microsecond),
      _ => throw UnsupportedError("Unknown date type")
    };
  }

  /// Return a date built using our values. If no date portion is set,
  /// use the 'Epoch' of January 1, 1970.
  GeneralDateTimeInterface asDate({int retries = 3}) {
    // can crash the VM, e.g. large month values.
    if (_date != null) return _date!;
    GeneralDateTimeInterface preliminaryResult = JalaliDateTime(
      _estimatedYear,
      month,
      dayOrDayOfYear,
      hour24,
      minute,
      second,
      fractionalSecond
    );
    if (utc && _hasCentury) {
      _date = preliminaryResult;
    }
    // else {
    //   _date = _correctForErrors(preliminaryResult, retries);
    // }
    return _date!;
  }

  int get _estimatedYear {
    GeneralDateTimeInterface preliminaryResult(int year) => JalaliDateTime(
        year,
        generalDateTime.month,
        generalDateTime.day,
        generalDateTime.hour,
        generalDateTime.minute,
        generalDateTime.second,
        generalDateTime.millisecond,
        generalDateTime.microsecond);
    int estimatedYear;
    if (_hasCentury) {
      estimatedYear = year;
    } else {
      GeneralDateTimeInterface now = GeneralDateTimeInterface.now();
      if (utc) {
        now = now.toUtc();
      }

      const int lookBehindYears = 80;
      GeneralDateTimeInterface lowerDate = _offsetYear(now, -lookBehindYears);
      GeneralDateTimeInterface upperDate =
          _offsetYear(now, 100 - lookBehindYears);
      var lowerCentury = (lowerDate.year ~/ 100) * 100;
      var upperCentury = (upperDate.year ~/ 100) * 100;
      estimatedYear = upperCentury + year;

      // Our interval must be half-open since there otherwise could be ambiguity
      // for a date that is exactly 20 years in the future or exactly 80 years
      // in the past (mod 100).  We'll treat the lower-bound date as the
      // exclusive bound because:
      // * It's farther away from the present, and we're less likely to care
      //   about it.
      // * By the time this function exits, time will have advanced to favor
      //   the upper-bound date.
      //
      // We don't actually need to check both bounds.
      if (preliminaryResult(upperCentury + year).compareTo(upperDate) <= 0) {
        // Within range.
        assert(preliminaryResult(upperCentury + year).compareTo(lowerDate) > 0);
      } else {
        estimatedYear = lowerCentury + year;
      }
    }
    return estimatedYear;
  }

  /// Given a local DateTime, check for errors and try to compensate for them if
  /// possible.
  GeneralDateTimeInterface _correctForErrors(GeneralDateTimeInterface result) {

    var leapYear = result.isLeapYear;
    var resultDayOfYear = result.dayOfYear;


    if (dateOnly && result.hour != 0) {
      // This could be a flake, try again.
      var tryAgain = asDate();
      if (tryAgain != result) {
        // Trying again gave a different answer, so presumably it worked.
        return tryAgain;
      }

      // Trying again didn't work, try to force the offset.
      int expectedDayOfYear = generalDateTime.dayOfYear;

      // If we're _dateOnly, then hours should be zero, but might have been
      // offset to e.g. 11:00pm the previous day. Add that time back in. This
      // might be because of an erratic error, but it might also be because of a
      // time zone (Brazil) where there is no midnight at a daylight savings
      // time transition. In that case we will retry, but eventually give up and
      // return 1:00am on the correct date.
      var daysPrevious = expectedDayOfYear - resultDayOfYear;
      // For example, if it's the day before at 11:00pm, we offset by (24 - 23),
      // so +1. If it's the same day at 1:00am, we offset by (0 - 1), so -1.
      var offset = (daysPrevious * 24) - result.hour;
      GeneralDateTimeInterface adjusted = result.add(Duration(hours: offset));
      // Check if the adjustment worked. This can fail on a time zone transition
      // where midnight doesn't exist.
      if (adjusted.hour == 0) {
        return adjusted;
      }
      // Adjusting did not work. Just check if the adjusted date is right. And
      // if it's not, just give up and return [result]. The scenario where this
      // might correctly happen is if we're in a Brazil time zone, jump forward
      // to 1:00 am because of a DST transition, and trying to go backwards 1
      // hour takes us back to 11:00pm the day before. In that case the 1:00am
      // answer on the correct date is preferable.
      var adjustedDayOfYear = adjusted.dayOfYear;
      if (adjustedDayOfYear != expectedDayOfYear) {
        return result;
      }
      return adjusted;
    }
    // None of our corrections applied, just return the uncorrected date.
    return result;
  }
}

// /// Defines a function type for creating DateTime instances.
// typedef _DateTimeConstructor = DateTime Function(int year, int month, int day,
//     int hour24, int minute, int second, int fractionalSecond, bool utc);
