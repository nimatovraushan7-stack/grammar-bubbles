import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'services/analytics_service.dart';
import 'services/sound_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/hash_service.dart';
import 'services/premium_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print(HashService.generateHash('TEST123'));

  await AnalyticsService.init();
  await SoundService.initialize();

  await Hive.initFlutter();
  await Hive.openBox('premiumBox');

  await PremiumService.initialize();

  runApp(
    const GrammarBubblesApp(),
  );
}
class GrammarBubblesApp extends StatelessWidget {
  const GrammarBubblesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grammar Bubbles',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
