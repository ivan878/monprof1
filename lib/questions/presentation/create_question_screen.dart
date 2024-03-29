import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/questions/logique_metier/questions_controller.dart';
import 'package:image_picker/image_picker.dart';

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({super.key});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final formkey = GlobalKey<FormState>();
  File? _image;

  Future<void> photoSelect(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      builder: (QuestionController controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const SimpleText(text: 'Posez votre Question'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Center(
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text('Choisir la source de .'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        photoSelect(ImageSource.gallery);
                                      },
                                      child: Text('G A L E R I'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        photoSelect(ImageSource.camera);
                                        // Fermer le modal
                                      },
                                      child: Text('P H O T O'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(255, 233, 232, 232)),
                      child: Center(
                        child: _image == null
                            ? const Icon(
                                Icons.camera_alt,
                                color: Colors.grey,
                                size: 50,
                              )
                            : Image.file(_image!, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const SimpleText(
                    text: 'Titre (facultatif)',
                  ),
                  SpacerHeight(5),
                  TextFielApp(
                    controller: controller.controllerTitre,
                  ),
                  SpacerHeight(20),
                  const SimpleText(
                    text: 'Contenue de la question *',
                  ),
                  SpacerHeight(5),
                  TextFielApp(
                    controller: controller.controllerDesc,
                    validator: ValidationBuilder(
                            requiredMessage:
                                'contenue de la question Obligatoire')
                        .minLength(20, 'Question invalide')
                        .required()
                        .build(),
                    maxLines: 5,
                    minLine: 3,
                  ),
                  const Spacer(),
                  DefaultButton(
                    onPressed: () async {
                      if (formkey.currentState!.validate()) {
                        await controller.createQuestion().then((value) {
                          if (controller.createQuestionState.hasError) {
                            Notify.showFailure(
                                context,
                                controller.createQuestionState.errorModel
                                        ?.error ??
                                    'Impossible de valider la question');
                          } else {
                            controller.getQuestion();
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    wdiget: controller.createQuestionState.isLoading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: CircularProgressIndicator(
                                color: white,
                              ),
                            ),
                          )
                        : null,
                    text: 'Valider',
                  ),
                  SpacerHeight(20)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
