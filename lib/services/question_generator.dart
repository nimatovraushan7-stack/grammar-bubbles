import 'dart:math';

import '../models/grammar_question.dart';
import '../models/verb_model.dart';
import 'verb_loader.dart';

typedef _VerbFormSelector = String Function(VerbModel verb);

enum QuizType {
  voltooidDeelwoord,
  verledenTijd,
}

enum VerbCategory {
  regular,
  irregular,
  mixed,
}

class QuestionGenerator {
  static final Random _random = Random();

  static Future<List<GrammarQuestion>> generateVerledenTijdQuestions(
      {List<VerbModel>? verbs}) async {
    return generateQuestions(
      quizType: QuizType.verledenTijd,
      verbCategory: VerbCategory.mixed,
      verbs: verbs,
    );
  }

  static Future<List<GrammarQuestion>> generateVoltooidDeelwoordQuestions(
      {List<VerbModel>? verbs}) async {
    return generateQuestions(
      quizType: QuizType.voltooidDeelwoord,
      verbCategory: VerbCategory.mixed,
      verbs: verbs,
    );
  }

  static Future<List<GrammarQuestion>> generateQuestions({
    required QuizType quizType,
    required VerbCategory verbCategory,
    List<VerbModel>? verbs,
  }) async {
    final source = verbs ?? await createQuizForCategory(verbCategory);
    return _generateQuestions(
      source,
      answerFor: _answerSelectorFor(quizType),
    );
  }

  static Future<List<GrammarQuestion>>
      generateRegelmatigeVoltooidDeelwoordQuestions() async {
    return generateQuestions(
      quizType: QuizType.voltooidDeelwoord,
      verbCategory: VerbCategory.regular,
    );
  }

  static Future<List<GrammarQuestion>>
      generateOnregelmatigeVoltooidDeelwoordQuestions() async {
    return generateQuestions(
      quizType: QuizType.voltooidDeelwoord,
      verbCategory: VerbCategory.irregular,
    );
  }

  static Future<List<GrammarQuestion>>
      generateGemengdeVoltooidDeelwoordQuestions() async {
    return generateQuestions(
      quizType: QuizType.voltooidDeelwoord,
      verbCategory: VerbCategory.mixed,
    );
  }

  static Future<List<GrammarQuestion>>
      generateRegelmatigeVerledenTijdQuestions() async {
    return generateQuestions(
      quizType: QuizType.verledenTijd,
      verbCategory: VerbCategory.regular,
    );
  }

  static Future<List<GrammarQuestion>>
      generateOnregelmatigeVerledenTijdQuestions() async {
    return generateQuestions(
      quizType: QuizType.verledenTijd,
      verbCategory: VerbCategory.irregular,
    );
  }

  static Future<List<GrammarQuestion>>
      generateGemengdeVerledenTijdQuestions() async {
    return generateQuestions(
      quizType: QuizType.verledenTijd,
      verbCategory: VerbCategory.mixed,
    );
  }

  static Future<List<VerbModel>> createQuizForCategory(
    VerbCategory verbCategory,
  ) {
    switch (verbCategory) {
      case VerbCategory.regular:
        return createRegularQuiz();
      case VerbCategory.irregular:
        return createIrregularQuiz();
      case VerbCategory.mixed:
        return createMixedQuiz();
    }
  }

  static Future<List<VerbModel>> createRegularQuiz() async {
    final regularVerbs = await VerbLoader.loadRegularVerbs();
    return createQuiz(regularVerbs, 15);
  }

  static Future<List<VerbModel>> createIrregularQuiz() async {
    final irregularVerbs = await VerbLoader.loadIrregularVerbs();
    return createQuiz(irregularVerbs, 15);
  }

  static Future<List<VerbModel>> createMixedQuiz() async {
    final regularVerbs = await VerbLoader.loadRegularVerbs();
    final irregularVerbs = await VerbLoader.loadIrregularVerbs();

    final mixedQuiz = [
      ...createQuiz(regularVerbs, 7),
      ...createQuiz(irregularVerbs, 8),
    ]..shuffle(_random);

    return List.unmodifiable(mixedQuiz);
  }

  static List<VerbModel> createQuiz(List<VerbModel> verbs, int count) {
    final shuffledVerbs = List<VerbModel>.from(verbs)..shuffle(_random);
    final selectedVerbs = <VerbModel>[];
    final selectedWords = <String>{};

    for (final verb in shuffledVerbs) {
      final word = verb.word.trim().toLowerCase();
      if (selectedWords.contains(word)) continue;

      selectedWords.add(word);
      selectedVerbs.add(verb);

      if (selectedVerbs.length == count) break;
    }

    if (selectedVerbs.length < count) {
      throw StateError(
        'Niet genoeg unieke werkwoorden om een quiz van $count vragen te maken.',
      );
    }

    return List.unmodifiable(selectedVerbs);
  }

  static _VerbFormSelector _answerSelectorFor(QuizType quizType) {
    switch (quizType) {
      case QuizType.voltooidDeelwoord:
        return (verb) => verb.voltooidDeelwoord;
      case QuizType.verledenTijd:
        return (verb) => verb.verledenTijd;
    }
  }

  static List<GrammarQuestion> _generateQuestions(
    List<VerbModel> verbs, {
    required _VerbFormSelector answerFor,
  }) {
    return List.unmodifiable(
      verbs.map((verb) {
        final correctAnswer = answerFor(verb);
        final options = <String>{
          correctAnswer,
          verb.verledenTijd,
          verb.voltooidDeelwoord,
          verb.tegenwoordigeTijd,
          verb.word,
          verb.tegenwoordigDeelwoord,
        };

        // Some verbs share forms, such as "verkocht". Fill those gaps with
        // plausible answers from the same category so every question has five.
        for (final otherVerb in verbs) {
          if (options.length >= 5) break;
          options.add(answerFor(otherVerb));
        }

        if (options.length < 5) {
          throw StateError(
            'Niet genoeg unieke antwoordopties voor ${verb.word}.',
          );
        }

        final shuffledOptions = options.take(5).toList()..shuffle();
        return GrammarQuestion(
          word: verb.word,
          correctAnswer: correctAnswer,
          options: List.unmodifiable(shuffledOptions),
        );
      }),
    );
  }
}
