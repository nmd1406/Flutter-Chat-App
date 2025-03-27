import 'dart:convert';

import 'package:chat_app/screens/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/main.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        "This channel is used for important notifications.", // description
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound("notify"),
  );

  static Future<void> initialize() async {
    await requestNotificationPermission();
    await _setUpForegroundNotification();
  }

  static Future<void> listenToFCMTokenChange() async {
    _messaging.onTokenRefresh.listen(
      (event) async {
        await saveFCMToken();
      },
    );
  }

  static Future<void> saveFCMToken({int retryCount = 0}) async {
    var user = _auth.currentUser;
    if (user == null) {
      return;
    }

    const int maxRetry = 3;

    String uid = user.uid;
    String? token = await _messaging.getToken();

    if (token == null) {
      if (retryCount < maxRetry) {
        Future.delayed(
          Duration(seconds: 10),
          () => saveFCMToken(retryCount: retryCount + 1),
        );
      }
      return;
    }

    await _firestore.collection("users").doc(uid).update({"fcmToken": token});
  }

  static Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      return;
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _showNotificationDeniedDialog();
    }
  }

  static Future<void> _setUpForegroundNotification() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);
    _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        if (notificationResponse.payload != null) {
          String? payload = notificationResponse.payload;

          Map<String, String> data = jsonDecode(payload!);
          Map<String, String> otherUserData = {
            "email": data["senderEmail"]!,
            "fcmToken": data["senderFCMToken"]!,
            "image_url": data["senderImageUrl"]!,
            "username": data["senderUsername"]!,
          };
          String otherUserId = data["senderId"]!;

          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => ChatScreen(
              otherUserData: otherUserData,
              otherUserId: otherUserId,
            ),
          ));
        } else {
          return;
        }
      },
    );
  }

  static void _showNotificationDeniedDialog() {
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Thông báo bị tắt"),
              content: Text(
                  "Bạn đã từ chối cấp quyền thông báo. Bạn sẽ không còn nhận thông báo tin nhắn mới. Bạn muốn cấp lại quyền thông báo chứ?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Tiếp tục mà không bật thông báo"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    // implement open setting screen later...
                  },
                  child: Text("Cho phép bật thông báo"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> backgroundNotification() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    // Nếu user ấn vào noti khi app bị terminate
    if (initialMessage != null) {
      _onTapNotification(initialMessage);
    }

    // nếu app đang ở background
    FirebaseMessaging.onMessageOpenedApp.listen(_onTapNotification);
  }

  static Future<void> foregroundNotification() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: android.smallIcon,
              importance: Importance.max,
              playSound: true,
              sound: RawResourceAndroidNotificationSound("notify"),
            ),
          ),
          payload: jsonEncode({
            "email": message.data["senderEmail"],
            "fcmToken": message.data["senderFCMToken"],
            "image_url": message.data["senderImageUrl"],
            "username": message.data["senderUsername"],
            "otherUserId": message.data["senderId"],
          }),
        );
      }
    });
  }

  static void _onTapNotification(RemoteMessage message) {
    Map<String, String> otherUserData = {
      "email": message.data["senderEmail"],
      "fcmToken": message.data["senderFCMToken"],
      "image_url": message.data["senderImageUrl"],
      "username": message.data["senderUsername"],
    };
    String otherUserId = message.data["senderId"];

    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => ChatScreen(
        otherUserData: otherUserData,
        otherUserId: otherUserId,
      ),
    ));

    return;
  }
}
