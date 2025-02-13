import 'dart:io';

import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
        return "No user found with this email.";
      case "wrong-password":
        return "Incorrect password. Please try again.";
      case "invalid-email":
        return "Invalid email format.";
      case "user-disabled":
        return "This user account has been disabled.";
      case "too-many-requests":
        return "Too many attempts. Please try again later.";
      case "network-request-failed":
        return "Lỗi kết nối mạng. Vui lòng thử lại sau,";
      default:
        return "Authentication failed. Please try again.";
    }
  }

  Future<File> _getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (exception) {
      print(exception.message);
      return _handleAuthException(exception);
    }
    return null;
  }

  Future<String?> signUp(
      String email, String password, String username, File? image) async {
    try {
      final userCredentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final storageRef = _storage
          .ref()
          .child("user_images")
          .child("${userCredentials.user!.uid}.jpg");

      if (image == null) {
        File defaultImage = await _getImageFileFromAssets(
            "images/default-avatar-profile-icon-of-social-media-user-vector.jpg");
        await storageRef.putFile(defaultImage);
      } else {
        await storageRef.putFile(image);
      }

      final imageUrl = await storageRef.getDownloadURL();
      _auth.currentUser!.updatePhotoURL(imageUrl);
      await _firestore.collection("users").doc(userCredentials.user!.uid).set({
        "username": username,
        "email": email,
        "image_url": imageUrl,
      });
    } on FirebaseAuthException catch (exception) {
      return _handleAuthException(exception);
    }
    return null;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> changePassword(String newPassword) async {
    var user = _auth.currentUser;
    try {
      await user!.updatePassword(newPassword);
      await _auth.signOut();
    } on FirebaseAuthException catch (exception) {
      // TODO
      print(exception.message);
    }
  }

  Future<bool> validatePassword(String password) async {
    var user = _auth.currentUser;
    var userCredential = EmailAuthProvider.credential(
      email: user!.email!,
      password: password,
    );
    try {
      var authResult = await user.reauthenticateWithCredential(userCredential);
      return authResult.user != null;
    } on FirebaseAuthException catch (exception) {
      // handle exceptions...
      print(exception.message);
      return false;
    }
  }

  String getCurrentUserUid() {
    return _auth.currentUser!.uid;
  }

  User getCurrentUser() {
    return _auth.currentUser!;
  }

  void signOut() async {
    await _auth.signOut();
  }
}
