import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final _chatService = ChatService();
final _authService = AuthService();

class MessageTile extends StatelessWidget {
  final String username;
  final String imageUrl;
  final String userId;
  final String otherUserId;
  final void Function() onOpenMessage;

  const MessageTile({
    super.key,
    required this.username,
    required this.imageUrl,
    required this.userId,
    required this.otherUserId,
    required this.onOpenMessage,
  });

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(Duration(days: 1));
    if (_isSameDay(today, date)) {
      return "${date.hour}:${date.minute}";
    }
    if (_isSameDay(yesterday, date)) {
      return "H.qua";
    }
    return "${date.day}/${date.month}";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _chatService.getMessages(userId, otherUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox.shrink();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("Không có tin nhắn"),
            );
          }

          var loadedMessages =
              snapshot.data!.docs.map((doc) => doc.data()).toList();
          var latestMessage = loadedMessages[0]["message"];
          var messageType = loadedMessages[0]["messageType"];
          bool isMe =
              loadedMessages[0]["senderId"] == _authService.getCurrentUserUid();
          DateTime date =
              (loadedMessages[0]["timeStamp"] as Timestamp).toDate();
          String formattedDate = _formatDate(date);

          return GestureDetector(
            onTap: onOpenMessage,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                tileColor: Theme.of(context).colorScheme.inversePrimary,
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withAlpha(180),
                  backgroundImage: NetworkImage(imageUrl),
                ),
                trailing: Text(formattedDate),
                title: Text(
                  username,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                ),
                subtitle: messageType != "text"
                    ? Row(
                        children: [
                          Icon(
                            Icons.file_copy,
                            size: 24,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${isMe ? "Bạn:" : null} [Đã gửi file phương tiện]",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : Text(
                        "${isMe ? "Bạn:" : null} $latestMessage",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          );
        });
  }
}
