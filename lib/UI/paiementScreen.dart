import 'package:flutter/material.dart';

import '../components/input2.dart';
import '../components/row_compte.dart';

class Paiement extends StatefulWidget {
  const Paiement({super.key});

  @override
  State<Paiement> createState() => _PaiementState();
}

class _PaiementState extends State<Paiement> {
  final numDebitController = TextEditingController();
  final numCreditController = TextEditingController();
  final key = GlobalKey<FormState>();
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Paiement d'un abonnement"),
        ),
        body: isloading
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
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      'elece',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.green,
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
                        rowCompte(Colors.blue, "Informations sur le contact",
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
                                const Text(
                                  'Numéro qui recevra le SMS',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                input2(numDebitController, (value) {
                                  if (value!.length != 9) {
                                    return 'Entrer un numéro valide';
                                  } else {
                                    return null;
                                  }
                                },
                                    'Numéro du bénéficiaire',
                                    'Numéro du bénéficiaire',
                                    'Entrer un numéro valide'),
                                const SizedBox(
                                  height: 15,
                                ),
                                const Text(
                                  'Numéro du payeur',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                input2(numCreditController, (value) {
                                  if (value!.length != 9) {
                                    return 'Entrer le numéro à débiter';
                                  } else {
                                    return null;
                                  }
                                }, 'Numéro à déditer', 'Numéro à débiter',
                                    'Entrer un numéro valide'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        rowCompte(
                            Colors.blue,
                            "Information sur le mode de paiement",
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
                                        child:
                                            Image.asset('assets/orange.png')),
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
                                        child: Image.asset('assets/momo.jpg')),
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
                            Text(
                              'Veuiller initier le paiement avec la chaine de paiement correspondante à votre opérateur.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Vous allez recevoir un sms dans moins de 24h pour activer votre abonnement.',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.blue),
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 50,
                          margin: const EdgeInsets.all(15),
                          child: TextButton(
                            onPressed: () async {
                              // if (key.currentState!.validate()) {
                              //   setState(() {
                              //     isloading = true;
                              //   });
                              //   var numdebit = numDebitController.text;
                              //   var numCredit = numDebitController.text;
                              //   var resultat =
                              //       await paiement(numdebit, numCredit);

                              //   Fluttertoast.showToast(
                              //     msg: 'commande valider avec succes',
                              //     toastLength: Toast.LENGTH_LONG,
                              //     backgroundColor:
                              //         Colors.blue.shade400.withOpacity(0.9),
                              //     timeInSecForIosWeb: 4,
                              //   );
                              //   Navigator.push(
                              //       context,
                              //       PageTransition(
                              //         alignment: Alignment.bottomCenter,
                              //         type: PageTransitionType.rightToLeft,
                              //         child: const ActiveCompte(),
                              //       ));
                              //   setState(() {
                              //     isloading = false;
                              //   });
                              // } else {
                              //   null;
                              // }
                            },
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: Colors.blue,
                              elevation: 3,
                            ),
                            child: const Text(
                              "Valider ma commande",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
