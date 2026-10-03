# Changelog

## Unreleased
- Fixed Gregorian symbol selection and removed shared calendar state.
- Replaced copied Persian data with Unicode CLDR 48 Hijri month and era names.
- Implemented local, UTC, strict and loose parsing for all three supported calendars.
- Fixed day-of-year handling, compact numeric fields, hour ranges, two-digit years,
  fractional-second parsing and pattern-cache invalidation.
- Reject malformed quoted patterns and unsupported time-zone patterns explicitly.
- Reuse locale pattern data and preserve ASCII/native digit parsing.
- Added calendar/parsing regression coverage, analysis and formatting CI checks.
- Replaced the counter example and corrected API documentation.
- Added intl and clock dependencies and aligned Flutter support with 3.32 or newer.

## [1.0.1]
- Updated `general_datetime` dependency to `^2.1.0`
- Improved internal date symbol processing and helper utilities
- Refined pattern parsing logic in `StringStack`
- Synchronized Android build configurations for the example project

## [1.0.0]
- Initial stable release
- Added support for a wide range of locales
- Internal optimizations for pattern parsing and string handling
- Updated example project with latest Android configurations
- Documentation improvements and added `LICENSE`

## [0.1.3]
- Updated `README.md` and documentation

## [0.1.2]
- Some optimizations applied
- Updated `README.md` and documentation

## [0.1.1]
- Full implementation of format functions for `JalaliDateTime`
- Updated `README.md` and documentation

## [0.0.1]
- Initial release with support for all platforms
