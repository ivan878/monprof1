import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/corps/widgets/simple_text.dart';

class DefaultButton extends StatelessWidget {
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final void Function(bool)? onHover;
  final void Function(bool)? onFocusChange;
  final double? radius;
  final double? height;
  final double? width;
  final double? fontSize;
  final double? elevation;
  final String? text;
  final Widget? wdiget;
  final Color? color;
  final Color? backgroundColor;
  final BorderSide? borderSide;
  final FocusNode? focusNode;
  final bool autofocus;
  final FontWeight? fontWeight;
  const DefaultButton(
      {super.key,
      this.autofocus = false,
      this.backgroundColor,
      this.borderSide,
      this.color,
      this.elevation,
      this.focusNode,
      this.fontSize,
      this.height,
      this.onFocusChange,
      this.onHover,
      this.onLongPress,
      this.onPressed,
      this.radius,
      this.text,
      this.wdiget,
      this.fontWeight,
      this.width});

  @override
  Widget build(BuildContext context) {
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
              size: fontSize ?? 17,
              color: color ?? white,
              align: TextAlign.center,
              weight: fontWeight ?? FontWeight.bold,
            ),
      ),
    );
  }
}
