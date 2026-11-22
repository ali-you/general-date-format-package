import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

void main() {
  test('formats the leap month and distinguishes repeated tithi dates', () {
    final second = AmantaDate.fromGregorian(2023, 7, 22);
    final first = second.addDays(-1);
    final english = AmantaDateFormat();
    final hindi = AmantaDateFormat('hi');
    expect(english.formatTraditional(first), 'Adhika Shravana 2080, tithi 4');
    expect(english.formatTraditional(second),
        'Adhika Shravana 2080, tithi 4 (second)');
    expect(hindi.formatTraditional(second), startsWith('अधिक श्रावण'));
    expect(english.formatCompact(first), isNot(english.formatCompact(second)));
    expect(hindi.parseCompact(english.formatCompact(second)), second);
    expect(() => english.parseCompact('2080-01-32'), throwsFormatException);
  });
}
