import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tadabbur_daily/screens/home_screen.dart';
import 'package:tadabbur_daily/screens/dashboard_screen.dart';
import 'package:tadabbur_daily/screens/favorites_screen.dart';
import 'package:tadabbur_daily/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await NotificationService.init();
  await NotificationService.scheduleDailyReminder(hour: 8, minute: 0);
  runApp(const TadabburApp());
}

class TadabburApp extends StatelessWidget {
  const TadabburApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tadabbur Daily',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.teal, // vert principal
          onPrimary: Colors.white,
          secondary: Color(0xFF00695C), // vert foncé accent
          onSecondary: Colors.white,
          background: Color(0xFFE0F2F1), // vert très clair
          onBackground: Color(0xFF222222),
          surface: Colors.white,
          onSurface: Colors.teal,
          error: Colors.red,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Color(0xFFE0F2F1), // vert très clair
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF00695C), // vert foncé accent
          unselectedItemColor: Colors.teal,
          selectedIconTheme: IconThemeData(color: Color(0xFF00695C), size: 28),
          unselectedIconTheme: IconThemeData(color: Colors.teal, size: 24),
          showUnselectedLabels: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Color(0xFF222222),
          displayColor: Color(0xFF00695C),
        ),
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

  final List<Widget> _screens = [
    HomeScreen(),
    DashboardScreen(),
    FavoriteScreen(),
  ];

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
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
        ],
      ),
    );
  }
}
