class VideoDownloadState {
  final int courseId;
  final String fileName;
  final int downloadedBytes;
  final int? totalBytes;
  final bool isDownloading;
  final bool isDownloaded;
  final String status;
  final String? lastError;
  final DateTime updatedAt;

  const VideoDownloadState({
    required this.courseId,
    required this.fileName,
    required this.downloadedBytes,
    required this.isDownloading,
    required this.isDownloaded,
    required this.status,
    required this.updatedAt,
    this.totalBytes,
    this.lastError,
  });

  double get progress {
    final total = totalBytes;
    if (total == null || total <= 0) return 0;
    return (downloadedBytes / total).clamp(0, 1);
  }

  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'file_name': fileName,
      'downloaded_bytes': downloadedBytes,
      'total_bytes': totalBytes,
      'is_downloading': isDownloading,
      'is_downloaded': isDownloaded,
      'download_progress': progress,
      'status': status,
      'last_error': lastError,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory VideoDownloadState.fromMap(Map<String, dynamic> map) {
    return VideoDownloadState(
      courseId: (map['course_id'] as num).toInt(),
      fileName: map['file_name']?.toString() ?? '',
      downloadedBytes: (map['downloaded_bytes'] as num?)?.toInt() ?? 0,
      totalBytes: (map['total_bytes'] as num?)?.toInt(),
      isDownloading: map['is_downloading'] == true,
      isDownloaded: map['is_downloaded'] == true,
      status: map['status']?.toString() ?? 'idle',
      lastError: map['last_error']?.toString(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
