import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
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
  double textSize = 28;
  Color textColor = Colors.white;
  double trimStart = 0;
  double trimEnd = 1;
  String selectedFilter = 'None';

  Future<void> _exportVideo() async {
    if (widget.videoPath == null) return;

    final input = widget.videoPath!;
    final output = '${input}_ultracut.mp4';

    final duration = _controller.value.duration.inMilliseconds / 1000.0;
    final start = trimStart * duration;
    final end = trimEnd * duration;
    final clipDuration = end - start;

    if (clipDuration <= 0) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exporting video...')),
      );
    }

    final command =
        '-y -ss $start -i "$input" -t $clipDuration -c:v libx264 -c:a aac "$output"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!mounted) return;

    if (returnCode != null && returnCode.isValueSuccess()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export complete: $output')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export failed')),
      );
    }
  }

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

  Widget _colorButton(Color color) {
    return IconButton(
      onPressed: () {
        setState(() => textColor = color);
      },
      icon: Icon(
        Icons.circle,
        color: color,
        size: 26,
      ),
    );
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_controller),
                          if (showTextOverlay)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              color: Colors.black54,
                              child: Text(
                                overlayText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: textSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
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

          // Text styling
          if (showTextOverlay)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_size, color: Colors.white),
                      Expanded(
                        child: Slider(
                          value: textSize,
                          min: 16,
                          max: 60,
                          divisions: 22,
                          onChanged: (value) {
                            setState(() => textSize = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _colorButton(Colors.white),
                      _colorButton(Colors.red),
                      _colorButton(Colors.yellow),
                      _colorButton(Colors.cyan),
                    ],
                  ),
                ],
              ),
            ),

          // Trim range
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trim',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RangeSlider(
                  values: RangeValues(trimStart, trimEnd),
                  min: 0,
                  max: 1,
                  onChanged: (values) {
                    setState(() {
                      trimStart = values.start;
                      trimEnd = values.end;
                    });
                  },
                ),
              ],
            ),
          ),

          // Filters
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                'None',
                'Bright',
                'Warm',
                'Cool',
                'Vintage',
                'B&W',
              ].map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selectedFilter == filter,
                    onSelected: (_) {
                      setState(() => selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

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
                onPressed: _exportVideo,
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
