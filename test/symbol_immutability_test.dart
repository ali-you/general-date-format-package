import 'package:flutter_test/flutter_test.dart';
import 'package:general_date_format/general_date_format.dart';
import 'package:general_date_format/src/date_symbols.dart';
import 'package:general_datetime/general_datetime.dart';

void main() {
  for (final date in [PersianDateTime.utc(1403), HijriDateTime.utc(1446)]) {
    group('${date.runtimeType} symbol isolation', () {
      test('field replacement fails without altering other instances', () {
        final first = GeneralDateFormat('yyyy MMMM dd', 'en');
        final second = GeneralDateFormat('yyyy MMMM dd', 'en');
        final original = first.format(date);
        expect(second.format(date), original);
        final dynamic symbols = first.dateSymbols;
        expect(() => symbols.MONTHS = ['CORRUPTED'], throwsNoSuchMethodError);
        expect(() => symbols.FIRSTDAYOFWEEK = 4, throwsNoSuchMethodError);
        expect(() => symbols.ZERODIGIT = 'x', throwsNoSuchMethodError);
        expect(second.format(date), original);
        expect(GeneralDateFormat('yyyy MMMM dd', 'en').format(date), original);
        expect(first.parseStrict(original, date, true), date);
      });

      test('all collection fields reject mutation', () {
        final format = GeneralDateFormat('yyyy MMMM', 'en')..format(date);
        final symbols = format.dateSymbols;
        final snapshot = symbols.serializeToMap();
        final getters = [
          symbols.ERAS,
          symbols.ERANAMES,
          symbols.NARROWMONTHS,
          symbols.STANDALONENARROWMONTHS,
          symbols.MONTHS,
          symbols.STANDALONEMONTHS,
          symbols.SHORTMONTHS,
          symbols.STANDALONESHORTMONTHS,
          symbols.WEEKDAYS,
          symbols.STANDALONEWEEKDAYS,
          symbols.SHORTWEEKDAYS,
          symbols.STANDALONESHORTWEEKDAYS,
          symbols.NARROWWEEKDAYS,
          symbols.STANDALONENARROWWEEKDAYS,
          symbols.SHORTQUARTERS,
          symbols.QUARTERS,
          symbols.AMPMS,
          symbols.DATEFORMATS,
          symbols.TIMEFORMATS,
          symbols.DATETIMEFORMATS
        ];
        for (final values in getters) {
          expect(() => values[0] = 'CORRUPTED', throwsUnsupportedError);
          expect(() => values.add('CORRUPTED'), throwsUnsupportedError);
        }
        expect(() => symbols.WEEKENDRANGE[0] = 1, throwsUnsupportedError);
        if (symbols.AVAILABLEFORMATS != null) {
          expect(() => symbols.AVAILABLEFORMATS!['y'] = 'CORRUPTED',
              throwsUnsupportedError);
        }
        expect(symbols.serializeToMap(), snapshot);
      });

      test('serialized snapshots are detached through nested collections', () {
        final format = GeneralDateFormat('yyyy MMMM', 'en');
        final text = format.format(date);
        final symbols = format.dateSymbols;
        final snapshot = symbols.serializeToMap();
        (snapshot['MONTHS'] as List<String>)[0] = 'CORRUPTED';
        (snapshot['WEEKENDRANGE'] as List<int>)[0] = 1;
        snapshot['FIRSTDAYOFWEEK'] = 4;
        expect(format.format(date), text);
        expect(GeneralDateFormat('yyyy MMMM', 'en').format(date), text);
        expect(symbols.MONTHS[0], isNot('CORRUPTED'));
      });
    });
  }

  test('constructor does not retain caller-owned lists or maps', () {
    final names = ['Original'];
    final weekend = [5, 6];
    final available = {'custom': 'yyyy'};
    final symbols = DateSymbols(
      NAME: 'custom',
      ERAS: names,
      ERANAMES: names,
      NARROWMONTHS: names,
      STANDALONENARROWMONTHS: names,
      MONTHS: names,
      STANDALONEMONTHS: names,
      SHORTMONTHS: names,
      STANDALONESHORTMONTHS: names,
      WEEKDAYS: names,
      STANDALONEWEEKDAYS: names,
      SHORTWEEKDAYS: names,
      STANDALONESHORTWEEKDAYS: names,
      NARROWWEEKDAYS: names,
      STANDALONENARROWWEEKDAYS: names,
      SHORTQUARTERS: names,
      QUARTERS: names,
      AMPMS: names,
      DATEFORMATS: names,
      TIMEFORMATS: names,
      DATETIMEFORMATS: names,
      FIRSTDAYOFWEEK: 0,
      FIRSTWEEKCUTOFFDAY: 3,
      WEEKENDRANGE: weekend,
      AVAILABLEFORMATS: available,
    );
    names[0] = 'CORRUPTED';
    weekend[0] = 1;
    available['custom'] = 'CORRUPTED';
    expect(symbols.MONTHS, ['Original']);
    expect(symbols.WEEKDAYS, ['Original']);
    expect(symbols.WEEKENDRANGE, [5, 6]);
    expect(symbols.AVAILABLEFORMATS, {'custom': 'yyyy'});
  });

  test('deserialization defensively copies caller collections', () {
    final base = GeneralDateFormat('yyyy MMMM', 'en')
      ..format(PersianDateTime.utc(1403));
    final map = base.dateSymbols.serializeToMap();
    map['AVAILABLEFORMATS'] = <String, String>{'custom': 'yyyy'};
    final symbols = DateSymbols.deserializeFromMap(map);
    (map['MONTHS'] as List<String>)[0] = 'CORRUPTED';
    (map['WEEKENDRANGE'] as List<int>)[0] = 1;
    (map['AVAILABLEFORMATS'] as Map<String, String>)['custom'] = 'CORRUPTED';
    expect(symbols.MONTHS[0], 'Farvardin');
    expect(symbols.AVAILABLEFORMATS!['custom'], 'yyyy');
    expect(() => symbols.AVAILABLEFORMATS!['custom'] = 'CORRUPTED',
        throwsUnsupportedError);
    final copy = symbols.serializeToMap();
    (copy['AVAILABLEFORMATS'] as Map<String, String>)['custom'] = 'CORRUPTED';
    expect(symbols.AVAILABLEFORMATS!['custom'], 'yyyy');
  });
}
