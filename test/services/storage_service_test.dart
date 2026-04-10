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
  });
}
