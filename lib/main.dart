import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'study_screens.dart';

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

  void selectTab(int index) {
    if (mounted) setState(() => currentTab = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onSelect: selectTab),
      const StudyScreen(),
      const QuizScreen(),
      const ProgressScreen(),
      SettingsScreen(
        onlineConfigured: widget.onlineConfigured,
        quickExit: () => selectTab(1),
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: currentTab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: selectTab,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE1EDFF),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Study'),
          NavigationDestination(icon: Icon(Icons.bolt_outlined), selectedIcon: Icon(Icons.bolt), label: 'Quiz'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
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
              subtitle: 'Learn  •  Practice  •  Grow  •  Do Better'),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StudySection('Your learning space'),
                StudyPanel(
                  child: Row(children: [
                    const Icon(Icons.waving_hand, color: Color(0xFFFFB02B)),
                    const SizedBox(width: 10),
                    const Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('A little progress every day',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 3),
                        Text('Start with notes or take a quick quiz.',
                          style: TextStyle(color: Color(0xFF70809D), fontSize: 12)),
                      ],
                    )),
                    IconButton(onPressed: () => onSelect(2),
                      icon: const Icon(Icons.arrow_forward, color: studyBlue)),
                  ]),
                ),
                const StudySection('My subjects'),
                Row(children: [
                  Expanded(child: _SubjectCard('Mathematics',
                      Icons.calculate_outlined, const Color(0xFF1768F7),
                      () => onSelect(1))),
                  const SizedBox(width: 9),
                  Expanded(child: _SubjectCard('Science',
                      Icons.science_outlined, const Color(0xFFF34678),
                      () => onSelect(1))),
                ]),
                const SizedBox(height: 9),
                Row(children: [
                  Expanded(child: _SubjectCard('English',
                      Icons.menu_book_outlined, const Color(0xFF0DA982),
                      () => onSelect(1))),
                  const SizedBox(width: 9),
                  Expanded(child: _SubjectCard('General Knowledge',
                      Icons.public, const Color(0xFFEF9418),
                      () => onSelect(1))),
                ]),
                const StudySection('Quick access'),
                StudyFeatureTile(title: 'Quick Quiz', description: '10 practice questions',
                    icon: Icons.fact_check_outlined, color: const Color(0xFF7257D7),
                    onTap: () => onSelect(2)),
                const SizedBox(height: 10),
                StudyFeatureTile(title: 'My Notes', description: 'Save and revise chapters',
                    icon: Icons.sticky_note_2_outlined, color: const Color(0xFFEF9418),
                    onTap: () => onSelect(1)),
                const SizedBox(height: 10),
                StudyFeatureTile(title: 'Study Progress', description: 'See goals and results',
                    icon: Icons.insights_outlined, color: studyBlue,
                    onTap: () => onSelect(3)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      );
}

class _SubjectCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SubjectCard(this.title, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 30),
            const Spacer(),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Open subject', style: TextStyle(
              fontSize: 11, color: Color(0xFF6D7A96))),
          ]),
        ),
      );
}
