import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:chat_app/widgets/user_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _userService = UserService();
final _authService = AuthService();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FlutterChat",
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
      body: Column(
        children: [
          StreamBuilder(
            stream: _userService.getUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text("Không có tin nhắn"),
                );
              }

              final currentUserUid = _authService.getCurrentUserUid();
              final usersData = snapshot.data!.docs
                  .where((doc) => doc.id != currentUserUid)
                  .toList();

              return ListView.builder(
                shrinkWrap: true,
                itemCount: usersData.length,
                itemBuilder: (context, index) {
                  final user = usersData[index].data();
                  final username = user["username"];
                  final imageUrl = user["image_url"];

                  return UserTile(
                    username: username,
                    imageUrl: imageUrl,
                    onOpenMessage: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.chat_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.people),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
