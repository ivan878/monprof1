import 'package:flutter/material.dart';

import '../components/row_compte.dart';

class CompteUser extends StatefulWidget {
  const CompteUser({super.key});

  @override
  State<CompteUser> createState() => _CompteUserState();
}

class _CompteUserState extends State<CompteUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compte'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              rowCompte(Colors.blue, "Informations sur le compte", Icons.info),
              const SizedBox(
                height: 5,
              ),
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          height: 100,
                          child: ClipOval(
                              child: Image.asset('assets/study3.png'))),
                      const Column(
                        children: [
                          Text(
                            "Error to get a name",
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            'eleve',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              rowCompte(Colors.blue, "Informations sur le statut du compte",
                  Icons.real_estate_agent),
              const SizedBox(
                height: 5,
              ),
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Statut du Compte',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            " Statut",
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 150,
                        child: Column(
                          children: [],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      const Text(
                        "Si vous disposez "
                        "d'un code d'activation, veuillez activer cet abonnement ",
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 15),
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: TextButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => const ActiveCompte()),
                            // );
                          },
                          child: const Text(
                            "Activer",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              rowCompte(Colors.blue, "Information sur l'application",
                  Icons.app_settings_alt_outlined),
              const SizedBox(
                height: 15,
              ),
              const Icon(
                Icons.school_outlined,
                size: 250,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'MonProf version 1.0',
                style: TextStyle(fontWeight: FontWeight.w200, fontSize: 17),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const CircleAvatar(
                          maxRadius: 20,
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: const CircleAvatar(
                          maxRadius: 20,
                          backgroundColor: Colors.green,
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: const CircleAvatar(
                            maxRadius: 20,
                            backgroundImage: AssetImage('assets/insta.png')),
                      ),
                      InkWell(
                        onTap: () {},
                        child: const CircleAvatar(
                          maxRadius: 20,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
