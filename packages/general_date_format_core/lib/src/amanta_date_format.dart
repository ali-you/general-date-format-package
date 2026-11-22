import 'package:general_datetime_core/general_datetime_core.dart';

import 'helpers.dart';

/// Formats Amanta civil dates in English or Hindi.
///
/// Compact dates use Vikrama year, ordinal month, and sequential civil day.
/// Traditional labels include the leap month and repeated tithi markers.
final class AmantaDateFormat {
  AmantaDateFormat([String locale = 'en'])
      : _hindi = canonicalizedLocale(locale).split('_').first == 'hi';

  final bool _hindi;

  String _formatNumber(int value) {
    final ascii = value.toString();
    return _hindi
        ? String.fromCharCodes(
            ascii.codeUnits.map((digit) => digit - 0x30 + 0x966))
        : ascii;
  }

  String formatCompact(AmantaDate date) => date.toString();

  AmantaDate parseCompact(String input) => AmantaDate.parse(input);

  String formatTraditional(AmantaDate date) {
    final month = (_hindi ? _hindiMonths : _englishMonths)[date.lunarMonth - 1];
    final leap = date.isLeapMonth ? (_hindi ? 'अधिक ' : 'Adhika ') : '';
    final repeat =
        date.isRepeatedTithi ? (_hindi ? ' (द्वितीय)' : ' (second)') : '';
    return '$leap$month ${_formatNumber(date.year)}, '
        '${_hindi ? 'तिथि' : 'tithi'} ${_formatNumber(date.tithi)}$repeat';
  }

  static const _englishMonths = [
    'Chaitra',
    'Vaishakha',
    'Jyeshtha',
    'Ashadha',
    'Shravana',
    'Bhadrapada',
    'Ashvina',
    'Kartika',
    'Margashirsha',
    'Pausha',
    'Magha',
    'Phalguna',
  ];

  static const _hindiMonths = [
    'चैत्र',
    'वैशाख',
    'ज्येष्ठ',
    'आषाढ़',
    'श्रावण',
    'भाद्रपद',
    'आश्विन',
    'कार्तिक',
    'मार्गशीर्ष',
    'पौष',
    'माघ',
    'फाल्गुन',
  ];
}
