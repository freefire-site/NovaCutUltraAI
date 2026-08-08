import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class EditorScreen extends StatefulWidget {
  final String? videoPath;

  const EditorScreen({
    super.key,
    this.videoPath,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late VideoPlayerController _controller;

  String overlayText = '';
  bool showTextOverlay = false;

  void _addText() {
    final controller = TextEditingController(text: overlayText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B1B),
          title: const Text(
            'Add Text',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter text',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  overlayText = controller.text;
                  showTextOverlay = controller.text.trim().isNotEmpty;
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(
      File(widget.videoPath!),
    )..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _editorAction(
    IconData icon,
    String title, {
    VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed ?? () {},
      icon: Icon(icon),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('UltraCut Editor'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            icon: Icon(
              _controller.value.isPlaying
                  ? Icons.pause_circle
                  : Icons.play_circle,
              color: Colors.white,
              size: 55,
            ),
          ),

          if (_controller.value.isInitialized)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),

          const SizedBox(height: 10),

          // Volume
          Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.volume_up, color: Colors.white),
              Expanded(
                child: Slider(
                  value: _controller.value.volume,
                  min: 0,
                  max: 1,
                  onChanged: (value) {
                    _controller.setVolume(value);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),

          // Speed
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(Icons.speed, color: Colors.white),
              ),
              Expanded(
                child: Slider(
                  value: _controller.value.playbackSpeed,
                  min: 0.25,
                  max: 2.0,
                  divisions: 7,
                  label: '${_controller.value.playbackSpeed.toStringAsFixed(2)}x',
                  onChanged: (value) {
                    _controller.setPlaybackSpeed(value);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Trim & Edit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.content_cut, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Trim selection ready',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Editor actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _editorAction(
                    Icons.music_note,
                    'Audio',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _editorAction(
                    Icons.text_fields,
                    'Text',
                    onPressed: _addText,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _editorAction(
                    Icons.auto_awesome,
                    'Filter',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.undo),
                    label: const Text('Undo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.redo),
                    label: const Text('Redo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text('Export Video'),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
