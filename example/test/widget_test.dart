import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Independent fixture: 2024-03-20 is SH 1403-01-01 and AH 1445-09-10.
  final referenceInstant = DateTime.utc(2024, 3, 20, 12, 34, 56, 789, 123);
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets('Demonstrates all calendars and native digits', (tester) async {
    await tester.pumpWidget(MyApp(now: () => referenceInstant));
    expect(find.text('Gregorian'), findsOneWidget);
    expect(find.text('Persian'), findsOneWidget);
    expect(find.text('Hijri'), findsOneWidget);
    expect(find.textContaining('Ramadan'), findsOneWidget);
    expect(find.text('2024/03/20'), findsOneWidget);
    expect(find.text('1403/01/01'), findsOneWidget);
    expect(find.text('1445/09/10'), findsOneWidget);
    expect(find.text('Parsed in UTC: true'), findsNWidgets(3));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Persian').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('۱۴۰۳/۰۱/۰۱'), findsOneWidget);
    expect(find.text('۲۰۲۴/۰۳/۲۰'), findsOneWidget);
    expect(find.text('۱۴۴۵/۰۹/۱۰'), findsOneWidget);
    expect(find.textContaining('رمضان'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final calendar in ['Persian', 'Hijri']) {
    testWidgets('Opens and confirms a $calendar picker in Persian',
        (tester) async {
      await tester.pumpWidget(MyApp(now: () => referenceInstant));
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
      expect(
          find.text(calendar == 'Persian'
              ? 'Selected Persian: ۱۴۰۳/۱/۱'
              : 'Selected Hijri: ۱۴۴۵/۹/۱۰'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'One clock reading keeps all calendars stable across midnight and rebuilds',
      (tester) async {
    final beforeMidnight = DateTime.utc(2024, 3, 20, 23, 59, 59, 999, 999);
    final afterMidnight = DateTime.utc(2024, 3, 21);
    var calls = 0;
    await tester.pumpWidget(MyApp(now: () {
      calls++;
      return calls == 1 ? beforeMidnight : afterMidnight;
    }));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('2024/03/20'), findsOneWidget);
    expect(find.text('1403/01/01'), findsOneWidget);
    expect(find.text('1445/09/10'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Persian').hitTestable());
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('۲۰۲۴/۰۳/۲۰'), findsOneWidget);
    expect(find.text('۱۴۰۳/۰۱/۰۱'), findsOneWidget);
    expect(find.text('۱۴۴۵/۰۹/۱۰'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A new screen captures its own injected instant', (tester) async {
    var calls = 0;
    DateTime now() {
      calls++;
      return calls == 1 ? referenceInstant : DateTime.utc(2024, 3, 21, 12, 34);
    }

    await tester.pumpWidget(MyApp(now: now));
    expect(calls, 1);
    expect(find.text('2024/03/20'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(MyApp(now: now));
    expect(calls, 2);
    expect(find.text('2024/03/21'), findsOneWidget);
    expect(find.text('1403/01/02'), findsOneWidget);
    expect(find.text('1445/09/11'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
