import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/simple_text.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({Key? key, required this.phone}) : super(key: key);

  @override
  State<OtpScreen> createState() => OtpScreenState();
}

class OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController controllerOTP = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SimpleText(
          text: "Verification du Compte",
          size: 16,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SimpleText(
                text:
                    "Renseignez le code que vous avez reçu par SMS sur le numéro ${widget.phone}",
              ),
              const SizedBox(height: 40),
              OtpFieldApp(
                validator: ValidationBuilder(
                        requiredMessage: "Renseignez un numéro de téléphone")
                    .maxLength(4)
                    .minLength(4)
                    .required()
                    .build(),
                controller: controllerOTP,
              ),
              const Spacer(),
              DefaultButton(
                text: "Valider",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => OtpScreen(
                    //       phone: controllerPhone.text,
                    //     ),
                    //   ),
                    // );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
