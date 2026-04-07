import 'package:get/get.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/notification/data/notification_model.dart';
import 'package:monprof/notification/data/services/notification_api.dart';

class NotificationController extends GetxController {
  final NotificationApi api;
  NotificationController({required this.api});
  int currentPage = 1;

  AppState<int> unreadNotification = AppState<int>();
  AppState<List<NotificationModel>> notificationList =
      AppState<List<NotificationModel>>();
  AppState<bool> readNotification = AppState<bool>();

  @override
  onInit() {
    getUnreadNotification();
    super.onInit();
  }

  void getNotificationList({bool isRefresh = false}) {
    if (isRefresh) {
      currentPage = 1;
    }
    notificationList = AppState(status: AppStatus.loading);
    update();
    api.getMessageList(page: currentPage).then((value) {
      if (value.length >= 15) {
        currentPage++;
      }
      notificationList = AppState(data: value, status: AppStatus.data);
      update();
    }, onError: (e) {
      notificationList = AppState(
        status: AppStatus.error,
        errorModel: returnError(e),
      );
      update();
    });
  }

  void getUnreadNotification() {
    unreadNotification = AppState(status: AppStatus.loading);
    update();
    api.getUnreaNotification().then((value) {
      unreadNotification = AppState(data: value, status: AppStatus.data);
      update();
    }, onError: (e) {
      unreadNotification = AppState(
        status: AppStatus.error,
        errorModel: returnError(e),
      );
      update();
    });
  }

  Future readMessage(NotificationModel model) async {
    readNotification = AppState(status: AppStatus.loading);
    update();
    await api.readMessage(model).then((value) {
      readNotification = AppState(data: value, status: AppStatus.data);
      final message = model.copyWith(isRead: true);
      final index = notificationList.data!
          .indexWhere((element) => element.id == model.id);
      notificationList.data![index] = message;
      update();
    }, onError: (e) {
      readNotification = AppState(
        status: AppStatus.error,
        errorModel: returnError(e),
      );
      update();
    });
  }

  //End of the class
}
