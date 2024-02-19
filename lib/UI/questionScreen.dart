import 'package:flutter/material.dart';

class Question extends StatefulWidget {
  const Question({super.key});

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  var titreController = TextEditingController();
  var descController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forum"),
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
                      const Text(
                        "Entrez votre question ",
                        style: TextStyle(fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: titreController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Veuillez entrez le titre';
                          } else {
                            null;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.blue.withOpacity(0.2),
                          filled: true,
                          hintText: "titre",
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
                      TextFormField(
                        controller: descController,
                        minLines: 6,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Veuillez entrez la description';
                          } else {
                            null;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.blue.withOpacity(0.2),
                          filled: true,
                          hintText: "description",
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
                            // if (formKey.currentState!.validate()) {
                            //   setState(() {
                            //     loading = true;
                            //   });

                            //   String title = titreController.text;
                            //   String desc = descController.text;
                            //   var result = await ajoutsujet(desc, title);
                            //   var recupliste =
                            //       await recuplistesujets(desc, title);

                            //   setState(() {
                            //     loading = false;
                            //   });

                            Navigator.of(context).pop();
                            // Fluttertoast.showToast(
                            //   msg: 'Votre question a été soumise avec succes',
                            //   toastLength: Toast.LENGTH_LONG,
                            //   backgroundColor:
                            //       Colors.blue.shade400.withOpacity(0.9),
                            //   timeInSecForIosWeb: 4,
                            // );
                            // var code = codeController.text;
                            // String? status = await activationcompte(code);
                            // print(status);

                            // if (status.toString() == '2') {
                            //   Fluttertoast.showToast(
                            //     msg: "Ativation reussi",
                            //     timeInSecForIosWeb: 3,
                            //   );
                            //   Navigator.pop(context);
                            // } else if (status.toString() == '1') {
                            //   Fluttertoast.showToast(
                            //     msg: "CODE Déja Utilisé",
                            //     timeInSecForIosWeb: 5,
                            //   );
                            // } else {
                            //   Fluttertoast.showToast(
                            //     msg: "Code invalide",
                            //     timeInSecForIosWeb: 3,
                            //   );
                            // }
                          },
                          style: TextButton.styleFrom(
                            // primary: Colors.white,
                            backgroundColor: Colors.blue,
                            elevation: 3,
                          ),
                          child: const Text(
                            "envoyer",
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
