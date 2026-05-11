import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final List<String> _reminderMessages = [
    'Une parole divine t\'attend… ouvre ton cœur 🤲',
    'Le Coran guérit ce que les mots ne peuvent atteindre 🌿',
    'Quelques minutes avec Allah suffisent à illuminer ta journée ☀️',
    'Ton âme a soif… viens te ressourcer 💧',
    'Chaque verset est une lettre d\'amour de ton Créateur 💌',
    'Le silence du matin est parfait pour écouter Sa parole 🌅',
    'Un verset médité vaut mille lus sans réflexion 📖',
    'Allah t\'a réservé un message aujourd\'hui… viens le découvrir ✨',
    'Tadabbur : quand le Coran te parle personnellement 🫀',
    'Prends un instant… ton Seigneur t\'appelle doucement 🕊️',
  ];

  static String _getRandomMessage() {
    final random = Random();
    return _reminderMessages[random.nextInt(_reminderMessages.length)];
  }

  static Future<void> init() async {
    try {
      tz_data.initializeTimeZones();

      String timeZoneName = 'UTC';
      try {
        final dynamic timezoneInfo = await FlutterTimezone.getLocalTimezone().timeout(
          const Duration(seconds: 2),
        );
        if (timezoneInfo is String) {
          timeZoneName = timezoneInfo;
        } else {
          timeZoneName = timezoneInfo.identifier;
        }
      } catch (e) {
        debugPrint('NotificationService timezone error: $e');
      }

      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint(
          'NotificationService setLocalLocation error: $e; falling back to UTC',
        );
        tz.setLocalLocation(tz.UTC);
      }

      debugPrint(
        'NotificationService init timezone: $timeZoneName, local=${tz.local.name}',
      );

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _plugin.initialize(
        settings: InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  static Future<void> requestPermissions() async {
    // Demande pour Android 13+
    try {
      final bool? androidGranted = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      debugPrint('Android notification permission granted: $androidGranted');
    } catch (e) {
      debugPrint('Erreur demande permission Android: $e');
    }

    // Demande explicite pour iOS
    try {
      final bool? iosGranted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      debugPrint('iOS notification permission granted: $iosGranted');
    } catch (e) {
      debugPrint('Erreur demande permission iOS: $e');
    }
  }

  static Future<void> scheduleDailyReminder({
    int hour = 8,
    int minute = 0,
  }) async {
    try {
      await _plugin.cancel(id: 0);

      final scheduledDate = _nextInstanceOfTime(hour, minute);
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Rappel quotidien',
          channelDescription: 'Rappel quotidien pour méditer',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      try {
        await _plugin.zonedSchedule(
          id: 0,
          title: '🌙 Tadabbur Daily',
          body: _getRandomMessage(),
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } on PlatformException catch (e) {
        debugPrint(
          'scheduleDailyReminder exact alarm failed: ${e.code} - ${e.message}',
        );
        if (e.code == 'exact_alarms_not_permitted') {
          await _plugin.zonedSchedule(
            id: 0,
            title: '🌙 Tadabbur Daily',
            body: _getRandomMessage(),
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
          );
          debugPrint(
            'scheduleDailyReminder fallback to inexact schedule succeeded',
          );
        } else {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('scheduleDailyReminder error: $e');
    }
    debugPrint('TZ local: ${tz.local.name}');
    debugPrint('Scheduled at: ${_nextInstanceOfTime(hour, minute)}');
    debugPrint('Now: ${tz.TZDateTime.now(tz.local)}');
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
