import 'dart:io';

import 'package:chat_app/services/file_service.dart';
import 'package:chat_app/widgets/image_message.dart';
import 'package:chat_app/widgets/other_file_message.dart';
import 'package:chat_app/widgets/video_message.dart';
import 'package:flutter/material.dart';

final _fileService = FileService();
const List<String> _videoFileExtension = [
  "3gp",
  "asf",
  "avi",
  "m4u",
  "m4v",
  "mov",
  "mp4",
  "mpe",
  "mpeg",
  "mpg",
  "mpg4",
];
const List<String> _imageFileExtension = [
  "bmp",
  "gif",
  "jpeg",
  "jpg",
  "png",
];
const List<String> _audioFileExtension = [];

class FileMessageBubble extends StatelessWidget {
  final String fileUrl;

  const FileMessageBubble({
    super.key,
    required this.fileUrl,
  });

  Widget _buildFileContainer(String fileExtension, File? file) {
    if (_imageFileExtension.contains(fileExtension)) {
      if (file != null) {
        return ImageMessage(
          imageFile: file,
        );
      }
      return ImageMessage(
        imageUrl: fileUrl,
      );
    }

    if (_videoFileExtension.contains(fileExtension)) {
      if (file != null) {
        return VideoMessage(
          videoFile: file,
        );
      }
      return VideoMessage(
        fileUrl: fileUrl,
      );
    }

    return OtherFileMessage(
      fileName: "",
      fileExtension: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileInfo = _fileService.getFileInfoFromUrl(fileUrl);
    File? file;

    return GestureDetector(
      onTap: () async {
        file = await _fileService.openFile(fileUrl, fileInfo["fileName"]!);
      },
      child: Card(
        child: Container(
          height: 180,
          width: 220,
          child: _buildFileContainer(fileInfo["fileExtension"]!, file),
        ),
      ),
    );
  }
}
