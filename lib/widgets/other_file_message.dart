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

  String _formatFileName() {
    int firstSeperator = fileName.indexOf("_");
    int fileExtensionSeperator = fileName.lastIndexOf(".");
    return fileName.substring(firstSeperator + 1, fileExtensionSeperator);
  }

  @override
  Widget build(BuildContext context) {
    String fileFullName = _formatFileName();

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.65,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity(horizontal: VisualDensity.maximumDensity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        tileColor: isMe
            ? Colors.deepPurple[300]
            : Theme.of(context).colorScheme.secondary.withAlpha(200),
        leading: _fileTypeIconMap[fileExtension] ??
            Icon(
              Icons.file_copy_sharp,
              size: 23,
            ),
        title: Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            text: fileFullName,
            children: [
              TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                text: fileExtension,
              )
            ],
          ),
          maxLines: 3,
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
