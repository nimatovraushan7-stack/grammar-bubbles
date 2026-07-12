import 'package:flutter/material.dart';

import '../services/favorite_service.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';
import '../widgets/grammar_menu_card.dart';
import '../widgets/responsive_text.dart';
import 'favorite_list_screen.dart';

class FavoritesHomeScreen extends StatelessWidget {
  const FavoritesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LocalizationService.t;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/ocean_background.png'),
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
                            Row(
                              children: [
                                _IconActionButton(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  onTap: () async {
                                    await SoundService.playClick();
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                  },
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 26),
                            ResponsiveText(
                              l('favorites'),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              minFontSize: 18,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                                shadows: [
                                  Shadow(
                                    color: Color(0xAA001018),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            ResponsiveText(
                              l('favoritesSubtitle'),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              minFontSize: 10,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 36),
                            ValueListenableBuilder(
                              valueListenable: FavoriteService.listenable(),
                              builder: (context, _, __) {
                                final summaries =
                                    FavoriteService.categorySummaries;

                                if (summaries.isEmpty) {
                                  return const _EmptyFavoritesState();
                                }

                                return Column(
                                  children: [
                                    ...summaries.expand(
                                      (summary) => [
                                        GrammarMenuCard(
                                          title:
                                              '${l('favoritePrefix')} ${LocalizationService.t(summary.title)}',
                                          description: LocalizationService.t(
                                            'savedWordsCount',
                                          ).replaceAll(
                                            '{count}',
                                            '${summary.count}',
                                          ),
                                          icon: Icons.star_rounded,
                                          glowColor: const Color(0xFFFFD25B),
                                          onTap: () => _openCategory(
                                            context,
                                            summary.category,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
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
    String category,
  ) async {
    await SoundService.playClick();
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoriteListScreen(category: category),
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState();

  @override
  Widget build(BuildContext context) {
    final l = LocalizationService.t;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xF01A3145),
            Color.alphaBlend(
              const Color(0xFFFFD25B).withOpacity(0.14),
              const Color(0xF0122638),
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD25B).withOpacity(0.34),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star_rounded,
            color: Color(0xFFFFD25B),
            size: 52,
          ),
          const SizedBox(height: 14),
          ResponsiveText(
            l('noFavoriteWordsYet'),
            textAlign: TextAlign.center,
            maxLines: 1,
            minFontSize: 14,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            l('favoritesEmptySubtitle'),
            textAlign: TextAlign.center,
            maxLines: 4,
            minFontSize: 12,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const glowColor = Color(0xFF2FD4FF);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: glowColor.withOpacity(0.12),
        highlightColor: glowColor.withOpacity(0.06),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xF01A3145),
                Color.alphaBlend(
                  glowColor.withOpacity(0.18),
                  const Color(0xF0122638),
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: glowColor.withOpacity(0.38),
            ),
          ),
          child: Icon(
            icon,
            color: glowColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}
