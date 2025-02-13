import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final Icon? icon;
  final void Function() onTap;

  const SettingTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      onTap: onTap,
      leading: icon,
      title: Text(title),
    );
  }
}
