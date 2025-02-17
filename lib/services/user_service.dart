import 'package:chat_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _authService = AuthService();

class UserService {
  final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("users").snapshots();
  }

  Stream<Map<String, dynamic>?> getUserData(String userId) {
    final userData = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data());
    return userData;
  }

  Future<void> changeUserName(String newUsername) async {
    String uid = _authService.getCurrentUserUid();
    await _firestore
        .collection("users")
        .doc(uid)
        .update({"username": newUsername});
  }
}
