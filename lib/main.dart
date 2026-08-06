import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const UltraCutApp());
}

class UltraCutApp extends StatelessWidget {
  const UltraCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UltraCut',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

