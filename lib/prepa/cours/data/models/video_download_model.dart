/// État d'un téléchargement de vidéo, persisté pour survivre à la fermeture
/// de l'application.
enum VideoDownloadStatus {
  /// Téléchargement en cours dans cette session.
  downloading,

  /// Interrompu — réseau coupé, application fermée, annulation. Reprenable.
  paused,

  /// Fichier complet et vérifié.
  completed,

  /// Échec non reprenable : le fragment local a été jeté.
  failed,
}

/// Progression d'une vidéo, conservée entre deux lancements de l'application.
///
/// Le fichier est écrit dans [partPath] tant qu'il est incomplet, puis renommé
/// en [filePath] une fois terminé. Cette séparation évite qu'un fragment soit
/// pris pour une vidéo lisible : seul un fichier au nom final est complet.
///
/// [etag] mémorise l'empreinte du fichier distant au moment du premier octet.
/// À la reprise, elle est comparée à l'empreinte courante : si le fichier a été
/// remplacé côté serveur — re-chiffrement, nouvelle version — compléter le
/// fragment produirait un fichier mêlant deux versions, donc illisible.
class VideoDownloadModel {
  final String coursId;
  final String? matiereId;
  final String url;
  final String filePath;
  final String partPath;
  final int receivedBytes;
  final int totalBytes;
  final String? etag;
  final bool isCrypted;
  final VideoDownloadStatus status;
  final DateTime updatedAt;

  const VideoDownloadModel({
    required this.coursId,
    this.matiereId,
    required this.url,
    required this.filePath,
    required this.partPath,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.etag,
    this.isCrypted = false,
    this.status = VideoDownloadStatus.paused,
    required this.updatedAt,
  });

  /// Fraction téléchargée, entre 0 et 1.
  double get progress {
    if (totalBytes <= 0) return 0;
    return (receivedBytes / totalBytes).clamp(0.0, 1.0);
  }

  bool get isResumable =>
      status == VideoDownloadStatus.paused && receivedBytes > 0;

  bool get isComplete => status == VideoDownloadStatus.completed;

  VideoDownloadModel copyWith({
    int? receivedBytes,
    int? totalBytes,
    String? etag,
    bool? isCrypted,
    VideoDownloadStatus? status,
  }) {
    return VideoDownloadModel(
      coursId: coursId,
      matiereId: matiereId,
      url: url,
      filePath: filePath,
      partPath: partPath,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      etag: etag ?? this.etag,
      isCrypted: isCrypted ?? this.isCrypted,
      status: status ?? this.status,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'coursId': coursId,
        'matiereId': matiereId,
        'url': url,
        'filePath': filePath,
        'partPath': partPath,
        'receivedBytes': receivedBytes,
        'totalBytes': totalBytes,
        'etag': etag,
        'isCrypted': isCrypted,
        'status': status.name,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory VideoDownloadModel.fromJson(Map<String, dynamic> json) {
    return VideoDownloadModel(
      coursId: json['coursId']?.toString() ?? '',
      matiereId: json['matiereId']?.toString(),
      url: json['url']?.toString() ?? '',
      filePath: json['filePath']?.toString() ?? '',
      partPath: json['partPath']?.toString() ?? '',
      receivedBytes: (json['receivedBytes'] as num?)?.toInt() ?? 0,
      totalBytes: (json['totalBytes'] as num?)?.toInt() ?? 0,
      etag: json['etag']?.toString(),
      isCrypted: json['isCrypted'] as bool? ?? false,
      status: VideoDownloadStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => VideoDownloadStatus.paused,
      ),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
