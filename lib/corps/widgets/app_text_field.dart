import 'package:flutter/material.dart';

class TextFielApp extends StatefulWidget {
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? hinText;
  final String? Function(String?)? validator;
  final bool? obscureTexte;
  final TextInputType? inputType;
  final BorderSide? side;
  final EdgeInsets? padding;
  final int? lenght;
  final int? maxLines;
  final int? minLine;

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
      obscureText: widget.obscureTexte ?? false,
      validator: widget.validator,
      maxLength: widget.lenght,
      minLines: widget.minLine,
      maxLines: widget.maxLines,
      decoration: appInputDecoration(
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        hintText: widget.hinText,
        side: widget.side,
        padding: widget.padding,
      ),
    );
  }
}

InputDecoration appInputDecoration(
    {Widget? prefixIcon,
    Widget? suffixIcon,
    String? hintText,
    EdgeInsets? padding,
    BorderSide? side}) {
  return InputDecoration(
    contentPadding:
        padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    fillColor: Colors.blue.withOpacity(0.3),
    filled: true,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    hintText: hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: side ?? BorderSide.none,
    ),
  );
}
