import 'package:flutter/material.dart';

import 'package:chat_app/screens/find_friends.dart';
import 'package:chat_app/screens/messages.dart';
import 'package:chat_app/screens/settings/setting.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/user_service.dart';

final _authService = AuthService();
final _userService = UserService();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 0;
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

  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: 0,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildAvatar() {
    return StreamBuilder(
      stream: _userService.getUserData(_authService.getCurrentUserUid()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text("Lỗi load data"),
          );
        }

        String imageUrl = snapshot.data!["image_url"];

        return CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        );
      },
    );
  }

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
          if (_currentPageIndex != 2)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _buildAvatar(),
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            _pageController.animateToPage(
              value,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
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
