import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/sugestion/suggestionScreen.dart';
// import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/cours/presentation/cours_screen.dart';
import 'package:monprof/home/presentation/profile_compte_screen.dart';
import 'package:monprof/home/data/models/categorie_model.dart';
import 'package:monprof/home/data/models/matieres_models.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/home/data/repository/home_repository.dart';
import 'package:monprof/notification/data/services/notification_api.dart';
import 'package:monprof/notification/notification_controller.dart';
import 'package:monprof/notification/screnn/notification_screnn.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((t) {
        Get.find<HomeController>().listenserDeviceUpdated(context);
        Get.find<HomeController>().updateToken();
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    Get.put(NotificationController(api: GetIt.instance<NotificationApi>()));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<HomeController>().listenserDeviceUpdated(context);
      Get.find<HomeController>().checkUpdate().then((value) {
        if (value == "true") {
          if (mounted) showUpdateDialog(context);
        }
      });
    });
    super.initState();
  }

  final formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: HomeController(
        repository: GetIt.instance<HomeRepository>(),
      ),
      builder: (HomeController controller) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const SimpleText(text: "MonProf"),
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
                  child: SimpleText(
                      text: controller.classe?.shortName ?? '', size: 15),
                ),
              ),
              GetBuilder<NotificationController>(
                builder: (controller) {
                  return GestureDetector(
                    onTap: () {
                      changeScreen(context, const NotificationScreen());
                    },
                    child: CircleAvatar(
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.notifications,
                            size: 27,
                            color: Colors.blue,
                          ),
                          if ((controller.unreadNotification.data ?? 0) > 0)
                            const Positioned(
                              right: 0,
                              top: 0,
                              child: Icon(
                                Icons.circle,
                                size: 14,
                                color: Colors.red,
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () async {
                      changeScreen(context, const ProfileCompteScreen());
                    },
                    child: controller.users?.profile_image?.isNotEmpty == true
                        ? CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                controller.users!.profile_image!),
                          )
                        : Image.asset('assets/study2.png'),
                  ),
                ),
              ),
            ],
          ),
          body: controller.matiereState.isLoading ||
                  controller.categorieState.isLoading
              ? const Loading()
              : controller.matiereState.hasError ||
                      controller.categorieState.hasError
                  ? ErrorPage(
                      errorMessage: controller.matiereState.errorModel?.error ??
                          controller.categorieState.errorModel?.error ??
                          "Something whent's wrong".tr,
                      reload: () async {
                        await controller.initFunction();
                      },
                    )
                  : SingleChildScrollView(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          child: Form(
                            key: formkey,
                            child: Column(
                              children: [
                                Image.asset('assets/mp2.png'),
                                const SizedBox(height: 15),
                                (controller.matiereState.data ?? []).isEmpty
                                    ? SimpleText(
                                        text:
                                            'Aucune matière disponible por le moment'
                                                .tr)
                                    : DropdownButtonFormField<Matiere?>(
                                        // focusColor: Colors.white,
                                        value: controller.matiere,
                                        validator: (value) {
                                          return value == null
                                              ? "choisir une matière".tr
                                              : null;
                                        },
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        isExpanded: true,
                                        // style: textStyle.copyWith(color: white),
                                        // iconEnabledColor: Colors.black,
                                        iconSize: 30,
                                        elevation: 16,
                                        decoration: appInputDecoration(),
                                        items: (controller.matiereState.data ??
                                                [])
                                            .map<DropdownMenuItem<Matiere?>>(
                                                (Matiere value) {
                                          return DropdownMenuItem<Matiere>(
                                            value: value,
                                            child: SimpleText(
                                              text: value.libelle ?? '',
                                              // color: Colors.black,
                                            ),
                                          );
                                        }).toList(),
                                        hint: SimpleText(
                                          text: "Matière".tr,
                                          size: 16,
                                          weight: FontWeight.w500,
                                        ),
                                        onChanged: (Matiere? value) {
                                          controller.changeMatiere(value);
                                        }),
                                const SizedBox(height: 20),
                                (controller.categorieState.data ?? []).isEmpty
                                    ? SimpleText(
                                        text:
                                            'Impossible de charger les catégrie'
                                                .tr)
                                    : DropdownButtonFormField<CategorieStatus?>(
                                        // focusColor: Colors.white,
                                        value: controller.categorie,
                                        validator: (value) {
                                          return value == null
                                              ? "choisir une catégorie".tr
                                              : null;
                                        },
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        isExpanded: true,
                                        // style: textStyle.copyWith(color: white),
                                        // iconEnabledColor: Colors.black,
                                        iconSize: 30,
                                        elevation: 16,
                                        decoration: appInputDecoration(),
                                        items:
                                            (controller.categorieState.data ??
                                                    [])
                                                .map((e) => e)
                                                .toList()
                                                .map<
                                                        DropdownMenuItem<
                                                            CategorieStatus?>>(
                                                    (CategorieStatus value) {
                                          return DropdownMenuItem<
                                              CategorieStatus>(
                                            value: value,
                                            child: SimpleText(
                                              text:
                                                  value.categorie.libelle ?? '',
                                              // color: Colors.black,
                                            ),
                                          );
                                        }).toList(),
                                        hint: SimpleText(
                                          text: "Catégorie".tr,
                                          size: 16,
                                          weight: FontWeight.w500,
                                        ),
                                        onChanged: (CategorieStatus? value) {
                                          controller.changeCategorie(value);
                                        }),
                                const SizedBox(height: 15),
                                DefaultButton(
                                  text: 'Rechercher'.tr,
                                  onPressed: () {
                                    if (formkey.currentState!.validate()) {
                                      changeScreen(
                                        context,
                                        CoursScreen(
                                            categorie: controller.categorie!,
                                            matiere: controller.matiere!),
                                      );
                                    }
                                  },
                                  fontSize: 17,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.3),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SimpleText(
                                      size: 12,
                                      text: "Votre avis compte 😃 ".tr,
                                      weight: FontWeight.w300,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        changeScreen(
                                          context,
                                          const Suggestion(),
                                        );
                                      },
                                      child: SimpleText(
                                        text: "Je donne mon avis".tr,
                                        color: Colors.blue,
                                        size: 12,
                                        weight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
        );
      },
    );
  }

  void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png'),
              const Text(
                'Nouvelle version MONPROF disponible',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: const SimpleText(
            text:
                'Une nouvelle version de l\'application est disponible, voulez-vous la télécharger ?',
            align: TextAlign.center,
            size: 15,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Me rappeler plus tard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Ne plus affiche',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.find<HomeController>().launchURL();
              },
              child: const Text(
                'Mettre a jour',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}


// Traduite.