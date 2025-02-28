import 'dart:io';

import 'package:flutter/material.dart';

class ImageMessage extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;

  const ImageMessage({
    super.key,
    this.imageUrl,
    this.imageFile,
  });

  Widget _buildImage() {
    if (imageFile != null) {
      return Image.file(imageFile!);
    }

    return Image.network(imageUrl!);
  }

  @override
  Widget build(BuildContext context) {
    return _buildImage();
  }
}
