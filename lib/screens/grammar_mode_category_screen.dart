import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/grammar_question.dart';
import '../services/analytics_service.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';
import '../widgets/responsive_text.dart';
import 'game_screen.dart';

class GrammarModeConfig {
  final String gameTitle;
  final String exerciseId;
  final List<String> bestScoreCategories;
  final Future<List<GrammarQuestion>> Function() questionsLoader;

  const GrammarModeConfig({
    required this.gameTitle,
    required this.exerciseId,
    required this.bestScoreCategories,
    required this.questionsLoader,
  });
}

class GrammarModeCategoryScreen extends StatelessWidget {
  final String titleKey;
  final String instructionKey;
  final GrammarModeConfig irregularMode;
  final GrammarModeConfig regularMode;
  final GrammarModeConfig separableMode;
  final GrammarModeConfig mixedMode;

  const GrammarModeCategoryScreen({
    super.key,
    required this.titleKey,
    required this.instructionKey,
    required this.irregularMode,
    required this.regularMode,
    required this.separableMode,
    required this.mixedMode,
  });

  static const _glowColor = Color(0xFF2FD4FF);

  @override
  Widget build(BuildContext context) {
    final l = LocalizationService.t;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                          _CategoryHeader(
                            title: l(titleKey),
                          ),
                          const SizedBox(height: 36),
                          ValueListenableBuilder(
                            valueListenable:
                                AnalyticsService.analyticsBox.listenable(),
                            builder: (context, _, __) {
                              final irregularBest = _bestScoreForCategories(
                                irregularMode.bestScoreCategories,
                              );
                              final regularBest = _bestScoreForCategories(
                                regularMode.bestScoreCategories,
                              );
                              final separableBest = _bestScoreForCategories(
                                separableMode.bestScoreCategories,
                              );
                              final mixedBest = _bestScoreForCategories(
                                mixedMode.bestScoreCategories,
                              );

                              return Column(
                                children: [
                                  _PracticeModeCard(
                                    title: l('regularVerbs'),
                                    bestScore: regularBest,
                                    total: 15,
                                    icon: Icons.check_circle_rounded,
                                    glowColor: _glowColor,
                                    onTap: () => _startMode(
                                      context,
                                      mode: regularMode,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _PracticeModeCard(
                                    title: l('irregularVerbs'),
                                    bestScore: irregularBest,
                                    total: 15,
                                    icon: Icons.bolt_rounded,
                                    glowColor: const Color(0xFF4CFF6B),
                                    onTap: () => _startMode(
                                      context,
                                      mode: irregularMode,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _PracticeModeCard(
                                    title: l('separableVerbs'),
                                    bestScore: separableBest,
                                    total: 15,
                                    icon: Icons.call_split_rounded,
                                    glowColor: const Color(0xFFFFD25B),
                                    onTap: () => _startMode(
                                      context,
                                      mode: separableMode,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _PracticeModeCard(
                                    title: l('mixed'),
                                    bestScore: mixedBest,
                                    total: 15,
                                    icon: Icons.shuffle_rounded,
                                    glowColor: const Color(0xFFB56CFF),
                                    onTap: () => _startMode(
                                      context,
                                      mode: mixedMode,
                                    ),
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
    );
  }

  static int _bestScoreForCategories(List<String> categories) {
    final scores = AnalyticsService.allResults
        .where((result) => categories.contains(result.category))
        .map((result) => result.score)
        .toList(growable: false);

    if (scores.isEmpty) return 0;
    return scores.reduce((best, score) => score > best ? score : best);
  }

  Future<void> _startMode(
    BuildContext context, {
    required GrammarModeConfig mode,
  }) async {
    await SoundService.playClick();
    final questions = await mode.questionsLoader();
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          title: mode.gameTitle,
          instruction: instructionKey,
          questions: questions,
          categoryId: 'verbs',
          categoryTitle: 'Werkwoorden',
          exerciseId: mode.exerciseId,
          exerciseTitle: mode.gameTitle,
        ),
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: GrammarModeCategoryScreen._glowColor.withOpacity(
          0.12,
        ),
        highlightColor: GrammarModeCategoryScreen._glowColor.withOpacity(
          0.06,
        ),
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
                  GrammarModeCategoryScreen._glowColor.withOpacity(0.18),
                  const Color(0xF0122638),
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: GrammarModeCategoryScreen._glowColor.withOpacity(
                0.38,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: GrammarModeCategoryScreen._glowColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;

  const _CategoryHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ResponsiveText(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          minFontSize: 16,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
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
        const SizedBox(height: 12),
        ResponsiveText(
          LocalizationService.t('choosePracticeMode'),
          textAlign: TextAlign.center,
          maxLines: 1,
          minFontSize: 10,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Color(0x99001018),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PracticeModeCard extends StatefulWidget {
  final String title;
  final int bestScore;
  final int total;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onTap;

  const _PracticeModeCard({
    required this.title,
    required this.bestScore,
    required this.total,
    required this.icon,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_PracticeModeCard> createState() => _PracticeModeCardState();
}

class _PracticeModeCardState extends State<_PracticeModeCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.985 : (_hovered ? 1.015 : 1.0);

    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      scale: scale,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onHover: (value) => setState(() => _hovered = value),
          splashColor: widget.glowColor.withOpacity(0.12),
          highlightColor: widget.glowColor.withOpacity(0.06),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xF01A3145),
                  Color.alphaBlend(
                    widget.glowColor.withOpacity(0.18),
                    const Color(0xF0122638),
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: widget.glowColor.withOpacity(0.38)),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: widget.glowColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: widget.glowColor.withOpacity(0.32),
                    ),
                  ),
                  child: Icon(widget.icon, color: widget.glowColor, size: 27),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ResponsiveText(
                        widget.title,
                        maxLines: 1,
                        minFontSize: 10,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _StarRating(
                            score: widget.bestScore,
                            total: widget.total,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: ResponsiveText(
                              LocalizationService.bestScore(
                                widget.bestScore,
                                widget.total,
                              ),
                              maxLines: 1,
                              minFontSize: 9,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: widget.glowColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int score;
  final int total;
  final double size;

  const _StarRating({
    required this.score,
    required this.total,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final earnedStars = _starCountForScore(score, total);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isEarned = index < earnedStars;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isEarned
                ? const Color(0xFFFFD25B)
                : Colors.white.withOpacity(0.28),
            size: size,
          ),
        );
      }),
    );
  }
}

int _starCountForScore(int score, int total) {
  if (total <= 0 || score <= 0) return 0;

  final percentage = score / total;
  if (percentage >= 0.9) return 3;
  if (percentage >= 0.7) return 2;
  return 1;
}
