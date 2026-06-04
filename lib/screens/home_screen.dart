// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tadabbur_daily/models/verse.dart';
import 'package:tadabbur_daily/services/quran_service.dart';
import 'package:tadabbur_daily/screens/journal_screen.dart';
import 'package:tadabbur_daily/services/storage_service.dart';
import 'package:tadabbur_daily/main.dart';
import 'package:tadabbur_daily/services/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Set<int> _favoriteVerseNumbers = {};

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
    await _loadFavorites();
    setState(() {
      _language = lang;
      _verseFuture = _loadDailyVerse(lang);
    });
  }

  // Charge le verset du jour depuis le cache, ou un nouveau si périmé
  Future<Verse> _loadDailyVerse(String lang) async {
    // Vérifier d'abord si on a un verset pour aujourd'hui (indépendamment de la langue)
    final savedAny = await StorageService().getDailyVerseAnyLanguage();
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (savedAny != null && savedAny['date'] == today) {
      // On a déjà un verset pour aujourd'hui, on le garde mais on met à jour la traduction
      final verse = Verse(
        arabicText: savedAny['arabicText'],
        translation: savedAny['translation'],
        surahNumber: savedAny['surahNumber'],
        surahNameArabic: savedAny['surahNameArabic'],
        surahNameEnglish: savedAny['surahNameEnglish'],
        verseNumber: savedAny['verseNumber'],
        globalVerseNumber: savedAny['globalVerseNumber'],
        audioUrl: savedAny['audioUrl'],
      );
      // Mettre à jour la traduction si la langue a changé
      if (savedAny['language'] != lang) {
        final translatedVerse = await _quranService.fetchSpecificVerse(
          verse.globalVerseNumber,
          language: lang,
        );
        await StorageService().saveDailyVerse({
          'arabicText': translatedVerse.arabicText,
          'translation': translatedVerse.translation,
          'surahNumber': translatedVerse.surahNumber,
          'surahNameArabic': translatedVerse.surahNameArabic,
          'surahNameEnglish': translatedVerse.surahNameEnglish,
          'verseNumber': translatedVerse.verseNumber,
          'globalVerseNumber': translatedVerse.globalVerseNumber,
          'audioUrl': translatedVerse.audioUrl,
          'language': lang,
        });
        return translatedVerse;
      }
      return verse;
    }
    // Pas de verset aujourd'hui → en chercher un nouveau
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

  Future<void> _loadFavorites() async {
    final favorites = await StorageService().getAllFavorites();
    if (!mounted) return;
    setState(() {
      _favoriteVerseNumbers = favorites
          .map((entry) => entry['globalVerseNumber'] as int)
          .toSet();
    });
  }

  Future<void> _toggleFavorite(Verse verse) async {
    final isFavorite = _favoriteVerseNumbers.contains(verse.globalVerseNumber);
    final appState = TadabburApp.of(context);
    final localizations = appState?.languageProvider;
    final messenger = ScaffoldMessenger.of(context);

    if (isFavorite) {
      await StorageService().deleteFavorite(verse.globalVerseNumber);
    } else {
      await StorageService().saveFavorite({
        'globalVerseNumber': verse.globalVerseNumber,
        'surahNameEnglish': verse.surahNameEnglish,
        'surahNameArabic': verse.surahNameArabic,
        'surahNumber': verse.surahNumber,
        'verseNumber': verse.verseNumber,
        'arabicText': verse.arabicText,
        'translation': verse.translation,
      });
    }
    await _loadFavorites();
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'Verset supprimé des favoris 💔'
              : localizations?.get('verseAddedToFavorites') ??
                    'Verset ajouté aux favoris ⭐',
        ),
      ),
    );
  }

  // Afficher le sélecteur de sourate
  void _showSurahPicker(LanguageProvider? localizations) {
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
                    localizations?.get('chooseSurah') ?? 'Choisir une sourate',
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
                          '${QuranService.versesPerSurah[index]} ${localizations?.get('verses') ?? 'versets'}',
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

  // Charger un verset d'une sourate spécifique (limité à 1 par jour)
  Future<void> _loadVerseFromSurah(int surahNumber) async {
    await _audioPlayer.stop();
    _currentAudioUrl = null;

    // Charger le premier verset de la sourate
    final verse = await _quranService.fetchVerseFromSurah(
      surahNumber: surahNumber,
      language: _language,
    );

    // Sauvegarder comme verset du jour (limite à 1 par jour)
    await StorageService().saveDailyVerse({
      'arabicText': verse.arabicText,
      'translation': verse.translation,
      'surahNumber': verse.surahNumber,
      'surahNameArabic': verse.surahNameArabic,
      'surahNameEnglish': verse.surahNameEnglish,
      'verseNumber': verse.verseNumber,
      'globalVerseNumber': verse.globalVerseNumber,
      'audioUrl': verse.audioUrl,
      'language': _language,
    });

    setState(() {
      _verseFuture = Future.value(verse);
    });
  }
  Future<void> _openTafsir(Verse verse) async {
  final url = Uri.parse(
    'https://quran.com/${verse.surahNumber}/${verse.verseNumber}'
  );
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

  // Widget skeleton pour le chargement
  Widget _buildShimmerSkeleton(LanguageProvider? localizations) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            margin: EdgeInsets.symmetric(vertical: 24, horizontal: 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Reference skeleton
                  Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Arabic text skeleton
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 24,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Translation skeleton
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Buttons skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 16),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 16),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
    final appState = TadabburApp.of(context);
    final localizations = appState?.languageProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.get('homeTitle') ?? 'Verset du jour'),
       actions: [
  PopupMenuButton<String>(
    icon: const Icon(Icons.language, color: Colors.white),
    onSelected: (value) async {
      if (value == _language) return;

      await appState?.changeLanguage(value);

      setState(() {
        _language = value;
      });

      _loadVerse();
    },
    itemBuilder: (context) => const [
      PopupMenuItem(
        value: 'fr',
        child: Text('Français'),
      ),
      PopupMenuItem(
        value: 'en',
        child: Text('English'),
      ),
    ],
  ),
  IconButton(
    onPressed: () => _showSurahPicker(localizations),
    icon: const Icon(Icons.search, color: Colors.white),
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
                _buildShimmerSkeleton(localizations)
              else
                FutureBuilder<Verse>(
                  future: _verseFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerSkeleton(localizations);
                    }
                    if (snapshot.hasError) {
                      return Text(localizations?.get('error') ?? 'Erreur !');
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
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      height: 2.2,
                                    ),
                                  ),
                                  SizedBox(height: 18),
                                  Divider(
                                    thickness: 1,
                                    color: Theme.of(context).colorScheme.primary
                                        .withAlpha((0.3 * 255).round()),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    verse.translation,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha((0.85 * 255).round()),
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
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
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
                                          _favoriteVerseNumbers.contains(
                                                verse.globalVerseNumber,
                                              )
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              _favoriteVerseNumbers.contains(
                                                verse.globalVerseNumber,
                                              )
                                              ? Colors.red
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        ),
                                        onPressed: () async {
                                          await _toggleFavorite(verse);
                                        },
                                      ),
                                       SizedBox(width: 16),
                                      Center(
                                      child: TextButton.icon(
                                        icon: Icon(Icons.menu_book, color: Colors.teal[700]),
                                        label: Text(
                                          'Lire le Tafsir',
                                          style: TextStyle(color: Colors.teal[700]),
                                        ),
                                        onPressed: () => _openTafsir(verse),
                                      ),
                                    ),
                                      SizedBox(width: 16),
                                      IconButton(
                                        icon: Icon(
                                          Icons.share,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        onPressed: () async {
                                          final text =
                                              '🕌 *Tadabbur Daily*\n\n'
                                              '${verse.arabicText}\n\n'
                                              '━━━━━━━━━━━━━━━━━━━━\n'
                                              '${verse.translation}\n\n'
                                              '— ${verse.surahNameEnglish} (${verse.surahNumber}:${verse.verseNumber})\n\n'
                                              '✨';

                                          // Sur mobile → menu de partage natif
                                          // Sur desktop/web → copie dans le presse-papier
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          final copiedMessage =
                                              localizations?.get(
                                                'verseCopied',
                                              ) ??
                                              'Verset copié ! 📋';
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
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(copiedMessage),
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
                            child: Text(
                              localizations?.get('journal') ?? 'Méditer',
                            ),
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
