import 'package:flutter/material.dart';

class FileMessageBubble extends StatelessWidget {
  String? userImage;

  FileMessageBubble({
    super.key,
    this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 180,
        width: 220,
        child: Image.network(userImage!),
      ),
    );
  }
}
