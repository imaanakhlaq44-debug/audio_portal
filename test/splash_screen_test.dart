import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imaan_akhlaq/main.dart';
import 'package:imaan_akhlaq/screens/splash_screen.dart';

import 'test_helpers.dart';

/// Records what the navigator was asked to do, so a test can assert on
/// navigation without building (and settling) the destination screen.
class _RouteLog extends NavigatorObserver {
  final List<String> events = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      events.add('push');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      events.add('replace');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      events.add('pop');
}

void main() {
  late Directory dir;

  setUp(() async => dir = await setUpStorage());
  tearDown(() async => tearDownStorage(dir));

  testWidgets('shows the illustration, tagline and call to action', (
    tester,
  ) async {
    await tester.pumpWidget(hostScreen(const SplashScreen()));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Audio Portal Story'), findsOneWidget);
    expect(find.text('START ADVENTURE'), findsOneWidget);
  });

  testWidgets('the call to action replaces the splash with the app shell', (
    tester,
  ) async {
    final log = _RouteLog();
    await tester.pumpWidget(
      hostScreen(const SplashScreen(), navigatorObserver: log),
    );
    await tester.pump();

    await tester.tap(find.text('START ADVENTURE'));
    // Let the route transition finish; one pump only starts it.
    await tester.pumpAndSettle();

    expect(
      log.events,
      contains('replace'),
      reason: 'pushReplacement, so back does not return to the splash',
    );
    expect(find.byType(MainScreen), findsOneWidget);
  });

  testWidgets('cannot be returned to once the app shell is open', (
    tester,
  ) async {
    await tester.pumpWidget(hostScreen(const SplashScreen()));
    await tester.pump();

    await tester.tap(find.text('START ADVENTURE'));
    // Let the route transition finish; one pump only starts it.
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
  });
}
