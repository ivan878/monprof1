import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/paiements/logique_metier/paiement_controller.dart';

class PaymentStatusComponent extends StatelessWidget {
  const PaymentStatusComponent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaiementsController>(builder: (controller) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              height: 8,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SpacerHeight(15),
          Image.asset(
            controller.failedPayment
                ? "assets/Warning.png"
                : controller.successPayment
                    ? "assets/succes_image.png"
                    : "assets/succes_pay.png",
            height: 120,
          ),
          const SizedBox(height: 20),
          Text(
            controller.failedPayment
                ? "Le paiement  n'a pas abouti.".tr
                : controller.successPayment
                    ? "Paiement effectué avec succès.".tr
                    : 'Paiement en cours de traitement.'.tr,
            textAlign: TextAlign.center,
            style: textStyle.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: controller.failedPayment
                  ? Colors.red.shade800
                  : controller.successPayment
                      ? Colors.green.shade800
                      : null,
            ),
          ),
          const SizedBox(height: 8),
          if (!controller.successPayment)
            if (controller.failedPayment) ...[
              Text(
                "Votre paiement n'a pas pu être traité.\nRaison: ${controller.raisonFailedPayment ?? "Inconnue"}"
                    .tr,
                textAlign: TextAlign.center,
                style: textStyle.copyWith(
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
            ] else if (!controller.successPayment) ...[
              Text(
                "Valider le paiement via votre fournisseur de service mobile au ${controller.paiementProvider!.title.startsWith("MTN") ? "*126#" : "#150*50#"}."
                    .tr,
                textAlign: TextAlign.center,
                style: textStyle.copyWith(
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              Text(
                "Votre paiement a été effectué avec succès. Monprof vous remercie pour votre confiance. et vous souhaite une bonne apprentissage."
                    .tr,
                textAlign: TextAlign.center,
                style: textStyle.copyWith(
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
            ],
          DefaultButton(
            text: 'Terminer'.tr,
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            backgroundColor:
                controller.failedPayment ? Colors.red : primaryColor,
            height: 50,
            radius: 10,
          ),
          SpacerHeight(10),
        ],
      );
    });
  }
}
