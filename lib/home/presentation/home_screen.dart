import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:monprof/UI/loading.dart';
import 'package:monprof/UI/suggestionScreen.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/cours/presentation/cours_screen.dart';
import 'package:monprof/home/presentation/compte_screen.dart';
import 'package:monprof/home/data/models/categorie_model.dart';
import 'package:monprof/home/data/models/matieres_models.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/home/data/repository/home_repository.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                      onTap: () async {
                        changeScreen(context, CompteUser());
                      },
                      child: Image.asset('assets/study2.png')),
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
                          "Something whent's wrong",
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
                                    ? const SimpleText(
                                        text:
                                            'Aucune matière disponible por le moment')
                                    : DropdownButtonFormField<Matiere?>(
                                        focusColor: Colors.white,
                                        value: controller.matiere,
                                        validator: (value) {
                                          return value == null
                                              ? "choisir une matière"
                                              : null;
                                        },
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        isExpanded: true,
                                        style: textStyle.copyWith(color: white),
                                        iconEnabledColor: Colors.black,
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
                                              color: Colors.black,
                                            ),
                                          );
                                        }).toList(),
                                        hint: const Text(
                                          "Matière",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        onChanged: (Matiere? value) {
                                          controller.changeMatiere(value);
                                        }),
                                const SizedBox(height: 20),
                                (controller.categorieState.data ?? []).isEmpty
                                    ? const SimpleText(
                                        text: 'Impossible charger les catégrie')
                                    : DropdownButtonFormField<Categorie?>(
                                        focusColor: Colors.white,
                                        value: controller.categorie,
                                        validator: (value) {
                                          return value == null
                                              ? "choisir une catégorie"
                                              : null;
                                        },
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        isExpanded: true,
                                        style: textStyle.copyWith(color: white),
                                        iconEnabledColor: Colors.black,
                                        iconSize: 30,
                                        elevation: 16,
                                        decoration: appInputDecoration(),
                                        items: (controller
                                                    .categorieState.data ??
                                                [])
                                            .map((e) => e.categorie)
                                            .toList()
                                            .map<DropdownMenuItem<Categorie?>>(
                                                (Categorie value) {
                                          return DropdownMenuItem<Categorie>(
                                            value: value,
                                            child: SimpleText(
                                              text: value.libelle ?? '',
                                              color: Colors.black,
                                            ),
                                          );
                                        }).toList(),
                                        hint: const Text(
                                          "Categorie",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        onChanged: (Categorie? value) {
                                          controller.changeCategorie(value);
                                        }),
                                const SizedBox(height: 15),
                                DefaultButton(
                                  text: 'Rechercher',
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
                                    const Text(
                                      "Votre avis compte 😃 ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          changeScreen(context, Suggestion());
                                        },
                                        child: const Text(
                                          "Je donne mon avis",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        )),
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
}
