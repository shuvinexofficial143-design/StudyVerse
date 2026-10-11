import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'study_screens.dart';
import 'study_data.dart';
import 'nios_curriculum.dart';

const studyBlue = Color(0xFF1768F7);
const studyInk = Color(0xFF14213F);
const studyCanvas = Color(0xFFF6F9FF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  final onlineConfigured = url.isNotEmpty && anonKey.isNotEmpty;
  if (onlineConfigured) {
    await Supabase.initialize(url: url, publishableKey: anonKey);
  }
  runApp(StudyVerseApp(onlineConfigured: onlineConfigured));
}

class StudyVerseApp extends StatelessWidget {
  final bool onlineConfigured;
  const StudyVerseApp({super.key, required this.onlineConfigured});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'StudyVerse',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: studyBlue,
            brightness: Brightness.light,
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: studyCanvas,
          appBarTheme: const AppBarTheme(
            backgroundColor: studyCanvas,
            foregroundColor: studyInk,
            elevation: 0,
          ),
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: studyInk,
                displayColor: studyInk,
              ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: Color(0xFFE4EBF7)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: Color(0xFFE4EBF7)),
            ),
          ),
        ),
        home: StudyShell(onlineConfigured: onlineConfigured),
      );
}

class StudyShell extends StatefulWidget {
  final bool onlineConfigured;
  const StudyShell({super.key, required this.onlineConfigured});

  @override
  State<StudyShell> createState() => _StudyShellState();
}

class _StudyShellState extends State<StudyShell> {
  int currentTab = 0;
  final List<int> _tabHistory = <int>[0];
  final GlobalKey<QuizScreenState> _quizKey = GlobalKey<QuizScreenState>();

  void selectTab(int index) {
    if (!mounted || index == currentTab) return;
    setState(() {
      currentTab = index;
      _tabHistory.remove(index);
      _tabHistory.add(index);
    });
  }

  Future<void> _handleSystemBack() async {
    // The Android system back button must navigate, not silently close the app.
    if (currentTab == 2 && (_quizKey.currentState?.handleBack() ?? false)) {
      return;
    }
    if (_tabHistory.length > 1) {
      setState(() {
        _tabHistory.removeLast();
        currentTab = _tabHistory.last;
      });
      return;
    }
    if (currentTab != 0) {
      selectTab(0);
      return;
    }
    if (!mounted) return;
    final exitConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit StudyVerse?'),
        content: const Text('Stay here, or close the study app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep studying'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit app'),
          ),
        ],
      ),
    );
    if (exitConfirmed == true) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onSelect: selectTab),
      const StudyScreen(),
      QuizScreen(key: _quizKey),
      const ProgressScreen(),
      SettingsScreen(
        onlineConfigured: widget.onlineConfigured,
        quickExit: () => selectTab(1),
      ),
    ];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleSystemBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: currentTab, children: pages),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentTab,
          onDestinationSelected: selectTab,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE1EDFF),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Study'),
            NavigationDestination(
                icon: Icon(Icons.bolt_outlined),
                selectedIcon: Icon(Icons.bolt),
                label: 'Quiz'),
            NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Progress'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class StudyHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const StudyHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7F2FF), Color(0xFFF6F9FF)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 29, fontWeight: FontWeight.w800,
                        letterSpacing: -0.7, color: studyInk,
                      )),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: const TextStyle(color: Color(0xFF687998),
                          fontSize: 13)),
                ],
              ),
            ),
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFD9E9FF),
              child: Icon(Icons.auto_stories_rounded, color: studyBlue, size: 28),
            ),
          ],
        ),
      );
}

class StudyPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const StudyPanel({super.key, required this.child,
      this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFECF1F9)),
          boxShadow: const [
            BoxShadow(color: Color(0x0A254C96),
                blurRadius: 16, offset: Offset(0, 5)),
          ],
        ),
        child: Material(type: MaterialType.transparency, child: child),
      );
}

