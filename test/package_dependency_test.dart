@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('package code and tooling do not depend directly on intl', () {
    expect(File('pubspec.yaml').readAsStringSync(),
        isNot(matches(RegExp(r'^\s+intl:', multiLine: true))));
    for (final directory in [
      'lib',
      'tool',
      'packages/general_date_format_core'
    ]) {
      for (final file in Directory(directory)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))) {
        expect(file.readAsStringSync(), isNot(contains('package:intl/')),
            reason: file.path);
      }
    }
  });
}
