import 'dart:math';

import '../models/grammar_question.dart';
import '../models/verb_model.dart';
import 'learning_level_service.dart';
import 'verb_loader.dart';

typedef _VerbFormSelector = String Function(VerbModel verb);

enum QuizType {
  voltooidDeelwoord,
  verledenTijd,
  separableVerb,
}

enum VerbCategory {
  regular,
  irregular,
  mixed,
}

class QuestionGenerator {
  static final Random _random = Random();

  static const pastParticipleRegularId = 'Voltooid Deelwoord - Regelmatig';
  static const pastParticipleIrregularId = 'Voltooid Deelwoord - Onregelmatig';
  static const pastParticipleSeparableId = 'Voltooid Deelwoord - Scheidbaar';
  static const pastTenseRegularId = 'Verleden Tijd - Regelmatig';
  static const pastTenseIrregularId = 'Verleden Tijd - Onregelmatig';
  static const pastTenseSeparableId = 'Verleden Tijd - Scheidbaar';

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

  static Future<List<GrammarQuestion>> generateSeparableVerbQuestions() async {
    final verbs = await createSeparableQuiz();
    return _generateQuestions(
      verbs,
      answerFor: _answerSelectorFor(QuizType.separableVerb),
      instructionKey: 'instructionSeparableVerb',
    );
  }

  static Future<List<GrammarQuestion>>
      generateScheidbareVoltooidDeelwoordQuestions() async {
    final verbs = await createSeparableQuiz(
      exerciseId: pastParticipleSeparableId,
    );
    return generateQuestions(
      quizType: QuizType.voltooidDeelwoord,
      verbCategory: VerbCategory.mixed,
      verbs: verbs,
    );
  }

  static Future<List<GrammarQuestion>>
      generateScheidbareVerledenTijdQuestions() async {
    final verbs = await createSeparableQuiz(
      exerciseId: pastTenseSeparableId,
    );
    return generateQuestions(
      quizType: QuizType.verledenTijd,
      verbCategory: VerbCategory.mixed,
      verbs: verbs,
    );
  }

  static Future<List<GrammarQuestion>> generateMixedVerbQuestions() async {
    final pastParticipleVerbs = await createQuizForCategory(VerbCategory.mixed);
    final pastTenseVerbs = await createQuizForCategory(VerbCategory.mixed);
    final separableVerbs = await createSeparableQuiz(count: 5);

    final questions = [
      ..._generateQuestions(
        pastParticipleVerbs.take(5).toList(growable: false),
        answerFor: _answerSelectorFor(QuizType.voltooidDeelwoord),
        instructionKey: 'instructionPastParticiple',
      ),
      ..._generateQuestions(
        pastTenseVerbs.take(5).toList(growable: false),
        answerFor: _answerSelectorFor(QuizType.verledenTijd),
        instructionKey: 'instructionPastTense',
      ),
      ..._generateQuestions(
        separableVerbs,
        answerFor: _answerSelectorFor(QuizType.separableVerb),
        instructionKey: 'instructionSeparableVerb',
      ),
    ]..shuffle(_random);

    return List.unmodifiable(questions);
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
    final verbs = await createRegularQuiz(
      exerciseId: pastParticipleRegularId,
    );
    return generateQuestions(
      quizType: QuizType.voltooidDeelwoord,
      verbCategory: VerbCategory.regular,
      verbs: verbs,
    );
  }

  static Future<List<GrammarQuestion>>
      generateOnregelmatigeVoltooidDeelwoordQuestions() async {
    final verbs = await createIrregularQuiz(
      exerciseId: pastParticipleIrregularId,
    );
    return generateQuestions(
      quizType: QuizType.voltooidDeelwoord,
      verbCategory: VerbCategory.irregular,
      verbs: verbs,
    );
  }

