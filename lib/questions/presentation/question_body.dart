import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/UI/loading.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/cours/logique_metier/cous_controller.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/paiements/presentation/paiements_screen.dart';
import 'package:monprof/questions/data/models/question.dart';
import 'package:monprof/questions/data/repository/question_repository.dart';
import 'package:monprof/questions/logique_metier/questions_controller.dart';
import 'package:monprof/questions/presentation/components/pieceJointeScreen.dart';
import 'package:monprof/questions/presentation/create_question_screen.dart';
import 'package:monprof/corps/utils/navigation.dart' as navigator;

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
        categorie: homeController.categorie!.categorie.id!,
        matiere: homeController.matiere!.id!,
      ),
      builder: (QuestionController controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0.0,
            onPressed: () {
              homeController.categorie?.status == true
                  ? changeScreen(context, const CreateQuestionScreen())
                  : changeScreen(
                      context,
                      const PaiementsScreen(),
                    );
            },
            label: SimpleText(
              text: 'Question',
              color: white,
              size: 17,
              letterspacing: 2,
            ),
            icon: Icon(Icons.add_circle_outline, color: white, size: 27),
          ),
          body: Padding(
            padding: const EdgeInsets.all(5),
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
                    : RefreshIndicator(
                        onRefresh: () async {
                          controller.getQuestion();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              ...controller.getQuestionState.data!.reversed
                                  .map((question) => Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255, 50, 122, 181)),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    title: SimpleText(
                                                      text: question.titre ??
                                                          homeController
                                                              .matiere!
                                                              .libelle!,
                                                      maxlines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      weight: FontWeight.w600,
                                                    ),
                                                    subtitle: SimpleText(
                                                      text:
                                                          question.description,
                                                      maxlines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Visibility(
                                                      visible:
                                                          question.image_url !=
                                                              null,
                                                      child: SizedBox(
                                                          height: 100,
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: question
                                                                .image_url!,
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: white,
                                                              ),
                                                            ),
                                                          ))),
                                                  buildQuestion(question,
                                                      homeController, context),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))
                                  .toList(),
                              SpacerHeight(70),
                            ],
                          ),
                        ),
                      ),
          ),
        );
      },
    );
  }

  Container buildQuestion(
      Questions question, HomeController homeController, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: ExpansionTile(
        title: Text(
          question.reponse?.titre.toString() ?? 'reponse',
          style: const TextStyle(color: Color.fromARGB(255, 50, 122, 181)),
        ),
        children: homeController.categorie?.status == true
            ? [
                Text(question.reponse?.description.toString() ??
                    'Pas de reponse pour le moment'),
                Visibility(
                  visible: question.reponse?.image_url != null,
                  child: GestureDetector(
                    onTap: () {
                      navigator.changeScreen(
                          context,
                          PieceJointe(
                            imagepj: question.reponse!.image_url!,
                          ));
                    },
                    child: SizedBox(
                      height: 150,
                      child: CachedNetworkImage(
                        imageUrl: question.reponse?.image_url ?? '',
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ]
            : [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DefaultButton(
                    text: 'Activer la catégorie',
                    onPressed: () async {
                      await navigator.changeScreen(
                        context,
                        const PaiementsScreen(),
                      );
                    },
                  ),
                )
              ],
      ),
    );
  }
}
