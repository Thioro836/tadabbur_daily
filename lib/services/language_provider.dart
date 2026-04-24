import 'package:flutter/material.dart';
import 'package:tadabbur_daily/services/app_localizations.dart';
import 'package:tadabbur_daily/services/storage_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = 'fr';
  late AppLocalizations _localizations;

  LanguageProvider() {
    _localizations = AppLocalizations(_language);
  }

  String get language => _language;
  AppLocalizations get localizations => _localizations;

  Future<void> initializeLanguage() async {
    _language = await StorageService().getLanguage();
    _localizations = AppLocalizations(_language);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_language == language) return;
    _language = language;
    _localizations = AppLocalizations(language);
    await StorageService().saveLanguage(language);
    notifyListeners();
  }

  String get(String key) {
    return _localizations.get(key);
  }

  String translate(String key, {Map<String, String>? params}) {
    return _localizations.translate(key, params: params);
  }
}
