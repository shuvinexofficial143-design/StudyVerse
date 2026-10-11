import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';
import 'nios_curriculum.dart';

/// Learning materials stay offline on THIS device.
/// This module does not upload PDFs, flashcards, or plans to the chat backend.
class OfflineFlashcard {
  final String id;
  final String subject;
  final String front;
  final String back;

  const OfflineFlashcard({
    required this.id,
    required this.subject,
    required this.front,
    required this.back,
  });

  Map<String, String> toJson() => {
        'id': id, 'subject': subject, 'front': front, 'back': back,
      };

  factory OfflineFlashcard.fromJson(Map<String, dynamic> json) =>
      OfflineFlashcard(
        id: json['id'] as String? ?? '',
        subject: json['subject'] as String? ?? 'General',
        front: json['front'] as String? ?? '',
        back: json['back'] as String? ?? '',
      );
}

class StudyPlanItem {
  final String id;
  final String subject;
  final String task;
  final int weekday;
  final int minutes;

  const StudyPlanItem({
    required this.id,
    required this.subject,
    required this.task,
    required this.weekday,
    required this.minutes,
  });

  Map<String, dynamic> toJson() => {
        'id': id, 'subject': subject, 'task': task,
        'weekday': weekday, 'minutes': minutes,
      };

  factory StudyPlanItem.fromJson(Map<String, dynamic> json) => StudyPlanItem(
        id: json['id'] as String? ?? '',
        subject: json['subject'] as String? ?? 'General',
        task: json['task'] as String? ?? '',
        weekday: (json['weekday'] as num?)?.toInt() ?? 1,
        minutes: (json['minutes'] as num?)?.toInt() ?? 540,
      );
}

class SavedPdf {
  final String id;
  final String name;
  final String path;
  const SavedPdf({required this.id, required this.name, required this.path});
  Map<String, String> toJson() => {'id': id, 'name': name, 'path': path};
  factory SavedPdf.fromJson(Map<String, dynamic> json) => SavedPdf(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Document',
        path: json['path'] as String? ?? '',
      );
}

class StudyExtrasStorage {
  static const _cards = 'studyverse_flashcards_v1';
  static const _planner = 'studyverse_weekly_planner_v1';
  static const _pdfs = 'studyverse_offline_pdf_paths_v1';

