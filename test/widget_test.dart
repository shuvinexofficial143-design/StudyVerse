import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyverse/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NIOS Senior Secondary home is visible', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StudyVerseApp(onlineConfigured: false));
    await tester.pumpAndSettle();
    expect(find.text('StudyVerse'), findsOneWidget);
    expect(find.text('Your NIOS Class 12 Hub'), findsOneWidget);
    expect(find.text('NIOS Practice Quiz'), findsOneWidget);
  });

  testWidgets('Android back from a tab returns to the previous tab',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StudyVerseApp(onlineConfigured: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Progress').last);
    await tester.pumpAndSettle();
    expect(find.text('NIOS Progress'), findsOneWidget);

    // Dispatch the same pop request as Android's system navigation button.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Your NIOS Class 12 Hub'), findsOneWidget);
  });
}
