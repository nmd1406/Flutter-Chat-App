import 'package:chat_app/services/file_service.dart';
import 'package:flutter/material.dart';

final _fileService = FileService();

class FileMessageBubble extends StatelessWidget {
  final String fileUrl;

  const FileMessageBubble({
    super.key,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    final fileInfo = _fileService.getFileInfoFromUrl(fileUrl);

    return GestureDetector(
      onTap: () async {
        await _fileService.openFile(fileUrl, fileInfo["fileName"]!);
      },
      child: Card(
        child: Container(
          height: 180,
          width: 220,
          child: Image.network(
            fileUrl,
          ),
        ),
      ),
    );
  }
}
