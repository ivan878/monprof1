import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/api_service.dart';
import 'package:monprof/corps/utils/helper.dart';
// import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/cours/data/models/cours_model.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:monprof/UI/lecteurvideoScreen.dart';
// import 'package:monprof/corps/utils/navigation.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoController extends GetxController {
  Cours cours;

  VideoController({required this.cours});

  RxDouble progrees = 0.0.obs;
  RxBool loading = false.obs;
  // RxBool isDownloaded = false.obs;
  Rx<File> files = File('').obs;

  //Request permission

  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.status;
    if (!status.isGranted) {
      var result = await permission.request();
      if (result.isGranted) {
        return true;
      }
    }
    return false;
  }

  Future<Directory?> getDirectory() async => Platform.isIOS
      ? await getApplicationDocumentsDirectory()
      : await getExternalStorageDirectory();

  Future<bool> getPersmission() async => Platform.isIOS
      ? await requestPermission(Permission.photos)
      : await requestPermission(Permission.storage);

  //fonction de suppression de vidéo mal télécharger ou avec erreur de lecture
  Future<bool> supprimer() async {
    String fileName = cours.created_at
        .replaceAll('-', '_')
        .replaceAll(':', '_')
        .replaceAll('.', '');

    Directory? dir = Platform.isIOS
        ? await getApplicationSupportDirectory()
        : await getExternalStorageDirectory();
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

  Future<bool> saveVideo() async {
    String fileName = cours.created_at
        .replaceAll('-', '_')
        .replaceAll(':', '_')
        .replaceAll('.', '');
    try {
      // final permission =
      await getPersmission();
      directory = await getDirectory();

      // if (!permission) {
      //   loger('Permission non accordé');
      //   return false;
      // }

      if (!await directory!.exists()) {
        await directory!.create(recursive: true);
      }
      File saveFile = File("${directory!.path}/$fileName");
      loading.value = true;
      update();
      final head = await header();
      await Dio().download(
        cours.video_url,
        saveFile.path,
        options: Options(headers: head),
        onReceiveProgress: (received, total) {
          progrees.value = double.parse((received / total).toStringAsFixed(0));
          update();
        },
      );
      files.value = saveFile;
      // debugger(message: response.data.toString());
      // loger(response.data);
      // await saveFile.writeAsString(response.data);
      await existCour();
      loading.value = false;
      progrees.value = 0.0;
      return true;
    } catch (e) {
      loger(e);
      return false;
    }
  }

  Future<bool> downloadvideo() async {
    return await saveVideo();
  }

  existCour() async {
    String fileName = cours.created_at
        .replaceAll('-', '_')
        .replaceAll(':', '_')
        .replaceAll('.', '');
    await getPersmission();
    directory = await getDirectory();
    File targetFile = File("${directory!.path}/$fileName");
    final exist = await targetFile.exists();
    loger(exist);
    if (exist) {
      // isDownloaded.value = true;
      files.value = targetFile;
      update();
    }
  }
}
