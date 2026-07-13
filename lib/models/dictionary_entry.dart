import 'grammar_question.dart';

enum DictionaryEntryType {
  verb,
  article,
  generic,
}

class DictionaryEntry {
  final String word;
  final DictionaryEntryType type;
  final String source;
  final String category;
  final String categoryTitle;
  final String? presentTense;
  final String? pastTense;
  final String? pastParticiple;
  final String? presentParticiple;
  final String? article;
  final String? demonstrative;

  const DictionaryEntry({
    required this.word,
    required this.type,
    required this.source,
    required this.category,
    required this.categoryTitle,
    this.presentTense,
    this.pastTense,
    this.pastParticiple,
    this.presentParticiple,
    this.article,
    this.demonstrative,
  });

  String get typeLabelKey {
    switch (type) {
      case DictionaryEntryType.verb:
        return 'verbs';
      case DictionaryEntryType.article:
        return 'articles';
      case DictionaryEntryType.generic:
        return 'dictionary';
    }
  }

  String get favoriteExerciseId => 'dictionary_${type.name}';

  GrammarQuestion toFavoriteQuestion() {
    switch (type) {
      case DictionaryEntryType.article:
        return GrammarQuestion(
          word: word,
          correctAnswer: article ?? word,
          options: const ['de', 'het'],
          instructionKey: 'instructionDeHet',
          category: category,
          categoryTitle: categoryTitle,
          exercise: favoriteExerciseId,
          exerciseTitle: categoryTitle,
        );
      case DictionaryEntryType.verb:
      case DictionaryEntryType.generic:
        final answer = pastParticiple ?? pastTense ?? presentTense ?? word;
        return GrammarQuestion(
          word: word,
          correctAnswer: answer,
          options: List.unmodifiable({answer, word}),
          instructionKey: 'instructionPastParticiple',
          category: category,
          categoryTitle: categoryTitle,
          exercise: favoriteExerciseId,
          exerciseTitle: categoryTitle,
        );
    }
  }
}
