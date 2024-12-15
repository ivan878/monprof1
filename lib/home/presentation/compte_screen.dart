import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monprof/auths/presentation/login-screen.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/components/row_compte.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/paiements/presentation/active_compte.dart';
import 'package:monprof/splash/splash_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CompteUser extends StatefulWidget {
  const CompteUser({super.key});

  @override
  State<CompteUser> createState() => _CompteUserState();
}

class _CompteUserState extends State<CompteUser> {
  String version = '';
  String buildnumber = '';

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  getInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    buildnumber = packageInfo.buildNumber;
    version = packageInfo.version;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compte'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              onPressed: () async {
                logOut(controller: controller);
              },
              icon: const Icon(
                Icons.logout,
                size: 30,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              rowCompte(
                  Colors.blue, "Informations sur le compte".tr, Icons.info),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          buildProfile(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
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
                                text:
                                    controller.users?.phone ?? "${"Tel".tr} :",
                                weight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                                letterspacing: 2.0,
                              ),
                              SpacerHeight(8),
                              SimpleText(
                                text: controller.eleve?.etablissement ??
                                    "${"Etablissement".tr} :",
                                weight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SpacerHeight(8),
                              SimpleText(
                                text: "${controller.classe?.libelle}",
                                weight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SpacerHeight(10),
                              GestureDetector(
                                onTap: () {
                                  logOut(delete: true, controller: controller);
                                },
                                child: rowCompte(
                                  Colors.red,
                                  "Supprimer le compte",
                                  Icons.delete,
                                  iconColor: red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SpacerHeight(30),
                      SimpleText(
                          text: "Langue de l'application".tr,
                          size: 16,
                          weight: FontWeight.bold),
                      SpacerHeight(5),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              onTap: () async =>
                                  await Get.find<SplaController>()
                                      .updateLocal(const Locale('fr')),
                              title: FittedBox(
                                  child: SimpleText(text: 'Français'.tr)),
                              leading: Icon(
                                  Get.locale?.languageCode == 'fr'
                                      ? Icons.circle
                                      : Icons.circle_outlined,
                                  color: Get.locale?.languageCode == 'fr'
                                      ? primaryColor
                                      : null),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              onTap: () async => Get.find<SplaController>()
                                  .updateLocal(const Locale('en')),
                              title: FittedBox(
                                  child: SimpleText(text: 'English'.tr)),
                              leading: Icon(
                                  Get.locale?.languageCode == 'en'
                                      ? Icons.circle
                                      : Icons.circle_outlined,
                                  color: Get.locale?.languageCode == 'en'
                                      ? primaryColor
                                      : null),
                            ),
                          ),
                        ],
                      ),
                      SpacerHeight(15),
                      SimpleText(
                          text: "Thème de l'application".tr,
                          size: 16,
                          weight: FontWeight.bold),
                      SpacerHeight(5),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          !Get.find<SplaController>().isDarkmode
                                              ? primaryColor
                                              : Colors.grey.shade200),
                                ),
                                child: ListTile(
                                  onTap: () async {
                                    await Get.find<SplaController>()
                                        .updateThemMode(ThemeMode.light);
                                    setState(() {});
                                  },
                                  title: const SimpleText(text: 'Claire'),
                                  trailing:
                                      const Icon(Icons.light_mode, size: 27),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          Get.find<SplaController>().isDarkmode
                                              ? primaryColor
                                              : Colors.grey.shade400),
                                ),
                                child: ListTile(
                                  onTap: () async {
                                    await Get.find<SplaController>()
                                        .updateThemMode(ThemeMode.dark);
                                    setState(() {});
                                  },
                                  title: SimpleText(text: 'Sombre'.tr),
                                  trailing:
                                      const Icon(Icons.dark_mode, size: 27),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SpacerHeight(15),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              rowCompte(Colors.blue, "Informations sur le statut du compte".tr,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Statut du Compte'.tr,
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            " Statut".tr,
                            style: const TextStyle(
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
                      SimpleText(
                        text:
                            "Si vous disposez d'un code d'activation, veuillez activer cet abonnement"
                                .tr,
                        weight: FontWeight.w300,
                        size: 15,
                        align: TextAlign.center,
                      ),
                      SpacerHeight(10),
                      Center(
                        child: SizedBox(
                          width: taille(context).width * 0.5,
                          child: DefaultButton(
                            text: 'Activer'.tr,
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
              rowCompte(Colors.blue, "Information sur l'application".tr,
                  Icons.app_settings_alt_outlined),
              const SizedBox(
                height: 15,
              ),
              rowCompte(
                Colors.grey,
                "${"MonProf version".tr} $version $buildnumber",
                Icons.school_outlined,
                iconColor: greyColors,
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
                        onTap: () async {
                          await Utils.openUrl('https://www.monprof.org/wp');
                        },
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
                        onTap: () async {
                          await Utils.openUrl(
                              'https://www.instagram.com/monprofcm?igsh=cWw3ano3MG42amIO');
                        },
                        child: const CircleAvatar(
                            maxRadius: 20,
                            backgroundImage: AssetImage('assets/insta.png')),
                      ),
                      InkWell(
                        onTap: () async {
                          await Utils.openUrl(
                              'https://web.facebook.com/monprofcm');
                        },
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

  logOut({required HomeController controller, bool delete = false}) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: SimpleText(
                  text: delete
                      ? "Confirmer La supression".tr
                      : 'Se déconnecter'.tr,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 27,
                ),
                onTap: () async {
                  await controller.logout().then((value) {
                    if (value) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (route) => false);
                    } else {
                      Notify.showFailure(
                          context, 'Impossible de se déconnecter'.tr);
                    }
                  });
                },
              ),
              ListTile(
                title: SimpleText(
                  text: "Continuer sur Monprof".tr,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 27,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  updateProfile({required HomeController controller}) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: SimpleText(text: "Caméra".tr),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 27,
                ),
                onTap: () async {
                  final picker = ImagePicker();
                  final file =
                      await picker.pickImage(source: ImageSource.camera);
                  if (file != null) {
                    final image = File(file.path);
                    controller.updateProfileImage(imageProfile: image);
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                title: SimpleText(
                  text: "Galerie".tr,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 27,
                ),
                onTap: () async {
                  final picker = ImagePicker();
                  final file =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (file != null) {
                    final image = File(file.path);
                    controller.updateProfileImage(imageProfile: image);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildProfile() {
    return GetBuilder<HomeController>(builder: (HomeController controller) {
      return SizedBox(
        height: 110,
        width: 110,
        child: Stack(
          children: [
            controller.users?.profile_image?.isNotEmpty == true
                ? Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          controller.users!.profile_image!,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 100,
                    child: ClipOval(
                      child: Image.asset('assets/study3.png'),
                    ),
                  ),
            Positioned(
              top: 5,
              right: 0,
              child: Material(
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: GestureDetector(
                  onTap: () {
                    if (controller.updateProfileState.isLoading) {
                      return;
                    } else {
                      updateProfile(controller: controller);
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: white,
                    child: Center(
                      child: controller.updateProfileState.isLoading
                          ? const CircularProgressIndicator()
                          : Icon(Icons.edit, color: primaryColor),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}


//mutrix_tech.monprof.app