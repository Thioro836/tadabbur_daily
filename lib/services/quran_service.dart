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

    // Appel API avec édition audio (ar.alafasy = Mishary Alafasy)
    final url = Uri.parse(
      '$_baseUrl/ayah/$verseNumber/editions/quran-uthmani,$translationEdition,ar.alafasy',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List ayahs = data['data'];

      // ayahs[0] = texte arabe
      // ayahs[1] = traduction
      // ayahs[2] = audio
      if (ayahs.length < 3) {
        throw Exception('Réponse API incomplète');
      }
      String arabicText = ayahs[0]['text'];
      final int verseInSurah = ayahs[0]['numberInSurah'];
      final int surahNum = ayahs[0]['surah']['number'];
      final String? audioUrl = ayahs[2]['audio'];

      // Retirer la Basmala du premier verset (sauf Al-Fatiha et At-Tawba)
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
}
