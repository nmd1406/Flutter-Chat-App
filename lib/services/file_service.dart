import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class FileService {
  Future<bool> requestPermissions() async {
    return await Permission.manageExternalStorage.request().isGranted;
  }

  Future<void> openFile(String fileUrl, String fileName) async {
    // Then in your openFile method:
    if (!await requestPermissions()) {
      print("Storage permission denied");
      return;
    }

    try {
      // Get storage directory
      Directory directory = await path.getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/media_files/$fileName';
      File file = File(filePath);

      // Check if file already exists
      if (await file.exists()) {
        print("File already exists, opening...");
        OpenFile.open(filePath);
        return;
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
      OpenFile.open(filePath);
    } catch (e) {
      print("Error: $e");
    }
  }

  Map<String, String> getFileInfoFromUrl(String downloadUrl) {
    try {
      // Extract the file name from the URL
      // URLs typically look like: https://firebasestorage.googleapis.com/.../files%2Fexample.pdf?alt=...
      Uri uri = Uri.parse(downloadUrl);

      // Get the last segment of the path which contains the file name
      String fileName = uri.pathSegments.last;

      // Decode the URL-encoded file name
      fileName = Uri.decodeFull(fileName);

      // Get file extension
      String fileType = '';
      int dotIndex = fileName.lastIndexOf('.');
      if (dotIndex != -1) {
        fileType = fileName.substring(dotIndex);
      }

      return {
        'fileName': fileName,
        'fileType': fileType,
      };
    } catch (e) {
      print('Error extracting file info from URL: $e');
      return {
        'fileName': 'unknown',
        'fileType': '',
      };
    }
  }
}

class FileMetadata {
  final File file;
  final int size;
  final DateTime lastAccessed;

  FileMetadata({
    required this.file,
    required this.size,
    required this.lastAccessed,
  });
}
