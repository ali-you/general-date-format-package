import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';

void main() {
  final instant = DateTime.utc(2024, 3, 20, 13, 5);
  for (final date in <DateTime>[
    instant,
    PersianDateTime.fromDateTime(instant),
    HijriDateTime.fromDateTime(instant),
  ]) {
    final format = GeneralDateFormat('yyyy-MM-dd HH:mm', 'en_US');
    final text = format.format(date);
    final parsed = format.parseStrict(text, date, true);
    if (parsed.microsecondsSinceEpoch != instant.microsecondsSinceEpoch) {
      throw StateError('Calendar round trip changed the instant.');
    }
    print(text);
  }
}
