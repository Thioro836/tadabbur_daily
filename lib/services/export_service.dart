import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<String> exportMeditationsToPdf({
    required List<Map<String, dynamic>> entries,
  }) async {
    // Charger la police arabe
    final arabicFontData = await rootBundle.load(
      'assets/fonts/NotoSansArabic-Regular.ttf',
    );
    final arabicFont = pw.Font.ttf(arabicFontData);

    // FIX 1 : Utiliser NotoSans pour le latin aussi (supporte l'apostrophe et accents)
    final latinFontData = await rootBundle.load(
      'assets/fonts/NotoSansArabic-Regular.ttf',
    );
    final latinFont = pw.Font.ttf(latinFontData);

    final pdf = pw.Document();

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
    // FIX 2 : Style arabe avec direction RTL correcte
    final arabicStyle = pw.TextStyle(
      font: arabicFont,
      fontSize: 16,
    );

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
              final verseRef =
                  (surahNumber != null &&
                      surahNumber > 0 &&
                      verseNumber != null &&
                      verseNumber > 0)
                  ? 'Sourate $surahNumber - Verset $verseNumber'
                  : 'Verset ${globalVerseNumber ?? '?'}';

              final verseText = (entry['arabicText'] ?? '').toString().trim();
              final translation = (entry['translation'] ?? '').toString().trim();
              final reflection = (entry['reflection'] ?? '').toString().trim();
              final identification = (entry['identification'] ?? '').toString().trim();
              final invocation = (entry['invocation'] ?? '').toString().trim();

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
                      // FIX 3 : Affichage du verset arabe avec alignement RTL
                      if (verseText.isNotEmpty) ...[
                        pw.SizedBox(height: 10),
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(4),
                            ),
                          ),
                          child: pw.Text(
                            verseText,
                            style: arabicStyle,
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                      if (translation.isNotEmpty) ...[
                        pw.SizedBox(height: 8),
                        pw.Text(
                          translation,
                          style: bodyStyle.copyWith(
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                      pw.SizedBox(height: 10),
                      pw.Divider(thickness: 0.5),
                      pw.SizedBox(height: 6),
                      pw.Text('Ce qui m\'a marque', style: labelStyle),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        reflection.isNotEmpty ? reflection : '-',
                        style: bodyStyle,
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text('Comment je m\'y identifie', style: labelStyle),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        identification.isNotEmpty ? identification : '-',
                        style: bodyStyle,
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text('Mon du\'a', style: labelStyle),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invocation.isNotEmpty ? invocation : '-',
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
    } catch (e) {
      print('PDF share skipped: $e');
    }

    return file.path;
  }
}