import 'package:flutter/material.dart';

import '../data/grammar_catalog.dart';
import '../models/grammar_navigation.dart';
import '../services/favorite_service.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';
import '../utils/dictionary_debug.dart';
import '../widgets/grammar_menu_card.dart';
import '../widgets/responsive_text.dart';
import 'analytics_screen.dart';
import 'dictionary_screen.dart';
import 'favorites_home_screen.dart';
import 'grammar_menu_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    SoundService.startBackground();
  }

  @override
  Widget build(BuildContext context) {
    final l = LocalizationService.t;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/ocean_background.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(0),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            const Text(
                              'GRAMMAR\nBUBBLES',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ResponsiveText(
                              l('dashboardSubtitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 46),
                            ...GrammarCatalog.categories.expand(
                              (category) => [
                                GrammarMenuCard(
                                  title: l(category.title),
                                  description: l(category.description),
                                  icon: category.icon,
                                  glowColor: category.glowColor,
                                  comingSoon: category.comingSoon,
                                  onTap: () => _openCategory(
                                    context,
                                    category,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                            ValueListenableBuilder(
                              valueListenable: FavoriteService.listenable(),
                              builder: (context, _, __) {
                                return GrammarMenuCard(
                                  title: l('favorites'),
                                  description: l('savedWordsCount').replaceAll(
                                    '{count}',
                                    '${FavoriteService.count}',
                                  ),
                                  icon: Icons.star_rounded,
                                  glowColor: const Color(0xFFFFD25B),
                                  onTap: () async {
                                    await SoundService.playClick();
                                    if (!context.mounted) return;

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const FavoritesHomeScreen(),
                                      ),
                                    );
                                    if (!context.mounted) return;
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            GrammarMenuCard(
                              title: l('dictionary'),
                              description: l('dictionarySubtitle'),
                              icon: Icons.menu_book_rounded,
                              glowColor: const Color(0xFF2FD4FF),
                              onTap: () async {
                                DictionaryDebug.log(
                                  'DashboardScreen',
                                  'Dictionary card tapped',
                                );
                                await SoundService.playClick();
                                if (!context.mounted) return;

                                DictionaryDebug.log(
                                  'DashboardScreen',
                                  'Navigator.push DictionaryScreen',
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DictionaryScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(height: 10),
                            GrammarMenuCard(
                              title: l('settingsButton'),
                              description: l('settingsButtonSubtitle'),
                              icon: Icons.settings_rounded,
                              glowColor: const Color(0xFF45D7FF),
                              onTap: () async {
                                await SoundService.playClick();
                                if (!context.mounted) return;

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                                if (!context.mounted) return;
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 20),
                            GrammarMenuCard(
                              title: l('myGrowth'),
                              description: l('viewProgress'),
                              icon: Icons.insights_rounded,
                              glowColor: const Color(0xFFB56CFF),
                              onTap: () async {
                                await SoundService.playClick();
                                if (!context.mounted) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AnalyticsScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCategory(
    BuildContext context,
    GrammarCategory category,
  ) async {
    await SoundService.playClick();
    if (!context.mounted) return;

    final destinationBuilder = category.destinationBuilder;
    if (category.comingSoon || destinationBuilder == null) {
      await showComingSoonDialog(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: destinationBuilder,
      ),
    );
  }
}
