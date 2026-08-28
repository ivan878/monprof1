import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/cours/data/crypto/mxv_container.dart';
import 'package:monprof/prepa/cours/data/crypto/video_decryption_service.dart';
import 'package:monprof/prepa/cours/data/repository/video_key_repository.dart';
import 'package:monprof/prepa/cours/screens/video_player_screen.dart';
import 'package:page_transition/page_transition.dart';

/// Ouvre le lecteur, en déchiffrant d'abord si nécessaire.
///
/// Le lecteur ne reçoit que des fichiers en clair. Cette étape est donc
/// commune à tous les points d'entrée — carte de cours, historique — et
/// centralisée ici pour éviter d'en dupliquer la logique.
class VideoLauncher {
  VideoLauncher._();

  /// Prépare puis ouvre la vidéo. Affiche une progression modale pendant le
  /// déchiffrement, annulable par l'utilisateur.
  static Future<void> open(
    BuildContext context, {
    required String filePath,
    required String coursId,
    String? matiereId,
    String? title,
    String? videoUrl,
    required bool isCrypted,
  }) async {
    final hive = GetIt.instance<HiveService>();
    var source = filePath;

    // Le chemin transmis peut être périmé — entrée d'historique écrite avant
    // le correctif, purge du système. Le cache vidéo reste la source de
    // vérité : on s'y replie avant de conclure à une vidéo perdue, sinon on
    // ferait retélécharger un fichier pourtant intact.
    if (!await File(source).exists()) {
      final cache = hive.getVideoCache(coursId, matiereId);
      if (cache != null && await File(cache.filePath).exists()) {
        source = cache.filePath;
      } else {
        hive
          ..deleteVideoCache(coursId, matiereId)
          ..deletePlaybackPosition(coursId, matiereId);
        Notify.toastError(
            'Cette vidéo n\'est plus disponible sur l\'appareil. '
            'Téléchargez-la à nouveau.');
        return;
      }
    }

    String playablePath = source;
    String? temporaryCacheKey;

    if (isCrypted) {
      final cacheKey = '${coursId}_${matiereId ?? 'none'}';
      final progress = ValueNotifier<double>(0);
      var cancelled = false;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _DecryptDialog(
          progress: progress,
          onCancel: () => cancelled = true,
        ),
      );

      try {
        final keyState = await GetIt.instance<VideoKeyRepository>()
            .resolve(coursId, expectedKeyId: await _keyIdOf(source));

        if (!keyState.hasData || keyState.data == null) {
          throw StateError(keyState.errorModel?.error ??
              'Clé de lecture indisponible. Connectez-vous une fois à Internet '
                  'pour débloquer cette vidéo.');
        }

        playablePath = await VideoDecryptionService.instance.decryptToTemp(
          encryptedPath: source,
          key: keyState.data!.key,
          cacheKey: cacheKey,
          onProgress: (p) => progress.value = p,
          cancelled: () => cancelled,
        );
        temporaryCacheKey = cacheKey;
      } catch (e) {
        if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
        // L'annulation est un choix de l'utilisateur, pas une erreur.
        if (!cancelled) {
          Notify.toastError(
              e is StateError ? e.message : 'Préparation de la vidéo impossible.');
        }
        return;
      } finally {
        progress.dispose();
      }

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // ferme la progression
    }

    if (!context.mounted) return;
    await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: VideoPlayerScreen(
          filePath: playablePath,
          coursId: coursId,
          matiereId: matiereId,
          title: title,
          videoUrl: videoUrl,
          temporaryCacheKey: temporaryCacheKey,
          // L'historique doit pointer sur le conteneur d'origine : la copie
          // en clair est effacée dès la fermeture du lecteur.
          sourceFilePath: source,
        ),
      ),
    );
  }

  /// Identifiant de clé inscrit dans l'en-tête du conteneur.
  ///
  /// Le comparer à la clé en coffre détecte une vidéo re-chiffrée côté
  /// administration et déclenche le renouvellement de la clé, plutôt qu'un
  /// échec ultérieur sur un tag GCM invalide.
  static Future<String?> _keyIdOf(String path) async {
    try {
      final handle = await File(path).open();
      try {
        return (await MxvHeader.readFrom(handle)).keyId;
      } finally {
        await handle.close();
      }
    } catch (_) {
      return null;
    }
  }
}

class _DecryptDialog extends StatelessWidget {
  final ValueNotifier<double> progress;
  final VoidCallback onCancel;

  const _DecryptDialog({required this.progress, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // La fermeture passe par « Annuler » : un retour système laisserait le
      // déchiffrement tourner sans que rien ne l'indique.
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (context, value, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SimpleText(
                text: 'Préparation de la vidéo',
                size: 15,
                weight: FontWeight.bold,
              ),
              const SizedBox(height: 4),
              SimpleText(
                text: '${(value * 100).round()} %',
                size: 13,
                color: onGrey300,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value > 0 ? value : null,
                  minHeight: 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(prepaPrimaryColor),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: onCancel,
            child: SimpleText(text: 'Annuler', size: 14, color: onGrey300),
          ),
        ],
      ),
    );
  }
}
