import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:google_fonts/google_fonts.dart';

Color primaryColor = Colors.lightBlue.shade500; //::HexColor('39C166');
Color secondaryColor = HexColor('faba7d');
Color darkColor = HexColor('333333');
Color darkColorSecond = HexColor('555555');
Color greyColors = HexColor('999999');
Color white = Colors.white;
Color red = Colors.red;
Color blackColor = Colors.black;
TextStyle textStyle = GoogleFonts.poppins();
Color grey300 = HexColor('f3f3f3'); // Colors.grey.shade300;
Color onGrey300 = HexColor("8e8e8e"); // Colors.grey.shade300;

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: primaryColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    onPrimary: white,
    onSecondary: white,
  ),
);
