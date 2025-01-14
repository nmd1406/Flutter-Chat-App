import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:flutter/material.dart';

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
        title: Text(
          otherUserData["username"],
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 20,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: () async {},
            icon: Icon(
              Icons.info_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          )
        ],
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
