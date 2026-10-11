import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyverse/study_extras.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('flashcards persist and retain answer/subject', () async {
    SharedPreferences.setMockInitialValues({});
    const card = OfflineFlashcard(
      id: 'one', subject: 'Political Science',
      front: 'Which part contains fundamental rights?',
      back: 'Part III of the Indian Constitution.',
    );
    await StudyExtrasStorage.saveCards([card]);
    final loaded = await StudyExtrasStorage.loadCards();
    expect(loaded, hasLength(1));
    expect(loaded.single.back, 'Part III of the Indian Constitution.');
  });

  test('weekly planner saves day and minutes', () async {
    SharedPreferences.setMockInitialValues({});
    const session = StudyPlanItem(
      id: 'sample', subject: 'Hindi',
      task: 'Revise essay practice', weekday: 4, minutes: 945,
    );
    await StudyExtrasStorage.savePlan([session]);
    final saved = await StudyExtrasStorage.loadPlan();
    expect(saved, hasLength(1));
    expect(saved.single.weekday, 4);
    expect(saved.single.minutes, 945);
  });

  test('empty saved PDFs and invalid storage are handled', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await StudyExtrasStorage.loadPdfs(), isEmpty);
    await StudyExtrasStorage.savePdfs([
      const SavedPdf(
        id: 'a', name: 'law.pdf', path: '/temporary/local/law.pdf',
      ),
    ]);
    final loaded = await StudyExtrasStorage.loadPdfs();
    expect(loaded.single.name, 'law.pdf');
    expect(loaded.single.path, '/temporary/local/law.pdf');
  });
}
