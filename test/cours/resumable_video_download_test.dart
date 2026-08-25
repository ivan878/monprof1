import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monprof/cours/data/models/cours_model.dart';
import 'package:monprof/cours/logique_metier/video_reader_controller.dart';

class _TestVideoController extends VideoController {
  final Directory testDirectory;

  _TestVideoController({
    required super.cours,
    required this.testDirectory,
  });

  @override
  Future<Directory> getDirectory() async => testDirectory;
}

void main() {
  test('resumes a partial video using an HTTP Range request', () async {
    final bytes = List<int>.generate(2048, (index) => index % 255);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    String? receivedRange;
    server.listen((request) async {
      receivedRange = request.headers.value(HttpHeaders.rangeHeader);
      final offset = int.parse(
        RegExp(r'bytes=([0-9]+)-').firstMatch(receivedRange!)!.group(1)!,
      );
      final remaining = bytes.sublist(offset);
      request.response
        ..statusCode = HttpStatus.partialContent
        ..headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $offset-${bytes.length - 1}/${bytes.length}',
        )
        ..contentLength = remaining.length
        ..add(remaining);
      await request.response.close();
    });

    final directory = await Directory.systemTemp.createTemp('monprof-video-');
    addTearDown(() => directory.delete(recursive: true));
    final course = Cours(
      id: 7,
      video_url: 'http://${server.address.host}:${server.port}/course.mp4',
      libelle: 'Cours test',
      description: 'Test de reprise',
      classe_id: 1,
      matieres_id: 1,
      categorie_id: 1,
      created_at: '2026-08-25T00:00:00',
      updated_at: '2026-08-25T00:00:00',
      open: true,
      supportsRange: true,
    );
    final controller = _TestVideoController(
      cours: course,
      testDirectory: directory,
    );
    final partial = File('${directory.path}/${controller.fileName}.part');
    await partial.writeAsBytes(bytes.sublist(0, 512));

    final downloaded = await controller.downloadvideo();

    expect(downloaded, isTrue);
    expect(receivedRange, 'bytes=512-');
    expect(controller.isDownloaded, isTrue);
    expect(controller.progrees, 1);
    expect(await controller.files.readAsBytes(), bytes);
  });
}
