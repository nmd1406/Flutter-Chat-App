import 'dart:io';

import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

final _chatService = ChatService();
final _storageService = StorageService();

class NewMessage extends StatefulWidget {
  final Map<String, dynamic> otherUserData;
  final String otherUserId;

  const NewMessage({
    super.key,
    required this.otherUserData,
    required this.otherUserId,
  });

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _pickFiles() async {
    final pickedFiles =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (pickedFiles == null) {
      return;
    }

    try {
      for (var file in pickedFiles.files) {
        String fileUrl = await _storageService.uploadFiles(File(file.path!));
        await _chatService.sendMessage(widget.otherUserId, fileUrl, "files");
      }
    } catch (e) {
      print(e);
    }
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    _chatService.sendMessage(widget.otherUserId, enteredMessage, "text");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: "Nhập tin nhắn...",
                prefixIcon: Icon(Icons.message),
                suffixIcon: IconButton(
                  onPressed: _pickFiles,
                  icon: Icon(Icons.file_copy),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(width: 1.3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    width: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).primaryColor,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
