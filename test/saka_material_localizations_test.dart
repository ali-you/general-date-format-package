import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/localizations.dart';
import 'package:general_datetime/delegates.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Hindi picker labels and compact input use the Saka date', () async {
    const delegate = SakaCalendarDelegate();
    final localizations =
        await SakaCalendarMaterialLocalizations.load(const Locale('hi'));
    final date = SakaDateTime.atStartOfDay(1948, 1, 1);
    expect(delegate.formatMonthYear(date, localizations), contains('चैत्र'));
    expect(delegate.formatYear(1948, localizations), '१९४८');
    expect(localizations.formatDecimal(19), '१९');
    final compact = delegate.formatCompactDate(date, localizations);
    expect(delegate.parseCompactDate(compact, localizations), date);
    expect(delegate.parseCompactDate('३१/१/१९४८', localizations), isNull);
  });

  test('Canadian English picker advertises its actual compact date format',
      () async {
    const delegate = SakaCalendarDelegate();
    final localizations =
        await SakaCalendarMaterialLocalizations.load(const Locale('en', 'CA'));
    final date = SakaDateTime.atStartOfDay(1948, 2, 17);
    expect(delegate.dateHelpText(localizations), 'yyyy-mm-dd');
    final compact = delegate.formatCompactDate(date, localizations);
    expect(compact, '1948-02-17');
    expect(delegate.parseCompactDate(compact, localizations), date);
    expect(delegate.parseCompactDate('02/17/1948', localizations), isNull);
  });
}
