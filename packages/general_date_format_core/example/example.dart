import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';

void main() {
  final date = SakaDateTime.utc(1948, 1, 1);
  final formatter = GeneralDateFormat('d MMMM y G', 'en');
  final text = formatter.format(date);
  print(text); // 1 Chaitra 1948 Śaka
  print(CalendarDateUtils.toGregorian(formatter.parseStrict(text, date, true)));
}
