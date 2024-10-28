import 'package:chat_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _auth = AuthService();

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _enteredEmail = "";

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();
    _formKey.currentState!.reset();
    FocusScope.of(context).unfocus();

    try {
      await _auth.resetPassword(_enteredEmail);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              "Gửi thành công",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Text("Kiểm tra email của bạn để truy cập liên kết"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text("Quay lại đăng nhập"),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (exception) {
      print(exception.message);
      // handle exceptions....
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Card(
          elevation: 60,
          child: SizedBox(
            width: 380,
            height: 450,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_reset_sharp,
                    size: 110,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Đặt lại mật khẩu",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Nhập email của bạn và chúng tôi sẽ gửi cho bạn liên kết để đặt lại mật khẩu tài khoản.",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
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
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains('@')) {
                          return "Email không hợp lệ!";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredEmail = newValue!;
                      },
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Text("Gửi liên kết"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Quay lại đăng nhập"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
