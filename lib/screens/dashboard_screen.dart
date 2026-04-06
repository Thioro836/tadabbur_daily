import 'package:flutter/material.dart';
import 'package:tadabbur_daily/models/verse.dart';
import 'package:tadabbur_daily/services/notification_service.dart';
import 'package:tadabbur_daily/services/storage_service.dart';
import 'package:tadabbur_daily/screens/journal_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storageService = StorageService();
  late Future<List<Map<String, dynamic>>> _entries;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _entries = _storageService.getAllEntries();
    _loadNotificationStatus();
  }

  Future<void> _loadNotificationStatus() async {
    final enabled = await StorageService().getNotificationStatus();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mon Parcours')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _entries,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Erreur !');
                  }
                  final historique = snapshot.data!;
                  if (historique.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune méditation pour le moment.\nCommencez par méditer un verset ! 🌙',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Text(
                        '🔥 Streak : ${_storageService.calculateStreak(historique)} jours',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '📖 Total méditations : ${historique.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      SwitchListTile(
                        title: Text('🔔 Notifications'),
                        value: _notificationsEnabled,
                        onChanged: (value) async {
                          await StorageService().saveNotification(value);
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: historique.length,
                        itemBuilder: (context, index) {
                          final entry = historique[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JournalScreen(
                                    verse: Verse(
                                      arabicText: '',
                                      translation: '',
                                      surahNumber: 0,
                                      surahNameArabic: '',
                                      surahNameEnglish: '',
                                      verseNumber: 0,
                                      globalVerseNumber:
                                          entry['globalVerseNumber'],
                                    ),
                                    initialReflection: entry['reflection'],
                                    initialIdentification:
                                        entry['identification'],
                                    initialInvocation: entry['invocation'],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              child: ListTile(
                                title: Text(entry['date']),
                                subtitle: Text(entry['reflection']),
                                trailing: Icon(Icons.edit, color: Colors.teal),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
