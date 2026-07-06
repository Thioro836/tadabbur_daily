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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final content = <pw.Widget>[
            pw.Text(
              'Mes notes de méditation',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Export généré le ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 16),
          ];

          if (entries.isEmpty) {
            content.add(pw.Text('Aucune méditation à exporter.'));
          } else {
            for (final entry in entries) {
              final date = (entry['date'] ?? '').toString();
              final verseRef =
                  entry['surahNumber'] != null && entry['verseNumber'] != null
                  ? 'Sourate ${entry['surahNumber']} · Verset ${entry['verseNumber']}'
                  : 'Verset ${entry['globalVerseNumber'] ?? '?'}';
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
                      pw.Text(
                        date,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        verseRef,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                      if (verseText.isNotEmpty) ...[
                        pw.SizedBox(height: 8),
                        pw.Text(
                          verseText,
                          style: pw.TextStyle(fontSize: 14, font: arabicFont),
                        ),
                      ],
                      if (translation.isNotEmpty) ...[
                        pw.SizedBox(height: 6),
                        pw.Text(
                          translation,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Réflexion',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(reflection.isNotEmpty ? reflection : '—'),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Identification',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(identification.isNotEmpty ? identification : '—'),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Invocation',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(invocation.isNotEmpty ? invocation : '—'),
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
