import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyverse/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('study home renders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StudyVerseApp(onlineConfigured: false));
    await tester.pumpAndSettle();
    expect(find.text('StudyVerse'), findsOneWidget);
    expect(find.text('Quick Quiz'), findsOneWidget);
  });
}
