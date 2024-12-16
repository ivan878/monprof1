import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/notification/notification_controller.dart';
import 'package:monprof/notification/screnn/notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<NotificationController>().getNotificationList(isRefresh: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
        builder: (NotificationController controller) {
      return Scaffold(
        appBar: AppBar(
          title: SimpleText(text: 'List des Notifications'.tr),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Builder(builder: (_) {
            if (controller.notificationList.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.notificationList.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SimpleText(
                      text: controller.notificationList.errorModel!.error,
                      size: 16,
                      color: red,
                    ),
                    IconButton(
                        onPressed: () {
                          controller.getNotificationList();
                        },
                        icon: const Icon(Icons.refresh)),
                  ],
                ),
              );
            }

            if (controller.notificationList.hasData &&
                controller.notificationList.data!.isEmpty) {
              return Center(child: SimpleText(text: 'Aucune notification'.tr));
            }

            if (controller.notificationList.data == null) {
              return Center(
                child: SimpleText(text: 'Aucune notification'.tr),
              );
            }
            return ListView.builder(
              itemCount: controller.notificationList.data!.length,
              itemBuilder: (context, index) {
                final item = controller.notificationList.data![index];
                return Container(
                  decoration: BoxDecoration(
                    border: item.id == controller.notificationList.data!.last.id
                        ? null
                        : Border(
                            bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: ListTile(
                    onTap: () {
                      if (!item.isRead) controller.readMessage(item);
                      changeScreen(context,
                          NotificationDetailScreen(notification: item));
                    },
                    contentPadding: const EdgeInsets.all(0),
                    leading: const Icon(Icons.message_outlined),
                    title:
                        SimpleText(text: item.title, weight: FontWeight.bold),
                    subtitle: SimpleText(
                      text: item.body,
                      maxlines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: item.isRead
                        ? const Icon(Icons.done_all_outlined)
                        : Icon(Icons.circle, color: primaryColor),
                  ),
                );
              },
            );
          }),
        ),
      );
    });
  }
}
