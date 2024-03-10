// import 'package:flutter/material.dart';
// import 'package:monprof/components/input2.dart';
// import 'package:monprof/components/row_compte.dart';

// class PaiementP extends StatefulWidget {
//   const PaiementP({super.key});

//   @override
//   State<PaiementP> createState() => _PaiementPState();
// }

// class _PaiementPState extends State<PaiementP> {
//   final numDebitController = TextEditingController();
//   final numCreditController = TextEditingController();
//   final quantiteController = TextEditingController();
//   final key = GlobalKey<FormState>();
//   bool isloading = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text("Paiement d'un abonnement"),
//         ),
//         body: isloading
//             ? Center(
//                 child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.transparent,
//                   ),
//                   child: const CircularProgressIndicator(),
//                 ),
//               ))
//             : Container(
//                 padding: const EdgeInsets.all(8.0),
//                 margin: const EdgeInsets.all(10.0),
//                 child: SingleChildScrollView(
//                   child: Form(
//                     key: key,
//                     child: Column(
//                       // mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         rowCompte(Colors.blue, "Informations sur la classe",
//                             Icons.school),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Material(
//                           borderRadius: BorderRadius.circular(10),
//                           elevation: 2,
//                           child: Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.blue),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   //width: MediaQuery.of(context).size.width * 0.7,
//                                   padding: const EdgeInsets.all(5),
//                                   decoration: BoxDecoration(
//                                     color: Colors.blue.withOpacity(0.3),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   //     child: listCoursDropdown.isNotEmpty
//                                   //         ? DropdownButton<Map<String, dynamic>>(
//                                   //             value: valeurClasse,
//                                   //             borderRadius:
//                                   //                 BorderRadius.circular(10),
//                                   //             alignment: AlignmentDirectional
//                                   //                 .centerStart,
//                                   //             isExpanded: true,
//                                   //             iconEnabledColor: Colors.black,
//                                   //             iconSize: 30,
//                                   //             elevation: 16,
//                                   //             underline: Container(
//                                   //               decoration: const BoxDecoration(
//                                   //                 color: Colors.black,
//                                   //               ),
//                                   //             ),
//                                   //             onChanged: (newValue) {
//                                   //               setState(() {
//                                   //                 valeurClasse = newValue!;
//                                   //                 idClasse =
//                                   //                     int.parse(newValue['id']);
//                                   //               });
//                                   //               montant();
//                                   //               setState(() {});

//                                   //               Fluttertoast.showToast(
//                                   //                 msg:
//                                   //                     'Vous avez choisi la classe de: ${valeurClasse!['libelle']}',
//                                   //                 toastLength: Toast.LENGTH_LONG,
//                                   //                 backgroundColor:
//                                   //                     const Color.fromARGB(
//                                   //                             249, 20, 185, 136)
//                                   //                         .withOpacity(0.9),
//                                   //                 timeInSecForIosWeb: 5,
//                                   //               );
//                                   //             },
//                                   //             items:
//                                   //                 listCoursDropdown.map((value) {
//                                   //               return DropdownMenuItem<
//                                   //                   Map<String, dynamic>>(
//                                   //                 value: value,
//                                   //                 child: Text(value['libelle']),
//                                   //               );
//                                   //             }).toList(),
//                                   //             hint: const Text(
//                                   //               "Choisir la classe",
//                                   //               style: TextStyle(
//                                   //                   fontSize: 16,
//                                   //                   fontWeight: FontWeight.w500),
//                                   //             ),
//                                   //           )
//                                   //         : Shimmer.fromColors(
//                                   //             period: const Duration(
//                                   //                 milliseconds: 500),
//                                   //             child: Container(
//                                   //               margin: const EdgeInsets.all(0.0),
//                                   //               height: 50,
//                                   //               color:
//                                   //                   Colors.grey.withOpacity(0.5),
//                                   //               width: double.infinity,
//                                   //               child: const Center(
//                                   //                 child: Text(
//                                   //                     'selectionner la classe'),
//                                   //               ),
//                                   //             ),
//                                   //             baseColor: Colors.grey.shade400,
//                                   //             highlightColor:
//                                   //                 Colors.grey.shade200,
//                                   //           )),
//                                   // Container(
//                                   //     width:
//                                   //         MediaQuery.of(context).size.width * 0.8,
//                                   //     padding: const EdgeInsets.all(5),
//                                   //     decoration: BoxDecoration(
//                                   //       color: Colors.blue.withOpacity(0.3),
//                                   //       borderRadius: BorderRadius.circular(10),
//                                   //     ),
//                                   //     child: listtrimDow.isNotEmpty
//                                   //         ? DropdownButton<String>(
//                                   //             value: trimestre,
//                                   //             borderRadius:
//                                   //                 BorderRadius.circular(10),
//                                   //             alignment:
//                                   //                 AlignmentDirectional.centerStart,

