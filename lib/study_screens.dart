import 'package:flutter/material.dart';
import 'main.dart';
import 'study_data.dart';
import 'private_space.dart';

const subjectNames = ['Mathematics', 'Science', 'English', 'General Knowledge'];

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});
  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  List<StudyNote> notes = [];
  String selectedSubject = 'All';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final saved = await StudyStorage.loadNotes();
    if (mounted) setState(() => notes = saved);
  }

  Future<void> _addNote() async {
    final title = TextEditingController();
    final body = TextEditingController();
    String subject = subjectNames.first;
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
        title: 'Subjects & Notes',
        subtitle: 'Organise materials and revise easily.',
      ),
      Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [
        const StudySection('My subjects'),
        Wrap(spacing: 8, runSpacing: 7,
          children: ['All', ...subjectNames].map((subject) => ChoiceChip(
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
            'Your notes are saved on this device. PDF import and cloud sync are planned.',
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
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool started = false;
  bool finished = false;
  int index = 0;
  int score = 0;
  int? selectedAnswer;

  void _start() => setState(() {
    started = true;
    finished = false;
    index = 0;
    score = 0;
    selectedAnswer = null;
  });

  Future<void> _next() async {
    if (selectedAnswer == null) return;
    if (selectedAnswer == quizItems[index].answer) score++;
    if (index == quizItems.length - 1) {
      await StudyStorage.saveQuizScore(score);
      if (mounted) setState(() => finished = true);
    } else {
      setState(() {
        index++;
        selectedAnswer = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    const StudyHeader(title: 'Quiz Zone',
        subtitle: 'Practice  •  Test  •  Improve'),
    Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [
      if (!started) ...[
        const StudySection('Ready to practise?'),
        StudyPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.emoji_events_outlined,
                color: Color(0xFFFFA500), size: 42),
            const SizedBox(height: 12),
            const Text('Quick Knowledge Challenge',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('10 questions across maths, science, English and general knowledge.'),
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
            Text('Chapter quizzes', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Additional question banks and mock tests will be added next.',
                style: TextStyle(color: Color(0xFF73829B), fontSize: 12)),
          ],
        )),
      ] else if (finished) ...[
        const SizedBox(height: 25),
        Center(child: Icon(score >= 7 ? Icons.workspace_premium :
          Icons.auto_stories, color: studyBlue, size: 75)),
        const SizedBox(height: 12),
        Center(child: Text('$score / ${quizItems.length}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 42))),
        const Center(child: Text('Quiz completed!')),
        const SizedBox(height: 20),
        FilledButton(onPressed: _start, child: const Text('Try again')),
        TextButton(onPressed: () => setState(() {
          started = false; finished = false;
        }), child: const Text('Back to Quiz Zone')),
      ] else ...[
        Row(children: [
          Expanded(child: Text('Question ${index + 1} of ${quizItems.length}',
            style: const TextStyle(fontWeight: FontWeight.w700))),
          Text('${((index + 1) / quizItems.length * 100).round()}%',
            style: const TextStyle(color: studyBlue)),
        ]),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: (index + 1) / quizItems.length,
          minHeight: 8, borderRadius: BorderRadius.circular(20)),
        const SizedBox(height: 22),
        StudyPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quizItems[index].question,
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
                title: Text(quizItems[index].options[answer]),
                tileColor: selectedAnswer == answer
                    ? const Color(0xFFEAF2FF) : const Color(0xFFF8FAFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(width: double.infinity,
              child: FilledButton(onPressed: selectedAnswer == null ? null : _next,
                child: Text(index == quizItems.length - 1
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
    'Revise your maths notes',
    'Read one science chapter',
    'Complete 10 practice questions',
    'Write your own study note',
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
    const StudyHeader(title: 'My Progress',
      subtitle: 'Small efforts create big results.'),
    Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [
      const StudySection('Study overview'),
      Row(children: [
        Expanded(child: StudyPanel(child: Column(children: [
          const Icon(Icons.fact_check_outlined, color: studyBlue, size: 30),
          const SizedBox(height: 8),
          Text('$lastScore / 10', style: const TextStyle(
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
        title: Text('Study Preferences'),
        subtitle: Text('Learning goals and subjects'),
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
