import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

Future<dynamic> changeScreen(BuildContext context, Widget page) async {
  return await Navigator.push(
    context,
    PageTransition(
      child: page,
      type: PageTransitionType.topToBottom,
    ),
  );
}
