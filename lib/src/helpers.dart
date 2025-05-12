class LocaleDataException implements Exception {
  final String message;

  LocaleDataException(this.message);

  @override
  String toString() => 'LocaleDataException: $message';
}

/// Returns an index of a separator between language and region.
/// Assumes that language length can be only 2 or 3.
int _separatorIndex(String locale) {
  if (locale.length < 3) return -1;
  if (locale[2] == '-' || locale[2] == '_') return 2;
  if (locale.length < 4) return -1;
  if (locale[3] == '-' || locale[3] == '_') return 3;
  return -1;
}

String canonicalizedLocale(String? aLocale) {
  if (aLocale == null) return "en_US";
  if (aLocale == 'C') return 'en_ISO';
  if (aLocale.length < 5) return aLocale;

  var separatorIndex = _separatorIndex(aLocale);
  if (separatorIndex == -1) return aLocale;
  var language = aLocale.substring(0, separatorIndex);
  var region = aLocale.substring(separatorIndex + 1);
  if (region.length <= 3) region = region.toUpperCase();
  return '${language}_$region';
}

String? verifiedLocale(String? newLocale, bool Function(String) localeExists) {
  if (newLocale == null) return verifiedLocale("en_US", localeExists);
  if (localeExists(newLocale)) return newLocale;
  final fallbackOptions = [
    canonicalizedLocale,
    shortLocale,
    deprecatedLocale,
    (locale) => deprecatedLocale(shortLocale(locale)),
    (locale) => deprecatedLocale(canonicalizedLocale(locale)),
    (_) => 'fallback'
  ];
  for (var option in fallbackOptions) {
    var localeFallback = option(newLocale);
    if (localeExists(localeFallback)) {
      return localeFallback;
    }
  }
  throw ArgumentError('Invalid locale "$newLocale"');
}

/// Return the other code for a current-deprecated locale pair. This helps in
/// situations where, for example, the user has a `he.arb` file, but gets passed
/// the `iw` locale code.
String deprecatedLocale(String aLocale) {
  switch (aLocale) {
    case 'iw':
      return 'he';
    case 'he':
      return 'iw';
    case 'fil':
      return 'tl';
    case 'tl':
      return 'fil';
    case 'id':
      return 'in';
    case 'in':
      return 'id';
    case 'no':
      return 'nb';
    case 'nb':
      return 'no';
  }
  return aLocale;
}

/// Return the short version of a locale name, e.g. 'en_US' => 'en'
String shortLocale(String aLocale) {
  if (aLocale.length < 2) return aLocale;
  var separatorIndex = _separatorIndex(aLocale);
  if (separatorIndex == -1) {
    return (aLocale.length < 4) ? aLocale.toLowerCase() : aLocale;
  }
  return aLocale.substring(0, separatorIndex).toLowerCase();
}
