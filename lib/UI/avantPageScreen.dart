import 'package:flutter/material.dart';

class AvantPage extends StatefulWidget {
  const AvantPage({super.key});

  @override
  State<AvantPage> createState() => _AvantPageState();
}

class _AvantPageState extends State<AvantPage> {
  void nav() {
    // Navigator.push(
    //   context,
    //   PageTransition(
    //     alignment: Alignment.bottomCenter,
    //     type: PageTransitionType.rightToLeft,
    //     child: const Inscription(),
    //   ),
    // );
  }

  void nav2() {
    // Navigator.push(
    //   context,
    //   PageTransition(
    //     alignment: Alignment.bottomCenter,
    //     type: PageTransitionType.rightToLeft,
    //     child: const InscriptionParent(),
    //   ),
    // );
  }

  void politique() {
    // Navigator.of(context).push(
    //   PageTransition(
    //       child: const ContratUser(), type: PageTransitionType.rightToLeft),
    // );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenue'),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(child: Image.asset('assets/mp2.png')),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: listFunctions()[index],
                      child: SizedBox(
                        height: 220,
                        width: 180,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Colors.blue),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(height: index == 2 ? 10 : 3),
                                Expanded(
                                  child: Hero(
                                      tag: "photo$index",
                                      child: Image.asset(assetImage[index])),
                                ),
                                Text(
                                  listElement[index],
                                ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            )
            // bouton2('Parent / tuteur', nav2, 'assets/prof.png'),
            // bouton2('Eleve', nav, 'assets/prof.png'),
            // bouton2('Gude rapde', nav, 'assets/prof.png'),
          ],
        )),
      ),
    );
  }

  listFunctions() => [nav2, nav, politique];
}

final listElement = ['Parent', 'Elève', 'Guide'];
final assetImage = [
  "assets/parent.jpg",
  'assets/eleve.ico',
  'assets/guide.png'
];
