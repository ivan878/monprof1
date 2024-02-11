import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final numeroController = TextEditingController();
  final nomController = TextEditingController();
  final passwordController = TextEditingController();

  bool isloading = false;
  final formKey = GlobalKey<FormState>();

  String? valeurClasse;

  bool visible = false;
  bool visibleconfir = false;
  String requestError = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            'Connexion',
            style: TextStyle(
                color: Colors.blue, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 200,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(20),
                    child: Image.asset('assets/book.png')),
                TextFormField(
                  validator: (val) {
                    if (val!.isEmpty || val.length < 9) {
                      return 'entre un numero de téléphone valide';
                    } else {
                      return null;
                    }
                  },
                  controller: numeroController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      fillColor: Colors.blue.withOpacity(0.3),
                      filled: true,
                      hintText: "Identifiant",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: IconButton(
                        onPressed: () {},
                        icon: const CircleAvatar(child: Icon(Icons.phone)),
                      )),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  validator: (val) {
                    if (val!.length < 6) {
                      return 'Le mots de passe doit avoir au moins 6 caracteres ';
                    } else {
                      return null;
                    }
                  },
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: visibleconfir,
                  decoration: InputDecoration(
                    fillColor: Colors.blue.withOpacity(0.3),
                    filled: true,
                    hintText: "entrez le mots de passe",
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          visibleconfir = !visibleconfir;
                        });
                      },
                      icon: visibleconfir
                          ? const CircleAvatar(child: Icon(Icons.lock))
                          : const CircleAvatar(child: Icon(Icons.lock_open)),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          visibleconfir = !visibleconfir;
                        });
                      },
                      icon: !visibleconfir
                          ? const CircleAvatar(child: Icon(Icons.visibility))
                          : const CircleAvatar(
                              child: Icon(Icons.visibility_off)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 50,
                  margin: const EdgeInsets.all(15),
                  child: TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Navigator.push(
                        //   context,
                        //   PageTransition(
                        //       alignment: Alignment.bottomCenter,
                        //       type: PageTransitionType.rightToLeft,
                        //       child: const TransitionPage(),
                        //       childCurrent: const Login()),
                        // );
                      } else {
                        return null;
                      }
                    },
                    child: const Text(
                      "CONNEXION",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.blue,
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const ResetPassword()),
                    // );
                  },
                  child: const Text("Mots de passe oublier? 😥",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   PageTransition(
                    //       alignment: Alignment.bottomCenter,
                    //       type: PageTransitionType.rightToLeft,
                    //       child: const Inscription(),
                    //       childCurrent: const Login()),
                    // );
                  },
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Pas de compte ?",
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 17),
                        ),
                        Text("Inscrivez vous",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
