// Symbol field names follow intl's serialized date data schema.
// ignore_for_file: non_constant_identifier_names, constant_identifier_names

/// Immutable locale symbols with defensive copies of all collection inputs.
class DateSymbols {
  final String NAME;
  final List<String>

      /// The short name of the era, e.g. 'BC' or 'AD'
      ERAS,

      /// The long name of the era, e.g. 'Before Christ' or 'Anno Domino'
      ERANAMES,

      /// Very short names of months, e.g. 'J'.
      NARROWMONTHS,

      /// Very short names of months as they would be written on their own,
      /// e.g. 'J'.
      STANDALONENARROWMONTHS,

      /// Full names of months, e.g. 'January'.
      MONTHS,

      /// Full names of months as they would be written on their own,
      /// e.g. 'January'.
      ///
      /// These are frequently the same as MONTHS, but for example might start
      /// with upper case where the names in MONTHS might not.
      STANDALONEMONTHS,

      /// Short names of months, e.g. 'Jan'.
      SHORTMONTHS,

      /// Short names of months as they would be written on their own,
      /// e.g. 'Jan'.
      STANDALONESHORTMONTHS,

      /// The days of the week, starting with Sunday.
      WEEKDAYS,

      /// The days of the week as they would be written on their own, starting
      /// with Sunday.
      /// Frequently the same as WEEKDAYS, but for example might
      /// start with upper case where the names in WEEKDAYS might not.
      STANDALONEWEEKDAYS,

      /// Short names for days of the week, starting with Sunday, e.g. 'Sun'.
      SHORTWEEKDAYS,

      /// Short names for days of the week as they would be written on their
      /// own, starting with Sunday, e.g. 'Sun'.
      STANDALONESHORTWEEKDAYS,

      /// Very short names for days of the week, starting with Sunday, e.g. 'S'.
      NARROWWEEKDAYS,

      /// Very short names for days of the week as they would be written on
      /// their own, starting with Sunday, e.g. 'S'.
      STANDALONENARROWWEEKDAYS,

      /// Names of the quarters of the year in a short form, e.g. 'Q1'.
      SHORTQUARTERS,

      /// Long names of the quartesr of the year, e.g. '1st Quarter'.
      QUARTERS,

      /// A list of length 2 with localized text for 'AM' and 'PM'.
      AMPMS,

      /// The supported date formats for this locale.
      DATEFORMATS,

      /// The supported time formats for this locale.
      TIMEFORMATS,

      /// The ways date and time formats can be combined for this locale.
      DATETIMEFORMATS;
  final Map<String, String>? AVAILABLEFORMATS;

  /// The first day of the week, in ISO 8601 style, where the first day of the
  /// week, i.e. index 0, is Monday.
  final int FIRSTDAYOFWEEK;

  /// Which days are weekend days, integers where 0=Monday.
  ///
  /// For example, [5, 6] to mean Saturday and Sunday are weekend days.
  final List<int> WEEKENDRANGE;
  final int FIRSTWEEKCUTOFFDAY;

  final String? ZERODIGIT;

  DateSymbols({
    required this.NAME,
    required List<String> ERAS,
    required List<String> ERANAMES,
    required List<String> NARROWMONTHS,
    required List<String> STANDALONENARROWMONTHS,
    required List<String> MONTHS,
    required List<String> STANDALONEMONTHS,
    required List<String> SHORTMONTHS,
    required List<String> STANDALONESHORTMONTHS,
    required List<String> WEEKDAYS,
    required List<String> STANDALONEWEEKDAYS,
    required List<String> SHORTWEEKDAYS,
    required List<String> STANDALONESHORTWEEKDAYS,
    required List<String> NARROWWEEKDAYS,
    required List<String> STANDALONENARROWWEEKDAYS,
    required List<String> SHORTQUARTERS,
    required List<String> QUARTERS,
    required List<String> AMPMS,
    required List<String> DATEFORMATS,
    required List<String> TIMEFORMATS,
    required List<String> DATETIMEFORMATS,
    this.ZERODIGIT,
    Map<String, String>? AVAILABLEFORMATS,
    required this.FIRSTDAYOFWEEK,
    required List<int> WEEKENDRANGE,
    required this.FIRSTWEEKCUTOFFDAY,
  })  : ERAS = List<String>.unmodifiable(ERAS),
        ERANAMES = List<String>.unmodifiable(ERANAMES),
        NARROWMONTHS = List<String>.unmodifiable(NARROWMONTHS),
        STANDALONENARROWMONTHS =
            List<String>.unmodifiable(STANDALONENARROWMONTHS),
        MONTHS = List<String>.unmodifiable(MONTHS),
        STANDALONEMONTHS = List<String>.unmodifiable(STANDALONEMONTHS),
        SHORTMONTHS = List<String>.unmodifiable(SHORTMONTHS),
        STANDALONESHORTMONTHS =
            List<String>.unmodifiable(STANDALONESHORTMONTHS),
        WEEKDAYS = List<String>.unmodifiable(WEEKDAYS),
        STANDALONEWEEKDAYS = List<String>.unmodifiable(STANDALONEWEEKDAYS),
        SHORTWEEKDAYS = List<String>.unmodifiable(SHORTWEEKDAYS),
        STANDALONESHORTWEEKDAYS =
            List<String>.unmodifiable(STANDALONESHORTWEEKDAYS),
        NARROWWEEKDAYS = List<String>.unmodifiable(NARROWWEEKDAYS),
        STANDALONENARROWWEEKDAYS =
            List<String>.unmodifiable(STANDALONENARROWWEEKDAYS),
        SHORTQUARTERS = List<String>.unmodifiable(SHORTQUARTERS),
        QUARTERS = List<String>.unmodifiable(QUARTERS),
        AMPMS = List<String>.unmodifiable(AMPMS),
        DATEFORMATS = List<String>.unmodifiable(DATEFORMATS),
        TIMEFORMATS = List<String>.unmodifiable(TIMEFORMATS),
        DATETIMEFORMATS = List<String>.unmodifiable(DATETIMEFORMATS),
        AVAILABLEFORMATS = AVAILABLEFORMATS == null
            ? null
            : Map<String, String>.unmodifiable(AVAILABLEFORMATS),
        WEEKENDRANGE = List<int>.unmodifiable(WEEKENDRANGE);

