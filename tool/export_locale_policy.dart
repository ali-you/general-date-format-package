// One-time migration snapshot. Edit the JSON policy after reviewing changes;
// do not rerun this exporter against already migrated data.
import 'dart:convert';
import 'dart:io';
import 'package:general_date_format_core/src/common/date_time_patterns.dart';
import 'package:general_date_format_core/src/symbols/persian_calendar_symbol_data_local.dart';

void main() {
  final iso = persianDateSymbolMap['en_ISO']!;
  final policy = {
    'reason': 'Preserve the existing calendar-independent skeleton API, date '
        'ordering, native-digit defaults, and explicit en_ISO short labels. '
        'CLDR month/era translations are migrated separately. These are '
        'application compatibility choices, not claims of CLDR equivalence.',
    'patterns': dateTimePatternMap,
    'zeroDigits': {
      for (final entry in persianDateSymbolMap.entries)
        if (entry.value.ZERODIGIT != null) entry.key: entry.value.ZERODIGIT
    },
    'persianDateFormats': {
      for (final entry in persianDateSymbolMap.entries)
        entry.key: entry.value.DATEFORMATS
    },
    'persianOverrides': {
      'en_ISO': {
        'SHORTMONTHS': iso.SHORTMONTHS,
        'STANDALONESHORTMONTHS': iso.STANDALONESHORTMONTHS,
        'ERAS': iso.ERAS,
        'ERANAMES': iso.ERANAMES
      }
    },
  };
  File('tool/locale_compatibility.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(policy)}\n');
}
