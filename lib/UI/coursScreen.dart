import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:monprof/UI/paiementScreen.dart';
import 'package:monprof/UI/questionScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:monprof/UI/lecteurvideoScreen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
// ignore_for_file: sort_child_properties_last

class Cours extends StatefulWidget {
  final String idmat;
  final String idtrim;
  final String libmat;
  final String libtrim;

  const Cours({
    Key? key,
    required this.idmat,
    required this.libmat,
    required this.libtrim,
    required this.idtrim,
  }) : super(key: key);

  @override
  _CoursState createState() => _CoursState();
}

class _CoursState extends State<Cours> {
  // ignore: prefer_typing_uninitialized_variables
  var tabController;
  int indextab = 0;
  final title = TextEditingController();
  final desc = TextEditingController();
  List<Map<String, dynamic>> listmessages = [];

  int _currentIndex = 0;
  var listcourvide = true;
  String statut = '1';

  String prixMat = '';
  var downloadIndex = -1;
  var key = GlobalKey<FormState>();
  final Dio dio = Dio();
  bool expan = false;

  void change(String prix) {
    Navigator.push(
        context,
        PageTransition(
            alignment: Alignment.bottomCenter,
            type: PageTransitionType.rightToLeft,
            child: const Paiement(),
            fullscreenDialog: true));
  }

  //fonction pour sauvegarder les video et lire depuis le dossier de l'app
  bool loading = false;
  double progress = 0;
  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  //fonction de suppression de vidéo mal télécharger ou avec erreur de lecture
  Future<bool> supprimer(String url, String fileName) async {
    Directory? dir = await getExternalStorageDirectory();
    //final targetFile = Directory("${dir.path}/books/$fileName.pdf");
    File targetFile = File(dir!.path + "/$fileName");
    if (targetFile.existsSync()) {
      targetFile.deleteSync(recursive: true);
      print('fichier supprimer avec succes:');
      return true;
    } else {
      return false;
    }
  }

