import 'package:chat_app/widgets/settings/change_avatar.dart';
import 'package:chat_app/widgets/settings/change_password_popup.dart';
import 'package:chat_app/widgets/settings/change_username_popup.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/widgets/settings/setting_tile.dart';

class AccountSetting extends StatelessWidget {
  const AccountSetting({super.key});

  void _changePasswordPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordPopup(),
    );
  }

  void _buildChangeAvatar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ChangeAvatar(),
    );
  }

  void _buildChangeUsername(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChangeUsernamePopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tài khoản",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingTile(
              title: "Thay đổi tên người dùng",
              icon: null,
              onTap: () {
                _buildChangeUsername(context);
              },
            ),
            SettingTile(
              title: "Thay đổi ảnh đại diện",
              icon: null,
              onTap: () {
                _buildChangeAvatar(context);
              },
            ),
            SettingTile(
              title: "Thay đổi mật khẩu",
              icon: null,
              onTap: () {
                _changePasswordPopUp(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
