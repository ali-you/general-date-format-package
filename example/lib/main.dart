import 'package:flutter/material.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_datetime/general_datetime.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'General Date Format',
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: const FormatExample(),
      );
}

class FormatExample extends StatefulWidget {
  const FormatExample({super.key});

  @override
  State<FormatExample> createState() => _FormatExampleState();
}

class _FormatExampleState extends State<FormatExample> {
  String locale = 'en';

  @override
  Widget build(BuildContext context) {
    final dates = <String, DateTime>{
      'Gregorian': DateTime(2024, 3, 20, 13, 5),
      'Persian': PersianDateTime(1403, 1, 1, 13, 5),
      'Hijri': HijriDateTime(1446, 9, 1, 13, 5),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('General Date Format')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
              'The input date selects the calendar. The locale selects language and digits.'),
          DropdownButton<String>(
            value: locale,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'fa', child: Text('Persian')),
              DropdownMenuItem(value: 'ar', child: Text('Arabic')),
            ],
            onChanged: (value) => setState(() => locale = value!),
          ),
          for (final entry in dates.entries)
            _calendarCard(entry.key, entry.value),
        ],
      ),
    );
  }

  Widget _calendarCard(String name, DateTime date) {
    final numeric = GeneralDateFormat('yyyy/MM/dd', locale);
    final input = numeric.format(date);
    final parsed = numeric.parseStrict(input, date, true);
    final full = GeneralDateFormat.yMMMMEEEEd(locale).add_Hm().format(date);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SelectableText(full),
            SelectableText(input),
            const SizedBox(height: 8),
            Text('Parsed in UTC: ${parsed.isUtc}'),
            Text(
                'Calendar fields: ${parsed.year}/${parsed.month}/${parsed.day}'),
          ],
        ),
      ),
    );
  }
}
