import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
// import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/components/row_compte.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/paiements/logique_metier/paiement_controller.dart';
import 'package:monprof/paiements/presentation/categorie_summary_widget.dart';
import 'package:monprof/paiements/presentation/component/payment_status_component.dart';

class PaiementsProviderInformation extends StatelessWidget {
  const PaiementsProviderInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Resume de paiement".tr),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GetBuilder<PaiementsController>(builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              rowCompte(Colors.blue, "Resume".tr, Icons.wallet_giftcard),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CategorieSummaryWidget(),
                    const SizedBox(height: 5),
                    const Divider(),
                    const SizedBox(height: 5),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Numero du payeur'.tr,
                              style: textStyle.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const Spacer(),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset(
                                controller.paiementProvider?.img ?? "",
                                height: 27,
                              ),
                            ),
                            SpacerWidth(8),
                            Text(
                              controller.controllerNumeroPayeur.text,
                              style: textStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Moyen de paiement'.tr,
                              style: textStyle.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const Spacer(),
                            Text(
                              controller.paiementProvider?.title ?? " ",
                              style: textStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Frais MONPROF '.tr,
                              style: textStyle.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const Spacer(),
                            Text(
                              "0 XAF",
                              style: textStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Frais du fournisseur '.tr,
                              style: textStyle.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const Spacer(),
                            Text(
                              "${((home.categorie?.categorie.prix ?? 0) * 2.5 / 100).toInt()} XAF",
                              style: textStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Divider(),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Montant total  à payer '.tr,
                              style: textStyle.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const Spacer(),
                            Text(
                              "${((home.categorie?.categorie.prix ?? 0) + ((home.categorie?.categorie.prix ?? 0) * 2.5 / 100)).toInt()} XAF",
                              style: textStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              const Spacer(),
              DefaultButton(
                wdiget: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SimpleText(
                      text: "Confirmer le paiement".tr,
                      color: white,
                      size: 17,
                      weight: FontWeight.bold,
                    ),
                    if (controller.paiementState.isLoading) ...[
                      SpacerWidth(10),
                      const SizedBox(
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      )
                    ]
                  ],
                ),
                onPressed: () async {
                  await controller.requestPaiement();
                  if (context.mounted) {
                    if (controller.paiementState.hasError) {
                      Notify.showFailure(context,
                          controller.paiementState.errorModel?.error ?? "");
                    } else if (controller.paiementState.hasData) {
                      Notify.toastSuccess(
                          'Demande de paiment prise en compte'.tr);
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: false,
                          isDismissible: false,
                          builder: (context) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: PaymentStatusComponent(),
                            );
                          });
                    }
                  }
                },
              ),
              SpacerHeight(40),
            ],
          );
        }),
      ),
    );
  }
}
