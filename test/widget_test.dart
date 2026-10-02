import 'package:cyberpath/app.dart';
import 'package:cyberpath/features/progress/application/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester t, Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  await t.pumpWidget(ProviderScope(overrides: [prefsProvider.overrideWithValue(prefs)], child: const CyberPathApp()));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('fresh install shows onboarding and reaches home', (t) async {
    await pumpApp(t, {});
    expect(find.text('Learn Cybersecurity.'), findsOneWidget);
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    await t.tap(find.text('Get started'));
    await t.pumpAndSettle();
    expect(find.text('Ready to build real skills?'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('bottom navigation switches tabs', (t) async {
    await pumpApp(t, {
      'cyberpath.progress.v1': '{"onboarded":true}',
    });
    expect(find.text('Ready to build real skills?'), findsOneWidget);
    await t.tap(find.text('Learn'));
    await t.pumpAndSettle();
    expect(find.text('Linux Fundamentals'), findsOneWidget);
    await t.tap(find.text('Profile'));
    await t.pumpAndSettle();
    expect(find.text('Skill tree'), findsOneWidget);
  });

  testWidgets('quiz scoring: a correct answer enables Continue', (t) async {
    await pumpApp(t, {'cyberpath.progress.v1': '{"onboarded":true}'});
    await t.tap(find.text('Learn'));
    await t.pumpAndSettle();
    await t.tap(find.text('Linux Fundamentals'));
    await t.pumpAndSettle();
    await t.tap(find.text('The Shell & Filesystem'));
    await t.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await t.tap(find.text('Continue'));
      await t.pumpAndSettle();
    }
    // Multiple-choice block: Continue is disabled until answered.
    expect(t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue')).onPressed, isNull);
    await t.tap(find.text('pwd').last);
    await t.pump();
    await t.tap(find.text('Check'));
    await t.pumpAndSettle();
    expect(find.textContaining('Correct.'), findsOneWidget);
    expect(t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue')).onPressed, isNotNull);
  });
}