//                                   //             isExpanded: true,
//                                   //             iconEnabledColor: Colors.black,
//                                   //             iconSize: 30,
//                                   //             elevation: 16,
//                                   //             //style: TextStyle(color: Colors.teal),
//                                   //             underline: Container(
//                                   //               decoration: const BoxDecoration(
//                                   //                 color: Colors.black,
//                                   //               ),
//                                   //             ),
//                                   //             onChanged: (String? newValue) {
//                                   //               setState(() {
//                                   //                 trimestre = newValue;
//                                   //               });
//                                   //             },
//                                   //             items: listtrimDow.map((value) {
//                                   //               return DropdownMenuItem<String>(
//                                   //                 value: value,
//                                   //                 child: Text(value),
//                                   //               );
//                                   //             }).toList(),
//                                   //             hint: const Text(
//                                   //               "Choisir le trimestre",
//                                   //               style: TextStyle(
//                                   //                   fontSize: 16,
//                                   //                   fontWeight: FontWeight.w500),
//                                   //             ),
//                                   //           )
//                                   //         : Shimmer.fromColors(
//                                   //             period:
//                                   //                 const Duration(milliseconds: 500),
//                                   //             child: Container(
//                                   //               margin: const EdgeInsets.all(0.0),
//                                   //               height: 50,
//                                   //               color: Colors.grey.withOpacity(0.5),
//                                   //               width: double.infinity,
//                                   //               child: const Center(
//                                   //                 child: Text('patientez svp'),
//                                   //               ),
//                                   //             ),
//                                   //             baseColor: Colors.grey.shade400,
//                                   //             highlightColor: Colors.grey.shade200,
//                                   //           ),
//                                 ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 Container(
//                                   padding: const EdgeInsets.all(5),
//                                   decoration: BoxDecoration(
//                                     color: Colors.blue.withOpacity(0.3),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   // child: listtrimDow.isNotEmpty
//                                   //     ? DropdownButton<Map<String, dynamic>>(
//                                   //         value: trimestre,
//                                   //         borderRadius:
//                                   //             BorderRadius.circular(10),
//                                   //         alignment:
//                                   //             AlignmentDirectional.centerStart,

//                                   //         isExpanded: true,
//                                   //         iconEnabledColor: Colors.black,
//                                   //         iconSize: 30,
//                                   //         elevation: 16,
//                                   //         //style: TextStyle(color: Colors.teal),
//                                   //         underline: Container(
//                                   //           decoration: const BoxDecoration(
//                                   //             color: Colors.black,
//                                   //           ),
//                                   //         ),
//                                   //         onChanged: (newValue) {
//                                   //           setState(() {
//                                   //             trimestre = newValue;
//                                   //             trim = int.parse(newValue?['id']);
//                                   //           });
//                                   //           montant();
//                                   //           setState(() {});
//                                   //         },
//                                   //         items: listtrimDow.map((value) {
//                                   //           return DropdownMenuItem<
//                                   //               Map<String, dynamic>>(
//                                   //             value: value,
//                                   //             child: Text(value['libelle']),
//                                   //           );
//                                   //         }).toList(),
//                                   //         hint: const Text(
//                                   //           "Choisir le trimestre",
//                                   //           style: TextStyle(
//                                   //               fontSize: 16,
//                                   //               fontWeight: FontWeight.w500),
//                                   //         ),
//                                   //       )
//                                   //     : Shimmer.fromColors(
//                                   //         period:
//                                   //             const Duration(milliseconds: 500),
//                                   //         child: Container(
//                                   //           margin: const EdgeInsets.all(0.0),
//                                   //           height: 50,
//                                   //           color: Colors.grey.withOpacity(0.5),
//                                   //           width: double.infinity,
//                                   //           child: const Center(
//                                   //             child: Text('patientez svp'),
//                                   //           ),
//                                   //         ),
//                                   //         baseColor: Colors.grey.shade400,
//                                   //         highlightColor: Colors.grey.shade200,
//                                   //       ),
//                                 ),
//                                 // Container(
//                                 //   // width:
//                                 //   //  MediaQuery.of(context).size.width * 0.7,
//                                 //   padding: const EdgeInsets.all(5),
//                                 //   decoration: BoxDecoration(
//                                 //     color: Colors.blue.withOpacity(0.3),
//                                 //     borderRadius: BorderRadius.circular(10),
//                                 //   ),
//                                 //   child: listtrimDow.isNotEmpty
//                                 //       ? DropdownButton<String>(
//                                 //           value: trimestre,
//                                 //           borderRadius:
//                                 //               BorderRadius.circular(10),
//                                 //           alignment:
//                                 //               AlignmentDirectional.centerStart,

