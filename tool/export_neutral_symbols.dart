// Maintainer-only snapshot: the formatter core never imports intl.
import 'dart:convert';
import 'dart:io';

import 'package:intl/date_symbol_data_local.dart' as intl_data;
import 'package:general_date_format_core/src/common/symbol_list.dart';

void main() {
  final source = intl_data.dateTimeSymbolMap();
  final data = <String, Map<String, dynamic>>{};
  for (final locale in symbolList) {
    final fields = source[locale]!.serializeToMap();
    fields.removeWhere((key, _) =>
        key.contains('MONTHS') ||
        key == 'ERAS' ||
        key == 'ERANAMES' ||
        key == 'ZERODIGIT');
    data[locale] = fields;
  }
  File('tool/calendar_neutral_symbols.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(data)}\n',
  );
}
