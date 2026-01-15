import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'quiz_screen.dart';
import 'coin_animation_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoAssetPath;
  const VideoPlayerScreen({super.key, required this.videoAssetPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _showCoins = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoAssetPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
      
    _controller.addListener(() {
      if (_controller.value.isInitialized && _controller.value.position >= _controller.value.duration) {
        if (!_showCoins) {
          setState(() => _showCoins = true);
          Future.delayed(3.seconds, () {
            if (mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          GestureDetector(
            onTap: () => setState(() => _controller.value.isPlaying ? _controller.pause() : _controller.play()),
            child: AnimatedSwitcher(
              duration: 300.ms,
              child: _controller.value.isPlaying ? const SizedBox.shrink() : Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: Icon(Icons.play_arrow, color: Colors.white, size: 80)),
              ),
            ),
          ),
          if (_showCoins)
            ...List.generate(30, (index) => const CoinAnimation()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
