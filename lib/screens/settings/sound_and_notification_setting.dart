import 'package:app_settings/app_settings.dart';
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
      body: Column(
        children: [
          ListTile(
            titleTextStyle: Theme.of(context).textTheme.titleMedium,
            onTap: () async {
              await AppSettings.openAppSettings(
                  type: AppSettingsType.notification);
            },
            title: Text("Tuỳ chỉnh âm thanh"),
          ),
        ],
      ),
    );
  }
}
