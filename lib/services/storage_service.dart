import 'package:hive/hive.dart';

class StorageService {
  static const String _boxName = 'journal_entries';

  // Ouvrir la boîte
  Future<Box> _getBox() async {
    return await Hive.openBox(_boxName);
  }

  // Sauvegarder une entrée
  // Clé = date + numéro du verset (ex: "2026-03-24_1234")
  // Permet plusieurs méditations par jour
  Future<void> saveEntry({
    required String date,
    required String reflection,
    required String identification,
    required String invocation,
    required int globalVerseNumber,
  }) async {
    final box = await _getBox();
    final key = '${date}_$globalVerseNumber';
    await box.put(key, {
      'date': date,
      'reflection': reflection,
      'identification': identification,
      'invocation': invocation,
      'globalVerseNumber': globalVerseNumber,
    });
  }

  // Récupérer une entrée par date
  Future<Map<String, dynamic>?> getEntry(String date) async {
    final box = await _getBox();
    return box.get(date);
  }

  // Récupérer toutes les entrées (exclure favoris et langue)
  Future<List<Map<String, dynamic>>> getAllEntries() async {
    final box = await _getBox();
    return box.keys
        .where(
          (key) =>
              !key.toString().startsWith('fav_') &&
              key != 'selected_language' &&
              key != 'notifications_enabled' &&
              key != 'dark_mode_enabled' &&
              key != 'daily_verse',
        )
        .map((key) => Map<String, dynamic>.from(box.get(key)))
        .toList();
  }

  int calculateStreak(List<Map<String, dynamic>> entries) {
    int streak = 0;
    DateTime currentDate = DateTime.now();

    var mySet = entries.map((e) => e['date']).toSet();
    while (mySet.contains(currentDate.toIso8601String().split('T')[0])) {
      streak++;
      currentDate = currentDate.subtract(Duration(days: 1));
    }

    return streak;
  }

  // Sauvegarder la langue choisie
  Future<void> saveLanguage(String language) async {
    final box = await _getBox();
    await box.put('selected_language', language);
  }

  // Récupérer la langue choisie
  Future<String> getLanguage() async {
    final box = await _getBox();
    return box.get('selected_language', defaultValue: 'fr');
  }

  // Sauvegarder un favori
  Future<void> saveFavorite(Map<String, dynamic> verse) async {
    // 1. Ouvrir la boîte
    final box = await _getBox();
    // 2. Générer une clé unique pour ce verset (ex: "fav_1234" où 1234 est le globalVerseNumber)
    final key = 'fav_${verse['globalVerseNumber']}';
    // 3. box.put(clé, verse)
    await box.put(key, verse);
  }

  // Récupérer tous les favoris
  Future<List<Map<String, dynamic>>> getAllFavorites() async {
    // 1. Ouvrir la boîte
    final box = await _getBox();
    // 2. Filtrer les valeurs dont la clé commence par 'fav_'
    return box.keys
        .where((key) => key.toString().startsWith('fav_'))
        .map((key) => Map<String, dynamic>.from(box.get(key)))
        .toList();
  }

  //sauvegarder les notifications
  Future<void> saveNotification(bool enabled) async {
    final box = await _getBox();
    await box.put('notifications_enabled', enabled);
  }

  Future<bool> getNotificationStatus() async {
    final box = await _getBox();
    return box.get('notifications_enabled', defaultValue: true);
  }

  Future<void> saveDarkMode(bool enabled) async {
    final box = await _getBox();
    await box.put('dark_mode_enabled', enabled);
  }

  Future<bool> getDarkMode() async {
    final box = await _getBox();
    return box.get('dark_mode_enabled', defaultValue: false);
  }

  // Sauvegarder le verset du jour
  Future<void> saveDailyVerse(Map<String, dynamic> verseData) async {
    final box = await _getBox();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await box.put('daily_verse', {'date': today, ...verseData});
  }

  // Récupérer le verset du jour (null si pas de verset aujourd'hui)
  Future<Map<String, dynamic>?> getDailyVerse() async {
    final box = await _getBox();
    final data = box.get('daily_verse');
    if (data == null) return null;
    final saved = Map<String, dynamic>.from(data);
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (saved['date'] == today) {
      return saved;
    }
    return null; // Verset périmé, il faut en charger un nouveau
  }

  // Exporter les données en JSON (backup)
  Future<String> exportData() async {
    final box = await _getBox();
    final entries = <dynamic>[];
    final favorites = <dynamic>[];

    // Récupérer toutes les entrées
    for (var key in box.keys) {
      if (key.toString().startsWith('fav_')) {
        favorites.add(box.get(key));
      } else if (!key.toString().startsWith('selected_') &&
          key != 'notifications_enabled' &&
          key != 'dark_mode_enabled') {
        entries.add(box.get(key));
      }
    }

    final data = {
      'entries': entries,
      'favorites': favorites,
      'exported_at': DateTime.now().toIso8601String(),
    };

    return data.toString(); // Ou utiliser json.encode() pour JSON valide
  }

  // Nettoyer les données plus anciennes que X jours (par défaut 90 jours)
  Future<int> deleteEntriesOlderThan({int days = 90}) async {
    final box = await _getBox();
    int deletedCount = 0;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    final keysToDelete = <String>[];
    for (var key in box.keys) {
      if (!key.toString().startsWith('fav_') &&
          key != 'selected_language' &&
          key != 'notifications_enabled' &&
          key != 'dark_mode_enabled') {
        try {
          final entryDate = DateTime.parse(key.toString());
          if (entryDate.isBefore(cutoffDate)) {
            keysToDelete.add(key.toString());
          }
        } catch (e) {
          // Ignorer les clés qui ne sont pas des dates valides
        }
      }
    }

    for (var key in keysToDelete) {
      await box.delete(key);
      deletedCount++;
    }

    return deletedCount;
  }

  // Supprimer toutes les données
  Future<void> deleteAllData() async {
    final box = await _getBox();
    await box.clear();
  }

  // Obtenir des statistiques sur les données stockées
  Future<Map<String, dynamic>> getStorageStats() async {
    final box = await _getBox();
    int entriesCount = 0;
    int favoritesCount = 0;
    DateTime? oldestEntry;
    DateTime? newestEntry;

    for (var key in box.keys) {
      if (key.toString().startsWith('fav_')) {
        favoritesCount++;
      } else if (!key.toString().startsWith('selected_') &&
          key != 'notifications_enabled' &&
          key != 'dark_mode_enabled') {
        entriesCount++;
        try {
          final entryDate = DateTime.parse(key.toString());
          oldestEntry ??= entryDate;
          if (entryDate.isBefore(oldestEntry)) {
            oldestEntry = entryDate;
          }
          newestEntry ??= entryDate;
          if (entryDate.isAfter(newestEntry)) {
            newestEntry = entryDate;
          }
        } catch (e) {
          // Ignorer
        }
      }
    }

    return {
      'total_entries': entriesCount,
      'total_favorites': favoritesCount,
      'oldest_entry': oldestEntry?.toIso8601String(),
      'newest_entry': newestEntry?.toIso8601String(),
    };
  }
}
