// ignore: file_names
import 'package:flutter/material.dart';

class Waitpage extends StatelessWidget {
  const Waitpage({Key? key}) : super(key: key);

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
            const SizedBox(
              height: 10,
            ),
            const Text("en cours de developpement ...",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
