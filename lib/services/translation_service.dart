import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'localization_service.dart';

class TranslationService {
  static const String boxName = 'translationBox';

  static final Map<String, Map<String, String>> _assetCache = {};

  static Future<void> initialize() async {
    await _box();
  }

  static Future<String> getTranslation(
    String word, {
    String languageCode = 'nl',
  }) async {
    final normalizedWord = _normalizeWord(word);
    final normalizedLanguage = _normalizeLanguage(languageCode);

    if (normalizedLanguage == 'nl') {
      return normalizedWord;
    }

    final cacheKey = '$normalizedLanguage:$normalizedWord';
    final box = await _box();
    final cachedTranslation = box.get(cacheKey);
    final unavailableText = LocalizationService.t('translationUnavailable');

    final translations = await _loadTranslations(normalizedLanguage);
    final assetTranslation = translations[normalizedWord];
    if (assetTranslation != null) {
      if (cachedTranslation != assetTranslation) {
        await box.put(cacheKey, assetTranslation);
      }

      return assetTranslation;
    }

    final translation = unavailableText;

    await box.put(cacheKey, translation);
    return translation;
  }

  static Future<Box<String>> _box() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<String>(boxName);
    }

    return Hive.openBox<String>(boxName);
  }

  static Future<Map<String, String>> _loadTranslations(
    String languageCode,
  ) async {
    final cachedTranslations = _assetCache[languageCode];
    if (cachedTranslations != null) {
      return cachedTranslations;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/verb_translations_$languageCode.json',
      );
      final jsonData = jsonDecode(jsonString);

      if (jsonData is! Map<String, dynamic>) {
        throw const FormatException('Translation asset must be a JSON object.');
      }

      final translations = jsonData.map(
        (key, value) => MapEntry(
          _normalizeWord(key),
          value is String
              ? value
              : LocalizationService.t('translationUnavailable'),
        ),
      );

      _assetCache[languageCode] = translations;
      return translations;
    } catch (_) {
      _assetCache[languageCode] = const {};
      return const {};
    }
  }

  static String _normalizeLanguage(String languageCode) {
    return languageCode.trim().toLowerCase();
  }

  static String _normalizeWord(String word) {
    return word.trim().toLowerCase();
  }
}
