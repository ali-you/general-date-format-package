# General Date Format example

Run `flutter pub get` and `flutter run` from this directory.

The app shows explicit numeric patterns, locale-aware date/time skeletons and
strict UTC parsing for Gregorian, Persian and Hijri dates. Select English,
Persian or Arabic to change the language and native digits.

`DateTime`, `PersianDateTime` and `HijriDateTime` select the calendar. Formatting
does not convert calendars; use `general_datetime` for conversion.
