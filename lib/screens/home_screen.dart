import 'package:flutter/material.dart';

void main() {
  runApp(const NovaCutApp());
}

class NovaCutApp extends StatelessWidget {
  const NovaCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NovaCut Ultra AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('NovaCut Ultra AI'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create amazing videos easily.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('📁 Import Video'),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('✂️ Trim Video'),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('🎨 AI Effects'),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('🤖 AI Video Generator'),
              ),
            ),            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('✨ Auto Edit AI'),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'NovaCut Ultra AI',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
