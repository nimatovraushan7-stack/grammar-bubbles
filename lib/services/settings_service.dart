import 'package:hive_flutter/hive_flutter.dart';

import 'localization_service.dart';

class SettingsService {
  static const String boxName = 'settingsBox';
  static const int defaultQuestionTime = 10;
  static const String defaultLanguageCode = 'nl';

  static const String _questionTimeKey = 'questionTime';
  static const String _languageKey = 'language';

  static Future<void> initialize() async {
    await _box();
  }

  static int getQuestionTime() {
    final seconds = _boxSync().get(
      _questionTimeKey,
      defaultValue: defaultQuestionTime,
    );

    if (seconds is int) {
      return seconds.clamp(5, 20);
    }

    return defaultQuestionTime;
  }

  static Future<void> setQuestionTime(int seconds) async {
    await _boxSync().put(
      _questionTimeKey,
      seconds.clamp(5, 20),
    );
  }

  static String getLanguage() {
    final languageCode = _boxSync().get(
      _languageKey,
      defaultValue: defaultLanguageCode,
    );

    if (languageCode is String && languageCode.trim().isNotEmpty) {
      return languageCode.trim().toLowerCase();
    }

    return defaultLanguageCode;
  }

  static Future<void> setLanguage(String languageCode) async {
    final normalizedLanguageCode = languageCode.trim().toLowerCase();

    await _boxSync().put(
      _languageKey,
      normalizedLanguageCode,
    );
    await LocalizationService.setLanguage(normalizedLanguageCode);
  }

  static Future<Box<dynamic>> _box() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }

    return Hive.openBox<dynamic>(boxName);
  }

  static Box<dynamic> _boxSync() {
    if (!Hive.isBoxOpen(boxName)) {
      throw StateError('SettingsService must be initialized before use.');
    }

    return Hive.box<dynamic>(boxName);
  }
}
