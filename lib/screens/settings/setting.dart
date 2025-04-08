import 'package:chat_app/screens/settings/account_setting.dart';
import 'package:chat_app/screens/settings/media_files_setting.dart';
import 'package:chat_app/screens/settings/sound_and_notification_setting.dart';
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

  Route _createRouteSlideTransition() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          SoundAndNotificationSettingScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1, 0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final curveAnimation =
            CurvedAnimation(parent: animation, curve: Curves.decelerate);

        return SlideTransition(
          position: tween.animate(curveAnimation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              icon: Icon(
                Icons.supervised_user_circle_rounded,
                color: Colors.indigoAccent,
                size: 36,
              ),
            ),
            SettingTile(
              title: "Thông báo & âm thanh",
              onTap: () =>
                  Navigator.of(context).push(_createRouteSlideTransition()),
              icon: Icon(
                Icons.notifications,
                color: Colors.amberAccent,
                size: 36,
              ),
            ),
            SettingTile(
              title: "Ảnh & file phương tiện",
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MediaFilesSettingScreen(),
              )),
              icon: Icon(
                Icons.perm_media,
                color: Colors.lightGreen,
                size: 36,
              ),
            ),
            SettingTile(
              title: "Đăng xuất",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Đăng xuất"),
                    content: Text("Bạn sẽ đăng xuất khỏi ứng dụng."),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          _authService.signOut();
                          Navigator.of(context).pop();
                        },
                        child: Text("Đăng xuất"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Huỷ"),
                      ),
                    ],
                  ),
                );
                // _authService.signOut();
              },
              icon: Icon(
                Icons.exit_to_app_rounded,
                color: Colors.red[700],
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
