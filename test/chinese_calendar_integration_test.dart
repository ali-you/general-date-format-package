import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general_calendar/general_calendar.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/delegates.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  for (final locale in [const Locale('zh'), const Locale('fa')]) {
    testWidgets('localized calendar selects a leap month in $locale',
        (tester) async {
      DateTime? selected;
      await tester.pumpWidget(MaterialApp(
        locale: locale,
        supportedLocales: [locale],
        localizationsDelegates: const [
          ChineseCalendarMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: GeneralCalendar(
            calendarDelegate: const ChineseCalendarDelegate(),
            firstDate: ChineseDateTime(2025, 6),
            lastDate: ChineseDateTime(2025, 8, 29),
            currentDate: ChineseDateTime(2025, 6),
            onDateChanged: (date) => selected = date,
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('general-calendar-next')));
      await tester.pumpAndSettle();
      final expected = ChineseDateTime(2025, 7, 10);
      expect(
          find.text(
              GeneralDateFormat.yMMMM(locale.toString()).format(expected)),
          findsOneWidget);
      await tester
          .tap(find.byKey(const ValueKey('general-calendar-day-2025-7-10')));
      await tester.pumpAndSettle();
      expect(selected, expected);
      expect((selected as ChineseDateTime).monthCode, 'M06L');
      final format = GeneralDateFormat('yyyy MM MMMM dd', locale.toString());
      expect(format.parseStrict(format.format(selected!), expected), expected);
      expect(tester.takeException(), isNull);
    });
  }
}