  static Future<List<GrammarQuestion>>
      generateGemengdeVoltooidDeelwoordQuestions() async {
    return generateBalancedMixedQuestions(quizType: QuizType.voltooidDeelwoord);
  }

  static Future<List<GrammarQuestion>>
      generateRegelmatigeVerledenTijdQuestions() async {
    final verbs = await createRegularQuiz(
      exerciseId: pastTenseRegularId,
    );
    return generateQuestions(
      quizType: QuizType.verledenTijd,
      verbCategory: VerbCategory.regular,
      verbs: verbs,
    );
  }

  static Future<List<GrammarQuestion>>
      generateOnregelmatigeVerledenTijdQuestions() async {
    final verbs = await createIrregularQuiz(
      exerciseId: pastTenseIrregularId,
    );
    return generateQuestions(
      quizType: QuizType.verledenTijd,
      verbCategory: VerbCategory.irregular,
      verbs: verbs,
    );
  }

  static Future<List<GrammarQuestion>>
      generateGemengdeVerledenTijdQuestions() async {
    return generateBalancedMixedQuestions(quizType: QuizType.verledenTijd);
  }

  static Future<List<GrammarQuestion>> generateBalancedMixedQuestions({
    required QuizType quizType,
  }) async {
    final regularVerbs = await VerbLoader.loadRegularVerbs();
    final irregularVerbs = await VerbLoader.loadIrregularVerbs();
    final separableVerbs = await VerbLoader.loadSeparableVerbs();
    final isPastParticiple = quizType == QuizType.voltooidDeelwoord;

    final selectedVerbs = [
      ...createQuizForExercise(
        regularVerbs,
        5,
        isPastParticiple ? pastParticipleRegularId : pastTenseRegularId,
      ),
      ...createQuizForExercise(
        irregularVerbs,
        5,
        isPastParticiple ? pastParticipleIrregularId : pastTenseIrregularId,
      ),
      ...createQuizForExercise(
        separableVerbs,
        5,
        isPastParticiple ? pastParticipleSeparableId : pastTenseSeparableId,
      ),
    ]..shuffle(_random);

    return _generateQuestions(
      selectedVerbs,
      answerFor: _answerSelectorFor(quizType),
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

  static Future<List<VerbModel>> createRegularQuiz({String? exerciseId}) async {
    final regularVerbs = await VerbLoader.loadRegularVerbs();
    return createQuizForExercise(regularVerbs, 15, exerciseId);
  }

  static Future<List<VerbModel>> createIrregularQuiz({
    String? exerciseId,
  }) async {
    final irregularVerbs = await VerbLoader.loadIrregularVerbs();
    return createQuizForExercise(irregularVerbs, 15, exerciseId);
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

  static Future<List<VerbModel>> createSeparableQuiz({
    int count = 15,
    String? exerciseId,
  }) async {
    final separableVerbs = await VerbLoader.loadSeparableVerbs();
    return createQuizForExercise(separableVerbs, count, exerciseId);
  }

  static List<VerbModel> createQuizForExercise(
    List<VerbModel> verbs,
    int count,
    String? exerciseId,
  ) {
    if (exerciseId == null) {
      return createQuiz(verbs, count);
    }

    final selectedVerbs = LearningLevelService.selectQuestionsForExercise(
      exerciseId: exerciseId,
      items: verbs,
      levelForItem: (verb) => verb.level,
      count: count,
    );

    if (selectedVerbs.length < count) {
      throw StateError(
        'Niet genoeg unieke werkwoorden om een quiz van $count vragen te maken.',
      );
    }

    return List.unmodifiable(selectedVerbs);
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
      case QuizType.separableVerb:
        return (verb) => verb.voltooidDeelwoord;
    }
  }

  static List<GrammarQuestion> _generateQuestions(
    List<VerbModel> verbs, {
    required _VerbFormSelector answerFor,
    String? instructionKey,
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
          instructionKey: instructionKey,
        );
      }),
    );
  }
}
