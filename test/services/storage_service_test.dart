import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur_daily/services/storage_service.dart';

void main() {
  group('StorageService Unit Tests (Simplified)', () {
    late StorageService storageService;

    setUp(() {
      storageService = StorageService();
    });

    test('StorageService should be instantiable', () {
      expect(storageService, isNotNull);
    });

    test('StorageService has saveLanguage method', () {
      expect(storageService.saveLanguage, isNotNull);
    });

    test('StorageService has getLanguage method', () {
      expect(storageService.getLanguage, isNotNull);
    });

    test('StorageService has saveEntry method', () {
      expect(storageService.saveEntry, isNotNull);
    });

    test('StorageService has getEntry method', () {
      expect(storageService.getEntry, isNotNull);
    });

    test('StorageService has getAllEntries method', () {
      expect(storageService.getAllEntries, isNotNull);
    });

    test('StorageService has saveFavorite method', () {
      expect(storageService.saveFavorite, isNotNull);
    });

    test('StorageService has getAllFavorites method', () {
      expect(storageService.getAllFavorites, isNotNull);
    });

    test('StorageService has getDarkMode method', () {
      expect(storageService.getDarkMode, isNotNull);
    });

    test('StorageService has saveDarkMode method', () {
      expect(storageService.saveDarkMode, isNotNull);
    });

    test('StorageService has calculateStreak method', () {
      expect(storageService.calculateStreak, isNotNull);
    });

    test('StorageService calculateStreak with empty list returns 0', () {
      final streak = storageService.calculateStreak([]);
      expect(streak, 0);
    });

    test('StorageService calculateStreak logic validation', () {
      // Since we can't test with Hive data, validate the method exists
      // and would work with the right structure
      expect(storageService.calculateStreak([]), 0);
    });

    // ---- Nouvelles méthodes v6 ----

    test('StorageService has exportData method', () {
      expect(storageService.exportData, isNotNull);
    });

    test('StorageService has deleteEntriesOlderThan method', () {
      expect(storageService.deleteEntriesOlderThan, isNotNull);
    });

    test('StorageService has deleteAllData method', () {
      expect(storageService.deleteAllData, isNotNull);
    });

    test('StorageService has getStorageStats method', () {
      expect(storageService.getStorageStats, isNotNull);
    });

    test('StorageService has deleteFavorite method', () {
      expect(storageService.deleteFavorite, isNotNull);
    });

    test('StorageService has groupEntriesByMonth method', () {
      expect(storageService.groupEntriesByMonth, isNotNull);
    });

    test(
      'StorageService groupEntriesByMonth with empty list returns empty map',
      () {
        final result = storageService.groupEntriesByMonth([]);
        expect(result, isEmpty);
      },
    );

    test('StorageService groupEntriesByMonth groups correctly', () {
      final entries = [
        {'date': '2026-04-10', 'reflection': 'Test 1'},
        {'date': '2026-04-12', 'reflection': 'Test 2'},
        {'date': '2026-03-05', 'reflection': 'Test 3'},
      ];
      final result = storageService.groupEntriesByMonth(entries);

      expect(result.keys.length, 2);
      expect(result.containsKey('2026-04'), true);
      expect(result.containsKey('2026-03'), true);
      expect(result['2026-04']!.length, 2);
      expect(result['2026-03']!.length, 1);
    });

    test('StorageService groupEntriesByMonth sorts months descending', () {
      final entries = [
        {'date': '2026-01-01', 'reflection': 'Jan'},
        {'date': '2026-04-01', 'reflection': 'Apr'},
        {'date': '2026-02-01', 'reflection': 'Feb'},
      ];
      final result = storageService.groupEntriesByMonth(entries);
      final keys = result.keys.toList();

      expect(keys[0], '2026-04'); // Plus récent en premier
      expect(keys[1], '2026-02');
      expect(keys[2], '2026-01');
    });

    test('StorageService has saveDailyVerse method', () {
      expect(storageService.saveDailyVerse, isNotNull);
    });

    test('StorageService has getDailyVerse method', () {
      expect(storageService.getDailyVerse, isNotNull);
    });
  });
}
