import 'package:monprof/i18n/en.dart';
import 'package:monprof/i18n/fr.dart';

abstract class AppLocalization {
  static Map<String, Map<String, String>> translationsKeys = {
    'fr_FR': francais,
    'en_EN': anglais,
    'fr_CA': francais,
    'en_US': anglais,
  };
}
