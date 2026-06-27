import '../models/grammar_question.dart';
import '../models/verb_model.dart';
import 'verb_loader.dart';

typedef _VerbFormSelector = String Function(VerbModel verb);

class QuestionGenerator {
  static Future<List<GrammarQuestion>> generateVerledenTijdQuestions(
      {List<VerbModel>? verbs}) async {
    final source = verbs ?? await VerbLoader.loadVerbs();
    return _generateQuestions(
      source,
      answerFor: (verb) => verb.verledenTijd,
    );
  }

  static Future<List<GrammarQuestion>> generateVoltooidDeelwoordQuestions(
      {List<VerbModel>? verbs}) async {
    final source = verbs ?? await VerbLoader.loadVerbs();
    return _generateQuestions(
      source,
      answerFor: (verb) => verb.voltooidDeelwoord,
    );
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