//                                 //           isExpanded: true,
//                                 //           iconEnabledColor: Colors.black,
//                                 //           iconSize: 30,
//                                 //           elevation: 16,
//                                 //           //style: TextStyle(color: Colors.teal),
//                                 //           underline: Container(
//                                 //             decoration: const BoxDecoration(
//                                 //               color: Colors.black,
//                                 //             ),
//                                 //           ),
//                                 //           onChanged: (String? newValue) {
//                                 //             setState(() {
//                                 //               trimestre = newValue;
//                                 //             });
//                                 //           },
//                                 //           items: listtrimDow.map((value) {
//                                 //             return DropdownMenuItem<String>(
//                                 //               value: value,
//                                 //               child: Text(value),
//                                 //             );
//                                 //           }).toList(),
//                                 //           hint: const Text(
//                                 //             "Choisir le trimestre",
//                                 //             style: TextStyle(
//                                 //                 fontSize: 16,
//                                 //                 fontWeight: FontWeight.w500),
//                                 //           ),
//                                 //         )
//                                 //       : Shimmer.fromColors(
//                                 //           period:
//                                 //               const Duration(milliseconds: 500),
//                                 //           child: Container(
//                                 //             margin: const EdgeInsets.all(0.0),
//                                 //             height: 50,
//                                 //             color: Colors.grey.withOpacity(0.5),
//                                 //             width: double.infinity,
//                                 //             child: const Center(
//                                 //               child: Text('patientez svp'),
//                                 //             ),
//                                 //           ),
//                                 //           baseColor: Colors.grey.shade400,
//                                 //           highlightColor: Colors.grey.shade200,
//                                 //         ),
//                                 // ),
//                                 const SizedBox(
//                                   height: 15,
//                                 ),
//                                 Container(
//                                   height: 55,
//                                   width: MediaQuery.of(context).size.width,
//                                   decoration: BoxDecoration(
//                                     color: Color.fromARGB(99, 163, 163, 163),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: const Center(
//                                       child: Text('Prix' + 'Fcfa',
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 17,
//                                               color: Colors.green))),
//                                 ),
//                                 const SizedBox(
//                                   height: 15,
//                                 ),
//                                 TextFormField(
//                                     keyboardType: TextInputType.number,
//                                     controller: quantiteController,
//                                     onChanged: (val) {
//                                       // if (val.trim().isNotEmpty) {
//                                       //   setState(() {
//                                       //     quantiteCours = int.parse(val);
//                                       //     montantTotal = prix * quantiteCours;
//                                       //   });
//                                       // }
//                                     },
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.blue.withOpacity(0.3),
//                                       filled: true,
//                                       hintText: 'Quantité',
//                                       border: OutlineInputBorder(
//                                         borderSide: BorderSide.none,
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                     )),
//                                 // input(quantiteController, (value) {
//                                 //   if (value!.length < 9 || value.length > 10) {
//                                 //     return 'entrez un numéro valide';
//                                 //   } else {
//                                 //     return null;
//                                 //   }
//                                 // }, true, const Icon(Icons.ac_unit), 'Quantité',
//                                 //     TextInputType.number, 'nombre invalide'),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Container(
//                                   height: 55,
//                                   width: MediaQuery.of(context).size.width,
//                                   decoration: BoxDecoration(
//                                     color: Color.fromARGB(99, 163, 163, 163),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: const Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceAround,
//                                     children: [
//                                       Text(
//                                         'Total',
//                                         style: TextStyle(
//                                             fontSize: 17,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       Text(
//                                         'Montant' + 'Fcfa',
//                                         style: TextStyle(
//                                             fontSize: 17,
//                                             color: Colors.green,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         rowCompte(Colors.blue, "Informations sur le contact",
//                             Icons.phone_android_outlined),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Material(
//                           borderRadius: BorderRadius.circular(10),
//                           elevation: 2,
//                           child: Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.blue),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Numéro qui recevra le SMS',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 input2(numDebitController, (value) {
//                                   if (value!.length != 9) {
//                                     return 'Entrer un numéro valide';
//                                   } else {
//                                     return null;
//                                   }
//                                 },
//                                     'Numéro du bénéficiaire',
//                                     'Numéro du bénéficiaire',
//                                     'Entrer un numéro valide'),
//                                 const SizedBox(
//                                   height: 15,
//                                 ),
//                                 const Text(
//                                   'Numéro du payeur',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 input2(numCreditController, (value) {
//                                   if (value!.length != 9) {
//                                     return 'Entrer le numéro à débiter';
//                                   } else {
//                                     return null;
//                                   }
//                                 }, 'Numéro à déditer', 'Numéro à débiter',
//                                     'Entrer un numéro valide'),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 15,
//                         ),
//                         rowCompte(
//                             Colors.blue,
//                             "Information sur le mode de paiement",
//                             Icons.wallet_giftcard),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Material(
//                           borderRadius: BorderRadius.circular(10),
//                           elevation: 2,
//                           child: Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.blue),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     SizedBox(
//                                         height: 50,
//                                         child:
//                                             Image.asset('assets/orange.png')),
//                                     const Text(
//                                       '#150*11*MONPROF*Montant#',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     SizedBox(
//                                         height: 45,
//                                         child: Image.asset('assets/momo.jpg')),
//                                     const Text(
//                                       ' 657 140 696',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 const Text('Nom affiché : ETS MONPROF',
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.blue)),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const Divider(),
//                         const Column(
//                           children: [
//                             Text(
//                               'Veuiller initier le paiement avec la chaine de paiement correspondante à votre opérateur.',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             Text(
//                               'Vous allez recevoir un sms dans moins de 24h pour activer votre abonnement.',
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w300,
//                                   color: Colors.blue),
//                             ),
//                           ],
//                         ),
//                         Container(
//                           width: MediaQuery.of(context).size.width * 0.9,
//                           height: 50,
//                           margin: const EdgeInsets.all(15),
//                           child: TextButton(
//                             onPressed: () async {
//                               if (key.currentState!.validate()) {
//                                 // setState(() {
//                                 //   isloading = true;
//                                 // });
//                                 // var numdebit = numDebitController.text;
//                                 // var numCredit = numCreditController.text;
//                                 // var quantite = quantiteController.text;
//                                 // final res = await paiementP(
//                                 //     numdebit, numCredit, quantite);
//                                 // if (res == null) {
//                                 //   Fluttertoast.showToast(
//                                 //     msg: 'commande valider avec succes',
//                                 //     toastLength: Toast.LENGTH_LONG,
//                                 //     backgroundColor:
//                                 //         Colors.blue.shade400.withOpacity(0.9),
//                                 //     timeInSecForIosWeb: 4,
//                                 //   );
//                                 // Navigator.pop(context);
//                                 // context,
//                                 // PageTransition(
//                                 //   alignment: Alignment.bottomCenter,
//                                 //   type: PageTransitionType.rightToLeft,
//                                 //   child: const HomeParent(),
//                                 // ));
//                               } else {
//                                 // Fluttertoast.showToast(
//                                 //   msg: 'Erreur',
//                                 //   toastLength: Toast.LENGTH_LONG,
//                                 //   backgroundColor:
//                                 //       Colors.red.shade400.withOpacity(0.9),
//                                 //   timeInSecForIosWeb: 10,
//                                 // );
//                               }
//                             },
//                             style: TextButton.styleFrom(
//                               primary: Colors.white,
//                               backgroundColor: Colors.blue,
//                               elevation: 3,
//                             ),
//                             child: const Text(
//                               "Valider ma commande",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 17),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ));
//   }
// }
