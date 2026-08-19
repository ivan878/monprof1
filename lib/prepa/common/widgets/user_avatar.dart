import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';

/// Avatar utilisateur : photo de profil si elle existe, initiales sinon.
///
/// Centralise les deux comportements qui étaient jusqu'ici dispersés — chaque
/// écran calculait ses propres initiales et aucun, hors édition du profil,
/// n'affichait réellement la photo.
class UserAvatar extends StatelessWidget {
  final PrepaUser? user;

  /// Diamètre du cercle en pixels logiques.
  final double size;

  /// Couleur de fond du repli en initiales.
  final Color? backgroundColor;

  /// Taille du texte des initiales — déduite du diamètre si absente.
  final double? initialsSize;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 44,
    this.backgroundColor,
    this.initialsSize,
  });

  /// Une lettre par mot, deux au maximum.
  static String initialsOf(String? name) {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = user?.profilePictureUrl;
    final hasUrl = url != null && url.trim().isNotEmpty;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: hasUrl
            ? CachedNetworkImage(
                imageUrl: url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                // Décodage à la taille d'affichage : évite de garder en mémoire
                // une image pleine résolution pour un cercle de 44 px.
                memCacheWidth:
                    (size * MediaQuery.of(context).devicePixelRatio).round(),
                placeholder: (_, __) => _fallback(),
                errorWidget: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      color: backgroundColor ?? prepaPrimaryColor,
      alignment: Alignment.center,
      child: SimpleText(
        text: initialsOf(user?.fullName),
        size: initialsSize ?? size * 0.38,
        weight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
