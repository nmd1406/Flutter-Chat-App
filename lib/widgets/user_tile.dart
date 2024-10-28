import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String username;
  final String imageUrl;
  final void Function() onOpenMessage;

  const UserTile({
    super.key,
    required this.username,
    required this.imageUrl,
    required this.onOpenMessage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenMessage,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          // contentPadding: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          tileColor: Theme.of(context).colorScheme.inversePrimary,
          leading: CircleAvatar(
            radius: 24,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withAlpha(180),
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text(username),
          subtitle: Text("Tin nhan"),
        ),
      ),
    );
  }
}
