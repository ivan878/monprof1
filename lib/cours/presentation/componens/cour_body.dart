import 'dart:io';

import 'package:get/get.dart';
import 'package:monprof/UI/lecteurvideo_screen.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/cours/data/models/cours_model.dart';
import 'package:monprof/cours/logique_metier/cours_controller.dart';
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
                                  // if (cours.open || Platform.isAndroid)
                                    BuildCourComponen(
                                      cours: cours
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

  const BuildCourComponen({super.key, required this.cours});

  @override
  State<BuildCourComponen> createState() => _BuildCourComponenState();
}

class _BuildCourComponenState extends State<BuildCourComponen> {
  late VideoController videoController;
  @override
  initState() {
    videoController = Get.put(
      VideoController(cours: widget.cours),
      tag: widget.cours.id.toString(),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoController>(
      tag: widget.cours.id.toString(),
      init: videoController,
      initState: (state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          videoController.existCour();
        });
      },
      builder: (controller) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: controller.isDownloaded
              ? const Icon(Icons.play_circle, color: Colors.white)
              : !controller.loading
                  ? const Icon(Icons.download, color: Colors.white)
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: controller.progrees,
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
          child: !widget.cours.open
              ? const Icon(Icons.lock)
              : buildPopUpVideo(controller),

          // child: buildPopUpVideo(controller),
        ),
        onTap: () async {
          if (!widget.cours.open) {
            changeScreen(context, const PaiementsScreen());
          } else {
          printer(widget.cours.video_url);
          if (controller.isDownloaded) {
            final File cryptedFile = controller.files;
            final decryptedFile =
                await controller.getFileDecrypted(cryptedFile);
            if (context.mounted) {
              changeScreen(
                context,
                LectureCoursVideo(
                  video: decryptedFile,
                ),
              );
            }
            return;
          }
          await controller.downloadvideo();
          }
        },
      ),
    );
  }

  PopupMenuButton<dynamic> buildPopUpVideo(VideoController controller) {
    return PopupMenuButton(
      itemBuilder: ((context) => [
            PopupMenuItem(
                child: Text('retélécharger'.tr),
                onTap: () async {
                  await controller.downloadvideo().then((value) {
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
                  await controller.supprimer();
                }),
          ]),
    );
  }
}
