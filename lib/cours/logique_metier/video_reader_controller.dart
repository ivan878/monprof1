import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/utils/constantes.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/cours/data/models/cours_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class VideoController extends GetxController {
  Cours cours;
  late String fileName;

  VideoController({required this.cours}) {
    fileName = cours.created_at
        .replaceAll('-', '_')
        .replaceAll(':', '_')
        .replaceAll('.', '');
    fileName += ".mprf.mp4";
    super.onInit();
  }

  double progrees = 0.0;
  bool loading = false;
  bool isDownloaded = false;
  File files = File('');

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
      ? await getApplicationSupportDirectory()
      : await getExternalStorageDirectory();

  Future<bool> getPersmission() async => Platform.isIOS
      ? await requestPermission(Permission.photos)
      : await requestPermission(Permission.storage);

  //fonction de suppression de vidéo mal télécharger ou avec erreur de lecture
  Future<bool> supprimer() async {
    Directory? dir = Platform.isIOS
        ? await getApplicationSupportDirectory()
        : await getExternalStorageDirectory();
    // final targetFile = Directory("${dir.path}/books/$fileName.pdf");
    File targetFile = File("${dir!.path}/$fileName");
    if (targetFile.existsSync()) {
      targetFile.deleteSync(recursive: true);
      update();
      existCour();
      printer('fichier supprimer avec succes:');
      return true;
    } else {
      update();
      return false;
    }
  }

  Directory? directory;

  Uint8List decryptFile(Uint8List encryptedData, String base64Key) {
    final keyString =
        base64Key.startsWith('base64:') ? base64Key.substring(7) : base64Key;
    final keyBytes = base64.decode(keyString);
    // final key = encrypt.Key.fromUtf8(keyString.padRight(32).substring(0, 32));
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV(encryptedData.sublist(0, 16));
    final data = encryptedData.sublist(16);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decryptBytes(encrypt.Encrypted(data), iv: iv);

    return Uint8List.fromList(decrypted);
  }

  Future<File> getFileDecrypted(File cryptedFile) async {
    try {
      Uint8List encryptedData = cryptedFile.readAsBytesSync();
      Uint8List decryptedData = decryptFile(encryptedData, encryptedKey);
      File decryptedFile =
          File("${directory!.path}/${cryptedFile.path.split('/').last}");
      await decryptedFile.writeAsBytes(decryptedData);
      return decryptedFile;
    } catch (e) {
      return cryptedFile;
    }
  }

  Future saveVideo() async {
    try {
      // final permission =
      bool permissionGranted = await getPersmission();
      if (permissionGranted || Platform.isIOS) {
        directory = await getDirectory();
        if (!await directory!.exists()) {
          await directory!.create(recursive: true);
        }
        File saveFile = File("${directory!.path}/$fileName");
        loading = true;
        update();
        // final head = await header();
        await Dio().download(
          cours.video_url,
          saveFile.path,
          // options: Options(headers: head),
          onReceiveProgress: (received, total) {
            final progressvalue = received / total;
            printer(progressvalue);
            progrees = progressvalue;
            update();
          },
        );
        files = saveFile;
        await existCour();
        loading = false;
        progrees = 0.0;
        update();
      } else {
        Notify.toastError("Permission non accrodee");
      }
    } catch (e) {
      loger(e);
      supprimer();
      Notify.toastError("Erreur de téléchargement de la vidéo $e".tr);
    } finally {
      update();
    }
  }

  Future downloadvideo() async {
    return saveVideo();
  }

  Future<void> existCour() async {
    await getPersmission();
    directory = await getDirectory();
    File targetFile = File("${directory!.path}/$fileName");
    isDownloaded = await targetFile.exists();
    loger(isDownloaded);
    if (isDownloaded) {
      // isDownloaded = true;
      files = targetFile;
    }
    update();
  }
}
