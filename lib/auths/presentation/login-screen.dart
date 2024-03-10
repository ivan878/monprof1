import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import '../../components/input.dart';
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
  final numeroController = TextEditingController();
  final nomController = TextEditingController();
  final passwordController = TextEditingController();

  bool isloading = false;

  String? valeurClasse;

  bool visible = false;
  bool visibleconfir = false;
  String requestError = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
                      const Text(
                        'CONNECTEZ VOUS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      const Text(
                        'Remplire les champs pour vous connectez',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Column(
                        children: [
                          input(
                            ValidationBuilder(
                                    requiredMessage: 'Email obligatoire')
                                .email("email incorrecte")
                                .build(),
                            controller.controllerEmail,
                            'Email',
                            const Icon(Icons.email_outlined),
                          ),
                          // TextFielApp(
                          //   hinText: 'Email',
                          //   prefixIcon: const Icon(Icons.email_outlined),
                          //   inputType: TextInputType.emailAddress,
                          //   controller: controller.controllerEmail,
                          //   validator: ValidationBuilder(
                          //           requiredMessage: 'Email obligatoire')
                          //       .email("email incorrecte")
                          //       .build(),
                          // ),
                          const SizedBox(height: 15),
                          inputPassword(
                              ValidationBuilder(
                                      requiredMessage:
                                          'Mot de passe obligatoire')
                                  .minLength(6,
                                      'le mote de passe a au moins 6 caractère')
                                  .build(),
                              controller.controllerPassword,
                              controller.obscureText,
                              'Mot de passe',
                              const Icon(Icons.lock), () {
                            () => controller.chanObscureText();                            
                            Icon(
                              controller.obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            );
                          }),
                          // TextFielApp(
                          //   hinText: 'Mot de passe',
                          //   inputType: TextInputType.visiblePassword,
                          //   controller: controller.controllerPassword,
                          //   obscureTexte: controller.obscureText,
                          //   maxLines: 1,
                          //   suffixIcon: GestureDetector(
                          //     onTap: () => controller
                          //         .chanObscureText(controller.obscureText),
                          //     child: Icon(
                          //       controller.obscureText
                          //           ? Icons.visibility_off
                          //           : Icons.visibility,
                          //     ),
                          //   ),
                          //   prefixIcon: const Icon(Icons.security),
                          //   validator: ValidationBuilder(
                          //           requiredMessage: 'Mot de passe obligatoire')
                          //       .minLength(6,
                          //           'le mote de passe a au moins 6 caractère')
                          //       .build(),
                          // ),
                          const SizedBox(height: 15),
                          DefaultButton(
                            onPressed: () async {
                              await controller.login().then((value) {
                                if (controller.state.hasData) {
                                  Notify.showSuccess(
                                      context, 'Opérations réusite');
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
                                  Notify.showFailure(
                                      context,
                                      controller.state.errorModel?.error ??
                                          'svp remplire les champs...😮😌');
                                }
                              });
                            },
                            text: 'CONNEXION',
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
                            onTap: () {},
                            child: SimpleText(
                              text: "Mots de passe oublier? 😥",
                              weight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const SimpleText(
                                  text: "Pas de compte ?",
                                  weight: FontWeight.w300,
                                  size: 17,
                                ),
                                InkWell(
                                  onTap: () {
                                    registerChoice(context);
                                  },
                                  child: SimpleText(
                                    text: "Inscrivez vous",
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

  registerChoice(BuildContext context) {
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
              const SimpleText(
                text: 'Comment souhaitez-vous vous inscire ?',
                weight: FontWeight.w700,
                size: 18,
                letterspacing: 3,
                align: TextAlign.center,
              ),
              SpacerHeight(20),
              DefaultButton(
                text: 'Je suis élève',
                onPressed: () {
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
              SpacerHeight(15),
              DefaultButton(
                text: 'Je suis tuteur',
                onPressed: () {
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
              SpacerHeight(30)
            ],
          ),
        );
      },
    );
  }
}
