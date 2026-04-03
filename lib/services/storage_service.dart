import 'package:hive/hive.dart';

class StorageService {
  static const String _boxName = 'journal_entries';

  // Ouvrir la boîte
  Future<Box> _getBox() async {
    return await Hive.openBox(_boxName);
  }

  // Sauvegarder une entrée
  // Clé = la date du jour (ex: "2026-03-24")
  // Valeur = un Map avec reflection, identification, invocation, globalVerseNumber
  Future<void> saveEntry({
    required String date,
    required String reflection,
    required String identification,
    required String invocation,
    required int globalVerseNumber,
  }) async {
    final box = await _getBox();
    await box.put(date, {
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

  // Récupérer toutes les entrées
  Future<List<Map<String, dynamic>>> getAllEntries() async {
    final box = await _getBox();
    return box.values.cast<Map<String, dynamic>>().toList();
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
}
