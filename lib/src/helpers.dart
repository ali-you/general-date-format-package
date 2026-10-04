class LocaleDataException implements Exception {
  final String message;

  LocaleDataException(this.message);

  @override
  String toString() => 'LocaleDataException: $message';
}

/// Normalize language, script and region independently, accepting either
/// BCP-47 hyphens or the underscores used by the bundled locale tables.
String canonicalizedLocale(String? aLocale) {
  if (aLocale == null) return 'en_US';
  if (aLocale == 'C') return 'en_ISO';
  final parts = aLocale.replaceAll('-', '_').split('_');
  if (parts.join('_').toLowerCase() == 'en_iso') return 'en_ISO';
  parts[0] = parts[0].toLowerCase();
  var index = 1;
  if (index < parts.length && _script.hasMatch(parts[index])) {
    final script = parts[index].toLowerCase();
    parts[index++] = '${script[0].toUpperCase()}${script.substring(1)}';
  }
  if (index < parts.length && _region.hasMatch(parts[index])) {
    parts[index] = parts[index].toUpperCase();
    index++;
  }
  for (; index < parts.length; index++) {
    parts[index] = parts[index].toLowerCase();
  }
  return parts.join('_');
}

final _script = RegExp(r'^[A-Za-z]{4}$');
final _region = RegExp(r'^(?:[A-Za-z]{2}|[0-9]{3})$');

/// Resolve against a data set without throwing, for delegate support checks.
/// Variants/extensions may match an exact key; otherwise their preferences are
/// ignored. This is a bundled-data fallback policy, not a full CLDR matcher.
String? resolveLocale(String? locale, bool Function(String) localeExists) {
  for (final candidate in _localeCandidates(locale ?? 'en_US').toSet()) {
    if (localeExists(candidate)) return candidate;
  }
  return null;
}

String verifiedLocale(String? newLocale, bool Function(String) localeExists) {
  final resolved = resolveLocale(newLocale, localeExists);
  if (resolved != null) return resolved;
  throw ArgumentError('Invalid locale "$newLocale"');
}

Iterable<String> _localeCandidates(String locale) sync* {
  yield locale;
  final normalized = canonicalizedLocale(locale);
  yield normalized;
  final parts = normalized.split('_');
  final language = parts.first;
  final languages = {language, deprecatedLocale(language)};
  var index = 1;
  final script = index < parts.length && _script.hasMatch(parts[index])
      ? parts[index++]
      : null;
  final region = index < parts.length && _region.hasMatch(parts[index])
      ? parts[index++]
      : null;

  // Try complete language aliases and the base locale before dropping region.
  for (final code in languages) {
    yield [code, ...parts.skip(1)].join('_');
    yield [code, if (script != null) script, if (region != null) region]
        .join('_');
  }
  if (script != null) {
    for (final code in languages) {
      yield '${code}_$script';
    }
  }

  // intl/bundled Chinese data uses regional keys instead of script keys.
  // An explicit script wins over a region whose usual script would conflict.
  if (language == 'zh' && script == 'Hant') {
    yield region == 'HK' || region == 'MO' ? 'zh_HK' : 'zh_TW';
    yield region == 'HK' || region == 'MO' ? 'zh_TW' : 'zh_HK';
  } else if (language == 'zh' && script == 'Hans') {
    yield 'zh_CN';
  } else if (region != null) {
    for (final code in languages) {
      yield '${code}_$region';
    }
  }
  yield* languages;
  yield 'fallback';
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
  return canonicalizedLocale(aLocale).split('_').first;
}
