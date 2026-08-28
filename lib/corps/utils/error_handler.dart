import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/error_model.dart';

ErrorModel returnError(error) {
  if (error is SocketException) {
    return ErrorModel.fromMap({"error": 'Erreur de connection internet'});
  }
  if (error is TimeoutException) {
    return ErrorModel.fromMap(
        {"error": 'Délai d\'attente dépassé, veuillez réessayer'});
  }
  if (error is PlatformException) {
    printer(error);
    return ErrorModel.fromMap({"error": 'Erreur système inconnue'});
  }
  if (error is CustomException) {
    return ErrorModel(error: error.message, code: error.code);
  }
  if (error is DioException) return manageDioError(error);

  return ErrorModel.fromMap({'error': error.toString()});
}

ErrorModel manageDioError(DioException except) {
  final code = except.response?.statusCode;

  if (except.error is CustomException) {
    final customException = except.error as CustomException;
    return ErrorModel(
      error: customException.message,
      code: code ?? customException.code,
    );
  }
  switch (code) {
    case 401:
      return ErrorModel.fromMap(
          {"error": 'Autorisation refusée', 'code': code});
    case 403:
      printer(except.response?.data['error'] ??
          except.response?.data ??
          except.response?.statusMessage);
      return ErrorModel.fromMap({
        "error": except.response?.statusMessage ?? 'Données incorrectes',
        'code': code
      });
    case 500:
      printer(except.response?.data['error'] ??
          except.response?.data ??
          except.response?.statusMessage);
      return ErrorModel.fromMap({
        "error": except.response?.data['error'] ??
            except.response?.data ??
            except.response?.statusMessage ??
            'Erreur de serveur interne',
        'code': code
      });
    case 404:
      return ErrorModel.fromMap({
        'error':
            except.response?.data['error'] ?? 'Connexion au serveur impossible',
        'code': code
      });
    case null:
      return returnCatchError(except.error);
    default:
      return ErrorModel.fromMap({
        'code': code,
        'error':
            except.response?.data['error'] ?? "Quelque chose n'a pas fonctionné"
      });
  }
}

ErrorModel returnCatchError(error) {
  if (error is SocketException) {
    printer('error SOCKET $error');
    return ErrorModel.fromMap({"error": 'Erreur de connection internet'});
  }
  if (error is HttpException) {
    printer('error HTTP');
    return ErrorModel.fromMap({"error": 'Erreur de connection internet'});
  }

  return ErrorModel.fromMap({'error': "Quelque chose n'a pas fonctionné"});
}

class CustomException implements Exception {
  final String message;
  final int? code;
  CustomException({
    required this.message,
    this.code,
  });
}
