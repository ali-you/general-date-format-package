import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/delegates.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  const arithmetic = HebrewCalendarDelegate();
  for (final locale in [
    const Locale('en'),
    const Locale('he'),
    const Locale('fa'),
    const Locale('ar'),
    const Locale('ko')
  ]) {
    test('$locale translates Material strings and round trips actual months',
        () async {
      final material = await HebrewCalendarMaterialLocalizations.load(locale);
      final baseline = await GlobalMaterialLocalizations.delegate.load(locale);
      expect(material.cancelButtonLabel, baseline.cancelButtonLabel);
      expect(material.invalidDateFormatLabel, baseline.invalidDateFormatLabel);
      for (final year in [5784, 5785]) {
        for (final month in HebrewDateTime.monthsOfYear(year)) {
          final date = HebrewDateTime(
              year, month, HebrewDateTime.daysInMonth(year, month));
          final input = material.formatCompactDate(date);
          expect(arithmetic.parseCompactDate(input, material), date);
          expect(material.formatMonthYear(date),
              GeneralDateFormat.yMMMM(locale.languageCode).format(date));
        }
      }
      expect(material.formatYear(DateTime(0)), isNotEmpty);
      expect(material.formatYear(DateTime(10000)), isNotEmpty);
      expect(() => material.formatFullDate(PersianDateTime(1403)),
          throwsArgumentError);
      expect(
          () => material.formatMonthYear(DateTime(2024)), throwsArgumentError);
      expect(material.parseCompactDate(null), isNull);
      expect(material.parseCompactDate('junk'), isNull);
      final format = GeneralDateFormat('yMd', locale.languageCode)
        ..useNativeDigits = false;
      final leapInput = format.format(HebrewDateTime(5784, 6));
      expect(material.parseCompactDate(leapInput.replaceAll('5784', '5785')),
          isNull);
    });
  }

  test('digit preference changes dates and Material numeric labels together',
      () async {
    for (final locale in [const Locale('fa'), const Locale('ar')]) {
      for (final native in [false, true]) {
        final material = await HebrewCalendarMaterialLocalizations.load(locale,
            useNativeDigits: native);
        final format = GeneralDateFormat('yMd', locale.languageCode)
          ..useNativeDigits = native;
        final date = HebrewDateTime(5784, 7, 10);
        expect(material.formatCompactDate(date), format.format(date));
        expect(material.parseCompactDate(format.format(date)), date);
        expect(
            material.formatDecimal(123),
            native
                ? locale.languageCode == 'fa'
                    ? '۱۲۳'
                    : '١٢٣'
                : '123');
        expect(
            material.formatMinute(const TimeOfDay(hour: 12, minute: 5)),
            native
                ? locale.languageCode == 'fa'
                    ? '۰۵'
                    : '٠٥'
                : '05');
      }
    }
    const ascii =
        HebrewCalendarMaterialLocalizationsDelegate(useNativeDigits: false);
    expect(
        ascii.shouldReload(const HebrewCalendarMaterialLocalizationsDelegate()),
        isTrue);
    expect(ascii.isSupported(const Locale('he', 'IL')), isTrue);
    expect(ascii.isSupported(const Locale('zz')), isFalse);
  });

  testWidgets('Hebrew-script picker navigates from Adar I to Adar II',
      (tester) async {
    final material =
        await HebrewCalendarMaterialLocalizations.load(const Locale('he'));
    DateTime? selected;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('he'),
      supportedLocales: const [Locale('he')],
      localizationsDelegates: const [
        HebrewCalendarMaterialLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Scaffold(
          body: CalendarDatePicker(
        initialDate: HebrewDateTime(5784, 6, 10),
        firstDate: HebrewDateTime(5784),
        lastDate: HebrewDateTime(5784, 13, 29),
        currentDate: HebrewDateTime(5784, 6, 10),
        calendarDelegate: arithmetic,
        onDateChanged: (date) => selected = date,
      )),
    ));
    await tester.pumpAndSettle();
    expect(find.text(material.formatMonthYear(HebrewDateTime(5784, 6))),
        findsOneWidget);
    await tester.tap(find.byTooltip(material.nextMonthTooltip));
    await tester.pumpAndSettle();
    expect(find.text(material.formatMonthYear(HebrewDateTime(5784, 7))),
        findsOneWidget);
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    expect(selected, HebrewDateTime(5784, 7, 10));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hebrew input validates absent months in a common year',
      (tester) async {
    final key = GlobalKey<FormState>();
    DateTime? submitted;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        HebrewCalendarMaterialLocalizations.delegate
      ],
      home: Scaffold(
          body: Form(
              key: key,
              child: InputDatePickerFormField(
                initialDate: HebrewDateTime(5785, 7),
                firstDate: HebrewDateTime(5785),
                lastDate: HebrewDateTime(5785, 13, 29),
                calendarDelegate: arithmetic,
                onDateSubmitted: (date) => submitted = date,
              ))),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '6/1/5785');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(key.currentState!.validate(), isFalse);
    expect(submitted, isNull);
    await tester.enterText(find.byType(TextField), '7/29/5785');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(key.currentState!.validate(), isTrue);
    expect(submitted, HebrewDateTime(5785, 7, 29));
  });

  testWidgets('translated Hebrew range picker saves both Adars',
      (tester) async {
    final delegate = arithmetic.rangePickerDelegate;
    final first = HebrewDateTime(5784, 6);
    final last = HebrewDateTime(5784, 7, 29);
    final initial = DateTimeRange<DateTime>(start: first, end: last);
    DateTimeRange? selected;
    final material =
        await HebrewCalendarMaterialLocalizations.load(const Locale('he'));
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('he'),
      supportedLocales: const [Locale('he')],
      localizationsDelegates: const [
        HebrewCalendarMaterialLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates
      ],
      home: Builder(
          builder: (context) => TextButton(
                onPressed: () async => selected = await showDateRangePicker(
                  context: context,
                  firstDate: first,
                  lastDate: last,
                  currentDate: first,
                  initialDateRange: initial,
                  calendarDelegate: delegate,
                  builder: calendarDateRangePickerBuilder(delegate),
                ),
                child: const Text('open'),
              )),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text(material.saveButtonLabel));
    await tester.pumpAndSettle();
    expect(selected, initial);
    expect(selected!.start, isA<HebrewDateTime>());
    expect(selected!.end, isA<HebrewDateTime>());
  });
}
