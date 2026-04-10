import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur_daily/models/verse.dart';

void main() {
  group('Verse Model Tests', () {
    test('Verse should create instance with all required properties', () {
      const verse = Verse(
        arabicText: 'الحمد لله رب العالمين',
        translation: 'All praise is due to Allah, the Lord of all worlds',
        surahNameArabic: 'الفاتحة',
        surahNameEnglish: 'Al-Fatiha',
        surahNumber: 1,
        verseNumber: 1,
        globalVerseNumber: 1,
        audioUrl: 'https://example.com/audio.mp3',
      );

      expect(verse.arabicText, 'الحمد لله رب العالمين');
      expect(
        verse.translation,
        'All praise is due to Allah, the Lord of all worlds',
      );
      expect(verse.surahNumber, 1);
      expect(verse.verseNumber, 1);
      expect(verse.globalVerseNumber, 1);
      expect(verse.audioUrl, 'https://example.com/audio.mp3');
    });

    test('Verse should handle null audioUrl', () {
      const verse = Verse(
        arabicText: 'الحمد لله رب العالمين',
        translation: 'Praise be to Allah',
        surahNameArabic: 'الفاتحة',
        surahNameEnglish: 'Al-Fatiha',
        surahNumber: 1,
        verseNumber: 1,
        globalVerseNumber: 1,
      );

      expect(verse.audioUrl, isNull);
    });

    test('Verse should create multiple instances with different data', () {
      const verse1 = Verse(
        arabicText: 'الحمد لله',
        translation: 'Praise be to Allah',
        surahNameArabic: 'الفاتحة',
        surahNameEnglish: 'Al-Fatiha',
        surahNumber: 1,
        verseNumber: 1,
        globalVerseNumber: 1,
      );

      const verse2 = Verse(
        arabicText: 'قل هو الله أحد',
        translation: 'Say, He is Allah, the One',
        surahNameArabic: 'الإخلاص',
        surahNameEnglish: 'Al-Ikhlas',
        surahNumber: 112,
        verseNumber: 1,
        globalVerseNumber: 6236,
      );

      expect(verse1.globalVerseNumber, 1);
      expect(verse2.globalVerseNumber, 6236);
      expect(verse1.surahNumber, 1);
      expect(verse2.surahNumber, 112);
    });

    test('Verse constructor should be const', () {
      // This verifies that Verse can be created as a const
      const verse = Verse(
        arabicText: 'الحمد لله',
        translation: 'Praise be to Allah',
        surahNameArabic: 'الفاتحة',
        surahNameEnglish: 'Al-Fatiha',
        surahNumber: 1,
        verseNumber: 1,
        globalVerseNumber: 1,
      );

      expect(verse, isNotNull);
    });
  });
}
