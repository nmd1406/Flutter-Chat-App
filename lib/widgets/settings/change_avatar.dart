import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:image_picker/image_picker.dart';

final _authService = AuthService();
final _userService = UserService();

class ChangeAvatar extends StatefulWidget {
  const ChangeAvatar({super.key});

  @override
  State<ChangeAvatar> createState() => _ChangeAvatarState();
}

class _ChangeAvatarState extends State<ChangeAvatar> {
  File? _pickedImage;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImage = File(pickedImage.path);
    });
  }

  void _takePicture() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImage = File(pickedImage.path);
    });
  }

  Widget _buildAvatar() {
    if (_pickedImage != null) {
      return CircleAvatar(
        radius: 36,
        backgroundColor: Colors.grey,
        foregroundImage: FileImage(_pickedImage!),
      );
    }

    return StreamBuilder(
      stream: _userService.getUserData(_authService.getCurrentUserUid()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 36,
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text("Lỗi load data"),
          );
        }

        String imageUrl = snapshot.data!["image_url"];

        return CircleAvatar(
          radius: 36,
          backgroundImage: NetworkImage(imageUrl),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildAvatar(),
          ListTile(
            title: Text("Chọn ảnh từ thư viện"),
            leading: Icon(Icons.image_outlined),
            onTap: _pickImage,
          ),
          ListTile(
            title: Text("Chụp ảnh"),
            leading: Icon(Icons.camera_alt_sharp),
            onTap: _takePicture,
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text("Thay đổi"),
          ),
          TextButton(
            onPressed: () {},
            child: Text("Huỷ"),
          ),
        ],
      ),
    );
  }
}
