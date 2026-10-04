# Changelog

## 1.0.0 — release preparation

- Extract the corrected pure Dart implementation from the Flutter package.
- Preserve exact microseconds in six-digit fraction formatting/parsing, including
  localized digits, and reject excess nonzero precision in strict/loose parsing.
- Generate Persian and Umm al-Qura names from checksum-locked CLDR 48 sources,
  preserving documented locale and shared-pattern compatibility policies.
