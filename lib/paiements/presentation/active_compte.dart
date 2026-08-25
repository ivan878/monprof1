import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:form_validator/form_validator.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/paiements/logique_metier/paiement_controller.dart';
import 'package:monprof/paiements/datas/reposytory/paiement_ripository.dart';

class ActiveCompte extends StatefulWidget {
  const ActiveCompte({super.key});

  @override
  State<ActiveCompte> createState() => _ActiveCompteState();
}

class _ActiveCompteState extends State<ActiveCompte> {
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init:
          PaiementsController(repository: GetIt.instance<PaiementRepository>()),
      builder: (PaiementsController controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("Activer un abonnement".tr),
          ),
          body: Form(
            key: formKey,
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SimpleText(
                    text:
                        "S'il vous plait, veuillez entrer le code d'activation reçu par SMS ou par mail."
                            .tr,
                  ),
                  const SizedBox(height: 10),
                  TextFielApp(
                    controller: controller.controllerCode,
                    validator: ValidationBuilder(
                            requiredMessage:
                                "Veuillez entrer un code d'activation".tr)
                        .minLength(6, 'code invalide'.tr)
                        .build(),
                    hinText: "Code d'activation".tr,
                  ),
                  const Spacer(),
                  DefaultButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await controller.activeCode();
                        if (!context.mounted) return;

                        if (controller.codeActivationState.hasError) {
                          Notify.showFailure(
                            context,
                            controller.codeActivationState.errorModel?.error ??
                                "",
                          );
                        } else if (controller.codeActivationState.hasData) {
                          Notify.showSuccess(
                            context,
                            'Code active avec succes'.tr,
                          );
                          Navigator.pop(context);
                          await Get.find<HomeController>().getCategorie();
                        }
                      }
                    },
                    text: 'Valider'.tr,
                    wdiget: controller.codeActivationState.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(5.0),
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
