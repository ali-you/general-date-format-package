/// Type for the callback action when a message translation is not found.
typedef MessageIfAbsent = String? Function(
    String? messageText, List<Object>? args);

abstract class MessageLookup {
  String? lookupMessage(String? messageText, String? locale, String? name,
      List<Object>? args, String? meaning,
      {MessageIfAbsent? ifAbsent});

  void addLocale(String localeName, Function findLocale);
}

class LocaleDataException implements Exception {
  final String message;

  LocaleDataException(this.message);

  @override
  String toString() => 'LocaleDataException: $message';
}

///  An abstract superclass for data readers to keep the type system happy.
abstract class LocaleDataReader {
  Future<String> read(String locale);
}

/// If a message is a string literal without interpolation, compute
/// a name based on that and the meaning, if present.
// NOTE: THIS LOGIC IS DUPLICATED IN intl_translation AND THE TWO MUST MATCH.
String? computeMessageName(String? name, String? text, String? meaning) {
  if (name != null && name != '') return name;
  return meaning == null ? text : '${text}_$meaning';
}

/// Returns an index of a separator between language and region.
///
/// Assumes that language length can be only 2 or 3.
int _separatorIndex(String locale) {
  if (locale.length < 3) {
    return -1;
  }
  if (locale[2] == '-' || locale[2] == '_') {
    return 2;
  }
  if (locale.length < 4) {
    return -1;
  }
  if (locale[3] == '-' || locale[3] == '_') {
    return 3;
  }
  return -1;
}

String canonicalizedLocale(String? aLocale) {
// Locales of length < 5 are presumably two-letter forms, or else malformed.
// We return them unmodified and if correct they will be found.
// Locales longer than 6 might be malformed, but also do occur. Do as
// little as possible to them, but make the '-' be an '_' if it's there.
// We treat C as a special case, and assume it wants en_ISO for formatting.
// TODO(alanknight): en_ISO is probably not quite right for the C/Posix
// locale for formatting. Consider adding C to the formats database.
  if (aLocale == null) return "en_US";
  if (aLocale == 'C') return 'en_ISO';
  if (aLocale.length < 5) return aLocale;

  var separatorIndex = _separatorIndex(aLocale);
  if (separatorIndex == -1) {
    return aLocale;
  }
  var language = aLocale.substring(0, separatorIndex);
  var region = aLocale.substring(separatorIndex + 1);
  // If it's longer than three it's something odd, so don't touch it.
  if (region.length <= 3) region = region.toUpperCase();
  return '${language}_$region';
}

String? verifiedLocale(String? newLocale, bool Function(String) localeExists,
    String? Function(String)? onFailure) {
// TODO(alanknight): Previously we kept a single verified locale on the Intl
// object, but with different verification for different uses, that's more
// difficult. As a result, we call this more often. Consider keeping
// verified locales for each purpose if it turns out to be a performance
// issue.
  if (newLocale == null) {
    return verifiedLocale("en_US", localeExists, onFailure);
  }
  if (localeExists(newLocale)) {
    return newLocale;
  }
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
  return (onFailure ?? _throwLocaleError)(newLocale);
}

/// The default action if a locale isn't found in verifiedLocale. Throw
/// an exception indicating the locale isn't correct.
String _throwLocaleError(String localeName) {
  throw ArgumentError('Invalid locale "$localeName"');
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
  // TODO(b/241094372): Remove this check.
  if (aLocale == 'invalid') {
    return 'in';
  }
  if (aLocale.length < 2) {
    return aLocale;
  }
  var separatorIndex = _separatorIndex(aLocale);
  if (separatorIndex == -1) {
    if (aLocale.length < 4) {
      // aLocale is already only a language code.
      return aLocale.toLowerCase();
    } else {
      // Something weird, returning as is.
      return aLocale;
    }
  }
  return aLocale.substring(0, separatorIndex).toLowerCase();
}
