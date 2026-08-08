import 'package:flutter/material.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  bool isPlaying = false;
  double timelinePosition = 0.35;
  double speed = 1.0;
  double volume = 1.0;
  String selectedTool = '';

  final List<_EditorTool> tools = const [
    _EditorTool(Icons.content_cut, 'Trim'),
    _EditorTool(Icons.music_note, 'Audio'),
    _EditorTool(Icons.text_fields, 'Text'),
    _EditorTool(Icons.auto_awesome, 'Effects'),
    _EditorTool(Icons.filter_vintage, 'Filters'),
    _EditorTool(Icons.speed, 'Speed'),
  ];

  void selectTool(String tool) {
    setState(() {
      selectedTool = tool;
    });

    if (tool == 'Trim') {
      _showTrimSheet();
    } else if (tool == 'Audio') {
      _showAudioSheet();
    } else if (tool == 'Text') {
      _showTextSheet();
    } else if (tool == 'Effects') {
      _showEffectsSheet();
    } else if (tool == 'Filters') {
      _showFiltersSheet();
    } else if (tool == 'Speed') {
      _showSpeedSheet();
    }
  }

  void _showTrimSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15151C),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trim Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              RangeSlider(
                values: const RangeValues(0.0, 1.0),
                onChanged: (_) {},
              ),
              const SizedBox(height: 10),
              const Text(
                'Drag the handles to choose the clip duration.',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 20),
              _sheetButton('Apply Trim', Icons.check),
            ],
          ),
        );
      },
    );
  }

  void _showAudioSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15151C),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Audio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.library_music,
                  color: Color(0xFFB388FF),
                ),
                title: const Text(
                  'Add Music',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(
                  Icons.mic,
                  color: Color(0xFFB388FF),
                ),
                title: const Text(
                  'Voiceover',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              Slider(
                value: volume,
                min: 0,
                max: 1,
                onChanged: (value) {
                  setState(() {
                    volume = value;
                  });
                },
              ),
              const Text(
                'Volume',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTextSheet() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15151C),
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Text',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your text',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF22222B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _sheetButton('Add Text', Icons.add),
            ],
          ),
        );
      },
    );
  }

  void _showEffectsSheet() {
    final effects = [
      'Glow',
      'Blur',
      'Shake',
      'Zoom',
      'Flash',
      'Fade',
    ];

    _showOptionSheet('Effects', effects);
  }

  void _showFiltersSheet() {
    final filters = [
      'Original',
      'Cinema',
      'Vintage',
      'Warm',
      'Cool',
      'B&W',
    ];

    _showOptionSheet('Filters', filters);
  }

  void _showOptionSheet(String title, List<String> options) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15151C),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: options.map((option) {
                  return ActionChip(
                    label: Text(option),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$option selected'),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSpeedSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15151C),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Playback Speed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '${speed.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      color: Color(0xFFB388FF),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: speed,
                    min: 0.25,
                    max: 3.0,
                    divisions: 11,
                    onChanged: (value) {
                      setSheetState(() {
                        speed = value;
                      });
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetButton(String title, IconData icon) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C4DFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08080C),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'UltraCut Editor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export system coming next 🚀'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Export'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF15151B),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library_outlined,
                        color: Colors.white38,
                        size: 64,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Video Preview',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 15,
                    left: 15,
                    right: 15,
                    child: Slider(
                      value: timelinePosition,
                      onChanged: (value) {
                        setState(() {
                          timelinePosition = value;
                        });
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 58,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF7C4DFF),
                      child: IconButton(
                        iconSize: 30,
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                        },
                        icon: Icon(
                          isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            height: 95,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Timeline',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF17171E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: List.generate(
                        10,
                        (index) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? const Color(0xFF383842)
                                  : const Color(0xFF4A4A55),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
            color: const Color(0xFF101015),
            child: Column(
              children: [
                SizedBox(
                  height: 82,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: tools.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final tool = tools[index];
                      final selected = selectedTool == tool.title;

                      return GestureDetector(
                        onTap: () => selectTool(tool.title),
                        child: Container(
                          width: 72,
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF30204F)
                                : const Color(0xFF1B1B23),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF7C4DFF)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                tool.icon,
                                color: const Color(0xFFB388FF),
                                size: 25,
                              ),
                              const SizedBox(height: 7),
                              Text(
                                tool.title,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.undo),
                        label: const Text('Undo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
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
                          foregroundColor: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorTool {
  final IconData icon;
  final String title;

  const _EditorTool(this.icon, this.title);
}
