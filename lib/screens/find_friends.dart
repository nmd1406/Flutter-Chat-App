import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:chat_app/widgets/user_tile.dart';
import 'package:flutter/material.dart';

final _userService = UserService();
final _authService = AuthService();

class FindPeopleScreen extends StatefulWidget {
  const FindPeopleScreen({super.key});

  @override
  State<FindPeopleScreen> createState() => _FindPeopleScreenState();
}

class _FindPeopleScreenState extends State<FindPeopleScreen> {
  final _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String query = _searchController.text;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: SearchBar(
            controller: _searchController,
            hintText: "Tìm kiếm",
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            onSubmitted: (value) {
              setState(() {
                query = value;
              });
            },
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            leading: Icon(Icons.search),
            trailing: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                  });
                },
                icon: Icon(Icons.close_rounded),
              )
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: _userService.getUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text("Không có người dùng"),
                );
              }

              final currentUserUid = _authService.getCurrentUserUid();
              final userData = snapshot.data!.docs
                  .where((doc) => doc.id != currentUserUid)
                  .where(
                (doc) {
                  final user = doc.data();
                  return user["username"].contains(query);
                },
              ).toList();

              if (userData.isEmpty) {
                return Center(
                  child: Text("Không có người dùng"),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: userData.length,
                itemBuilder: (context, index) {
                  final user = userData[index].data();
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
        ),
      ],
    );
  }
}
