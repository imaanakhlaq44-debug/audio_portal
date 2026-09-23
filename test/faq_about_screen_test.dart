import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qissora/screens/about_screen.dart';
import 'package:qissora/screens/faq_screen.dart';

import 'test_helpers.dart';

void main() {
  late Directory dir;
  setUp(() async => dir = await setUpStorage());
  tearDown(() async => tearDownStorage(dir));

  testWidgets('a FAQ opens to show its answer and closes again', (t) async {
    await t.pumpWidget(hostScreen(const FaqScreen(), inScaffold: true));
    final faq = faqGroups.first.faqs.first;

    expect(find.text(faq.question), findsOneWidget);
    expect(find.text(faq.answer), findsNothing);

    await t.tap(find.text(faq.question));
    await t.pumpAndSettle();
    expect(find.text(faq.answer), findsOneWidget);

    await t.tap(find.text(faq.question));
    await t.pumpAndSettle();
    expect(find.text(faq.answer), findsNothing);
  });

  testWidgets('About shows every section and the contact button', (t) async {
    await t.pumpWidget(hostScreen(const AboutScreen(), inScaffold: true));
    for (final title in [
      'Guided by Imaan & Akhlaq',
      'Our Vision',
      'Introduction',
      'Core Objectives',
      'Progression Focus',
      'Contact Us on WhatsApp',
    ]) {
      await t.scrollUntilVisible(find.text(title), 300);
      expect(find.text(title), findsOneWidget, reason: title);
    }
  });
}
