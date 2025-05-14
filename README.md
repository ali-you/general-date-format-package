# General Date Format Package

<a href="https://pub.dev/packages/general_date_format">
   <img src="https://img.shields.io/pub/v/general_date_format?label=pub.dev&labelColor=333940&logo=dart">
</a>
<a href="https://github.com/ali-you/general-date-format-package/issues">
   <img alt="Issues" src="https://img.shields.io/github/issues/ali-you/general-date-format-package?color=0088ff" />
</a>
<a href="https://github.com/ali-you/general-date-format-package/issues?q=is%3Aclosed">
   <img alt="Issues" src="https://img.shields.io/github/issues-closed/ali-you/general-date-format-package?color=0088ff" />
</a>
<!-- <a href="https://github.com/ali-you/ambient-light-plugin/pulls">
   <img alt="GitHub pull requests" src="https://img.shields.io/github/issues-pr/ali-you/ambient-light-plugin?color=0088ff" />
</a> -->
<a href="https://github.com/ali-you/general-date-format-package/pulls">
   <img alt="GitHub Pull Requests" src="https://badgen.net/github/prs/ali-you/general-date-format-package" />
</a>
<a href="https://github.com/ali-you/general-date-format-package/blob/main/LICENSE" rel="ugc">
   <img src="https://img.shields.io/github/license/ali-you/general-date-format-package?color=#007A88&amp;labelColor=333940;" alt="GitHub">
</a>
<a href="https://github.com/ali-you/general-date-format-package">
   <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/ali-you/general-date-format-package">
</a>

![Flutter CI](https://github.com/ali-you/general-date-format-package/actions/workflows/flutter.yml/badge.svg)

A Flutter package for flexible and generalized date formatting, extending the capabilities of the
`general_datetime` package. It provides an intuitive and powerful way to format dates across various
calendar systems (like Jalali and Gregorian) and locales.

## Features

- Locale-aware formatting (e.g., Persian, English, Arabic).
- Support for multiple calendar systems (e.g., Jalali, Gregorian, etc.).
- Simple, consistent syntax similar to intl.DateFormat.
- Supports standard formatting symbols (yyyy, MM, dd, HH, etc.).
- Extendable and suitable for both DateTime and custom date models like JalaliDateTime.

## Installation

To use this plugin, you can add it to your Flutter project in one of two ways:

### 1. Add to `pubspec.yaml`

Include the following dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  general_date_format: <latest_version>

```

### 2. Add directly from the terminal

Run the following command to add the plugin directly to your project:

```bash
flutter pub add general_date_format
```

## Usage

Here's an example of how to use the package to format a date:

```dart
import 'package:general_date_format/general_date_format.dart';

void main() {
  final jalali = JalaliDateTime.now();
  final formatted = GeneralDateFormat.format(jalali, 'yyyy/MM/dd');
  print(formatted); // Example: 1402/02/11
}
```

### Formatting Options

You can use various formatting patterns, such as:

- `'yyyy-MM-dd'` for a full date.
- `'HH:mm:ss'` for time.
- And other custom patterns based on your needs.

Check the documentation for more advanced usage and available formats.

## Documentation

Full documentation can be found at

- [GitHub Repository](https://github.com/ali-you/general-date-format-package).
- [API Reference on pub.dev](https://pub.dev/documentation/general_date_format/latest/).

## Related Packages

- [`general_datetime`](https://pub.dev/packages/general_datetime): Generalized abstraction over
  different calendar systems.
- [`intl`](https://pub.dev/packages/intl): Provides internationalization and localization support.

## Issues

Feel free to open issues and submit pull requests.
For any issues or feature requests, please check
the [issues page](https://github.com/ali-you/general-date-format-package/issues).

## License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for more
details.
