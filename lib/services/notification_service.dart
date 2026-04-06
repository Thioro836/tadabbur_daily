import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  // 1. Instance unique du plugin (Singleton pattern)
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Messages de rappel variés et inspirants
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

  // 2. Initialiser les notifications
  static Future<void> init() async {
    // Initialiser les fuseaux horaires
    tz_data.initializeTimeZones();

    // Configuration Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Configuration iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combiner les configurations
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialiser le plugin
    await _plugin.initialize(settings: initSettings);
  }

  // 3. Programmer une notification quotidienne
  static Future<void> scheduleDailyReminder({
    int hour = 8,
    int minute = 0,
  }) async {
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
  }

  // 4. Calculer la prochaine occurrence de l'heure choisie
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

    // Si l'heure est déjà passée aujourd'hui, programmer pour demain
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // 5. Annuler toutes les notifications
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
