import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/components/row_compte.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/paiements/presentation/active_compte.dart';

class CompteUser extends StatefulWidget {
  const CompteUser({super.key});

  @override
  State<CompteUser> createState() => _CompteUserState();
}

class _CompteUserState extends State<CompteUser> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: taille(context).width * 0.55,
                            child: SimpleText(
                              text:
                                  "${controller.users?.name} ${controller.users?.lastName ?? ''}",
                              weight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                              size: 17,
                            ),
                          ),
                          SpacerHeight(10),
                          SimpleText(
                            text: controller.users?.phone ?? "Tel :",
                            weight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                            letterspacing: 2.0,
                          ),
                          SpacerHeight(8),
                          SimpleText(
                            text: controller.eleve?.etablissement ??
                                "Etablissement :",
                            weight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SpacerHeight(8),
                          SimpleText(
                            text: "${controller.classe?.libelle}",
                            weight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              rowCompte(Colors.blue, "Informations sur le statut du compte",
                  Icons.real_estate_agent),
              const SizedBox(height: 5),
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
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            " Statut",
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GetBuilder<HomeController>(
                        builder: (controller) {
                          return controller.categorieState.isLoading
                              ? Center(
                                  child: SizedBox(
                                    height: 70,
                                    width: 70,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: CircularProgressIndicator(
                                          color: primaryColor),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    ...(controller.categorieState.data ?? [])
                                        .map((categorie) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SimpleText(
                                                    text: (categorie.categorie
                                                                .libelle ??
                                                            '')
                                                        .toUpperCase(),
                                                    size: 15,
                                                    weight: FontWeight.normal,
                                                  ),
                                                  Icon(
                                                    Icons.check_circle,
                                                    size: 27,
                                                    color: categorie.status
                                                        ? Colors.greenAccent
                                                        : red,
                                                  )
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ],
                                );
                        },
                      ),
                      SpacerHeight(10),
                      const Divider(),
                      const SimpleText(
                        text:
                            "Si vous disposez d'un code d'activation, veuillez activer cet abonnement ",
                        weight: FontWeight.w300,
                        size: 15,
                        align: TextAlign.center,
                      ),
                      SpacerHeight(10),
                      Center(
                        child: SizedBox(
                          width: taille(context).width * 0.5,
                          child: DefaultButton(
                            text: 'Activer',
                            color: Colors.blue,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            backgroundColor: Colors.transparent,
                            elevation: 0.0,
                            radius: 10,
                            borderSide: const BorderSide(color: Colors.blue),
                            onPressed: () {
                              changeScreen(context, const ActiveCompte());
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                          backgroundImage: AssetImage('assets/web.png'),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: const CircleAvatar(
                          maxRadius: 20,
                          backgroundColor: Colors.green,
                          backgroundImage: AssetImage('assets/whatsapp.png'),
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
                          child: Icon(
                            Icons.facebook_sharp,
                            color: Colors.white,
                          ),
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
