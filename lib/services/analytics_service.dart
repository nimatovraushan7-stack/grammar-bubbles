import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/quiz_result.dart';

class DailyPerformance {
  final String label;
  final int score;
  final int total;
  final int percentage;

  DailyPerformance({
    required this.label,
    required this.score,
    required this.total,
    required this.percentage,
  });
}

class CategoryProgress {
  final String category;
  final int score;
  final int total;
  final int percentage;

  CategoryProgress({
    required this.category,
    required this.score,
    required this.total,
    required this.percentage,
  });
}

class AnalyticsService {
  static const String boxName = 'quizResults';
  static Box<QuizResult>? _box;

  static Box<QuizResult> get analyticsBox {
    if (_box == null) {
      throw StateError('AnalyticsService has not been initialized. Call AnalyticsService.init() first.');
    }
    return _box!;
  }

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(QuizResultAdapter().typeId)) {
      Hive.registerAdapter(QuizResultAdapter());
    }

    _box = await Hive.openBox<QuizResult>(boxName);
  }

  static Future<void> saveQuizResult({
    required String category,
    required int score,
    required int total,
  }) async {
    final result = QuizResult(
      date: DateTime.now(),
      category: category,
      score: score,
      total: total,
    );

    await analyticsBox.add(result);
  }

  static List<QuizResult> get allResults => analyticsBox.values.toList();

  static int get totalPlayed => allResults.length;

  static int get totalCorrect =>
      allResults.fold(0, (previous, result) => previous + result.score);

  static int get totalQuestions =>
      allResults.fold(0, (previous, result) => previous + result.total);

  static int get averagePercentage {
    if (totalQuestions == 0) return 0;
    return ((totalCorrect / totalQuestions) * 100).round();
  }

  static int get bestScore {
    if (allResults.isEmpty) return 0;
    return allResults.map((result) => result.score).reduce(max);
  }

  static QuizResult? get lastResult {
    if (allResults.isEmpty) return null;
    return allResults.last;
  }

  static int bestScoreForCategory(String category) {
    final filtered = allResults
        .where((result) => result.category == category)
        .toList(growable: false);

    if (filtered.isEmpty) return 0;
    return filtered.map((result) => result.score).reduce(max);
  }

  static int percentageForCategory(String category) {
    final filtered = allResults
        .where((result) => result.category == category)
        .toList(growable: false);

    if (filtered.isEmpty) return 0;

    final totalScore = filtered.fold(0, (sum, result) => sum + result.score);
    final totalQuestions = filtered.fold(0, (sum, result) => sum + result.total);

    if (totalQuestions == 0) return 0;
    return ((totalScore / totalQuestions) * 100).round();
  }

  static int get streak {
    if (allResults.isEmpty) return 0;

    final uniqueDates = allResults
        .map((result) => _normalizeDate(result.date))
        .toSet();

    final latestDay = uniqueDates.reduce((value, element) {
      return value.isAfter(element) ? value : element;
    });

    var streak = 0;
    var currentDay = latestDay;

    while (uniqueDates.contains(currentDay)) {
      streak += 1;
      currentDay = currentDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static List<DailyPerformance> get last7DaysPerformance {
    final today = _normalizeDate(DateTime.now());
    final performance = <DailyPerformance>[];

    for (var i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final resultsForDay = allResults
          .where((result) => _normalizeDate(result.date) == day)
          .toList(growable: false);

      final score = resultsForDay.fold(0, (sum, result) => sum + result.score);
      final total = resultsForDay.fold(0, (sum, result) => sum + result.total);
      final percentage = total == 0 ? 0 : ((score / total) * 100).round();
      final label = _weekdayLabel(day.weekday);

      performance.add(DailyPerformance(
        label: label,
        score: score,
        total: total,
        percentage: percentage,
      ));
    }

    return performance;
  }

  static List<CategoryProgress> get categoryProgress {
    const categories = [
      'Voltooid Deelwoord',
      'Verleden Tijd',
    ];

    return categories.map((category) {
      final results = allResults
          .where((result) => result.category == category)
          .toList(growable: false);
      final score = results.fold(0, (sum, result) => sum + result.score);
      final total = results.fold(0, (sum, result) => sum + result.total);
      final percentage = total == 0 ? 0 : ((score / total) * 100).round();

      return CategoryProgress(
        category: category,
        score: score,
        total: total,
        percentage: percentage,
      );
    }).toList(growable: false);
  }

  static String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Ma';
      case DateTime.tuesday:
        return 'Di';
      case DateTime.wednesday:
        return 'Wo';
      case DateTime.thursday:
        return 'Do';
      case DateTime.friday:
        return 'Vr';
      case DateTime.saturday:
        return 'Za';
      case DateTime.sunday:
        return 'Zo';
      default:
        return '';
    }
  }
}