  static Future<List<OfflineFlashcard>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cards);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((entry) =>
              OfflineFlashcard.fromJson(Map<String, dynamic>.from(entry as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCards(List<OfflineFlashcard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _cards, jsonEncode(cards.map((item) => item.toJson()).toList()));
  }

  static Future<List<StudyPlanItem>> loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_planner);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((entry) =>
              StudyPlanItem.fromJson(Map<String, dynamic>.from(entry as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePlan(List<StudyPlanItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _planner, jsonEncode(items.map((item) => item.toJson()).toList()));
  }

  static Future<List<SavedPdf>> loadPdfs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pdfs);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((entry) => SavedPdf.fromJson(
              Map<String, dynamic>.from(entry as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePdfs(List<SavedPdf> pdfs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _pdfs, jsonEncode(pdfs.map((item) => item.toJson()).toList()));
  }
}

const weekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday',
  'Friday', 'Saturday', 'Sunday',
];

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});
  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  List<OfflineFlashcard> cards = [];
  String? showingAnswerId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await StudyExtrasStorage.loadCards();
    if (mounted) setState(() => cards = result);
  }

  Future<void> _addCard() async {
    final front = TextEditingController();
    final back = TextEditingController();
    var subject = niosSubjects.first.name;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('New flashcard'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: subject,
                decoration: const InputDecoration(labelText: 'Subject'),
                isExpanded: true,
                items: niosSubjects.map((item) =>
                  DropdownMenuItem(value: item.name,
                    child: Text(item.name, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) update(() => subject = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: front,
                maxLength: 300,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Question / term'),
              ),
              TextField(
                controller: back,
                maxLength: 1000,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Answer / meaning'),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
            FilledButton(onPressed: () {
              if (front.text.trim().isNotEmpty && back.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            }, child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved == true) {
      final next = [
        OfflineFlashcard(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          subject: subject,
          front: front.text.trim(),
          back: back.text.trim(),
        ),
        ...cards,
      ];
      await StudyExtrasStorage.saveCards(next);
      if (mounted) setState(() => cards = next);
    }
    // Text-field controllers are owned by this dialog and disposed after pop.
    front.dispose();
    back.dispose();
  }

  Future<void> _deleteCard(OfflineFlashcard card) async {
    final next = cards.where((entry) => entry.id != card.id).toList();
    await StudyExtrasStorage.saveCards(next);
    if (mounted) setState(() => cards = next);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Flashcards')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addCard,
      icon: const Icon(Icons.add),
      label: const Text('New card')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const StudyPanel(child: Text(
        'Make revision cards from your real NIOS subjects. '
        'Tap a question to reveal its answer. Cards are saved offline.')),
      const SizedBox(height: 16),
      if (cards.isEmpty)
        const StudyPanel(child: Center(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Text('No flashcards yet. Create your first one.'),
          ),
        )),
      for (final card in cards) ...[
        StudyPanel(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.subject, style: const TextStyle(
              fontSize: 12, color: studyBlue)),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () => setState(() => showingAnswerId =
                showingAnswerId == card.id ? null : card.id),
              title: Text(card.front, style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(showingAnswerId == card.id
                    ? card.back : 'Tap to reveal answer'),
              ),
              trailing: Icon(showingAnswerId == card.id
                  ? Icons.visibility : Icons.visibility_outlined),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _deleteCard(card),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete')),
            ),
          ],
        )),
        const SizedBox(height: 10),
      ],
      const SizedBox(height: 75),
    ]),
  );
}

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});
  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  List<StudyPlanItem> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await StudyExtrasStorage.loadPlan();
    if (mounted) setState(() => items = result);
  }

  Future<void> _add() async {
    final task = TextEditingController();
    var subject = niosSubjects.first.name;
    var weekday = DateTime.now().weekday;
    var time = const TimeOfDay(hour: 17, minute: 0);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Schedule study session'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: task,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'Task (e.g. Revise chapter 2)')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: subject,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: niosSubjects.map((item) =>
                    DropdownMenuItem(value: item.name,
                      child: Text(item.name,
                        overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (value) {
                  if (value != null) update(() => subject = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: weekday,
                decoration: const InputDecoration(labelText: 'Day'),
                items: [
                  for (var day = 1; day <= 7; day++)
                    DropdownMenuItem(value: day,
                      child: Text(weekdays[day - 1])),
                ],
                onChanged: (value) {
                  if (value != null) update(() => weekday = value);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.schedule),
                label: Text('Time: ${time.format(dialogContext)}'),
                onPressed: () async {
                  final chosen = await showTimePicker(
                    context: dialogContext, initialTime: time);
                  if (chosen != null) update(() => time = chosen);
                },
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
            FilledButton(onPressed: () {
              if (task.text.trim().isNotEmpty) Navigator.pop(context, true);
            }, child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved == true) {
      final next = [
        ...items,
        StudyPlanItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          subject: subject, task: task.text.trim(),
          weekday: weekday, minutes: time.hour * 60 + time.minute,
        ),
      ];
      await StudyExtrasStorage.savePlan(next);
      if (mounted) setState(() => items = next);
    }
    task.dispose();
  }

  Future<void> _delete(StudyPlanItem item) async {
    final next = items.where((x) => x.id != item.id).toList();
    await StudyExtrasStorage.savePlan(next);
    if (mounted) setState(() => items = next);
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort((a, b) {
      final day = a.weekday.compareTo(b.weekday);
      return day != 0 ? day : a.minutes.compareTo(b.minutes);
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Study Planner')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        label: const Text('Add session'),
        icon: const Icon(Icons.add)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const StudyPanel(child: Text(
          'Plan the week around your NIOS Senior Secondary subjects. '
          'This timetable is saved offline; it does not send notifications.')),
        const SizedBox(height: 14),
        if (sorted.isEmpty) const StudyPanel(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Text('Nothing scheduled. Add a study session.'),
          ),
        ),
        for (var day = 1; day <= 7; day++)
          if (sorted.any((item) => item.weekday == day)) ...[
            StudySection(weekdays[day - 1]),
            for (final item in sorted.where((item) => item.weekday == day)) ...[
              StudyPanel(child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_note, color: studyBlue),
                title: Text(item.task),
                subtitle: Text(
                  '${item.subject}  •  ${TimeOfDay(hour: item.minutes ~/ 60, minute: item.minutes % 60).format(context)}',
                ),
                trailing: IconButton(
                  tooltip: 'Remove planned session',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(item)),
              )),
              const SizedBox(height: 9),
            ],
          ],
        const SizedBox(height: 75),
      ]),
    );
  }
}

