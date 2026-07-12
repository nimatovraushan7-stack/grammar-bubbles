import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/quiz_result.dart';
import '../services/analytics_service.dart';
import '../services/localization_service.dart';
import '../widgets/responsive_text.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LocalizationService.t;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ocean_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.50),
                  Colors.black.withOpacity(0.78),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderRow(onBack: () => Navigator.pop(context)),
                  const SizedBox(height: 22),
                  Expanded(
                    child: ValueListenableBuilder<Box<QuizResult>>(
                      valueListenable:
                          AnalyticsService.analyticsBox.listenable(),
                      builder: (context, box, _) {
                        final totalPlayed = AnalyticsService.totalPlayed;
                        final totalCorrect = AnalyticsService.totalCorrect;
                        final averageScore = AnalyticsService.averagePercentage;
                        final bestScore = AnalyticsService.bestScore;
                        final streak = AnalyticsService.streak;
                        final lastResult = AnalyticsService.lastResult;
                        final categories = AnalyticsService.categoryProgress;
                        final weekly = AnalyticsService.last7DaysPerformance;

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ResponsiveText(
                                l('grammarAnalytics').toUpperCase(),
                                maxLines: 1,
                                minFontSize: 14,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ResponsiveText(
                                l('analyticsSubtitle'),
                                maxLines: 3,
                                minFontSize: 12,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 26),
                              _StreakCard(streak: streak),
                              const SizedBox(height: 22),
                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: [
                                  _StatCard(
                                    label: l('average'),
                                    value: '$averageScore%',
                                    accent: const Color(0xFF78D8FF),
                                    icon: Icons.track_changes_rounded,
                                  ),
                                  _StatCard(
                                    label: l('best'),
                                    value: '$bestScore/15',
                                    accent: const Color(0xFFFFD25B),
                                    icon: Icons.emoji_events_rounded,
                                  ),
                                  _StatCard(
                                    label: l('played'),
                                    value: '$totalPlayed',
                                    accent: const Color(0xFF6CFF8A),
                                    icon: Icons.bar_chart_rounded,
                                  ),
                                  _StatCard(
                                    label: l('good'),
                                    value: '$totalCorrect',
                                    accent: const Color(0xFF9A6CFF),
                                    icon: Icons.check_circle_rounded,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              ResponsiveText(
                                l('last7Days'),
                                maxLines: 1,
                                minFontSize: 12,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _DailyPerformanceChart(weekly: weekly),
                              const SizedBox(height: 28),
                              ResponsiveText(
                                l('categoryPerformance'),
                                maxLines: 1,
                                minFontSize: 12,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Column(
                                children: categories
                                    .map((category) => _CategoryPerformanceCard(
                                          category: category.category,
                                          percentage: category.percentage,
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 24),
                              if (lastResult != null)
                                _LastScoreCard(lastResult: lastResult),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final VoidCallback onBack;

  const _HeaderRow({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ResponsiveText(
            LocalizationService.t('oceanMode'),
            maxLines: 1,
            minFontSize: 10,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6CFF8A).withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFF6CFF8A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResponsiveText(
                        LocalizationService.t('currentStreak'),
                        maxLines: 1,
                        minFontSize: 10,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ResponsiveText(
                  LocalizationService.days(streak),
                  maxLines: 1,
                  minFontSize: 14,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2FD4FF), Color(0xFF5C6BFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2FD4FF).withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.whatshot,
              size: 34,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 28,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.14),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: accent,
              size: 24,
            ),
            const SizedBox(height: 14),
            ResponsiveText(
              label,
              maxLines: 1,
              minFontSize: 9,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ResponsiveText(
              value,
              maxLines: 1,
              minFontSize: 20,
              style: TextStyle(
                color: accent,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyPerformanceChart extends StatelessWidget {
  final List<DailyPerformance> weekly;

  const _DailyPerformanceChart({required this.weekly});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: weekly.map((performance) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 30,
                child: ResponsiveText(
                  performance.label,
                  maxLines: 1,
                  minFontSize: 9,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    Container(
                      height: 22,
                      width: MediaQuery.of(context).size.width *
                          (performance.percentage / 100) *
                          0.6,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2FD4FF), Color(0xFF6CFF8A)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 42,
                child: ResponsiveText(
                  '${performance.percentage}%',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  minFontSize: 9,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryPerformanceCard extends StatelessWidget {
  final String category;
  final int percentage;

  const _CategoryPerformanceCard({
    required this.category,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final barWidth = MediaQuery.of(context).size.width * 0.55;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            LocalizationService.categoryTitle(category),
            maxLines: 1,
            minFontSize: 10,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              Container(
                height: 20,
                width: barWidth * (percentage / 100),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB56CFF), Color(0xFF2FD4FF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2FD4FF).withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ResponsiveText(
            '$percentage%',
            maxLines: 1,
            minFontSize: 10,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _LastScoreCard extends StatelessWidget {
  final QuizResult lastResult;

  const _LastScoreCard({required this.lastResult});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            LocalizationService.t('lastScore'),
            maxLines: 1,
            minFontSize: 10,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ResponsiveText(
                  LocalizationService.categoryTitle(lastResult.category),
                  maxLines: 1,
                  minFontSize: 10,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ResponsiveText(
                '${lastResult.score}/${lastResult.total}',
                maxLines: 1,
                minFontSize: 12,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            lastResult.isoDate,
            maxLines: 1,
            minFontSize: 9,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
