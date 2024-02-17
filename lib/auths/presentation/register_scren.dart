import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:monprof/UI/loading.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/UI/contatUserScreen.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:form_validator/form_validator.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:page_transition/page_transition.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/home/presentation/home_screen.dart';
import 'package:monprof/auths/datas/models/classe_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';
import 'package:monprof/auths/logique_metier/register_controller.dart';

// ignore_for_file: sort_child_properties_last

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool visible = false;
  bool visibleconfir = true;
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: RegisterController(
        repository: GetIt.instance<UserRepository>(),
      ),
      builder: (RegisterController controller) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const SimpleText(text: "Inscription"),
            elevation: 0,
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   PageTransition(
                      //     alignment: Alignment.bottomCenter,
                      //     type: PageTransitionType.rightToLeft,
                      //     child: const Suggestion(),
                      //   ),
                      // );
                    },
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
          body: controller.classeState.isLoading
              ? const Loading()
              : controller.classeState.hasError
                  ? ErrorPage(
                      errorMessage: controller.classeState.errorModel?.error ??
                          'An Error Occured',
                      reload: () => controller.getClasse(),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(30),
                        child: Form(
                          key: controller.formkey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Center(
                                child: Container(
                                    height: 150,
                                    margin: const EdgeInsets.all(10),
                                    padding: const EdgeInsets.all(20),
                                    child: Image.asset('assets/book.png')),
                              ),
                              TextFielApp(
                                controller: controller.controllerName,
                                hinText: 'Nom',
                                prefixIcon: const Icon(Icons.person_outline),
                                validator: ValidationBuilder(
                                        requiredMessage: "Renseignez le nom")
                                    .minLength(3, 'Nom incorrect')
                                    .required()
                                    .build(),
                              ),
                              const SizedBox(height: 10),
                              TextFielApp(
                                controller: controller.controllerLastName,
                                hinText: 'Prenom',
                                prefixIcon: const Icon(Icons.person),
                                validator: ValidationBuilder(
                                        requiredMessage: "Renseignez le nom")
                                    .minLength(3, 'Nom incorrect')
                                    .build(),
                              ),
                              const SizedBox(height: 10),
                              TextFielApp(
                                controller: controller.controllerEmail,
                                hinText: 'Email',
                                inputType: TextInputType.emailAddress,
                                prefixIcon: const Icon(Icons.email_outlined),
                                validator: ValidationBuilder(
                                        requiredMessage:
                                            "Renseignez l'adresse E-mail")
                                    .email("Email incorrecte")
                                    .required()
                                    .build(),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                  focusColor: Colors.white,
                                  value: controller.controllerSexe,
                                  alignment: AlignmentDirectional.centerStart,
                                  isExpanded: true,
                                  style: const TextStyle(color: Colors.white),
                                  iconEnabledColor: Colors.black,
                                  iconSize: 30,
                                  elevation: 16,
                                  decoration: appInputDecoration(),
                                  items: controller.sexesChoices
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                  hint: const Text(
                                    "Genre",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  onChanged: (String? value) {
                                    controller.changeSexe(value);
                                  }),
                              const SizedBox(height: 10),
                              TextFielApp(
                                controller: controller.controllerPhone,
                                hinText: 'Téléphone',
                                lenght: 9,
                                inputType: TextInputType.phone,
                                prefixIcon: const Icon(Icons.phone_outlined),
                                validator: ValidationBuilder(
                                        requiredMessage:
                                            "Renseignez un numéro de téléphone")
                                    .maxLength(9, 'le numéro a 9 chiffre')
                                    .minLength(9, 'le numéro a 9 chiffre')
                                    .required()
                                    .build(),
                              ),
                              const SizedBox(height: 10),
                              (controller.classeState.data ?? []).isEmpty
                                  ? const SizedBox.shrink()
                                  : DropdownButtonFormField<Classe?>(
                                      focusColor: Colors.white,
                                      value: controller.classe,
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      isExpanded: true,
                                      style: textStyle.copyWith(color: white),
                                      iconEnabledColor: Colors.black,
                                      iconSize: 30,
                                      elevation: 16,
                                      decoration: appInputDecoration(),
                                      items: (controller.classeState.data ?? [])
                                          .map<DropdownMenuItem<Classe?>>(
                                              (Classe value) {
                                        return DropdownMenuItem<Classe>(
                                          value: value,
                                          child: SimpleText(
                                            text: value.libelle ?? '',
                                            color: Colors.black,
                                          ),
                                        );
                                      }).toList(),
                                      hint: const Text(
                                        "Classe",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      onChanged: (Classe? value) {
                                        controller.changeClasse(value);
                                      }),
                              const SizedBox(height: 10),
                              TextFielApp(
                                controller: controller.controllerEtablissement,
                                hinText: 'Etablissement',
                                prefixIcon: const Icon(Icons.school),
                                validator: ValidationBuilder(
                                        requiredMessage: "Votre école")
                                    .required()
                                    .build(),
                              ),
                              const SizedBox(height: 10),
                              TextFielApp(
                                hinText: 'Mot de passe',
                                inputType: TextInputType.visiblePassword,
                                controller: controller.controllerPassword,
                                obscureTexte: controller.obscureText,
                                suffixIcon: GestureDetector(
                                  onTap: () => controller
                                      .chanObscureText(controller.obscureText),
                                  child: Icon(
                                    controller.obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                                prefixIcon: const Icon(Icons.security),
                                validator: ValidationBuilder(
                                        requiredMessage:
                                            'Mot de passe obligatoire')
                                    .minLength(6,
                                        'le mote de passe a au moins 6 caractère')
                                    .build(),
                              ),
                              const SizedBox(height: 10),
                              TextFielApp(
                                hinText: 'Confirmez le mot de passse',
                                inputType: TextInputType.visiblePassword,
                                obscureTexte: controller.obscureText,
                                prefixIcon: const Icon(Icons.lock),
                                validator: (val) {
                                  if (val ==
                                      controller.controllerPassword.text) {
                                    return null;
                                  }
                                  return "Mot de passe obligatoire";
                                },
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                  "En vous inscrivant, vous acceptez la politique générale d'utilisation  et de vente de Monprof ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w300)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Checkbox(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      value: controller.politiqueAccepted,
                                      onChanged: (pol) =>
                                          controller.changePolitique(
                                              !controller.politiqueAccepted)),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            alignment: Alignment.bottomCenter,
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: const ContratUser(),
                                          ),
                                        );
                                      },
                                      child: const Text('Lire la politique...',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold))),
                                ],
                              ),
                              Visibility(
                                visible: controller.politiqueAccepted,
                                child: DefaultButton(
                                    onPressed: () async {
                                      await controller.register().then((value) {
                                        if (controller.state.hasData) {
                                          Notify.showSuccess(
                                              context, 'Opérations réusite');
                                          changeScreen(
                                            context,
                                            const Home(),
                                          );
                                        } else {
                                          Notify.showFailure(
                                              context,
                                              controller.state.errorModel
                                                      ?.error ??
                                                  '');
                                        }
                                      });
                                    },
                                    text: 'INSCRIPTION',
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
                                    fontSize: 20),
                              ),
                              const SizedBox(height: 15),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text("j'ai déja un compte",
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w300)),
                                      Text(
                                        "connectez vous",
                                        style: TextStyle(
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
