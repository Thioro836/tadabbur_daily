import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tadabbur_daily/screens/home_screen.dart';
import 'package:tadabbur_daily/screens/dashboard_screen.dart';
import 'package:tadabbur_daily/screens/favorites_screen.dart';
import 'package:tadabbur_daily/screens/settings_screen.dart';
import 'package:tadabbur_daily/services/notification_service.dart';
import 'package:tadabbur_daily/services/storage_service.dart';
import 'package:tadabbur_daily/services/language_provider.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive en premier
  await Hive.initFlutter();

  // Initialiser les notifications
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Erreur init notifications: $e');
  }

 
  // Précharger la police Amiri pour éviter les carrés
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.amiri(),
    ]).timeout(Duration(seconds: 3));
  } catch (e) {
    // Continuer sans la police si pas de connexion
    debugPrint('Erreur police: $e');
  }

  runApp(const TadabburApp());
}

class TadabburApp extends StatefulWidget {
  const TadabburApp({super.key});

  // Méthode statique pour accéder au State depuis n'importe où
  static _TadabburAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_TadabburAppState>();
  }

  @override
  State<TadabburApp> createState() => _TadabburAppState();
}

class _TadabburAppState extends State<TadabburApp> {
  bool _isDarkMode = false;
  late LanguageProvider _languageProvider;

  @override
  void initState() {
    super.initState();
    _languageProvider = LanguageProvider();
    _languageProvider.addListener(_onLanguageChanged);
    _loadTheme();
    _initializeLanguage();
  }

  Future<void> _initializeLanguage() async {
    await _languageProvider.initializeLanguage();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _languageProvider.removeListener(_onLanguageChanged);
    _languageProvider.dispose();
    super.dispose();
  }

  Future<void> _loadTheme() async {
    final isDark = await StorageService().getDarkMode();
    if (mounted) {
      setState(() {
        _isDarkMode = isDark;
      });
    }
  }

  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  Future<void> changeLanguage(String language) async {
    await _languageProvider.setLanguage(language);
  }

  LanguageProvider get languageProvider => _languageProvider;

  // ---- THÈME CLAIR ----
  ThemeData get _lightTheme => ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.teal,
      onPrimary: Colors.white,
      secondary: Color(0xFF00695C),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.teal,
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Color(0xFFE0F2F1),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF00695C),
      unselectedItemColor: Colors.teal,
      selectedIconTheme: IconThemeData(color: Color(0xFF00695C), size: 28),
      unselectedIconTheme: IconThemeData(color: Colors.teal, size: 24),
      showUnselectedLabels: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Color(0xFF222222),
      displayColor: Color(0xFF00695C),
    ),
  );

  // ---- THÈME SOMBRE ----
  ThemeData get _darkTheme => ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.teal[300]!,
      onPrimary: Colors.black,
      secondary: Colors.tealAccent,
      onSecondary: Colors.black,
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.teal[200]!,
      error: Colors.redAccent,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.teal[200],
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Colors.tealAccent,
      unselectedItemColor: Colors.teal[200],
      selectedIconTheme: IconThemeData(color: Colors.tealAccent, size: 28),
      unselectedIconTheme: IconThemeData(color: Colors.teal[200], size: 24),
      showUnselectedLabels: true,
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF2C2C2C),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: Color(0xFFE0E0E0), displayColor: Colors.tealAccent),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tadabbur Daily',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
    SettingsScreen(),
  ];
  @override
  void initState() {
    super.initState();
    // L'UI est prête, on gère les notifications en arrière-plan
    _setupNotifications();
  }
  Future<void> _setupNotifications() async {
    try {
      // 1. On demande la permission de base (sans l'alarme exacte)
      await NotificationService.requestPermissions();

      // 2. On vérifie les préférences et on programme
      final storage = StorageService();
      final notificationsEnabled = await storage.getNotificationStatus();
      
      if (notificationsEnabled) {
        await NotificationService.scheduleDailyReminder(hour: 8, minute: 0);
      }
    } catch (e) {
      debugPrint('Erreur lors du setup des notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = TadabburApp.of(context);
    final localizations = appState?.languageProvider;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: localizations?.get('home') ?? 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: localizations?.get('dashboard') ?? 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: localizations?.get('favorites') ?? 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: localizations?.get('settings') ?? 'Paramètres',
          ),
        ],
      ),
    );
  }
}
