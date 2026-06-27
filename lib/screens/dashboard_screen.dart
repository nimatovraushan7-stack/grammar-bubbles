import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'analytics_screen.dart';
import 'game_screen.dart';

import '../services/analytics_service.dart';
import '../services/question_generator.dart';
import '../services/sound_service.dart';

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
          color: Colors.black.withOpacity(0),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
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
                    const Text(
                      'Leer grammatica spelenderwijs',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 60),
                    ValueListenableBuilder(
                      valueListenable:
                          AnalyticsService.analyticsBox.listenable(),
                      builder: (context, _, __) {
                        final best = AnalyticsService.bestScoreForCategory(
                            'Voltooid Deelwoord');
                        return _MenuButton(
                          title: 'Voltooid Deelwoord',
                          subtitle: 'Oefen het perfecte deelwoord',
                          icon: Icons.auto_awesome_rounded,
                          glowColor: const Color(0xFF2FD4FF),
                          bestScore: best,
                          onTap: () async {
                            await SoundService.playClick();
                            final questions = await QuestionGenerator
                                .generateVoltooidDeelwoordQuestions();
                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameScreen(
                                  title: 'Voltooid Deelwoord',
                                  instruction:
                                      'Zoek het voltooid deelwoord van:',
                                  questions: questions,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder(
                      valueListenable:
                          AnalyticsService.analyticsBox.listenable(),
                      builder: (context, _, __) {
                        final best = AnalyticsService.bestScoreForCategory(
                            'Verleden Tijd');
                        return _MenuButton(
                          title: 'Verleden Tijd',
                          subtitle: 'Train werkwoorden in de verleden tijd',
                          icon: Icons.history_rounded,
                          glowColor: const Color(0xFF4CFF6B),
                          bestScore: best,
                          onTap: () async {
                            await SoundService.playClick();
                            final questions = await QuestionGenerator
                                .generateVerledenTijdQuestions();
                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameScreen(
                                  title: 'Verleden Tijd',
                                  instruction: 'Zoek de verleden tijd van:',
                                  questions: questions,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _MenuButton(
                      glowColor: const Color(0xFFB56CFF),
                      title: 'Mijn groei',
                      subtitle: 'Bekijk je voortgang en prestaties',
                      icon: Icons.insights_rounded,
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
                    const SizedBox(height: 20),
                    const _LockedButton(
                      title: 'Onregelmatige Werkwoorden',
                      subtitle: 'Binnenkort beschikbaar',
                    ),
                    const SizedBox(height: 20),
                    const _LockedButton(
                      title: 'Passieve Vorm',
                      subtitle: 'Binnenkort beschikbaar',
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color glowColor;
  final int? bestScore;

  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.glowColor,
    this.bestScore,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: glowColor.withOpacity(0.12),
        highlightColor: glowColor.withOpacity(0.06),
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
                  glowColor.withOpacity(0.18),
                  const Color(0xF0122638),
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: glowColor.withOpacity(0.38)),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.12),
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
                  color: glowColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: glowColor.withOpacity(0.32)),
                ),
                child: Icon(icon, color: glowColor, size: 27),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (bestScore == null)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      )
                    else
                      _InlineBestScore(score: bestScore!, total: 15),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: glowColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedButton extends StatelessWidget {
  final String title;
  final String subtitle;

  const _LockedButton({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xE8203040),
            Color(0xE8152535),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white38,
              size: 25,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white30,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineBestScore extends StatelessWidget {
  final int score;
  final int total;

  const _InlineBestScore({
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StarRating(score: score, total: total),
        const SizedBox(width: 8),
        Text(
          'Beste score: $score/$total',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  final int score;
  final int total;

  const _StarRating({required this.score, required this.total});

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
            size: 20,
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
