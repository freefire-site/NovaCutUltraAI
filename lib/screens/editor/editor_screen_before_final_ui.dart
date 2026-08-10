import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gal/gal.dart';
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
  double filterIntensity = 1.0;
  bool isExporting = false;
  final List<String> _editHistory = [];
  final List<String> _redoHistory = [];
  String? selectedAudioPath;

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedAudioPath = result.files.single.path;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio selected successfully'),
        ),
      );
    }
  }

  void _restoreHistoryState(String state) {
    if (!state.startsWith('filter:')) {
      return;
    }

    final parts = state.split('|');

    if (parts.length == 2) {
      final filter = parts[0].replaceFirst('filter:', '');
      final intensityText =
          parts[1].replaceFirst('intensity:', '');
      final intensity = double.tryParse(intensityText);

      if (intensity != null) {
        selectedFilter = filter;
        filterIntensity = intensity;
      }
    }
  }

  String _getVideoFilter() {
    final i = filterIntensity;

    switch (selectedFilter) {
      case 'Bright':
        return 'eq=brightness=${0.08 * i}:contrast=${1.0 + (0.05 * i)}';
      case 'Warm':
        return 'colorbalance=rs=${0.08 * i}:gs=${0.03 * i}:bs=${-0.05 * i}';
      case 'Cool':
        return 'colorbalance=rs=${-0.05 * i}:gs=${0.03 * i}:bs=${0.08 * i}';
      case 'Vintage':
        return 'eq=saturation=${1.0 - (0.25 * i)}:contrast=${1.0 - (0.1 * i)}';
      case 'B&W':
        return 'hue=s=${1.0 - i}';
      default:
        return 'null';
    }
  }

  Future<void> _exportVideo() async {
    if (widget.videoPath == null || isExporting) return;

    setState(() {
      isExporting = true;
    });

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

    final filter = _getVideoFilter();

    final command = selectedAudioPath != null
        ? '-y -ss $start -i "$input" -i "$selectedAudioPath" '
            '-t $clipDuration -map 0:v:0 -map 1:a:0 '
            '-vf "$filter" -c:v libx264 -c:a aac -shortest "$output"'
        : '-y -ss $start -i "$input" -t $clipDuration '
            '-vf "$filter" -c:v libx264 -c:a aac "$output"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!mounted) return;

    setState(() {
      isExporting = false;
    });

    if (returnCode != null && returnCode.isValueSuccess()) {
      try {
        await Gal.putVideo(
          output,
          album: 'UltraCut',
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video exported and saved to Gallery!'),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery save failed: $e')),
        );
      }
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
                  if (overlayText.isNotEmpty) {
                    _editHistory.add(overlayText);
                  }
                  _redoHistory.clear();

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
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Center(
                child: _controller.value.isInitialized
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        final videoSize = _controller.value.size;

                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: videoSize.width,
                              height: videoSize.height,
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
                            ),
                          ),
                        );
                      },
                    )
                  : const CircularProgressIndicator(),
              ),
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.timeline_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Timeline',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_controller.value.position.inSeconds}s / ${_controller.value.duration.inSeconds}s',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // Audio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickAudio,
                    icon: const Icon(Icons.music_note),
                    label: Text(
                      selectedAudioPath == null
                          ? 'Add Music'
                          : 'Music Selected',
                    ),
                  ),
                ),
                if (selectedAudioPath != null)
                  IconButton(
                    onPressed: () {
                      setState(() => selectedAudioPath = null);
                    },
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

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

          // CapCut-style Trim
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.content_cut_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Trim',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(trimStart * 100).round()}% - ${(trimEnd * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RangeSlider(
                  values: RangeValues(trimStart, trimEnd),
                  min: 0,
                  max: 1,
                  divisions: 100,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  onChanged: (values) {
                    setState(() {
                      trimStart = values.start;
                      trimEnd = values.end;
                    });

                    final duration = _controller.value.duration;
                    final start = duration * trimStart;

                    _controller.seekTo(start);
                  },
                ),
              ],
            ),
          ),

          // Filters
          // Filter intensity
          if (selectedFilter != 'None')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: Colors.white),
                  Expanded(
                    child: Slider(
                      value: filterIntensity,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      label: '${(filterIntensity * 100).round()}%',
                      onChanged: (value) {
                      setState(() {
                        _editHistory.add(
                          'filter:$selectedFilter|intensity:$filterIntensity',
                        );
                        _redoHistory.clear();
                        filterIntensity = value;
                      });
                    },
                    ),
                  ),
                ],
              ),
            ),

          // Undo / Redo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _editHistory.isEmpty
                    ? null
                    : () {
                        setState(() {
                          final state = _editHistory.removeLast();
                          _redoHistory.add(
                            'filter:$selectedFilter|intensity:$filterIntensity',
                          );
                          _restoreHistoryState(state);
                        });
                      },
                icon: const Icon(Icons.undo),
                label: const Text('Undo'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _redoHistory.isEmpty
                    ? null
                    : () {
                        setState(() {
                          final state = _redoHistory.removeLast();
                          _editHistory.add(
                            'filter:$selectedFilter|intensity:$filterIntensity',
                          );
                          _restoreHistoryState(state);
                        });
                      },
                icon: const Icon(Icons.redo),
                label: const Text('Redo'),
              ),
            ],
          ),

          if (isExporting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: LinearProgressIndicator(),
            ),

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
                      setState(() {
                        _editHistory.add(
                          'filter:$selectedFilter|intensity:$filterIntensity',
                        );
                        _redoHistory.clear();
                        selectedFilter = filter;
                      });
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
