import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const NovaCutUltraAI());
}

class NovaCutUltraAI extends StatelessWidget {
  const NovaCutUltraAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NovaCut Ultra AI',
      home: const HomeScreen(),
    );
  }
}
