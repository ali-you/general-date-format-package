# General Date Format example

Run `flutter pub get` and `flutter run` from this directory.

The app shows explicit numeric patterns, locale-aware date/time skeletons and
strict UTC parsing for Gregorian (via application-owned `intl.DateFormat`),
Persian and Hijri dates. The app uses Flutter localization delegates to initialize
intl; the calendar formatter core does not initialize it. Select English,
Persian or Arabic to change the language and native digits.

`DateTime`, `PersianDateTime` and `HijriDateTime` select the calendar. Formatting
does not convert calendars; use `general_datetime` for conversion.

The screen samples `DateTime.now` once, then derives Persian and Hijri values
from that same native instant. It retains the snapshot while changing locale
or opening a picker; creating a new screen samples time again.

Tests use an injected clock instead of the machine's current date:

```dart
MyApp(now: () => DateTime.utc(2024, 3, 20, 12, 34))
```

The fixed fixture is Gregorian 2024-03-20, Persian 1403-01-01, and Umm al-Qura
1445-09-10. The suite verifies numeric/native digits, both localized picker
selections, a clock crossing midnight, locale rebuilds, and fresh screen state.
Run `flutter test` from this directory to verify it.
