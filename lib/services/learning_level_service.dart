import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

enum LearningLevel {
  a1,
  a2,
  b1,
  b2,
}

class LearningProgress {
  final LearningLevel currentLevel;
  final List<int> lastScores;
  final int averageScore;
  final int completedSessionCount;

  const LearningProgress({
    required this.currentLevel,
    required this.lastScores,
    required this.averageScore,
    required this.completedSessionCount,
  });
}

class LearningLevelService {
  static const String boxName = 'learningLevelBox';
  static const String autoMode = 'auto';
  static const String defaultMode = autoMode;

  static const _modeKey = 'mode';
  static const _progressPrefix = 'exerciseProgress';
  static final Random _random = Random();

  static Future<void> initialize() async {
    await _box();
  }

  static String getMode() {
    final mode = _boxSync().get(_modeKey, defaultValue: defaultMode);
    if (mode is String && _isValidMode(mode)) {
      return mode;
    }

    return defaultMode;
  }

  static Future<void> setMode(String mode) async {
    final normalizedMode = mode.trim().toLowerCase();
    if (!_isValidMode(normalizedMode)) return;

    await _boxSync().put(_modeKey, normalizedMode);
  }

  static bool get isAutoMode => getMode() == autoMode;

  static LearningLevel levelForExercise(String exerciseId) {
    final mode = getMode();
    if (mode != autoMode) {
      return _levelFromCode(mode);
    }

    return progressForExercise(exerciseId).currentLevel;
  }

  static LearningProgress progressForExercise(String exerciseId) {
    final progress = _readProgress(exerciseId);
    return LearningProgress(
      currentLevel: _levelFromCode(
        progress['level'] as String? ?? _levelCode(LearningLevel.a1),
      ),
      lastScores: List<int>.from(progress['scores'] as List? ?? const []),
      averageScore: progress['average'] as int? ?? 0,
      completedSessionCount: progress['sessions'] as int? ?? 0,
    );
  }

  static Future<void> recordSession({
    required String exerciseId,
    required int score,
    required int total,
  }) async {
    if (isMixedExercise(exerciseId) || total <= 0) return;

    final progress = _readProgress(exerciseId);
    final scores = List<int>.from(progress['scores'] as List? ?? const []);
    final percentage = ((score / total) * 100).round();

    scores.add(percentage);
    while (scores.length > 3) {
      scores.removeAt(0);
    }

    final average = scores.isEmpty
        ? 0
        : (scores.reduce((sum, value) => sum + value) / scores.length).round();
    final currentLevel = _levelFromCode(
      progress['level'] as String? ?? _levelCode(LearningLevel.a1),
    );
    final nextLevel = _updatedLevel(
      currentLevel: currentLevel,
      average: average,
      hasThreeSessions: scores.length == 3,
    );
    final completedSessionCount = (progress['sessions'] as int? ?? 0) + 1;

    await _boxSync().put(_progressKey(exerciseId), {
      'level': _levelCode(nextLevel),
      'scores': scores,
      'average': average,
      'sessions': completedSessionCount,
    });
  }

  static bool isMixedExercise(String exerciseId) {
    final normalizedId = exerciseId.trim().toLowerCase();
    return normalizedId.contains('gemengd') || normalizedId.contains('mixed');
  }

  static List<T> selectQuestionsForExercise<T>({
    required String exerciseId,
    required List<T> items,
    required String Function(T item) levelForItem,
    int count = 15,
  }) {
    final level = levelForExercise(exerciseId);
    return selectQuestionsForLevel(
      level: level,
      items: items,
      levelForItem: levelForItem,
      count: count,
    );
  }

