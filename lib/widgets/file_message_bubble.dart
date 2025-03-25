import 'dart:io';

import 'package:chat_app/services/file_service.dart';
import 'package:chat_app/widgets/image_message.dart';
import 'package:chat_app/widgets/other_file_message.dart';
import 'package:chat_app/widgets/video_message.dart';
import 'package:flutter/material.dart';

final _fileService = FileService();
const List<String> _videoFileExtension = [
  ".3gp",
  ".asf",
  ".avi",
  ".m4u",
  ".m4v",
  ".mov",
  ".mp4",
  ".mpe",
  ".mpeg",
  ".mpg",
  ".mpg4",
];
const List<String> _imageFileExtension = [
  ".bmp",
  ".gif",
  ".jpeg",
  ".jpg",
  ".png",
];

class FileMessageBubble extends StatelessWidget {
  final String fileUrl;
  final bool isMe;

  const FileMessageBubble({
    super.key,
    required this.fileUrl,
    required this.isMe,
  });

  Widget _buildFileContainer(
      String fileName, String fileExtension, File? file) {
    if (_imageFileExtension.contains(fileExtension)) {
      return FutureBuilder(
        future: file != null
            ? _fileService.getImageDimensionFromFile(file)
            : _fileService.getImageDimensionFromUrl(fileUrl),
        builder: (context, snapshot) {
          print("image");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 300,
              width: 200,
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          return ImageMessage(
            height: snapshot.data!.height,
            width: snapshot.data!.width,
            imageFile: file,
            imageUrl: fileUrl,
          );
        },
      );
    }

    if (_videoFileExtension.contains(fileExtension)) {
      return FutureBuilder(
        future: file != null
            ? _fileService.getVideoDimensionFromFile(file)
            : _fileService.getVideoDimensionFromUrl(fileUrl),
        builder: (context, snapshot) {
          print("video");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 300,
              width: 200,
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          return VideoMessage(
            height: snapshot.data!.height,
            width: snapshot.data!.width,
            videoFile: file,
            fileUrl: fileUrl,
          );
        },
      );
    }

    return OtherFileMessage(
      fileName: fileName,
      fileExtension: fileExtension,
      isMe: isMe,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileInfo = _fileService.getFileInfoFromUrl(fileUrl);
    File? file;

    return GestureDetector(
      onTap: () async {
        file = await _fileService.openFile(
            fileUrl, fileInfo["fileName"]!, context);
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _buildFileContainer(
            fileInfo["fileName"]!, fileInfo["fileExtension"]!, file),
      ),
    );
  }
}
