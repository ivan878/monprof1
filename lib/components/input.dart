import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';

Widget input(
  String? Function(String?)? validator,
  TextEditingController? controller,
  String? hinText,
  Widget? prefixIcon, {
  final Widget? suffixIcon,
  final bool? obscureTexte,
  final TextInputType? inputType,
  final BorderSide? side,
  final EdgeInsets? padding,
  final int? lenght,
  final int? maxLines,
  final int? minLine,
}) {
  return TextFormField(
    validator: validator,
    controller: controller,
    keyboardType: inputType,
    decoration: appInputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintText: hinText,
      side: side,
      padding: padding,
    ),
    // decoration: InputDecoration(
    //   border: const OutlineInputBorder(
    //     borderRadius: BorderRadius.all(Radius.circular(10)),
    //     borderSide: BorderSide(color: Color(0xFFB3B3B3), width: 0.3),
    //   ),
    //   prefixIcon: prefixIcon,
    //   // const Icon(Icons.lock),
    //   iconColor: Colors.white54,
    //   hintText: hinText,
    // ),
  );
}

//champs pour password
Widget inputPassword(
    String? Function(String?)? validator,
    TextEditingController? controller,
    bool obscure,
    String? hinText,
    Widget? prefixIcon,
    void Function()? onPressed) {
  return TextFormField(
      validator: validator,
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Color(0xFFB3B3B3), width: 0.3),
        ),
        prefixIcon: prefixIcon,
        iconColor: Colors.white54,
        hintText: hinText,
      ));
}

//champs pour numero de téléphone
Widget inputPhone(
    String? Function(String?)? validator,
    TextEditingController? controller,
    int? maxLength,
    String? hinText,
    Widget? prefixIcon) {
  return TextFormField(
      validator: validator,
      controller: controller,
      maxLength: maxLength,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFFB3B3B3), width: 0.3)),
        prefixIcon: prefixIcon,
        // const Icon(Icons.lock),
        iconColor: Colors.white54,
        hintText: hinText,
      ));
}

// Widget input(
//     TextEditingController controller,
//     String? Function(String?)? validator,
//     bool voir,
//     Widget icon,
//     String hintext,
//     TextInputType enterType,
//     String errormessage) {
//   return TextFormField(
//       validator: validator,
//       controller: controller,
//       keyboardType: enterType,
//       obscureText: voir,
//       decoration: InputDecoration(
//           fillColor: Colors.blue.withOpacity(0.3),
//           filled: true,
//           hintText: hintext,
//           border: OutlineInputBorder(
//             borderSide: BorderSide.none,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           prefixIcon: IconButton(
//             onPressed: () {},
//             icon: CircleAvatar(
//               child: icon,
//             ),
//           )));
// }
