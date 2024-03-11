import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFielApp extends StatefulWidget {
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? hinText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool? obscureTexte;
  final TextInputType? inputType;
  final BorderSide? side;
  final EdgeInsets? padding;
  final int? lenght;
  final int? maxLines;
  final int? minLine;
  final bool? filled;
  final Color? fillColor;

  final List<TextInputFormatter>? inputFormatters;

  const TextFielApp({
    super.key,
    this.controller,
    this.obscureTexte,
    this.inputType,
    this.prefixIcon,
    this.suffixIcon,
    this.hinText,
    this.validator,
    this.lenght,
    this.side,
    this.padding,
    this.maxLines,
    this.minLine,
    this.inputFormatters,
    this.fillColor,
    this.onChanged,
    this.filled,
  });

  @override
  State<TextFielApp> createState() => _TextFielAppState();
}

class _TextFielAppState extends State<TextFielApp> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.inputType,
      onChanged: widget.onChanged,
      obscureText: false,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.lenght,
      minLines: widget.minLine,
      maxLines: widget.maxLines,
      decoration: appInputDecoration(
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        hintText: widget.hinText,
        side: widget.side,
        fillColor: widget.fillColor,
        filled: widget.filled,
        padding: widget.padding,
      ),
    );
  }
}

InputDecoration appInputDecoration(
    {Widget? prefixIcon,
    Widget? suffixIcon,
    String? hintText,
    bool? filled,
    Color? fillColor,
    EdgeInsets? padding,
    BorderSide? side}) {
  return InputDecoration(
    contentPadding:
        padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    hintText: hintText,
    filled: filled,
    fillColor: fillColor,
    iconColor: Colors.white54,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color(0xFFB3B3B3), width: 0.3),
    ),
  );
}
