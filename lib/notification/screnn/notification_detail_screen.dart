import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/notification/data/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SimpleText(text: 'Détails'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SimpleText(
              text: notification.title,
              size: 18,
              weight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            SimpleText(
              text: notification.body,
              size: 16,
            ),
            SpacerHeight(15),
            if (notification.createdAt != null)
              Align(
                alignment: Alignment.centerRight,
                child: SimpleText(
                  text: DateFormat('EEEE d MMM y h:m')
                      .format(notification.createdAt!),
                  size: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
