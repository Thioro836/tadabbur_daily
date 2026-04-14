import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:tadabbur_daily/models/verse.dart';

class QuranService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const int _totalVerses = 6236;

  // Nombre de versets par sourate (114 sourates)
  static const List<int> versesPerSurah = [
    7,
    286,
    200,
    176,
    120,
    165,
    206,
    75,
    129,
    109,
    123,
    111,
    43,
    52,
    99,
    128,
    111,
    110,
    98,
    135,
    112,
    78,
    118,
    64,
    77,
    227,
    93,
    88,
    69,
    60,
    34,
    30,
    73,
    54,
    45,
    83,
    182,
    88,
    75,
    85,
    54,
    53,
    89,
    59,
    37,
    35,
    38,
    29,
    18,
    45,
    60,
    49,
    62,
    55,
    78,
    96,
    29,
    22,
    24,
    13,
    14,
    11,
    11,
    18,
    12,
    12,
    30,
    52,
    52,
    44,
    28,
    28,
    20,
    56,
    40,
    31,
    50,
    40,
    46,
    42,
    29,
    19,
    36,
    25,
    22,
    17,
    19,
    26,
    30,
    20,
    15,
    21,
    11,
    8,
    8,
    19,
    5,
    8,
    8,
    11,
    11,
    8,
    3,
    9,
    5,
    4,
    7,
    3,
    6,
    3,
    5,
    4,
    5,
    6,
  ];

  // Noms des sourates en arabe
  static const List<String> surahNamesArabic = [
    'الفاتحة',
    'البقرة',
    'آل عمران',
    'النساء',
    'المائدة',
    'الأنعام',
    'الأعراف',
    'الأنفال',
    'التوبة',
    'يونس',
    'هود',
    'يوسف',
    'الرعد',
    'إبراهيم',
    'الحجر',
    'النحل',
    'الإسراء',
    'الكهف',
    'مريم',
    'طه',
    'الأنبياء',
    'الحج',
    'المؤمنون',
    'النور',
    'الفرقان',
    'الشعراء',
    'النمل',
    'القصص',
    'العنكبوت',
    'الروم',
    'لقمان',
    'السجدة',
    'الأحزاب',
    'سبأ',
    'فاطر',
    'يس',
    'الصافات',
    'ص',
    'الزمر',
    'غافر',
    'فصلت',
    'الشورى',
    'الزخرف',
    'الدخان',
    'الجاثية',
    'الأحقاف',
    'محمد',
    'الفتح',
    'الحجرات',
    'ق',
    'الذاريات',
    'الطور',
    'النجم',
    'القمر',
    'الرحمن',
    'الواقعة',
    'الحديد',
    'المجادلة',
    'الحشر',
    'الممتحنة',
    'الصف',
    'الجمعة',
    'المنافقون',
    'التغابن',
    'الطلاق',
    'التحريم',
    'الملك',
    'القلم',
    'الحاقة',
    'المعارج',
    'نوح',
    'الجن',
    'المزمل',
    'المدثر',
    'القيامة',
    'الإنسان',
    'المرسلات',
    'النبأ',
    'النازعات',
    'عبس',
    'التكوير',
    'الانفطار',
    'المطففين',
    'الانشقاق',
    'البروج',
    'الطارق',
    'الأعلى',
    'الغاشية',
    'الفجر',
    'البلد',
    'الشمس',
    'الليل',
    'الضحى',
    'الشرح',
    'التين',
    'العلق',
    'القدر',
    'البينة',
    'الزلزلة',
    'العاديات',
    'القارعة',
    'التكاثر',
    'العصر',
    'الهمزة',
    'الفيل',
    'قريش',
    'الماعون',
    'الكوثر',
    'الكافرون',
    'النصر',
    'المسد',
    'الإخلاص',
    'الفلق',
    'الناس',
  ];

  // Génère un numéro de verset aléatoire
  int _getRandomVerseNumber() {
    final random = Random();
    return random.nextInt(_totalVerses) + 1;
  }

  // Calcule le numéro global d'un verset à partir de sourate + numéro dans la sourate
  int _getGlobalVerseNumber(int surahNumber, int verseInSurah) {
    int global = 0;
    for (int i = 0; i < surahNumber - 1; i++) {
      global += versesPerSurah[i];
    }
    return global + verseInSurah;
  }

  // Récupère un verset aléatoire d'une sourate spécifique
  Future<Verse> fetchVerseFromSurah({
    required int surahNumber,
    String language = 'fr',
  }) async {
    final random = Random();
    final verseInSurah = random.nextInt(versesPerSurah[surahNumber - 1]) + 1;
    final globalNumber = _getGlobalVerseNumber(surahNumber, verseInSurah);
    return fetchVerseByNumber(globalNumber, language: language);
  }

  // Récupère un verset par son numéro global
  Future<Verse> fetchVerseByNumber(
    int verseNumber, {
    String language = 'fr',
  }) async {
    final String translationEdition = language == 'fr'
        ? 'fr.hamidullah'
        : 'en.sahih';

    final url = Uri.parse(
      '$_baseUrl/ayah/$verseNumber/editions/quran-uthmani,$translationEdition,ar.alafasy',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List ayahs = data['data'];

      if (ayahs.length < 3) {
        throw Exception('Réponse API incomplète');
      }
      String arabicText = ayahs[0]['text'];
      final int verseInSurah = ayahs[0]['numberInSurah'];
      final int surahNum = ayahs[0]['surah']['number'];
      final String? audioUrl = ayahs[2]['audio'];

      if (verseInSurah == 1 && surahNum != 1 && surahNum != 9) {
        arabicText = arabicText.replaceFirst(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ ',
          '',
        );
      }

      return Verse(
        arabicText: arabicText,
        translation: ayahs[1]['text'],
        surahNumber: surahNum,
        surahNameArabic: ayahs[0]['surah']['name'],
        surahNameEnglish: ayahs[0]['surah']['englishName'],
        verseNumber: verseInSurah,
        globalVerseNumber: ayahs[0]['number'],
        audioUrl: audioUrl,
      );
    } else {
      throw Exception('Erreur lors du chargement du verset');
    }
  }

  // Récupère le verset du jour depuis l'API
  Future<Verse> fetchRandomVerse({String language = 'fr'}) async {
    final int verseNumber = _getRandomVerseNumber();
    return fetchVerseByNumber(verseNumber, language: language);
  }
}
