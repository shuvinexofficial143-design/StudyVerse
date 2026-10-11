import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyverse/study_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('quiz has ten valid questions', () {
    expect(quizItems, hasLength(10));
    for (final question in quizItems) {
      expect(question.options, hasLength(4));
      expect(question.answer, inInclusiveRange(0, 3));
      expect(question.question.isNotEmpty, isTrue);
    }
  });

  test('notes can persist and reload', () async {
    SharedPreferences.setMockInitialValues({});
    const note = StudyNote(
      id: 'unit-test',
      subject: 'Science',
      title: 'Test note',
      body: 'Content',
    );
    await StudyStorage.saveNotes([note]);
    final notes = await StudyStorage.loadNotes();
    expect(notes, hasLength(1));
    expect(notes.single.title, 'Test note');
    expect(notes.single.body, 'Content');
  });

  test('quiz score persists', () async {
    SharedPreferences.setMockInitialValues({});
    await StudyStorage.saveQuizScore(8);
    expect(await StudyStorage.lastQuizScore(), 8);
  });
}
