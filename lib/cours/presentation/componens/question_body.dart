import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/cours/logique_metier/cous_controller.dart';

class QuestionBody extends StatefulWidget {
  final CoursController controller;
  const QuestionBody({super.key, required this.controller});

  @override
  State<QuestionBody> createState() => _QuestionBodyState();
}

class _QuestionBodyState extends State<QuestionBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const SimpleText(text: 'Question'),
        icon: const Icon(Icons.add_circle_outline),
      ),
    );
  }
}
