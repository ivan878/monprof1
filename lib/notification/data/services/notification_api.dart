import 'package:dio/dio.dart';
import 'package:monprof/corps/api_service.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/notification/data/notification_model.dart';

class NotificationApi {
  final Dio dio;

  NotificationApi({required this.dio});

  Future<int> getUnreaNotification() async {
    final headers = await header();
    try {
      final response = await dio.get('/notifications/unread',
          options: Options(headers: headers));
      if (response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw CustomException(message: response.data['data']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NotificationModel>> getMessageList({int page = 1}) async {
    final headers = await header();
    try {
      final response = await dio.get('/notifications?page=$page',
          options: Options(headers: headers));
      if (response.data['status'] == true) {
        return (response.data['data']['data'] as List)
            .map((e) => NotificationModel.fromMap(e))
            .toList();
      } else {
        throw CustomException(message: response.data['data']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future readMessage(NotificationModel model) async {
    try {
      final headers = await header();
      final response = await dio.put(
        '/notifications/read',
        queryParameters: {'message_id': model.id},
        options: Options(headers: headers),
      );
      if (response.data['status'] == true) {
        return true;
      } else {
        throw CustomException(message: response.data['data']);
      }
    } catch (e) {
      rethrow;
    }
  }

  //
}
