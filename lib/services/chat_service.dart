import 'package:chat_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _authService = AuthService();

class ChatService {
  static final _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String senderUsername, String senderImageUrl,
      String receiverId, String message) async {
    final String currentUserId = _authService.getCurrentUserUid();
    final Timestamp timestamp = Timestamp.now();

    Map<String, dynamic> messageData = {
      "userImage": senderImageUrl,
      "username": senderUsername,
      "senderId": currentUserId,
      "receiverId": receiverId,
      "timeStamp": timestamp,
      "message": message,
    };

    List<String> ids = [currentUserId, receiverId];
    // Đảm bảo chat room id cho sender và receiver là giống nhau
    ids.sort();
    final chatRoomId = ids.join('_');

    final chatRoomRef = _firestore.collection("chat_rooms").doc(chatRoomId);
    await chatRoomRef.set(
      {"chatRoomId": ids},
      SetOptions(merge: true),
    );

    var messageRef = chatRoomRef.collection("messages");
    await messageRef.add(messageData);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      String userId, String otherId) {
    List<String> ids = [userId, otherId];
    ids.sort();
    final chatRoomId = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPrivateChatRooms(String uid) {
    return _firestore
        .collection("chat_rooms")
        .where("chatRoomId", arrayContains: uid)
        .snapshots();
  }
}
