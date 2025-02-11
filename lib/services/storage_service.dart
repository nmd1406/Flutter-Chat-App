import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  Future<String> getAvatarUrl(String uid) async {
    final storageRef = _storage.ref().child("user_images").child(uid);

    return await storageRef.getDownloadURL();
  }
}
