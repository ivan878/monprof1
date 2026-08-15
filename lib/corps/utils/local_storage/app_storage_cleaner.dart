import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bilan d'une purge — utile pour le log et un éventuel retour utilisateur.
class StorageCleanupReport {
  final int videosDeleted;
  final int bytesFreed;
  final List<String> failures;

  const StorageCleanupReport({
    this.videosDeleted = 0,
    this.bytesFreed = 0,
    this.failures = const [],
  });

  double get megabytesFreed => bytesFreed / (1024 * 1024);

  @override
  String toString() =>
      'StorageCleanupReport(videos: $videosDeleted, '
      '${megabytesFreed.toStringAsFixed(1)} Mo, échecs: ${failures.length})';
}

/// Efface toutes les données locales de l'application.
///
/// Appelé à la déconnexion : aucune donnée du compte précédent ne doit rester
/// sur l'appareil — ni caches métier, ni vidéos téléchargées, ni préférences.
/// Chaque étape est isolée : l'échec de l'une n'empêche pas les suivantes.
class AppStorageCleaner {
  final HiveService hiveService;
  final FlutterSecureStorage secureStorage;

  const AppStorageCleaner({
    required this.hiveService,
    required this.secureStorage,
  });

  /// Extensions traitées comme des médias téléchargés lors du balayage.
  static const _mediaExtensions = {
    'mp4', 'm4v', 'mov', 'avi', 'mkv', 'webm', '3gp', 'flv', 'wmv', 'mpeg',
    'mpg', 'ts', 'm3u8', 'mp3', 'm4a', 'aac', 'wav',
  };

  Future<StorageCleanupReport> clearAll() async {
    final failures = <String>[];
    int videosDeleted = 0;
    int bytesFreed = 0;

    // 1. Vidéos référencées en cache — supprimées avant de vider Hive,
    //    sinon on perd les chemins et les fichiers deviennent orphelins.
    try {
      final result = await _deleteFiles(hiveService.allCachedVideoPaths());
      videosDeleted += result.count;
      bytesFreed += result.bytes;
    } catch (e) {
      failures.add('vidéos référencées: $e');
    }

    // 2. Balayage du dossier documents — rattrape les téléchargements
    //    interrompus avant leur enregistrement en cache.
    try {
      final dir = await getApplicationDocumentsDirectory();
      final result = await _sweepMediaFiles(dir);
      videosDeleted += result.count;
      bytesFreed += result.bytes;
    } catch (e) {
      failures.add('dossier documents: $e');
    }

    // 3. Dossier temporaire — fichiers partiels dio et cache images réseau.
    try {
      final tmp = await getTemporaryDirectory();
      bytesFreed += await _emptyDirectory(tmp);
    } catch (e) {
      failures.add('dossier temporaire: $e');
    }

    // 4. Caches métier Hive.
    try {
      await hiveService.clearAll();
    } catch (e) {
      failures.add('hive: $e');
    }

    // 5. Préférences simples.
    try {
      await (await SharedPreferences.getInstance()).clear();
    } catch (e) {
      failures.add('préférences: $e');
    }

    // 6. Stockage sécurisé (profil utilisateur).
    try {
      await secureStorage.deleteAll();
    } catch (e) {
      failures.add('stockage sécurisé: $e');
    }

    // 7. Images gardées en mémoire.
    try {
      PaintingBinding.instance.imageCache
        ..clear()
        ..clearLiveImages();
    } catch (e) {
      failures.add('cache images: $e');
    }

    final report = StorageCleanupReport(
      videosDeleted: videosDeleted,
      bytesFreed: bytesFreed,
      failures: failures,
    );
    printer('Purge du stockage local → $report');
    return report;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Future<({int count, int bytes})> _deleteFiles(Iterable<String> paths) async {
    int count = 0;
    int bytes = 0;
    for (final path in paths) {
      try {
        final file = File(path);
        if (!await file.exists()) continue;
        bytes += await file.length();
        await file.delete();
        count++;
      } catch (_) {
        continue; // fichier verrouillé ou déjà supprimé — sans conséquence
      }
    }
    return (count: count, bytes: bytes);
  }

  /// Supprime récursivement les fichiers médias d'un dossier, en laissant
  /// intactes les autres données (Hive stocke ses `.hive` au même endroit).
  Future<({int count, int bytes})> _sweepMediaFiles(Directory dir) async {
    int count = 0;
    int bytes = 0;
    if (!await dir.exists()) return (count: count, bytes: bytes);

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.path.split(Platform.pathSeparator).last;
      final dot = name.lastIndexOf('.');
      if (dot == -1) continue;
      final ext = name.substring(dot + 1).toLowerCase();
      if (!_mediaExtensions.contains(ext)) continue;

      try {
        bytes += await entity.length();
        await entity.delete();
        count++;
      } catch (_) {
        continue;
      }
    }
    return (count: count, bytes: bytes);
  }

  /// Vide un dossier de son contenu sans supprimer le dossier lui-même.
  Future<int> _emptyDirectory(Directory dir) async {
    int bytes = 0;
    if (!await dir.exists()) return bytes;

    await for (final entity in dir.list(followLinks: false)) {
      try {
        if (entity is File) bytes += await entity.length();
        await entity.delete(recursive: true);
      } catch (_) {
        continue;
      }
    }
    return bytes;
  }
}
