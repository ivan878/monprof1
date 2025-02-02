import 'package:get/get.dart';
import 'package:monprof/UI/lecteurvideoScreen.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/utils/notify.dart';
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
              : controller.coursState.hasData &&
                      controller.coursState.data!.isEmpty
                  ? ErrorPage(
                      errorMessage:
                          'Ce contenu sera disponible dans les meilleurs délais',
                      textColor: Theme.of(context).textTheme.titleMedium?.color,
                      texteSize: 17,
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
                                  BuildCourComponen(
                                    cours: cours,
                                    videoController:
                                        VideoController(cours: cours),
                                  ),
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

class BuildCourComponen extends StatefulWidget {
  final Cours cours;
  final VideoController videoController;
  const BuildCourComponen(
      {super.key, required this.cours, required this.videoController});

  @override
  State<BuildCourComponen> createState() => _BuildCourComponenState();
}

class _BuildCourComponenState extends State<BuildCourComponen> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      widget.videoController.existCour();
      return Obx(
        () => ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: widget.videoController.files.value.path.isNotEmpty
                ? const Icon(Icons.play_circle, color: Colors.white)
                : !widget.videoController.loading.value
                    ? const Icon(Icons.download, color: Colors.white)
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          value: widget.videoController.progrees.value,
                        ),
                      ),
          ),
          title: SimpleText(
            text: widget.cours.libelle,
            maxlines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: SimpleText(
            text: widget.cours.description,
            maxlines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            child:
                !widget.cours.open ? const Icon(Icons.lock) : BuildPopUpVideo(),
          ),
          onTap: () async {
            if (!widget.cours.open) {
              changeScreen(context, const PaiementsScreen());
            } else {
              printer(widget.cours.video_url);
              if (widget.videoController.files.value.path.isNotEmpty) {
                changeScreen(
                  context,
                  LectureCoursVideo(
                    video: widget.videoController.files.value,
                  ),
                );
                return;
              }
              await widget.videoController.downloadvideo().then((value) {
                setState(() {});
                if (!value) {
                  // loger('echec');
                  Notify.toastError("Erreur de téléchargement de la vidéo".tr);
                }
              });
            }
          },
        ),
      );
    });
  }

  PopupMenuButton<dynamic> BuildPopUpVideo() {
    return PopupMenuButton(
      itemBuilder: ((context) => [
            PopupMenuItem(
                child: Text('retélécharger'.tr),
                onTap: () async {
                  await widget.videoController.downloadvideo().then((value) {
                    setState(() {});
                    if (!value) {
                      Notify.toastError(
                          "Erreur de téléchargement de la vidéo".tr);
                    }
                  });
                }),
            PopupMenuItem(
                child: Text('Supprimer'.tr),
                onTap: () async {
                  await widget.videoController.supprimer();
                }),
          ]),
    );
  }

  BuildCourComponen copyWith({
    Cours? cours,
    VideoController? videoController,
  }) {
    return BuildCourComponen(
      cours: cours ?? this.widget.cours,
      videoController: videoController ?? this.widget.videoController,
    );
  }
}
