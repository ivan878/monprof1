import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/corps/utils/offline_first.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/concours/data/repository/concours_repository.dart';

class ConcoursDetailController extends ChangeNotifier {
  final ConcoursRepository repository;
  final HiveService hiveService;
  final String concoursId;

  ConcoursDetailController({
    required this.repository,
    required this.hiveService,
    required this.concoursId,
  });

  AppState<ConcoursModel> state = AppState();

  /// Affiche d'abord le concours en cache — matières et session comprises —
  /// puis le rafraîchit depuis le serveur. Sans réseau, la copie locale reste
  /// affichée : c'est elle qui rend le concours consultable hors connexion.
  Future<void> load() async {
    await OfflineFirst.load<ConcoursModel>(
      readCache: () => hiveService.getConcoursDetail(concoursId),
      fetch: () => repository.getConcoursById(concoursId),
      writeCache: hiveService.saveConcoursDetail,
      emit: (next) {
        state = next;
        notifyListeners();
      },
    );
  }

  Future<void> refresh() => load();
}
