import 'package:chat_app/screens/find_friends.dart';
import 'package:chat_app/screens/messages.dart';
import 'package:chat_app/screens/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 1;
  final List<Widget> _screens = [
    MessagesScreen(),
    FindPeopleScreen(),
    SettingScreen(),
  ];

  final List<String> _screenTitles = [
    "FlutterChat",
    "Mọi người",
    "Cài đặt",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _screenTitles[_currentPageIndex],
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ),
        ],
      ),
      body: _screens[_currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            _currentPageIndex = value;
          });
        },
        selectedIndex: _currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            label: "Tin nhắn",
            icon: Icon(Icons.chat_rounded),
          ),
          NavigationDestination(
            label: "Mọi người",
            icon: Icon(Icons.people),
          ),
          NavigationDestination(
            label: "Cài đặt",
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
