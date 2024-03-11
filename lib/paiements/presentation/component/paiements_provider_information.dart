import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/components/row_compte.dart';
import 'package:monprof/corps/widgets/simple_text.dart';

class PaiementsProviderInformation extends StatelessWidget {
  const PaiementsProviderInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        rowCompte(Colors.blue, "Mode de Paiements", Icons.wallet_giftcard),
        const SizedBox(height: 10),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        height: 50, child: Image.asset('assets/orange.png')),
                    Text(
                      ' #150*11*MONPROF*Montant#',
                      style: textStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 45, child: Image.asset('assets/momo.jpg')),
                    Text(
                      ' 657 140 696',
                      style: textStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Nom affiché : ETS MONPROF',
                  style: textStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
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
      ],
    );
  }
}
