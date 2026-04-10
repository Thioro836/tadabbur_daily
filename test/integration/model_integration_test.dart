import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur_daily/models/journal_entry.dart';
import 'package:tadabbur_daily/models/verse.dart';

void main() {
  group('Model Integration Tests', () {
    test('JournalEntry should store Verse details', () {
      final entry = JournalEntry(
        id: 'entry-1',
        reflection: 'Beautiful reflection',
        identification: 'I identified with this verse',
        invocation: 'This moved me to dua',
        globalVerseNumber: 1,
        date: DateTime(2026, 4, 10),
      );

      expect(entry.id, 'entry-1');
      expect(entry.reflection, 'Beautiful reflection');
      expect(entry.identification, 'I identified with this verse');
      expect(entry.invocation, 'This moved me to dua');
      expect(entry.globalVerseNumber, 1);
    });

    test('Verse model should work with different languages', () {
      final verseArabic = Verse(
        arabicText: 'الحمد لله رب العالمين',
        translation: 'Praise be to Allah, Lord of all worlds',
        surahNameArabic: 'الفاتحة',
        surahNameEnglish: 'Al-Fatiha',
        surahNumber: 1,
        verseNumber: 1,
        globalVerseNumber: 1,
      );

      final verseEnglish = Verse(
        arabicText: 'الحمد لله رب العالمين',
        translation: 'Praise be to Allah Lord of all the worlds',
        surahNameArabic: 'الفاتحة',
        surahNameEnglish: 'The Opening',
        surahNumber: 1,
        verseNumber: 1,
        globalVerseNumber: 1,
      );

      expect(verseArabic.arabicText, verseEnglish.arabicText);
      expect(verseArabic.translation, isNotEmpty);
      expect(verseEnglish.translation, isNotEmpty);
    });

    test('JournalEntry copyWith should create new instance', () {
      final originalEntry = JournalEntry(
        id: 'entry-1',
        reflection: 'Original reflection',
        identification: 'Original identification',
        invocation: 'Original invocation',
        globalVerseNumber: 1,
        date: DateTime(2026, 4, 10),
      );

      final updatedEntry = originalEntry.copyWith(
        reflection: 'Updated reflection',
      );

      expect(updatedEntry.id, 'entry-1');
      expect(updatedEntry.reflection, 'Updated reflection');
      expect(updatedEntry.identification, 'Original identification');
      expect(updatedEntry.invocation, 'Original invocation');

      // Original should be unchanged
      expect(originalEntry.reflection, 'Original reflection');
    });

    test('Multiple verses can be created independently', () {
      final verses = [
        Verse(
          arabicText: 'Verse 1',
          translation: 'Translation 1',
          surahNameArabic: 'سورة 1',
          surahNameEnglish: 'Surah 1',
          surahNumber: 1,
          verseNumber: 1,
          globalVerseNumber: 1,
        ),
        Verse(
          arabicText: 'Verse 2',
          translation: 'Translation 2',
          surahNameArabic: 'سورة 2',
          surahNameEnglish: 'Surah 2',
          surahNumber: 2,
          verseNumber: 1,
          globalVerseNumber: 50,
        ),
        Verse(
          arabicText: 'Verse 3',
          translation: 'Translation 3',
          surahNameArabic: 'سورة 3',
          surahNameEnglish: 'Surah 3',
          surahNumber: 3,
          verseNumber: 1,
          globalVerseNumber: 100,
        ),
      ];

      expect(verses.length, 3);
      expect(verses[0].globalVerseNumber, 1);
      expect(verses[1].globalVerseNumber, 50);
      expect(verses[2].globalVerseNumber, 100);
    });

    test('Multiple journal entries can be created for different dates', () {
      final entries = [
        JournalEntry(
          id: 'entry-1',
          reflection: 'Day 1 reflection',
          identification: 'Day 1 id',
          invocation: 'Day 1 inv',
          globalVerseNumber: 1,
          date: DateTime(2026, 4, 1),
        ),
        JournalEntry(
          id: 'entry-2',
          reflection: 'Day 2 reflection',
          identification: 'Day 2 id',
          invocation: 'Day 2 inv',
          globalVerseNumber: 50,
          date: DateTime(2026, 4, 2),
        ),
        JournalEntry(
          id: 'entry-3',
          reflection: 'Day 3 reflection',
          identification: 'Day 3 id',
          invocation: 'Day 3 inv',
          globalVerseNumber: 100,
          date: DateTime(2026, 4, 3),
        ),
      ];

      expect(entries.length, 3);
      expect(entries[0].date, DateTime(2026, 4, 1));
      expect(entries[1].date, DateTime(2026, 4, 2));
      expect(entries[2].date, DateTime(2026, 4, 3));
    });

    test('Verse with optional audioUrl should work', () {
      final verseWithAudio = Verse(
        arabicText: 'Text',
        translation: 'Translation',
        surahNameArabic: 'سورة',
        surahNameEnglish: 'Surah',
        surahNumber: 1,
        verseNumber: 1,
        globalVerseNumber: 1,
        audioUrl: 'https://example.com/audio.mp3',
      );

      final verseWithoutAudio = Verse(
        arabicText: 'Text',
        translation: 'Translation',
        surahNameArabic: 'سورة',
        surahNameEnglish: 'Surah',
        surahNumber: 1,
        verseNumber: 1,
        globalVerseNumber: 1,
      );

      expect(verseWithAudio.audioUrl, isNotNull);
      expect(verseWithoutAudio.audioUrl, isNull);
    });

    test('JournalEntry with required fields should work', () {
      final entry = JournalEntry(
        id: 'entry-1',
        reflection: 'Reflection',
        identification: 'Identification',
        invocation: 'Invocation',
        globalVerseNumber: 1,
        date: DateTime(2026, 4, 10),
      );

      final fields = [
        entry.id,
        entry.reflection,
        entry.identification,
        entry.invocation,
      ];

      expect(fields.length, 4);
      expect(fields.every((field) => field.isNotEmpty), true);
    });

    test('Verse global verse number should be unique per surah', () {
      final verse1Surah1 = Verse(
        arabicText: 'Verse 1 of Surah 1',
        translation: 'Translation',
        surahNameArabic: 'السورة الأولى',
        surahNameEnglish: 'Surah 1',
        surahNumber: 1,
        verseNumber: 1,
        globalVerseNumber: 1,
      );

      final verse1Surah2 = Verse(
        arabicText: 'Verse 1 of Surah 2',
        translation: 'Translation',
        surahNameArabic: 'السورة الثانية',
        surahNameEnglish: 'Surah 2',
        surahNumber: 2,
        verseNumber: 1,
        globalVerseNumber: 8,
      );

      expect(verse1Surah1.surahNumber, 1);
      expect(verse1Surah2.surahNumber, 2);
      expect(
        verse1Surah1.globalVerseNumber != verse1Surah2.globalVerseNumber,
        true,
      );
    });

    test('JournalEntry should preserve all field values', () {
      const testId = 'entry-1';
      const testReflection = 'Test reflection content';
      const testIdentification = 'Test identification content';
      const testInvocation = 'Test invocation content';
      const testGlobalVerseNumber = 1;
      final testDate = DateTime(2026, 4, 10);

      final entry = JournalEntry(
        id: testId,
        reflection: testReflection,
        identification: testIdentification,
        invocation: testInvocation,
        globalVerseNumber: testGlobalVerseNumber,
        date: testDate,
      );

      expect(entry.id, testId);
      expect(entry.reflection, testReflection);
      expect(entry.identification, testIdentification);
      expect(entry.invocation, testInvocation);
      expect(entry.globalVerseNumber, testGlobalVerseNumber);
      expect(entry.date, testDate);
    });
  });
}
