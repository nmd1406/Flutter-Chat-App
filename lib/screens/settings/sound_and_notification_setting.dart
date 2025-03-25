import 'package:flutter/material.dart';

class SoundAndNotificationSettingScreen extends StatelessWidget {
  const SoundAndNotificationSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thông báo & âm thanh",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
