import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text("Politiques générales ")),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(children: [
            rowCompte(
                Colors.blue, "Poltique générale d'utilisation", Icons.info),
            const SizedBox(
              height: 15,
            ),
            rowCompte(Colors.blue, 'Poltique générale de vente', Icons.info),
            const SizedBox(
              height: 15,
            ),
            rowCompte(Colors.blue, 'Mentions légales', Icons.info),
          ]),
        ),
      ),
    );
  }
}
