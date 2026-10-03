import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets('Demonstrates all calendars and native digits', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Gregorian'), findsOneWidget);
    expect(find.text('Persian'), findsOneWidget);
    expect(find.text('Hijri'), findsOneWidget);
    expect(find.textContaining('Ramadan'), findsOneWidget);
    expect(find.text('Parsed in UTC: true'), findsNWidgets(3));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Persian').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('۱۴۰۳/۰۱/۰۱'), findsOneWidget);
    expect(find.textContaining('رمضان'), findsOneWidget);
  });

  for (final calendar in ['Persian', 'Hijri']) {
    testWidgets('Opens and confirms a $calendar picker in Persian',
        (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Persian').hitTestable());
      await tester.pumpAndSettle();
      final button = find.byKey(ValueKey('pick-$calendar'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.textContaining(calendar == 'Persian' ? 'فروردین' : 'رمضان'),
          findsWidgets);
      final material = MaterialLocalizations.of(
          tester.element(find.byType(DatePickerDialog)));
      expect(Directionality.of(tester.element(find.byType(DatePickerDialog))),
          TextDirection.rtl);
      await tester.tap(find.text(material.okButtonLabel));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.textContaining('Selected $calendar:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
