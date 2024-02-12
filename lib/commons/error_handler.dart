import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:monprof/corps/helper.dart';
import 'package:monprof/commons/error_model.dart';

// import 'package:firebase_core/firebase_core.dart';

///
///Le fichier que voicie contient les fonctions de gestion des erreur
///

// Gestion des errrue globale

ErrorModel returnError(error) {
  // error.printInfo();
  switch (error.runtimeType) {
    case SocketException:
      // printer('socket exception');
      return ErrorModel.fromMap({"error": 'Erreur de connection internet'.tr});
    case TimeoutException:
      // printer('socket exception');
      return ErrorModel.fromMap(
          {"error": 'Delet d\'attente dépaasé veillez réssayer'.tr});
    case PlatformException:
      printer(error);
      return ErrorModel.fromMap({"error": 'Erreur systeme inconnue'.tr});
    case DioException:
      // printer('error dio');
      return manageDioError(error as DioException);
    default:
      // printer('cant\'t get error type ${error.runtimeType}');
      return ErrorModel.fromMap({'error': error.toString()});
  }
}

// Gestion des erreur web service du packages Dio

ErrorModel manageDioError(DioException except) {
  final code = except.response?.statusCode;
  // printer(except.error.runtimeType);
  switch (code) {
    case 401:
      return ErrorModel.fromMap({
        "error": except.response?.statusMessage ?? 'AUthorisation refusée'.tr,
        'code': code
      });
    case 403:
      printer(except.response?.data ?? except.response?.statusMessage);
      return ErrorModel.fromMap({
        "error": except.response?.statusMessage ?? 'Données incorrectes'.tr,
        'code': code
      });
    case 500:
      printer(except.response?.data ?? except.response?.statusMessage);
      return ErrorModel.fromMap({
        "error":
            except.response?.statusMessage ?? 'Erreur de serveur interne'.tr,
        'code': code
      });
    case 404:
      return ErrorModel.fromMap(
          {'error': 'Connection au serveur impossible'.tr, 'code': code});
    case null:
      return returnCatchError(except.error);
    default:
      return ErrorModel.fromMap(
          {'code': code, 'error': "Quelque chose n'a pas fonctionné".tr});
  }
}

// Gestion des erreur inconnues .

ErrorModel returnCatchError(error) {
  switch (error.runtimeType) {
    case SocketException:
      printer('error SOCKET $error');
      return ErrorModel.fromMap({"error": 'Erreur de connection internet'.tr});

    case HttpException:
      printer('error HTTP');
      return ErrorModel.fromMap({"error": 'Erreur de connection internet'.tr});
    default:
      // printer('cant\'t get error type');
      return ErrorModel.fromMap(
          {'error': "Quelque chose n'a pas fonctionné".tr});
  }
}
