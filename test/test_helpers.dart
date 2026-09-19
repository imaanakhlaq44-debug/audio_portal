import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qissora/services/audio_player_service.dart';
import 'package:qissora/services/premium_service.dart';
import 'package:qissora/services/storage_service.dart';
import 'package:qissora/services/theme_controller.dart';
import 'package:qissora/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Hive (via `path_provider`) needs a real directory. In tests there is no
/// platform implementation, so we answer the plugin channel with a throwaway
/// temp dir and point Hive at it.
///
/// Call from `setUp`; the matching [tearDownStorage] wipes it again.
Future<Directory> setUpStorage() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final dir = await Directory.systemTemp.createTemp('qissora_test');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => dir.path,
      );

  await StorageService.init(subDir: 'hive');
  return dir;
}

/// Closes and reopens storage on the same directory — what an app restart
/// looks like from the boxes' point of view. Unlike [StorageService.reset]
/// this keeps the data, so tests can assert that something persisted.
Future<void> restartStorage() async {
  await StorageService.close();
  await StorageService.init(subDir: 'hive');
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

/// Runs a storage write from inside a `testWidgets` body.
///
/// Hive writes touch the disk, and awaiting real I/O inside the fake-async
/// zone `testWidgets` installs deadlocks: the clock never advances, so the
/// completion callback never runs and the test hangs with no output.
/// [WidgetTester.runAsync] steps outside that zone, which is the only safe
/// way to do it.
Future<void> writeToStorage(
  WidgetTester tester,
  Future<void> Function() write,
) async {
  await tester.runAsync(write);
}

/// Wraps [screen] in the context the running app gives it.
///
/// Screens read their colours from an [AppColors] theme extension, and the
/// widgets inside them reach for [AudioPlayerService] and [ThemeController]
/// through Provider — so a bare `MaterialApp(home: screen)` throws rather
/// than renders.
///
/// Pass `inScaffold: true` for a screen that is not a [Scaffold] itself and
/// relies on the one MainScreen owns (LibraryScreen and HomeScreen do; their
/// text fields and ink effects need a [Material] ancestor).
///
/// [navigatorObserver] lets a test assert on navigation without having to
/// build the destination.
/// Pass [player] to drive the screen from a test double; it defaults to the
/// real singleton for screens that never touch playback.
///
/// [premium] decides what is locked. It defaults to an unlocked account, so
/// tests about something else are not stopped by the paywall; pass a free
/// one to test the free experience.
Widget hostScreen(
  Widget screen, {
  bool inScaffold = false,
  NavigatorObserver? navigatorObserver,
  AudioPlayerService? player,
  PremiumService? premium,
}) {
  final access =
      premium ?? (PremiumService.forTesting()..isPremiumForTesting = true);
  (player ?? AudioPlayerService.instance).premium = access;
  // Bundled fonts only; a test must never reach for the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AudioPlayerService>.value(
        value: player ?? AudioPlayerService.instance,
      ),
      ChangeNotifierProvider<ThemeController>(create: (_) => ThemeController()),
      ChangeNotifierProvider<PremiumService>.value(value: access),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      navigatorObservers: [if (navigatorObserver != null) navigatorObserver],
      home: inScaffold ? Scaffold(body: screen) : screen,
    ),
  );
}
