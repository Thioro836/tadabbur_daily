import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:tadabbur_daily/services/quran_service.dart';

class ExportService {
  static Future<String> exportMeditationsToPdf({
    required List<Map<String, dynamic>> entries,
  }) async {
    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansArabic-Regular.ttf',
    );
    final arabicFont = pw.Font.ttf(fontData);
    final pdf = pw.Document();

    final latinFont = pw.Font.helvetica();
    final headerStyle = pw.TextStyle(
      font: latinFont,
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
    );
    final labelStyle = pw.TextStyle(
      font: latinFont,
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
    );
    final bodyStyle = pw.TextStyle(font: latinFont, fontSize: 12);
    final arabicStyle = pw.TextStyle(font: arabicFont, fontSize: 14);

    const Map<String, String> unicodeTranslit = {
      '’': "'",
      '‘': "'",
      '“': '"',
      '”': '"',
      '–': '-',
      '—': '-',
      '…': '...',
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'å': 'a',
      'ā': 'a',
      'ă': 'a',
      'ą': 'a',
      'À': 'A',
      'Á': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'Å': 'A',
      'Ā': 'A',
      'Ă': 'A',
      'Ą': 'A',
      'ç': 'c',
      'ć': 'c',
      'ĉ': 'c',
      'ċ': 'c',
      'č': 'c',
      'Ç': 'C',
      'Ć': 'C',
      'Ĉ': 'C',
      'Ċ': 'C',
      'Č': 'C',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'ē': 'e',
      'ĕ': 'e',
      'ė': 'e',
      'ę': 'e',
      'ě': 'e',
      'É': 'E',
      'È': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Ē': 'E',
      'Ĕ': 'E',
      'Ė': 'E',
      'Ę': 'E',
      'Ě': 'E',
      'î': 'i',
      'ï': 'i',
      'í': 'i',
      'ì': 'i',
      'ī': 'i',
      'ĭ': 'i',
      'į': 'i',
      'İ': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Í': 'I',
      'Ì': 'I',
      'Ī': 'I',
      'Ĭ': 'I',
      'Į': 'I',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ø': 'o',
      'ō': 'o',
      'ŏ': 'o',
      'ő': 'o',
      'Ơ': 'O',
      'Ó': 'O',
      'Ò': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'Ø': 'O',
      'Ō': 'O',
      'Ŏ': 'O',
      'Ő': 'O',
      'œ': 'oe',
      'Œ': 'OE',
      'æ': 'ae',
      'Æ': 'AE',
      'û': 'u',
      'ù': 'u',
      'ú': 'u',
      'ü': 'u',
      'ū': 'u',
      'ŭ': 'u',
      'ů': 'u',
      'ű': 'u',
      'ų': 'u',
      'Û': 'U',
      'Ù': 'U',
      'Ú': 'U',
      'Ü': 'U',
      'Ū': 'U',
      'Ŭ': 'U',
      'Ů': 'U',
      'Ű': 'U',
      'Ų': 'U',
      'ÿ': 'y',
      'Ÿ': 'Y',
      'ñ': 'n',
      'ń': 'n',
      'ņ': 'n',
      'ň': 'n',
      'ŋ': 'n',
      'Ñ': 'N',
      'Ń': 'N',
      'Ņ': 'N',
      'Ň': 'N',
      'Ŋ': 'N',
      'ś': 's',
      'ŝ': 's',
      'ş': 's',
      'š': 's',
      'Ś': 'S',
      'Ŝ': 'S',
      'Ş': 'S',
      'Š': 'S',
      'ż': 'z',
      'ź': 'z',
      'ž': 'z',
      'Ż': 'Z',
      'Ź': 'Z',
      'Ž': 'Z',
      'ř': 'r',
      'ŕ': 'r',
      'ŗ': 'r',
      'Ř': 'R',
      'Ŕ': 'R',
      'Ŗ': 'R',
      'ď': 'd',
      'đ': 'd',
      'Ď': 'D',
      'Đ': 'D',
      'ť': 't',
      'ţ': 't',
      'ț': 't',
      'Ť': 'T',
      'Ţ': 'T',
      'Ț': 'T',
      'ĥ': 'h',
      'ħ': 'h',
      'Ĥ': 'H',
      'Ħ': 'H',
      'ĵ': 'j',
      'Ĵ': 'J',
      'ŵ': 'w',
      'Ŵ': 'W',
      'ý': 'y',
      'Ý': 'Y',
      'Þ': 'TH',
      'þ': 'th',
      'ß': 'ss',
    };

