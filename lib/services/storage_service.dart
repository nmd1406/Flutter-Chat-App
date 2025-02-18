import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chat_app/services/auth_service.dart';

final _authService = AuthService();

class StorageService {
  static final _storage = FirebaseStorage.instance;
  static final _firestore = FirebaseFirestore.instance;

  Future<String> getAvatarUrl(String uid) async {
    final storageRef = _storage.ref().child("user_images").child("$uid.jpg");

    return await storageRef.getDownloadURL();
  }

  Future<void> updateAvatar(File newAvatar) async {
    String uid = _authService.getCurrentUserUid();

    var storageRef = _storage.ref().child("user_images").child("$uid.jpg");
    await storageRef.putFile(newAvatar);

    String imageUrl = await storageRef.getDownloadURL();
    await _firestore
        .collection("users")
        .doc(uid)
        .update({"image_url": imageUrl});
  }

  Future<String> uploadFiles(File file) async {
    String filePath = file.path;
    String fileName = path.basename(filePath);

    var storageRef = _storage.ref().child("media_files").child(fileName);
    await storageRef.putFile(file);

    return await storageRef.getDownloadURL();
  }
}
