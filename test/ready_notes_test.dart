import 'package:flutter_test/flutter_test.dart';
import 'package:studyverse/ready_notes.dart';

void main() {
  test('all 24 bundled revision lessons are in English', () {
    expect(readyStudyNotes.length, 24);
    for (final note in readyStudyNotes) {
      expect(note.title.trim(), isNotEmpty);
      expect(note.body.trim().length, greaterThan(80));
      expect(RegExp(r'[\u0900-\u097F]').hasMatch(note.title), isFalse,
        reason: 'The app is English-medium: ${note.title}');
      expect(RegExp(r'[\u0900-\u097F]').hasMatch(note.body), isFalse,
        reason: 'A bundled lesson still has Hindi content: ${note.title}');
    }
    expect(readyStudyNotes.any((e) => e.subject == 'Introduction to Law'), isTrue);
    expect(readyStudyNotes.any((e) => e.subject == 'English'), isTrue);
  });
}
