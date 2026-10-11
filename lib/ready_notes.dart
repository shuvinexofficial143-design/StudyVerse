import 'package:flutter/material.dart';
import 'main.dart';
import 'study_data.dart';

/// Original short revision notes, bundled locally; not official NIOS textbooks.
/// Subject/lesson enrollment and official textbooks must still be checked.
const readyStudyNotes = <StudyNote>[
  StudyNote(id: 'bundle-1', subject: "Introduction to Law", title: "कानून का अर्थ और स्रोत", body: "कानून समाज में व्यवहार को नियंत्रित करने वाले लागू करने योग्य नियम हैं।\n\nमुख्य स्रोत: संविधान, विधायिका के अधिनियम, अधीनस्थ नियम, न्यायिक निर्णय और कानून द्वारा मान्य रीति-रिवाज।\n\nकानून का उद्देश्य न्याय, व्यवस्था और अधिकारों की रक्षा में मदद करना है। कानून और नैतिकता में संबंध है, लेकिन दोनों हमेशा एक समान नहीं होते।\n\nप्रश्न: कानून की किसी दो विशेषताओं और दो स्रोतों को लिखो।"),
  StudyNote(id: 'bundle-2', subject: "Introduction to Law", title: "प्राकृतिक न्याय के सिद्धांत", body: "प्राकृतिक न्याय निष्पक्ष फैसला लेने की बुनियादी प्रक्रिया है।\n\n1. दूसरे पक्ष को सुनना (Audi alteram partem)।\n2. अपने ही मामले में न्यायाधीश न बनना (Nemo judex in causa sua)।\n\nउदाहरण: किसी छात्र पर गंभीर कार्रवाई से पहले आरोप और जवाब देने का अवसर मिलना चाहिए।\n\nप्रश्न: निष्पक्ष सुनवाई क्यों जरूरी है?"),
  StudyNote(id: 'bundle-3', subject: "Introduction to Law", title: "भारतीय न्यायिक व्यवस्था", body: "सर्वोच्च न्यायालय भारत का शीर्ष न्यायालय है। राज्यों में उच्च न्यायालय और उनके अधीन जिला व अन्य न्यायालय काम करते हैं।\n\nदीवानी विवाद: संपत्ति, अनुबंध आदि से जुड़ा हो सकता है। आपराधिक मामले: अपराध और दंड से जुड़े होते हैं।\n\nन्यायालय का क्षेत्राधिकार कानून तय करता है। अपील हर मामले में स्वचालित नहीं होती।\n\nप्रश्न: उच्च न्यायालय और जिला न्यायालय में दो अंतर लिखो।"),
  StudyNote(id: 'bundle-4', subject: "Introduction to Law", title: "संविधान और मौलिक अधिकार", body: "भारतीय संविधान शासन का मूल ढाँचा बनाता है। प्रस्तावना न्याय, स्वतंत्रता, समानता और बंधुता की दिशा बताती है।\n\nमौलिक अधिकार भाग III में, नीति निर्देशक सिद्धांत भाग IV में और मौलिक कर्तव्य भाग IVA में हैं।\n\nमौलिक अधिकारों पर लागू संवैधानिक सीमाएँ भी समझना जरूरी है।\n\nप्रश्न: अधिकार और नीति निर्देशक सिद्धांतों में अंतर बताओ।"),
  StudyNote(id: 'bundle-5', subject: "Introduction to Law", title: "लोक अदालत और ADR", body: "विवाद समाधान के विकल्पों में मध्यस्थता, सुलह और उपयुक्त मामलों में लोक अदालत शामिल हैं।\n\nमध्यस्थता में तीसरा निष्पक्ष व्यक्ति दोनों पक्षों को स्वीकार्य समाधान निकालने में मदद करता है। लोक अदालत की भूमिका और सीमाएँ विधि से निर्धारित होती हैं।\n\nप्रश्न: समझौता आधारित विवाद समाधान के दो फायदे बताओ।"),
  StudyNote(id: 'bundle-6', subject: "Political Science", title: "राष्ट्र, राज्य और सरकार", body: "राज्य के प्रमुख तत्व: जनसंख्या, क्षेत्र, सरकार और संप्रभुता। राष्ट्र साझा पहचान और जुड़ाव की भावना से भी संबंधित है।\n\nसरकार बदल सकती है, पर राज्य बना रहता है। लोकतंत्र में जवाबदेही और जनता की भागीदारी महत्वपूर्ण है।\n\nप्रश्न: राज्य और सरकार में दो अंतर लिखो।"),
  StudyNote(id: 'bundle-7', subject: "Political Science", title: "लोकतंत्र और शक्तियों का विभाजन", body: "लोकतंत्र में नागरिकों की भागीदारी, नियमित चुनाव, विधि का शासन और अधिकारों का संरक्षण महत्वपूर्ण हैं।\n\nविधायिका कानून बनाती है, कार्यपालिका शासन चलाती है और न्यायपालिका विवादों का निर्णय करती है। संस्थाओं में नियंत्रण और संतुलन आवश्यक हैं।\n\nप्रश्न: स्वतंत्र न्यायपालिका लोकतंत्र के लिए क्यों जरूरी है?"),
  StudyNote(id: 'bundle-8', subject: "Political Science", title: "चुनाव और सार्वभौमिक वयस्क मताधिकार", body: "सार्वभौमिक वयस्क मताधिकार का अर्थ है कि निर्धारित आयु पूरी करने वाले योग्य नागरिक कानून के अनुसार मतदान कर सकते हैं।\n\nभारत में मतदान की सामान्य न्यूनतम आयु 18 वर्ष है। चुनाव आयोग चुनाव प्रशासन की महत्वपूर्ण संवैधानिक संस्था है।\n\nप्रश्न: स्वतंत्र और निष्पक्ष चुनाव की तीन विशेषताएँ लिखो।"),
  StudyNote(id: 'bundle-9', subject: "History", title: "इतिहास के स्रोत", body: "इतिहास की पढ़ाई में अभिलेख, सिक्के, पुरातात्विक अवशेष, साहित्य और यात्रा-वृत्तांत जैसे स्रोतों का उपयोग होता है।\n\nप्राथमिक स्रोत अपने समय के प्रत्यक्ष साक्ष्य हो सकते हैं। किसी स्रोत का अर्थ निकालते समय लेखक, समय और संदर्भ जाँचना चाहिए।\n\nप्रश्न: पुरातात्विक और साहित्यिक स्रोतों के उदाहरण दो।"),
  StudyNote(id: 'bundle-10', subject: "History", title: "भारतीय स्वतंत्रता आंदोलन का कालक्रम", body: "1885: भारतीय राष्ट्रीय कांग्रेस की स्थापना। 1905: स्वदेशी आंदोलन को गति। 1920: असहयोग आंदोलन। 1930: दांडी यात्रा और सविनय अवज्ञा। 1942: भारत छोड़ो आंदोलन। 1947: भारत स्वतंत्र हुआ।\n\nयाद करने के लिए हर घटना के कारण, प्रमुख नेतृत्व और परिणाम की टाइमलाइन बनाओ।\n\nप्रश्न: 1920 और 1942 के आंदोलनों में क्या अंतर था?"),
  StudyNote(id: 'bundle-11', subject: "Hindi", title: "अपठित गद्यांश और सार लेखन", body: "पहले पूरा गद्यांश पढ़कर मुख्य विषय पहचानें। उत्तर लिखते समय उसी पाठ के तथ्यों का प्रयोग करें।\n\nसार लेखन में मूल भाव बनाए रखें, उदाहरण/दोहराव कम करें और अपनी निजी राय न जोड़ें।\n\nअभ्यास: किसी खबर का 50 शब्दों में सार लिखें।"),
  StudyNote(id: 'bundle-12', subject: "Hindi", title: "औपचारिक पत्र लेखन", body: "औपचारिक पत्र में पता, तिथि, प्राप्तकर्ता, विषय, संबोधन, मुख्य अनुच्छेद और हस्ताक्षर होते हैं।\n\nभाषा सम्मानजनक, संक्षिप्त और स्पष्ट रखें। अनुरोध तथा कारण सीधे लिखें।\n\nअभ्यास: पुस्तकालय में अतिरिक्त पुस्तकों के लिए प्रधानाचार्य को पत्र लिखें।"),
  StudyNote(id: 'bundle-13', subject: "English", title: "Tenses — quick revision", body: "Simple Present: She studies daily.\nPresent Continuous: She is studying now.\nSimple Past: She studied yesterday.\nPresent Perfect: She has completed her homework.\n\nUse correct helping verbs and time expressions.\n\nPractice: Convert 'He reads books' into continuous and past tense."),
  StudyNote(id: 'bundle-14', subject: "English", title: "Reading comprehension and formal writing", body: "For comprehension, read once for the central idea and once for details. Separate facts from guesses.\n\nFor a formal letter: state your purpose, give supporting details, make a clear request and proofread.\n\nPractice: Write an application for two days of leave in 100 words."),
  StudyNote(id: 'bundle-15', subject: "Sociology", title: "समाजीकरण और सामाजिक संस्थाएँ", body: "समाजीकरण से व्यक्ति समाज के नियम, मूल्य और भूमिकाएँ सीखता है। परिवार, विद्यालय, साथियों और मीडिया का इसमें योगदान हो सकता है।\n\nपरिवार, अर्थव्यवस्था, शिक्षा जैसी संस्थाएँ सामाजिक संबंधों को संगठित करती हैं।\n\nप्रश्न: समाजीकरण के दो प्रमुख माध्यमों की व्याख्या करो।"),
  StudyNote(id: 'bundle-16', subject: "Geography", title: "मौसम और जलवायु", body: "मौसम किसी स्थान की अल्पकालीन वायुमंडलीय दशा है, जबकि जलवायु लंबे समय की औसत प्रवृत्तियों को दर्शाती है।\n\nमुख्य तत्व: तापमान, वर्षा, आर्द्रता, पवन और वायुदाब।\n\nप्रश्न: मौसम बदलता रहता है, फिर भी जलवायु का वर्णन कैसे होता है?"),
  StudyNote(id: 'bundle-17', subject: "Economics", title: "माँग, आपूर्ति और कीमत", body: "माँग का अर्थ किसी कीमत पर खरीदने की इच्छा और क्षमता है। आपूर्ति विक्रेता की बाजार में उपलब्ध कराने की इच्छा और क्षमता से जुड़ी है।\n\nअन्य स्थितियाँ समान हों तो कीमत बढ़ने पर सामान्यतः माँग की मात्रा घटती और आपूर्ति की मात्रा बढ़ती है।\n\nप्रश्न: त्योहार के समय माँग बढ़ने से कीमत क्यों प्रभावित हो सकती है?"),
  StudyNote(id: 'bundle-18', subject: "Psychology", title: "सीखना और याद रखने की तकनीक", body: "सीखने का अर्थ अनुभव और अभ्यास से ज्ञान या व्यवहार में बदलाव है। ध्यान और स्मृति अध्ययन को प्रभावित करते हैं।\n\nActive Recall: पुस्तक बंद करके प्रश्नों के उत्तर याद करो।\nSpaced Revision: अंतराल पर दोहराओ।\nPractice Tests: गलतियों की सूची बनाओ।\n\nप्रश्न: केवल पढ़ने से बेहतर Active Recall क्यों हो सकता है?"),
  StudyNote(id: 'bundle-19', subject: "Mathematics", title: "द्विघात समीकरण", body: "सामान्य रूप: ax² + bx + c = 0 (a ≠ 0)।\n\nमूलों का सूत्र: x = (-b ± √(b²-4ac)) / (2a)\nविवेचक D = b² - 4ac।\nD > 0: दो भिन्न वास्तविक मूल। D = 0: बराबर वास्तविक मूल। D < 0: वास्तविक मूल नहीं।\n\nअभ्यास: x² - 5x + 6 = 0 हल करो। उत्तर: 2, 3।"),
  StudyNote(id: 'bundle-20', subject: "Biology", title: "DNA, जीन और गुणसूत्र", body: "DNA वंशानुगत सूचना का अणु है। जीन DNA का कार्यात्मक क्षेत्र होता है जो अक्सर RNA या प्रोटीन निर्माण से जुड़ा होता है।\n\nमानव की अधिकांश सामान्य देह कोशिकाओं में 46 गुणसूत्र होते हैं।\n\nप्रश्न: DNA, जीन और गुणसूत्र का संबंध चित्र सहित समझाओ।"),
  StudyNote(id: 'bundle-21', subject: "Physics", title: "गति और न्यूटन के नियम", body: "वेग में परिवर्तन की दर त्वरण कहलाती है। स्थिर द्रव्यमान के लिए न्यूटन का दूसरा नियम F = ma है।\n\nप्रथम नियम जड़त्व से, तृतीय नियम क्रिया-प्रतिक्रिया से संबंधित है। तृतीय नियम में बल दो अलग-अलग वस्तुओं पर लगते हैं।\n\nउदाहरण: 2 kg वस्तु में 3 m/s² त्वरण के लिए 6 N बल।"),
  StudyNote(id: 'bundle-22', subject: "Chemistry", title: "परमाणु और रासायनिक बंध", body: "प्रोटॉन धन आवेशित, इलेक्ट्रॉन ऋण आवेशित और न्यूट्रॉन आवेशहीन होते हैं।\n\nआयनिक बंध विपरीत आवेश वाले आयनों के बीच आकर्षण से और सहसंयोजक बंध इलेक्ट्रॉन युग्म की साझेदारी से बनता है।\n\nप्रश्न: NaCl और H₂O में बंध के स्वरूप का अंतर बताओ।"),
  StudyNote(id: 'bundle-23', subject: "Business Studies", title: "प्रबंधन के प्रमुख कार्य", body: "प्रबंधन के सामान्य कार्य: Planning, Organising, Staffing, Directing और Controlling।\n\nPlanning में लक्ष्य तय होते हैं; Organising में कार्य बाँटा जाता है; Controlling में वास्तविक नतीजे लक्ष्य से तुलना करके सुधार किए जाते हैं।\n\nप्रश्न: छोटी दुकान में योजना और नियंत्रण के उदाहरण दो।"),
  StudyNote(id: 'bundle-24', subject: "Accountancy", title: "लेखांकन समीकरण", body: "Assets = Liabilities + Owner's Equity.\n\nउदाहरण: मालिक ₹10,000 निवेश करता है तो नकदी (Asset) और पूँजी (Equity) दोनों बढ़ते हैं।\n\nव्यापार का ऋण लेने पर संपत्ति और दायित्व दोनों में वृद्धि हो सकती है।\n\nप्रश्न: बैंक से ₹5,000 ऋण लेने पर समीकरण में क्या बदलाव होगा?"),
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
          '24 छोटी रिविज़न नोट्स — बिना इंटरनेट पढ़ें। ये StudyVerse के मौलिक सारांश हैं, '
          'NIOS की पूरी आधिकारिक किताबें नहीं। पूर्ण पाठ के लिए Official PDF Library देखें.'
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
                  const Text('स्रोत: NIOS पाठ्यक्रम-संगत स्वतंत्र रिविज़न सारांश। '
                    'इसे पूरी किताब या आधिकारिक प्रश्नपत्र न समझें।',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
              ),
            )),
          ),
          const SizedBox(height: 10),
        ],
        if (matching.isEmpty)
          const StudyPanel(child: Text('इस विषय के नोट्स अभी नहीं हैं।')),
        const SizedBox(height: 30),
      ]),
    );
  }
}
