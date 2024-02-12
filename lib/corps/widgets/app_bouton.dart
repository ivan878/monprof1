import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/corps/widgets/simple_text.dart';

// ignore: non_constant_identifier_names
Widget DefaultButton({
  Key? key,
  required void Function()? onPressed,
  void Function()? onLongPress,
  void Function(bool)? onHover,
  void Function(bool)? onFocusChange,
  double? radius,
  double? height,
  double? width,
  double? fontSize,
  double? elevation,
  String? text,
  Widget? wdiget,
  Color? color,
  Color? backgroundColor,
  BorderSide? borderSide,
  FocusNode? focusNode,
  bool autofocus = false,
}) {
  return SizedBox(
    height: height ?? 55,
    width: width ?? double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: elevation,
        backgroundColor: backgroundColor ?? primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 10),
          side: borderSide ?? BorderSide.none,
        ),
      ),
      onPressed: onPressed,
      child: wdiget ??
          SimpleText(
            text: text!,
            size: fontSize,
            color: color ?? white,
            align: TextAlign.center,
          ),
    ),
  );
}
