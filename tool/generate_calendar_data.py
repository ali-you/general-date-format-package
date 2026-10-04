"""Pinned CLDR 48 calendar generation with verified inputs and compatibility policy.

Use --refresh-lock only when deliberately reviewing the pinned source manifest.
--check never changes tracked output or the lock; caches may be populated.
"""
import argparse
import concurrent.futures
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / 'packages/general_date_format_core/lib/src'
CACHE = ROOT / '.dart_tool/cldr-48-verified'
LOCK = ROOT / 'tool/cldr_sources.lock.json'
BASE = 'https://raw.githubusercontent.com/unicode-org/cldr-json/48.0.0/'
ALIASES = {'en_ISO': 'en', 'in': 'id', 'iw': 'he', 'tl': 'fil', 'no': 'nb',
           'no_NO': 'nb', 'zh_CN': 'zh', 'zh_TW': 'zh-Hant', 'zh_HK': 'zh-Hant-HK'}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--refresh-lock', action='store_true')
    parser.add_argument('--calendar', choices=['all', 'persian', 'hijri'], default='all')
    parser.add_argument('--dart', default='dart')
    args = parser.parse_args(argv)
    if args.check and args.refresh_lock:
        parser.error('--check cannot refresh the source lock')
    locked = json.loads(LOCK.read_text()) if LOCK.exists() else {}
    sources = dict(locked)
    CACHE.mkdir(parents=True, exist_ok=True)

    def load(url, old_cache=None):
        path = CACHE / (hashlib.sha256(url.encode()).hexdigest() + '.json')
        if not path.exists():
            if old_cache and old_cache.exists():
                raw = old_cache.read_bytes()
            else:
                request = urllib.request.Request(url, headers={'User-Agent': 'calendar-data-generator'})
                with urllib.request.urlopen(request, timeout=45) as response:
                    raw = response.read()
            path.write_bytes(raw)
        raw = path.read_bytes()
        digest = hashlib.sha256(raw).hexdigest()
        if not args.refresh_lock and locked.get(url) != digest:
            raise ValueError(f'Unapproved or modified CLDR input: {url}')
        sources[url] = digest
        return json.loads(raw)

    locales = re.findall(r'"([^"]+)"', (CORE / 'common/symbol_list.dart').read_text())
    policy = json.loads((ROOT / 'tool/locale_compatibility.json').read_text(encoding='utf-8'))
    outputs = {}
    audit = {}
    for name, package, calendar in [('persian', 'persian', 'persian'), ('hijri', 'islamic', 'islamic-umalqura')]:
        if args.calendar not in ['all', name]:
            continue
        index_url = f'https://api.github.com/repos/unicode-org/cldr-json/contents/cldr-json/cldr-cal-{package}-full/main?ref=48.0.0'
        old_index = ROOT / '.dart_tool/cldr-48/locales.json' if name == 'hijri' else None
        available = {entry['name'] for entry in load(index_url, old_index)}
        locale_sources = {}
        for locale in locales:
            candidate = ALIASES.get(locale, locale.replace('_', '-'))
            while candidate not in available and '-' in candidate:
                candidate = candidate.rsplit('-', 1)[0]
            if candidate not in available:
                raise ValueError(f'No {calendar} data for {locale}')
            locale_sources[locale] = candidate

        def calendar_data(locale):
            url = BASE + f'cldr-json/cldr-cal-{package}-full/main/{locale}/ca-{calendar}.json'
            old = ROOT / f'.dart_tool/cldr-48/{locale}.json' if name == 'hijri' else None
            if name == 'persian' and locale == 'af':
                old = ROOT / '.dart_tool/cldr-48/persian-af.json'
            return load(url, old)['main'][locale]['dates']['calendars'][calendar]

        unique = sorted(set(locale_sources.values()))
        print(f'Reading {len(unique)} pinned {name} locales', flush=True)
        with concurrent.futures.ThreadPoolExecutor(max_workers=12) as pool:
            data = dict(zip(unique, pool.map(calendar_data, unique)))
        table = {}
        for locale in locales:
            fields = data[locale_sources[locale]]
            values = {}
            for key, context, width in [('MONTHS', 'format', 'wide'), ('SHORTMONTHS', 'format', 'abbreviated'),
                ('NARROWMONTHS', 'format', 'narrow'), ('STANDALONEMONTHS', 'stand-alone', 'wide'),
                ('STANDALONESHORTMONTHS', 'stand-alone', 'abbreviated'), ('STANDALONENARROWMONTHS', 'stand-alone', 'narrow')]:
                values[key] = [fields['months'][context][width][str(i)] for i in range(1, 13)]
            for key, field in [('ERAS', 'eraAbbr'), ('ERANAMES', 'eraNames')]:
                values[key] = [fields['eras'][field]['0']] * 2
            if name == 'persian':
                values.update(policy['persianOverrides'].get(locale, {}))
            table[locale] = values
            # Report retained shared skeletons that differ from Persian CLDR;
            # the existing API chooses skeletons before knowing date calendar.
            if name == 'persian':
                cldr_patterns = fields['dateTimeFormats']['availableFormats']
                audit[locale] = {'sourceLocale': locale_sources[locale],
                    'retainedPatternDifferences': {key: {'package': value, 'CLDR': cldr_patterns.get(key)}
                        for key, value in policy['patterns'].get(locale, {}).items()
                        if cldr_patterns.get(key) != value}}
        outputs[CORE / f'symbols/{name}_calendar_data.dart'] = dart_table(
            f'{name}CalendarData', 'Map<String, Map<String, List<String>>>', table)

    if args.calendar in ['all', 'persian']:
        outputs[CORE / 'common/date_time_patterns.dart'] = dart_table(
            '_dateTimePatternMap', 'Map<String, Map<String, String>>', policy['patterns']) + '\nMap<String, Map<String, String>> get dateTimePatternMap => _dateTimePatternMap;\n'
        outputs[CORE / 'symbols/calendar_locale_policy.dart'] = (
            dart_table('calendarZeroDigits', 'Map<String, String>', policy['zeroDigits']) +
            dart_table('persianDateFormats', 'Map<String, List<String>>', policy['persianDateFormats']))
        outputs[ROOT / 'tool/locale_migration_report.json'] = json.dumps(audit, ensure_ascii=False, indent=2, sort_keys=True) + '\n'
    # Use the Dart formatter for reproducible valid source formatting.
    for path, content in outputs.items():
        if path.suffix == '.dart':
            with tempfile.TemporaryDirectory(dir=CACHE) as directory:
                temporary = Path(directory) / path.name
                temporary.write_text(content, encoding='utf-8')
                subprocess.run([args.dart, 'format', str(temporary)], check=True, stdout=subprocess.DEVNULL)
                content = temporary.read_text(encoding='utf-8')
        if args.check:
            if not path.exists() or path.read_text(encoding='utf-8') != content:
                raise SystemExit(f'Generated output differs: {path}')
        else:
            path.write_text(content, encoding='utf-8', newline='\n')
    if args.refresh_lock:
        LOCK.write_text(json.dumps(sources, indent=2, sort_keys=True) + '\n', encoding='utf-8')
    print('Verified calendar data' if args.check else 'Generated calendar data', flush=True)


def dart_table(name, dart_type, data):
    literal = json.dumps(data, ensure_ascii=False).replace('$', '\\$')
    return ('// Generated from pinned CLDR 48 and tool/locale_compatibility.json.\n'
            '// Input hashes: tool/cldr_sources.lock.json. See THIRD_PARTY_NOTICES.md.\n'
            f'const {name} = <{dart_type[len("Map<"):-1]}>{literal};\n')


if __name__ == '__main__':
    main()
