import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/cours/data/models/cours_model.dart';
import 'package:monprof/prepa/cours/data/models/matiere_model.dart';

// Playback history entry — one per video with a saved position
typedef PlaybackEntry = ({
  String coursId,
  String? matiereId,
  String? title,
  String? filePath,
  String? videoUrl,
  int positionMs,
  int totalMs,
});

class HiveService {
  late Box<String> _concours;
  late Box<String> _matieres;
  late Box<String> _cours;
  late Box<String> _coursByMatiere;
  late Box<String> _videoCache;
  late Box<String> _playback; // reading positions

  Future<void> init() async {
    await Hive.initFlutter();
    _concours = await Hive.openBox<String>('cache_concours');
    _matieres = await Hive.openBox<String>('cache_matieres');
    _cours = await Hive.openBox<String>('cache_cours');
    _coursByMatiere = await Hive.openBox<String>('cache_cours_by_matiere');
    _videoCache = await Hive.openBox<String>('cache_video');
    _playback = await Hive.openBox<String>('cache_playback');
  }

  // ── Shared key helper ───────────────────────────────────────────────────────

  String _key(String coursId, String? matiereId) =>
      '${coursId}_${matiereId ?? 'none'}';

  // ── Concours detail cache ───────────────────────────────────────────────────

  ConcoursModel? getConcoursDetail(String id) {
    final raw = _concours.get('detail_$id');
    if (raw == null) return null;
    try {
      return ConcoursModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  void saveConcoursDetail(ConcoursModel concours) {
    _concours.put('detail_${concours.id}', jsonEncode(concours.toJson()));
  }

  // ── Concours list (first page only) ────────────────────────────────────────

  List<ConcoursModel> getConcoursList() {
    final raw = _concours.get('list');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ConcoursModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void saveConcoursList(List<ConcoursModel> items) {
    _concours.put('list', jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // ── Matieres list (first page only) ────────────────────────────────────────

  List<MatiereModel> getMatieresList() {
    final raw = _matieres.get('list');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MatiereModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void saveMatieresList(List<MatiereModel> items) {
    _matieres.put('list', jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // ── Cours by matière (first page only) ─────────────────────────────────────

  List<PrepaCoursModel> getCoursByMatiereId(String matiereId) {
    final raw = _coursByMatiere.get(matiereId);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PrepaCoursModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void saveCoursByMatiereId(String matiereId, List<PrepaCoursModel> items) {
    _coursByMatiere.put(
        matiereId, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // ── Cours detail ────────────────────────────────────────────────────────────

  PrepaCoursModel? getCours(String coursId) {
    final raw = _cours.get(coursId);
    if (raw == null) return null;
    try {
      return PrepaCoursModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  void saveCours(PrepaCoursModel cours) {
    _cours.put(cours.id, jsonEncode(cours.toJson()));
  }

  // ── Video file cache ────────────────────────────────────────────────────────

  ({String filePath, String videoUrl})? getVideoCache(
      String coursId, String? matiereId) {
    final raw = _videoCache.get(_key(coursId, matiereId));
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return (
        filePath: map['filePath'] as String,
        videoUrl: map['videoUrl'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  void saveVideoCache(
      String coursId, String? matiereId, String filePath, String videoUrl) {
    _videoCache.put(
      _key(coursId, matiereId),
      jsonEncode({'filePath': filePath, 'videoUrl': videoUrl}),
    );
  }

  void deleteVideoCache(String coursId, String? matiereId) {
    _videoCache.delete(_key(coursId, matiereId));
  }

  // ── Playback position ───────────────────────────────────────────────────────

  PlaybackEntry? getPlaybackPosition(String coursId, String? matiereId) {
    final raw = _playback.get(_key(coursId, matiereId));
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return (
        coursId: m['coursId'] as String? ?? coursId,
        matiereId: m['matiereId'] as String?,
        title: m['title'] as String?,
        filePath: m['filePath'] as String?,
        videoUrl: m['videoUrl'] as String?,
        positionMs: m['positionMs'] as int? ?? 0,
        totalMs: m['totalMs'] as int? ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  void savePlaybackPosition({
    required String coursId,
    required String? matiereId,
    required int positionMs,
    required int totalMs,
    String? title,
    String? filePath,
    String? videoUrl,
  }) {
    _playback.put(
      _key(coursId, matiereId),
      jsonEncode({
        'coursId': coursId,
        'matiereId': matiereId,
        'positionMs': positionMs,
        'totalMs': totalMs,
        'title': title,
        'filePath': filePath,
        'videoUrl': videoUrl,
      }),
    );
  }

  void deletePlaybackPosition(String coursId, String? matiereId) {
    _playback.delete(_key(coursId, matiereId));
  }

  // ── Purge ───────────────────────────────────────────────────────────────────

  /// Chemins de tous les fichiers vidéo référencés en cache, quelle que soit
  /// la boîte qui les enregistre (téléchargements + historique de lecture).
  Set<String> allCachedVideoPaths() {
    final paths = <String>{};

    void collect(Box<String> box) {
      for (final raw in box.values) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          final path = map['filePath'] as String?;
          if (path != null && path.isNotEmpty) paths.add(path);
        } catch (_) {
          continue;
        }
      }
    }

    collect(_videoCache);
    collect(_playback);
    return paths;
  }

  /// Vide toutes les boîtes locales. À appeler à la déconnexion :
  /// aucune donnée du compte précédent ne doit survivre.
  Future<void> clearAll() async {
    await Future.wait([
      _concours.clear(),
      _matieres.clear(),
      _cours.clear(),
      _coursByMatiere.clear(),
      _videoCache.clear(),
      _playback.clear(),
    ]);
  }

  /// All videos with a saved position, sorted by most recently updated
  /// (Hive preserves insertion order, newest overwrites same key in-place).
  List<PlaybackEntry> getPlaybackHistory() {
    final entries = <PlaybackEntry>[];
    for (final raw in _playback.values) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final positionMs = m['positionMs'] as int? ?? 0;
        if (positionMs <= 0) continue;
        entries.add((
          coursId: m['coursId'] as String? ?? '',
          matiereId: m['matiereId'] as String?,
          title: m['title'] as String?,
          filePath: m['filePath'] as String?,
          videoUrl: m['videoUrl'] as String?,
          positionMs: positionMs,
          totalMs: m['totalMs'] as int? ?? 0,
        ));
      } catch (_) {
        continue;
      }
    }
    return entries.reversed.toList(); // most recently added last → reversed = most recent first
  }
}
