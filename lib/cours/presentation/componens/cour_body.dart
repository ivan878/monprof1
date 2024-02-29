import 'package:get/get.dart';
import 'package:monprof/UI/loading.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/helper.dart';
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
                                videoController: VideoController(cours: cours),
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

class BuildCourComponen extends StatelessWidget {
  final Cours cours;
  final VideoController videoController;
  const BuildCourComponen(
      {super.key, required this.cours, required this.videoController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: videoController.isDownloaded.value
              ? const Icon(Icons.play_circle, color: Colors.white)
              : !videoController.loading.value
                  ? const Icon(Icons.download, color: Colors.white)
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: videoController.progrees.value,
                      ),
                    ),
        ),
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
                            onTap: () async {
                              await videoController
                                  .downloadvideo()
                                  .then((value) {
                                if (!value) {
                                  Notify.toastError(
                                      "Erreur de téléchargement de la vidéo");
                                }
                              });
                            }),
                        PopupMenuItem(
                            child: const Text('Supprimer'),
                            onTap: () async {
                              await videoController.supprimer();
                            }),
                      ])),
        ),
        onTap: () async {
          if (!cours.open) {
            changeScreen(context, const PaiementsScreen());
          } else {
            await videoController.downloadvideo().then((value) {
              if (!value) {
                loger('echec');
                // Notify.toastError("Erreur de téléchargement de la vidéo");
              }
            });
          }
        },
      ),
    );
  }
}
// import 'package:monprof/UI/loading.dart';
// import 'package:flutter/material.dart';
// import 'package:monprof/corps/utils/navigation.dart';
// import 'package:monprof/corps/widgets/simple_text.dart';
// import 'package:monprof/cours/data/models/cours_model.dart';
// import 'package:monprof/cours/logique_metier/cous_controller.dart';
// import 'package:monprof/paiements/presentation/paiements_screen.dart';
// import 'package:monprof/cours/logique_metier/video_reader_controller.dart';

// class CoursBody extends StatefulWidget {
//   final CoursController controller;
//   const CoursBody({super.key, required this.controller});

//   @override
//   State<CoursBody> createState() => _CoursBodyState();
// }

// class _CoursBodyState extends State<CoursBody> {
//   late CoursController controller;

//   @override
//   void initState() {
//     controller = widget.controller;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: controller.coursState.isLoading
//           ? const Loading()
//           : controller.coursState.hasError
//               ? ErrorPage(
//                   errorMessage: controller.coursState.errorModel?.error ??
//                       'Something went wrong',
//                   reload: () async {
//                     await controller.getCours();
//                   },
//                 )
//               : RefreshIndicator(
//                   onRefresh: () async {
//                     await controller.getCours();
//                   },
//                   child: ListView.builder(itemBuilder: ((context, index) {
//                     return Container(
//                       margin: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                             width: 1,
//                             style: BorderStyle.solid,
//                             color: Colors.blue),
//                       ),
//                       child: Column(
//                         children: [
//                           ListTile(
//                             leading: FutureBuilder<bool>(
//                                 future:
//                                     Future.delayed(const Duration(seconds: 10))
//                                         .then((value) => true),
//                                 builder: (context, snapshot) {
//                                   return CircleAvatar(
//                                     backgroundColor: Colors.blue,
//                                     child: (snapshot.hasData &&
//                                             snapshot.data! &&
//                                             (VideoController().loading &&
//                                                 VideoController()
//                                                         .downloadIndex !=
//                                                     index))
//                                         ? const Icon(Icons.play_circle,
//                                             color: Colors.white)
//                                         : (VideoController().loading &&
//                                                 VideoController()
//                                                         .downloadIndex !=
//                                                     index)
//                                             ? const Icon(Icons.download,
//                                                 color: Colors.white)
//                                             : Padding(
//                                                 padding:
//                                                     const EdgeInsets.all(8.0),
//                                                 child:
//                                                     CircularProgressIndicator(
//                                                   value: VideoController()
//                                                       .progrees,
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//                                   );
//                                 }),
//                             title: const SimpleText(
//                               text: 'titre',
//                               maxlines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             subtitle: const SimpleText(
//                               text: 'cours.',
//                               maxlines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             trailing: Container(
//                               child: !cours.open
//                                   ? const Icon(Icons.lock)
//                                   : PopupMenuButton(
//                                       itemBuilder: ((context) => [
//                                             PopupMenuItem(
//                                                 child:
//                                                     const Text('retélécharger'),
//                                                 onTap: () async {
//                                                   setState(() {
//                                                     VideoController()
//                                                         .downloadIndex = index;
//                                                   });
//                                                 }),
//                                             PopupMenuItem(
//                                                 child: const Text('Supprimer'),
//                                                 onTap: () async {}),
//                                           ])),
//                             ),
//                             onTap: () {
//                               if (cours.open) {
//                                 VideoController().downloadIndex = index;
//                               }

//                               setState(() {});

//                               !cours.open
//                                   ? changeScreen(
//                                       context, const PaiementsScreen())
//                                   : const CircularProgressIndicator();
//                               // : downloadvideo(url, namecours);
//                               setState(() {});
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   })),
//                   // child: ListView(
//                   //   physics: const AlwaysScrollableScrollPhysics(),
//                   //   children: [
//                   //     ...controller.coursState.data!.map(
//                   //       (cours) => Container(
//                   //         margin: const EdgeInsets.all(8),
//                   //         decoration: BoxDecoration(
//                   //           borderRadius: BorderRadius.circular(10),
//                   //           border: Border.all(
//                   //               width: 1,
//                   //               style: BorderStyle.solid,
//                   //               color: Colors.blue),
//                   //         ),
//                   //         child: Column(
//                   //           children: [
//                   //             BuildCourComponen(cours: cours),
//                   //           ],
//                   //         ),
//                   //       ),
//                   //     ),
//                   //   ],
//                   // ),
//                 ),
//     );
//   }
// }

// class BuildCourComponen extends StatelessWidget {
//   final Cours cours;
//   final int index;
//   const BuildCourComponen({super.key, required this.cours, required this.index});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: FutureBuilder<bool>(
//           future:
//               Future.delayed(const Duration(seconds: 3)).then((value) => true),
//           builder: (context, snapshot) {
//             return CircleAvatar(
//               backgroundColor: Colors.blue,
//               child: (snapshot.hasData && snapshot.data!)
//                   ? const Icon(Icons.play_circle, color: Colors.white)
//                   : (cours.open)
//                       ? const Icon(Icons.download, color: Colors.white)
//                       : const Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                           ),
//                         ),
//             );
//           }),
//       title: SimpleText(
//         text: cours.libelle,
//         maxlines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//       subtitle: SimpleText(
//         text: cours.description,
//         maxlines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//       trailing: Container(
//         child: !cours.open
//             ? const Icon(Icons.lock)
//             : PopupMenuButton(
//                 itemBuilder: ((context) => [
//                       PopupMenuItem(
//                           child: const Text('retélécharger'),
//                           onTap: () async {}),
//                       PopupMenuItem(
//                           child: const Text('Supprimer'), onTap: () async {}),
//                     ])),
//       ),
//       onTap: () {
//         if (!cours.open) {
//           changeScreen(context, const PaiementsScreen());
//         } else {
//           VideoController().downloadvideo(
//             cours.video_url,
//             cours.video_url,
//             context,
//           );
//         }
//       },
//     );
//   }
// }
