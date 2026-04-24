import 'dart:math';
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
    // FIX 1 : Initialiser les fuseaux horaires
    tz_data.initializeTimeZones();

    // FIX 2 : Détecter et définir le fuseau horaire local du device
    final String timeZoneName = await _getDeviceTimeZone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);

    // Demander les permissions sur Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // FIX 3 : Demander la permission pour les alarmes exactes (Android 12+)
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  // Récupérer le fuseau horaire du device
  static Future<String> _getDeviceTimeZone() async {
    try {
      // Utilise DateTime pour détecter le fuseau horaire
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final hours = offset.inHours;
      final minutes = offset.inMinutes.remainder(60).abs();

      // Correspondance simple basée sur l'offset
      if (hours == 1 && minutes == 0) return 'Europe/Paris';
      if (hours == 2 && minutes == 0) return 'Europe/Paris'; // heure été
      if (hours == 0 && minutes == 0) return 'UTC';
      if (hours == -5 && minutes == 0) return 'America/New_York';

      // Fallback sur UTC si non reconnu
      return 'UTC';
    } catch (e) {
      return 'UTC';
    }
  }

  static Future<void> scheduleDailyReminder({
    int hour = 8,
    int minute = 0,
  }) async {
    // Annuler les notifications existantes avant de reprogrammer
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
      // FIX 4 : Utiliser exactAllowWhileIdle pour plus de fiabilité
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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