import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(height: 300, child: Image.asset('assets/mp2.png')),
            const CircularProgressIndicator(),
            const SizedBox(
              height: 10,
            ),
            const Text("Chargement veuillez patienté s'il vous plait ...",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
