// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';

Widget boutton(context, String name, void Function() press, double largeur,
    double taille) {
  return Container(
    width: largeur,
    height: 50,
    margin: const EdgeInsets.all(15),
    child: TextButton(
      onPressed: (() => press()),
      child: Text(
        name,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: taille),
      ),
      style: TextButton.styleFrom(
        // primary: Colors.white,
        backgroundColor: Colors.blue,
        elevation: 3,
      ),
    ),
  );
}
