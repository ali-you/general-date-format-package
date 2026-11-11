import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/delegates.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  test('every supported Material locale formats and parses Chinese bounds',
      () async {
    var checked = 0;
    for (final name in GeneralDateFormat.allLocalesWithSymbols()) {
      final parts = name.split('_');
      final locale = Locale.fromSubtags(
        languageCode: parts.first,
        scriptCode: parts.length > 1 && parts[1].length == 4 ? parts[1] : null,
        countryCode:
            parts.length > 1 && parts.last.length != 4 ? parts.last : null,
      );
      if (!ChineseCalendarMaterialLocalizations.delegate.isSupported(locale)) {
        continue;
      }
      for (final nativeDigits in [false, true]) {
        final material = await ChineseCalendarMaterialLocalizations.load(locale,
            useNativeDigits: nativeDigits);
        for (final date in [
          ChineseDateTime(1901),
          ChineseDateTime(2025, 7, 29),
          ChineseDateTime(2099, 13, 30),
        ]) {
          final input = material.formatCompactDate(date);
          expect(material.parseCompactDate(input), date,
              reason: '$name nativeDigits=$nativeDigits $input');
          expect(material.formatFullDate(date), isNotEmpty);
          expect(material.formatMonthYear(date), isNotEmpty);
          expect(material.formatYear(date), isNotEmpty);
        }
      }
      checked++;
    }
    expect(checked, greaterThan(100));
  });
  test('ASCII digit override round trips Chinese input in native-digit locales',
      () async {
    for (final locale in [const Locale('fa'), const Locale('ar')]) {
      final material = await ChineseCalendarMaterialLocalizations.load(locale,
          useNativeDigits: false);
      final date = ChineseDateTime(2025, 7, 29);
      final text = material.formatCompactDate(date);
      expect(text, contains('2025'));
      expect(material.parseCompactDate(text), date);
      expect(material.formatDecimal(25), '25');
    }
  });
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