  factory DateSymbols.deserializeFromMap(Map<dynamic, dynamic> map) {
    List<String> getStringList(String name) => List<String>.from(map[name]);

    return DateSymbols(
      NAME: map['NAME'],
      ERAS: getStringList('ERAS'),
      ERANAMES: getStringList('ERANAMES'),
      NARROWMONTHS: getStringList('NARROWMONTHS'),
      STANDALONENARROWMONTHS: getStringList('STANDALONENARROWMONTHS'),
      MONTHS: getStringList('MONTHS'),
      STANDALONEMONTHS: getStringList('STANDALONEMONTHS'),
      SHORTMONTHS: getStringList('SHORTMONTHS'),
      STANDALONESHORTMONTHS: getStringList('STANDALONESHORTMONTHS'),
      WEEKDAYS: getStringList('WEEKDAYS'),
      STANDALONEWEEKDAYS: getStringList('STANDALONEWEEKDAYS'),
      SHORTWEEKDAYS: getStringList('SHORTWEEKDAYS'),
      STANDALONESHORTWEEKDAYS: getStringList('STANDALONESHORTWEEKDAYS'),
      NARROWWEEKDAYS: getStringList('NARROWWEEKDAYS'),
      STANDALONENARROWWEEKDAYS: getStringList('STANDALONENARROWWEEKDAYS'),
      SHORTQUARTERS: getStringList('SHORTQUARTERS'),
      QUARTERS: getStringList('QUARTERS'),
      AMPMS: getStringList('AMPMS'),
      ZERODIGIT: map['ZERODIGIT'],
      DATEFORMATS: getStringList('DATEFORMATS'),
      TIMEFORMATS: getStringList('TIMEFORMATS'),
      AVAILABLEFORMATS: Map<String, String>.from(map['AVAILABLEFORMATS'] ?? {}),
      FIRSTDAYOFWEEK: map['FIRSTDAYOFWEEK'],
      WEEKENDRANGE: List<int>.from(map['WEEKENDRANGE']),
      FIRSTWEEKCUTOFFDAY: map['FIRSTWEEKCUTOFFDAY'],
      DATETIMEFORMATS: getStringList('DATETIMEFORMATS'),
    );
  }

  Map<String, dynamic> serializeToMap() {
    var basicMap = _serializeToMap();
    if (ZERODIGIT != null && ZERODIGIT != '') {
      basicMap['ZERODIGIT'] = ZERODIGIT;
    }
    return basicMap;
  }

  Map<String, dynamic> _serializeToMap() => {
        'NAME': NAME,
        'ERAS': [...ERAS],
        'ERANAMES': [...ERANAMES],
        'NARROWMONTHS': [...NARROWMONTHS],
        'STANDALONENARROWMONTHS': [...STANDALONENARROWMONTHS],
        'MONTHS': [...MONTHS],
        'STANDALONEMONTHS': [...STANDALONEMONTHS],
        'SHORTMONTHS': [...SHORTMONTHS],
        'STANDALONESHORTMONTHS': [...STANDALONESHORTMONTHS],
        'WEEKDAYS': [...WEEKDAYS],
        'STANDALONEWEEKDAYS': [...STANDALONEWEEKDAYS],
        'SHORTWEEKDAYS': [...SHORTWEEKDAYS],
        'STANDALONESHORTWEEKDAYS': [...STANDALONESHORTWEEKDAYS],
        'NARROWWEEKDAYS': [...NARROWWEEKDAYS],
        'STANDALONENARROWWEEKDAYS': [...STANDALONENARROWWEEKDAYS],
        'SHORTQUARTERS': [...SHORTQUARTERS],
        'QUARTERS': [...QUARTERS],
        'AMPMS': [...AMPMS],
        'DATEFORMATS': [...DATEFORMATS],
        'TIMEFORMATS': [...TIMEFORMATS],
        'AVAILABLEFORMATS': AVAILABLEFORMATS == null
            ? null
            : Map<String, String>.from(AVAILABLEFORMATS!),
        'FIRSTDAYOFWEEK': FIRSTDAYOFWEEK,
        'WEEKENDRANGE': [...WEEKENDRANGE],
        'FIRSTWEEKCUTOFFDAY': FIRSTWEEKCUTOFFDAY,
        'DATETIMEFORMATS': [...DATETIMEFORMATS],
      };

  @override
  String toString() => NAME;
}
