import 'package:monprof/UI/loading.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/cours/data/models/cours_model.dart';
import 'package:monprof/cours/logique_metier/cous_controller.dart';
import 'package:monprof/paiements/presentation/paiements_screen.dart';
import 'package:monprof/cours/logique_metier/video_reader_controller.dart';

class CoursBody extends StatefulWidget {
  final CoursController controller;
  const CoursBody({super.key, required this.controller});

  @override
  State<CoursBody> createState() => _CoursBodyState();
}

class _CoursBodyState extends State<CoursBody> {
  late CoursController controller;

  @override
  void initState() {
    controller = widget.controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.coursState.isLoading
          ? const Loading()
          : controller.coursState.hasError
              ? ErrorPage(
                  errorMessage: controller.coursState.errorModel?.error ??
                      'Something went wrong',
                  reload: () async {
                    await controller.getCours();
                  },
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.getCours();
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      ...controller.coursState.data!.map(
                        (cours) => Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1,
                                style: BorderStyle.solid,
                                color: Colors.blue),
                          ),
                          child: Column(
                            children: [
                              BuildCourComponen(cours: cours),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class BuildCourComponen extends StatelessWidget {
  final Cours cours;
  const BuildCourComponen({super.key, required this.cours});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FutureBuilder<bool>(
          future:
              Future.delayed(const Duration(seconds: 3)).then((value) => true),
          builder: (context, snapshot) {
            return CircleAvatar(
              backgroundColor: Colors.blue,
              child: (snapshot.hasData && snapshot.data!)
                  ? const Icon(Icons.play_circle, color: Colors.white)
                  : (cours.open)
                      ? const Icon(Icons.download, color: Colors.white)
                      : const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
            );
          }),
      title: SimpleText(
        text: cours.libelle,
        maxlines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: SimpleText(
        text: cours.description,
        maxlines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        child: !cours.open
            ? const Icon(Icons.lock)
            : PopupMenuButton(
                itemBuilder: ((context) => [
                      PopupMenuItem(
                          child: const Text('retélécharger'),
                          onTap: () async {}),
                      PopupMenuItem(
                          child: const Text('Supprimer'), onTap: () async {}),
                    ])),
      ),
      onTap: () {
        if (!cours.open) {
          changeScreen(context, const PaiementsScreen());
        } else {
          VideoController().downloadvideo(
            cours.video_url,
            cours.video_url,
            context,
          );
        }
      },
    );
  }
}
