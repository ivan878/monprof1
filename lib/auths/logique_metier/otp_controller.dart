import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/auths/datas/models/otp_model.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';

class OtpController extends GetxController {
  final UserRepository repository = GetIt.instance<UserRepository>();
  AppState<OtpModel> requestOTPState = AppState<OtpModel>();
  AppState<bool> submitOTPState = AppState<bool>();

  Future<void> requestOTP(String phone) async {
    requestOTPState = AppState(status: AppStatus.loading);
    update();
    try {
      final response = await repository.requestOTP(phone);
      requestOTPState = response;
    } catch (e) {
      requestOTPState = AppState(
        status: AppStatus.error,
        errorModel: returnError(e),
      );
    }
    update();
  }

  Future<void> submitOTP(String phone, String otp) async {
    submitOTPState = AppState(status: AppStatus.loading);
    update();
    try {
      final response = await repository.verifyOTP(phone, otp);
      submitOTPState = response;
    } catch (e) {
      submitOTPState = AppState(
        status: AppStatus.error,
        errorModel: returnError(e),
      );
    }
    update();
  }
}
