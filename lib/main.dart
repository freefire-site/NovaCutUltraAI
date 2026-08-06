import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'screens/home_screen.dart';

void main() {
  runApp(const UltraCutApp());
}

class UltraCutApp extends StatelessWidget {
  const UltraCutApp({super.key});
=======
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const NovaCutUltraAI());
}

class NovaCutUltraAI extends StatelessWidget {
  const NovaCutUltraAI({super.key});
>>>>>>> 1989033bc11077ab029cb021f09ee2ede67a5ed3

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      title: 'UltraCut',
      theme: ThemeData.dark(),
=======
      title: 'NovaCut Ultra AI',
      theme: AppTheme.darkTheme,
>>>>>>> 1989033bc11077ab029cb021f09ee2ede67a5ed3
      home: const HomeScreen(),
    );
  }
}
<<<<<<< HEAD

=======
>>>>>>> 1989033bc11077ab029cb021f09ee2ede67a5ed3
