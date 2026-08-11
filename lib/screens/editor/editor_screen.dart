import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:video_player/video_player.dart';

class EditorScreen extends StatefulWidget {
  final String? videoPath;

  const EditorScreen({super.key, this.videoPath});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late VideoPlayerController _controller;

  String overlayText = '';
  bool showTextOverlay = false;
  String selectedFilter = 'None';
  String? selectedAudioPath;

  double textSize = 28;
  Color textColor = Colors.white;
  double trimStart = 0;
  double trimEnd = 1;
  bool isExporting = false;

  final List<String> _history = [];
  final List<String> _redo = [];

  @override
  void initState() {
    super.initState();

    if (widget.videoPath != null) {
      _controller = VideoPlayerController.file(File(widget.videoPath!))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        });

      _controller.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedAudioPath = result.files.single.path;
        _history.add('audio');
        _redo.clear();
      });
    }
  }

  void _addText() {
    final textController = TextEditingController(text: overlayText);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1F),
        title: const Text('Add Text', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter text',
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurpleAccent),
            ),
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
                overlayText = textController.text;
                showTextOverlay = overlayText.trim().isNotEmpty;
                _history.add('text');
                _redo.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    final filters = ['None', 'Bright', 'Warm', 'Cool', 'Vintage', 'B&W'];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF17171B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: filters.map((filter) {
              final selected = selectedFilter == filter;

              return ChoiceChip(
                label: Text(filter),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    selectedFilter = filter;
                    _history.add('filter:$filter');
                    _redo.clear();
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _undo() {
    if (_history.isEmpty) return;

    setState(() {
      _redo.add(_history.removeLast());

      if (_history.isEmpty) {
        selectedFilter = 'None';
        overlayText = '';
        showTextOverlay = false;
        selectedAudioPath = null;
      }
    });
  }

  void _redoAction() {
    if (_redo.isEmpty) return;

    setState(() {
      final action = _redo.removeLast();
      _history.add(action);
    });
  }

  String _getVideoFilter() {
    switch (selectedFilter) {
      case 'Bright':
        return 'eq=brightness=0.08:contrast=1.05';
      case 'Warm':
        return 'colorbalance=rs=0.08:gs=0.03:bs=-0.05';
      case 'Cool':
        return 'colorbalance=rs=-0.05:gs=0.03:bs=0.08';
      case 'Vintage':
        return 'eq=saturation=0.75:contrast=0.9';
      case 'B&W':
        return 'hue=s=0';
      default:
        return 'null';
    }
  }

  Future<void> _exportVideo() async {
    if (widget.videoPath == null || isExporting) return;

    final duration = _controller.value.duration.inMilliseconds / 1000.0;

    final start = trimStart * duration;
    final end = trimEnd * duration;
    final clipDuration = end - start;

    if (clipDuration <= 0) return;

    setState(() {
      isExporting = true;
    });

    final input = widget.videoPath!;
    final output = '${input}_ultracut.mp4';
    final filter = _getVideoFilter();

    final command = selectedAudioPath != null
        ? '-y -ss $start -i "$input" -i "$selectedAudioPath" '
              '-t $clipDuration -map 0:v:0 -map 1:a:0 '
              '-vf "$filter" -c:v libx264 -c:a aac -shortest "$output"'
        : '-y -ss $start -i "$input" '
              '-t $clipDuration -vf "$filter" '
              '-c:v libx264 -c:a aac "$output"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!mounted) return;

    setState(() {
      isExporting = false;
    });

    if (returnCode != null && returnCode.isValueSuccess()) {
      try {
        await Gal.putVideo(output, album: 'UltraCut');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video exported successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gallery save failed: $e')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Export failed')));
    }
  }

  Widget _tool(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF24242A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 23),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeline() {
    if (!_controller.value.isInitialized) {
      return const SizedBox();
    }

    final position = _controller.value.position;
    final duration = _controller.value.duration;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF18181D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.movie_creation_outlined,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Timeline',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${position.inSeconds}s / ${duration.inSeconds}s',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              padding: const EdgeInsets.symmetric(vertical: 5),
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(trimStart, trimEnd),
            min: 0,
            max: 1,
            divisions: 100,
            onChanged: (values) {
              if (values.end - values.start > 0.01) {
                setState(() {
                  trimStart = values.start;
                  trimEnd = values.end;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready =
        widget.videoPath != null && _controller.value.isInitialized;

    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'UltraCut',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: isExporting ? null : _exportVideo,
                    child: Text(
                      isExporting ? 'Exporting...' : 'Export',
                      style: const TextStyle(
                        color: Color(0xFF9B7BFF),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // VIDEO PREVIEW
            Container(
              height: 285,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: ready
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            VideoPlayer(_controller),

                            if (showTextOverlay)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
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
                              ),

                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_controller.value.isPlaying) {
                                        _controller.pause();
                                      } else {
                                        _controller.play();
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white24,
                                      ),
                                    ),
                                    child: Icon(
                                      _controller.value.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),

            const SizedBox(height: 10),

            // TIME / PLAYBACK ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  IconButton(
                    onPressed: ready
                        ? () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          }
                        : null,
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    ready
                        ? '${_controller.value.position.inSeconds}s'
                        : '0s',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    ready
                        ? '${_controller.value.duration.inSeconds}s'
                        : '0s',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // TIMELINE
            if (ready)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF121216),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _timeline(),
              ),

            const SizedBox(height: 8),

            // EDITING TOOLS
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF101014),
                  border: Border(
                    top: BorderSide(color: Colors.white10),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 82,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        children: [
                          _tool(
                            Icons.content_cut_rounded,
                            'Trim',
                          ),
                          _tool(
                            Icons.call_split_rounded,
                            'Split',
                          ),
                          _tool(
                            Icons.music_note_rounded,
                            'Audio',
                            onTap: _pickAudio,
                          ),
                          _tool(
                            Icons.text_fields_rounded,
                            'Text',
                            onTap: _addText,
                          ),
                          _tool(
                            Icons.auto_awesome_rounded,
                            'Filter',
                            onTap: _showFilters,
                          ),
                          _tool(
                            Icons.speed_rounded,
                            'Speed',
                          ),
                          _tool(
                            Icons.volume_up_rounded,
                            'Volume',
                          ),
                          _tool(
                            Icons.crop_rounded,
                            'Crop',
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // UNDO / REDO
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        14,
                        4,
                        14,
                        8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: _undo,
                              icon: const Icon(
                                Icons.undo_rounded,
                                size: 20,
                              ),
                              label: const Text('Undo'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: _redoAction,
                              icon: const Icon(
                                Icons.redo_rounded,
                                size: 20,
                              ),
                              label: const Text('Redo'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
