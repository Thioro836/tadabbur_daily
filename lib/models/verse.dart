class Verse {
  final String arabicText;
  final String translation;
  final String surahNameArabic;
  final String surahNameEnglish;
  final int surahNumber;
  final int verseNumber;
  final int globalVerseNumber;
  final String? audioUrl; // URL audio du verset

  const Verse({
    required this.arabicText,
    required this.translation,
    required this.surahNameArabic,
    required this.surahNameEnglish,
    required this.surahNumber,
    required this.verseNumber,
    required this.globalVerseNumber,
    this.audioUrl,
  });
}
