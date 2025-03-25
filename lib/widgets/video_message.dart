import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

class VideoMessage extends StatefulWidget {
  final String? fileUrl;
  final File? videoFile;
  final double height;
  final double width;

  const VideoMessage({
    super.key,
    this.fileUrl,
    this.videoFile,
    required this.height,
    required this.width,
  });

  @override
  State<VideoMessage> createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  late CachedVideoPlayerPlusController _videoPlayerController;

  @override
  void initState() {
    super.initState();

    if (widget.videoFile != null) {
      _videoPlayerController =
          CachedVideoPlayerPlusController.file(widget.videoFile!);
    } else if (widget.fileUrl != null) {
      _videoPlayerController = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(widget.fileUrl!),
      );
    }

    _videoPlayerController.initialize().then(
      (value) async {
        _videoPlayerController.play();
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.6,
        maxHeight: 300,
      ),
      height: widget.height * 0.3,
      width: widget.width * 0.3,
      child: _videoPlayerController.value.isInitialized
          ? AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  CachedVideoPlayerPlus(_videoPlayerController),
                  Icon(
                    Icons.play_circle_filled_outlined,
                    size: 54,
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