    String normalizeText(String text) {
      if (text.isEmpty) return text;
      final buffer = StringBuffer();
      for (final codeUnit in text.runes) {
        final char = String.fromCharCode(codeUnit);
        buffer.write(unicodeTranslit[char] ?? char);
      }
      return buffer.toString();
    }

    Map<String, int> getSurahVerse(int globalVerseNumber) {
      int remaining = globalVerseNumber;
      for (int i = 0; i < QuranService.versesPerSurah.length; i++) {
        final versesInSurah = QuranService.versesPerSurah[i];
        if (remaining <= versesInSurah) {
          return {'surah': i + 1, 'verse': remaining};
        }
        remaining -= versesInSurah;
      }
      return {'surah': 0, 'verse': 0};
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final content = <pw.Widget>[
            pw.Text('Mes notes de méditation', style: headerStyle),
            pw.SizedBox(height: 12),
            pw.Text(
              'Export généré le ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: bodyStyle.copyWith(fontSize: 10),
            ),
            pw.SizedBox(height: 16),
          ];

          if (entries.isEmpty) {
            content.add(
              pw.Text('Aucune méditation à exporter.', style: bodyStyle),
            );
          } else {
            for (final entry in entries) {
              final date = (entry['date'] ?? '').toString();
              final surahNumber = entry['surahNumber'] as int?;
              final verseNumber = entry['verseNumber'] as int?;
              final globalVerseNumber = entry['globalVerseNumber'] as int?;
              final effectiveSurahNumber =
                  (surahNumber != null && surahNumber > 0)
                  ? surahNumber
                  : (globalVerseNumber != null && globalVerseNumber > 0
                        ? getSurahVerse(globalVerseNumber)['surah']!
                        : 0);
              final effectiveVerseNumber =
                  (verseNumber != null && verseNumber > 0)
                  ? verseNumber
                  : (globalVerseNumber != null && globalVerseNumber > 0
                        ? getSurahVerse(globalVerseNumber)['verse']!
                        : 0);
              final verseRef =
                  (effectiveSurahNumber > 0 && effectiveVerseNumber > 0)
                  ? 'Sourate $effectiveSurahNumber · Verset $effectiveVerseNumber'
                  : 'Verset ${globalVerseNumber ?? '?'}';
              final verseText = normalizeText(
                (entry['arabicText'] ?? '').toString(),
              );
              final translation = normalizeText(
                (entry['translation'] ?? '').toString(),
              );
              final reflection = normalizeText(
                (entry['reflection'] ?? '').toString(),
              );
              final identification = normalizeText(
                (entry['identification'] ?? '').toString(),
              );
              final invocation = normalizeText(
                (entry['invocation'] ?? '').toString(),
              );

              content.add(
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.5),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(6),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(date, style: labelStyle),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        verseRef,
                        style: bodyStyle.copyWith(fontSize: 11),
                      ),
                      if (verseText.isNotEmpty) ...[
                        pw.SizedBox(height: 8),
                        pw.Directionality(
                          textDirection: pw.TextDirection.rtl,
                          child: pw.Text(verseText, style: arabicStyle),
                        ),
                      ],
                      if (translation.isNotEmpty) ...[
                        pw.SizedBox(height: 6),
                        pw.Text(translation, style: bodyStyle),
                      ],
                      pw.SizedBox(height: 10),
                      pw.Text('Réflexion', style: labelStyle),
                      pw.Text(
                        reflection.isNotEmpty ? reflection : '—',
                        style: bodyStyle,
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text('Identification', style: labelStyle),
                      pw.Text(
                        identification.isNotEmpty ? identification : '—',
                        style: bodyStyle,
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text('Invocation', style: labelStyle),
                      pw.Text(
                        invocation.isNotEmpty ? invocation : '—',
                        style: bodyStyle,
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          return content;
        },
      ),
    );

    final appDir = await getApplicationDocumentsDirectory();
    Directory targetDir = appDir;

    if (!Platform.isIOS && !Platform.isAndroid) {
      try {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          targetDir = downloadsDir;
        }
      } catch (_) {
        // Sur certaines plateformes mobiles, getDownloadsDirectory() n'est pas supporté.
        targetDir = appDir;
      }
    }

    final file = File(
      '${targetDir.path}/tadabbur_notes_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Mes notes de méditation Tadabbur Daily',
        ),
      );
    } catch (_) {
      // Le partage peut échouer sur certaines plateformes ; le fichier est déjà enregistré.
    }

    return file.path;
  }
}
