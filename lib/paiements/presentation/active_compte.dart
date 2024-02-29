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
            title: const Text("Activer un abonnement"),
          ),
          body: controller.paiementState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: formKey,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SimpleText(
                          text:
                              "S'il vous plait, veuillez entrer le code d'activation"
                              "reçu par SMS ou par mail.",
                        ),
                        const SizedBox(height: 10),
                        TextFielApp(
                          controller: controller.controllerCode,
                          validator: ValidationBuilder(
                                  requiredMessage:
                                      "Veuillez entrer un code d'activation")
                              .minLength(6, 'code invalide')
                              .build(),
                          hinText: "Code d'activation",
                        ),
                        const Spacer(),
                        DefaultButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await controller.activeCode().then((value) async {
                                if (controller.paiementState.hasError) {
                                  Notify.showFailure(
                                      context,
                                      controller.paiementState.errorModel
                                              ?.error ??
                                          "");
                                } else if (controller.paiementState.hasData) {
                                  Notify.showSuccess(
                                      context, 'Code active avec succes');
                                  Navigator.pop(context);
                                  await Get.find<HomeController>()
                                      .getCategorie();
                                }
                              });
                            }
                          },
                          text: 'Valider',
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
