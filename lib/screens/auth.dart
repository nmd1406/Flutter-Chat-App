import 'dart:io';

import 'package:chat_app/screens/forget_password.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _auth = AuthService();

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isAuthenticating = false;
  String _enteredEmail = "";
  String _enteredPassword = "";
  String _enteredUsername = "";
  File? _selectedImage;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || (!_isLogin && _selectedImage == null)) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        await _auth.signIn(_enteredEmail, _enteredPassword);
      } else {
        await _auth.signUp(
            _enteredEmail, _enteredPassword, _enteredUsername, _selectedImage!);
      }
    } on FirebaseAuthException catch (exception) {
      if (exception.code == "email-already-in-use") {
        // handle exception
      }

      // handle some exceptions...

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.message ?? "Xác thực thất bại."),
          ),
        );
        setState(() {
          _isAuthenticating = false;
        });
      }

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                ),
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: TextFormField(
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
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return "Email không hợp lệ.";
                                }

                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredEmail = newValue!;
                              },
                            ),
                          ),
                          if (!_isLogin)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
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
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                      width: 1.3,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                                enableSuggestions: false,
                                autocorrect: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 4) {
                                    return "Tên người dùng phải có ít nhất 4 ký tự.";
                                  }

                                  return null;
                                },
                                onSaved: (newValue) {
                                  _enteredUsername = newValue!;
                                },
                              ),
                            ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Mật khẩu",
                              prefixIcon: Icon(Icons.key),
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
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return "Mật khẩu phải chứa ít nhất 6 ký tự.";
                              }

                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredPassword = newValue!;
                            },
                          ),
                          if (_isLogin)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ForgetPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Quên mật khẩu?",
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating) CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(_isLogin ? "Đăng nhập" : "Đăng ký"),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? "Tạo tài khoản"
                                  : "Bạn có tài khoản? Đăng nhập"),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
