# General Date Format example

This example uses the local formatter 3.0.0 and chronology 4.0.0 pair with
both cores at 2.0.0. Hebrew support requires these versions. Until the hosted
releases are published, select the local cores. From the formatter repository root:

```console
python tool/resolve_calendar_pair.py --chronology ../general_date --formatter .
```

Then run `flutter pub get` and `flutter run` from this directory. The helper
writes ignored overrides for all required local packages. Remove development
overrides and resolve matching hosted versions before release verification.

The app shows explicit numeric patterns, locale-aware date/time skeletons and
strict UTC parsing for Gregorian (via application-owned `intl.DateFormat`),
Persian, Hijri, and Hebrew dates. The app uses Flutter localization delegates to initialize
intl; the calendar formatter core does not initialize it. Select English,
Persian, Arabic, or Hebrew to change the language and native digits.

`DateTime`, `PersianDateTime`, `HijriDateTime`, and `HebrewDateTime` select the calendar. Formatting
does not convert calendars; use `general_datetime` for conversion.

The screen samples `DateTime.now` once, then derives Persian, Hijri, and Hebrew values
from that same native instant. It retains the snapshot while changing locale
or opening a picker; creating a new screen samples time again.

Tests use an injected clock instead of the machine's current date:

```dart
MyApp(now: () => DateTime.utc(2024, 3, 20, 12, 34))
```

The fixed fixture is Gregorian 2024-03-20, Persian 1403-01-01, and Umm al-Qura
1445-09-10, and Hebrew 5784-07-10. The suite verifies numeric/native digits, all three localized picker
selections, a clock crossing midnight, locale rebuilds, and fresh screen state.
Run `flutter test` from this directory to verify it.
