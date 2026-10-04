# Changelog

## Unreleased

- Remove Gregorian formatting/parsing from GeneralDateFormat; applications use
  intl.DateFormat directly and choose their own locale initialization.
- Bundle Persian/Hijri neutral locale metadata and remove intl and clock from
  the Dart core. The Flutter Material adapter retains its required intl bridge.
- Add a per-formatter native `now` callback for two-digit year parsing.
- Default pre-operation dateSymbols to Persian; reject native DateTime selectors
  with UnsupportedError, including nullable parsing APIs.

## 1.0.0 — release preparation

- Extract the corrected pure Dart implementation from the Flutter package.
- Preserve exact microseconds in six-digit fraction formatting/parsing, including
  localized digits, and reject excess nonzero precision in strict/loose parsing.
- Generate Persian and Umm al-Qura names from checksum-locked CLDR 48 sources,
  preserving documented locale and shared-pattern compatibility policies.
