// Basic smoke test for the Imaan & Akhlaq app.

import 'package:flutter_test/flutter_test.dart';

import 'package:imaan_akhlaq/main.dart';

void main() {
  testWidgets('App loads home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify the app renders without crashing.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
