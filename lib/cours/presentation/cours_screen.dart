import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/home/data/models/categorie_model.dart';
import 'package:monprof/home/data/models/matieres_models.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/cours/logique_metier/cous_controller.dart';
import 'package:monprof/cours/presentation/componens/cour_body.dart';
import 'package:monprof/cours/data/repository/cours_repository.dart';
import 'package:monprof/cours/presentation/componens/question_body.dart';
// import 'package:monprof/auths/datas/models/classe_model.dart';

class CoursScreen extends StatefulWidget {
  final Categorie categorie;
  final Matiere matiere;
  const CoursScreen(
      {super.key, required this.categorie, required this.matiere});

  @override
  State<CoursScreen> createState() => _CoursScreenState();
}

class _CoursScreenState extends State<CoursScreen> {
  late Categorie categorie;
  late Matiere matiere;
  int indextab = 0;

  @override
  void initState() {
    categorie = widget.categorie;
    matiere = widget.matiere;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: CoursController(
          repository: GetIt.instance<CoursRepository>(),
          matiere: matiere,
          categorie: categorie,
        ),
        builder: (CoursController controller) {
          return DefaultTabController(
            length: 2,
            child: RefreshIndicator(
              onRefresh: () async {},
              child: Scaffold(
                appBar: AppBar(
                  title: SimpleText(
                      text: HomeController.data.classe?.libelle ?? 'Classe'),
                  bottom: TabBar(
                    onTap: (value) {
                      setState(() {
                        indextab = value;
                      });
                    },
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.book),
                        text: 'Exercices/Sujets',
                      ),
                      Tab(
                        icon: Icon(Icons.message),
                        text: 'Forum',
                      ),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    CoursBody(controller: controller),
                    QuestionBody(controller: controller),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
