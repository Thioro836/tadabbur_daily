import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tadabbur_daily/screens/home_screen.dart';
import 'package:tadabbur_daily/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const TadabburApp());
}

class TadabburApp extends StatelessWidget {
  const TadabburApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tadabbur Daily',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [HomeScreen(), DashboardScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Verset'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Parcours',
          ),
        ],
      ),
    );
  }
}
