// Smoke test for the Qissora app shell.
//
// `MyApp` reads the saved theme through StorageService, so Hive has to be up
// before the widget tree is pumped -- the previous version of this test pumped
// MyApp straight away and always failed on an uninitialised box.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qissora/main.dart';
import 'package:qissora/screens/splash_screen.dart';
import 'package:qissora/services/storage_service.dart';

import 'test_helpers.dart';

void main() {
  late Directory dir;

  setUp(() async {
    // Never hit the network from a test; the app bundles its fonts anyway.
    GoogleFonts.config.allowRuntimeFetching = false;
    dir = await setUpStorage();
  });

  tearDown(() async => tearDownStorage(dir));

  testWidgets('app boots to the splash screen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('START ADVENTURE'), findsOneWidget);
  });

  testWidgets('the saved theme drives MaterialApp.themeMode', (tester) async {
    // Hive writes to a real file, so it has to run outside the fake-async
    // zone testWidgets installs -- awaiting real IO in there deadlocks.
    await tester.runAsync(() => StorageService.setThemeMode(ThemeMode.dark));

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.darkTheme, isNotNull);
  });
}
