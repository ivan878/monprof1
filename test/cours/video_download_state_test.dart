import 'package:flutter_test/flutter_test.dart';
import 'package:monprof/cours/data/models/cours_model.dart';
import 'package:monprof/cours/data/models/video_download_state.dart';

void main() {
  test('persists resumable video download information', () {
    final state = VideoDownloadState(
      courseId: 42,
      fileName: 'course.mp4',
      downloadedBytes: 20,
      totalBytes: 100,
      isDownloading: true,
      isDownloaded: false,
      status: 'downloading',
      updatedAt: DateTime.utc(2026, 8, 25),
    );

    final stored = state.toMap();
    final restored = VideoDownloadState.fromMap(stored);

    expect(stored['is_downloading'], isTrue);
    expect(stored['download_progress'], .2);
    expect(restored.downloadedBytes, 20);
    expect(restored.totalBytes, 100);
    expect(restored.progress, .2);
  });

  test('course reads the backend HTTP range capability', () {
    final course = Cours.fromMap({
      'id': 42,
      'video_url': 'https://minio.example/video.mp4',
      'libelle': 'Algèbre',
      'description': 'Cours',
      'classe_id': 1,
      'matieres_id': 2,
      'categorie_id': 3,
      'created_at': '2026-08-25T00:00:00Z',
      'updated_at': '2026-08-25T00:00:00Z',
      'open': true,
      'video_delivery': {
        'supports_range': true,
        'resume_strategy': 'http-range',
      },
    });

    expect(course.supportsRange, isTrue);
  });
}
