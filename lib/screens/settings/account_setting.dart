import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/widgets/setting_tile.dart';

final _authService = AuthService();

class AccountSetting extends StatefulWidget {
  const AccountSetting({super.key});

  @override
  State<AccountSetting> createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  final _formKey = GlobalKey<FormState>();

  String _newPassword = "";
  String _confirmNewPassword = "";

  void _changePasswordPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          "Thay đổi mật khẩu",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 27,
          ),
        ),
        children: [
          Container(
            height: 250,
            width: 400,
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    obscureText: true,
                    autocorrect: false,
                    validator: (value) {
                      if (value == null || value.trim().length < 6) {
                        return "Mật khẩu phải chứa ít nhất 6 ký tự.";
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _newPassword = newValue!;
                    },
                    decoration:
                        _textFormFieldDecoration(context, "Mật khẩu mới"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    obscureText: true,
                    autocorrect: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Nhập lại mật khẩu";
                      }
                      if (value != _newPassword) {
                        return "Mật khẩu không trùng khớp";
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _confirmNewPassword = newValue!;
                    },
                    decoration:
                        _textFormFieldDecoration(context, "Xác nhận mật khẩu"),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
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
            ),
          )
        ],
      ),
    );
  }

  InputDecoration _textFormFieldDecoration(BuildContext context, String title) {
    return InputDecoration(
      labelText: title,
      enabledBorder: OutlineInputBorder(
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
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          width: 1.3,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          width: 1.3,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Người dùng",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Column(
        children: [
          SettingTile(
            title: "Thay đổi mật khẩu",
            icon: null,
            onTap: () {
              _changePasswordPopUp(context);
            },
          ),
        ],
      ),
    );
  }
}
