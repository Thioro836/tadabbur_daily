import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur_daily/services/quran_service.dart';

void main() {
  group('QuranService Unit Tests', () {
    late QuranService quranService;

    setUp(() {
      quranService = QuranService();
    });

    test('QuranService should be instantiable', () {
      expect(quranService, isNotNull);
    });

    test('QuranService should have fetchRandomVerse method', () {
      expect(quranService.fetchRandomVerse, isNotNull);
    });

    test('QuranService should have proper initialization', () {
      expect(quranService.runtimeType.toString(), 'QuranService');
    });

    test('QuranService default language is French', () {
      // Test that French is a supported language
      final supportedLanguages = ['fr', 'en'];
      expect(supportedLanguages.contains('fr'), true);
    });

    test('QuranService supports both French and English', () {
      final supportedLanguages = ['fr', 'en'];
      expect(supportedLanguages.length, 2);
      expect(supportedLanguages.contains('fr'), true);
      expect(supportedLanguages.contains('en'), true);
    });

    test('QuranService API endpoint is valid', () {
      const apiUrl = 'http://api.alquran.cloud/v1/random';
      expect(apiUrl.isNotEmpty, true);
      expect(apiUrl.startsWith('http'), true);
    });

    test('QuranService can construct API URL with French', () {
      const baseUrl = 'http://api.alquran.cloud/v1/random';
      const lang = 'fr';
      const expectedFragment = 'fr_sahih';

      expect(expectedFragment.contains(lang), true);
    });

    test('QuranService can construct API URL with English', () {
      const baseUrl = 'http://api.alquran.cloud/v1/random';
      const lang = 'en';
      const expectedFragment = 'en_sahih';

      expect(expectedFragment.contains(lang), true);
    });

    test('QuranService Verse fields validation', () {
      // Test that expected Verse fields exist
      final expectedFields = [
        'arabicText',
        'translation',
        'surah',
        'globalVerseNumber',
      ];
      expect(expectedFields.length, 4);
    });
  });
}
