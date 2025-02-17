import 'package:flutter/material.dart';

import 'package:chat_app/services/user_service.dart';

final _userService = UserService();

class ChangeUsernamePopup extends StatefulWidget {
  const ChangeUsernamePopup({super.key});

  @override
  State<ChangeUsernamePopup> createState() => _ChangeUsernamePopupState();
}

class _ChangeUsernamePopupState extends State<ChangeUsernamePopup> {
  final _formKey = GlobalKey<FormState>();
  String _enteredUsername = "";

  void _submit() async {
    bool isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();
    await _userService.changeUserName(_enteredUsername);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đổi tên thành công."),
        ),
      );
      Navigator.of(context).pop();
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        "Thay đổi tên người dùng",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                labelText: "Tên người dùng",
                prefixIcon: Icon(Icons.person),
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
              ),
              validator: (value) {
                if (value == null || value.isEmpty || value.trim().length < 4) {
                  return "Tên người dùng phải có ít nhất 4 ký tự.";
                }
                return null;
              },
              onSaved: (newValue) {
                _enteredUsername = newValue!;
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
        )
      ],
    );
  }
}
