import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StudyNote {
  final String id;
  final String subject;
  final String title;
  final String body;

  const StudyNote({
    required this.id,
    required this.subject,
    required this.title,
    required this.body,
  });

  Map<String, String> toJson() =>
      {'id': id, 'subject': subject, 'title': title, 'body': body};

  factory StudyNote.fromJson(Map<String, dynamic> json) => StudyNote(
        id: json['id'] as String? ?? '',
        subject: json['subject'] as String? ?? 'General',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );
}

class StudyStorage {
  static const _notesKey = 'studyverse_notes_v1';
  static const _quizKey = 'studyverse_last_quiz_score';
  static const _tasksKey = 'studyverse_tasks_v1';

  static Future<List<StudyNote>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesKey);
    if (raw == null) {
      return [
        const StudyNote(
          id: 'sample1',
          subject: 'Mathematics',
          title: 'Algebra Revision',
          body: 'Quadratic equation: ax² + bx + c = 0.\n'
              'Discriminant: b² - 4ac.\n'
              'Practice factorisation and completing the square.',
        ),
        const StudyNote(
          id: 'sample2',
          subject: 'Science',
          title: 'Cell Structure',
          body: 'Nucleus stores genetic information.\n'
              'Mitochondria release energy.\n'
              'Cell membrane controls passage of substances.',
        ),
      ];
    }
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((value) => StudyNote.fromJson(
              Map<String, dynamic>.from(value as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveNotes(List<StudyNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notesKey,
      jsonEncode(notes.map((note) => note.toJson()).toList()),
    );
  }

  static Future<int> lastQuizScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_quizKey) ?? 0;
  }

  static Future<void> saveQuizScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_quizKey, score);
  }

  static Future<Set<int>> completedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_tasksKey) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  static Future<void> saveCompletedTasks(Set<int> completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _tasksKey, completed.map((value) => value.toString()).toList());
  }
}

class QuizItem {
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;
  const QuizItem(this.question, this.options, this.answer, this.explanation);
}

const quizItems = <QuizItem>[
  QuizItem(
    'Which organelle is called the powerhouse of the cell?',
    ['Nucleus', 'Mitochondrion', 'Ribosome', 'Chloroplast'],
    1,
    'Mitochondria produce most of the ATP used by cells.',
  ),
  QuizItem(
    'What is 12 × 8?',
    ['86', '92', '96', '108'],
    2,
    '12 multiplied by 8 equals 96.',
  ),
  QuizItem(
    'Which is the chemical symbol for water?',
    ['O₂', 'CO₂', 'H₂O', 'NaCl'],
    2,
    'Water contains two hydrogen atoms and one oxygen atom.',
  ),
  QuizItem(
    'Which planet is known as the Red Planet?',
    ['Mercury', 'Venus', 'Mars', 'Jupiter'],
    2,
    'Mars looks reddish due to iron oxides on its surface.',
  ),
  QuizItem(
    'What is the square root of 144?',
    ['10', '11', '12', '14'],
    2,
    '12 × 12 = 144.',
  ),
  QuizItem(
    'Which part of speech describes a noun?',
    ['Adjective', 'Verb', 'Adverb', 'Preposition'],
    0,
    'An adjective modifies or describes a noun.',
  ),
  QuizItem(
    'How many degrees are in a right angle?',
    ['45', '60', '90', '180'],
    2,
    'A right angle measures 90 degrees.',
  ),
  QuizItem(
    'Which gas do plants take in during photosynthesis?',
    ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Hydrogen'],
    1,
    'Plants use carbon dioxide and water to make sugars.',
  ),
  QuizItem(
    'What is the largest ocean on Earth?',
    ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
    3,
    'The Pacific Ocean is Earth\'s largest ocean.',
  ),
  QuizItem(
    'What is 15% of 200?',
    ['15', '20', '30', '35'],
    2,
    '10% is 20 and 5% is 10, so 15% is 30.',
  ),
];
