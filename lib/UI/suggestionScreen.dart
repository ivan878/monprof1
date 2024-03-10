import 'package:flutter/material.dart';

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
//liste
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          focusColor: Colors.white,
                          value: valeur,
                          //elevation: 5,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white),
                          iconEnabledColor: Colors.black,
                          items: <String>[
                            'Ajout',
                            'Fonctionnement',
                            'Erreur survenue',
                            'Problème d utilisation',
                            'Autres (A préciser) ',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          hint: const Text(
                            "choisir le sujet",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              valeur = value;
                            });
                          },
                        ),
                      ),

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
                            borderRadius: BorderRadius.circular(10),
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
                        margin: const EdgeInsets.all(15),
                        child: TextButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });

                              // var titre = valeur.toString();
                              // var desc = descController.text;
                              // print('la description est :$titre');
                              // var resul = suggestion(titre, desc);

                              Navigator.pop(context);
                              // Fluttertoast.showToast(
                              //   msg:
                              //       'Votre suggestion a été soumise avec succes',
                              //   toastLength: Toast.LENGTH_LONG,
                              //   backgroundColor:
                              //       Colors.blue.shade400.withOpacity(0.9),
                              //   timeInSecForIosWeb: 4,
                              // );

                              setState(() {
                                loading = false;
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            // primary: Colors.white,
                            backgroundColor: Colors.blue,
                            elevation: 3,
                          ),
                          child: const Text(
                            "Envoyer",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
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
