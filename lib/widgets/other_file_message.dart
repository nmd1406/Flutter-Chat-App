import 'package:flutter/material.dart';
import "package:font_awesome_flutter/font_awesome_flutter.dart";

final Map<String, FaIcon> _fileTypeIconMap = {
  ".docx": FaIcon(
    FontAwesomeIcons.solidFileWord,
    color: Colors.blue[900],
  ),
  ".doc": FaIcon(
    FontAwesomeIcons.solidFileWord,
    color: Colors.blue[900],
  ),
  ".pdf": FaIcon(
    FontAwesomeIcons.filePdf,
    color: Colors.red,
  ),

  ///...Them cac icon
};

class OtherFileMessage extends StatelessWidget {
  final String fileName;
  final String fileExtension;
  final bool isMe;

  const OtherFileMessage({
    super.key,
    required this.fileName,
    required this.fileExtension,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    String fileFullName = fileName;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity(horizontal: VisualDensity.maximumDensity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        tileColor: isMe
            ? Colors.grey[300]
            : Theme.of(context).colorScheme.secondary.withAlpha(200),
        leading: _fileTypeIconMap[fileExtension] ??
            Icon(
              Icons.file_copy_sharp,
              size: 23,
            ),
        title: Text(
          fileFullName.replaceRange(10, fileFullName.length - 20, "..."),
          maxLines: 2,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          softWrap: true,
        ),
      ),
    );
  }
}
