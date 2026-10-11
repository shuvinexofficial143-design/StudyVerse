import 'package:flutter/material.dart';
import 'main.dart';
import 'study_data.dart';

/// Original short revision notes, bundled locally; not official NIOS textbooks.
/// Subject/lesson enrollment and official textbooks must still be checked.
const readyStudyNotes = <StudyNote>[
  StudyNote(id: 'bundle-1', subject: "Introduction to Law", title: "Meaning and Sources of Law", body: "Law is a set of rules recognised and enforced by legal institutions. It helps maintain order, protect rights and resolve disputes.\n\nImportant sources include the Constitution, Acts passed by legislatures, delegated legislation, judicial precedents and legally recognised customs.\n\nLaw and morality influence each other but are not identical. A moral wrong is not always a legal offence.\n\nRevision question: Explain any two functions and two sources of law."),
  StudyNote(id: 'bundle-2', subject: "Introduction to Law", title: "Principles of Natural Justice", body: "Natural justice promotes fairness in decision-making.\n\n1. Audi alteram partem: A person affected by a decision should have a fair opportunity to be heard.\n2. Nemo judex in causa sua: A person should not judge a matter in which they have a personal interest.\n\nExample: Before serious disciplinary action, a student should normally receive notice and an opportunity to respond, subject to applicable rules.\n\nRevision question: Why is the right to be heard important?"),
  StudyNote(id: 'bundle-3', subject: "Introduction to Law", title: "The Indian Judicial System", body: "India has a structured court system. The Supreme Court is the country's highest court. High Courts serve states or groups of states, and district and subordinate courts deal with many local disputes.\n\nCivil cases may concern property, contracts and other private rights. Criminal proceedings relate to offences and penalties.\n\nA court's jurisdiction and the availability of appeals are determined by law.\n\nRevision question: Compare the roles of a High Court and a district court."),
  StudyNote(id: 'bundle-4', subject: "Introduction to Law", title: "Constitution and Fundamental Rights", body: "The Constitution establishes India's main governing institutions and fundamental legal principles. The Preamble expresses ideals including justice, liberty, equality and fraternity.\n\nPart III contains Fundamental Rights. Part IV sets out Directive Principles of State Policy. Part IVA sets out Fundamental Duties.\n\nRights may have constitutionally permitted restrictions, so learn both their scope and limitations.\n\nRevision question: Distinguish Fundamental Rights from Directive Principles."),
  StudyNote(id: 'bundle-5', subject: "Introduction to Law", title: "Lok Adalat and Alternative Dispute Resolution", body: "Alternative dispute resolution (ADR) includes approaches such as mediation and conciliation. The aim is to resolve suitable disputes without a full contested trial.\n\nIn mediation, a neutral person helps parties negotiate their own agreement. Lok Adalats provide a legal forum for settlement of certain disputes within statutory limits.\n\nDifferent methods have different legal rules and are not suitable for every case.\n\nRevision question: State two possible advantages of settlement-based dispute resolution."),
  StudyNote(id: 'bundle-6', subject: "Political Science", title: "State, Nation and Government", body: "The state is generally studied through four elements: population, territory, government and sovereignty. A nation can also involve shared identity, history or belonging.\n\nGovernment is the machinery through which the state acts. Governments may change after elections, while the state continues.\n\nIn a democracy, public participation, legitimacy and accountability are essential.\n\nRevision question: Write two differences between a state and a government."),
  StudyNote(id: 'bundle-7', subject: "Political Science", title: "Democracy and Separation of Powers", body: "Democracy relies on public participation, representative institutions, regular elections, the rule of law and protection of rights.\n\nThe legislature makes laws, the executive administers them and the judiciary interprets laws and resolves disputes. Constitutional checks and balances help prevent misuse of power.\n\nRevision question: Why does an independent judiciary matter in a democracy?"),
  StudyNote(id: 'bundle-8', subject: "Political Science", title: "Elections and Universal Adult Franchise", body: "Universal adult franchise means eligible adult citizens can vote according to law, without property or wealth qualifications. The general minimum voting age in India is 18 years.\n\nThe Election Commission of India is a constitutional institution responsible for important election functions.\n\nRevision question: What makes an election free and fair? Name three conditions."),
  StudyNote(id: 'bundle-9', subject: "History", title: "Sources of History", body: "Historians study inscriptions, coins, archaeological remains, literature, records and travellers' accounts to reconstruct the past.\n\nA primary source may provide direct evidence from the period being examined. Sources must be evaluated for their date, authorship, context and reliability.\n\nTwo sources can present different viewpoints of the same event.\n\nRevision question: Give two examples each of archaeological and written sources."),
  StudyNote(id: 'bundle-10', subject: "History", title: "Indian Freedom Movement: Timeline", body: "1885: Indian National Congress was founded.\n1905: The Swadeshi movement gained momentum.\n1920: The Non-Cooperation Movement began.\n1930: The Salt March became a major event in Civil Disobedience.\n1942: The Quit India Movement began.\n1947: India gained independence and partition took place.\n\nWhen revising, make a table of dates, leaders, causes and outcomes.\n\nRevision question: Compare the aims and methods of the movements of 1920 and 1942."),
  StudyNote(id: 'bundle-11', subject: "Hindi", title: "Hindi: Reading Comprehension and Summary", body: "For an unseen Hindi passage, first identify its central idea and the writer's purpose. Read the questions carefully, use evidence from the passage and answer in clear, correct Hindi.\n\nA good summary retains the original meaning while removing repetition and minor examples. Do not insert unsupported personal opinions.\n\nPractice: Read a short Hindi news report and write its summary in approximately 50 words."),
  StudyNote(id: 'bundle-12', subject: "Hindi", title: "Hindi: Formal Letters and Reports", body: "A formal Hindi letter typically includes the sender's address, date, recipient, subject, salutation, main message and signature.\n\nUse polite, accurate language and a logical sequence of paragraphs. Reports should identify when and where an event occurred, the key facts and the conclusion.\n\nPractice: Draft a formal letter in Hindi requesting additional library books. This explanation is in English for English-medium revision."),
  StudyNote(id: 'bundle-13', subject: "English", title: "English Grammar: Tenses", body: "Simple Present: She studies every day.\nPresent Continuous: She is studying now.\nSimple Past: She studied yesterday.\nPresent Perfect: She has finished her homework.\n\nPay attention to helping verbs, subject–verb agreement and time expressions.\n\nPractice: Change 'He reads a book' into present continuous, simple past and present perfect. Explain when each tense is used."),
  StudyNote(id: 'bundle-14', subject: "English", title: "Reading Comprehension and Formal Writing", body: "Read a passage first to understand its central idea, then scan for details. Separate facts stated in the text from guesses or assumptions.\n\nFor formal writing, introduce the purpose, give supporting details, make a clear request or conclusion and proofread spelling and grammar.\n\nPractice: Write a 100-word letter requesting two days of leave."),
  StudyNote(id: 'bundle-15', subject: "Sociology", title: "Socialisation and Social Institutions", body: "Socialisation is the process through which people learn the values, expectations and behaviour of a society.\n\nFamily, school, peers and media can influence socialisation. Social institutions such as education, family and the economy organise important areas of social life.\n\nRevision question: Explain how family and school contribute to socialisation."),
  StudyNote(id: 'bundle-16', subject: "Geography", title: "Weather and Climate", body: "Weather describes short-term atmospheric conditions at a place. Climate refers to long-term patterns and averages of weather.\n\nImportant elements include temperature, rainfall, humidity, air pressure and wind. India's monsoon is influenced by seasonal changes in circulation and land–sea temperature contrasts.\n\nRevision question: How can climate remain recognisable while daily weather changes?"),
  StudyNote(id: 'bundle-17', subject: "Economics", title: "Demand, Supply and Price", body: "Demand refers to quantities consumers are willing and able to purchase at different prices. Supply refers to quantities producers are willing and able to offer.\n\nOther factors being equal, a higher price generally reduces quantity demanded and increases quantity supplied. Income, technology and production costs can shift demand or supply.\n\nRevision question: Explain why festival demand may affect the market price of a product."),
  StudyNote(id: 'bundle-18', subject: "Psychology", title: "Learning, Memory and Study Methods", body: "Learning is a relatively lasting change in knowledge or behaviour resulting from experience or practice. Attention and memory influence how well information is retained.\n\nActive recall: Answer questions without looking at notes.\nSpaced repetition: Revise after increasing time intervals.\nPractice tests: Identify weak areas and correct mistakes.\n\nRevision question: Why can active recall be more effective than repeatedly rereading notes?"),
  StudyNote(id: 'bundle-19', subject: "Mathematics", title: "Quadratic Equations", body: "A quadratic equation has the form ax² + bx + c = 0, where a is not zero.\n\nThe quadratic formula is x = (-b ± √(b² - 4ac)) / (2a).\nThe discriminant D = b² - 4ac indicates the type of roots:\nD > 0: two distinct real roots.\nD = 0: one repeated real root.\nD < 0: no real roots.\n\nPractice: Solve x² - 5x + 6 = 0. Answer: 2 and 3."),
  StudyNote(id: 'bundle-20', subject: "Biology", title: "DNA, Genes and Chromosomes", body: "DNA stores inherited biological information. A gene is a functional region of DNA that may contribute to the production of an RNA or a protein.\n\nMost normal human body cells contain 46 chromosomes. Different forms of a gene are called alleles. DNA replicates before many types of cell division.\n\nRevision question: Use a simple drawing to explain how DNA, genes and chromosomes relate."),
  StudyNote(id: 'bundle-21', subject: "Physics", title: "Motion and Newton's Laws", body: "Acceleration is the rate of change of velocity. For constant mass, Newton's second law can be written as F = ma.\n\nFirst law: An object maintains its state of rest or uniform straight-line motion unless acted on by a net external force.\nThird law: Interacting objects exert equal and opposite forces on each other.\n\nExample: A 2 kg object accelerating at 3 m/s² needs a net force of 6 N.\n\nRevision question: Explain inertia with a real-life example."),
  StudyNote(id: 'bundle-22', subject: "Chemistry", title: "Atoms, Ions and Chemical Bonds", body: "An atom contains a nucleus with protons and usually neutrons, surrounded by electrons. Protons are positive, electrons negative and neutrons uncharged.\n\nIonic bonding involves electrostatic attraction between oppositely charged ions. Covalent bonding involves sharing electron pairs.\n\nRevision question: Compare bonding in sodium chloride (NaCl) and water (H₂O)."),
  StudyNote(id: 'bundle-23', subject: "Business Studies", title: "Functions of Management", body: "Core management functions are often described as Planning, Organising, Staffing, Directing and Controlling.\n\nPlanning defines objectives and actions. Organising allocates responsibilities. Staffing develops people. Directing provides leadership and motivation. Controlling compares actual outcomes with planned goals and identifies corrective action.\n\nRevision question: Give practical examples of planning and controlling in a small shop."),
  StudyNote(id: 'bundle-24', subject: "Accountancy", title: "The Accounting Equation", body: "The accounting equation is Assets = Liabilities + Owner's Equity.\n\nAssets are economic resources controlled by the business, liabilities are obligations and owner's equity represents the owner's residual interest.\n\nExample: If the owner invests ₹10,000 cash, both cash assets and owner's equity increase by ₹10,000.\n\nRevision question: What happens to the equation when a business borrows ₹5,000 from a bank?"),
];

