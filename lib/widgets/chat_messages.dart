import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _chatService = ChatService();
final _authService = AuthService();
final _userService = UserService();

class ChatMessages extends StatefulWidget {
  final Map<String, dynamic> otherUserData;
  final String otherUserId;

  const ChatMessages({
    super.key,
    required this.otherUserData,
    required this.otherUserId,
  });

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: _chatService.getMessages(
          _authService.getCurrentUserUid(), widget.otherUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text("Không có tin nhắn"),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text("Có lỗi xảy ra..."),
          );
        }

        final loadedMessages = snapshot.data!.docs;

        return Stack(
          children: [
            ListView.builder(
              itemCount: loadedMessages.length,
              padding: EdgeInsets.only(
                bottom: 40,
                left: 13,
                right: 13,
              ),
              reverse: true,
              itemBuilder: (context, index) {
                final chatMessage = loadedMessages[index].data();
                final nextChatMessage = (index + 1 < loadedMessages.length)
                    ? loadedMessages[index + 1].data()
                    : null;
                final currentMessageUserId = chatMessage["senderId"];
                final nextMessageUserId = nextChatMessage != null
                    ? nextChatMessage["senderId"]
                    : null;
                final nextUserIsSame =
                    nextMessageUserId == currentMessageUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                    message: chatMessage["message"],
                    messageType: chatMessage["messageType"],
                    isMe: authenticatedUser.uid == currentMessageUserId,
                  );
                } else {
                  return StreamBuilder(
                    stream: _userService.getUserData(currentMessageUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox.shrink();
                      }

                      return MessageBubble.first(
                        userImage: snapshot.data!["image_url"],
                        username: snapshot.data!["username"],
                        message: chatMessage["message"],
                        messageType: chatMessage["messageType"],
                        isMe: authenticatedUser.uid == currentMessageUserId,
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
