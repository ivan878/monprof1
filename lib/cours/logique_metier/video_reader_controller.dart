import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/api_service.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:path_provider/path_provider.dart';
import 'package:monprof/UI/lecteurvideoScreen.dart';
import 'package:monprof/corps/utils/navigation.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoController extends GetxController {
  //Request permission
  Future<bool> requestPermission(Permission permission) async {
    var result = await permission.request();
    if ( result.isGranted) {
      return true;
    // } else {
    //   // var result = await permission.request();
    //   if (result == PermissionStatus.granted) {
    //     return true;
    //   }
    }
    return false;
  }

  //fonction de suppression de vidéo mal télécharger ou avec erreur de lecture
  Future<bool> supprimer(String url, String fileName) async {
    Directory? dir = await getExternalStorageDirectory();
    //final targetFile = Directory("${dir.path}/books/$fileName.pdf");
    File targetFile = File("${dir!.path}/$fileName");
    if (targetFile.existsSync()) {
      targetFile.deleteSync(recursive: true);
      printer('fichier supprimer avec succes:');
      return true;
    } else {
      return false;
    }
  }

  Directory? directory;

  Future<bool> saveVideo(
      String url, String fileName, BuildContext context) async {
    try {
      directory = await getExternalStorageDirectory();
      // if (Platform.isAndroid) {
      //   if (await requestPermission(Permission.storage)) {
      //     directory = await getExternalStorageDirectory();

      //     // print(directory);
      //   } else {
      //     return false;
      //   }
      // } else {
      //   if (await requestPermission(Permission.photos)) {
      //     directory = await getTemporaryDirectory();
      //   } else {
      //     return false;
      //   }
      // }

      if (!await directory!.exists()) {
        await directory!.create(recursive: true);
      }
      if (await directory!.exists()) {
        File saveFile = File("${directory!.path}/$fileName");
        if (await saveFile.exists()) {
          // ignore: use_build_context_synchronously
          changeScreen(context, LectureCoursVideo(video: saveFile));
          // return false;
        } else {
          final head = await header();
          await Dio().download(
            url,
            saveFile.path,
            // options: Options(headers: head),
            onReceiveProgress: (value1, value2) {},
          );
        }
        if (Platform.isIOS) {
          return false;
        }
        return true;
      }
    } catch (e) {
      printer(e);
    }
    return false;
  }

  downloadvideo(String url, String name, BuildContext context) async {
    bool downloaded = await saveVideo(url, name, context);
    if (downloaded) {
      printer("vidéo télécharger");
      Notify.showSuccess(context, 'Téléchargement réussie');
    } else {
      Notify.showFailure(context, 'Echec de téléchargment');
    }
  }
}
