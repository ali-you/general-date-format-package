
# General Date Format Package

A Flutter package for flexible and generalized date formatting, extending the functionality of the `general_datetime` package to provide an easy-to-use way of formatting dates across different calendar systems.

## Features

- Flexible date formatting based on a variety of calendar systems.
- Locale-aware date formatting to support different regional preferences.
- Easily format dates to string representations in multiple formats.

## Installation

To use this package, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  general_date_format: <latest_version>
```

## Usage

Here's an example of how to use the package to format a date:

```dart
import 'package:general_date_format/general_date_format.dart';

void main() {
  final date = DateTime.now();
  final formattedDate = GeneralDateFormat.format(date, 'yyyy-MM-dd');
  print(formattedDate); // Output: 2025-04-28 (Example)
}
```

### Formatting Options

You can use various formatting patterns, such as:

- `'yyyy-MM-dd'` for a full date.
- `'HH:mm:ss'` for time.
- And other custom patterns based on your needs.

Check the documentation for more advanced usage and available formats.

## Documentation

Full documentation can be found at [General Date Format Docs](https://github.com/ali-you/general-date-format-package).

## Issues

For any issues or feature requests, please check the [issues page](https://github.com/ali-you/general-date-format-package/issues).

## License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for more details.
