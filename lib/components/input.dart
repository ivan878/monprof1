import 'package:flutter/material.dart';

Widget input(
    TextEditingController controller,
    String? Function(String?)? validator,
    bool voir,
    Widget icon,
    String hintext,
    TextInputType enterType,
    String errormessage) {
  return TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: enterType,
      obscureText: voir,
      decoration: InputDecoration(
          fillColor: Colors.blue.withOpacity(0.3),
          filled: true,
          hintText: hintext,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: IconButton(
            onPressed: () {},
            icon: CircleAvatar(
              child: icon,
            ),
          )));
}
