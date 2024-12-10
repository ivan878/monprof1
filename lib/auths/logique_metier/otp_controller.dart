import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:monprof/auths/datas/models/otp_model.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';

class OtpController extends GetxController {
  final UserRepository repository = GetIt.instance<UserRepository>();
  AppState<OtpModel> requestOTPState = AppState<OtpModel>();
  AppState<bool> submitOTPState = AppState<bool>();
  AppState<bool> resetPasswordState = AppState<bool>();

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
      final response = await repository.verifyOTP(
        requestOTPState.data?.verificationId ?? "",
        otp,
        phone,
      );
      submitOTPState = response;
    } catch (e) {
      submitOTPState = AppState(
        status: AppStatus.error,
        errorModel: returnError(e),
      );
    }
    update();
  }

  Future<void> resetPassword(String phone, String otp, String type,
      {String? password}) async {
    resetPasswordState = AppState(status: AppStatus.loading);
    update();
    try {
      final response = await repository.resetPassword(
        phone,
        otp,
        type,
        requestOTPState.data!.verificationId ?? '',
        password: password,
      );
      resetPasswordState = response;
    } catch (e) {
      submitOTPState = AppState(
        status: AppStatus.error,
        errorModel: returnError(e),
      );
    }
    update();
  }

  resetPhoneFromFirestore(String phone) async {
    final mobileDeviceIdentifier = await MobileDeviceIdentifier().getDeviceId();
    FirebaseFirestore.instance.collection('UserDevices').doc(phone).set({
      'user_device': mobileDeviceIdentifier,
    });
  }
}
