import 'package:flutter/material.dart';
import 'package:tadabbur_daily/models/verse.dart';
import 'package:tadabbur_daily/services/storage_service.dart';
import 'package:tadabbur_daily/main.dart';

class JournalScreen extends StatefulWidget {
  final Verse verse;
  final String? initialReflection;
  final String? initialIdentification;
  final String? initialInvocation;
  final bool readOnly;
  final String? existingEntryKey;
  final String? initialDate;

  const JournalScreen({
    super.key,
    required this.verse,
    this.initialReflection,
    this.initialIdentification,
    this.initialInvocation,
    this.readOnly = false,
    this.existingEntryKey,
    this.initialDate,
  });

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final StorageService _storageService = StorageService();

  // On crée des TextEditingController pour chaque TextField
  final _reflectionController = TextEditingController();
  final _identificationController = TextEditingController();
  final _invocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reflectionController.text = widget.initialReflection ?? '';
    _identificationController.text = widget.initialIdentification ?? '';
    _invocationController.text = widget.initialInvocation ?? '';
  }

  // On n'oublie pas de les disposer pour éviter les fuites de mémoire
  @override
  void dispose() {
    _reflectionController.dispose();
    _identificationController.dispose();
    _invocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = TadabburApp.of(context);
    final localizations = appState?.languageProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.get('journalTitle') ?? 'Méditation'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.verse.arabicText,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl, // Right-To-Left (arabe)
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 10),
              Text(
                widget.verse.translation,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              Divider(thickness: 1, color: Colors.grey),
              SizedBox(height: 20),
              TextFormField(
                controller: _reflectionController,
                maxLines: 4,
                readOnly: widget.readOnly,
                decoration: InputDecoration(
                  labelText:
                      localizations?.get('whatStruckMe') ??
                      'Ce qui m\'a marqué',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _identificationController,
                maxLines: 4,
                readOnly: widget.readOnly,
                decoration: InputDecoration(
                  labelText:
                      localizations?.get('howIdentify') ??
                      'Comment je m\'y identifie',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _invocationController,
                maxLines: 4,
                readOnly: widget.readOnly,
                decoration: InputDecoration(
                  labelText:
                      localizations?.get('myDuaa') ?? 'Mon du\'a(invocation)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              if (!widget.readOnly)
                ElevatedButton(
                  onPressed: () async {
                    final date =
                        widget.initialDate ??
                        DateTime.now().toString().split(' ')[0];
                    await _storageService.saveEntry(
                      date: date,
                      reflection: _reflectionController.text,
                      identification: _identificationController.text,
                      invocation: _invocationController.text,
                      globalVerseNumber: widget.verse.globalVerseNumber,
                      key: widget.existingEntryKey,
                      arabicText: widget.verse.arabicText,
                      translation: widget.verse.translation,
                      surahNameArabic: widget.verse.surahNameArabic,
                      surahNameEnglish: widget.verse.surahNameEnglish,
                      surahNumber: widget.verse.surahNumber,
                      verseNumber: widget.verse.verseNumber,
                    );
                    //afficher un message de confirmation après la sauvegarde
                    if (!mounted || !context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localizations?.get('saved') ??
                              'Méditation sauvegardée ✅',
                        ),
                      ),
                    );
                    if (!mounted || !context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: Text(localizations?.get('save') ?? 'Sauvegarder'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
