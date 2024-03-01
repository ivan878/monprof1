import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Lecteurvideo extends StatefulWidget {
  final File file;

  const Lecteurvideo({
    // required this.videoPlayerController,
    required this.file,
    Key? key,
  }) : super(key: key);
  @override
  State<Lecteurvideo> createState() => _LecteurvideoState();
}

class _LecteurvideoState extends State<Lecteurvideo> {
  late ChewieController _chewieController;
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(widget.file);
    _chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 16 / 9,
        autoInitialize: true,
        autoPlay: true,
        // looping: widget.looping,
        errorBuilder: (context, erromessage) {
          return Center(
            child: Text(erromessage),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
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
        child: Lecteurvideo(file: widget.video),
        // looping: true,
      ),
    );
  }
}
