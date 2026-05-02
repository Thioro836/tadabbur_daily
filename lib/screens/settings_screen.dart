import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tadabbur_daily/main.dart';
import 'package:tadabbur_daily/services/notification_service.dart';
import 'package:tadabbur_daily/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;
  TimeOfDay _notificationTime = TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notif = await _storageService.getNotificationStatus();
    final dark = await _storageService.getDarkMode();
    final time = await _storageService.getNotificationTime();
    setState(() {
      _notificationsEnabled = notif;
      _isDarkMode = dark;
      _notificationTime = time;
    });
  }

  // Sélectionner l'heure de notification
  Future<void> _pickNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await _storageService.saveNotificationTime(picked);
      setState(() {
        _notificationTime = picked;
      });

      // Reprogrammer la notification avec la nouvelle heure
      if (_notificationsEnabled) {
        await NotificationService.scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏰ Notification programmée à ${picked.format(context)}'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    }
  }

  // Exporter les données
  Future<void> _exportData() async {
    final appState = TadabburApp.of(context);
    final localizations = appState?.languageProvider;

    final json = await _storageService.exportData();
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.get('exportedToClipboard') ??
                '✅ Données exportées dans le presse-papier !',
          ),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  // Nettoyer les anciennes données
  Future<void> _cleanOldData() async {
    final appState = TadabburApp.of(context);
    final localizations = appState?.languageProvider;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localizations?.get('cleanDataConfirm') ?? '🧹 Nettoyer les données',
        ),
        content: Text(
          localizations?.get('cleanDataMessage') ??
              'Supprimer les méditations de plus de 90 jours ?\n\n'
                  'Les favoris ne seront pas affectés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations?.get('cancel') ?? 'Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              localizations?.get('delete') ?? 'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final count = await _storageService.deleteEntriesOlderThan(days: 90);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations?.translate(
                    'entriesDeleted',
                    params: {'count': count.toString()},
                  ) ??
                  '🗑️ $count entrée(s) supprimée(s)',
            ),
            backgroundColor: Colors.teal,
          ),
        );
      }
    }
  }

  // Supprimer toutes les données
  Future<void> _deleteAllData() async {
    final appState = TadabburApp.of(context);
    final localizations = appState?.languageProvider;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localizations?.get('deleteAllConfirm') ?? '⚠️ Tout supprimer',
        ),
        content: Text(
          localizations?.get('deleteAllMessage') ??
              'Cette action est irréversible !\n\n'
                  'Toutes vos méditations, favoris et paramètres seront supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations?.get('cancel') ?? 'Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              localizations?.get('deleteAll') ?? 'Tout supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations?.get('allDataDeleted') ??
                  '🗑️ Toutes les données ont été supprimées',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = TadabburApp.of(context);
    final localizations = appState?.languageProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.get('settingsTitle') ?? 'Paramètres'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Section Préférences
          Text(
            localizations?.get('preferences') ?? '⚙️ Préférences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    localizations?.get('notifications') ?? '🔔 Notifications',
                  ),
                  subtitle: Text(
                    'Rappel quotidien à ${_notificationTime.format(context)}',
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    await _storageService.saveNotification(value);
                    if (value) {
                      await NotificationService.scheduleDailyReminder(
                        hour: _notificationTime.hour,
                        minute: _notificationTime.minute,
                      );
                    } else {
                      await NotificationService.cancelAll();
                    }
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                // Sélecteur d'heure (visible seulement si notifs activées)
                if (_notificationsEnabled) ...[
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.access_time, color: Colors.teal),
                    title: Text('Heure du rappel'),
                    subtitle: Text(_notificationTime.format(context)),
                    onTap: _pickNotificationTime,
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
                Divider(height: 1),
                SwitchListTile(
                  title: Text(
                    localizations?.get('darkMode') ?? '🌙 Mode sombre',
                  ),
                  subtitle: Text(
                    localizations?.get('darkModeDesc') ??
                        'Thème adapté pour la nuit',
                  ),
                  value: _isDarkMode,
                  onChanged: (value) async {
                    await _storageService.saveDarkMode(value);
                    TadabburApp.of(context)?.toggleTheme(value);
                    setState(() {
                      _isDarkMode = value;
                    });
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Section Gestion des données
          Text(
            localizations?.get('dataManagement') ?? '🗂️ Gestion des données',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.download, color: Colors.teal),
                  title: Text(
                    localizations?.get('exportData') ?? 'Exporter mes données',
                  ),
                  subtitle: Text(
                    localizations?.get('exportDataDesc') ??
                        'Copie JSON dans le presse-papier',
                  ),
                  onTap: _exportData,
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.cleaning_services, color: Colors.orange),
                  title: Text(
                    localizations?.get('cleanData') ?? 'Nettoyer (+90 jours)',
                  ),
                  subtitle: Text(
                    localizations?.get('cleanDataDesc') ??
                        'Supprime les anciennes méditations',
                  ),
                  onTap: _cleanOldData,
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(
                    localizations?.get('deleteAll') ?? 'Tout supprimer',
                  ),
                  subtitle: Text(
                    localizations?.get('deleteAllDesc') ??
                        'Efface toutes les données',
                  ),
                  onTap: _deleteAllData,
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Section À propos
          Text(
            localizations?.get('about') ?? '📱 À propos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    localizations?.get('appName') ?? 'Tadabbur Daily',
                  ),
                  subtitle: Text(
                    localizations?.get('version') ?? 'Version 1.0.1',
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.auto_stories,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    localizations?.get('verseSource') ?? 'Source des versets',
                  ),
                  subtitle: Text(
                    localizations?.get('verseSourceAPI') ??
                        'API Al-Quran Cloud',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}