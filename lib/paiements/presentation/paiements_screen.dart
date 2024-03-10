import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:form_validator/form_validator.dart';
import 'package:monprof/components/row_compte.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/paiements/logique_metier/paiement_controller.dart';
import 'package:monprof/paiements/datas/reposytory/paiement_ripository.dart';

class PaiementsScreen extends StatefulWidget {
  const PaiementsScreen({super.key});

  @override
  State<PaiementsScreen> createState() => _PaiementsScreenState();
}

class _PaiementsScreenState extends State<PaiementsScreen> {
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init:
          PaiementsController(repository: GetIt.instance<PaiementRepository>()),
      builder: (PaiementsController controller) {
        return Scaffold(
            appBar: AppBar(
              title: const Text("Paiements d'un abonnement"),
            ),
            body: controller.paiementState.isLoading
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: const CircularProgressIndicator(),
                    ),
                  ))
                : Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      child: Form(
                        key: key,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            rowCompte(Colors.blue, "Informations sur la classe",
                                Icons.school),
                            const SizedBox(
                              height: 10,
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(10),
                              elevation: 2,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Classe',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                        ),
                                        Text(
                                          'nom eleve',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Trimestre',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          'eleve',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Montant',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          'eleve mon',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            rowCompte(
                                Colors.blue,
                                "Informations sur le contact",
                                Icons.phone_android_outlined),
                            const SizedBox(
                              height: 10,
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(10),
                              elevation: 2,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SimpleText(
                                      text: 'Numéro qui recevra le SMS',
                                      weight: FontWeight.bold,
                                    ),
                                    const SizedBox(height: 10),
                                    TextFielApp(
                                      lenght: 9,
                                      controller:
                                          controller.controllerNumeroClient,
                                      validator: ValidationBuilder(
                                              requiredMessage:
                                                  'Numéro du bénéficiaire')
                                          .maxLength(
                                              9, 'entrer un numéro valide')
                                          .minLength(9, 'numéro invalide')
                                          .build(),
                                      inputType: TextInputType.phone,
                                      hinText: '--- --- ---',
                                    ),
                                    // const SizedBox(height: 15),
                                    const Text(
                                      'Numéro du payeur',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFielApp(
                                      controller:
                                          controller.controllerNumeroPayeur,
                                      lenght: 9,
                                      validator: ValidationBuilder(
                                              requiredMessage:
                                                  'Numéro du payeur')
                                          .maxLength(
                                              9, 'entrer un numéro valide')
                                          .minLength(9, 'numéro invalide')
                                          .build(),
                                      inputType: TextInputType.phone,
                                      hinText: '--- --- ---',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            rowCompte(Colors.blue, "Mode de Paiements",
                                Icons.wallet_giftcard),
                            const SizedBox(
                              height: 10,
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(10),
                              elevation: 2,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Image.asset(
                                                'assets/orange.png')),
                                        const Text(
                                          ' #150*11*MONPROF*Montant#',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            height: 45,
                                            child:
                                                Image.asset('assets/momo.jpg')),
                                        const Text(
                                          ' 657 140 696',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text('Nom affiché : ETS MONPROF',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue)),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            const Column(
                              children: [
                                SimpleText(
                                  text:
                                      'Veuiller initier le Paiements avec la chaine de PaiementsScreen correspondante à votre opérateur.',
                                  align: TextAlign.center,
                                  weight: FontWeight.bold,
                                ),
                                SizedBox(height: 15),
                                SimpleText(
                                  text:
                                      'Vous allez recevoir un sms dans moins de 24h pour activer votre abonnement.',
                                  weight: FontWeight.w300,
                                  color: Colors.blue,
                                  align: TextAlign.center,
                                ),
                              ],
                            ),
                            SpacerHeight(15),
                            DefaultButton(
                              wdiget: SimpleText(
                                text: "Valider ma commande",
                                color: white,
                                size: 17,
                                weight: FontWeight.bold,
                              ),
                              onPressed: () async {
                                if (key.currentState!.validate()) {
                                  await controller
                                      .requestPaiement()
                                      .then((value) {
                                    if (controller.paiementState.hasError) {
                                      Notify.showFailure(
                                          context,
                                          controller.paiementState.errorModel
                                                  ?.error ??
                                              "");
                                    } else if (controller
                                        .paiementState.hasData) {
                                      Notify.showSuccess(context,
                                          'Demande de paiment prise en compte');
                                      Navigator.pop(context);
                                    }
                                  });
                                } else {
                                  null;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ));
      },
    );
  }
}
