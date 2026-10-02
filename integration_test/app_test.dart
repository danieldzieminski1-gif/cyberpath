import 'package:cyberpath/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding to terminal lab', (t) async {
    app.main();
    await t.pumpAndSettle(const Duration(seconds: 2));
    if (find.text('Next').evaluate().isNotEmpty) {
      await t.tap(find.text('Next'));
      await t.pumpAndSettle();
      await t.tap(find.text('Next'));
      await t.pumpAndSettle();
      await t.tap(find.text('Get started'));
      await t.pumpAndSettle();
    }
    await t.tap(find.text('Practice'));
    await t.pumpAndSettle();
    await t.tap(find.text('Terminal Lab').first);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'pwd');
    await t.testTextInput.receiveAction(TextInputAction.send);
    await t.pumpAndSettle();
    expect(find.text('/home/learner'), findsOneWidget);
  });
}
