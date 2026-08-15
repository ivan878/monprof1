// import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/notification/data/services/local_notification_service.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // LocalNotificationService().showLocalNotification(message);
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? deviceToken;

  Future<String?> getToken() async => await _firebaseMessaging.getToken();

  Future<void> init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    LocalNotificationService().initLocalNotification();
    initPushNotification();
  }

  initPushNotification() async {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      sound: true,
      badge: true,
    );
    FirebaseMessaging.instance
        .getInitialMessage()
        .then(handleGetInitialMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageOpenApp);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(handleOnMessage);
  }

  handleMessageOpenApp(RemoteMessage? message) async {
    if (message == null) return;

    handleOnReceiveMessage(message);
  }

  handleGetInitialMessage(RemoteMessage? message) async {
    if (message == null) return;
    LocalNotificationService().showLocalNotification(message);
    handleOnReceiveMessage(message);
  }

  handleMessage(RemoteMessage? message) async {
    if (message == null) return;
    LocalNotificationService().showLocalNotification(message);
    handleOnReceiveMessage(message);
  }

  handleOnMessage(RemoteMessage message) async {
    printer(message.notification?.toMap(), type: 'w');
    if (Platform.isAndroid) {
      LocalNotificationService().showLocalNotification(message);
    }
    handleOnReceiveMessage(message);
  }

  void handleOnReceiveMessage(RemoteMessage? message) async {
    printer(message?.toMap(), type: 'w');
    loger("All ${message?.toMap()}");
    if (message?.data != null) {
      loger("message ${message?.data}");
      loger("Notification ${message?.data}");
      printer(message?.data ?? '', type: '');
      final type = message!.data['EVENT_TYPE'];
      if (type == 'APP_MESSAGE') {}
    }
  }
}
