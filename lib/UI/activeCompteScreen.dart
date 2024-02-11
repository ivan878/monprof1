import 'package:flutter/material.dart';

class ActiveCompte extends StatefulWidget {
  const ActiveCompte({super.key});

  @override
  State<ActiveCompte> createState() => _ActiveCompteState();
}

class _ActiveCompteState extends State<ActiveCompte> {
  var codeController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activer un abonnement"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: formKey,
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "S'il vous plait, veuillez entrer le code d'activation"
                      "reçu par SMS ou par mail.",
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: codeController,
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Veuillez entrer un code d'activation";
                        } else {
                          null;
                        }
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.blue.withOpacity(0.2),
                        filled: true,
                        hintText: "Code activation",
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

                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             const TransitionPage()));
                          } else {}

                          setState(() {
                            loading = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.blue,
                          elevation: 3,
                        ),
                        child: const Text(
                          "Activer",
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
    );
  }
}
