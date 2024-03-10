import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:monprof/UI/loading.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/home/data/repository/home_repository.dart';
import 'package:monprof/paiements/presentation/paiement_parent.dart';
// import 'package:monprof/UI/paiementPScreen.dart';
// import 'package:monprof/home/presentation/compte_screen.dart';

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
    return GetBuilder(
        init: HomeController(
          repository: GetIt.instance<HomeRepository>(),
        ),
        builder: (HomeController controller) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const SimpleText(text: "MonProf"),
                elevation: 0,
                actions: [],
              ),
              body: controller.categorieParentState.isLoading
                  ? const Loading()
                  : controller.categorieParentState.hasError
                      ? ErrorPage(
                          errorMessage: controller
                                  .categorieParentState.errorModel?.error ??
                              "Something whent's wrong",
                          reload: () async {
                            await controller.initFunction();
                          },
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            controller.initFunction();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                      child: GestureDetector(
                                        onTap: () {
                                          changeScreen(
                                            context,
                                            const PaimentParentScreen(),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 15),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                width: 1, color: Colors.blue),
                                          ),
                                          child: const SimpleText(
                                            text: 'Faire un achat',
                                            color: Colors.blue,
                                            weight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SimpleText(
                                    text: 'statuts',
                                    color: Colors.blue,
                                    weight: FontWeight.w400,
                                    size: 20,
                                  ),
                                  const Divider(
                                    thickness: 2,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 0),
                                    child: GridView(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.85,
                                          mainAxisSpacing: 15,
                                          crossAxisSpacing: 15,
                                        ),
                                        children: controller
                                            .categorieParentState.data!
                                            .map((data) => Column(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: colorstat[0],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child:
                                                            Column(children: [
                                                          Text(
                                                            data.categorie
                                                                    .libelle ??
                                                                '',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 17,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const Divider(
                                                            thickness: 3,
                                                          ),
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                'Total',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                              Text(
                                                                data.total
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                'Activer',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                              Text(
                                                                data.active
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 2,
                                                                    horizontal:
                                                                        20),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          40),
                                                            ),
                                                            child: Text(
                                                              data.unactive
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 17,
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                            .toList()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          );
        });
  }
}
