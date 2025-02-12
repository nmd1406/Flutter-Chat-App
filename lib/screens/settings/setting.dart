import 'package:chat_app/screens/settings/account_setting.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:chat_app/widgets/settings/setting_tile.dart';

final _authService = AuthService();
final _userService = UserService();

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  Widget _buildAvatar() {
    return StreamBuilder(
      stream: _userService.getUserData(_authService.getCurrentUserUid()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 56,
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
          radius: 56,
          backgroundImage: NetworkImage(imageUrl),
        );
      },
    );
  }

  Widget _buildUsername() {
    return StreamBuilder(
      stream: _userService.getUserData(_authService.getCurrentUserUid()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text("Lỗi load data"),
          );
        }

        return Text(
          snapshot.data!["username"],
          style: Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = _authService.getCurrentUser();

    return Container(
      alignment: AlignmentDirectional.topCenter,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 37),
            _buildAvatar(),
            const SizedBox(height: 15),
            _buildUsername(),
            const SizedBox(height: 45),
            SettingTile(
              title: "Tài khoản",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AccountSetting(),
                  ),
                );
              },
              icon: Icon(Icons.supervised_user_circle_rounded),
            ),
            SettingTile(
              title: "Thông báo và âm thanh",
              onTap: () {},
              icon: Icon(Icons.notifications),
            ),
            SettingTile(
              title: "Ảnh & file phương tiện",
              onTap: () {},
              icon: Icon(Icons.perm_media),
            ),
            SettingTile(
              title: "Đăng xuất",
              onTap: () {
                _authService.signOut();
              },
              icon: Icon(Icons.exit_to_app),
            ),
          ],
        ),
      ),
    );
  }
}
