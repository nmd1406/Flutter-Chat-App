import 'package:animations/animations.dart';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(14.0),
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
              ),
            ],
          ),
        ),
        if (query.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            child: Text(
              'Gợi ý',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
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

              // List người dùng hiển thị không bao gồm bản thân
              // Shuffle phục vụ cho chức năng gợi ý người dùng khác
              final currentUserUid = _authService.getCurrentUserUid();
              final userData = snapshot.data!.docs
                  .where((doc) => doc.id != currentUserUid)
                  .where(
                (doc) {
                  final user = doc.data();
                  return user["username"].contains(query);
                },
              ).toList()
                ..shuffle();

              if (userData.isEmpty) {
                return Center(
                  child: Text("Không có người dùng"),
                );
              }

              // Khi tìm kiếm người dùng thì hiển thị tất cả các kết quả trùng khớp
              // Đối với phần gợi ý khi không tìm kiếm thì chỉ hiển thị tối đa 10 người dùng
              int userDisplayCount = query.isEmpty
                  ? (userData.length < 10 ? userData.length : 10)
                  : userData.length;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: userDisplayCount,
                itemBuilder: (context, index) {
                  final user = userData[index].data();
                  final otherUserId = userData[index].id;
                  final username = user["username"];
                  final imageUrl = user["image_url"];

                  return OpenContainer(
                    closedColor: Colors.transparent,
                    closedElevation: 0,
                    openElevation: 0,
                    transitionDuration: Duration(milliseconds: 320),
                    middleColor: Theme.of(context).scaffoldBackgroundColor,
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    openShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    closedBuilder: (context, openContainer) => UserTile(
                      username: username,
                      imageUrl: imageUrl,
                      onOpenMessage: openContainer,
                    ),
                    openBuilder: (context, closeContainer) => ChatScreen(
                      otherUserData: user,
                      otherUserId: otherUserId,
                    ),
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
