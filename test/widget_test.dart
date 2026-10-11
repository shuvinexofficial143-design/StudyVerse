import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyverse/main.dart';
import 'package:studyverse/study_screens.dart';

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
  testWidgets('Study extras open and Android back returns one page',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StudyVerseApp(onlineConfigured: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Study').last);
    await tester.pumpAndSettle();
    final pdfLink = find.text('Offline PDF Reader');
    final studyScroll = find.descendant(
      of: find.byType(StudyScreen), matching: find.byType(Scrollable));
    await tester.scrollUntilVisible(pdfLink, 200, scrollable: studyScroll.first);
    await tester.pumpAndSettle();
    await tester.tap(pdfLink);
    await tester.pumpAndSettle();
    expect(find.text('Offline PDF Library'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('NIOS Study & Notes'), findsOneWidget);
  });

  testWidgets('Back in quiz navigates to previous question rather than exit',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StudyVerseApp(onlineConfigured: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quiz').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Start Quick Quiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Quick Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 10'), findsOneWidget);
    // Select the first radio-style answer tile.
    final answers = find.byType(ListTile);
    await tester.tap(answers.first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Next Question'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next Question'));
    await tester.pumpAndSettle();
    expect(find.text('Question 2 of 10'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 10'), findsOneWidget);
  });

}
