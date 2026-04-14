import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tadabbur_daily/main.dart';
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
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _entries = _storageService.getAllEntries();
    _loadNotificationStatus();
    _loadDarkModeStatus();
  }

  Future<void> _loadNotificationStatus() async {
    final enabled = await StorageService().getNotificationStatus();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _loadDarkModeStatus() async {
    final isDark = await StorageService().getDarkMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  // Graphique des 7 derniers jours
  Widget _buildWeeklyChart(List<Map<String, dynamic>> historique) {
    final now = DateTime.now();
    final days = <String>['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    // Compter les méditations par jour sur les 7 derniers jours
    final List<double> values = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final dateStr = date.toIso8601String().split('T')[0];
      return historique.where((e) => e['date'] == dateStr).length.toDouble();
    });

    final List<String> labels = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return days[date.weekday - 1];
    });

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📈 7 derniers jours',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: values
                      .reduce((a, b) => a > b ? a : b)
                      .clamp(1, 10)
                      .toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            labels[value.toInt()],
                            style: TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i],
                          color: values[i] > 0 ? Colors.teal : Colors.grey[300],
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                      // Graphique des 7 derniers jours
                      _buildWeeklyChart(historique),
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
                      SwitchListTile(
                        title: Text('🌙 Mode sombre'),
                        value: _isDarkMode,
                        onChanged: (value) async {
                          await StorageService().saveDarkMode(value);
                          TadabburApp.of(context)?.toggleTheme(value);
                          setState(() {
                            _isDarkMode = value;
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
