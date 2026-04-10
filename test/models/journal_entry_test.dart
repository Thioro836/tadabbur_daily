import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur_daily/models/journal_entry.dart';

void main() {
  group('JournalEntry Model Tests', () {
    test('JournalEntry should create instance with required properties', () {
      final now = DateTime.now();
      final entry = JournalEntry(
        id: '1',
        reflection: 'This verse teaches me about gratitude',
        identification: 'I identify with the call to patience',
        invocation: 'O Allah, grant me patience',
        date: now,
        globalVerseNumber: 1,
        isCompleted: true,
      );

      expect(entry.id, '1');
      expect(entry.reflection, 'This verse teaches me about gratitude');
      expect(entry.identification, 'I identify with the call to patience');
      expect(entry.invocation, 'O Allah, grant me patience');
      expect(entry.globalVerseNumber, 1);
      expect(entry.isCompleted, true);
      expect(entry.date, now);
    });

    test('JournalEntry should have default empty strings for reflection', () {
      final now = DateTime.now();
      final entry = JournalEntry(id: '2', date: now, globalVerseNumber: 2);

      expect(entry.reflection, '');
      expect(entry.identification, '');
      expect(entry.invocation, '');
      expect(entry.isCompleted, false);
    });

    test(
      'JournalEntry copyWith should create new instance with updated values',
      () {
        final now = DateTime.now();
        final entry = JournalEntry(
          id: '1',
          reflection: 'Original reflection',
          date: now,
          globalVerseNumber: 1,
        );

        final updatedEntry = entry.copyWith(
          reflection: 'Updated reflection',
          isCompleted: true,
        );

        expect(updatedEntry.reflection, 'Updated reflection');
        expect(updatedEntry.isCompleted, true);
        expect(updatedEntry.id, '1');
        expect(updatedEntry.globalVerseNumber, 1);
      },
    );

    test('JournalEntry copyWith should preserve original instance', () {
      final now = DateTime.now();
      final entry = JournalEntry(
        id: '1',
        reflection: 'Original reflection',
        date: now,
        globalVerseNumber: 1,
      );

      final updatedEntry = entry.copyWith(reflection: 'New reflection');

      expect(entry.reflection, 'Original reflection');
      expect(updatedEntry.reflection, 'New reflection');
    });

    test('JournalEntry copyWith with null values should not override', () {
      final now = DateTime.now();
      final entry = JournalEntry(
        id: '1',
        reflection: 'Test',
        identification: 'Test ID',
        date: now,
        globalVerseNumber: 1,
      );

      final updated = entry.copyWith();

      expect(updated.reflection, 'Test');
      expect(updated.identification, 'Test ID');
      expect(updated.id, '1');
    });

    test('Multiple JournalEntry instances should be independent', () {
      final now = DateTime.now();
      final entry1 = JournalEntry(
        id: '1',
        reflection: 'Entry 1',
        date: now,
        globalVerseNumber: 1,
      );

      final entry2 = JournalEntry(
        id: '2',
        reflection: 'Entry 2',
        date: now.add(const Duration(days: 1)),
        globalVerseNumber: 2,
      );

      expect(entry1.id, '1');
      expect(entry2.id, '2');
      expect(entry1.reflection, 'Entry 1');
      expect(entry2.reflection, 'Entry 2');
    });
  });
}
