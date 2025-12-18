import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:form_validator/form_validator.dart';
import 'package:monprof/components/row_compte.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/paiements/logique_metier/paiement_controller.dart';
import 'package:monprof/paiements/datas/reposytory/paiement_ripository.dart';
import 'package:monprof/paiements/presentation/categorie_summary_widget.dart';
import 'package:monprof/paiements/presentation/component/paiements_provider_information.dart';

class PaiementsScreen extends StatefulWidget {
  const PaiementsScreen({super.key});

  @override
  State<PaiementsScreen> createState() => _PaiementsScreenState();
}

class _PaiementsScreenState extends State<PaiementsScreen> {
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final controller = Get.find<PaiementsController>();
      controller.getPaiementProviders();
    });
  }

  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init:
          PaiementsController(repository: GetIt.instance<PaiementRepository>()),
      builder: (PaiementsController controller) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Paiement d'un abonnement".tr),
            ),
            body: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Form(
                  key: key,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      rowCompte(Colors.blue, "Informations sur la classe".tr,
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
                          child: const CategorieSummaryWidget(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      rowCompte(Colors.blue, "Informations sur le contact".tr,
                          Icons.phone_android_outlined),
                      const SizedBox(
                        height: 10,
                      ),
                      if (controller.paiementProviderState.isLoading) ...[
                        SpacerHeight(30),
                        SizedBox(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          ),
                        ),
                        SpacerHeight(10),
                        Center(
                          child: SimpleText(
                            text: "Chargement des services de paiement".tr,
                            align: TextAlign.center,
                          ),
                        ),
                      ] else if (controller.paiementProviderState.hasError) ...[
                        SpacerHeight(15),
                        Text(
                          controller.paiementProviderState.errorModel?.error ??
                              'Une erreur est survenue lors du chargement des services de paiement',
                          textAlign: TextAlign.center,
                          style: textStyle.copyWith(color: Colors.red),
                        ),
                        SpacerHeight(10),
                        Center(
                          child: IconButton(
                            onPressed: () {
                              controller.getPaiementProviders();
                            },
                            icon: Icon(
                              Icons.refresh,
                              size: 30,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        SpacerHeight(3),
                        Center(
                          child: SimpleText(
                              text: 'Refraichir'.tr, align: TextAlign.center),
                        )
                      ] else if (controller.paiementProviderState.data ==
                              null ||
                          controller.paiementProviderState.data!.isEmpty) ...[
                        SpacerHeight(15),
                        Text(
                          controller.paiementProviderState.errorModel?.error ??
                              'Aucun service de paiement disponible pour le moment',
                          textAlign: TextAlign.center,
                          style: textStyle.copyWith(
                            color: Colors.deepOrangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SpacerHeight(10),
                        Center(
                          child: IconButton(
                            onPressed: () {
                              controller.getPaiementProviders();
                            },
                            icon: Icon(
                              Icons.refresh,
                              size: 30,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        SpacerHeight(3),
                        Center(
                          child: SimpleText(
                              text: 'Refraichir'.tr, align: TextAlign.center),
                        )
                      ] else ...[
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
                                SimpleText(
                                  text: 'Numéro qui recevra le SMS'.tr,
                                  weight: FontWeight.bold,
                                ),
                                const SizedBox(height: 10),
                                TextFielApp(
                                  lenght: 9,
                                  controller: controller.controllerNumeroClient,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: ValidationBuilder(
                                    requiredMessage:
                                        'Numéro du bénéficiaire'.tr,
                                  )
                                      .maxLength(
                                        9,
                                        'entrer un numéro valide'.tr,
                                      )
                                      .minLength(
                                        9,
                                        'numéro invalide'.tr,
                                      )
                                      .build(),
                                  inputType: TextInputType.phone,
                                  hinText: '--- --- ---',
                                ),
                                // const SizedBox(height: 15),
                                Text(
                                  'Numéro du payeur'.tr,
                                  style: textStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFielApp(
                                  controller: controller.controllerNumeroPayeur,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  lenght: 9,
                                  validator: ValidationBuilder(
                                    requiredMessage: 'Numéro du payeur'.tr,
                                  )
                                      .maxLength(
                                        9,
                                        'entrer un numéro valide'.tr,
                                      )
                                      .minLength(
                                        9,
                                        'numéro invalide'.tr,
                                      )
                                      .build(),
                                  inputType: TextInputType.phone,
                                  hinText: '--- --- ---',
                                  onChanged: (p0) {
                                    if (p0.length == 9) {
                                      controller
                                          .selectPaymentProviderFromNumber(p0);
                                    }
                                  },
                                  suffixIcon: controller.paiementProvider !=
                                          null
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            controller.paiementProvider!.img!,
                                            height: 20,
                                            width: 20,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.error,
                                                color: Colors.red,
                                              );
                                            },
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SpacerHeight(40),
                        DefaultButton(
                          wdiget: SimpleText(
                            text: "Continuer".tr,
                            color: white,
                            size: 17,
                            weight: FontWeight.bold,
                          ),
                          onPressed: () async {
                            if (key.currentState!.validate()) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PaiementsProviderInformation(),
                                ),
                              );
                            }
                          },
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }
}
