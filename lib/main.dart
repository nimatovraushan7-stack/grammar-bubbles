import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'services/analytics_service.dart';
import 'services/sound_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/hash_service.dart';
import 'services/favorite_service.dart';
import 'services/dictionary_service.dart';
import 'services/learning_level_service.dart';
import 'services/localization_service.dart';
import 'services/premium_service.dart';
import 'services/settings_service.dart';
import 'services/translation_service.dart';
import 'utils/dictionary_debug.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      DictionaryDebug.error(
        'FlutterError.onError',
        details.exception,
        details.stack ?? StackTrace.current,
        context: details.context?.toDescription(),
      );
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      DictionaryDebug.error(
        'PlatformDispatcher.onError',
        error,
        stackTrace,
      );
      return false;
    };

    print(HashService.generateHash('TEST123'));

    await AnalyticsService.init();
    await SoundService.initialize();

    await Hive.initFlutter();
    await Hive.openBox('premiumBox');
    await SettingsService.initialize();
    await FavoriteService.initialize();
    await DictionaryService.initialize();
    await LearningLevelService.initialize();
    await LocalizationService.initialize();
    await TranslationService.initialize();

    await PremiumService.initialize();

    runApp(
      const GrammarBubblesApp(),
    );
  }, (error, stackTrace) {
    DictionaryDebug.error(
      'runZonedGuarded',
      error,
      stackTrace,
    );
  });
}

class GrammarBubblesApp extends StatelessWidget {
  const GrammarBubblesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: LocalizationService.t('appTitle'),
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
