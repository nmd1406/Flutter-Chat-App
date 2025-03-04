import 'dart:io';

import 'package:flutter/material.dart';

class ImageMessage extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final double height;
  final double width;

  const ImageMessage({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.height,
    required this.width,
  });

  Widget _buildImage() {
    if (imageFile == null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
      );
    }

    return Image.file(
      imageFile!,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.5,
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      height: height,
      width: width,
      child: _buildImage(),
    );
  }
}