/// Official NIOS-hosted chapter PDFs are downloaded only when selected.
/// We do not redistribute textbook files in the application package.
const _niosPdfChapters = <(String, String)>[
  ('Law 338 — Lesson 1: Meaning of Law',
   'https://digital.nios.ac.in/content/338en/338_Introduction_To_Law_Eng_L1.pdf'),
  ('Law 338 — Lesson 2: Classification of Legal System',
   'https://digital.nios.ac.in/content/338en/338_Introduction_To_Law_Eng_L2.pdf'),
  ('Law 338 — Lesson 5: Law and Social Control',
   'https://digital.nios.ac.in/content/338en/338_Introduction_To_Law_Eng_L5.pdf'),
  ('Law 338 — Lesson 6: Natural Justice',
   'https://digital.nios.ac.in/content/338en/338_Introduction_To_Law_Eng_L6.pdf'),
  ('Law 338 — Lesson 13: Indian Judicial System',
   'https://digital.nios.ac.in/content/338en/338_Introduction_To_Law_Eng_L13.pdf'),
  ('Law 338 — Lesson 18: Constitutionalism and Preamble',
   'https://digital.nios.ac.in/content/338en/338_Introduction_To_Law_Eng_L18.pdf'),
];

class PdfLibraryScreen extends StatefulWidget {
  const PdfLibraryScreen({super.key});
  @override
  State<PdfLibraryScreen> createState() => _PdfLibraryScreenState();
}

