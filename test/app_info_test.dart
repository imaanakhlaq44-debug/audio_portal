import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imaan_akhlaq/app_info.dart';

void main() {
  test('appVersion matches the version in pubspec.yaml', () {
    // The version is written in two places: pubspec.yaml, which the build
    // uses, and app_info.dart, which the parents dashboard displays. Reading
    // the pubspec through a plugin just to show one string would add platform
    // code for nothing, so they are kept in sync by this test instead.
    //
    // It is not academic: the dashboard read "v1.1.0" through every change in
    // 1.2.0, because nothing connected the two.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+)\+\d+\s*$',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(match, isNotNull, reason: 'no "version: x.y.z+n" in pubspec.yaml');
    expect(
      appVersion,
      match!.group(1),
      reason: 'bump appVersion in lib/app_info.dart to match pubspec.yaml',
    );
  });

  test('appName is set', () {
    expect(appName.trim(), isNotEmpty);
  });
}
