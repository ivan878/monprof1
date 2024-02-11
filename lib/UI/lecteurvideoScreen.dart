import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Lecteurvideo extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;

  const Lecteurvideo({
    required this.videoPlayerController,
    required this.looping,
    Key? key,
  }) : super(key: key);
  @override
  State<Lecteurvideo> createState() => _LecteurvideoState();
}

class _LecteurvideoState extends State<Lecteurvideo> {
  late ChewieController _chewieController;
  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
        videoPlayerController: widget.videoPlayerController,
        aspectRatio: 16 / 9,
        autoInitialize: true,
        autoPlay: true,
        looping: widget.looping,
        errorBuilder: (context, erromessage) {
          return Center(
            child: Text(erromessage),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Chewie(controller: _chewieController)),
    );
  }
}

class LectureCoursVideo extends StatefulWidget {
  final File video;
  const LectureCoursVideo({Key? key, required this.video}) : super(key: key);

  @override
  State<LectureCoursVideo> createState() => _LectureCoursVideState();
}

class _LectureCoursVideState extends State<LectureCoursVideo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lecteurvideo(
          videoPlayerController: VideoPlayerController.file(widget.video,
              videoPlayerOptions:
                  VideoPlayerOptions(allowBackgroundPlayback: false)),
          looping: true,
        ),
      ),
    );
  }
}
