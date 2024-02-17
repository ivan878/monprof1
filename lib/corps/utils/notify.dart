import 'package:oktoast/oktoast.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/corps/widgets/simple_text.dart';

class Notify {
  static double defaultTextSize = 14;

  static void toastSuccess(
    String msg, {
    VoidCallback? onDismiss,
    int seconds = 5,
  }) {
    showToast(msg,
        duration: Duration(seconds: seconds),
        position: ToastPosition.bottom,
        backgroundColor: Colors.greenAccent.withOpacity(0.8),
        radius: 13.0,
        textPadding: const EdgeInsets.all(8.0),
        textStyle: TextStyle(fontSize: defaultTextSize, color: Colors.black),
        onDismiss: onDismiss);
  }

  static void toast(String msg,
      {VoidCallback? onDismiss,
      int seconds = 5,
      double? fontSize,
      double? textPadding}) {
    showToast(msg,
        duration: Duration(seconds: seconds),
        position: ToastPosition.bottom,
        backgroundColor: Colors.white.withOpacity(0.8),
        radius: 13.0,
        textPadding: EdgeInsets.all(textPadding ?? 8.0),
        textStyle: TextStyle(
            fontSize: fontSize ?? defaultTextSize, color: Colors.black),
        onDismiss: onDismiss);
  }

  static void toastError(String msg,
      {VoidCallback? onDismiss,
      int seconds = 5,
      double? fontSize,
      double? textPadding}) {
    showToast(msg.contains('DioException') ? "Erreur du serveur inconnue" : msg,
        duration: Duration(seconds: seconds),
        position: ToastPosition.bottom,
        backgroundColor: Colors.yellowAccent.withOpacity(0.8),
        radius: 13.0,
        textPadding: EdgeInsets.all(textPadding ?? 8.0),
        textStyle: TextStyle(
            fontSize: fontSize ?? defaultTextSize, color: Colors.black),
        onDismiss: onDismiss);
  }

  static void toastDanger(String msg,
      {VoidCallback? onDismiss,
      int seconds = 5,
      double? fontSize,
      double? textPadding}) {
    showToast(msg,
        duration: Duration(seconds: seconds),
        position: ToastPosition.bottom,
        backgroundColor: Colors.red.withOpacity(1),
        radius: 13.0,
        textPadding: EdgeInsets.all(textPadding ?? 8.0),
        textStyle: TextStyle(
            fontSize: fontSize ?? defaultTextSize, color: Colors.white),
        onDismiss: onDismiss);
  }

  static void showProcessing(BuildContext context, String msg,
      {VoidCallback? onDismiss,
      Color? backgroundColor,
      double? padding,
      double? strokeWidth}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          padding: EdgeInsets.all(padding ?? 10),
          // dismissDirection: DismissDirection.up,
          backgroundColor: backgroundColor ?? primaryColor,
          content: Row(
            children: [
              Expanded(child: Text(msg)),
              CircularProgressIndicator(strokeWidth: strokeWidth ?? 2),
            ],
          ),
        ),
      );
  }

  static void showFailure(BuildContext context, String msg,
      {VoidCallback? onDismiss}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(child: Text(msg)),
              Icon(
                Icons.error,
                color: white,
              )
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
  }

  static void showSuccess(BuildContext context, String msg,
      {VoidCallback? onDismiss}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: SimpleText(
                  text: msg,
                  color: Colors.white,
                  weight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.check)
            ],
          ),
          backgroundColor: Colors.green[400],
        ),
      );
  }

  static void show(BuildContext context, String msg,
      {VoidCallback? onDismiss}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                  child: SimpleText(
                text: msg,
                size: 14,
                weight: FontWeight.w600,
              )),
              const Icon(
                Icons.info_outline,
                color: Colors.black,
              )
            ],
          ),
          backgroundColor: Colors.white,
        ),
      );
  }
}