class _PdfLibraryScreenState extends State<PdfLibraryScreen> {
  List<SavedPdf> pdfs = [];
  bool importing = false;
  String? downloadingPdf;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await StudyExtrasStorage.loadPdfs();
    if (mounted) setState(() => pdfs = loaded);
  }

  Future<void> _downloadOfficialPdf(String title, String link) async {
    if (importing || downloadingPdf != null) return;
    final uri = Uri.parse(link);
    if (uri.scheme != 'https' || uri.host != 'digital.nios.ac.in') {
      return;
    }
    setState(() => downloadingPdf = link);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.getUrl(uri).timeout(
        const Duration(seconds: 20));
      final response = await request.close().timeout(
        const Duration(seconds: 25));
      if (response.statusCode != HttpStatus.ok) {
        throw const FormatException('NIOS PDF अभी डाउनलोड नहीं हुई।');
      }
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response.timeout(const Duration(seconds: 45))) {
        if (builder.length + chunk.length > 25 * 1024 * 1024) {
          throw const FormatException('यह PDF 25 MB से बड़ी है।');
        }
        builder.add(chunk);
      }
      final bytes = builder.takeBytes();
      if (bytes.length < 4 || bytes[0] != 37 || bytes[1] != 80 ||
          bytes[2] != 68 || bytes[3] != 70) {
        throw const FormatException('NIOS से सही PDF नहीं मिली।');
      }
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/studyverse_pdfs');
      await folder.create(recursive: true);
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final output = File('${folder.path}/$id.pdf');
      await output.writeAsBytes(bytes, flush: true);
      final next = [
        SavedPdf(id: id, name: title, path: output.path), ...pdfs,
      ];
      await StudyExtrasStorage.savePdfs(next);
      if (mounted) {
        setState(() => pdfs = next);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('PDF सेव हो गई। अब बिना इंटरनेट पढ़ सकते हैं।')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
          'डाउनलोड नहीं हुआ। इंटरनेट चेक करें या NIOS साइट से PDF खोलें।')));
    } finally {
      client.close(force: true);
      if (mounted) setState(() => downloadingPdf = null);
    }
  }

  Future<void> _browseAllNiosMaterials() async {
    final uri = Uri.parse(
      'https://rcpune.nios.ac.in/senior-secondary-courses-material.html');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('NIOS वेबसाइट नहीं खुली। इंटरनेट देखें।')));
    }
  }

  Future<void> _importPdf() async {
    if (importing) return;
    setState(() => importing = true);
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (picked == null) return;
      final reportedLength = picked.lengthSync();
      if (reportedLength != null && reportedLength > 25 * 1024 * 1024) {
        throw const FormatException('Choose a PDF smaller than 25 MB.');
      }
      final bytes = await picked.readAsBytes();
      if (bytes.length < 4 || bytes.length > 25 * 1024 * 1024) {
        throw const FormatException('Choose a PDF smaller than 25 MB.');
      }
      if (bytes[0] != 37 || bytes[1] != 80 ||
          bytes[2] != 68 || bytes[3] != 70) {
        throw const FormatException('The selected file is not a valid PDF.');
      }
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/studyverse_pdfs');
      await folder.create(recursive: true);
      final path = '${folder.path}/$id.pdf';
      await File(path).writeAsBytes(bytes, flush: true);
      final updated = [
        SavedPdf(id: id, name: picked.name, path: path), ...pdfs,
      ];
      await StudyExtrasStorage.savePdfs(updated);
      if (mounted) setState(() => pdfs = updated);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error is FormatException
              ? error.message : 'Could not import PDF. Try again.')));
      }
    } finally {
      if (mounted) setState(() => importing = false);
    }
  }

  Future<void> _deletePdf(SavedPdf pdf) async {
    final next = pdfs.where((item) => item.id != pdf.id).toList();
    await StudyExtrasStorage.savePdfs(next);
    final file = File(pdf.path);
    if (await file.exists()) await file.delete();
    if (mounted) setState(() => pdfs = next);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Offline PDF Library')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: importing ? null : _importPdf,
      icon: Icon(importing ? Icons.hourglass_top : Icons.add),
      label: Text(importing ? 'Importing…' : 'Import PDF')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const StudyPanel(child: Text(
        'Import downloaded NIOS textbooks or your own PDF files. '
        'They stay on this device and work without internet. '
        'Only add documents you are permitted to use.')),
      const SizedBox(height: 15),
      const StudySection('NIOS Official PDF Lessons'),
      const Text(
        'ये असली NIOS साइट के PDF हैं। Download दबाने पर फोन में ऑफलाइन '
        'सेव होंगे; पहली बार इंटरनेट चाहिए। सभी विषयों की किताबों के लिए '
        'नीचे NIOS वेबसाइट खोलें।',
        style: TextStyle(color: Color(0xFF66728B), fontSize: 12),
      ),
      const SizedBox(height: 10),
      for (final (title, url) in _niosPdfChapters)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: StudyPanel(padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
              title: Text(title, style: const TextStyle(fontSize: 13)),
              trailing: IconButton(
                tooltip: 'Download official PDF',
                icon: downloadingPdf == url
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download),
                onPressed: downloadingPdf == null && !importing
                    ? () => _downloadOfficialPdf(title, url) : null,
              ),
            ),
          ),
        ),
      OutlinedButton.icon(
        onPressed: _browseAllNiosMaterials,
        icon: const Icon(Icons.public),
        label: const Text('All Subject PDFs — Official NIOS Website'),
      ),
      const SizedBox(height: 18),
      const StudySection('Saved Offline PDFs'),
      if (pdfs.isEmpty) const StudyPanel(
        child: Padding(padding: EdgeInsets.all(20),
          child: Text('Your PDF library is empty. Tap Import PDF to begin.')),
      ),
      for (final pdf in pdfs) ...[
        StudyPanel(child: ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
          title: Text(pdf.name, maxLines: 2,
            overflow: TextOverflow.ellipsis),
          subtitle: const Text('Saved offline'),
          onTap: () async {
            if (!await File(pdf.path).exists()) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF file was not found.')));
              }
              return;
            }
            if (context.mounted) {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (context) => OfflinePdfViewer(pdf: pdf)));
            }
          },
          trailing: IconButton(
            tooltip: 'Delete imported PDF',
            onPressed: () => _deletePdf(pdf),
            icon: const Icon(Icons.delete_outline)),
        )),
        const SizedBox(height: 9),
      ],
      const SizedBox(height: 75),
    ]),
  );
}

class OfflinePdfViewer extends StatelessWidget {
  final SavedPdf pdf;
  const OfflinePdfViewer({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(pdf.name,
      maxLines: 1, overflow: TextOverflow.ellipsis)),
    body: PdfViewer.file(pdf.path),
  );
}
