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

  /// 1. INITIALISATION SILENCIEUSE
  /// À appeler dans le main() - Ne déclenche aucune pop-up
  static Future<void> init() async {
    tz_data.initializeTimeZones();

    final String timeZoneName = await _getDeviceTimeZone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // FIX : Tout à 'false' pour iOS afin d'éviter l'écran noir au démarrage
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // FIX : On remet le paramètre nommé "settings:" (comme tu l'avais très bien fait au début !)
    await _plugin.initialize(settings: initSettings);
  }

  /// 2. DEMANDE DE PERMISSIONS
  /// À appeler une fois l'UI chargée (ex: dans initState de l'écran d'accueil)
  static Future<void> requestPermissions() async {
    // Demander les permissions classiques sur Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Demander les permissions explicites sur iOS
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    // NOTE: Plus de demande pour les alarmes exactes (requestExactAlarmsPermission)
  }

  /// 3. DÉTECTION DU FUSEAU HORAIRE
  static Future<String> _getDeviceTimeZone() async {
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final hours = offset.inHours;
      final minutes = offset.inMinutes.remainder(60).abs();

      if (hours == 1 && minutes == 0) return 'Europe/Paris';
      if (hours == 2 && minutes == 0) return 'Europe/Paris'; // heure été
      if (hours == -5 && minutes == 0) return 'America/New_York';

      return 'UTC';
    } catch (e) {
      return 'UTC';
    }
  }

  /// 4. PROGRAMMATION DU RAPPEL QUOTIDIEN
  static Future<void> scheduleDailyReminder({
    int hour = 8,
    int minute = 0,
  }) async {

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
  }
  /// 5. CALCUL DU PROCHAIN HORAIRE
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

  /// 6. ANNULATION DE TOUTES LES NOTIFICATIONS
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}