import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  for (final locale in [
    const Locale('en'),
    const Locale('fa'),
    const Locale('af')
  ]) {
    testWidgets(
        'Flutter translation exercises all calendar/date/number entry points $locale',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
          locale: locale,
          supportedLocales: [locale],
          localizationsDelegates: [
            PersianCalendarMaterialLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates
          ],
          home: Builder(builder: (context) {
            final labels = MaterialLocalizations.of(context);
            final date = PersianDateTime(1403, 1, 1);
            for (final text in [
              labels.formatDecimal(1234),
              labels.formatYear(date),
              labels.formatMediumDate(date),
              labels.formatShortDate(date),
              labels.formatFullDate(date),
              labels.formatMonthYear(date),
              labels.formatShortMonthDay(date),
              labels.formatCompactDate(date),
              labels.formatHour(const TimeOfDay(hour: 13, minute: 5)),
              labels.formatMinute(const TimeOfDay(hour: 13, minute: 5)),
              labels.formatTimeOfDay(const TimeOfDay(hour: 13, minute: 5))
            ]) {
              expect(text, isNotEmpty);
            }
            expect(
                labels.parseCompactDate(labels.formatCompactDate(date)), date);
            return const Scaffold(body: Text('compatible'));
          })));
      await tester.pumpAndSettle();
      expect(find.text('compatible'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
