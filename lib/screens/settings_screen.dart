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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notif = await _storageService.getNotificationStatus();
    final dark = await _storageService.getDarkMode();
    setState(() {
      _notificationsEnabled = notif;
      _isDarkMode = dark;
    });
  }

  // Exporter les données
  Future<void> _exportData() async {
    final json = await _storageService.exportData();
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Données exportées dans le presse-papier !'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  // Nettoyer les anciennes données
  Future<void> _cleanOldData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🧹 Nettoyer les données'),
        content: Text(
          'Supprimer les méditations de plus de 90 jours ?\n\n'
          'Les favoris ne seront pas affectés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final count = await _storageService.deleteEntriesOlderThan(days: 90);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ $count entrée(s) supprimée(s)'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    }
  }

  // Supprimer toutes les données
  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Tout supprimer'),
        content: Text(
          'Cette action est irréversible !\n\n'
          'Toutes vos méditations, favoris et paramètres seront supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Tout supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ Toutes les données ont été supprimées'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paramètres')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Section Préférences
          Text(
            '⚙️ Préférences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('🔔 Notifications'),
                  subtitle: Text('Rappel quotidien à 8h'),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    await _storageService.saveNotification(value);
                    if (value) {
                      await NotificationService.scheduleDailyReminder();
                    } else {
                      await NotificationService.cancelAll();
                    }
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                Divider(height: 1),
                SwitchListTile(
                  title: Text('🌙 Mode sombre'),
                  subtitle: Text('Thème adapté pour la nuit'),
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
            '🗂️ Gestion des données',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.download, color: Colors.teal),
                  title: Text('Exporter mes données'),
                  subtitle: Text('Copie JSON dans le presse-papier'),
                  onTap: _exportData,
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.cleaning_services, color: Colors.orange),
                  title: Text('Nettoyer (+90 jours)'),
                  subtitle: Text('Supprime les anciennes méditations'),
                  onTap: _cleanOldData,
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Tout supprimer'),
                  subtitle: Text('Efface toutes les données'),
                  onTap: _deleteAllData,
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Section À propos
          Text(
            '📱 À propos',
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
                  title: Text('Tadabbur Daily'),
                  subtitle: Text('Version 1.0.0'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.auto_stories,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text('Source des versets'),
                  subtitle: Text('API Al-Quran Cloud'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
