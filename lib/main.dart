import 'package:chat_app/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:chat_app/screens/splash.dart';
import 'package:chat_app/screens/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  await saveFCMToken();
  await listenToFCMTokenChange();
  runApp(const App());
}

Future<void> listenToFCMTokenChange() async {
  FirebaseMessaging.instance.onTokenRefresh.listen(
    (event) async {
      await saveFCMToken();
    },
  );
}

Future<void> saveFCMToken() async {
  var user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return;
  }

  String uid = user.uid;
  String? token = await FirebaseMessaging.instance.getToken();

  if (token == null) {
    Future.delayed(Duration(seconds: 10), () => saveFCMToken());
    return;
  }

  await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .update({"fcmToken": token});
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
        iconTheme: IconThemeData(
          size: 30,
          color: Theme.of(context).primaryColor,
        ),
      ),
      routes: {
        "/auth": (context) => AuthScreen(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            // return const ChatScreen();
            return const HomeScreen();
          }

          return const AuthScreen();
        },
      ),
    );
  }
}
