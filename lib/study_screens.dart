import 'package:flutter/material.dart';
import 'main.dart';
import 'study_data.dart';
import 'private_space.dart';
import 'nios_curriculum.dart';
import 'study_extras.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

final subjectNames = niosSubjects.map((subject) => subject.name).toList();

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});
  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  List<StudyNote> notes = [];
  List<String> registeredSubjects = [];
  String selectedSubject = 'All';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final saved = await StudyStorage.loadNotes();
    final enrolled = await StudyStorage.loadSelectedSubjects();
    if (mounted) {
      setState(() {
        notes = saved;
        registeredSubjects = enrolled;
      });
    }
  }

  Future<void> _chooseSubjects() async {
    final chosen = registeredSubjects.toSet();
    final updated = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomContext) => StatefulBuilder(
        builder: (dialogContext, rebuild) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(dialogContext).height * .78,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 4, 18, 8),
                  child: Column(children: [
                    Text('Select your actual NIOS 12 subjects',
                      style: TextStyle(fontWeight: FontWeight.w800,
                        fontSize: 17)),
                    SizedBox(height: 6),
                    Text('Use your registration/admission record. These are '
                      'options, not confirmed enrolments. Select up to seven.',
                      style: TextStyle(fontSize: 12,
                        color: Color(0xFF6D7C98)),
                      textAlign: TextAlign.center),
                  ]),
                ),
                Expanded(child: ListView.builder(
                  itemCount: niosSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = niosSubjects[index];
                    return CheckboxListTile(
                      title: Text(subject.name),
                      subtitle: Text('NIOS subject code: ${subject.code}'),
                      value: chosen.contains(subject.name),
                      onChanged: (selected) {
                        rebuild(() {
                          if (selected == true) {
                            if (chosen.length < 7) chosen.add(subject.name);
                          } else {
                            chosen.remove(subject.name);
                          }
                        });
                      },
                    );
                  },
                )),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(
                          dialogContext, chosen.toList()),
                      child: const Text('Save my subjects'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (updated == null) return;
    await StudyStorage.saveSelectedSubjects(updated);
    if (mounted) {
      setState(() {
        registeredSubjects = updated;
        if (selectedSubject != 'All' &&
            !registeredSubjects.contains(selectedSubject)) {
          selectedSubject = 'All';
        }
      });
    }
  }

  void _viewLawChapters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .80,
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                Text('Introduction to Law (338)',
                  style: TextStyle(fontWeight: FontWeight.w800,
                    fontSize: 19)),
                SizedBox(height: 5),
                Text('Official NIOS chapter titles. Study material is '
                  'available from NIOS. This subject is optional.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12)),
              ]),
            ),
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(
                  text: 'https://digital.nios.ac.in/topic.php?id=338en'));
                if (sheetContext.mounted) {
                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                    const SnackBar(content: Text(
                      'NIOS official material link copied')));
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy official lesson link'),
            ),
            Expanded(child: ListView.builder(
              itemCount: introductionToLawChapters.length,
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  child: Text('${index + 1}',
                    style: const TextStyle(fontSize: 11)),
                ),
                title: Text(introductionToLawChapters[index]),
              ),
            )),
          ]),
        ),
      ),
    );
  }

  Future<void> _addNote() async {
    final title = TextEditingController();
    final body = TextEditingController();
    String subject = registeredSubjects.isNotEmpty
        ? registeredSubjects.first : 'Introduction to Law';
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, rebuild) => AlertDialog(
          title: const Text('Add study note'),
          content: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title,
                decoration: const InputDecoration(labelText: 'Note title')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: subject,
                items: subjectNames.map((name) =>
                    DropdownMenuItem(value: name, child: Text(name))).toList(),
                onChanged: (value) {
                  if (value != null) rebuild(() => subject = value);
                },
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: 12),
              TextField(controller: body, maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notes', alignLabelWithHint: true)),
            ],
          )),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
            FilledButton(onPressed: () {
              if (title.text.trim().isNotEmpty && body.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            }, child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved == true) {
      final newNotes = [
        StudyNote(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          subject: subject,
          title: title.text.trim(),
          body: body.text.trim(),
        ),
        ...notes,
      ];
      await StudyStorage.saveNotes(newNotes);
      if (mounted) setState(() => notes = newNotes);
    }
    title.dispose();
    body.dispose();
  }

  Future<void> _editNote(StudyNote note) async {
    final title = TextEditingController(text: note.title);
    final body = TextEditingController(text: note.body);
    var subject = note.subject;
    final subjects = <String>{...subjectNames, note.subject}.toList();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Edit note'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: title, maxLength: 150,
                decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: subject,
                isExpanded: true,
                items: subjects.map((item) => DropdownMenuItem(
                    value: item, child: Text(item,
                      overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (value) {
                  if (value != null) update(() => subject = value);
                },
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: 10),
              TextField(controller: body, maxLength: 10000,
                minLines: 4, maxLines: 7,
                decoration: const InputDecoration(
                    labelText: 'Study note', alignLabelWithHint: true)),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
            FilledButton(onPressed: () {
              if (title.text.trim().isNotEmpty && body.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            }, child: const Text('Save changes')),
          ],
        ),
      ),
    );
    if (saved == true) {
      final next = notes.map((item) => item.id == note.id
          ? StudyNote(id: note.id, subject: subject,
              title: title.text.trim(), body: body.text.trim())
          : item).toList();
      await StudyStorage.saveNotes(next);
      if (mounted) setState(() => notes = next);
    }
    title.dispose();
    body.dispose();
  }

  Future<void> _openOfficialMaterials() async {
    final url = Uri.parse(
        'https://rcpune.nios.ac.in/senior-secondary-courses-material.html');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      await Clipboard.setData(ClipboardData(text: url.toString()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
            'Could not open browser. The NIOS link was copied.')));
      }
    }
  }

  Future<void> _showNote(StudyNote note) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.subject, style: const TextStyle(color: studyBlue,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              SelectableText(note.body),
            ],
          )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
          TextButton(onPressed: () {
            Navigator.pop(context);
            _editNote(note);
          }, child: const Text('Edit')),
          TextButton(onPressed: () async {
            final remaining = notes.where((item) => item.id != note.id).toList();
            await StudyStorage.saveNotes(remaining);
            if (mounted) setState(() => notes = remaining);
            if (context.mounted) Navigator.pop(context);
          }, child: const Text('Delete')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = notes.where((note) =>
        selectedSubject == 'All' || note.subject == selectedSubject).toList();
    return Column(children: [
      const StudyHeader(
        title: 'NIOS Study & Notes',
        subtitle: 'Class 12 lessons • Your registered subjects',
      ),
      Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [
        const StudySection('NIOS Senior Secondary • Class 12'),
        StudyPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My registered subjects',
              style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(registeredSubjects.isEmpty
                ? 'No subjects chosen yet. Select subjects from the '
                  'actual NIOS admission record.'
                : registeredSubjects.join(' • ')),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _chooseSubjects,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit my subjects'),
            ),
          ],
        )),
        const SizedBox(height: 12),
        StudyFeatureTile(
          title: 'Introduction to Law (338)',
          description: 'Explore 31 official law chapters • Optional subject',
          icon: Icons.gavel, color: const Color(0xFFBD5684),
          onTap: _viewLawChapters,
        ),
        const StudySection('Study tools'),
        StudyFeatureTile(
          title: 'Offline PDF Reader',
          description: 'Import and read your downloaded NIOS PDFs',
          icon: Icons.picture_as_pdf_outlined,
          color: const Color(0xFFDE5263),
          onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(
              builder: (_) => const PdfLibraryScreen())),
        ),
        const SizedBox(height: 9),
        StudyFeatureTile(
          title: 'My Flashcards',
          description: 'Create, flip and revise question-answer cards',
          icon: Icons.style_outlined,
          color: const Color(0xFF7459D7),
          onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(
              builder: (_) => const FlashcardsScreen())),
        ),
        const SizedBox(height: 9),
        StudyFeatureTile(
          title: 'Weekly Study Planner',
          description: 'Set subjects, days and session times',
          icon: Icons.event_note_outlined,
          color: const Color(0xFF0A9F82),
          onTap: () => Navigator.push(context,
            MaterialPageRoute<void>(
              builder: (_) => const StudyPlannerScreen())),
        ),
        const SizedBox(height: 9),
        StudyFeatureTile(
          title: 'Official NIOS Textbooks',
          description: 'All Senior Secondary subject materials (NIOS website)',
          icon: Icons.open_in_browser,
          color: studyBlue,
          onTap: _openOfficialMaterials,
        ),
        const StudySection('Filter notes'),
        Wrap(spacing: 8, runSpacing: 7,
          children: ['All', ...registeredSubjects].map((subject) => ChoiceChip(
            label: Text(subject), selected: subject == selectedSubject,
            onSelected: (_) => setState(() => selectedSubject = subject),
          )).toList(),
        ),
        const SizedBox(height: 14),
        Row(children: [
          const Expanded(child: StudySection('Recent notes')),
          FilledButton.icon(onPressed: _addNote,
            icon: const Icon(Icons.add, size: 18), label: const Text('New note')),
        ]),
        if (visible.isEmpty)
          const StudyPanel(child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No notes in this subject yet. Tap New note to start.'),
          )),
        for (final note in visible) ...[
          StudyFeatureTile(title: note.title,
            description: note.subject,
            icon: Icons.description_outlined, color: studyBlue,
            onTap: () => _showNote(note)),
          const SizedBox(height: 9),
        ],
        const SizedBox(height: 12),
        const StudyPanel(child: Row(children: [
          Icon(Icons.offline_pin, color: Color(0xFF0CA678)),
          SizedBox(width: 10),
          Expanded(child: Text(
            'Notes, PDFs, flashcards and study plans save on this device. Cloud sync is not enabled.',
            style: TextStyle(fontSize: 12))),
        ])),
        const SizedBox(height: 22),
      ])),
    ]);
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  final ScrollController _quizScroll = ScrollController();
  bool started = false;
  bool finished = false;
  int index = 0;
  int score = 0;
  int? selectedAnswer;
  List<int?> answers = [];
  String quizSubject = 'Mixed NIOS';

  List<QuizItem> get currentQuestions {
    if (quizSubject == 'Mixed NIOS') {
      // Ten varied questions: two per subject, not an official exam paper.
      const subjects = <String>[
        'Introduction to Law',
        'Political Science',
        'History',
        'English',
        'Hindi',
      ];
      return [
        for (final subject in subjects)
          ...quizItems.where((question) => question.subject == subject).take(2),
      ];
    }
    return quizItems.where((question) =>
      question.subject == quizSubject).toList();
  }

  void _scrollToQuestionTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _quizScroll.hasClients) _quizScroll.jumpTo(0);
    });
  }

  @override
  void dispose() {
    _quizScroll.dispose();
    super.dispose();
  }

  bool handleBack() {
    if (!started) return false;
    if (finished) {
      setState(() {
        finished = false;
        started = false;
      });
      _scrollToQuestionTop();
      return true;
    }
    if (index > 0) {
      setState(() {
        index--;
        selectedAnswer = answers[index];
      });
      _scrollToQuestionTop();
      return true;
    }
    setState(() => started = false);
    _scrollToQuestionTop();
    return true;
  }

  void _start() {
    setState(() {
      started = true;
      finished = false;
      index = 0;
      score = 0;
      selectedAnswer = null;
      answers = List<int?>.filled(currentQuestions.length, null);
    });
    _scrollToQuestionTop();
  }

  Future<void> _next() async {
    if (selectedAnswer == null) return;
    answers[index] = selectedAnswer;
    if (index == currentQuestions.length - 1) {
      final questions = currentQuestions;
      final totalCorrect = [
        for (var i = 0; i < questions.length; i++)
          if (answers[i] == questions[i].answer) i,
      ].length;
      await StudyStorage.saveQuizResult(
        subject: quizSubject,
        correct: totalCorrect,
        total: questions.length,
      );
      if (mounted) {
        setState(() {
          score = totalCorrect;
          finished = true;
        });
        _scrollToQuestionTop();
      }
    } else {
      setState(() {
        index++;
        selectedAnswer = answers[index];
      });
      _scrollToQuestionTop();
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    const StudyHeader(title: 'NIOS Practice Quiz',
        subtitle: 'Class 12 • Law, humanities and languages'),
    Expanded(child: ListView(controller: _quizScroll,
      padding: const EdgeInsets.all(18), children: [
      if (!started) ...[
        const StudySection('Choose a subject'),
        Wrap(
          spacing: 7, runSpacing: 5,
          children: <String>[
            'Mixed NIOS',
            ...quizItems.map((question) => question.subject).toSet(),
          ].map((subject) => ChoiceChip(
            label: Text(subject),
            selected: subject == quizSubject,
            onSelected: (_) => setState(() => quizSubject = subject),
          )).toList(),
        ),
        const SizedBox(height: 12),
        StudyPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.emoji_events_outlined,
                color: Color(0xFFFFA500), size: 42),
            const SizedBox(height: 12),
            const Text('NIOS Revision Challenge',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Original practice questions, not official NIOS past papers.'),
            const SizedBox(height: 12),
            Text('${currentQuestions.length} practice questions • $quizSubject',
              style: const TextStyle(color: studyBlue)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: FilledButton.icon(onPressed: _start,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Quick Quiz'))),
          ],
        )),
        const StudySection('Your practice tools'),
        const StudyPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NIOS subject quizzes', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('More NIOS curriculum-mapped practice and mock tests are planned.',
                style: TextStyle(color: Color(0xFF73829B), fontSize: 12)),
          ],
        )),
      ] else if (finished) ...[
        const SizedBox(height: 25),
        Center(child: Icon(score >= (currentQuestions.length * .7) ? Icons.workspace_premium :
          Icons.auto_stories, color: studyBlue, size: 75)),
        const SizedBox(height: 12),
        Center(child: Text('$score / ${currentQuestions.length}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 42))),
        const Center(child: Text('Quiz completed!')),
        const SizedBox(height: 18),
        const StudySection('Review your answers'),
        for (var questionIndex = 0;
            questionIndex < currentQuestions.length;
            questionIndex++) ...[
          StudyPanel(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(
                  answers[questionIndex] ==
                      currentQuestions[questionIndex].answer
                      ? Icons.check_circle : Icons.cancel,
                  color: answers[questionIndex] ==
                      currentQuestions[questionIndex].answer
                      ? const Color(0xFF159E74) : Colors.redAccent,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(currentQuestions[questionIndex].question,
                  style: const TextStyle(fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 8),
              Text("Your answer: ${answers[questionIndex] == null ? 'Not answered' : currentQuestions[questionIndex].options[answers[questionIndex]!]}"),
              const SizedBox(height: 5),
              Text('Correct answer: ${currentQuestions[questionIndex].options[currentQuestions[questionIndex].answer]}',
                style: const TextStyle(color: Color(0xFF12966F))),
              const SizedBox(height: 5),
              Text(currentQuestions[questionIndex].explanation),
            ],
          )),
          const SizedBox(height: 9),
        ],
        const SizedBox(height: 20),
        FilledButton(onPressed: _start, child: const Text('Try again')),
        TextButton(onPressed: () => setState(() {
          started = false; finished = false;
        }), child: const Text('Back to Quiz Zone')),
      ] else ...[
        Row(children: [
          Expanded(child: Text('Question ${index + 1} of ${currentQuestions.length}',
            style: const TextStyle(fontWeight: FontWeight.w700))),
          Text('${((index + 1) / currentQuestions.length * 100).round()}%',
            style: const TextStyle(color: studyBlue)),
        ]),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: (index + 1) / currentQuestions.length,
          minHeight: 8, borderRadius: BorderRadius.circular(20)),
        const SizedBox(height: 22),
        StudyPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentQuestions[index].question,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            for (var answer = 0; answer < 4; answer++) ...[
              ListTile(
                onTap: () => setState(() => selectedAnswer = answer),
                leading: Icon(
                  selectedAnswer == answer
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: studyBlue,
                ),
                title: Text(currentQuestions[index].options[answer]),
                tileColor: selectedAnswer == answer
                    ? const Color(0xFFEAF2FF) : const Color(0xFFF8FAFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(width: double.infinity,
              child: FilledButton(onPressed: selectedAnswer == null ? null : _next,
                child: Text(index == currentQuestions.length - 1
                    ? 'Finish Quiz' : 'Next Question'))),
          ],
        )),
      ],
    ])),
  ]);
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int lastScore = 0;
  Set<int> done = {};
  static const tasks = [
    'Review an enrolled NIOS subject',
    'Revise one chapter from the NIOS material',
    'Complete a subject practice quiz',
    'Write or review your own study notes',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final score = await StudyStorage.lastQuizScore();
    final completed = await StudyStorage.completedTasks();
    if (mounted) setState(() { lastScore = score; done = completed; });
  }

  Future<void> _toggle(int index, bool? checked) async {
    setState(() {
      if (checked == true) { done.add(index); } else { done.remove(index); }
    });
    await StudyStorage.saveCompletedTasks(done);
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    const StudyHeader(title: 'NIOS Progress',
      subtitle: 'Small efforts create big results.'),
    Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [
      const StudySection('Study overview'),
      Row(children: [
        Expanded(child: StudyPanel(child: Column(children: [
          const Icon(Icons.fact_check_outlined, color: studyBlue, size: 30),
          const SizedBox(height: 8),
          Text('$lastScore correct', style: const TextStyle(
            fontSize: 23, fontWeight: FontWeight.w900)),
          const Text('Last quiz', style: TextStyle(fontSize: 12)),
        ]))),
        const SizedBox(width: 10),
        Expanded(child: StudyPanel(child: Column(children: [
          const Icon(Icons.task_alt, color: Color(0xFF0CA678), size: 30),
          const SizedBox(height: 8),
          Text('${done.length} / ${tasks.length}', style: const TextStyle(
            fontSize: 23, fontWeight: FontWeight.w900)),
          const Text('Tasks complete', style: TextStyle(fontSize: 12)),
        ]))),
      ]),
      const StudySection('Recent NIOS quiz attempts'),
      FutureBuilder<List<Map<String, dynamic>>>(
        future: StudyStorage.loadQuizHistory(),
        builder: (context, snapshot) {
          final attempts = snapshot.data ?? [];
          if (attempts.isEmpty) {
            return const StudyPanel(
              child: Text('Complete a quiz to see your study history here.'));
          }
          return StudyPanel(child: Column(
            children: [
              for (final attempt in attempts.take(6))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.assignment_turned_in_outlined,
                    color: studyBlue),
                  title: Text(attempt['subject'] as String? ?? 'NIOS quiz'),
                  subtitle: Text((attempt['at'] as String? ?? '').split('T').first),
                  trailing: Text(
                    '${attempt['correct'] ?? 0} / ${attempt['total'] ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
            ],
          ));
        },
      ),
      const StudySection('Today\'s study goals'),
      StudyPanel(child: Column(children: [
        for (int i = 0; i < tasks.length; i++)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: done.contains(i),
            onChanged: (value) => _toggle(i, value),
            title: Text(tasks[i],
              style: TextStyle(
                decoration: done.contains(i) ? TextDecoration.lineThrough : null,
              )),
          ),
      ])),
      const SizedBox(height: 16),
      StudyPanel(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Goal completion',
            style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: done.length / tasks.length,
            minHeight: 10, borderRadius: BorderRadius.circular(30)),
          const SizedBox(height: 7),
          Text('${(100 * done.length / tasks.length).round()}% of today\'s goals',
            style: const TextStyle(color: Color(0xFF7786A1), fontSize: 12)),
        ],
      )),
    ])),
  ]);
}

