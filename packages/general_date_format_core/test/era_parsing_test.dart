import 'package:general_date_format_core/general_date_format_core.dart';
import 'package:general_date_format_core/src/date_symbols.dart';
import 'package:general_datetime_core/general_datetime_core.dart';
import 'package:test/test.dart';

// Supply distinct/ambiguous names without changing the pinned locale tables.
class _EraFormat extends GeneralDateFormat {
  final List<String> eras;
  final List<String> eraNames;

  _EraFormat(String pattern,
      {this.eras = const ['BP', 'AP'],
      this.eraNames = const ['Before Persia', 'Anno Persia']})
      : super(pattern, 'en');

  @override
  DateSymbols get dateSymbols =>
      DateSymbols.deserializeFromMap(super.dateSymbols.serializeToMap()
        ..['ERAS'] = eras
        ..['ERANAMES'] = eraNames);
}

void main() {
  final selector = PersianDateTime.utc(1403);

  void expectRejected(GeneralDateFormat format, String input, bool utc) {
    expect(
        () => format.parseStrict(input, selector, utc), throwsFormatException);
    expect(
        () => format.parseLoose(input, selector, utc), throwsFormatException);
    expect(format.tryParseStrict(input, selector, utc), isNull);
    expect(format.tryParseLoose(input, selector, utc), isNull);
  }

  for (final utc in [false, true]) {
    for (final pattern in ['G', 'GGGG', 'G GGGG', 'GGGG G']) {
      test('distinct eras agree with signed years $pattern utc=$utc', () {
        final format = _EraFormat('$pattern yyyy-MM-dd');
        for (final year in [-1, 0, 1]) {
          final date = utc ? PersianDateTime.utc(year) : PersianDateTime(year);
          final input = format.format(date);
          expect(format.parseStrict(input, selector, utc), date);
          expect(format.parseLoose(input.toLowerCase(), selector, utc), date);
          final conflict = year > 0
              ? input.replaceAll('AP', 'BP').replaceAll('Anno', 'Before')
              : input.replaceAll('BP', 'AP').replaceAll('Before', 'Anno');
          expectRejected(format, conflict, utc);
          // Permissive parsing keeps the signed numeric year authoritative.
          expect(format.parse(conflict, selector, utc), date);
        }
      });
    }

    test('bundled era names round trip both calendars utc=$utc', () {
      for (final locale in GeneralDateFormat.allLocalesWithSymbols()) {
        for (final pattern in ['G yyyy-MM-dd', 'GGGG yyyy-MM-dd']) {
          final format = GeneralDateFormat(pattern, locale);
          for (final year in [-1, 0, 1]) {
            final date =
                utc ? PersianDateTime.utc(year) : PersianDateTime(year);
            final input = format.format(date);
            expect(format.parseStrict(input, selector, utc), date,
                reason: '$locale $pattern year=$year');
            expect(format.parseLoose(input, selector, utc), date,
                reason: '$locale $pattern year=$year');
          }
          final hijri = utc ? HijriDateTime.utc(1445) : HijriDateTime(1445);
          final input = format.format(hijri);
          expect(format.parseStrict(input, hijri, utc), hijri);
          expect(format.parseLoose(input, hijri, utc), hijri);
        }
      }
    });
  }

  for (final pattern in ['G GGGG', 'GGGG G']) {
    test('ambiguous abbreviation agrees with distinct full name $pattern', () {
      final format = _EraFormat('$pattern yyyy-MM-dd', eras: ['AP', 'AP']);
      for (final year in [-1, 0, 1]) {
        final date = PersianDateTime.utc(year);
        final input = format.format(date);
        expect(format.parseStrict(input, selector, true), date);
        expect(format.parseLoose(input.toLowerCase(), selector, true), date);
      }
      final conflict =
          format.format(PersianDateTime.utc(-1)).replaceAll('Before', 'Anno');
      expectRejected(format, conflict, true);
    });
  }

  test('repeated distinct era labels cannot contradict one another', () {
    final format = _EraFormat('G GGGG yyyy-MM-dd');
    expectRejected(format, 'BP Anno Persia -0001-01-01', true);
    expectRejected(format, 'AP Before Persia 0001-01-01', true);
  });

  test('loose era aliases retain every case/whitespace equivalent meaning', () {
    final format =
        _EraFormat('GGGG yyyy-MM-dd', eraNames: ['Solar Year', 'solar  year']);
    for (final year in [-1, 0, 1]) {
      final date = PersianDateTime.utc(year);
      expect(format.parseStrict(format.format(date), selector, true), date);
      final numericYear =
          '${year < 0 ? '-' : ''}${year.abs().toString().padLeft(4, '0')}';
      expect(
          format.parseLoose('SOLAR   YEAR $numericYear-01-01', selector, true),
          date);
    }
    expect(format.tryParseStrict('solar  year -0001-01-01', selector, true),
        isNull);
  });

  test('era validation uses the resolved century and default year', () {
    final format = _EraFormat('G yy-MM-dd')
      ..now = () => PersianDateTime.utc(-20).toDateTime();
    expect(format.parseStrict('BP 99-01-01', selector, true),
        PersianDateTime.utc(-1));
    expectRejected(format, 'AP 99-01-01', true);
    final defaultYear = _EraFormat('G');
    expectRejected(defaultYear, 'BP', true);
    expect(defaultYear.parseStrict('AP', selector, true).year, greaterThan(0));
  });
}
