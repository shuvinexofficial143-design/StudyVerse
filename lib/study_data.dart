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
  static const _tasksKey = 'studyverse_nios12_tasks_v2';
  static const _subjectsKey = 'studyverse_nios12_selected_subjects_v1';

  static Future<List<StudyNote>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesKey);
    if (raw == null) {
      return [
        const StudyNote(
          id: 'sample1',
          subject: 'Political Science',
          title: 'Constitution Revision',
          body: 'Read the Preamble and its core ideals.\n'
              'Review the separation of powers and key institutions.',
        ),
        const StudyNote(
          id: 'sample2',
          subject: 'Introduction to Law',
          title: 'Law Foundation — Sample Notes',
          body: 'Explore natural justice, the Indian judicial system,\n'
              'Fundamental Rights and Lok Adalat.\n'
              'Law (338) is optional: check your registered subject list.',
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

  static Future<List<String>> loadSelectedSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_subjectsKey) ?? <String>[];
  }

  static Future<void> saveSelectedSubjects(List<String> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_subjectsKey, subjects);
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
  final String subject;
  const QuizItem(
    this.question,
    this.options,
    this.answer,
    this.explanation, {
    required this.subject,
  });
}

/// Original practice questions for a NIOS Senior Secondary learner.
/// These are not past NIOS papers, official exam questions or a complete bank.
const quizItems = <QuizItem>[
  QuizItem(
    'Which part of the Indian Constitution contains Fundamental Rights?',
    ['Part I', 'Part III', 'Part IV', 'Part IX'],
    1,
    'Fundamental Rights are set out in Part III of the Constitution.',
    subject: 'Introduction to Law',
  ),
  QuizItem(
    'The principle "hear the other side" is related to which idea?',
    ['Natural justice', 'Absolute monarchy', 'Ex post facto law', 'Diplomacy'],
    0,
    'Audi alteram partem is an important principle of natural justice.',
    subject: 'Introduction to Law',
  ),
  QuizItem(
    'Which forum helps parties settle certain disputes through compromise?',
    ['Election Commission', 'Lok Adalat', 'Central Bank', 'Planning Commission'],
    1,
    'Lok Adalat is an alternative dispute resolution forum.',
    subject: 'Introduction to Law',
  ),
  QuizItem(
    'Which of these usually concerns a private property dispute?',
    ['Civil law', 'Criminal law', 'International space law', 'Military law'],
    0,
    'Private property disputes generally fall under civil law.',
    subject: 'Introduction to Law',
  ),
  QuizItem(
    'Directive Principles of State Policy appear in which Part?',
    ['Part II', 'Part III', 'Part IV', 'Part V'],
    2,
    'Directive Principles of State Policy are found in Part IV.',
    subject: 'Introduction to Law',
  ),
  QuizItem(
    'What is the highest court in the Indian judicial hierarchy?',
    ['District Court', 'High Court', 'Supreme Court', 'Lok Adalat'],
    2,
    'The Supreme Court of India sits at the apex of the court hierarchy.',
    subject: 'Introduction to Law',
  ),
  QuizItem(
    'Which constitutional organ primarily enacts legislation?',
    ['Legislature', 'Judiciary', 'Election staff', 'Police'],
    0,
    'Legislatures enact laws within their constitutional powers.',
    subject: 'Political Science',
  ),
  QuizItem(
    'What does universal adult franchise refer to?',
    ['Voting restricted to officials', 'Adult citizens voting subject to law',
     'Only taxpayers voting', 'Only graduates voting'],
    1,
    'Adult citizens meeting the legal requirements have the right to vote.',
    subject: 'Political Science',
  ),
  QuizItem(
    'Which body conducts elections to Parliament in India?',
    ['Reserve Bank', 'Election Commission of India', 'Supreme Court Registry',
     'NITI Aayog'],
    1,
    'The Election Commission of India administers Parliamentary elections.',
    subject: 'Political Science',
  ),
  QuizItem(
    'When did India become a republic?',
    ['15 August 1947', '26 January 1950', '2 October 1952',
     '26 November 1949'],
    1,
    'The Constitution came into force on 26 January 1950.',
    subject: 'History',
  ),
  QuizItem(
    'In which year was the Quit India Movement launched?',
    ['1919', '1930', '1942', '1950'],
    2,
    'The Quit India Movement began in August 1942.',
    subject: 'History',
  ),
  QuizItem(
    'The Indian National Congress was founded in which year?',
    ['1857', '1885', '1905', '1947'],
    1,
    'The Indian National Congress was founded in 1885.',
    subject: 'History',
  ),
  QuizItem(
    'Choose the grammatically correct sentence.',
    ['She go to school.', 'She goes to school.',
     'She going to school.', 'She gone to school.'],
    1,
    'The third-person singular subject she takes goes in the present simple.',
    subject: 'English',
  ),
  QuizItem(
    'Which word is a synonym of "assist"?',
    ['Help', 'Ignore', 'Refuse', 'Delay'],
    0,
    'Assist means to help someone.',
    subject: 'English',
  ),
  QuizItem(
    'Which sentence is in the past tense?',
    ['They study.', 'They will study.',
     'They studied.', 'They are studying.'],
    2,
    'Studied is the past form of study.',
    subject: 'English',
  ),
  QuizItem(
    'इनमें से कौन-सा शब्द संज्ञा है?',
    ['सुंदर', 'विद्यालय', 'धीरे', 'जल्दी'],
    1,
    'विद्यालय किसी स्थान का नाम है, इसलिए यह संज्ञा है।',
    subject: 'Hindi',
  ),
  QuizItem(
    '“दिन” का विलोम क्या है?',
    ['प्रकाश', 'रात', 'सुबह', 'समय'],
    1,
    'दिन का विलोम रात है।',
    subject: 'Hindi',
  ),
  QuizItem(
    '“मैं पढ़ रहा हूँ” किस काल का उदाहरण है?',
    ['भूतकाल', 'भविष्यत्काल', 'वर्तमान काल', 'इनमें से कोई नहीं'],
    2,
    'यह वाक्य वर्तमान में जारी क्रिया बताता है।',
    subject: 'Hindi',
  ),
  QuizItem(
    'The study of human society and social relationships is called:',
    ['Sociology', 'Astronomy', 'Geology', 'Botany'],
    0,
    'Sociology studies society, social groups and relationships.',
    subject: 'Sociology',
  ),
  QuizItem(
    'Which is an example of a social institution?',
    ['Family', 'Mountain', 'River', 'Mineral'],
    0,
    'Family is a social institution organised around social relationships.',
    subject: 'Sociology',
  ),
];
