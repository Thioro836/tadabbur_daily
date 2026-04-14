import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
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
      _verseFuture = _loadDailyVerse(lang);
    });
  }

  // Charge le verset du jour depuis le cache, ou un nouveau si périmé
  Future<Verse> _loadDailyVerse(String lang) async {
    final saved = await StorageService().getDailyVerse();
    if (saved != null && saved['language'] == lang) {
      return Verse(
        arabicText: saved['arabicText'],
        translation: saved['translation'],
        surahNumber: saved['surahNumber'],
        surahNameArabic: saved['surahNameArabic'],
        surahNameEnglish: saved['surahNameEnglish'],
        verseNumber: saved['verseNumber'],
        globalVerseNumber: saved['globalVerseNumber'],
        audioUrl: saved['audioUrl'],
      );
    }
    // Pas de verset aujourd'hui ou langue différente → en chercher un nouveau
    final verse = await _quranService.fetchRandomVerse(language: lang);
    await StorageService().saveDailyVerse({
      'arabicText': verse.arabicText,
      'translation': verse.translation,
      'surahNumber': verse.surahNumber,
      'surahNameArabic': verse.surahNameArabic,
      'surahNameEnglish': verse.surahNameEnglish,
      'verseNumber': verse.verseNumber,
      'globalVerseNumber': verse.globalVerseNumber,
      'audioUrl': verse.audioUrl,
      'language': lang,
    });
    return verse;
  }

  // Forcer un nouveau verset aléatoire (bouton refresh)
  Future<void> _refreshVerse() async {
    await _audioPlayer.stop();
    _currentAudioUrl = null;
    final lang = await StorageService().getLanguage();
    final verse = _quranService.fetchRandomVerse(language: lang);
    setState(() {
      _language = lang;
      _verseFuture = verse;
    });
  }

  // Afficher le sélecteur de sourate
  void _showSurahPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Choisir une sourate',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 114,
                    itemBuilder: (context, index) {
                      final surahNum = index + 1;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            '$surahNum',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(QuranService.surahNamesArabic[index]),
                        subtitle: Text(
                          '${QuranService.versesPerSurah[index]} versets',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _loadVerseFromSurah(surahNum);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Charger un verset d'une sourate spécifique
  Future<void> _loadVerseFromSurah(int surahNumber) async {
    await _audioPlayer.stop();
    _currentAudioUrl = null;
    setState(() {
      _verseFuture = _quranService.fetchVerseFromSurah(
        surahNumber: surahNumber,
        language: _language,
      );
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
              _refreshVerse();
            },
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _showSurahPicker(),
            icon: Icon(Icons.search, color: Colors.white),
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
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
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
                                  // Boutons favori et partage
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
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
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Verset ajouté aux favoris ⭐',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(width: 16),
                                      IconButton(
                                        icon: Icon(
                                          Icons.share,
                                          color: Colors.teal[700],
                                        ),
                                        onPressed: () async {
                                          final text =
                                              '${verse.arabicText}\n\n${verse.translation}\n\n— ${verse.surahNameEnglish} (${verse.surahNumber}:${verse.verseNumber})';

                                          // Sur mobile → menu de partage natif
                                          // Sur desktop/web → copie dans le presse-papier
                                          if (!kIsWeb &&
                                              (defaultTargetPlatform ==
                                                      TargetPlatform.android ||
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.iOS)) {
                                            await SharePlus.instance.share(
                                              ShareParams(text: text),
                                            );
                                          } else {
                                            await Clipboard.setData(
                                              ClipboardData(text: text),
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Verset copié ! 📋',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
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
