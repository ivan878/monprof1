import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';

export 'package:monprof/corps/utils/local_storage/hive_service.dart'
    show PlaybackEntry;
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/common/apple_review_mode.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/concours/data/repository/concours_repository.dart';
import 'package:monprof/prepa/subscription/data/models/subscription_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

class HomeController extends ChangeNotifier {
  final ConcoursRepository concoursRepository;
  final SubscriptionRepository subscriptionRepository;
  final PrepaAuthRepository prepaAuthRepository;
  final HiveService hiveService;

  HomeController({
    required this.concoursRepository,
    required this.subscriptionRepository,
    required this.prepaAuthRepository,
    required this.hiveService,
  });

  AppState<List<ConcoursModel>> concoursState = AppState();
  AppState<List<SubscriptionModel>> subscriptionsState = AppState();
  PrepaUser? user;
  List<PlaybackEntry> videoHistory = [];

  bool _isLoading = false;

  void refreshVideoHistory() {
    videoHistory = hiveService.getPlaybackHistory().take(15).toList();
    notifyListeners();
  }

  Future<void> loadUser() async {
    try {
      user = await prepaAuthRepository.getCachedUser();
      // Le mode restreint iOS dépend du compte connecté : il est réévalué ici,
      // puis lu de façon synchrone par les écrans.
      AppleReviewMode.instance.applyTo(user);
      notifyListeners();
    } catch (e) {
      printer(e);
    }
  }

  void initialize() {
    load();
    loadUser();
  }

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    refreshVideoHistory(); // always sync from Hive on load
    try {
      // Show cached concours immediately
      final cachedConcours = hiveService.getConcoursList();
      if (cachedConcours.isNotEmpty) {
        concoursState = AppState(status: AppStatus.data, data: cachedConcours);
        subscriptionsState = AppState(status: AppStatus.loading);
      } else {
        concoursState = AppState(status: AppStatus.loading);
        subscriptionsState = AppState(status: AppStatus.loading);
      }
      notifyListeners();

      final results = await Future.wait([
        concoursRepository.listConcours(page: 1, size: 20),
        subscriptionRepository.listMySubscriptions(page: 0, size: 20),
      ]);

      final concoursResult = results[0] as AppState;
      if (concoursResult.hasData) {
        final page = concoursResult.data as dynamic;
        final list = (page.content as List).cast<ConcoursModel>();
        hiveService.saveConcoursList(list);
        concoursState = AppState(status: AppStatus.data, data: list);
      } else {
        if (cachedConcours.isEmpty) {
          concoursState = AppState(
            status: AppStatus.error,
            errorModel: concoursResult.errorModel,
          );
        }
        // Else keep showing cached silently
      }

      final subsResult = results[1] as AppState;
      if (subsResult.hasData) {
        final page = subsResult.data as dynamic;
        subscriptionsState = AppState(
          status: AppStatus.data,
          data: (page.content as List).cast<SubscriptionModel>(),
        );
      } else {
        subscriptionsState = AppState(
          status: AppStatus.error,
          errorModel: subsResult.errorModel,
        );
      }

      notifyListeners();
    } catch (e) {
      printer(e);
      final cachedConcours = hiveService.getConcoursList();
      if (cachedConcours.isEmpty) {
        concoursState = AppState(status: AppStatus.error);
      }
      subscriptionsState = AppState(status: AppStatus.error);
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() => load();
}
