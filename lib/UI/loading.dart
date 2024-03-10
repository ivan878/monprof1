import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:monprof/corps/widgets/simple_text.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    // const MediaQuery.of(context).size.height * 0.5;
                    child: const SpinKitPulsingGrid(
                      color: Colors.blue,
                      size: 70.0,
                    )),
                const Text("Chargement ...",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.blue)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final void Function()? reload;
  final String errorMessage;
  const ErrorPage({Key? key, required this.errorMessage, this.reload})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 150, child: Image.asset('assets/mp2.png')),
              const SizedBox(height: 10),
              SimpleText(
                text: errorMessage,
                weight: FontWeight.w600,
                color: Colors.red,
                align: TextAlign.center,
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: reload,
                child: const Icon(Icons.refresh, size: 27),
              )
            ],
          ),
        ),
      ),
    );
  }
}
