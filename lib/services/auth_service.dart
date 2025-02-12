import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      final userCredentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredentials;
    } on FirebaseAuthException catch (exception) {
      throw Exception(exception.message);
    }
  }

  Future<UserCredential> signUp(
      String email, String password, String username, File image) async {
    try {
      final userCredentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final storageRef = _storage
          .ref()
          .child("user_images")
          .child("${userCredentials.user!.uid}.jpg");
      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();
      _auth.currentUser!.updatePhotoURL(imageUrl);
      await _firestore.collection("users").doc(userCredentials.user!.uid).set({
        "username": username,
        "email": email,
        "image_url": imageUrl,
      });

      return userCredentials;
    } on FirebaseAuthException catch (exception) {
      throw Exception(exception.message);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  void changePassword(String newPassword) async {
    var user = _auth.currentUser;
    try {
      await user!.updatePassword(newPassword);
      signOut();
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
