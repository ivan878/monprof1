import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/theme.dart';

Widget rowCompte(Color color, String textvalue, IconData icon) {
  return Row(
    children: [
      Icon(
        icon,
        //Icons.real_estate_agent,
        color: Colors.blue,
      ),
      const SizedBox(
        width: 10,
      ),
      Text(
        textvalue,
        style: textStyle.copyWith(color: color),
      )
    ],
  );
}
