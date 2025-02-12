import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';

final _authService = AuthService();

class ChangePasswordPopup extends StatefulWidget {
  const ChangePasswordPopup({super.key});

  @override
  State<ChangePasswordPopup> createState() => _ChangePasswordPopupState();
}

class _ChangePasswordPopupState extends State<ChangePasswordPopup> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _checkCurrentPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _textFormFieldDecoration(String title) {
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

  void _submit() async {
    try {
      await _authService.validatePassword(_currentPasswordController.text);
    } on Exception catch (e) {
      // TODO
      setState(() {
        _checkCurrentPassword = false;
      });
    }

    bool isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _authService.changePassword(_newPasswordController.text);

    if (mounted) {
      Navigator.of(context).pop();
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        "Thay đổi mật khẩu",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 27,
        ),
      ),
      children: [
        Container(
          height: 380,
          width: 400,
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu hiện tại",
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
                    errorText: _checkCurrentPassword
                        ? null
                        : "Mật khẩu không chính xác.",
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return "Mật khẩu phải chứa ít nhất 6 ký tự.";
                    }
                    return null;
                  },
                  decoration: _textFormFieldDecoration("Mật khẩu mới"),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nhập lại mật khẩu.";
                    }
                    if (value != _newPasswordController.text) {
                      return "Mật khẩu không trùng khớp";
                    }
                    return null;
                  },
                  decoration: _textFormFieldDecoration("Xác nhận mật khẩu"),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _submit();
                      },
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
    );
  }
}
