import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class FileService {
  Future<bool> requestPermissions() async {
    return await Permission.manageExternalStorage.request().isGranted;
  }

  Future<File?> openFile(
      String fileUrl, String fileName, BuildContext context) async {
    // Then in your openFile method:
    if (!await requestPermissions()) {
      print("Storage permission denied");
      return null;
    }

    try {
      // Get storage directory
      Directory directory = await path.getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/media_files/$fileName';
      File file = File(filePath);

      // Check if file already exists
      if (await file.exists()) {
        print("File already exists, opening...");
        var result = await OpenFile.open(filePath);
        if (result.type == ResultType.noAppToOpen && context.mounted) {
          // Show dialog to suggest installing an app
          _showNoAppDialog(context);
        }

        return file;
      }

      // Download the file if it doesn't exist
      print("Downloading file...");
      Dio dio = Dio();
      await dio.download(fileUrl, filePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          print("Downloading: ${(received / total * 100).toStringAsFixed(0)}%");
        }
      });

      print("File downloaded to: $filePath");
      await OpenFile.open(filePath);
      return file;
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  void _showNoAppDialog(BuildContext context) {
    // Show a dialog prompting the user to install a DOCX viewer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Không mở được file"),
        content: Text(
            "Thiết bị không có ứng dụng hỗ trợ mở file này. Vui lòng tìm ứng dụng hỗ trợ file trên Play Store."),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await launchUrl(
                Uri.parse("market://details?id=com.android.vending"),
                mode: LaunchMode.externalApplication,
              );
            },
            child: Text("Mở Play Store"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Đóng"),
          ),
        ],
      ),
    );
  }

  Future<bool> isFileExist(String fileName) async {
    Directory directory = await path.getApplicationDocumentsDirectory();
    File file = File('${directory.path}/media_files/$fileName');
    return await file.exists();
  }

  Future<Size> getImageDimensionFromFile(File file) async {
    final Completer<Size> completer = Completer<Size>();

    ui.decodeImageFromList(file.readAsBytesSync(), (image) {
      completer.complete(Size(image.width.toDouble(), image.height.toDouble()));
    });

    return completer.future;
  }

  Future<Size> getImageDimensionFromUrl(String imageUrl) async {
    final Completer<Size> completer = Completer();
    final Image image = Image.network(imageUrl);

    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
        final Size size = Size(
          imageInfo.image.width.toDouble(),
          imageInfo.image.height.toDouble(),
        );
        completer.complete(size);
      }),
    );

    return completer.future;
  }

  Future<Size> getVideoDimensionFromFile(File file) async {
    final CachedVideoPlayerPlusController controller =
        CachedVideoPlayerPlusController.file(file);

    await controller.initialize(); // Ensure video is fully initialized
    return Size(
      controller.value.size.width,
      controller.value.size.height,
    );
  }

  Future<Size> getVideoDimensionFromUrl(String videoUrl) async {
    final CachedVideoPlayerPlusController controller =
        CachedVideoPlayerPlusController.networkUrl(Uri.parse(videoUrl));

    await controller.initialize(); // Wait until the video loads its metadata
    return Size(
      controller.value.size.width,
      controller.value.size.height,
    );
  }

  Map<String, String> getFileInfoFromUrl(String downloadUrl) {
    try {
      // Extract the file name from the URL
      // URLs typically look like: https://firebasestorage.googleapis.com/.../files%2Fexample.pdf?alt=...
      Uri uri = Uri.parse(downloadUrl);

      // Get the last segment of the path which contains the file name
      String fileName = uri.pathSegments.last;

      // Decode the URL-encoded file name
      fileName = Uri.decodeFull(fileName).split("media_files/")[1];

      // Get file extension
      String fileExtension = '';
      int dotIndex = fileName.lastIndexOf('.');
      if (dotIndex != -1) {
        fileExtension = fileName.substring(dotIndex);
      }

      return {
        'fileName': fileName,
        'fileExtension': fileExtension,
      };
    } catch (e) {
      print('Error extracting file info from URL: $e');
      return {
        'fileName': 'unknown',
        'fileExtension': '',
      };
    }
  }

  Future<String> getFileSizeFromUrl(String fileUrl) async {
    http.Response response = await http.head(Uri.parse(fileUrl));
    int bytes = int.parse(response.headers["content-length"]!);
    if (bytes <= 0) {
      return "0 B";
    }

    const List<String> suffixes = ["B", "KB", "MB", "GB"];
    int suffixIndex = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, suffixIndex)).toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }

  Future<String> getFileSize(File file) async {
    int bytes = await file.length();

    if (bytes <= 0) {
      return "0 B";
    }

    const List<String> suffixes = ["B", "KB", "MB", "GB"];
    int suffixIndex = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, suffixIndex)).toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }
}
