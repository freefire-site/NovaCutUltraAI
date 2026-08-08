import 'package:flutter/material.dart';

class AiToolsScreen extends StatelessWidget {
  const AiToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AI Tools'),
        backgroundColor: Colors.black,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: const [
          _Tool(Icons.auto_awesome, 'AI Video'),
          _Tool(Icons.image, 'AI Image'),
          _Tool(Icons.auto_fix_high, 'AI Enhance'),
          _Tool(Icons.subtitles, 'AI Captions'),
        ],
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  final IconData icon;
  final String title;

  const _Tool(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFF181818),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 36),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
