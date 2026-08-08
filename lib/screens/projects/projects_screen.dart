import 'package:flutter/material.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Projects'),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'No projects yet',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
