import 'dart:convert';
import 'dart:io';
import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';

void main() {
  final startup = Stopwatch()..start();
  final before = ProcessInfo.currentRss;
  final instant = DateTime.utc(2024, 3, 20, 12, 34, 56, 123, 456);
  final first = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', 'fa');
  final text = first.format(PersianDateTime.fromDateTime(instant));
  final firstFormatMicros = startup.elapsedMicroseconds;
  final rows = <Map<String, Object>>[];
  for (final date in <DateTime>[
    instant,
    PersianDateTime.fromDateTime(instant),
    HijriDateTime.fromDateTime(instant)
  ]) {
    final format = GeneralDateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS', 'fa');
    final input = format.format(date);
    final watch = Stopwatch()..start();
    const iterations = 10000;
    for (var i = 0; i < iterations; i++) {
      format.format(date);
      final parsed = format.parseStrict(input, date, true);
      if (parsed.microsecondsSinceEpoch != instant.microsecondsSinceEpoch) {
        throw StateError('Benchmark fixture changed');
      }
    }
    rows.add({
      'calendar': date.runtimeType.toString(),
      'iterations': iterations,
      'formatAndParseMicrosecondsPerIteration':
          watch.elapsedMicroseconds / iterations
    });
  }
  print(jsonEncode({
    'os': Platform.operatingSystem,
    'dart': Platform.version,
    'firstFormatMicroseconds': firstFormatMicros,
    'rssBefore': before,
    'rssAfter': ProcessInfo.currentRss,
    'fixture': text,
    'measurements': rows
  }));
}
