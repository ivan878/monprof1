import 'dart:developer';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

loger(Object object) {
  if (kDebugMode) {
    log(object.toString());
  }
}

printer(Object object, {String type = 'i'}) {
  if (kDebugMode) {
    switch (type) {
      case 'e':
        logger.e('Error', error: object.toString());
        break;
      case 's':
        logger.d(object.toString());
      default:
        logger.i(object.toString());
    }
  }
}

var logger = Logger(
  printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: false // Should each log print contain a timestamp
      ),
);
