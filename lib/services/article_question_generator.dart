import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/article_noun.dart';
import '../models/grammar_question.dart';
import 'learning_level_service.dart';
import 'pronoun_question_generator.dart';

class ArticleQuestionGenerator {
  static const _assetPath = 'assets/data/articles.json';
  static final Random _random = Random();
  static const deHetExerciseId = 'De / Het';
  static const dezeDitExerciseId = 'Deze / Dit';
  static const dieDatExerciseId = 'Die / Dat';

  static List<ArticleNoun>? _cache;

  static Future<List<GrammarQuestion>> generateDeHetQuestions() async {
    return generateDeHetQuestionSet(count: 15);
  }

  static Future<List<GrammarQuestion>> generateDezeDitQuestions() async {
    return generateDezeDitQuestionSet(count: 15);
  }

  static Future<List<GrammarQuestion>> generateDieDatQuestions() async {
    return generateDieDatQuestionSet(count: 15);
  }

  static Future<List<GrammarQuestion>> generateMixedGrammarQuestions() async {
    final questionGroups = await Future.wait([
      generateDeHetQuestionSet(count: 3),
      generateDezeDitQuestionSet(count: 3),
      generateDieDatQuestionSet(count: 3),
      PronounQuestionGenerator.generatePossessivePronounQuestionSet(count: 3),
      PronounQuestionGenerator.generatePersonalPronounQuestionSet(count: 3),
    ]);

    final questions = questionGroups.expand((group) => group).toList()
      ..shuffle(_random);
    return List.unmodifiable(questions);
  }

  static Future<List<GrammarQuestion>> generateDeHetQuestionSet({
    required int count,
  }) async {
    final nouns = await _loadNouns();
    final selectedNouns = _createQuiz(
      nouns,
      count,
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

  static Future<List<GrammarQuestion>> generateDezeDitQuestionSet({
    required int count,
  }) async {
    final nouns = await _loadNouns();
    final selectedNouns = _createQuiz(
      nouns,
      count,
      exerciseId: dezeDitExerciseId,
    );

    return List.unmodifiable(
      selectedNouns.map(
        (noun) {
          final articleOption = _phraseOptions(
            noun.word,
            firstOption: 'deze',
            secondOption: 'dit',
          );

          return GrammarQuestion(
            word: '___ ${noun.word}',
            correctAnswer: '${noun.demonstrative} ${noun.word}',
            options: articleOption,
            instructionKey: 'instructionDezeDit',
          );
        },
      ),
    );
  }

  static Future<List<GrammarQuestion>> generateDieDatQuestionSet({
    required int count,
  }) async {
    final nouns = await _loadNouns();
    final selectedNouns = _createQuiz(
      nouns,
      count,
      exerciseId: dieDatExerciseId,
    );

    return List.unmodifiable(
      selectedNouns.map(
        (noun) {
          final correctDemonstrative = noun.article == 'de' ? 'die' : 'dat';
          final options = _phraseOptions(
            noun.word,
            firstOption: 'die',
            secondOption: 'dat',
          );

          return GrammarQuestion(
            word: 'Ik wil ___ ${noun.word}.',
            correctAnswer: '$correctDemonstrative ${noun.word}',
            options: options,
            instructionKey: 'instructionDieDat',
          );
        },
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

  static List<String> _phraseOptions(
    String word, {
    required String firstOption,
    required String secondOption,
  }) {
    final options = [
      '$firstOption $word',
      '$secondOption $word',
    ]..shuffle(_random);

    return List.unmodifiable(options);
  }
}
