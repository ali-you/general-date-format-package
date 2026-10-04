import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';
import 'package:intl/date_symbol_data_local.dart' as intl_data;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Afrikaans names and day periods use independent CLDR golden text', () {
    final date = PersianDateTime.utc(1403, 1, 1, 13);
    final format = GeneralDateFormat('yyyy MMMM dd EEEE a HH', 'af');
    expect(format.format(date), '1403 Farvardin 01 Woensdag nm. 13');
    expect(format.parseStrict('1403 Farvardin 01 Woensdag nm. 13', date, true),
        date);
    expect(
        format.tryParseStrict('1403 Farvardin 01 Wednesday PM 13', date, true),
        isNull);
    expect(GeneralDateFormat('G yyyy', 'af').format(date), 'AP 1403');
    expect(format.dateSymbols.MONTHS, [
      'Farvardin',
      'Ordibehesht',
      'Khordad',
      'Tir',
      'Mordad',
      'Shahrivar',
      'Mehr',
      'Aban',
      'Azar',
      'Dey',
      'Bahman',
      'Esfand'
    ]);
  });

  test('Afrikaans picker headers and displayed dates use Afrikaans', () async {
    final persian =
        await PersianCalendarMaterialLocalizations.load(const Locale('af'));
    expect(persian.narrowWeekdays, ['S', 'M', 'D', 'W', 'D', 'V', 'S']);
    expect(persian.firstDayOfWeekIndex, 0);
    expect(persian.formatFullDate(PersianDateTime.utc(1403, 1, 1)),
        contains('Woensdag'));
    expect(persian.formatFullDate(PersianDateTime.utc(1403, 1, 1)),
        contains('Farvardin'));
  });

  test('every Persian locale reconciles neutral metadata with intl', () {
    const keys = [
      'WEEKDAYS',
      'STANDALONEWEEKDAYS',
      'SHORTWEEKDAYS',
      'STANDALONESHORTWEEKDAYS',
      'NARROWWEEKDAYS',
      'STANDALONENARROWWEEKDAYS',
      'SHORTQUARTERS',
      'QUARTERS',
      'AMPMS',
      'TIMEFORMATS',
      'DATETIMEFORMATS',
      'FIRSTDAYOFWEEK',
      'WEEKENDRANGE',
      'FIRSTWEEKCUTOFFDAY'
    ];
    final source = intl_data.dateTimeSymbolMap();
    for (final locale in GeneralDateFormat.allLocalesWithSymbols()) {
      final format = GeneralDateFormat('yyyy-MM-dd', locale)
        ..format(PersianDateTime.utc(1403));
      final symbols = format.dateSymbols.serializeToMap();
      final expected = source[locale]!.serializeToMap();
      for (final key in keys) {
        expect(symbols[key], expected[key], reason: '$locale $key');
      }
    }
  });

  test('Malaysia and ISO week conventions retain their selected source',
      () async {
    final date = PersianDateTime.fromDateTime(DateTime.utc(2024, 1, 15));
    for (final locale in ['en_MY', 'en_ISO']) {
      final format = GeneralDateFormat('c cc', locale);
      expect(format.format(date), '1 1');
      expect(format.dateSymbols.FIRSTDAYOFWEEK, 0);
    }
    final persian = await PersianCalendarMaterialLocalizations.load(
        const Locale('en', 'MY'));
    final flutter = await GlobalMaterialLocalizations.delegate
        .load(const Locale('en', 'MY'));
    expect(persian.firstDayOfWeekIndex, 1); // intl en_MY: Monday.
    expect(flutter.firstDayOfWeekIndex, 0); // Flutter falls back to English.
  });
}
