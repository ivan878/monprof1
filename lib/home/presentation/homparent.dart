import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/home/presentation/compte_screen.dart';

class HomeParentScreen extends StatefulWidget {
  const HomeParentScreen({super.key});

  @override
  State<HomeParentScreen> createState() => _HomeParentScreenState();
}

class _HomeParentScreenState extends State<HomeParentScreen> {
  Map<int, Color> colorstat = {
    0: const Color.fromARGB(255, 14, 102, 185),
    1: const Color.fromARGB(255, 65, 70, 65),
    2: const Color.fromARGB(255, 111, 51, 180),
    3: const Color.fromARGB(255, 92, 102, 73)
  };
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const SimpleText(text: "MonProf"),
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                    onTap: () async {
                      // changeScreen(context, const CompteUser());
                    },
                    child: Image.asset('assets/study2.png')),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/mp2.png'),
                  const SizedBox(height: 30),
                  Center(
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      elevation: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1, color: Colors.blue),
                        ),
                        child: const SimpleText(
                          text: 'Faire un achat',
                          color: Colors.blue,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Text('statuts',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.w400)),
                  const Divider(
                    thickness: 2,
                  ),
                  // Container(
                  //   height: 400,
                  //   padding:
                  //       const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  //   child: Wrap(
                  //       children: listcategoriestat
                  //           .map((data) => Padding(
                  //                 padding: const EdgeInsets.all(5),
                  //                 child: Column(
                  //                     mainAxisAlignment:
                  //                         MainAxisAlignment.spaceBetween,
                  //                     children: [
                  //                       Column(
                  //                         children: [
                  //                           Container(
                  //                             height: 200,
                  //                             width: MediaQuery.of(context)
                  //                                     .size
                  //                                     .width *
                  //                                 0.4,
                  //                             decoration: BoxDecoration(
                  //                                 color:
                  //                                     colorstat[data['colors']],
                  //                                 borderRadius:
                  //                                     BorderRadius.circular(10)),
                  //                             child: Padding(
                  //                               padding:
                  //                                   const EdgeInsets.all(8.0),
                  //                               child: Column(children: [
                  //                                 Text(data['libelle'],
                  //                                     style: const TextStyle(
                  //                                         fontSize: 17,
                  //                                         color: Colors.white,
                  //                                         fontWeight:
                  //                                             FontWeight.bold)),
                  //                                 const Divider(
                  //                                   thickness: 3,
                  //                                 ),
                  //                                 const SizedBox(
                  //                                   height: 15,
                  //                                 ),
                  //                                 Row(
                  //                                   mainAxisAlignment:
                  //                                       MainAxisAlignment
                  //                                           .spaceBetween,
                  //                                   children: [
                  //                                     const Text('Total',
                  //                                         style: TextStyle(
                  //                                             fontSize: 17,
                  //                                             color: Colors.white,
                  //                                             fontWeight:
                  //                                                 FontWeight
                  //                                                     .w300)),
                  //                                     Text(
                  //                                         data['nbreTotal']
                  //                                             .toString(),
                  //                                         style: const TextStyle(
                  //                                             color: Colors.green,
                  //                                             fontSize: 20,
                  //                                             fontWeight:
                  //                                                 FontWeight
                  //                                                     .bold)),
                  //                                   ],
                  //                                 ),
                  //                                 const SizedBox(
                  //                                   height: 15,
                  //                                 ),
                  //                                 Row(
                  //                                   mainAxisAlignment:
                  //                                       MainAxisAlignment
                  //                                           .spaceBetween,
                  //                                   children: [
                  //                                     const Text('Activer',
                  //                                         style: TextStyle(
                  //                                             fontSize: 17,
                  //                                             color: Colors.white,
                  //                                             fontWeight:
                  //                                                 FontWeight
                  //                                                     .w300)),
                  //                                     Text(
                  //                                         data['nbreTotalActive']
                  //                                             .toString(),
                  //                                         style: const TextStyle(
                  //                                             color: Colors.green,
                  //                                             fontSize: 20,
                  //                                             fontWeight:
                  //                                                 FontWeight
                  //                                                     .bold)),
                  //                                   ],
                  //                                 ),
                  //                                 const SizedBox(
                  //                                   height: 10,
                  //                                 ),
                  //                                 Container(
                  //                                   padding: const EdgeInsets
                  //                                           .symmetric(
                  //                                       vertical: 2,
                  //                                       horizontal: 20),
                  //                                   decoration: BoxDecoration(
                  //                                       color: Colors.white
                  //                                           .withOpacity(0.5),
                  //                                       borderRadius:
                  //                                           BorderRadius.circular(
                  //                                               40)),
                  //                                   child: Text(
                  //                                       data['nbreTotal']
                  //                                           .toString(),
                  //                                       style: const TextStyle(
                  //                                           color: Colors.white,
                  //                                           fontWeight:
                  //                                               FontWeight.bold,
                  //                                           fontSize: 17)),
                  //                                 ),
                  //                               ]),
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                       // Row(
                  //                       //   mainAxisAlignment:
                  //                       //       MainAxisAlignment.spaceBetween,
                  //                       //   children: [
                  //                       //     Text('libelle'),
                  //                       //     Text(data['libelle']),
                  //                       //   ],
                  //                       // ),
                  //                       // Text(data['description']),
                  //                       // Text(data['statut']),
                  //                       // Text(data['nbreTotal'].toString()),
                  //                       // Text(
                  //                       //     data['nbreTotalActive'].toString()),
                  //                     ]),
                  //               ))
                  //           .toList()),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
