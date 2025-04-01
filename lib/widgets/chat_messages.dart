import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

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
  late ScrollController _scrollController;
  final String _uid = _authService.getCurrentUserUid();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        List<String> ids = [widget.otherUserId, _uid];
        ids.sort();
        String chatRoomId = ids.join("_");

        _chatService.markAsRead(chatRoomId);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: StreamBuilder(
        stream: _chatService.getMessages(
            _authService.getCurrentUserUid(), widget.otherUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox.shrink();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset("assets/images/conversation.png"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Bắt đầu cuộc trò chuyện",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Có lỗi xảy ra..."),
            );
          }

          final loadedMessages = snapshot.data!.docs;

          return GroupedListView(
            controller: _scrollController,
            elements: loadedMessages.reversed.toList(),
            groupBy: (message) {
              DateTime time =
                  (message.data()["timeStamp"] as Timestamp).toDate();
              return DateTime(time.year, time.month, time.day);
            },
            groupSeparatorBuilder: (date) {
              String formattedDate = "${date.day}/${date.month}/${date.year}";

              DateTime today = DateTime.now();
              DateTime yesterday = today.subtract(Duration(days: 1));
              if (_isSameDay(date, today)) {
                formattedDate = "Hôm nay";
              } else if (_isSameDay(date, yesterday)) {
                formattedDate = "Hôm qua";
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 36, bottom: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    width: 100,
                    height: 24,
                    child: Text(
                      formattedDate,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              );
            },
            itemComparator: (message1, message2) {
              Timestamp time1 = message1.data()["timeStamp"] as Timestamp;
              Timestamp time2 = message2.data()["timeStamp"] as Timestamp;
              return time1.compareTo(time2);
            },
            itemBuilder: (context, message) {
              int index = loadedMessages.indexOf(message);

              final chatMessage = loadedMessages[index].data();
              final nextChatMessage =
                  (index - 1 > 0) ? loadedMessages[index - 1].data() : null;
              final currentMessageUserId = chatMessage["senderId"];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage["senderId"] : null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                  message: chatMessage["message"],
                  messageType: chatMessage["messageType"],
                  isMe: authenticatedUser.uid == currentMessageUserId,
                  timeStamp: (chatMessage["timeStamp"] as Timestamp).toDate(),
                  hasRead: chatMessage["hasRead"] as bool,
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
                      timeStamp:
                          (chatMessage["timeStamp"] as Timestamp).toDate(),
                      hasRead: chatMessage["hasRead"] as bool,
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
