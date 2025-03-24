import 'package:animations/animations.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:chat_app/widgets/message_tile.dart';
import 'package:flutter/material.dart';

final _userService = UserService();
final _authService = AuthService();
final _chatService = ChatService();

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String query = _searchController.text;

    final currentUserUid = _authService.getCurrentUserUid();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: SearchBar(
            controller: _searchController,
            hintText: "Tìm kiếm",
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            onSubmitted: (value) {
              setState(() {
                query = value;
              });
            },
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            leading: Icon(Icons.search),
            trailing: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                  });
                },
                icon: Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
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
                return const Center(
                  child: Icon(
                    Icons.error,
                    size: 54,
                    color: Colors.red,
                  ),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/chats.png",
                    ),
                    Text("Ở đây có vẻ hơi trống."),
                    Text("Hãy bắt đầu nhắn tin với ai đó."),
                  ],
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
                        return SizedBox.shrink();
                      }

                      if (!snapshot.hasData) {
                        return Center(
                          child: Text("Error loading user data"),
                        );
                      }

                      final userData = snapshot.data!;
                      String username = userData["username"];
                      String imageUrl = userData["image_url"];

                      if (username.contains(query) || query.isEmpty) {
                        return OpenContainer(
                          closedColor: Colors.transparent,
                          closedElevation: 0,
                          openElevation: 0,
                          transitionDuration: Duration(milliseconds: 320),
                          transitionType: ContainerTransitionType.fadeThrough,
                          middleColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          closedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          openShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          closedBuilder: (context, openContainer) {
                            return MessageTile(
                              username: username,
                              imageUrl: imageUrl,
                              userId: chatRoomId[0],
                              otherUserId: chatRoomId[1],
                              onOpenMessage: openContainer,
                            );
                          },
                          openBuilder: (context, _) {
                            return ChatScreen(
                              otherUserData: userData,
                              otherUserId: otherUserId,
                            );
                          },
                        );
                      }
                      return SizedBox.shrink();
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
