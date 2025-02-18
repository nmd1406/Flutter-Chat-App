import 'package:flutter/material.dart';

import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';

class ChatScreen extends StatelessWidget {
  final Map<String, dynamic> otherUserData;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.otherUserData,
    required this.otherUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              foregroundImage: NetworkImage(otherUserData["image_url"]),
              radius: 23,
            ),
            const SizedBox(width: 10),
            Text(
              otherUserData["username"],
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        elevation: 20,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(
              otherUserData: otherUserData,
              otherUserId: otherUserId,
            ),
          ),
          NewMessage(
            otherUserData: otherUserData,
            otherUserId: otherUserId,
          ),
        ],
      ),
    );
  }
}
