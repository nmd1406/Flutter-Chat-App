import 'package:chat_app/screens/home.dart';
import 'package:chat_app/screens/onboarding.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'package:chat_app/screens/splash.dart';
import 'package:chat_app/screens/auth.dart';

final navigatorKey = GlobalKey<NavigatorState>();

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

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool("isFirstTime") ?? true;

  await NotificationService.initialize();
  await NotificationService.saveFCMToken();
  await NotificationService.listenToFCMTokenChange();
  await NotificationService.backgroundNotification();
  await NotificationService.foregroundNotification();

  runApp(App(isFirstTime: isFirstTime));
}

class App extends StatelessWidget {
  final bool isFirstTime;

  const App({
    super.key,
    required this.isFirstTime,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
      home: isFirstTime
          ? OnboardingSceen()
          : StreamBuilder(
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
