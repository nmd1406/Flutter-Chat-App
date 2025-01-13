import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:chat_app/widgets/message_tile.dart';
import 'package:flutter/material.dart';

final _userService = UserService();
final _authService = AuthService();

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder(
          stream: _userService.getUsersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text("Không có tin nhắn"),
              );
            }

            final currentUserUid = _authService.getCurrentUserUid();
            final usersData = snapshot.data!.docs
                .where((doc) => doc.id != currentUserUid)
                .toList();

            return ListView.builder(
              shrinkWrap: true,
              itemCount: usersData.length,
              itemBuilder: (context, index) {
                final user = usersData[index].data();
                final username = user["username"];
                final imageUrl = user["image_url"];

                return MessageTile(
                  username: username,
                  imageUrl: imageUrl,
                  onOpenMessage: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