  Directory? directory;
  Future<bool> saveVideo(String url, String fileName) async {
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();

          // print(directory);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }

      if (!await directory!.exists()) {
        await directory!.create(recursive: true);
      }
      if (await directory!.exists()) {
        File saveFile = File(directory!.path + "/$fileName");
        if (await saveFile.exists()) {
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            PageTransition(
              alignment: Alignment.bottomCenter,
              type: PageTransitionType.rightToLeft,
              child: LectureCoursVideo(video: saveFile),
            ),
          );
          return false;
        } else {
          await dio.download(url, saveFile.path,
              onReceiveProgress: (value1, value2) {
            setState(() {
              progress = value1 / value2;
            });
            // print(progress);
          });
        }

        if (Platform.isIOS) {
          return false;
        }
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  downloadvideo(String url, String name) async {
    bool downloaded = await saveVideo(url, name);
    if (downloaded) {
      print("vidéo télécharger");
      // Fluttertoast.showToast(
      //   msg: 'téléchargement terminé avec succes',
      //   toastLength: Toast.LENGTH_LONG,
      //   timeInSecForIosWeb: 4,
      //   backgroundColor: Colors.blue.shade400.withOpacity(0.9),
      // );
    } else {
      print("echec de téléchargement");
    }
    setState(() {
      loading = false;
      progress = 0;
      downloadIndex = -1;
    });
  }

  @override
  void initState() {
    super.initState();
    // listcourBuilder();
    // recuplistesujets(desc.text, title.text);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.libmat),
          bottom: TabBar(
            onTap: (value) {
              setState(() {
                indextab = value;
              });
              print(indextab);
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
          controller: tabController,
          children: [
            listcourvide
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    margin: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        setState(() {});
                      },
                      child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Container(
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
                                  // ListTile(
                                  //   leading: FutureBuilder<bool>(
                                  //       // future: 10,
                                  //       builder: (context, snapshot) {
                                  //     return CircleAvatar(
                                  //       backgroundColor: Colors.blue,
                                  //       child: (snapshot.hasData &&
                                  //               snapshot.data! &&
                                  //               (!loading &&
                                  //                   downloadIndex != index))
                                  //           ? const Icon(Icons.play_circle,
                                  //               color: Colors.white)
                                  //           : (!loading &&
                                  //                   downloadIndex != index)
                                  //               ? const Icon(Icons.download,
                                  //                   color: Colors.white)
                                  //               : Padding(
                                  //                   padding:
                                  //                       const EdgeInsets.all(
                                  //                           8.0),
                                  //                   child:
                                  //                       CircularProgressIndicator(
                                  //                     value: progress,
                                  //                     color: Colors.white,
                                  //                   ),
                                  //                 ),
                                  //     );
                                  //   }),
                                  //   title: const Text('libelle'),
                                  //   subtitle: const Text('description'),
                                  //   trailing: Container(
                                  //     child: statut == '1'
                                  //         ? const Icon(Icons.lock)
                                  //         : PopupMenuButton(
                                  //             itemBuilder: ((context) => [
                                  //                   PopupMenuItem(
                                  //                       child: const Text(
                                  //                           'retélécharger'),
                                  //                       onTap: () async {
                                  //                         setState(() {
                                  //                           downloadIndex =
                                  //                               index;
                                  //                         });

                                  //                         // var result =
                                  //                         //     await supprimer(
                                  //                         //         url,
                                  //                         //         namecours);
                                  //                         // if (result) {
                                  //                         //   downloadvideo(
                                  //                         //       url, namecours);
                                  //                         // } else if (!result) {
                                  //                         //   downloadvideo(
                                  //                         //       url, namecours);
                                  //                         // } else {
                                  //                         //   Fluttertoast
                                  //                         //       .showToast(
                                  //                         //     msg:
                                  //                         //         'une erreur est survenue',
                                  //                         //     toastLength: Toast
                                  //                         //         .LENGTH_LONG,
                                  //                         //     backgroundColor:
                                  //                         //         Colors.red
                                  //                         //             .shade400
                                  //                         //             .withOpacity(
                                  //                         //                 0.9),
                                  //                         //     timeInSecForIosWeb:
                                  //                         //         4,
                                  //                         //  );
                                  //                         // }
                                  //                         // setState(() {
                                  //                         //   loading = false;
                                  //                         // });
                                  //                       }),
                                  //                   PopupMenuItem(
                                  //                       child: const Text(
                                  //                           'Supprimer'),
                                  //                       onTap: () async {
                                  //                         // var result =
                                  //                         //     await supprimer(
                                  //                         //         url,
                                  //                         //         namecours);
                                  //                         // if (result) {
                                  //                         //   Fluttertoast
                                  //                         //       .showToast(
                                  //                         //     msg:
                                  //                         //         'vidéo supprimer avec succes',
                                  //                         //     toastLength: Toast
                                  //                         //         .LENGTH_LONG,
                                  //                         //     backgroundColor:
                                  //                         //         Colors.blue
                                  //                         //             .shade400
                                  //                         //             .withOpacity(
                                  //                         //                 0.9),
                                  //                         //     timeInSecForIosWeb:
                                  //                         //         4,
                                  //                         //   );
                                  //                       }
                                  //                       // Fluttertoast
                                  //                       //     .showToast(
                                  //                       //   msg:
                                  //                       //       "la video n'existe pas ",
                                  //                       //   toastLength: Toast
                                  //                       //       .LENGTH_LONG,
                                  //                       //   backgroundColor:
                                  //                       //       const Color.fromARGB(
                                  //                       //               255,
                                  //                       //               248,
                                  //                       //               108,
                                  //                       //               120)
                                  //                       //           .withOpacity(
                                  //                       //               0.9),
                                  //                       //   timeInSecForIosWeb:
                                  //                       //       4,
                                  //                       // );

                                  //                       // }
                                  //                       ),
                                  //                 ])),
                                  //   ),
                                  //   onTap: () {
                                  //     if (statut != '1') {
                                  //       downloadIndex = index;
                                  //     }

                                  //     setState(() {});

                                  //     statut == '1'
                                  //         ? Navigator.push(
                                  //             context,
                                  //             PageTransition(
                                  //               alignment:
                                  //                   Alignment.bottomCenter,
                                  //               curve: Curves.easeInOut,
                                  //               type: PageTransitionType
                                  //                   .leftToRight,
                                  //               child: const Paiement(),
                                  //             ))
                                  //         : const CircularProgressIndicator();
                                  //     // : downloadvideo(url, namecours);
                                  //     setState(() {});
                                  //   },
                                  // ),
                                ],
                              ),
                            );
                          }),
                    ),
                  ),
            //partie forum
            listcourvide
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: forumcard(
                            listmessages,
                          ),
                        ),
                        Positioned(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // var etat = listmessages[0]["etat"];
                              // String prix = listmessages[0]["montant"];
                              // for (var x = 0; x <= listemessage.length; x++) {}
                              // print('compte actif :' + etat);
                              // prixMat
                              // if (etat == "1") {
                              // Navigator.push(
                              //   context,
                              //   PageTransition(
                              //       alignment: Alignment.bottomCenter,
                              //       type: PageTransitionType.bottomToTop,
                              //       child: Question(
                              //   )),
                              // );
                              //   } else {
                              //     change(prix);
                              //   }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 35,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(23),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Question'),
                          ),
                          bottom: 20,
                          right: 20,
                        )
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  //fonction de la card;

  Widget forumcard(List<Map<String, dynamic>> message) {
    String img = 'assets/prof.png';
    return ExpansionPanelList(
      animationDuration: const Duration(milliseconds: 1000),
      expandedHeaderPadding: EdgeInsets.only(bottom: 0.0),
      elevation: 2,
      children: message.map((chat) {
        String question = chat['description'];
        String titre = chat["libelle"];
        String reponse = chat['reponse'] ?? "Problème non résolut";
        String imagepj = chat['pieceJointe'] ?? "pas de piece jointe";

        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            var expan = false;
            return Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: expan
                        ? const Icon(Icons.check_circle,
                            color: Colors.greenAccent)
                        : const Icon(Icons.access_time_filled,
                            color: Colors.grey),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Text(
                      titre,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Colors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          body: Container(
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    question,
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                        letterSpacing: 0.3,
                        height: 1.3),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Divider(
                    height: 1,
                    thickness: 2,
                    color: Colors.blue,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipOval(
                        child: CircleAvatar(child: Image.asset(img)),
                      ),
                      Visibility(
                        visible: true,
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: TextButton(
                              child: const Text('voir la réponse'),
                              onPressed: () {},
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Visibility(
                    visible: false,
                    child: Text(
                      reponse,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          letterSpacing: 0.3,
                          height: 1.3),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Visibility(
                    visible: false,
                    child: Visibility(
                      visible: false,
                      child: Material(
                        elevation: 2,
                        child: InkWell(
                          onTap: (() {}),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue)),
                            height: 50,
                            child: Image.network(
                              imagepj,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isExpanded: chat["flex"],
        );
      }).toList(),
      expansionCallback: (int item, bool status) {
        // if (stringTobool(message[item]['resolu'])) {
        setState(() {
          message[item]['flex'] = !status;
        });
        // }
      },
    );
  }
}
