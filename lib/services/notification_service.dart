import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

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

      // Détecter le fuseau horaire de manière sécurisée
      final offset = DateTime.now().timeZoneOffset;
      final hours = offset.inHours;
      String timeZoneName = 'UTC';
      if (hours == 1) timeZoneName = 'Europe/Paris';
      if (hours == 2) timeZoneName = 'Europe/Paris'; // heure été

      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        tz.setLocalLocation(tz.UTC);
      }

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // 🔴 MODIFICATION IMPORTANTE ICI : Tout mettre à false !
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, 
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(settings: initSettings);

      // 🔴 SUPPRIME le bloc "Demander les permissions sur Android 13+" qui était ici.
      // Il est maintenant géré par requestPermissions() !

    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }
  static Future<void> requestPermissions() async {
    // Demande pour Android 13+
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Erreur demande permission Android: $e');
    }

    // Demande explicite pour iOS
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
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

      await _plugin.zonedSchedule(
        id: 0,
        title: '🌙 Tadabbur Daily',
        body: _getRandomMessage(),
        scheduledDate: _nextInstanceOfTime(hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Rappel quotidien',
            channelDescription: 'Rappel quotidien pour méditer',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('scheduleDailyReminder error: $e');
    }
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