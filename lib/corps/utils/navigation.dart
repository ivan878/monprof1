import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

/// Clé du navigateur racine.
///
/// Permet de naviguer depuis une couche qui n'a pas de `BuildContext` —
/// typiquement une invalidation de session détectée par l'intercepteur réseau.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<dynamic> changeScreen(BuildContext context, Widget page) async {
  return await Navigator.push(
    context,
    PageTransition(
      child: page,
      type: PageTransitionType.topToBottom,
    ),
  );
}
