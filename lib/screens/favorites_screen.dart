import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tadabbur_daily/services/storage_service.dart';
import 'package:tadabbur_daily/main.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final StorageService _storageService = StorageService();
  late Future<List<Map<String, dynamic>>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _storageService.getAllFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final appState = TadabburApp.of(context);
    final localizations = appState?.languageProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.get('favoritesTitle') ?? 'Mes Favoris'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _entries,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text(localizations?.get('error') ?? 'Erreur !');
                  }
                  final historique = snapshot.data!;
                  if (historique.isEmpty) {
                    return Center(
                      child: Text(
                        localizations?.get('noFavorites') ??
                            'Aucun favori pour le moment ⭐',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: historique.length,
                        itemBuilder: (context, index) {
                          final entry = historique[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry['surahNameEnglish']} (${entry['surahNameArabic']})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${entry['arabicText']}',
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: GoogleFonts.amiri(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      height: 1.8,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${entry['translation']}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
