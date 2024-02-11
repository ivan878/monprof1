import 'package:flutter/material.dart';

Widget input2(
    TextEditingController controller,
    String? Function(String?)? validator,
    String hintext,
    String errormessage,
    String s) {
  return TextFormField(
    validator: validator,
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      prefixIcon: const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '+237',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      fillColor: Colors.blue.withOpacity(0.3),
      filled: true,
      hintText: hintext,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    onTap: null,
  );
}
