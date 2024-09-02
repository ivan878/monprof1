import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/sugestion/sugestion_services.dart';

class Suggestion extends StatefulWidget {
  const Suggestion({super.key});

  @override
  State<Suggestion> createState() => _SuggestionState();
}

class _SuggestionState extends State<Suggestion> {
  var titreController = TextEditingController();
  var descController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  bool loading = false;
  String? valeur = ' ';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Remarques - Suggestions"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: descController,
                        minLines: 6,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Veuillez indiquer votre suggestion';
                          } else {
                            null;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.blue.withOpacity(0.2),
                          filled: true,
                          hintText: "Votre texte",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        onTap: null,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 50,
                        margin: const EdgeInsets.all(9),
                        child: TextButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() => loading = true);
                              try {
                                await SugestionServices()
                                    .sendSugeestion(descController.text);
                                Notify.toastSuccess(
                                    "Suggestion envoyé avec succès");
                                Navigator.pop(context);
                              } catch (e) {
                                Notify.toastError(
                                    "Erreur lors de l'envoi ${returnError(e)}");
                              } finally {
                                setState(() => loading = false);
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Envoyer",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
