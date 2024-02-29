import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/questions/data/models/question.dart';
import 'package:monprof/questions/data/repository/question_repository.dart';

class QuestionController extends GetxController {
  final QuestionRepository repository;
  final int categorie;
  final int matiere;

  QuestionController(
      {required this.repository,
      required this.categorie,
      required this.matiere});


// les  controller pour la créationd 'une question

  TextEditingController controllerTitre = TextEditingController();
  TextEditingController controllerDesc = TextEditingController();

  // les Etats de l'Application

  AppState<List<Questions>?> getQuestionState =
      AppState(status: AppStatus.loading);
  AppState<bool> createQuestionState = AppState();

  QuestionController get question => Get.find();


@override
  void onInit() {
    getQuestion();
    super.onInit();
  }

  //Récupération de la liste des questioons

  Future getQuestion() async {
    try {
      getQuestionState = AppState(status: AppStatus.loading);
      update();
      final result =
          await repository.getQuestion(categorie: categorie, matiere: matiere);
      getQuestionState =
          AppState(data: result, status: AppStatus.data, errorModel: null);
      update();
    } catch (e) {
      getQuestionState = AppState(
          status: AppStatus.error, data: null, errorModel: returnError(e));
      update();
    }
  }

  //  Création d'une question

  Future createQuestion() async {
    try {
      createQuestionState = AppState(status: AppStatus.loading);
      update();

      final Questions question = Questions(
        description: controllerDesc.text,
        categorie_id: categorie,
        matieres_id: matiere,
        titre: controllerTitre.text.trim().isNotEmpty? controllerTitre.text:Get.find<HomeController>().matiere?.libelle,
      );
      final result = await repository.createQuestion(question: question);
      controllerDesc.text= '';
      controllerTitre.text= '';
      createQuestionState = AppState(data: result, status: AppStatus.data, errorModel: null);
    } catch (e) {
      createQuestionState = AppState(
          status: AppStatus.error, data: null, errorModel: returnError(e));
      update();
    }
  } 

  ///
}
