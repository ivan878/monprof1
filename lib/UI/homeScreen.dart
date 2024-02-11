import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../components/bouton.dart';
import 'compteScreen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("MonProf"),
        elevation: 0,
        actions: [
          Container(
              margin: const EdgeInsets.all(5),
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('Tc', style: TextStyle(fontSize: 15)),
              )),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(10)),
              child: InkWell(
                  onTap: () async {
                    Navigator.push(
                        context,
                        PageTransition(
                          alignment: Alignment.bottomCenter,
                          type: PageTransitionType.rightToLeft,
                          child: const CompteUser(),
                        ));
                  },
                  child: Image.asset('assets/study2.png')),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(child: Image.asset('assets/mp2.png')),
                const SizedBox(
                  height: 15,
                ),
                // Container(
                //   width: MediaQuery.of(context).size.width * 0.7,
                //   padding: const EdgeInsets.all(5),
                //   decoration: BoxDecoration(
                //     color: Colors.blue.withOpacity(0.3),
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: listtrimDow.isNotEmpty
                //       ? DropdownButton<String>(
                //           value: trimestre,
                //           borderRadius: BorderRadius.circular(10),
                //           alignment: AlignmentDirectional.centerStart,

                //           isExpanded: true,
                //           iconEnabledColor: Colors.black,
                //           iconSize: 30,
                //           elevation: 16,
                //           //style: TextStyle(color: Colors.teal),
                //           underline: Container(
                //             decoration: const BoxDecoration(
                //               color: Colors.black,
                //             ),
                //           ),
                //           onChanged: (String? newValue) {
                //             setState(() {
                //               trimestre = newValue;
                //             });
                //           },
                //           items: listtrimDow.map((value) {
                //             return DropdownMenuItem<String>(
                //               value: value,
                //               child: Text(value),
                //             );
                //           }).toList(),
                //           hint: const Text(
                //             "Choisir le trimestre",
                //             style: TextStyle(
                //                 fontSize: 16, fontWeight: FontWeight.w500),
                //           ),
                //         )
                //       : Shimmer.fromColors(
                //           period: const Duration(milliseconds: 500),
                //           child: Container(
                //             margin: const EdgeInsets.all(0.0),
                //             height: 50,
                //             color: Colors.grey.withOpacity(0.5),
                //             width: double.infinity,
                //             child: const Center(
                //               child: Text('patientez svp'),
                //             ),
                //           ),
                //           baseColor: Colors.grey.shade400,
                //           highlightColor: Colors.grey.shade200,
                //         ),
                // ),
                const SizedBox(
                  height: 20,
                ),
                // Container(
                //   width: MediaQuery.of(context).size.width * 0.7,
                //   padding: const EdgeInsets.all(5),
                //   decoration: BoxDecoration(
                //     color: Colors.blue.withOpacity(0.3),
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: listtrimDow.isNotEmpty
                //       ? DropdownButton<String>(
                //           value: matiere,
                //           borderRadius: BorderRadius.circular(10),
                //           alignment: AlignmentDirectional.centerStart,

                //           isExpanded: true,
                //           iconEnabledColor: Colors.black,
                //           iconSize: 30,
                //           elevation: 16,
                //           //style: TextStyle(color: Colors.teal),
                //           underline: Container(
                //             decoration: const BoxDecoration(
                //               color: Colors.black,
                //             ),
                //           ),
                //           onChanged: (String? newValue) {
                //             setState(() {
                //               matiere = newValue;
                //             });
                //           },
                //           items: listmatDow.map((value) {
                //             return DropdownMenuItem<String>(
                //               value: value,
                //               child: Text(value),
                //             );
                //           }).toList(),
                //           hint: const Text(
                //             "Choisir la matière",
                //             style: TextStyle(
                //                 fontSize: 16, fontWeight: FontWeight.w500),
                //           ),
                //         )
                //       : Shimmer.fromColors(
                //           period: const Duration(milliseconds: 500),
                //           child: Container(
                //             margin: const EdgeInsets.all(0.0),
                //             height: 50,
                //             color: Colors.grey.withOpacity(0.5),
                //             width: double.infinity,
                //             child: const Center(
                //               child: Text('patientez svp'),
                //             ),
                //           ),
                //           baseColor: Colors.grey.shade400,
                //           highlightColor: Colors.grey.shade200,
                //         ),
                // ),

                const SizedBox(
                  height: 15,
                ),
                boutton(context, 'Rechercher', () {}, 250, 17),
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Votre avis compte 😃 ",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          // Navigator.push(
                          //     context,
                          //     PageTransition(
                          //       alignment: Alignment.bottomCenter,
                          //       duration: Duration(milliseconds: 300),
                          //       type: PageTransitionType.bottomToTop,
                          //       child: const Suggestion(),
                          //     ));
                        },
                        child: const Text(
                          "Je donne mon avis",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
