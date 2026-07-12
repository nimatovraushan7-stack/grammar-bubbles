import 'grammar_question.dart';

class FavoriteItem {
  final String id;
  final String category;
  final String categoryTitle;
  final String exercise;
  final String exerciseTitle;
  final String instruction;
  final String word;
  final String correctAnswer;
  final List<String> options;
  final String? instructionKey;
  final DateTime createdAt;

  const FavoriteItem({
    required this.id,
    required this.category,
    required this.categoryTitle,
    required this.exercise,
    required this.exerciseTitle,
    required this.instruction,
    required this.word,
    required this.correctAnswer,
    required this.options,
    required this.createdAt,
    this.instructionKey,
  });

  factory FavoriteItem.fromQuestion({
    required GrammarQuestion question,
    required String category,
    required String categoryTitle,
    required String exercise,
    required String exerciseTitle,
    required String instruction,
  }) {
    final id = createId(
      category: category,
      exercise: exercise,
      word: question.word,
      correctAnswer: question.correctAnswer,
    );

    return FavoriteItem(
      id: id,
      category: category,
      categoryTitle: categoryTitle,
      exercise: exercise,
      exerciseTitle: exerciseTitle,
      instruction: instruction,
      word: question.word,
      correctAnswer: question.correctAnswer,
      options: List.unmodifiable(question.options),
      instructionKey: question.instructionKey,
      createdAt: DateTime.now(),
    );
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] as String,
      category: json['category'] as String,
      categoryTitle:
          json['categoryTitle'] as String? ?? json['category'] as String,
      exercise: json['exercise'] as String,
      exerciseTitle:
          json['exerciseTitle'] as String? ?? json['exercise'] as String,
      instruction: json['instruction'] as String? ?? '',
      word: json['word'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: List<String>.from(json['options'] as List),
      instructionKey: json['instructionKey'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static String createId({
    required String category,
    required String exercise,
    required String word,
    required String correctAnswer,
  }) {
    return [
      category,
      exercise,
      word.trim().toLowerCase(),
      correctAnswer.trim().toLowerCase(),
    ].join('|');
  }

  GrammarQuestion toQuestion() {
    return GrammarQuestion(
      word: word,
      correctAnswer: correctAnswer,
      options: List.unmodifiable(options),
      instructionKey: instructionKey,
      category: category,
      categoryTitle: categoryTitle,
      exercise: exercise,
      exerciseTitle: exerciseTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'categoryTitle': categoryTitle,
      'exercise': exercise,
      'exerciseTitle': exerciseTitle,
      'instruction': instruction,
      'word': word,
      'correctAnswer': correctAnswer,
      'options': options,
      if (instructionKey != null) 'instructionKey': instructionKey,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
