import 'package:flutter/material.dart';
import 'package:tadabbur_daily/models/verse.dart';
import 'package:tadabbur_daily/services/quran_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuranService _quranService = QuranService();
  late Future<Verse> _verseFuture;

  @override
  void initState() {
    super.initState();
    _verseFuture = _quranService.fetchRandomVerse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('verset du jour')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<Verse>(
                future: _verseFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Erreur !');
                  }
                  final verse = snapshot.data!;
                  return Column(
                    children: [
                      Text(
                        '${verse.surahNameEnglish} (${verse.surahNumber}:${verse.verseNumber})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        verse.arabicText,
                        textAlign: TextAlign.right,
                        textDirection:
                            TextDirection.rtl, // Right-To-Left (arabe)
                        style: TextStyle(fontSize: 24),
                      ),
                      Divider(thickness: 1, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        verse.translation,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Verset suivant'),
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
