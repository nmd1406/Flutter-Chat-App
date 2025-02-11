import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:chat_app/widgets/message_tile.dart';
import 'package:flutter/material.dart';

final _userService = UserService();
final _authService = AuthService();
final _chatService = ChatService();

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserUid = _authService.getCurrentUserUid();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: StreamBuilder(
            stream: _chatService.getPrivateChatRooms(currentUserUid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData) {
                return Center(
                  child: Text("Không có tin nhắn"),
                );
              }

              final chatRooms =
                  snapshot.data!.docs.map((doc) => doc.data()).toList();

              return ListView.builder(
                shrinkWrap: true,
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoomId = chatRooms[index]["chatRoomId"];
                  final otherUserId = chatRoomId[0] == currentUserUid
                      ? chatRoomId[1]
                      : chatRoomId[0];
                  final user = _userService.getUserData(otherUserId);

                  return StreamBuilder(
                    stream: user,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            tileColor:
                                Theme.of(context).colorScheme.inversePrimary,
                            title: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return Center(
                          child: Text("Error loading user data"),
                        );
                      }

                      final userData = snapshot.data!;
                      String username = userData["username"];
                      String imageUrl = userData["image_url"];

                      return MessageTile(
                        username: username,
                        imageUrl: imageUrl,
                        userId: chatRoomId[0],
                        otherUserId: chatRoomId[1],
                        onOpenMessage: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                otherUserData: userData,
                                otherUserId: otherUserId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
