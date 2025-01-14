import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("users").snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(
      String userId) async {
    final userData =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    return userData;
  }
}
