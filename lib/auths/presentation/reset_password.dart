import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:monprof/auths/datas/models/otp_model.dart';
import 'package:monprof/auths/logique_metier/otp_controller.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/simple_text.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String code;
  final String phone;
  const ResetPasswordScreen({Key? key, required this.code, required this.phone})
      : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController passWordController = TextEditingController();
  TextEditingController confirmPassWordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const SimpleText(
          text: "Modification du mot de passe",
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
                text: "Renseignez le nouveau mot de passe",
                size: 16,
                weight: FontWeight.bold,
              ),
              const SizedBox(height: 20),
              // SpacerHeight(5),
              // const SimpleText(
              //   text: "Mot de passe",
              // ),
              TextFielApp(
                validator: ValidationBuilder(
                        requiredMessage: "Le mot de passe est obligatoire")
                    .minLength(
                        6, 'le mot de passe doit avoir au moins 6 caractères')
                    .required()
                    .build(),
                controller: passWordController,
                hinText: 'Mot de passe',
                suffixIcon: const Icon(Icons.security),
              ),
              const SizedBox(height: 15),
              // const SimpleText(
              //   text: "Confirmer le mot de passe",
              // ),
              // SpacerHeight(5),
              TextFielApp(
                validator: ValidationBuilder(
                        requiredMessage:
                            "Confirmer le mot de passe est obligatoire")
                    .required()
                    .add((val) {
                  if (val == passWordController.text) {
                    return null;
                  } else {
                    return 'Les mots de passe ne correspondent pas';
                  }
                }).build(),
                controller: confirmPassWordController,
                hinText: 'Confirmer le mot de passe',
                suffixIcon: const Icon(Icons.security),
              ),
              const Spacer(),
              GetBuilder<OtpController>(builder: (controller) {
                return DefaultButton(
                  text: "Valider",
                  wdiget: controller.resetPasswordState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : null,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await controller.resetPassword(
                        widget.phone,
                        widget.code,
                        OtpType.password,
                        password: passWordController.text,
                      );
                      if (controller.resetPasswordState.data == true) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Notify.toastSuccess("Mot de passe modifié avec succès");
                      } else if (controller.resetPasswordState.hasError) {
                        Notify.toastDanger(
                          controller.resetPasswordState.errorModel!.error,
                        );
                      }
                    }
                  },
                );
              }),
              SpacerHeight(MediaQuery.sizeOf(context).height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
