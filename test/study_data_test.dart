import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyverse/nios_curriculum.dart';
import 'package:studyverse/study_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('practice questions cover NIOS 12 law and humanities', () {
    expect(quizItems.length, greaterThanOrEqualTo(15));
    for (final question in quizItems) {
      expect(question.options, hasLength(4));
      expect(question.answer, inInclusiveRange(0, 3));
      expect(question.question.isNotEmpty, isTrue);
      expect(question.subject.isNotEmpty, isTrue);
    }
    expect(quizItems.any((item) => item.subject == 'Introduction to Law'),
        isTrue);
    expect(quizItems.any((item) => item.subject == 'Political Science'),
        isTrue);
    expect(quizItems.any((item) => item.subject == 'Hindi'), isTrue);
  });

  test('NIOS official Law 338 chapter list is available', () {
    expect(introductionToLawChapters, hasLength(31));
    expect(niosSubjects.any((item) =>
        item.name == 'Introduction to Law' && item.code == '338'), isTrue);
  });

  test('notes can persist and reload', () async {
    SharedPreferences.setMockInitialValues({});
    const note = StudyNote(
      id: 'unit-test',
      subject: 'Political Science',
      title: 'Test note',
      body: 'Constitution study notes',
    );
    await StudyStorage.saveNotes([note]);
    final notes = await StudyStorage.loadNotes();
    expect(notes, hasLength(1));
    expect(notes.single.title, 'Test note');
    expect(notes.single.body, 'Constitution study notes');
  });

  test('selected subjects are persisted per device', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await StudyStorage.loadSelectedSubjects(), isEmpty);
    await StudyStorage.saveSelectedSubjects(
        ['English', 'Political Science', 'Introduction to Law']);
    expect(await StudyStorage.loadSelectedSubjects(), [
      'English', 'Political Science', 'Introduction to Law',
    ]);
  });

  test('quiz score persists', () async {
    SharedPreferences.setMockInitialValues({});
    await StudyStorage.saveQuizScore(8);
    expect(await StudyStorage.lastQuizScore(), 8);
  });  test('NIOS quiz results save as attempts', () async {
    SharedPreferences.setMockInitialValues({});
    await StudyStorage.saveQuizResult(
        subject: 'Introduction to Law', correct: 4, total: 5);
    await StudyStorage.saveQuizResult(
        subject: 'History', correct: 2, total: 3);
    final history = await StudyStorage.loadQuizHistory();
    expect(history, hasLength(2));
    expect(history.first['subject'], 'History');
    expect(history.first['total'], 3);
    expect(await StudyStorage.lastQuizScore(), 2);
  });


}
