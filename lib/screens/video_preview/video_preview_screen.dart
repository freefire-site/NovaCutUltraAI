import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String videoPath;

  const VideoPreviewScreen({
    super.key,
    required this.videoPath,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(
      File(widget.videoPath),
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08080C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Video Preview',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: _controller.value.isInitialized
          ? Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    20,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF111116),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFF7C4DFF),
                          bufferedColor: Color(0xFF555560),
                          backgroundColor: Color(0xFF292932),
                        ),
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _controller,
                            builder: (context, value, child) {
                              return Text(
                                _formatDuration(value.position),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                          Text(
                            _formatDuration(
                              _controller.value.duration,
                            ),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              _controller.seekTo(
                                Duration(
                                  seconds: (_controller
                                              .value.position.inSeconds -
                                          5)
                                      .clamp(0, 999999),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.replay_5,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 10),

                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                const Color(0xFF7C4DFF),
                            child: IconButton(
                              onPressed: _togglePlay,
                              iconSize: 32,
                              color: Colors.white,
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          IconButton(
                            onPressed: () {
                              final duration =
                                  _controller.value.duration;

                              final newPosition =
                                  _controller.value.position +
                                      const Duration(seconds: 5);

                              _controller.seekTo(
                                newPosition < duration
                                    ? newPosition
                                    : duration,
                              );
                            },
                            icon: const Icon(
                              Icons.forward_5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _actionButton(
                              Icons.edit,
                              'Edit',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _actionButton(
                              Icons.download,
                              'Export',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C4DFF),
              ),
            ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String title,
  ) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(
          color: Colors.white12,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
