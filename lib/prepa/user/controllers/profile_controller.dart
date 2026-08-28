import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/corps/utils/offline_first.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/common/apple_review_mode.dart';
import 'package:monprof/prepa/user/data/repository/user_repository.dart';

class PrepaProfileController extends ChangeNotifier {
  final PrepaUserRepository repository;
  final HiveService hiveService;

  PrepaProfileController({
    required this.repository,
    required this.hiveService,
  });

  AppState<PrepaUser> state = AppState();

  /// Affiche le profil en cache puis le rafraîchit depuis le serveur.
  ///
  /// Sans réseau, la dernière version connue reste affichée : l'écran de
  /// profil ne doit pas se vider parce que la connexion manque.
  Future<void> loadProfile() async {
    await OfflineFirst.load<PrepaUser>(
      readCache: () {
        final raw = hiveService.getProfile();
        return raw == null ? null : PrepaUser.fromJson(raw);
      },
      fetch: repository.getMe,
      writeCache: (user) => hiveService.saveProfile(user.toJson()),
      emit: (next) {
        state = next;
        // Le mode restreint iOS dépend du compte : il est réévalué aussi bien
        // sur la donnée locale que sur celle du serveur, pour que l'interface
        // soit correcte dès la première image.
        if (next.hasData) AppleReviewMode.instance.applyTo(next.data);
        notifyListeners();
      },
    );
  }

  Future<void> refresh() => loadProfile();
}
