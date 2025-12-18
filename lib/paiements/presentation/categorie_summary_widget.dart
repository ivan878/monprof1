import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';

class CategorieSummaryWidget extends StatelessWidget {
  const CategorieSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Classe',
              style:
                  textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              home.classe?.libelle ?? " ",
              style: textStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Trimestre'.tr,
                style: textStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              child: Text(
                home.categorie?.categorie.libelle ?? " ",
                textAlign: TextAlign.end,
                style: textStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Montant'.tr,
              style:
                  textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              "${home.categorie?.categorie.prix.toString() ?? " "} XAF",
              style: textStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: primaryColor),
            ),
          ],
        ),
      ],
    );
  }
}
