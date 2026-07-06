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
                  ? 'Sourate $surahNumber · Verset $verseNumber'
                  : 'Verset ${globalVerseNumber ?? '?'}';
              final verseText = (entry['arabicText'] ?? '').toString();
              final translation = (entry['translation'] ?? '').toString();
              final reflection = (entry['reflection'] ?? '').toString();
              final identification = (entry['identification'] ?? '').toString();
              final invocation = (entry['invocation'] ?? '').toString();

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
    } catch (e) {
      // Le partage peut échouer sur certaines plateformes ; le fichier est déjà enregistré.
      // On garde simplement l'exception pour le log si nécessaire.
      print('PDF share skipped: $e');
    }

    return file.path;
  }
}
