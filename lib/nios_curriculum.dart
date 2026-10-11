/// Official NIOS Senior Secondary course codes, from NIOS Regional Centre
/// course listings. This catalogue is for selection, NOT a claim about which
/// subjects a particular learner has registered for.
/// https://rcpune.nios.ac.in/senior-secondary-courses-material.html
class NiosSubject {
  final String name;
  final String code;
  const NiosSubject(this.name, this.code);
}

const niosSubjects = <NiosSubject>[
  NiosSubject('Hindi', '301'),
  NiosSubject('English', '302'),
  NiosSubject('History', '315'),
  NiosSubject('Political Science', '317'),
  NiosSubject('Introduction to Law', '338'),
  NiosSubject('Sociology', '331'),
  NiosSubject('Psychology', '328'),
  NiosSubject('Economics', '318'),
  NiosSubject('Geography', '316'),
  NiosSubject('Home Science', '321'),
  NiosSubject('Business Studies', '319'),
  NiosSubject('Accountancy', '320'),
  NiosSubject('Mathematics', '311'),
  NiosSubject('Physics', '312'),
  NiosSubject('Chemistry', '313'),
  NiosSubject('Biology', '314'),
  NiosSubject('Computer Science', '330'),
  NiosSubject('Environmental Science', '333'),
  NiosSubject('Data Entry Operations', '336'),
  NiosSubject('Mass Communication', '335'),
  NiosSubject('Painting', '332'),
  NiosSubject('Library and Information Science', '339'),
];

/// Actual official chapter titles for NIOS Senior Secondary course 338.
/// https://digital.nios.ac.in/topic.php?id=338en
const introductionToLawChapters = <String>[
  'Meaning of Law',
  'Classification of Legal System',
  'Personal Law I: Hindu and Muslim Law',
  'Personal Law II: Christian, Parsi and Jewish Law',
  'Normative Functions of Law and Social Control',
  'Principles of Natural Justice',
  'Techniques of Law and Remedies I',
  'Techniques of Law and Remedies II',
  'Territorial Law',
  'Civil and Criminal Law',
  'Substantive Law and Procedural Law',
  'Public Law and Private Law',
  'Indian Judicial System',
  'Justice Delivery System',
  'Alternative Dispute Resolution',
  'Legal Services and Lok Adalat',
  'The Constitution of India: Its Nature',
  'Constitutionalism and Preamble',
  'Fundamental Rights and Duties',
  'Directive Principles of State Policy',
  'The Executive',
  'The Legislature',
  'The Judiciary',
  'Environmental Law',
  'Sustainable Development',
  'General Principles of Environmental Law',
  'Contemporary Developments',
  'Consumer Protection',
  'Unfair Trade Practices',
  'Consumer Disputes Redressal Agencies',
  'Consumer Activism',
];

const niosAcademicGuidance =
    'NIOS Senior Secondary (Class 12): select the subjects shown on your '
    'enrolment record. Law (338) is an optional subject and is not required '
    'just because you want to become an advocate. Passing Senior Secondary '
    'requires at least five eligible subjects, including one language.';

const lawCareerPath = <String>[
  'Finish NIOS Senior Secondary (Class 12).',
  'Check the eligibility and entrance rules for a 5-year integrated law degree.',
  'Study at a properly approved law college and complete the degree.',
  'Follow State Bar Council enrolment and AIBE requirements to practise.',
];
