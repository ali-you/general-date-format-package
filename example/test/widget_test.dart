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
}
