import 'package:chat_app/providers/first_time_opening_app.dart';
import 'package:chat_app/screens/home.dart';
import 'package:chat_app/screens/onboarding.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  await NotificationService.initialize();
  await NotificationService.saveFCMToken();
  await NotificationService.listenToFCMTokenChange();
  await NotificationService.backgroundNotification();
  await NotificationService.foregroundNotification();

  runApp(
    ProviderScope(
      child: App(),
    ),
  );
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    ref.read(firstTimeOpeningAppProvider.notifier).state = isFirstTime;
  }

  @override
  Widget build(BuildContext context) {
    _isFirstTime = ref.watch(firstTimeOpeningAppProvider);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
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
      home: _isFirstTime
          ? const OnboardingScreen()
          : StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }
                if (snapshot.hasData) {
                  return const HomeScreen();
                }
                return const AuthScreen();
              },
            ),
    );
  }
}
