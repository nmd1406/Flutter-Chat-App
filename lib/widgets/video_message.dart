import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

class VideoMessage extends StatefulWidget {
  final String? fileUrl;
  final File? videoFile;

  const VideoMessage({
    super.key,
    this.fileUrl,
    this.videoFile,
  });

  @override
  State<VideoMessage> createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  late CachedVideoPlayerPlusController _videoPlayerController;

  @override
  void initState() {
    super.initState();

    if (widget.fileUrl != null) {
      _videoPlayerController = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(widget.fileUrl!),
      );
    } else if (widget.videoFile != null) {
      _videoPlayerController =
          CachedVideoPlayerPlusController.file(widget.videoFile!);
    }

    _videoPlayerController.initialize();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _videoPlayerController.value.isInitialized
          ? AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: CachedVideoPlayerPlus(_videoPlayerController),
            )
          : CircularProgressIndicator.adaptive(),
    );
  }
}
