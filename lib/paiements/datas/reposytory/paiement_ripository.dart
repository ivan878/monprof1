import 'package:monprof/paiements/datas/models/paiements.dart';
import 'package:monprof/paiements/datas/services/paiements_services.dart';

class PaiementRepository {
  final PaiementServices services;
  PaiementRepository({required this.services});

  Future<bool> requestPaiements(Paiements paiement) async {
    try {
      final datas = await services.requestPaiements(paiement);
      return datas['status'];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> activeCode(String code) async {
    try {
      final datas = await services.activeCode(code);
      return datas['status'];
    } catch (e) {
      rethrow;
    }
  }
}
