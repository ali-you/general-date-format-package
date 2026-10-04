import 'package:flutter_test/flutter_test.dart';
import 'package:general_datetime/general_datetime.dart';

/// Calendar construction shared by formatter integration tests.
enum CalendarFixture {
  gregorian(2024),
  persian(1403),
  hijri(1446);

  const CalendarFixture(this.baseYear);
  final int baseYear;

  DateTime date(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0]) {
    return switch (this) {
      gregorian => DateTime(
          year, month, day, hour, minute, second, millisecond, microsecond),
      persian => PersianDateTime(
          year, month, day, hour, minute, second, millisecond, microsecond),
      hijri => HijriDateTime(
          year, month, day, hour, minute, second, millisecond, microsecond),
    };
  }

  DateTime get selector => date(baseYear);

  int monthLength(int year, int month) {
    final value = date(year, month);
    return value is GeneralDateTimeInterface
        ? (value as GeneralDateTimeInterface).monthLength
        : DateTime.utc(year, month + 1, 0).day;
  }

  int yearLength(int year) =>
      List.generate(12, (index) => monthLength(year, index + 1))
          .fold(0, (sum, length) => sum + length);
}

/// Compare calendar fields explicitly: subclass equality/epoch conversion is
/// owned by general_datetime, whereas this package promises field preservation.
void expectCalendarFields(DateTime actual, DateTime expected,
    {required bool utc, String? reason, int microsecond = 0}) {
  expect(actual.runtimeType, expected.runtimeType, reason: reason);
  expect(actual.isUtc, utc, reason: reason);
  expect([
    actual.year,
    actual.month,
    actual.day,
    actual.hour,
    actual.minute,
    actual.second,
    actual.millisecond,
    actual.microsecond,
  ], [
    expected.year,
    expected.month,
    expected.day,
    expected.hour,
    expected.minute,
    expected.second,
    expected.millisecond,
    microsecond, // The pattern determines the expected fractional precision.
  ], reason: reason);
}
