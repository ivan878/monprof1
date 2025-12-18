import 'dart:convert';
import 'dart:io';
// import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/notification/data/services/fcm_notification_services.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:koree/services/marketplace_service.dart';

// @pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }

  final payload = notificationResponse.payload;
  if (payload != null) {
    final RemoteMessage message = RemoteMessage.fromMap(jsonDecode(payload));
    NotificationService().handleOnReceiveMessage(message);
  }
}

class LocalNotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> initLocalNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@drawable/ic_launcher'); //app_icon

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      // onDidReceiveLocalNotification: (a, b, c, d) {
      //   printer("local Notification: $a, $b, $c, $d");
      // },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (message) async {
        final payload = message.payload;

        if (message.notificationResponseType ==
            NotificationResponseType.selectedNotification) {
          if (payload != null) {
            // final remote = RemoteMessage.fromMap(jsonDecode(payload));
            // loger("messageon vient de tapper sur cette Notification");
          }
        }
        notificationTapBackground(message);
      },
    );
  }

  static const androidChanel = AndroidNotificationChannel(
    'com.koree.delivery.app',
    'Koree Client App',
    description: 'Chaine de notification pour Koree clieny',
    importance: Importance.max,
  );

  Future<String?> getImageFromNotification(String imageUrl) async {
    final response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));
    final bytes = response.data;
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/notification_image.png';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  showLocalNotification(RemoteMessage message) async {
    var notification = message.notification;
    String? filePath;
    if (notification != null) {
      FilePathAndroidBitmap? filePathAndroidBitmap;
      if (notification.android?.imageUrl != null) {
        final filePathAndroid =
            await getImageFromNotification(notification.android!.imageUrl!);
        filePathAndroidBitmap = FilePathAndroidBitmap(filePathAndroid!);
        filePath = filePathAndroid;
      } else if (notification.apple?.imageUrl != null) {
        final filePathAndroid =
            await getImageFromNotification(notification.apple!.imageUrl!);
        filePath = filePathAndroid;
      }

      final isoNotificationDetails = DarwinNotificationDetails(
        attachments:
            filePath != null ? [DarwinNotificationAttachment(filePath)] : null,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final informations = filePathAndroidBitmap == null
          ? BigTextStyleInformation(
              "${notification.body}",
              htmlFormatBigText: true,
            )
          : BigPictureStyleInformation(
              filePathAndroidBitmap,
              contentTitle: notification.title,
              summaryText: "${notification.body}",
              htmlFormatSummaryText: true,
              htmlFormatContent: true,
              htmlFormatContentTitle: true,
              htmlFormatTitle: true,
            );
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        androidChanel.id,
        androidChanel.name,
        icon: '@drawable/ic_launcher',
        channelDescription: androidChanel.description,
        styleInformation: informations,
        importance: Importance.max,
        priority: Priority.max,
        ticker: 'Koree',
      );
      NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails, iOS: isoNotificationDetails);

      if (notification.title != null) {
        await flutterLocalNotificationsPlugin.show(
          0,
          notification.title,
          notification.body,
          notificationDetails,
          payload: jsonEncode({'data': message.data}),
        );
      }
    }
  }

////
  final paylod = {'event_type': 'NEW_ARTICLE', 'topic': "{'id': 23}"};
  testeNotif() {
    final RemoteMessage message = RemoteMessage(
      notification: const RemoteNotification(title: 'teste', body: 'actions'),
      data: paylod,
    );
    showLocalNotification(message);
  }

  ///
}
