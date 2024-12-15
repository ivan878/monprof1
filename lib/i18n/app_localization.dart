import 'package:monprof/i18n/de.dart';
import 'package:monprof/i18n/en.dart';
import 'package:monprof/i18n/es.dart';
import 'package:monprof/i18n/fr.dart';
import 'package:monprof/i18n/zh.dart';

abstract class AppLocalization {
  static Map<String, Map<String, String>> translationsKeys = {
    'fr_FR': francais,
    'en_EN': anglais,
    'fr_CA': francais,
    'en_US': anglais,
    'zh_CN': chinois,
    'es_ES': espagnol,
    'de_DE': allemand,
  };
}
