import 'package:flutter_test/flutter_test.dart';

void main() {
  const zone = String.fromEnvironment('CALENDAR_TEST_TZ');
  test('requested process timezone really supplies its independent DST rules',
      () {
    switch (zone) {
      case '':
        return; // Host-local developer run; no requested timezone.
      case 'UTC':
        expect(DateTime(2021, 3, 14, 12).timeZoneOffset, Duration.zero);
        break;
      case 'America/New_York':
        expect(DateTime(2021, 3, 14, 12).timeZoneOffset,
            const Duration(hours: -4));
        expect(DateTime(2021, 3, 14, 12).difference(DateTime(2021, 3, 13, 12)),
            const Duration(hours: 23));
        expect(DateTime(2021, 11, 7, 12).difference(DateTime(2021, 11, 6, 12)),
            const Duration(hours: 25));
        break;
      case 'Asia/Tehran':
        expect(DateTime(2019, 3, 22, 12).timeZoneOffset,
            const Duration(hours: 4, minutes: 30));
        expect(DateTime(2019, 3, 22, 12).difference(DateTime(2019, 3, 21, 12)),
            const Duration(hours: 23));
        expect(DateTime(2019, 9, 22, 12).difference(DateTime(2019, 9, 21, 12)),
            const Duration(hours: 25));
        break;
      default:
        fail('Unsupported requested timezone: $zone');
    }
  });
}
