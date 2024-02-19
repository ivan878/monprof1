import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/UI/loading.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/cours/logique_metier/cous_controller.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/questions/data/repository/question_repository.dart';
import 'package:monprof/questions/logique_metier/questions_controller.dart';
import 'package:monprof/questions/presentation/create_question_screen.dart';

class QuestionBody extends StatefulWidget {
  final CoursController controller;
  const QuestionBody({super.key, required this.controller});

  @override
  State<QuestionBody> createState() => _QuestionBodyState();
}

class _QuestionBodyState extends State<QuestionBody> {
  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    return GetBuilder(
      init: QuestionController(
        repository: GetIt.instance<QuestionRepository>(),
        categorie: homeController.categorie!.id!,
        matiere: homeController.matiere!.id!,
      ),
      builder: (QuestionController controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              changeScreen(context, const CreateQuestionScreen());
            },
            label: const SimpleText(text: 'Question'),
            icon: const Icon(Icons.add_circle_outline),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: controller.getQuestionState.isLoading
                ? const Loading()
                : controller.getQuestionState.hasError
                    ? ErrorPage(
                        errorMessage: controller
                                .getQuestionState.errorModel?.error ??
                            'Impossible de récupérer les liste des questions',
                        reload: () async {
                          await controller.getQuestion();
                        },
                      )
                    : Column(
                        children: [
                          ...controller.getQuestionState.data!.reversed
                              .map((question) => ListTile(
                                    title: SimpleText(
                                      text: question.titre ??
                                          homeController.matiere!.libelle!,
                                      maxlines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      weight: FontWeight.w600,
                                    ),
                                    subtitle: SimpleText(
                                      text: question.description,
                                      maxlines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList()
                        ],
                      ),
          ),
        );
      },
    );
  }
}
