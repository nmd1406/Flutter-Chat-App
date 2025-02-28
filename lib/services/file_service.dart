import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class FileService {
  Future<bool> requestPermissions() async {
    return await Permission.manageExternalStorage.request().isGranted;
  }

  Future<File?> openFile(String fileUrl, String fileName) async {
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
        OpenFile.open(filePath);
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
      OpenFile.open(filePath);
      return file;
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<bool> isFileExist(String fileName) async {
    Directory directory = await path.getApplicationDocumentsDirectory();
    File file = File('${directory.path}/media_files/$fileName');
    return await file.exists();
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
