import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';

class MesCoursPlaceholder extends StatelessWidget {
  const MesCoursPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SimpleText(
            text: 'Mes Cours', size: 18, weight: FontWeight.bold),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: const Center(child: Loading()),
    );
  }
}
