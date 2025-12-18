import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:get/get.dart';
// import 'package:monprof/UI/lecteurvideo_screen.dart';
import 'package:monprof/corps/utils/constantes.dart';
// import 'package:monprof/corps/utils/helper.dart';
// import 'package:monprof/corps/utils/navigation.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class FileListenController extends GetxController {
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

  Future<Directory?> getDirectory() async => Platform.isIOS
      ? await getApplicationSupportDirectory()
      : await getExternalStorageDirectory();

  Future<File> getFileDecrypted(File cryptedFile) async {
    Directory? directory = await getDirectory();
    Uint8List encryptedData = cryptedFile.readAsBytesSync();
    Uint8List decryptedData = decryptFile(encryptedData, encryptedKey);
    File decryptedFile =
        File("${directory!.path}/${cryptedFile.path.split('/').last}");
    await decryptedFile.writeAsBytes(decryptedData);
    return decryptedFile;
  }

  late StreamSubscription intentSub;
  // final RxList<SharedMediaFile> _sharedFiles = <SharedMediaFile>[].obs;

  void openFileFromListOfMediaFiles() async {
    // get First file from the list
    // if (_sharedFiles.isNotEmpty) {
    //   SharedMediaFile firstFile = _sharedFiles.first;
    //   final file = File(firstFile.path);
    //   if (file.existsSync()) {
    //     printer("File exists: ${file.path}");
    //     // Decrypt the file if it is encrypted
    //     final decryptedFile = await getFileDecrypted(file);
    //     changeScreen(
    //       Get.context!,
    //       LectureCoursVideo(
    //         video: decryptedFile,
    //       ),
    //     );
    //   }
    // }
  }

  void initializeFiles() {
    // Listen to media sharing coming from outside the app while the app is in the memory.
    // intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
    //   _sharedFiles.value = value;
    //   openFileFromListOfMediaFiles();
    // }, onError: (err) {
    //   printer("getIntentDataStream error: $err");
    // });

    // Get the media sharing coming from outside the app while the app is closed.
    // ReceiveSharingIntent.instance.getInitialMedia().then((value) {
    //   if (value.isNotEmpty) {
    //     _sharedFiles.value = value;
    //     openFileFromListOfMediaFiles();
    //   } else {
    //     printer("No initial media files found.");
    //   }
    //   // Tell the library that we are done processing the intent.
    //   ReceiveSharingIntent.instance.reset();
    // });
    intentSub.resume();
  }

  @override
  void onInit() {
    initializeFiles();
    super.onInit();
  }

  @override
  void onClose() {
    intentSub.cancel();
    super.onClose();
  }

  @override
  void dispose() {
    intentSub.cancel();
    // _sharedFiles.clear();
    super.dispose();
  }
}
