// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';

import '../components/input.dart';
import 'contatUserScreen.dart';
import 'loading.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final numeroController = TextEditingController();
  final nomController = TextEditingController();
  final ecoleController = TextEditingController();
  final passwordController = TextEditingController();
  final confpasswordController = TextEditingController();
  final emailController = TextEditingController();
  bool isloading = false;
  bool politique = false;
  String? valeurClasse;
  String? valeursexe;

  bool visible = false;
  bool visibleconfir = true;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return isloading
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text("INSCRIPTION"),
              elevation: 0,
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   PageTransition(
                        //     alignment: Alignment.bottomCenter,
                        //     type: PageTransitionType.rightToLeft,
                        //     child: const Suggestion(),
                        //   ),
                        // );
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: FaIcon(
                          FontAwesomeIcons.info,
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(30),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Center(
                        child: Container(
                            height: 150,
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(20),
                            child: Image.asset('assets/book.png')),
                      ),
                      input(nomController, (nomController) {
                        if (nomController!.isEmpty ||
                            nomController.length > 23) {
                          return 'entrez un nom ';
                        } else {
                          return null;
                        }
                      }, false, const Icon(Icons.person), 'Nom',
                          TextInputType.name, 'Nom obligatoire'),
                      const SizedBox(
                        height: 10,
                      ),
                      input(emailController, (emailController) {
                        if (emailController!.isEmpty) {
                          return 'entrez une adresse valide';
                        } else {
                          return null;
                        }
                      }, false, const Icon(Icons.email), 'Email',
                          TextInputType.emailAddress, 'Email obligatoire'),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                            focusColor: Colors.white,
                            value: valeursexe,
                            alignment: AlignmentDirectional.centerStart,
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white),
                            iconEnabledColor: Colors.black,
                            iconSize: 30,
                            elevation: 16,
                            underline: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black,
                              ),
                            ),
                            items: <String>[
                              'FEMME',
                              'HOMME',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                            hint: const Text(
                              "Votre sexe",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            onChanged: (String? value) {
                              setState(() {
                                valeursexe = value;
                              });
                            }),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      input(numeroController, (value) {
                        if (value!.length < 9 || value.length > 10) {
                          return 'entrez un numéro valide';
                        } else {
                          return null;
                        }
                      }, false, const Icon(Icons.phone), 'Téléphone',
                          TextInputType.phone, 'entre un numéro valide'),
                      const SizedBox(
                        height: 10,
                      ),
                      //input pour la classe
                      // Container(
                      //     //width: MediaQuery.of(context).size.width * 0.7,
                      //     padding: const EdgeInsets.all(5),
                      //     decoration: BoxDecoration(
                      //       color: Colors.blue.withOpacity(0.3),
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: listCoursDropdown.isNotEmpty
                      //         ? DropdownButton<String>(
                      //             value: valeurClasse,
                      //             borderRadius: BorderRadius.circular(10),
                      //             alignment: AlignmentDirectional.centerStart,
                      //             isExpanded: true,
                      //             iconEnabledColor: Colors.black,
                      //             iconSize: 30,
                      //             elevation: 16,
                      //             underline: Container(
                      //               decoration: const BoxDecoration(
                      //                 color: Colors.black,
                      //               ),
                      //             ),
                      //             onChanged: (String? newValue) {
                      //               setState(() {
                      //                 valeurClasse = newValue!;
                      //               });
                      //               Fluttertoast.showToast(
                      //                 msg:
                      //                     'Vous avez choisi la classe de: $valeurClasse',
                      //                 toastLength: Toast.LENGTH_LONG,
                      //                 backgroundColor: const Color.fromARGB(
                      //                         249, 20, 185, 136)
                      //                     .withOpacity(0.9),
                      //                 timeInSecForIosWeb: 5,
                      //               );
                      //             },
                      //             items: listCoursDropdown.map((String value) {
                      //               return DropdownMenuItem<String>(
                      //                 value: value,
                      //                 child: Text(value),
                      //               );
                      //             }).toList(),
                      //             hint: const Text(
                      //               "Votre classe",
                      //               style: TextStyle(
                      //                   fontSize: 16,
                      //                   fontWeight: FontWeight.w500),
                      //             ),
                      //           )
                      //         : Shimmer.fromColors(
                      //             period: const Duration(milliseconds: 500),
                      //             child: Container(
                      //               margin: const EdgeInsets.all(0.0),
                      //               height: 50,
                      //               color: Colors.grey.withOpacity(0.5),
                      //               width: double.infinity,
                      //               child: const Center(
                      //                 child: Text('selectionner la classe'),
                      //               ),
                      //             ),
                      //             baseColor: Colors.grey.shade400,
                      //             highlightColor: Colors.grey.shade200,
                      //           )),
                      const SizedBox(
                        height: 15,
                      ),
                      input(ecoleController, (ecoleController) {
                        if (ecoleController!.isEmpty ||
                            ecoleController.length < 2) {
                          return 'Entrer une abréviation du nom de votre école';
                        } else {
                          return null;
                        }
                      },
                          false,
                          const Icon(Icons.school),
                          'Ecole Ex: COSACOMA-LBA ... ',
                          TextInputType.text,
                          "veuillez entrer l'abrévation de votre école"),
                      const SizedBox(
                        height: 15,
                      ),
                      input(passwordController, (passwordController) {
                        if (passwordController!.length < 6) {
                          return 'Le mot de passe doit avoir au moins 6 caractères';
                        } else {
                          return null;
                        }
                      },
                          true,
                          const Icon(Icons.lock),
                          'Votre mot de passe',
                          TextInputType.visiblePassword,
                          'veuillez entré le nom de votre ecole'),

                      const SizedBox(
                        height: 15,
                      ),
                      input(confpasswordController, (confpasswordController) {
                        if (passwordController.text != confpasswordController) {
                          return 'le mots de passe ne corresponds pas';
                        } else {
                          return null;
                        }
                      },
                          false,
                          const Icon(Icons.lock),
                          'Confirmer votre mot de passe',
                          TextInputType.visiblePassword,
                          'veuillez entré le nom de votre ecole'),

                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                          "En vous inscrivant, vous acceptez la politique générale d'utilisation  et de vente de Monprof ",
                          style: TextStyle(fontWeight: FontWeight.w300)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Checkbox(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              value: politique,
                              onChanged: (pol) =>
                                  setState(() => politique = pol!)),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    alignment: Alignment.bottomCenter,
                                    type: PageTransitionType.rightToLeft,
                                    child: const ContratUser(),
                                  ),
                                );
                              },
                              child: const Text('Lire la politique...',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),

                      Visibility(
                        visible: politique,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 50,
                          margin: const EdgeInsets.all(15),
                          child: TextButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate() &&
                                  valeurClasse!.isNotEmpty) {
                                setState(() {
                                  isloading = !isloading;
                                });

                                //   IdEleve,

                                setState(() {
                                  isloading = !isloading;
                                });
                              } else {
                                null;
                              }
                            },
                            child: const Text(
                              "S'INSCRIRE",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: Colors.blue,
                              elevation: 3,
                            ),
                          ),
                        ),
                      ),

                      // InkWell(
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //   },
                      //   child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //       children: const [
                      //         Text("j'ai déja un compte",
                      //             style: TextStyle(
                      //                 fontSize: 17,
                      //                 fontWeight: FontWeight.w300)),
                      //         Text("connectez vous",
                      //             style: TextStyle(
                      //                 color: Colors.blue,
                      //                 fontSize: 17,
                      //                 fontWeight: FontWeight.bold)),
                      //       ]),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
