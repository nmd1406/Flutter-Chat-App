import 'dart:io';

import 'package:chat_app/screens/forget_password.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

final _auth = AuthService();

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  bool _passwordObscure = true;
  bool _isLogin = true;
  bool _isAuthenticating = false;
  String _enteredEmail = "";
  String _enteredPassword = "";
  String _enteredUsername = "";
  File? _selectedImage;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();
    String? errorMessage = "";
    setState(() {
      _isAuthenticating = true;
    });
    if (_isLogin) {
      errorMessage = await _auth.signIn(_enteredEmail, _enteredPassword);
    } else {
      _selectedImage ??= await _getAssetImageAsFile();

      errorMessage = await _auth.signUp(
        _enteredEmail,
        _enteredPassword,
        _enteredUsername,
        _selectedImage!,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? "Xác thực thất bại."),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });

      return;
    }
  }

  Future<File> _getAssetImageAsFile() async {
    String path =
        "assets/images/default-avatar-profile-icon-of-social-media-user-vector.jpg";
    var data = await rootBundle.load(path);
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

    return file;
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
              Lottie.asset(
                "assets/lottie/auth-screen.json",
                width: 350,
                height: 320,
                fit: BoxFit.cover,
                animate: true,
                repeat: true,
              ),
              AnimatedSize(
                duration: Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: Card(
                  key: ValueKey(_isLogin),
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
                            Visibility(
                              visible: !_isLogin,
                              child: Padding(
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
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Mật khẩu",
                                prefixIcon: Icon(Icons.key),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _passwordObscure = !_passwordObscure;
                                    });
                                  },
                                  icon: _passwordObscure
                                      ? Icon(Icons.visibility)
                                      : Icon(Icons.visibility_off),
                                ),
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
                              obscureText: _passwordObscure,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
