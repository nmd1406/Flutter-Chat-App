import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class FileService {
  static final _fileCache = FileCache();

  Future<void> openFile(String fileUrl, String fileName) async {
    try {
      final cacheFilePath =
          await _fileCache.getCacheFilePath(fileName, fileUrl);
      File cacheFile = File(cacheFilePath);

      if (!await cacheFile.exists()) {
        final response = await http.head(Uri.parse(fileUrl));
        final fileSize = int.parse(response.headers['content-length'] ?? '0');

        if (!await _fileCache.canCacheFile(fileSize)) {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File("${tempDir.path}/$fileName");

          final response = await http.get(Uri.parse(fileUrl));
          await tempFile.writeAsBytes(response.bodyBytes);

          await OpenFile.open(tempFile.path);
          return;
        }

        final res = await http.get(Uri.parse(fileUrl));
        await cacheFile.writeAsBytes(res.bodyBytes);
        await _fileCache.manageCacheSize();
      }

      await cacheFile.setLastAccessed(DateTime.now());
      await OpenFile.open(cacheFile.path);
    } catch (e) {
      print("Error open file: $e");
    }
  }

  Future<void> clearCache() async {
    try {
      final cacheDir = Directory(await _fileCache.getCacheDirectory());
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing cache: $e');
      rethrow;
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

class FileCache {
  static const int _maxCacheSize = 500 * 1024 * 1024;
  static const int _warningThreshold = 480 * 1024 * 1024;

  Future<String> getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory("${appDir.path}/file_cache");

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir.path;
  }

  Future<String> getCacheFilePath(String fileName, String fileUrl) async {
    final cacheDir = await getCacheDirectory();
    final urlHash = md5.convert(utf8.encode(fileUrl)).toString();

    return "$cacheDir/${urlHash}_$fileName";
  }

  Future<bool> isFileInCache(String fileName, String fileUrl) async {
    final cachePath = await getCacheFilePath(fileName, fileUrl);
    final file = File(cachePath);

    return await file.exists();
  }

  Future<void> manageCacheSize() async {
    try {
      final cacheDir = Directory(await getCacheDirectory());
      final files = await cacheDir.list().toList();

      int totalSize = 0;
      List<FileMetadata> filesList = [];

      for (var entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
          filesList.add(FileMetadata(
            file: entity,
            size: stat.size,
            lastAccessed: stat.accessed,
          ));
        }
      }

      if (totalSize > _warningThreshold) {
        filesList.sort(
          (a, b) {
            int timeCompare = a.lastAccessed.compareTo(b.lastAccessed);
            if (timeCompare != 0) {
              return timeCompare;
            }
            return b.size.compareTo(a.size);
          },
        );
      }

      while (totalSize > _warningThreshold && filesList.isNotEmpty) {
        final fileToRemove = filesList.removeAt(0);

        try {
          await fileToRemove.file.delete();
          totalSize -= fileToRemove.size;
        } catch (e) {
          print("Error removing cache file: $e");
        }
      }
    } catch (e) {
      print("Error managing cache: $e");
    }
  }

  Future<bool> canCacheFile(int fileSize) async {
    try {
      final cacheDir = Directory(await getCacheDirectory());
      if (!await cacheDir.exists()) {
        return true;
      }

      int currentSize = 0;
      final files = await cacheDir.list().toList();
      for (var entity in files) {
        if (entity is File) {
          currentSize += await entity.length();
        }
      }

      return (currentSize + fileSize) <= _maxCacheSize;
    } catch (e) {
      print("Error checking cache capacity: $e");
      return false;
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
