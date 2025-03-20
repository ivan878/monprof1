import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/row_compte.dart';

class ContratUser extends StatefulWidget {
  const ContratUser({super.key});

  @override
  State<ContratUser> createState() => _ContratUserState();
}

class _ContratUserState extends State<ContratUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Politiques générales".tr)),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(children: [
            GestureDetector(
              onTap: () {
                launchUrl(Uri.parse("https://mutrix.org/privacy"));
              },
              child: rowCompte(
                Colors.blue,
                "Poltique générale d'utilisation".tr,
                Icons.info,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse("https://mutrix.org/terms"));
                },
                child: rowCompte(
                    Colors.blue, 'Poltique générale de vente'.tr, Icons.info)),
            const SizedBox(
              height: 15,
            ),
            GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse("https://mutrix.org/terms/"));
                },
                child:
                    rowCompte(Colors.blue, 'Mentions légales'.tr, Icons.info)),
          ]),
        ),
      ),
    );
  }
}
