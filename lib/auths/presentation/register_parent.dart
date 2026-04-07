import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/UI/contatUserScreen.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:form_validator/form_validator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/home/presentation/homparent.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';
import 'package:monprof/auths/logique_metier/register_controller.dart';
// import 'package:monprof/UI/loading.dart';
// import 'package:monprof/auths/datas/models/classe_model.dart';

// ignore_for_file: sort_child_properties_last

class RegisterParentScreen extends StatefulWidget {
  const RegisterParentScreen({super.key});

  @override
  State<RegisterParentScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterParentScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: RegisterController(
          repository: GetIt.instance<UserRepository>(), canGetclasse: false),
      builder: (RegisterController controller) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: SimpleText(
              text: "INSCRIPTION".tr,
              letterspacing: 3,
            ),
            elevation: 0,
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                    onTap: () {},
                    child: const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: FaIcon(
                        FontAwesomeIcons.info,
                        color: Colors.white,
                      ),
                    )),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(15),
              child: Form(
                key: controller.formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFielApp(
                            validator: ValidationBuilder(
                                    requiredMessage: "Renseignez le nom".tr)
                                .minLength(3, 'Nom incorrect'.tr)
                                .required()
                                .build(),
                            controller: controller.controllerName,
                            hinText: 'Nom'.tr,
                            suffixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: TextFielApp(
                            validator: ValidationBuilder(
                                    requiredMessage: "Renseignez le nom".tr)
                                .minLength(3, 'Nom incorrect'.tr)
                                .build(),
                            controller: controller.controllerLastName,
                            hinText: 'Prenom'.tr,
                            suffixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFielApp(
                      validator: ValidationBuilder(
                              requiredMessage: "Renseignez l'adresse E-mail".tr)
                          .email("Email incorrecte".tr)
                          .required()
                          .build(),
                      controller: controller.controllerEmail,
                      hinText: 'Email'.tr,
                      suffixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: 10),
                    TextFielApp(
                      validator:
                          ValidationBuilder(requiredMessage: "Votre école".tr)
                              .required()
                              .build(),
                      controller: controller.controllerProfession,
                      hinText: 'Profession'.tr,
                      suffixIcon: const Icon(Icons.work),
                    ),
                    const SizedBox(height: 10),
                    TextFielApp(
                      validator: ValidationBuilder(
                              requiredMessage:
                                  "Renseignez un numéro de téléphone".tr)
                          .maxLength(9, 'le numéro a 9 chiffre'.tr)
                          .minLength(9, 'le numéro a 9 chiffre'.tr)
                          .required()
                          .build(),
                      controller: controller.controllerPhone,
                      lenght: 9,
                      hinText: 'Téléphone'.tr,
                      suffixIcon: const Icon(Icons.phone_outlined),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                        focusColor: Colors.white,
                        initialValue: controller.controllerSexe,
                        alignment: AlignmentDirectional.centerStart,
                        isExpanded: true,

                        // iconEnabledColor: Colors.black,
                        iconSize: 30,
                        elevation: 16,
                        decoration: appInputDecoration(),
                        items: controller.sexesChoices
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                  // color: Colors.black,
                                  ),
                            ),
                          );
                        }).toList(),
                        hint: Text(
                          "Genre".tr,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onChanged: (String? value) {
                          controller.changeSexe(value);
                        }),
                    const SizedBox(height: 10),
                    TextFielApp(
                      hinText: 'Mot de passe'.tr,
                      inputType: TextInputType.visiblePassword,
                      controller: controller.controllerPassword,
                      obscureTexte: controller.obscureText,
                      maxLines: 1,
                      suffixIcon: GestureDetector(
                        onTap: () =>
                            controller.chanObscureText(!controller.obscureText),
                        child: Icon(
                          controller.obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.security),
                      validator: ValidationBuilder(
                              requiredMessage: 'Mot de passe obligatoire'.tr)
                          .minLength(
                              6, 'le mote de passe a au moins 6 caractère'.tr)
                          .build(),
                    ),
                    const SizedBox(height: 10),
                    TextFielApp(
                      hinText: 'Confirmez le mot de passse'.tr,
                      inputType: TextInputType.visiblePassword,
                      obscureTexte: controller.obscureText,
                      prefixIcon: const Icon(Icons.lock),
                      maxLines: 1,
                      validator: (val) {
                        if (val == controller.controllerPassword.text) {
                          return null;
                        }
                        return "Mot de passe obligatoire".tr;
                      },
                    ),
                    const SizedBox(height: 15),
                    Text(
                        "En vous inscrivant, vous acceptez les politiques générale d'utilisation et de vente de Monprof"
                            .tr,
                        style: const TextStyle(fontWeight: FontWeight.w300)),
                    Row(
                      children: [
                        Checkbox(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            value: controller.politiqueAccepted,
                            onChanged: (pol) => controller.changePolitique(
                                !controller.politiqueAccepted)),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  alignment: Alignment.bottomCenter,
                                  type: PageTransitionType.rightToLeft,
                                  child: const ContratUser(),
                                ),
                              );
                            },
                            child: Text('Lire la politique...'.tr,
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                    Visibility(
                      visible: controller.politiqueAccepted,
                      child: DefaultButton(
                        onPressed: () async {
                          await controller.registerParent().then((value) {
                            if (controller.state.hasData) {
                              Notify.toast('Opérations réusite'.tr);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HomeParentScreen(),
                                  ),
                                  (route) => false);
                            } else {
                              loger(
                                controller.state.errorModel?.error ?? '',
                              );
                              Notify.showFailure(context,
                                  controller.state.errorModel?.error ?? '');
                            }
                          });
                        },
                        text: 'INSCRIPTION'.tr,
                        wdiget: controller.state.isLoading
                            ? SizedBox(
                                height: 50,
                                width: 50,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("j'ai déja un compte".tr.capitalizeFirst ?? '',
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w300)),
                            Text(
                              "connectez vous".tr,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
