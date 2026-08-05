import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const UltraCutAI());
}

class UltraCutAI extends StatelessWidget {
  const UltraCutAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UltraCut AI',
      home: const SplashScreen(),
    );
  }
}
