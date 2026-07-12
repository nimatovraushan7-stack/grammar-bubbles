import 'package:flutter/material.dart';

import '../models/grammar_question.dart';
import '../models/quiz_review_item.dart';
import '../services/favorite_service.dart';
import '../services/localization_service.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';
import '../services/translation_service.dart';
import '../widgets/responsive_text.dart';

class ResultScreen extends StatefulWidget {
  final String category;
  final int score;
  final int totalQuestions;
  final List<QuizReviewItem> reviewItems;

  const ResultScreen({
    super.key,
    required this.category,
    required this.score,
    required this.totalQuestions,
    this.reviewItems = const [],
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    SoundService.playVictory();
  }

  @override
  Widget build(BuildContext context) {
    double percentage = widget.score / widget.totalQuestions;

    int starCount = 0;

    if (percentage >= 0.9) {
      starCount = 3;
    } else if (percentage >= 0.7) {
      starCount = 2;
    } else if (widget.score > 0) {
      starCount = 1;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/ocean_background.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 34, 24, 72),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 106,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResponsiveText(
                          LocalizationService.categoryTitle(widget.category),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 14,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ResponsiveText(
                          LocalizationService.t('result'),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 14,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final isEarned = index < starCount;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Icon(
                                isEarned
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: isEarned
                                    ? const Color(0xFFFFD25B)
                                    : Colors.white.withOpacity(0.30),
                                size: 60,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 30),
                        ResponsiveText(
                          '${widget.score} / ${widget.totalQuestions}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 24,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ResponsiveText(
                          '${(percentage * 100).toInt()}%',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 14,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 22,
                          ),
                        ),
                        if (widget.reviewItems.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          _ReviewExpansionCard(
                            items: widget.reviewItems,
                            fallbackCategoryTitle: widget.category,
                          ),
                        ],
                        const SizedBox(height: 44),
                        SizedBox(
                          width: 260,
                          child: ElevatedButton(
                            onPressed: () async {
                              await SoundService.playClick();
                              if (!context.mounted) return;

                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2FD4FF),
                              shadowColor: const Color(0xFF2FD4FF),
                              elevation: 15,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: ResponsiveText(
                                    LocalizationService.t('playAgain'),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    minFontSize: 10,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 260,
                          child: OutlinedButton(
                            onPressed: () async {
                              await SoundService.playClick();
                              if (!context.mounted) return;

                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                              ),
                            ),
                            child: ResponsiveText(
                              LocalizationService.t('dashboard'),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              minFontSize: 10,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}

class _ReviewExpansionCard extends StatelessWidget {
  final List<QuizReviewItem> items;
  final String fallbackCategoryTitle;

  const _ReviewExpansionCard({
    required this.items,
    required this.fallbackCategoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final incorrectItems =
        items.where((item) => !item.isCorrect).toList(growable: false);
    final correctItems =
        items.where((item) => item.isCorrect).toList(growable: false);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 390),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xF01A3145),
            Color.alphaBlend(
              const Color(0xFF2FD4FF).withOpacity(0.12),
              const Color(0xF0122638),
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2FD4FF).withOpacity(0.28),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: const Color(0xFF2FD4FF).withOpacity(0.08),
          highlightColor: const Color(0xFF2FD4FF).withOpacity(0.05),
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          iconColor: const Color(0xFF2FD4FF),
          collapsedIconColor: const Color(0xFF2FD4FF),
          title: ResponsiveText(
            LocalizationService.t('reviewAnswers'),
            maxLines: 1,
            minFontSize: 14,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          children: [
            if (incorrectItems.isNotEmpty) ...[
              _ReviewSectionTitle(
                icon: Icons.cancel_rounded,
                color: Colors.redAccent,
                title: LocalizationService.t('incorrectAnswers'),
              ),
              const SizedBox(height: 10),
              ...incorrectItems.map(
                (item) => _ReviewAnswerCard(
                  item: item,
                  fallbackCategoryTitle: fallbackCategoryTitle,
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (correctItems.isNotEmpty) ...[
              _ReviewSectionTitle(
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF4CFF6B),
                title: LocalizationService.t('correctAnswers'),
              ),
              const SizedBox(height: 10),
              ...correctItems.map(
                (item) => _ReviewAnswerCard(
                  item: item,
                  fallbackCategoryTitle: fallbackCategoryTitle,
                  compact: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewSectionTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const _ReviewSectionTitle({
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: ResponsiveText(
            title,
            maxLines: 1,
            minFontSize: 13,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewAnswerCard extends StatelessWidget {
  final QuizReviewItem item;
  final String fallbackCategoryTitle;
  final bool compact;

  const _ReviewAnswerCard({
    required this.item,
    required this.fallbackCategoryTitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final question = item.question;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ReviewWord(word: question.word),
                const SizedBox(height: 8),
                if (!compact) ...[
                  _AnswerLine(
                    label: LocalizationService.t('yourAnswer'),
                    value:
                        item.selectedAnswer ?? LocalizationService.t('timesUp'),
                    valueColor: Colors.redAccent.shade100,
                  ),
                  const SizedBox(height: 5),
                ],
                _AnswerLine(
                  label: compact
                      ? LocalizationService.t('correct')
                      : LocalizationService.t('correctAnswer'),
                  value: question.correctAnswer,
                  valueColor: const Color(0xFF4CFF6B),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _ReviewFavoriteButton(
            question: question,
            fallbackCategoryTitle: fallbackCategoryTitle,
          ),
        ],
      ),
    );
  }
}

class _ReviewWord extends StatefulWidget {
  final String word;

  const _ReviewWord({required this.word});

  @override
  State<_ReviewWord> createState() => _ReviewWordState();
}

class _ReviewWordState extends State<_ReviewWord> {
  bool showTranslation = false;
  String? translationText;

  Future<void> toggleTranslation() async {
    final shouldShowTranslation = !showTranslation;

    setState(() {
      showTranslation = shouldShowTranslation;
      if (shouldShowTranslation) {
        translationText = null;
      }
    });

    if (!shouldShowTranslation) return;

    final translation = await TranslationService.getTranslation(
      widget.word,
      languageCode: SettingsService.getLanguage(),
    );

    if (!mounted || !showTranslation) return;

    setState(() {
      translationText = translation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shownWord = showTranslation && translationText != null
        ? translationText!
        : widget.word;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: toggleTranslation,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: ResponsiveText(
          shownWord,
          key: ValueKey('${widget.word}-$shownWord'),
          maxLines: 1,
          minFontSize: 11,
          style: TextStyle(
            color: showTranslation && translationText != null
                ? const Color(0xFF45D7FF)
                : Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _AnswerLine({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          child: ResponsiveText(
            label,
            maxLines: 1,
            minFontSize: 8,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ResponsiveText(
            value,
            maxLines: 1,
            minFontSize: 8,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewFavoriteButton extends StatelessWidget {
  final GrammarQuestion question;
  final String fallbackCategoryTitle;

  const _ReviewFavoriteButton({
    required this.question,
    required this.fallbackCategoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final category = question.category ?? 'general';
    final exercise = question.exercise ?? fallbackCategoryTitle;

    return SizedBox(
      width: 42,
      height: 42,
      child: ValueListenableBuilder(
        valueListenable: FavoriteService.listenable(),
        builder: (context, _, __) {
          final isFavorite = FavoriteService.isFavorite(
            question: question,
            category: category,
            exercise: exercise,
          );

          return IconButton(
            tooltip: LocalizationService.t(
              isFavorite ? 'removeFavorite' : 'addFavorite',
            ),
            onPressed: () async {
              await SoundService.playClick();
              final added = await FavoriteService.toggleFavorite(
                question: question,
                category: category,
                categoryTitle: question.categoryTitle ?? fallbackCategoryTitle,
                exercise: exercise,
                exerciseTitle: question.exerciseTitle ?? fallbackCategoryTitle,
                instruction: question.instructionKey ?? '',
              );

              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF061B2A),
                    content: ResponsiveText(
                      LocalizationService.t(
                        added ? 'addedToFavorites' : 'removedFromFavorites',
                      ),
                      maxLines: 1,
                      minFontSize: 11,
                    ),
                  ),
                );
            },
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavorite
                  ? const Color(0xFFFFD25B)
                  : Colors.white.withOpacity(0.78),
            ),
          );
        },
      ),
    );
  }
}
