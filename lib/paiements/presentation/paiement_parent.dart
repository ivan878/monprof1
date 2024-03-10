import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/components/row_compte.dart';
import 'package:form_validator/form_validator.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/home/data/models/categorie_model.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/paiements/logique_metier/paiement_controller.dart';
import 'package:monprof/paiements/datas/reposytory/paiement_ripository.dart';
import 'package:monprof/paiements/presentation/component/paiements_provider_information.dart';

class PaimentParentScreen extends StatefulWidget {
  const PaimentParentScreen({super.key});

  @override
  State<PaimentParentScreen> createState() => _PaimentParentScreenState();
}

class _PaimentParentScreenState extends State<PaimentParentScreen> {
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    return GetBuilder(
      init: PaiementsController(
          repository: GetIt.instance<PaiementRepository>(),
          categorie: homeController.categorieParent),
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
                      key: formKey,
                      child: Column(
                        children: [
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
                                  (homeController.categorieParentState.data ??
                                              [])
                                          .isEmpty
                                      ? const SimpleText(
                                          text:
                                              'Impossible de charger les catégrie')
                                      : DropdownButtonFormField<
                                              CategorieParentStatus?>(
                                          focusColor: Colors.white,
                                          value: controller.categorie,
                                          validator: (value) {
                                            return value == null
                                                ? "choisir une catégorie"
                                                : null;
                                          },
                                          alignment:
                                              AlignmentDirectional.centerStart,
                                          isExpanded: true,
                                          style:
                                              textStyle.copyWith(color: white),
                                          iconEnabledColor: Colors.black,
                                          iconSize: 30,
                                          elevation: 16,
                                          decoration: appInputDecoration(),
                                          items: (homeController
                                                      .categorieParentState
                                                      .data ??
                                                  [])
                                              .map((e) => e)
                                              .toList()
                                              .map<
                                                      DropdownMenuItem<
                                                          CategorieParentStatus?>>(
                                                  (CategorieParentStatus
                                                      value) {
                                            return DropdownMenuItem<
                                                CategorieParentStatus>(
                                              value: value,
                                              child: SimpleText(
                                                text: value.categorie.libelle ??
                                                    '',
                                                color: Colors.black,
                                              ),
                                            );
                                          }).toList(),
                                          hint: Text(
                                            "Categorie",
                                            style: textStyle.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          onChanged:
                                              (CategorieParentStatus? value) {
                                            controller
                                                .changeCategorieParent(value);
                                          }),
                                  SpacerHeight(15),
                                  Container(
                                    height: 55,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          99, 163, 163, 163),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Prix Unitaire ${controller.categorie!.categorie.prix} Fcfa',
                                        style: textStyle.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Colors.green),
                                      ),
                                    ),
                                  ),
                                  SpacerHeight(15),
                                  TextFielApp(
                                    hinText: 'Quantité',
                                    inputType: TextInputType.number,
                                    fillColor: Colors.blue.withOpacity(0.3),
                                    filled: true,
                                    side: BorderSide.none,
                                    controller: controller.controllerQuantite,
                                    onChanged: controller.changeQuantite,
                                    validator: ValidationBuilder(
                                            requiredMessage:
                                                'veillez choisir une quantité')
                                        .required()
                                        .build(),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                  SpacerHeight(10),
                                  Container(
                                    height: 55,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          99, 163, 163, 163),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          'Total',
                                          style: textStyle.copyWith(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Montant ${controller.totalPrice}  Fcfa',
                                          style: textStyle.copyWith(
                                              fontSize: 17,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SpacerHeight(15),
                          rowCompte(
                            Colors.blue,
                            "Informations sur le contact",
                            Icons.phone_android_outlined,
                          ),
                          SpacerHeight(10),
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
                                  SpacerHeight(10),
                                  TextFielApp(
                                    lenght: 9,
                                    controller:
                                        controller.controllerNumeroClient,
                                    validator: ValidationBuilder(
                                            requiredMessage:
                                                'Numéro du bénéficiaire')
                                        .maxLength(9, 'entrer un numéro valide')
                                        .minLength(9, 'numéro invalide')
                                        .build(),
                                    inputType: TextInputType.phone,
                                    hinText: '--- --- ---',
                                  ),
                                  // SpacerHeight(15),
                                  Text(
                                    'Numéro du payeur',
                                    style: textStyle.copyWith(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SpacerHeight(10),
                                  TextFielApp(
                                    controller:
                                        controller.controllerNumeroPayeur,
                                    lenght: 9,
                                    validator: ValidationBuilder(
                                            requiredMessage: 'Numéro du payeur')
                                        .maxLength(9, 'entrer un numéro valide')
                                        .minLength(9, 'numéro invalide')
                                        .build(),
                                    inputType: TextInputType.phone,
                                    hinText: '--- --- ---',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SpacerHeight(15),
                          const PaiementsProviderInformation(),
                          DefaultButton(
                            wdiget: SimpleText(
                              text: "Valider ma commande",
                              color: white,
                              size: 17,
                              weight: FontWeight.bold,
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                await controller
                                    .requestPaiement()
                                    .then((value) {
                                  if (controller.paiementState.hasError) {
                                    Notify.showFailure(
                                        context,
                                        controller.paiementState.errorModel
                                                ?.error ??
                                            "");
                                  } else if (controller.paiementState.hasData) {
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
                ),
        );
      },
    );
  }
}
