import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:monprof/auths/datas/models/otp_model.dart';
import 'package:monprof/auths/logique_metier/otp_controller.dart';
import 'package:monprof/auths/presentation/reset_password.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/simple_text.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String? otpType;
  const OtpScreen({
    Key? key,
    required this.phone,
    this.otpType = OtpType.password,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => OtpScreenState();
}

class OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController controllerOTP = TextEditingController();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SimpleText(
          text: "Verification du Compte".tr,
          size: 16,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SimpleText(
                text:
                    "${"Renseignez le code que vous avez reçu par SMS sur le numéro ".tr}${widget.phone}",
              ),
              const SizedBox(height: 40),
              OtpFieldApp(
                validator: ValidationBuilder(
                        requiredMessage: "Renseignez un numéro de téléphone".tr)
                    .maxLength(4)
                    .minLength(4)
                    .required()
                    .build(),
                onChanged: (p0) {
                  controllerOTP.text = p0;
                },
                controller: controllerOTP,
              ),
              const Spacer(),
              GetBuilder<OtpController>(builder: (controller) {
                return DefaultButton(
                  text: "Valider".tr,
                  wdiget: controller.submitOTPState.isLoading || loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : null,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await controller.submitOTP(
                        widget.phone,
                        controllerOTP.text,
                      );
                      if (controller.submitOTPState.data == true) {
                        if (widget.otpType == OtpType.password) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ResetPasswordScreen(
                                code: controllerOTP.text,
                                phone: widget.phone,
                              ),
                            ),
                          );
                        } else {
                          setState(() => loading = true);
                          await controller.resetPassword(
                            widget.phone,
                            controllerOTP.text,
                            OtpType.phoneEmei,
                          );
                          setState(() => loading = false);
                          if (controller.resetPasswordState.data == true) {
                            Notify.toastSuccess(
                                "Votre telephone a été validé avec succès".tr);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            controller.resetPhoneFromFirestore(widget.phone);
                          } else if (controller.resetPasswordState.hasError) {
                            Notify.toastDanger(
                              controller.resetPasswordState.errorModel!.error,
                            );
                          }
                        }
                      } else if (controller.submitOTPState.hasError) {
                        Notify.toastDanger(
                          controller.submitOTPState.errorModel!.error,
                        );
                      }
                    }
                  },
                );
              }),
              SpacerHeight(MediaQuery.sizeOf(context).height * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
