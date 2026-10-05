@Tags(['critical'])
library;

import 'dart:convert';
import 'dart:math';

import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  for (final selector in <DateTime>[
    PersianDateTime.utc(1403),
    HijriDateTime.utc(1445),
  ]) {
    DateTime convert(DateTime native) => selector is PersianDateTime
        ? PersianDateTime.fromDateTime(native)
        : HijriDateTime.fromDateTime(native);

    test(
        '${selector.runtimeType} retains native instants through display and JSON',
        () {
      const seed = 0xC0DE;
      final random = Random(seed);
      for (var sample = 0; sample < 200; sample++) {
        final utc = DateTime.utc(
          1900 + random.nextInt(200),
          1 + random.nextInt(12),
          1 + random.nextInt(28),
          random.nextInt(24),
          random.nextInt(60),
          random.nextInt(60),
          random.nextInt(1000),
          random.nextInt(1000),
        );
        for (final native in [utc, utc.toLocal()]) {
          final calendar = convert(native);
          for (final locale in ['en', 'fa', 'ar']) {
            final format =
                GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', locale);
            final parsed = format.parseStrict(
                format.format(calendar), selector, native.isUtc);
            final context =
                'seed $seed sample $sample $locale UTC=${native.isUtc} $native';
            expect(parsed.microsecondsSinceEpoch, native.microsecondsSinceEpoch,
                reason: context);
            expect(parsed.isUtc, native.isUtc, reason: context);
            final restored = CalendarInstant.fromJson(
                jsonDecode(jsonEncode(CalendarInstant.fromDateTime(parsed))));
            expect(restored.instant.toIso8601String(), utc.toIso8601String(),
                reason: context);
            final civil = CalendarDateRecord.fromJson(jsonDecode(
                jsonEncode(CalendarDateRecord.fromDateTime(parsed))));
            expect((
              civil.year,
              civil.month,
              civil.day
            ), (
              calendar.year,
              calendar.month,
              calendar.day
            ), reason: context);
          }
        }
      }
    });

    test('${selector.runtimeType} compact fraction widths have exact precision',
        () {
      for (final fraction in [0, 1, 9, 10, 99, 100, 999, 1000, 9999, 999999]) {
        final value = CalendarDateUtils.copyWith(selector,
            hour: 23,
            minute: 59,
            second: 58,
            millisecond: fraction ~/ 1000,
            microsecond: fraction % 1000);
        for (var width = 1; width <= 9; width++) {
          for (final locale in ['en', 'fa', 'ar']) {
            // The following minute token verifies that fraction parsing does
            // not consume digits belonging to an adjacent numeric field.
            final format =
                GeneralDateFormat("yyyyMMddHHmmss${'S' * width}mm", locale);
            final text = format.format(value);
            final parsed = format.parseStrict(text, selector, true);
            final retainedDigits = width < 3 ? 3 : (width > 6 ? 6 : width);
            final factor = pow(10, 6 - retainedDigits).toInt();
            final expected = convert(DateTime.fromMicrosecondsSinceEpoch(
                value.microsecondsSinceEpoch -
                    fraction +
                    fraction ~/ factor * factor,
                isUtc: true));
            expect(
                parsed.microsecondsSinceEpoch, expected.microsecondsSinceEpoch,
                reason: '$locale width $width fraction $fraction text $text');
            expect(parsed.minute, 59);
          }
        }
      }
    });
  }
}
