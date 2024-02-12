import 'package:flutter/material.dart';

class TextFielApp extends StatefulWidget {
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? hinText;
  final String? Function(String?)? validator;
  final bool? obscureTexte;
  final TextInputType? inputType;

  const TextFielApp({
    super.key,
    this.controller,
    this.obscureTexte,
    this.inputType,
    this.prefixIcon,
    this.suffixIcon,
    this.hinText,
    this.validator,
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
      decoration: InputDecoration(
        fillColor: Colors.blueAccent.shade100.withOpacity(0.3),
        filled: true,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        hintText: widget.hinText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
