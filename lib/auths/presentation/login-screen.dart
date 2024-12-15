// ignore_for_file: use_build_context_synchronously

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/auths/datas/models/otp_model.dart';
import 'package:monprof/auths/presentation/otp_phone_screen.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
// import '../../components/input.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:form_validator/form_validator.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:page_transition/page_transition.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/home/presentation/homparent.dart';
import 'package:monprof/home/presentation/home_screen.dart';
import 'package:monprof/auths/presentation/register_scren.dart';
import 'package:monprof/auths/presentation/register_parent.dart';
import 'package:monprof/auths/logique_metier/login_controller.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';

// import 'package:monprof/UI/avantPageScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final numeroController = TextEditingController();
  // final nomController = TextEditingController();
  // final passwordController = TextEditingController();
  bool obscurText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: Colors.white,
        title: const Center(
            child: Text(
          'M O N P R O F',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        )),
      ),
      body: GetBuilder(
          init: LoginController(repository: GetIt.instance<UserRepository>()),
          builder: (LoginController controller) {
            return SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Form(
                  key: controller.formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                            height: 150,
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(20),
                            child: Image.asset('assets/book.png')),
                      ),
                      Text(
                        'CONNECTEZ VOUS'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          // color: Colors.black
                        ),
                      ),
                      Text(
                        'Remplire les champs pour vous connectez'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Column(
                        children: [
                          TextFielApp(
                            hinText: 'Email'.tr,
                            prefixIcon: const Icon(Icons.email_outlined),
                            inputType: TextInputType.emailAddress,
                            controller: controller.controllerEmail,
                            validator: ValidationBuilder(
                                    requiredMessage: 'Email obligatoire'.tr)
                                .email("email incorrecte".tr)
                                .build(),
                          ),
                          const SizedBox(height: 15),
                          TextFielApp(
                              validator: ValidationBuilder(
                                      requiredMessage:
                                          'Mot de passe obligatoire'.tr)
                                  .minLength(
                                      6,
                                      'le mote de passe a au moins 6 caractère'
                                          .tr)
                                  .build(),
                              controller: controller.controllerPassword,
                              obscureTexte: obscurText,
                              maxLines: 1,
                              hinText: 'Mot de passe'.tr,
                              suffixIcon: GestureDetector(
                                onTap: () =>
                                    setState(() => obscurText = !obscurText),
                                child: Icon(
                                  obscurText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              )),
                          const SizedBox(height: 15),
                          DefaultButton(
                            onPressed: () async {
                              await controller.login().then((value) {
                                if (controller.state.hasData) {
                                  Notify.toastSuccess('Opérations réusite'.tr);
                                  if (controller.state.data!.isParent) {
                                    changeScreen(
                                      context,
                                      const HomeParentScreen(),
                                    );
                                  } else {
                                    changeScreen(
                                      context,
                                      const Home(),
                                    );
                                  }
                                } else {
                                  if (controller.canUsePhoneError) {
                                    changePhone();
                                  }
                                  Notify.showFailure(
                                      context,
                                      controller.state.errorModel?.error ??
                                          'svp remplire les champs...😮😌'.tr);
                                }
                              });
                            },
                            text: 'CONNEXION'.tr,
                            wdiget: controller.state.isLoading
                                ? SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      color: white,
                                    )),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 15),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  alignment: Alignment.bottomCenter,
                                  type: PageTransitionType.rightToLeft,
                                  child: const OtpPhoneScreen(),
                                  childCurrent: const LoginScreen(),
                                ),
                              );
                            },
                            child: SimpleText(
                              text: "Mots de passe oublier? 😥".tr,
                              weight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SimpleText(
                                  text: "Pas de compte ?".tr,
                                  weight: FontWeight.w300,
                                  size: 17,
                                ),
                                InkWell(
                                  onTap: () {
                                    registerChoice();
                                  },
                                  child: SimpleText(
                                    text: "Inscrivez vous".tr,
                                    weight: FontWeight.bold,
                                    color: primaryColor,
                                    size: 17,
                                  ),
                                ),
                              ]),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  registerChoice() async {
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
                title: SimpleText(text: "Elèves".tr),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 27,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageTransition(
                      alignment: Alignment.bottomCenter,
                      type: PageTransitionType.rightToLeft,
                      child: const RegisterScreen(),
                      childCurrent: const LoginScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: SimpleText(
                  text: "Parent".tr,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 27,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageTransition(
                      alignment: Alignment.bottomCenter,
                      type: PageTransitionType.rightToLeft,
                      child: const RegisterParentScreen(),
                      childCurrent: const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  changePhone() async {
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
                  text: "Utiliser ce téléphone".tr,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 27,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.bottomToTop,
                      child: const OtpPhoneScreen(
                        type: OtpType.phoneEmei,
                      ),
                      childCurrent: const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  registerChoices(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: primaryColor,
                    size: 27,
                  ),
                ),
              ),
              SpacerHeight(15),
              SimpleText(
                text: 'Comment souhaitez-vous vous inscire ?'.tr,
                weight: FontWeight.w700,
                size: 18,
                letterspacing: 3,
                align: TextAlign.center,
              ),
              SpacerHeight(20),
              DefaultButton(
                text: 'Je suis élève'.tr,
                onPressed: () {},
              ),
              SpacerHeight(15),
              DefaultButton(
                text: 'Je suis tuteur'.tr,
                onPressed: () {},
              ),
              SpacerHeight(30)
            ],
          ),
        );
      },
    );
  }
}
