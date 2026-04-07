
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:flutter/material.dart';
// import 'package:monprof/corps/utils/navigation.dart';
// import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/cours/data/models/cours_model.dart';
import 'package:monprof/cours/logique_metier/cours_controller.dart';
import 'package:monprof/cours/logique_metier/video_reader_controller.dart';
import 'package:monprof/paiements/presentation/paiements_screen.dart';

class CoursBodyTest extends StatefulWidget {
  final CoursController controller;
  const CoursBodyTest({super.key, required this.controller});

  @override
  State<CoursBodyTest> createState() => _CoursBodyTestState();
}

class _CoursBodyTestState extends State<CoursBodyTest> {
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
                                  BuildCourComponenTest(cours: cours),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: PayForPlaceButton(),
      ),
      // FloatingActionButton.extended(
      //   extendedPadding: EdgeInsets.only(right: 75, left: 75),
      //   backgroundColor: primaryColor,
      //   onPressed: () {

      //   },
      //   label: SimpleText(text: "Payer une place"),
      // ),
    );
  }
}

class BuildCourComponenTest extends StatefulWidget {
  final Cours cours;

  const BuildCourComponenTest({super.key, required this.cours});

  @override
  State<BuildCourComponenTest> createState() => _BuildCourComponenTestState();
}

class _BuildCourComponenTestState extends State<BuildCourComponenTest> {
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
      builder: (controller) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Image.asset(
            "assets/cours.png",
            height: 45,
            width: 45,
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
        trailing: IconButton(
          onPressed: () {
            shappCoursDetails(context);
          },
          icon: Icon(
            Icons.info_outline,
            size: 30,
          ),
        ),
        onTap: () async {
          if (context.mounted) {
            shappCoursDetails(context);
          }
        },
      ),
    );
  }

  void shappCoursDetails(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        context: context,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.blue),
            ),
            insetPadding: EdgeInsets.all(10),
            child: CoursDetailDialog(
              cours: widget.cours,
            ),
          );
        });
  }
}

class CoursDetailDialog extends StatelessWidget {
  final Cours cours;
  const CoursDetailDialog({
    super.key,
    required this.cours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.blue,
                child: Center(
                  child: Icon(Icons.close),
                ),
              ),
            ),
          ),
          // SizedBox(height: 10),
          SimpleText(
            text: "Detail de la lecons",
            size: 20,
            weight: FontWeight.bold,
          ),
          SizedBox(height: 20),
          SimpleText(
            text: "Titre",
            size: 16,
            weight: FontWeight.bold,
          ),
          SizedBox(height: 10),
          SimpleText(text: cours.libelle),
          SizedBox(height: 20),
          SimpleText(
            text: "Description",
            size: 16,
            weight: FontWeight.bold,
          ),
          SizedBox(height: 10),

          SimpleText(text: cours.description),

          SizedBox(height: 20),
          SimpleText(
            text: "Date",
            size: 16,
            weight: FontWeight.bold,
          ),
          SizedBox(height: 10),
          SimpleText(
            text: DateFormat().format(
              DateTime.tryParse(cours.created_at) ?? DateTime.now(),
            ),
          ),
          SizedBox(height: 10),
          const Padding(
            padding: EdgeInsetsGeometry.only(left: 30, right: 30),
            child: Divider(),
          ),
          SizedBox(height: 10),
          PayForPlaceButton(pop: true),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class PayForPlaceButton extends StatelessWidget {
  final bool pop;
  const PayForPlaceButton({super.key, this.pop = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (pop) Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (route) => PaiementsScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SimpleText(
              text: "Payer la place",
              size: 16,
              weight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
