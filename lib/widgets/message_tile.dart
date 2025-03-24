import 'package:chat_app/services/chat_service.dart';
import 'package:flutter/material.dart';

final _chatService = ChatService();

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

          return GestureDetector(
            onTap: () {
              if (_authService.getCurrentUserUid() ==
                  loadedMessages[0]["receiverId"]) {
                List<String> ids = [userId, otherUserId];
                ids.sort();
                String chatRoomId = ids.join("_");
                _chatService.markAsRead(chatRoomId);
              }
              onOpenMessage();
            },
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
                            "[Đã gửi file phương tiện]",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : Text(
                        latestMessage,
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
