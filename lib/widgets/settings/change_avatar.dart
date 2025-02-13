import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/user_service.dart';

final _authService = AuthService();
final _userService = UserService();
final _storageService = StorageService();

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

  void _submit() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không có ảnh nào được chọn."),
        ),
      );
      return;
    }

    await _storageService.updateAvatar(_pickedImage!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cập nhật ảnh đại diện thành công."),
        ),
      );
      Navigator.of(context).pop();
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: _buildAvatar(),
          ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _submit,
                child: Text("Thay đổi"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Huỷ"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
