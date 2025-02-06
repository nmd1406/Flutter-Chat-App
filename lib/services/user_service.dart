import 'package:cloud_firestore/cloud_firestore.dart';

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
}
