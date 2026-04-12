import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tadabbur_daily/models/verse.dart';
import 'package:tadabbur_daily/services/quran_service.dart';
import 'package:tadabbur_daily/screens/journal_screen.dart';
import 'package:tadabbur_daily/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuranService _quranService = QuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<Verse>? _verseFuture;
  String _language = 'fr';
  bool _isPlaying = false;
  String? _currentAudioUrl;

  @override
  void initState() {
    super.initState();
    _loadVerse();

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
        if (state.processingState == ProcessingState.completed) {
          _audioPlayer.stop();
          _audioPlayer.seek(Duration.zero);
        }
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadVerse() async {
    await _audioPlayer.stop();
    _currentAudioUrl = null;
    final lang = await StorageService().getLanguage();
    setState(() {
      _language = lang;
      _verseFuture = _quranService.fetchRandomVerse(language: lang);
    });
  }

  Future<void> _toggleAudio(String? audioUrl) async {
    if (audioUrl == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_currentAudioUrl != audioUrl) {
        _currentAudioUrl = audioUrl;
        await _audioPlayer.setUrl(audioUrl);
      }
      await _audioPlayer.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('verset du jour'),
        actions: [
          TextButton(
            onPressed: () async {
              await StorageService().saveLanguage(
                _language == 'fr' ? 'en' : 'fr',
              );
              _loadVerse();
            },
            child: Text(
              _language == 'fr' ? 'EN' : 'FR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _loadVerse();
            },
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_verseFuture == null)
                CircularProgressIndicator()
              else
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
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300),
                      builder: (context, opacity, child) {
                        return Opacity(opacity: opacity, child: child);
                      },
                      child: Column(
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.teal, width: 2),
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 28,
                                horizontal: 18,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '${verse.surahNameEnglish} (${verse.surahNumber}:${verse.verseNumber})',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[800],
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  Text(
                                    verse.surahNameArabic,
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: GoogleFonts.amiri(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[700],
                                    ),
                                  ),
                                  SizedBox(height: 18),
                                  Text(
                                    verse.arabicText,
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: GoogleFonts.amiri(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.teal[900],
                                      height: 2.2,
                                    ),
                                  ),
                                  SizedBox(height: 18),
                                  Divider(
                                    thickness: 1,
                                    color: Colors.teal[100],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    verse.translation,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.teal[700],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  // Bouton Audio centré
                                  if (verse.audioUrl != null)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: IconButton(
                                          icon: Icon(
                                            _isPlaying
                                                ? Icons.pause_circle
                                                : Icons.play_circle,
                                            color: Colors.teal[700],
                                            size: 48,
                                          ),
                                          onPressed: () async {
                                            await _toggleAudio(verse.audioUrl);
                                          },
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 8),
                                  // Bouton favori centré
                                  Center(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.favorite_border,
                                        color: Colors.teal[700],
                                      ),
                                      onPressed: () async {
                                        await StorageService().saveFavorite({
                                          'globalVerseNumber':
                                              verse.globalVerseNumber,
                                          'surahNameEnglish':
                                              verse.surahNameEnglish,
                                          'surahNameArabic':
                                              verse.surahNameArabic,
                                          'surahNumber': verse.surahNumber,
                                          'verseNumber': verse.verseNumber,
                                          'arabicText': verse.arabicText,
                                          'translation': verse.translation,
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Verset ajouté aux favoris ⭐',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      JournalScreen(verse: verse),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text('Méditer'),
                          ),
                        ],
                      ),
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