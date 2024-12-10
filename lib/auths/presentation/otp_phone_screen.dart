import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:monprof/auths/datas/models/otp_model.dart';
import 'package:monprof/auths/logique_metier/otp_controller.dart';
import 'package:monprof/auths/presentation/otp_screen.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/simple_text.dart';

class OtpPhoneScreen extends StatefulWidget {
  final String type;
  const OtpPhoneScreen({
    Key? key,
    this.type = OtpType.password,
  }) : super(key: key);

  @override
  State<OtpPhoneScreen> createState() => OtpPhoneScreenState();
}

class OtpPhoneScreenState extends State<OtpPhoneScreen> {
  TextEditingController controllerPhone = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SimpleText(
          text: "Verification du Compte",
          size: 16,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SimpleText(
                text:
                    "Renseignez le numero de telephone avec lequel vous avez effectuer l'inscription",
              ),
              const SizedBox(height: 40),
              TextFielApp(
                validator: ValidationBuilder(
                        requiredMessage: "Renseignez un numéro de téléphone")
                    .maxLength(9, 'le numéro a 9 chiffre')
                    .minLength(9, 'le numéro a 9 chiffre')
                    .required()
                    .build(),
                controller: controllerPhone,
                onChanged: (p0) {
                  if (p0.length == 9) {
                    FocusScope.of(context).unfocus();
                  }
                },
                lenght: 9,
                hinText: 'Téléphone',
                suffixIcon: const Icon(Icons.phone_outlined),
              ),
              const Spacer(),
              GetBuilder<OtpController>(
                  init: OtpController(),
                  builder: (controller) {
                    return DefaultButton(
                      text: "Valider",
                      wdiget: controller.requestOTPState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : null,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await controller.requestOTP(controllerPhone.text);
                          if (controller.requestOTPState.hasData) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => OtpScreen(
                                  phone: controllerPhone.text,
                                  otpType: widget.type,
                                ),
                              ),
                            );
                          } else if (controller.requestOTPState.hasError) {
                            Notify.toastDanger(
                              controller.requestOTPState.errorModel!.error,
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
