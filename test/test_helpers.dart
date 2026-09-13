import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imaan_akhlaq/services/storage_service.dart';

/// Hive (via `path_provider`) needs a real directory. In tests there is no
/// platform implementation, so we answer the plugin channel with a throwaway
/// temp dir and point Hive at it.
///
/// Call from `setUp`; the matching [tearDownStorage] wipes it again.
Future<Directory> setUpStorage() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final dir = await Directory.systemTemp.createTemp('imaan_akhlaq_test');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => dir.path,
      );

  await StorageService.init(subDir: 'hive');
  return dir;
}

Future<void> tearDownStorage(Directory dir) async {
  await StorageService.reset();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
  if (dir.existsSync()) dir.deleteSync(recursive: true);
}
