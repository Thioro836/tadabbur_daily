import 'package:flutter/material.dart';
import 'package:tadabbur_daily/screens/home_screen.dart';

void main() {
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
      home: HomeScreen(),
    );
  }
}
