import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/delegates.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  for (final locale in [
    const Locale('en'),
    const Locale('zh'),
    const Locale('zh', 'TW'),
    const Locale('fa'),
    const Locale('ar')
  ]) {
    test(
        '$locale round trips Chinese ordinal input and translates leap-month labels',
        () async {
      final material = await ChineseCalendarMaterialLocalizations.load(locale);
      final baseline = await GlobalMaterialLocalizations.delegate.load(locale);
      expect(material.cancelButtonLabel, baseline.cancelButtonLabel);
      for (final year in [2024, 2025]) {
        for (final month in ChineseDateTime.monthsOfYear(year)) {
          final date = ChineseDateTime(
              year, month, ChineseDateTime.daysInMonth(year, month));
          expect(material.parseCompactDate(material.formatCompactDate(date)),
              date);
          expect(material.formatMonthYear(date),
              GeneralDateFormat.yMMMM(locale.toString()).format(date));
        }
      }
      expect(material.parseCompactDate('junk'), isNull);
      expect(
          () => material.formatFullDate(DateTime(2025)), throwsArgumentError);
      expect(material.formatYear(DateTime(1900)), isNotEmpty);
      expect(material.formatYear(DateTime(2100)), isNotEmpty);
    });
  }
  testWidgets('localized Material picker navigates into a Chinese leap month',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        ChineseCalendarMaterialLocalizations.delegate
      ],
      home: Scaffold(
          body: CalendarDatePicker(
        firstDate: ChineseDateTime(2025),
        lastDate: ChineseDateTime(2025, 13, 29),
        initialDate: ChineseDateTime(2025, 6),
        currentDate: ChineseDateTime(2025, 6),
        calendarDelegate: const ChineseCalendarDelegate(),
        onDateChanged: (_) {},
      )),
    ));
    await tester.pumpAndSettle();
    expect(
        find.text(
            GeneralDateFormat.yMMMM('en_US').format(ChineseDateTime(2025, 6))),
        findsOneWidget);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(
        find.text(
            GeneralDateFormat.yMMMM('en_US').format(ChineseDateTime(2025, 7))),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
