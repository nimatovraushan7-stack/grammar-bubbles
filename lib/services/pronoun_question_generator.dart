import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/grammar_question.dart';
import 'learning_level_service.dart';

class PronounQuestionGenerator {
  static const possessivePronounsExerciseId = 'Possessive Pronouns';
  static const personalPronounsExerciseId = 'Personal Pronouns';

  static const _possessiveAssetPath = 'assets/data/possessive_pronouns.json';
  static const _personalAssetPath = 'assets/data/personal_pronouns.json';

  static List<_PronounQuestionData>? _possessiveCache;
  static List<_PronounQuestionData>? _personalCache;

  static Future<List<GrammarQuestion>> generatePossessivePronounQuestions() {
    return generatePossessivePronounQuestionSet(count: 15);
  }

  static Future<List<GrammarQuestion>> generatePersonalPronounQuestions() {
    return generatePersonalPronounQuestionSet(count: 15);
  }

  static Future<List<GrammarQuestion>> generatePossessivePronounQuestionSet({
    required int count,
  }) async {
    final questions = await _loadPossessiveQuestions();
    return _createQuiz(
      questions,
      count,
      exerciseId: possessivePronounsExerciseId,
      instructionKey: 'instructionPossessivePronouns',
    );
  }

  static Future<List<GrammarQuestion>> generatePersonalPronounQuestionSet({
    required int count,
  }) async {
    final questions = await _loadPersonalQuestions();
    return _createQuiz(
      questions,
      count,
      exerciseId: personalPronounsExerciseId,
      instructionKey: 'instructionPersonalPronouns',
    );
  }

  static Future<List<_PronounQuestionData>> _loadPossessiveQuestions() async {
    final cachedQuestions = _possessiveCache;
    if (cachedQuestions != null) return cachedQuestions;

    _possessiveCache = await _loadQuestions(_possessiveAssetPath);
    return _possessiveCache!;
  }

  static Future<List<_PronounQuestionData>> _loadPersonalQuestions() async {
    final cachedQuestions = _personalCache;
    if (cachedQuestions != null) return cachedQuestions;

    _personalCache = await _loadQuestions(_personalAssetPath);
    return _personalCache!;
  }

  static Future<List<_PronounQuestionData>> _loadQuestions(
    String assetPath,
  ) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonData = jsonDecode(jsonString);
    if (jsonData is! List) {
      throw FormatException('$assetPath moet een JSON-lijst bevatten.');
    }

    return List.unmodifiable(
      jsonData.map((item) {
        if (item is! Map<String, dynamic>) {
          throw FormatException(
            'Elk item in $assetPath moet een JSON-object zijn.',
          );
        }

        return _PronounQuestionData.fromJson(item);
      }),
    );
  }

  static List<GrammarQuestion> _createQuiz(
    List<_PronounQuestionData> questions,
    int count, {
    required String exerciseId,
    required String instructionKey,
  }) {
    final selectedQuestions = LearningLevelService.selectQuestionsForExercise(
      exerciseId: exerciseId,
      items: questions,
      levelForItem: (question) => question.level,
      count: count,
    );

    return List.unmodifiable(
      selectedQuestions.map(
        (question) => GrammarQuestion(
          word: question.word,
          correctAnswer: question.correctAnswer,
          options: question.options,
          instructionKey: instructionKey,
        ),
      ),
    );
  }
}

class _PronounQuestionData {
  final String word;
  final String correctAnswer;
  final List<String> options;
  final String level;

  const _PronounQuestionData({
    required this.word,
    required this.correctAnswer,
    required this.options,
    required this.level,
  });

  factory _PronounQuestionData.fromJson(Map<String, dynamic> json) {
    final options = json['options'];
    if (options is! List) {
      throw const FormatException('Pronoun question options must be a list.');
    }

    return _PronounQuestionData(
      word: _readString(json, 'word'),
      correctAnswer: _readString(json, 'correctAnswer'),
      options: List.unmodifiable(
        options.map((option) {
          if (option is! String || option.trim().isEmpty) {
            throw const FormatException(
              'Pronoun question options must be non-empty strings.',
            );
          }

          return option.trim();
        }),
      ),
      level: _readString(json, 'level'),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Ongeldige of ontbrekende waarde voor "$key".');
    }

    return value.trim();
  }
}
