import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/theme.dart';

Widget rowCompte(
  Color color,
  String textvalue,
  IconData icon, {
  Color? iconColor,
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  MainAxisSize mainAxisSize = MainAxisSize.max,
}) {
  return Row(
    mainAxisAlignment: mainAxisAlignment,
    mainAxisSize: mainAxisSize,
    children: [
      Icon(
        icon,
        //Icons.real_estate_agent,
        color: iconColor ?? Colors.blue,
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
