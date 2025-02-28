import 'package:flutter/material.dart';

class OtherFileMessage extends StatelessWidget {
  final String fileName;
  final String fileExtension;

  const OtherFileMessage({
    super.key,
    required this.fileName,
    required this.fileExtension,
  });

  @override
  Widget build(BuildContext context) {
    String fileFullName = "${fileName}.${fileExtension}";

    return ListTile(
      leading: Icon(Icons.file_copy_sharp),
      title: Text(fileFullName),
    );
  }
}
