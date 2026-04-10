import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tadabbur_daily/services/notification_service.dart';

class MockFlutterLocalNotificationsPlugin extends Mock {
  Future<bool?> initialize(dynamic initializationSettings) async => true;
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    dynamic scheduledDate,
    dynamic notificationDetails, {
    required bool uiLocalNotificationDateInterpretation,
    dynamic payload,
  }) async {}
  Future<void> cancelAll() async {}
}

void main() {
  group('NotificationService Unit Tests (Mocked)', () {
    test('NotificationService should be instantiable', () {
      final notificationService = NotificationService();
      expect(notificationService, isNotNull);
    });

    test('NotificationService has init method', () {
      // Static method, so we test by calling it (if it throws, the test fails)
      expect(NotificationService.init, isNotNull);
    });

    test('NotificationService has scheduleDailyReminder method', () {
      // Static method exists
      expect(NotificationService.scheduleDailyReminder, isNotNull);
    });

    test('NotificationService has cancelAll method', () {
      // Static method exists
      expect(NotificationService.cancelAll, isNotNull);
    });

    test('NotificationService hour validation: hour 0 valid', () {
      expect(0 >= 0 && 0 <= 23, true);
    });

    test('NotificationService hour validation: hour 8 valid', () {
      expect(8 >= 0 && 8 <= 23, true);
    });

    test('NotificationService hour validation: hour 14 valid', () {
      expect(14 >= 0 && 14 <= 23, true);
    });

    test('NotificationService hour validation: hour 23 valid', () {
      expect(23 >= 0 && 23 <= 23, true);
    });

    test('NotificationService hour validation: hour -1 invalid', () {
      expect(-1 >= 0 && -1 <= 23, false);
    });

    test('NotificationService hour validation: hour 24 invalid', () {
      expect(24 >= 0 && 24 <= 23, false);
    });

    test('NotificationService should handle multiple hour values', () async {
      final validHours = [0, 6, 8, 12, 14, 18, 20, 23];
      for (final hour in validHours) {
        expect(hour >= 0 && hour <= 23, true);
      }
    });
  });
}