  static List<T> selectQuestionsForLevel<T>({
    required LearningLevel level,
    required List<T> items,
    required String Function(T item) levelForItem,
    int count = 15,
  }) {
    if (items.length <= count) {
      return List.unmodifiable(List<T>.from(items)..shuffle(_random));
    }

    final selected = <T>[];
    final selectedItems = <T>{};
    final distribution = _distributionFor(level, count);

    for (final entry in distribution.entries) {
      final matchingItems = items
          .where((item) => _normalizeLevel(levelForItem(item)) == entry.key)
          .toList()
        ..shuffle(_random);

      for (final item in matchingItems.take(entry.value)) {
        selected.add(item);
        selectedItems.add(item);
      }
    }

    if (selected.length < count) {
      final remaining = items
          .where((item) => !selectedItems.contains(item))
          .toList()
        ..shuffle(_random);

      selected.addAll(remaining.take(count - selected.length));
    }

    selected.shuffle(_random);
    return List.unmodifiable(selected.take(count));
  }

  static Future<Box<dynamic>> _box() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }

    return Hive.openBox<dynamic>(boxName);
  }

  static Box<dynamic> _boxSync() {
    if (!Hive.isBoxOpen(boxName)) {
      throw StateError(
        'LearningLevelService must be initialized before use.',
      );
    }

    return Hive.box<dynamic>(boxName);
  }

  static Map<String, dynamic> _readProgress(String exerciseId) {
    final progress = _boxSync().get(_progressKey(exerciseId));
    if (progress is Map) {
      return Map<String, dynamic>.from(progress);
    }

    return {
      'level': _levelCode(LearningLevel.a1),
      'scores': <int>[],
      'average': 0,
      'sessions': 0,
    };
  }

  static String _progressKey(String exerciseId) {
    return '$_progressPrefix:${exerciseId.trim()}';
  }

  static LearningLevel _updatedLevel({
    required LearningLevel currentLevel,
    required int average,
    required bool hasThreeSessions,
  }) {
    if (!hasThreeSessions) return currentLevel;

    if (average >= 90) {
      return _nextLevel(currentLevel);
    }

    if (average <= 50) {
      return _previousLevel(currentLevel);
    }

    return currentLevel;
  }

  static LearningLevel _nextLevel(LearningLevel level) {
    final index = LearningLevel.values.indexOf(level);
    return LearningLevel
        .values[min(index + 1, LearningLevel.values.length - 1)];
  }

  static LearningLevel _previousLevel(LearningLevel level) {
    final index = LearningLevel.values.indexOf(level);
    return LearningLevel.values[max(index - 1, 0)];
  }

  static Map<String, int> _distributionFor(LearningLevel level, int count) {
    switch (level) {
      case LearningLevel.a1:
        return {'A1': count};
      case LearningLevel.a2:
        return {
          'A2': (count * 0.8).round(),
          'A1': count - (count * 0.8).round(),
        };
      case LearningLevel.b1:
        final b1 = (count * 0.7).round();
        final a2 = (count * 0.2).round();
        return {
          'B1': b1,
          'A2': a2,
          'B2': count - b1 - a2,
        };
      case LearningLevel.b2:
        final b2 = (count * 0.8).round();
        return {
          'B2': b2,
          'B1': count - b2,
        };
    }
  }

  static bool _isValidMode(String mode) {
    return mode == autoMode || ['a1', 'a2', 'b1', 'b2'].contains(mode);
  }

  static String _normalizeLevel(String level) {
    final normalizedLevel = level.trim().toUpperCase();
    if (['A1', 'A2', 'B1', 'B2'].contains(normalizedLevel)) {
      return normalizedLevel;
    }

    return 'A1';
  }

  static LearningLevel _levelFromCode(String code) {
    switch (code.trim().toLowerCase()) {
      case 'a2':
        return LearningLevel.a2;
      case 'b1':
        return LearningLevel.b1;
      case 'b2':
        return LearningLevel.b2;
      case 'a1':
      default:
        return LearningLevel.a1;
    }
  }

  static String _levelCode(LearningLevel level) {
    switch (level) {
      case LearningLevel.a1:
        return 'a1';
      case LearningLevel.a2:
        return 'a2';
      case LearningLevel.b1:
        return 'b1';
      case LearningLevel.b2:
        return 'b2';
    }
  }
}
