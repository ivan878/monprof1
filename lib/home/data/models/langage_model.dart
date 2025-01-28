// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class LangageModel {
  Locale locale;
  String name;

  LangageModel({required this.locale, required this.name});

  // @override
  // operator ==(Object other) {
  //   return other is LangageModel &&
  //       other.locale.countryCode == locale.languageCode &&
  //       other.name == name;
  // }

  @override
  bool operator ==(covariant LangageModel other) {
    if (identical(this, other)) return true;

    return other.locale == locale && other.name == name;
  }

  @override
  int get hashCode => locale.hashCode ^ name.hashCode;
}

List<LangageModel> languageList = [
  LangageModel(locale: Locale('en'), name: 'English'),
  LangageModel(locale: Locale('fr'), name: 'Français'),
  LangageModel(locale: Locale('es'), name: 'Español'),
  LangageModel(locale: Locale('de'), name: 'Deutsch'),
  LangageModel(locale: Locale('zh'), name: '中文'),
];