class ReadyStudyNotesScreen extends StatefulWidget {
  const ReadyStudyNotesScreen({super.key});

  @override
  State<ReadyStudyNotesScreen> createState() => _ReadyStudyNotesScreenState();
}

class _ReadyStudyNotesScreenState extends State<ReadyStudyNotesScreen> {
  String activeSubject = 'All';
  String keyword = '';

  @override
  Widget build(BuildContext context) {
    final subjects = readyStudyNotes.map((e) => e.subject).toSet().toList()..sort();
    final matching = readyStudyNotes.where((e) =>
      (activeSubject == 'All' || e.subject == activeSubject) &&
      (keyword.isEmpty || (e.title.toLowerCase().contains(keyword.toLowerCase()) ||
          e.body.toLowerCase().contains(keyword.toLowerCase())))).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Ready Study Notes')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const StudyPanel(child: Text(
          '24 original revision notes available offline. '
          'They are concise summaries, not complete official NIOS textbooks. Use the Official PDF Library for full lessons.'
        )),
        const SizedBox(height: 12),
        TextField(onChanged: (v) => setState(() => keyword = v),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search), hintText: 'Search notes...',
          )),
        const SizedBox(height: 12),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
          children: ['All', ...subjects].map((s) => Padding(
            padding: const EdgeInsets.only(right: 7),
            child: ChoiceChip(label: Text(s), selected: activeSubject == s,
              onSelected: (_) => setState(() => activeSubject = s)),
          )).toList(),
        )),
        const SizedBox(height: 12),
        for (final n in matching) ...[
          StudyFeatureTile(
            title: n.title,
            description: n.subject,
            icon: Icons.auto_stories_outlined,
            color: studyBlue,
            onTap: () => Navigator.push(context, MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text(n.subject)),
                body: ListView(padding: const EdgeInsets.all(18), children: [
                  Text(n.title, style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  SelectableText(n.body, style: const TextStyle(
                    fontSize: 16, height: 1.55)),
                  const SizedBox(height: 25),
                  const Text('Source: Original NIOS-aligned revision summary. '
                    'इसे पूरी किताब या आधिकारिक प्रश्नपत्र न समझें।',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
              ),
            )),
          ),
          const SizedBox(height: 10),
        ],
        if (matching.isEmpty)
          const StudyPanel(child: Text('No notes found for this subject.')),
        const SizedBox(height: 30),
      ]),
    );
  }
}
