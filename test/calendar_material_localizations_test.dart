@Tags(['critical'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/delegates.dart';
import 'package:general_datetime/general_datetime.dart';

import 'support/calendar_fixture.dart';

void main() {
  final fixtures = <CalendarFixture, CalendarDelegate<DateTime>>{
    CalendarFixture.persian: const PersianCalendarDelegate(),
    CalendarFixture.hijri: const HijriCalendarDelegate(),
  };

  LocalizationsDelegate<MaterialLocalizations> delegate(
          CalendarFixture calendar, bool native) =>
      calendar == CalendarFixture.persian
          ? PersianCalendarMaterialLocalizationsDelegate(
              useNativeDigits: native)
          : HijriCalendarMaterialLocalizationsDelegate(useNativeDigits: native);

  for (final entry in fixtures.entries) {
    final calendar = entry.key;
    final arithmetic = entry.value;
    group('${calendar.name} Material localizations', () {
      for (final locale in [
        const Locale('en', 'US'),
        const Locale('en', 'GB'),
        const Locale('fa'),
        const Locale('ar'),
        const Locale('de'),
        const Locale('ru')
      ]) {
        test('$locale supplies calendar dates and Flutter translations',
            () async {
          final material = await delegate(calendar, true).load(locale);
          final baseline =
              await GlobalMaterialLocalizations.delegate.load(locale);
          final date = calendar.date(calendar.baseYear,
              calendar == CalendarFixture.persian ? 1 : 9, 15);
          final localeName = locale.toString();
          final formats = <String, String Function(DateTime)>{
            'y': material.formatYear,
            'yMd': material.formatCompactDate,
            'yMMMd': material.formatShortDate,
            'MMMEd': material.formatMediumDate,
            'yMMMMEEEEd': material.formatFullDate,
            'yMMMM': material.formatMonthYear,
            'MMMd': material.formatShortMonthDay,
          };
          for (final format in formats.entries) {
            expect(format.value(date),
                GeneralDateFormat(format.key, localeName).format(date),
                reason: '$locale ${format.key}');
          }
          expectCalendarFields(
              material.parseCompactDate(material.formatCompactDate(date))!,
              date,
              utc: false);
          expect(arithmetic.formatMonthYear(date, material),
              material.formatMonthYear(date));
          expect(arithmetic.formatYear(date.year, material),
              material.formatYear(date));
          expect(material.narrowWeekdays, baseline.narrowWeekdays);
          expect(material.firstDayOfWeekIndex, baseline.firstDayOfWeekIndex);
          expect(material.dateSeparator, baseline.dateSeparator);
          expect(material.dateHelpText, baseline.dateHelpText);
          expect(material.okButtonLabel, baseline.okButtonLabel);
          expect(material.cancelButtonLabel, baseline.cancelButtonLabel);
          expect(
              material.invalidDateFormatLabel, baseline.invalidDateFormatLabel);
          expect(material.dateOutOfRangeLabel, baseline.dateOutOfRangeLabel);
          expect(material.dateRangeStartDateSemanticLabel('example'),
              baseline.dateRangeStartDateSemanticLabel('example'));
          expect(
              material.selectedRowCountTitle(2),
              baseline.selectedRowCountTitle(2).replaceAll(
                  baseline.formatDecimal(2), material.formatDecimal(2)));
          expect(material.timeOfDayFormat(), baseline.timeOfDayFormat());
        });
      }

      test('compact input is strict, nullable and selects the correct calendar',
          () async {
        final material =
            await delegate(calendar, true).load(const Locale('en', 'GB'));
        final year = calendar.baseYear;
        final valid = calendar.date(year, 1, 1);
        for (final String? input in [
          null,
          '',
          'invalid',
          '00/01/$year',
          '32/01/$year',
          '01/00/$year',
          '01/13/$year',
          '${material.formatCompactDate(valid)} trailing'
        ]) {
          expect(arithmetic.parseCompactDate(input, material), isNull,
              reason: input);
        }
        for (var month = 1; month <= 12; month++) {
          final length = calendar.monthLength(year, month);
          final last = calendar.date(year, month, length);
          expectCalendarFields(
              arithmetic.parseCompactDate(
                  material.formatCompactDate(last), material)!,
              last,
              utc: false);
          final invalid =
              '${length + 1}/${month.toString().padLeft(2, '0')}/$year';
          expect(material.parseCompactDate(invalid), isNull, reason: invalid);
        }
      });

      for (final locale in [const Locale('fa'), const Locale('ar')]) {
        for (final native in [false, true]) {
          test(
              '$locale native=$native keeps numeric labels and dates consistent',
              () async {
            final material = await delegate(calendar, native).load(locale);
            final date = calendar.date(calendar.baseYear, 1, 1);
            final format = GeneralDateFormat('yMd', locale.languageCode)
              ..useNativeDigits = native;
            expect(material.formatCompactDate(date), format.format(date));
            final digits = native
                ? (locale.languageCode == 'fa' ? '۱۲۳۴۵' : '١٢٣٤٥')
                : '12345';
            expect(
                material
                    .formatDecimal(123)
                    .replaceAll(RegExp(r'[^0-9۰-۹٠-٩]'), ''),
                digits.substring(0, 3));
            expect(material.formatMinute(const TimeOfDay(hour: 13, minute: 5)),
                native ? (locale.languageCode == 'fa' ? '۰۵' : '٠٥') : '05');
            expect(
                material.formatHour(const TimeOfDay(hour: 13, minute: 5),
                    alwaysUse24HourFormat: true),
                digits.substring(0, 1) + digits.substring(2, 3));
            final baseline =
                await GlobalMaterialLocalizations.delegate.load(locale);
            String expectedDigits(String value) {
              final sourceZero = baseline.formatDecimal(0).codeUnitAt(0);
              final targetZero =
                  (native ? (locale.languageCode == 'fa' ? '۰' : '٠') : '0')
                      .codeUnitAt(0);
              for (var digit = 0; digit < 10; digit++) {
                value = value.replaceAll(
                    String.fromCharCode(sourceZero + digit),
                    String.fromCharCode(targetZero + digit));
              }
              return value;
            }

            for (final count in [0, 1, 2, 3, 5, 11, 12345]) {
              expect(material.formatDecimal(count),
                  expectedDigits(baseline.formatDecimal(count)));
              expect(material.formatDecimal(-count),
                  expectedDigits(baseline.formatDecimal(-count)));
              expect(material.selectedRowCountTitle(count),
                  expectedDigits(baseline.selectedRowCountTitle(count)));
              expect(material.licensesPackageDetailText(count),
                  expectedDigits(baseline.licensesPackageDetailText(count)));
              expect(
                  material.remainingTextFieldCharacterCount(count),
                  expectedDigits(
                      baseline.remainingTextFieldCharacterCount(count)));
            }
            expect(material.pageRowsInfoTitle(1, 10, 12345, true),
                expectedDigits(baseline.pageRowsInfoTitle(1, 10, 12345, true)));
            expect(material.tabLabel(tabIndex: 1, tabCount: 5),
                expectedDigits(baseline.tabLabel(tabIndex: 1, tabCount: 5)));
            for (final hour in [0, 1, 12, 13, 23]) {
              for (final always24 in [false, true]) {
                final time = TimeOfDay(hour: hour, minute: 5);
                expect(
                    material.formatTimeOfDay(time,
                        alwaysUse24HourFormat: always24),
                    expectedDigits(baseline.formatTimeOfDay(time,
                        alwaysUse24HourFormat: always24)));
              }
            }
            expectCalendarFields(
                material.parseCompactDate(format.format(date))!, date,
                utc: false);
            // Accept native input even when the picker displays ASCII.
            final nativeInput =
                GeneralDateFormat.yMd(locale.languageCode).format(date);
            expectCalendarFields(material.parseCompactDate(nativeInput)!, date,
                utc: false);
          });
        }
      }

      test('regional fallback and unsupported locale behavior', () async {
        final selected = delegate(calendar, true);
        expect(selected.isSupported(const Locale('fa', 'IR')), true);
        expect(selected.isSupported(const Locale('zz')), false);
        await expectLater(
            selected.load(const Locale('zz')), throwsArgumentError);
        final region = await selected.load(const Locale('fa', 'IR'));
        final language = await selected.load(const Locale('fa'));
        expect(region.formatMonthYear(calendar.selector),
            language.formatMonthYear(calendar.selector));
      });

      for (final entry in <Locale, String>{
        const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'):
            'sr_Latn',
        const Locale.fromSubtags(
            languageCode: 'sr',
            scriptCode: 'Latn',
            countryCode: 'RS'): 'sr_Latn',
        const Locale.fromSubtags(
            languageCode: 'sr', scriptCode: 'Cyrl', countryCode: 'RS'): 'sr',
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'):
            'zh_TW',
        const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'): 'zh_HK',
        const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'): 'zh_TW',
        const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hans', countryCode: 'TW'): 'zh_CN',
        const Locale.fromSubtags(
            languageCode: 'en', scriptCode: 'Latn', countryCode: 'GB'): 'en_GB',
      }.entries) {
        test('${entry.key} keeps labels, dates and numbers consistent',
            () async {
          final selected = delegate(calendar, true);
          expect(selected.isSupported(entry.key), true);
          final material = await selected.load(entry.key);
          final baseline =
              await GlobalMaterialLocalizations.delegate.load(entry.key);
          final instant = DateTime.utc(2024, 1, 15);
          final date = calendar == CalendarFixture.persian
              ? PersianDateTime.fromDateTime(instant)
              : HijriDateTime.fromDateTime(instant);
          expect(material.cancelButtonLabel, baseline.cancelButtonLabel);
          expect(material.inputDateModeButtonLabel,
              baseline.inputDateModeButtonLabel);
          expect(material.formatFullDate(date),
              GeneralDateFormat('yMMMMEEEEd', entry.value).format(date));
          expect(material.formatMediumDate(date),
              GeneralDateFormat('MMMEd', entry.value).format(date));
          final symbols = GeneralDateFormat('y', entry.value)..format(date);
          expect(material.narrowWeekdays, symbols.dateSymbols.NARROWWEEKDAYS);
          expect(material.formatDecimal(12345), baseline.formatDecimal(12345));
          expectCalendarFields(
              material.parseCompactDate(material.formatCompactDate(date))!,
              date,
              utc: false);
          if (entry.key.scriptCode == 'Latn' &&
              entry.key.languageCode == 'sr') {
            expect(material.cancelButtonLabel, 'Otkaži');
            expect(material.formatFullDate(date), contains('ponedeljak'));
            expect(material.narrowWeekdays[1], 'p');
          }
          if (entry.key.scriptCode == 'Hant') {
            expect(material.formatMediumDate(date), contains('週一'));
          }
          if (entry.key.scriptCode == 'Hans') {
            expect(material.formatMediumDate(date), contains('周一'));
          }
        });
      }

      test(
          'all advertised locales with Material translations load and round-trip',
          () async {
        for (final code in GeneralDateFormat.allLocalesWithSymbols()) {
          final parts = code.split('_');
          final hasScript = parts.length > 1 && parts[1].length == 4;
          final locale = Locale.fromSubtags(
            languageCode: parts[0],
            scriptCode: hasScript ? parts[1] : null,
            countryCode: hasScript
                ? (parts.length > 2 ? parts[2] : null)
                : (parts.length > 1 ? parts[1] : null),
          );
          final selected = delegate(calendar, true);
          if (!selected.isSupported(locale)) continue;
          final material = await selected.load(locale);
          final date = calendar.date(calendar.baseYear, 9, 15);
          expectCalendarFields(
              material.parseCompactDate(material.formatCompactDate(date))!,
              date,
              utc: false,
              reason: code);
        }
      });

      test(
          'Gregorian input is rejected for date formats, year labels use calendar fields',
          () async {
        final material =
            await delegate(calendar, true).load(const Locale('en'));
        expect(
            () => material.formatFullDate(DateTime(2024)), throwsArgumentError);
        expect(material.formatYear(DateTime(calendar.baseYear)),
            '${calendar.baseYear}');
        final disabledYear = calendar == CalendarFixture.persian ? -62 : 1299;
        expect(arithmetic.formatYear(disabledYear, material), '$disabledYear');
      });
    });
  }

  test('delegate reload reflects digit settings', () {
    const persian = PersianCalendarMaterialLocalizationsDelegate();
    const hijri = HijriCalendarMaterialLocalizationsDelegate();
    expect(persian.shouldReload(persian), false);
    expect(hijri.shouldReload(hijri), false);
    expect(
        persian.shouldReload(const PersianCalendarMaterialLocalizationsDelegate(
            useNativeDigits: false)),
        true);
    expect(
        hijri.shouldReload(const HijriCalendarMaterialLocalizationsDelegate(
            useNativeDigits: false)),
        true);
    expect(PersianCalendarMaterialLocalizations.delegate,
        isA<PersianCalendarMaterialLocalizationsDelegate>());
    expect(HijriCalendarMaterialLocalizations.delegate,
        isA<HijriCalendarMaterialLocalizationsDelegate>());
  });

  test(
      'Persian year zero and negative years round-trip through picker localizations',
      () async {
    final material = await PersianCalendarMaterialLocalizations.load(
        const Locale('en', 'GB'));
    for (final year in [-61, -1, 0, 1, 1000, 1403, 3177]) {
      final date = PersianDateTime(year, 2, 31);
      expect(material.formatYear(DateTime(year)), '$year');
      expectCalendarFields(
          material.parseCompactDate(material.formatCompactDate(date))!, date,
          utc: false);
    }
  });

  for (final entry in fixtures.entries) {
    testWidgets(
        '${entry.key.name} year picker renders disabled boundary labels',
        (tester) async {
      final calendar = entry.key;
      final firstYear = calendar == CalendarFixture.persian ? -61 : 1300;
      final first = calendar.date(firstYear);
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [
          delegate(calendar, true),
          ...GlobalMaterialLocalizations.delegates
        ],
        home: Scaffold(
            body: SizedBox(
                height: 400,
                child: YearPicker(
                  firstDate: first,
                  lastDate: calendar.date(firstYear, 12, 29),
                  currentDate: first,
                  selectedDate: first,
                  calendarDelegate: entry.value,
                  onChanged: (_) {},
                ))),
      ));
      await tester.pumpAndSettle();
      expect(find.text('$firstYear'), findsOneWidget);
      expect(find.text('${firstYear - 1}'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    for (final locale in [
      const Locale('en'),
      const Locale('fa'),
      const Locale('ar')
    ]) {
      testWidgets('${entry.key.name} $locale picker calendar and input mode',
          (tester) async {
        final calendar = entry.key;
        final initial = calendar.date(calendar.baseYear, 9, 15);
        DateTime? selected;
        final formKey = GlobalKey<FormState>();
        await tester.pumpWidget(MaterialApp(
          locale: locale,
          supportedLocales: [locale],
          localizationsDelegates: [
            delegate(calendar, true),
            ...GlobalMaterialLocalizations.delegates
          ],
          home: Scaffold(
              body: Builder(
                  builder: (context) => Column(children: [
                        CalendarDatePicker(
                          initialDate: initial,
                          firstDate: calendar.date(calendar.baseYear),
                          lastDate: calendar.date(calendar.baseYear, 12, 29),
                          currentDate: initial,
                          calendarDelegate: entry.value,
                          onDateChanged: (_) {},
                        ),
                        Form(
                            key: formKey,
                            child: InputDatePickerFormField(
                              initialDate: initial,
                              firstDate: calendar.date(calendar.baseYear),
                              lastDate:
                                  calendar.date(calendar.baseYear, 12, 29),
                              calendarDelegate: entry.value,
                              onDateSaved: (value) => selected = value,
                            )),
                      ]))),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final material = MaterialLocalizations.of(
            tester.element(find.byType(CalendarDatePicker)));
        expect(find.text(material.formatMonthYear(initial)), findsOneWidget);
        final text =
            material.formatCompactDate(calendar.date(calendar.baseYear, 2, 15));
        await tester.enterText(find.byType(TextFormField), 'invalid');
        expect(formKey.currentState!.validate(), false);
        await tester.pump();
        expect(find.text(material.invalidDateFormatLabel), findsOneWidget);
        await tester.enterText(find.byType(TextFormField), text);
        expect(formKey.currentState!.validate(), true);
        formKey.currentState!.save();
        expectCalendarFields(selected!, calendar.date(calendar.baseYear, 2, 15),
            utc: false);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