class SettingsScreen extends StatelessWidget {
  final bool onlineConfigured;
  final VoidCallback quickExit;
  const SettingsScreen({super.key, required this.onlineConfigured,
    required this.quickExit});

  @override
  Widget build(BuildContext context) => Column(children: [
    const StudyHeader(title: 'Settings',
      subtitle: 'Manage your learning preferences.'),
    Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [
      const StudySection('Personalisation'),
      const StudyPanel(child: ListTile(
        leading: Icon(Icons.school_outlined, color: studyBlue),
        title: Text('NIOS Study Preferences'),
        subtitle: Text('Class 12 • Choose subjects in Study tab'),
      )),
      const SizedBox(height: 12),
      const StudyPanel(child: ListTile(
        leading: Icon(Icons.notifications_off_outlined, color: studyBlue),
        title: Text('Notifications'),
        subtitle: Text('No chat notifications are sent by this app'),
      )),
      const StudySection('Privacy & advanced'),
      StudyFeatureTile(
        title: 'Resource Vault', description: 'Protected personal space',
        icon: Icons.inventory_2_outlined, color: const Color(0xFF7659D7),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => VaultScreen(
            onlineConfigured: onlineConfigured, onQuickExit: quickExit))),
      ),
      const SizedBox(height: 12),
      const StudyPanel(child: ListTile(
        leading: Icon(Icons.security_outlined, color: Color(0xFF0CA678)),
        title: Text('Security'),
        subtitle: Text('Vault requires a separate six-digit PIN'),
      )),
      const StudySection('About'),
      const StudyPanel(child: ListTile(
        leading: Icon(Icons.info_outline, color: studyBlue),
        title: Text('StudyVerse'),
        subtitle: Text('Version 0.1.0 • Android preview'),
      )),
      const SizedBox(height: 16),
      if (!onlineConfigured)
        const Text('Live messaging is not configured yet. The study tools work offline.',
          style: TextStyle(fontSize: 12, color: Color(0xFF7786A1))),
    ])),
  ]);
}