class StudySection extends StatelessWidget {
  final String title;
  const StudySection(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Text(title, style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w800)),
      );
}

class StudyFeatureTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const StudyFeatureTile({
    super.key, required this.title, required this.description,
    required this.icon, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => StudyPanel(
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 3),
                      Text(description, style: const TextStyle(
                        fontSize: 11, color: Color(0xFF7886A3))),
                    ]),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF8C9AB7)),
              ],
            ),
          ),
        ),
      );
}

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onSelect;
  const HomeScreen({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          const StudyHeader(
            title: 'StudyVerse',
            subtitle: 'NIOS Senior Secondary  •  Class 12',
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StudyPanel(child: Row(children: [
                  const Icon(Icons.school_rounded,
                      color: studyBlue, size: 36),
                  const SizedBox(width: 14),
                  const Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your NIOS Class 12 Hub',
                          style: TextStyle(fontWeight: FontWeight.w800,
                              fontSize: 17)),
                      SizedBox(height: 4),
                      Text('Study notes, subject practice and daily goals.',
                          style: TextStyle(
                            color: Color(0xFF6B7C99), fontSize: 12)),
                    ],
                  )),
                ])),
                const StudySection('Your registered subjects'),
                FutureBuilder<List<String>>(
                  future: StudyStorage.loadSelectedSubjects(),
                  builder: (context, snapshot) {
                    final subjects = snapshot.data ?? <String>[];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (subjects.isEmpty)
                          const StudyPanel(child: Text(
                            'Choose the subjects on your actual NIOS '
                            'enrolment record. Nothing is assumed here.')),
                        if (subjects.isNotEmpty)
                          Wrap(spacing: 7, runSpacing: 7,
                            children: subjects.map((subject) =>
                              Chip(label: Text(subject),
                                avatar: const Icon(Icons.check_circle,
                                    color: studyBlue, size: 18)))
                              .toList()),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => onSelect(1),
                          icon: const Icon(Icons.tune),
                          label: const Text('Choose or edit subjects'),
                        ),
                      ],
                    );
                  },
                ),
                const StudySection('Start studying'),
                StudyFeatureTile(
                  title: 'Subject Notes & Chapters',
                  description: 'NIOS 12 notes and Law 338 chapters',
                  icon: Icons.menu_book_outlined,
                  color: studyBlue, onTap: () => onSelect(1)),
                const SizedBox(height: 10),
                StudyFeatureTile(
                  title: 'NIOS Practice Quiz',
                  description: 'Law, civics, history and language questions',
                  icon: Icons.fact_check_outlined,
                  color: const Color(0xFF7958C8),
                  onTap: () => onSelect(2)),
                const SizedBox(height: 10),
                StudyFeatureTile(
                  title: 'My Revision Progress',
                  description: 'Revision tasks and quiz scores',
                  icon: Icons.insights_outlined,
                  color: const Color(0xFF0FAE86),
                  onTap: () => onSelect(3)),
                const StudySection('Dream career: Advocate'),
                StudyPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.gavel, color: Color(0xFFCB568F)),
                        SizedBox(width: 10),
                        Expanded(child: Text('Path to becoming a lawyer',
                            style: TextStyle(fontWeight: FontWeight.w800,
                                fontSize: 16))),
                      ]),
                      const SizedBox(height: 12),
                      for (var i = 0; i < lawCareerPath.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: const Color(0xFFE6EDFF),
                                child: Text('${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 11, color: studyBlue)),
                              ),
                              const SizedBox(width: 9),
                              Expanded(child: Text(lawCareerPath[i],
                                style: const TextStyle(fontSize: 12.5))),
                            ],
                          ),
                        ),
                      const Text(
                        'Introduction to Law (338) is optional. It is not '
                        'automatically one of your enrolled NIOS subjects.',
                        style: TextStyle(fontSize: 11,
                            color: Color(0xFF72839B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      );
}
