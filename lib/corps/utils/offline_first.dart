import 'package:monprof/corps/utils/app_state.dart';

/// Chargement « cache d'abord, réseau ensuite ».
///
/// Le déroulé est toujours le même :
/// 1. la donnée locale est affichée immédiatement, sans attendre le réseau ;
/// 2. la requête part en arrière-plan ;
/// 3. en cas de succès, le cache et la vue sont mis à jour.
///
/// Le point décisif est le comportement en cas d'échec : **si une donnée
/// locale existe, elle reste affichée**. Remonter l'erreur effacerait un
/// contenu parfaitement utilisable au seul motif que le réseau est absent —
/// exactement ce qu'un fonctionnement hors ligne doit éviter. L'erreur n'est
/// exposée que lorsqu'il n'y a rien à montrer.
class OfflineFirst {
  OfflineFirst._();

  /// [readCache] : lecture locale, `null` si rien en cache.
  /// [fetch] : appel réseau.
  /// [writeCache] : persistance du résultat réseau.
  /// [emit] : publication d'un état vers la vue — appelé une à deux fois.
  static Future<AppState<T>> load<T>({
    required T? Function() readCache,
    required Future<AppState<T>> Function() fetch,
    required void Function(T data) writeCache,
    required void Function(AppState<T> state) emit,
  }) async {
    T? cached;
    try {
      cached = readCache();
    } catch (_) {
      // Un cache illisible ne doit jamais empêcher l'appel réseau.
      cached = null;
    }

    if (cached != null) {
      emit(AppState(status: AppStatus.data, data: cached));
    } else {
      emit(AppState(status: AppStatus.loading));
    }

    final result = await fetch();

    if (result.hasData && result.data != null) {
      try {
        writeCache(result.data as T);
      } catch (_) {
        // L'échec d'écriture du cache ne doit pas priver la vue de la donnée.
      }
      emit(result);
      return result;
    }

    // Échec réseau : on ne remplace un contenu affiché que s'il n'y en a pas.
    if (cached == null) emit(result);
    return result;
  }
}
