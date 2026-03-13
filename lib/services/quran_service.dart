import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:tadabbur_daily/models/verse.dart';

class QuranService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const int _totalVerses = 6236;

  // Génère un numéro de verset aléatoire
  int _getRandomVerseNumber() {
    final random = Random();
    return random.nextInt(_totalVerses) + 1; // +1 pour éviter 0
  }

  // Récupère le verset du jour depuis l'API
  Future<Verse> fetchRandomVerse({String language = 'fr'}) async {
    final int verseNumber = _getRandomVerseNumber();

    // Choisir l'édition de traduction selon la langue
    final String translationEdition = language == 'fr'
        ? 'fr.hamidullah'
        : 'en.sahih';

    // Appel API
    final url = Uri.parse(
      '$_baseUrl/ayah/$verseNumber/editions/quran-uthmani,$translationEdition',
    );

    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List ayahs = data['data'];

      // ayahs[0] = texte arabe
      // ayahs[1] = traduction
    if (ayahs.length < 2) {
        throw Exception('Réponse API incomplète');
      }
      return Verse(
        arabicText: ayahs[0]['text'],
        translation: ayahs[1]['text'],
        surahNumber: ayahs[0]['surah']['number'],
        surahNameArabic: ayahs[0]['surah']['name'],
        surahNameEnglish: ayahs[0]['surah']['englishName'],
        verseNumber: ayahs[0]['numberInSurah'],
        globalVerseNumber: ayahs[0]['number'],
      );
    } else {
      throw Exception('Erreur lors du chargement du verset');
    }
    
  }
}
