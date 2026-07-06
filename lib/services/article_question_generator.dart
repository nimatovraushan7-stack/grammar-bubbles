import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/article_noun.dart';
import '../models/grammar_question.dart';
import 'learning_level_service.dart';

class ArticleQuestionGenerator {
  static const _assetPath = 'assets/data/articles.json';
  static final Random _random = Random();
  static const deHetExerciseId = 'De / Het';

  static List<ArticleNoun>? _cache;

  static Future<List<GrammarQuestion>> generateDeHetQuestions() async {
    final nouns = await _loadNouns();
    final selectedNouns = _createQuiz(
      nouns,
      15,
      exerciseId: deHetExerciseId,
    );

    return List.unmodifiable(
      selectedNouns.map(
        (noun) => GrammarQuestion(
          word: noun.word,
          correctAnswer: noun.article,
          options: const ['de', 'het'],
        ),
      ),
    );
  }

  static Future<List<ArticleNoun>> _loadNouns() async {
    final cachedNouns = _cache;
    if (cachedNouns != null) return cachedNouns;

    final jsonString = await rootBundle.loadString(_assetPath);
    final jsonData = jsonDecode(jsonString);
    if (jsonData is! List) {
      throw const FormatException(
        'assets/data/articles.json moet een JSON-lijst bevatten.',
      );
    }

    final nouns = jsonData.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Elk item in assets/data/articles.json moet een JSON-object zijn.',
        );
      }
      return ArticleNoun.fromJson(item);
    }).toList(growable: false);

    _cache = List.unmodifiable(nouns);
    return _cache!;
  }

  static List<ArticleNoun> _createQuiz(
    List<ArticleNoun> nouns,
    int count, {
    String? exerciseId,
  }) {
    if (exerciseId != null) {
      return LearningLevelService.selectQuestionsForExercise(
        exerciseId: exerciseId,
        items: nouns,
        levelForItem: (noun) => noun.level,
        count: count,
      );
    }

    final shuffledNouns = List<ArticleNoun>.from(nouns)..shuffle(_random);
    final selectedNouns = <ArticleNoun>[];
    final selectedWords = <String>{};

    for (final noun in shuffledNouns) {
      final word = noun.word.trim().toLowerCase();
      if (selectedWords.contains(word)) continue;

      selectedWords.add(word);
      selectedNouns.add(noun);

      if (selectedNouns.length == count) break;
    }

    if (selectedNouns.length < count) {
      throw StateError(
        'Niet genoeg unieke zelfstandige naamwoorden om een quiz van $count vragen te maken.',
      );
    }

    return List.unmodifiable(selectedNouns);
  }
}
