import 'dart:convert';

import 'package:flutter/services.dart';

import 'settings_service.dart';

class LocalizationService {
  static const String fallbackLanguageCode = 'nl';

  static final Map<String, Map<String, String>> _cache = {};

  static String _languageCode = fallbackLanguageCode;

  static String get languageCode => _languageCode;

  static Future<void> initialize() async {
    _languageCode = SettingsService.getLanguage();
    await _loadLanguage(fallbackLanguageCode);
    await _loadLanguage(_languageCode);
  }

  static Future<void> setLanguage(String languageCode) async {
    _languageCode = languageCode.trim().toLowerCase();
    await _loadLanguage(_languageCode);
  }

  static String t(String key) {
    return _cache[_languageCode]?[key] ??
        _cache[fallbackLanguageCode]?[key] ??
        key;
  }

  static String questionCount(int current, int total) {
    return t('questionCount')
        .replaceAll('{current}', '$current')
        .replaceAll('{total}', '$total');
  }

  static String seconds(int count) {
    final key = count == 1 ? 'second' : 'seconds';
    return t(key).replaceAll('{count}', '$count');
  }

  static String bestScore(int score, int total) {
    return t('bestScore')
        .replaceAll('{score}', '$score')
        .replaceAll('{total}', '$total');
  }

  static String days(int count) {
    final key = count == 1 ? 'day' : 'days';
    return t(key).replaceAll('{count}', '$count');
  }

  static String instruction(String dutchInstruction) {
    if (_cache[fallbackLanguageCode]?.containsKey(dutchInstruction) ?? false) {
      return t(dutchInstruction);
    }

    switch (dutchInstruction) {
      case 'Zoek het voltooid deelwoord van:':
        return t('instructionPastParticiple');
      case 'Zoek de verleden tijd van:':
        return t('instructionPastTense');
      case 'Kies de juiste vorm van het scheidbare werkwoord:':
        return t('instructionSeparableVerb');
      case 'Kies het juiste lidwoord:':
        return t('instructionDeHet');
      case 'Kies deze of dit:':
        return t('instructionDezeDit');
      case 'Kies die of dat:':
        return t('instructionDieDat');
      case 'Kies het juiste bezittelijke voornaamwoord:':
        return t('instructionPossessivePronouns');
      case 'Kies het juiste persoonlijke voornaamwoord:':
        return t('instructionPersonalPronouns');
    }

    return t(dutchInstruction);
  }

  static String categoryTitle(String title) {
    switch (title) {
      case 'Voltooid Deelwoord':
        return t('pastParticiple');
      case 'Verleden Tijd':
        return t('pastTense');
      case 'Voltooid Deelwoord - Onregelmatig':
        return t('pastParticipleIrregular');
      case 'Voltooid Deelwoord - Regelmatig':
        return t('pastParticipleRegular');
      case 'Voltooid Deelwoord - Gemengd':
        return t('pastParticipleMixed');
      case 'Voltooid Deelwoord - Scheidbaar':
        return t('pastParticipleSeparable');
      case 'Verleden Tijd - Onregelmatig':
        return t('pastTenseIrregular');
      case 'Verleden Tijd - Regelmatig':
        return t('pastTenseRegular');
      case 'Verleden Tijd - Gemengd':
        return t('pastTenseMixed');
      case 'Verleden Tijd - Scheidbaar':
        return t('pastTenseSeparable');
      case 'Scheidbare Werkwoorden':
        return t('separableVerbs');
      case 'Werkwoorden - Gemengd':
        return t('mixedVerbs');
      case 'De / Het':
        return t('deHet');
      case 'Deze / Dit':
        return t('dezeDit');
      case 'Die / Dat':
        return t('dieDat');
      case 'Possessive Pronouns':
        return t('possessivePronouns');
      case 'Personal Pronouns':
        return t('personalPronouns');
      case 'Mixed Mode':
        return t('mixedMode');
    }

    return t(title);
  }

  static Future<void> _loadLanguage(String languageCode) async {
    if (_cache.containsKey(languageCode)) return;

    final jsonString = await rootBundle.loadString(
      'assets/l10n/$languageCode.json',
    );
    final jsonData = jsonDecode(jsonString);

    if (jsonData is! Map<String, dynamic>) {
      throw const FormatException('Localization asset must be a JSON object.');
    }

    _cache[languageCode] = jsonData.map(
      (key, value) => MapEntry(
        key,
        value is String ? value : key,
      ),
    );
  }
}
